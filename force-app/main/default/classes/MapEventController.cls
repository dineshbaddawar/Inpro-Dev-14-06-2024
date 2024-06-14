/**************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ==========================================================================
* Test Class:   LunchandLeanControllerTest
* ==========================================================================
* Purpose:      This is the controller class for MapEvent VF page.This 
*               controller class used to map the contact or lead to L & L event.
*				
* ==========================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   --------------------------------------------
* 4/21/2020     THG - JP        Created
*
****************************************************************************/
public class MapEventController {
    public LunchAndLearnEvent__c LunchAndLearnEventRecord{get;set;}
    public id LunchAndLearnId {get;set;} 
    public Boolean outputPanelFlag{get;set;}
    public String messageStr{get;set;}
    public Boolean successFlag {get;set;}
    public Boolean errorFlag {get;set;}
    
    public MapEventController(){
        LunchAndLearnId         =     ApexPages.currentPage().getParameters().get('Id');
        LunchAndLearnEventRecord   =     new LunchAndLearnEvent__c();
        outputPanelFlag       =     true;
        errorFlag           =     false;
        successFlag         =    false;
    }
    public PageReference submit(){
        LunchAndLearnEvent__c LunchRecord     =    new LunchAndLearnEvent__c();
        Event_Attendee__c CampaignMemberRecord    =     new Event_Attendee__c(); 
        List<Event_Attendee__c> existingMembers     =     new List<Event_Attendee__c>();
        LunchRecord               =     [SELECT Id, Name, Course_Name__c, Course_ID__c,Number_Attending__c FROM LunchAndLearnEvent__c where id=: LunchAndLearnId];
        if((String.valueOf( LunchAndLearnEventRecord.lookup_to_contact__c) !='') && (LunchAndLearnEventRecord.lookup_to_contact__c !=  null) ){
            
            Contact existingContact       =     new contact();
            existingContact           =     [Select Id ,Email from contact where id=:LunchAndLearnEventRecord.lookup_to_contact__c ];
            if(string.valueOf(existingContact.id) !='' && existingContact.id != null )
            {
                existingMembers=[SELECT Id, Contact__c, LunchAndLearnEvent__c,Course__c,Email_Opt_In__c,created_by_admin__c FROM Event_Attendee__c where Contact__c = : existingContact.Id AND Course__c= :LunchRecord.Course_Name__c  ];
                if( existingMembers != null && existingMembers.size() > 0){
                    existingMembers[0].LunchAndLearnEvent__c   =     LunchAndLearnId;
                    existingMembers[0].Email_Opt_In__c        =     false;
                    existingMembers[0].created_by_admin__c     =    true;
                    update existingMembers; 
                    updateNumberAttending(LunchRecord);
                    System.debug('Contact update');
                    messageStr                   =     'Successfully Updated the Contact';
                    successFlag                 =    true;
                    outputPanelFlag               =     false;    
                    //Database.executeBatch(new BatchEmailSendForCampaigns());
                    return null;
                }
                else
                {
                    CampaignMemberRecord.Course__c       =     LunchRecord.Course_Name__c;
                    CampaignMemberRecord.Contact__c         =      LunchAndLearnEventRecord.lookup_to_contact__c;
                    CampaignMemberRecord.LunchAndLearnEvent__c   =     LunchAndLearnId;
                    CampaignMemberRecord.Email_Opt_In__c        =     false;
                    CampaignMemberRecord.created_by_admin__c   =    true;
                    insert CampaignMemberRecord;
                    
                    updateNumberAttending(LunchRecord);
                    //Database.executeBatch(new BatchEmailSendForCampaigns());
                    outputPanelFlag               =     false;
                    successFlag                 =    true;
                    messageStr                   =     'Successfully Inserted The Contact';     
                    return null;  
                } 
            }             
        }else if(String.valueOf(LunchAndLearnEventRecord.lookup_to_lead__c) !='' && LunchAndLearnEventRecord.lookup_to_lead__c != null ){
            Lead existingLead                   =   new Lead();
            existingLead                     =   [Select Id ,Email from Lead where id=:LunchAndLearnEventRecord.lookup_to_lead__c ];
            if(string.valueOf(existingLead.id) !='' && existingLead.id !=null )
            {
                
                existingMembers=[SELECT Id, Lead__c, LunchAndLearnEvent__c,Course__c,Email_Opt_In__c,created_by_admin__c FROM Event_Attendee__c where  Lead__c = : existingLead.Id AND Course__c= :LunchRecord.Course_Name__c  ];
                if( existingMembers != null && existingMembers.size() > 0){
                    existingMembers[0].LunchAndLearnEvent__c     =   LunchAndLearnId;
                    existingMembers[0].Email_Opt_In__c          =   false;
                    existingMembers[0].created_by_admin__c       =  true;
                    update existingMembers; 
                    
                    updateNumberAttending(LunchRecord);
                    System.debug('Lead Update');
                    successFlag                   =  true;
                    messageStr                     =   'Successfully Updated The Lead';
                    outputPanelFlag                 =   false;   
                    //Database.executeBatch(new BatchEmailSendForCampaigns());
                    return null;
                }
                else{
                    CampaignMemberRecord.Course__c         =   LunchRecord.Course_Name__c;
                    CampaignMemberRecord.Lead__c          =   LunchAndLearnEventRecord.lookup_to_lead__c;
                    CampaignMemberRecord.LunchAndLearnEvent__c     =   LunchAndLearnId;
                    CampaignMemberRecord.created_by_admin__c     =  true;
                    
                    insert CampaignMemberRecord;
                    updateNumberAttending(LunchRecord);
                    successFlag                   =  true;
                    messageStr                     =   'Successfully Inserted The Lead';
                    outputPanelFlag                 =   false; 
                    //Database.executeBatch(new BatchEmailSendForCampaigns());
                    return null;
                } 
            }
            
        }else{
            
        }
        outputPanelFlag     =   false;    
        errorFlag         =   true;
        return null;
    }
    public PageReference Close(){
        PageReference ClosePage   = new PageReference('/' + LunchAndLearnId);
        return ClosePage;
    }
    public PageReference AddNext(){
        PageReference NextPage   = new PageReference('/apex/MapEventVF');
        NextPage.getParameters().put('Id',LunchAndLearnId);
        errorFlag         =     false;
        successFlag       =    false;
        outputPanelFlag     =     true; 
        NextPage.setRedirect(true);
        return NextPage;   
    }
    public void updateNumberAttending(LunchAndLearnEvent__c LearnEvent )
    {
        AggregateResult[] groupedResults = [SELECT COUNT(id)aver  FROM Event_Attendee__c where Course__c =: LearnEvent.Course_Name__c AND LunchAndLearnEvent__c=: LearnEvent.id];
        LearnEvent.Number_Attending__c = Decimal.valueOf(groupedResults[0].get('aver') + '');
        update LearnEvent;
    }
    
}