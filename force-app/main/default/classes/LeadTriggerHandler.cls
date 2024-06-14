/************************************************************
* Created by:   Inpro
* Created on:   2/24/2022
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 2/24/2022     Inpro - David   Created
* 3/24/2022     Inpro - Ben     Updated notification assignment date to be only on business days
*************************************************************/
public with sharing class LeadTriggerHandler {
    private Map<Id, Lead> newMap;
    private Map<Id, Lead> oldMap;
    private List<Lead> trigNew;
    private List<Lead> trigOld;
    private Boolean isDelete;

    // Constructor used for Before/After Update handler
    public LeadTriggerHandler(Map<Id, Lead> triggerOldMap,  Map<Id, Lead> triggerNewMap, List<Lead> triggerOld, List<Lead> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;

        setupData();
    }

    //Private void method that will stage local variables and related data for use within the rest of the handler
    private void setupData() {
    }

    public void beforeInsert() {
        
    }

    public void beforeDelete() {
    }

    //Public void method called After Delete from the Lead Trigger
    public void afterDelete() {        
    }


    //Public void method called After Insert from the Lead Trigger
    public void afterInsert() {
        doTerritoryAssignment();
    }

    //Public void method called Before Update from the Lead Trigger
    public void beforeUpdate() {
    }

    //Public void method called After Update from the Lead Trigger
    public void afterUpdate() {
        doTerritoryAssignment();  
        //doSampleRequestOwnerAssignment(); 
        sendLeadAssignmentNotifications();     
    }
  
    private void doTerritoryAssignment() {        
        if(!Test.isRunningTest())
            if (this.trigNew.size() == 1) {
                Lead l = this.trigNew[0];
                if (l.Territory__c == null){      
                    string stateCode = '';
                    string zipCode = '';
                    string countryCode = '';

                    if(l.statecode != null)
                    stateCode = l.stateCode; 
                    if(l.postalcode != null)
                        zipCode = l.postalcode;
                    if(l.CountryCode != null)
                        countryCode = l.CountryCode;

                    TerritoryHelper.updateRecordTerritory('Lead', l.Id, l.postalcode, stateCode, countryCode);
                }
            }
            else 
            {
                List<string> recordIds = new List<string>();
                for (lead l : this.trigNew) {
                    recordIds.add(l.Id);
                }
                //TerritoryHelper.bulkUpdateTerritories('lead', recordIds);
            }                
    }

    private void doSampleRequestOwnerAssignment()
    {
        try {               
            
            if (this.trigNew.size() == 1) {
                Lead l = this.trigNew[0];
            List<Sample_Request__c> sampleRequestsToUpdate = new List<Sample_Request__c>();
            List<Sample_Request__c> sampleRequests = [SELECT ownerId, Lead__c, Id FROM Sample_Request__c WHERE Lead__c = :l.Id LIMIT 1];

                if(SampleRequests.size() > 0)
                {
                    for (Sample_Request__c sr : sampleRequests) {
                        Sample_Request__c sample = new Sample_Request__c();
                        sample.Id = sr.Id;
                        sample.OwnerId = l.OwnerId;
                        if(l.OwnerId.to15().startsWith('005'))
                        {
                            sample.ISR__c = l.OwnerId;
                        }
                        sampleRequestsToUpdate.add(sample);
                    }

                    if(sampleRequestsToUpdate.size() > 0)
                        update sampleRequestsToUpdate;
                }
            }
        } 
        catch (Exception ex) 
        {
            EmailSendHelper.sendEmail('dsieraski@inprocorp.com', '', 'Update Lead Sample Request Error', JSON.serialize(ex));
        }     
    }

    private void sendLeadAssignmentNotifications()
    {
        List<Lead> leadsToUpdate = new List<lead>();
        //for now run when it's only one record getting updated.
        if(this.trigNew.size() == 1)
        for (Lead l : this.trigNew) 
        {            
            Lead oldLead = this.oldMap.get(l.id);

            //Leads whose sample requests has already been shipped/delivered do not need notifications
            List<Sample_Request__c> sr = 
                [SELECT Id, Lead__c, Type__c, Status__c
                 FROM Sample_Request__c 
                 WHERE Lead__c = :l.Id 
                   AND Type__c = 'Web Request' 
                   AND (Status__c = 'Shipped' OR Status__c = 'Delivered') LIMIT 1];

            if(l.Lead_Notification_Sent__c == false && 
               l.OwnerId.to15().startsWith('005') &&
               l.OwnerId != l.CreatedById &&
               l.IsConverted == false &&
               l.OwnerId != oldLead.OwnerId &&
               l.Status != 'Nurture' &&
               sr.size() == 0)
               {
                    Lead lead = new Lead();
                    lead.Id = l.Id;

                    //Only assign on work days
                    string weekday = Datetime.now().format('E');

                    if (weekday == 'Sun')
                    {
                        lead.Date_Assigned_to_User__c = Datetime.now().addDays(1);
                    }
                    else if (weekday == 'Sat')
                    {
                        lead.Date_Assigned_to_User__c = Datetime.now().addDays(2);
                    }
                    else
                    {
                        lead.Date_Assigned_to_User__c = Datetime.now();
                    }
                    lead.Lead_Notification_Sent__c = true;

                    //this field seems redudant
                    //lead.Lead_Owner_s_Manager__c =

                    leadsToUpdate.add(lead);
                    EmailSendHelper.EmailSendDTO emailDTO = new EmailSendHelper.EmailSendDTO();
                    List<EmailSendHelper.EmailSendDTO> emailDTOList = new List<EmailSendHelper.EmailSendDTO>();
                    emailDTO.UserId = l.OwnerId;                    
                    emailDTO.RecordId = l.Id;
                    emailDTO.TemplateName = 'New_lead_Assignment_1st_Notification';
                    emailDTO.IncludeManager = false;      
                    emailDTOList.add(emailDTO);
                    EmailSendHelper.sendEmail(emailDTOList);
               }
        }
        update leadsToUpdate;
    }
}