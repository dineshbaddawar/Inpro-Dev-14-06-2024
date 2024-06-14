public with sharing class EDIStatusDetailTriggerHandler {
    private Map<Id, EDI_Status_Detail__c> newMap;
    private Map<Id, EDI_Status_Detail__c> oldMap;
    private List<EDI_Status_Detail__c> trigNew;
    private List<EDI_Status_Detail__c> trigOld;
    private Boolean isDelete;

    // Constructor used for Before/After Update handler
    public EDIStatusDetailTriggerHandler(Map<Id, EDI_Status_Detail__c> triggerOldMap,  Map<Id, EDI_Status_Detail__c> triggerNewMap, List<EDI_Status_Detail__c> triggerOld, List<EDI_Status_Detail__c> triggerNew) {
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
        handleStatusDetailInsert();
    }

    //Public void method called Before Update from the Lead Trigger
    public void beforeUpdate() {
    }

    //Public void method called After Update from the Lead Trigger
    public void afterUpdate() {
     
    }

    public void handleStatusDetailInsert() 
    {
        try {
            
       
        if (this.trigNew.size() < 5)
        {
            for (EDI_Status_Detail__c detail : this.trigNew) {               
            
                //EDI_Status_Detail__c detail = this.trigNew[0];
                string status = detail.Status__c;
                string EDIHeaderID = detail.EDI_Header__c;
                EDICallout(EDIHeaderID, status, detail.Id);
            }         
        }

        } catch (Exception ex) {
            EDI_Error_Log__c log = new EDI_Error_Log__c();
            log.Error_Message__c = ex.getMessage() + ex.getStackTraceString();               
            insert log;
        }
    }

    private static Boolean CheckIfOrderTaskHasBeenCreated(string EDIHeaderID)
    {
            List<EDI_Status_Detail__c> statusDetails = 
            [SELECT Status__c, EDI_Header__c
            FROM EDI_Status_Detail__c
            WHERE Status__c = 'Order Task Created' and EDI_Header__c = :EDIHeaderID LIMIT 1];

            if(statusDetails.size() > 0)
                return true;
            else
                return false;
    }

    @AuraEnabled()
    @future (callout = true)
    public static void EDICallout(string EDIHeaderID, string Status, string DetailId)
     {              
        EDI_Header__c header = new EDI_Header__c();
        header.Id = EDIHeaderID;
        header.Current_Status__c = Status;         
        EDISvc.EDISvcSoap service = new EDISvc.EDISvcSoap();
        service.timeout_x = 120000;                    

        switch on Status {
            when 'New PO Created' {	
                if(!Test.isRunningTest())
                service.ProcessPO(EDIHeaderID);
            }	
            when 'PO Acknowledgement Created' {		
                if(!Test.isRunningTest())
                service.UploadEDIFiles(EDIHeaderID, 'PO Acknowledgement');
            }
            when 'Pending Approval' {	
                if(!Test.isRunningTest())	
                service.NotifyUsersNewPOPendingApproval(EDIHeaderID);
            }             
            when 'Approved' {		
                if(!CheckIfOrderTaskHasBeenCreated(EDIHeaderID))
                {
                    if(!Test.isRunningTest())
                    service.ProcessPOOrder(EDIHeaderID);
                }
                else {
                    EDI_Error_Log__c log = new EDI_Error_log__c();
                    log.Name = 'Error On: ' + Datetime.now();
                    log.Error_Message__c = 'An order task has already been created.';
                    log.EDI_Header__c = EDIHeaderID;
                    insert log;
                }
            }             
            when 'PO Acknowledgement Sent' {		
                if(CheckIfOrderTaskHasBeenCreated(EDIHeaderID))
                {                        
                    header.Current_Status__c = 'Order Task Created';                        
                }
            }       
            when 'ASN Created' {	
                if(!Test.isRunningTest())	
              service.UploadEDIFiles(EDIHeaderID, 'ASN');
            }
            when 'Invoice Created' {		
                if(!Test.isRunningTest())
              service.UploadEDIFiles(EDIHeaderID, 'Invoice');
            }
            when 'Invoiced' {		
                if(!Test.isRunningTest())
               service.ProcessInvoice(EDIHeaderID, DetailId);
            }
            when 'Shipping Acknowledgement Created' {		
                if(!Test.isRunningTest())
                service.UploadEDIFiles(EDIHeaderID, 'PO Acknowledgement');
            }
            when 'PO Cancellation Created' {		
                if(!Test.isRunningTest())
                service.UploadEDIFiles(EDIHeaderID, 'PO Cancel Acknowledgement');
            }
            when 'PO Denied' {		
                if(!Test.isRunningTest())
                service.DenyPO(EDIHeaderID);
            }
            when 'PO Denial Created' {
                if(!Test.isRunningTest())
                service.UploadEDIFiles(EDIHeaderID, 'PO Denial');
            }
            when 'Shipping Acknowledgement Requested' {
                if(!Test.isRunningTest())
                service.AcknowledgePO(EDIHeaderID);
            }
            when 'Ready for Acknowledgement' {
                if(!Test.isRunningTest())
                service.AcknowledgePO(EDIHeaderID);
            }
            when 'Manual Invoice Attention Needed' {
                if(!Test.isRunningTest())
                service.NotifyUsersManualInvoiceActionRequired(DetailId, EDIHeaderID);
            }                
            when 'PO Cancelled'
            {
                if(!Test.isRunningTest())
                 service.CancelPO(EDIHeaderID);
            }
        }
        
        update header;

    }

}