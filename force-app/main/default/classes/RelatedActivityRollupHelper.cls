public with sharing class RelatedActivityRollupHelper {
    @AuraEnabled
    public static string getActivityAttachmentsById(string recordId){
        try {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            List<sfdata.CRMAttachmentResult> results = service.GetActivityAttachmentsById(recordId, 'dsj8U73_3nv3Dhba').CRMAttachmentResult;
            return JSON.serialize(results);
        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }

    @AuraEnabled
    public static string getActivityAttachmentFileById(string recordId){
        try {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;        
            sfdata.CRMAttachmentResult result = service.GetActivityAttachmentFileById(recordId, 'dsj8U73_3nv3Dhba');
            return  JSON.serialize(result);
        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }
    

    @AuraEnabled
    public static string getHistoricalActivities(string recordId){
        try {
            if (recordId != '')
            {
                sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                service.timeout_x = 120000;        
                string results = service.GetHistoricalActivities(recordId, '', 'dsj8U73_3nv3Dhba');
                return results;
            }
            else return '';
        } catch (Exception e) {
            return e.getMessage() + ' ' + e.getStackTraceString();
        }
    }

    @AuraEnabled
    public static List<Task> getActivities (string recordId, string recordType) {        
    Set<Id> records = new Set<Id>();    
    if(recordType == 'Opportunity')
    {
        List<Quote> quoteList = [Select Id from Quote where opportunityid = :recordId];
        for (Quote quote : quoteList) {
            records.add(quote.Id);
        }
    }
    else if (recordType == 'Construction_Project__c')
    {
        Set<Id> oppRecords = new Set<Id>();
        List<Opportunity> oppList = [Select Id from Opportunity where Construction_Project__c = :recordId];
        for (Opportunity op : oppList) {
            oppRecords.add(op.Id);
            records.add(op.Id);
        }

        List<Quote> quoteList = [Select Id from Quote where opportunityid in :oppRecords];
        for (Quote quote : quoteList) {
            records.add(quote.Id);
        }
    }
        records.add(recordId);
        List<Task> taskList =  [SELECT  
                            TYPEOF what When Quote Then Name else Name END,
                            TYPEOF Owner
                            When User Then Name else Name END,
                                Description, Division__c, Type, Id, TaskSubtype, Subject, ActivityDate, 
                                    Status, WhoId, OwnerId, RecordTypeId, WhatId, LastModifiedDate                                    
                            FROM Task
                            WHERE WhatId IN :records order by LastModifiedDate, ActivityDate  asc];
                            Set<Id> emailRecords = new Set<Id>(); 
                            for (Task t : taskList) {
                                if (t.TaskSubtype == 'Email') {
                                    emailRecords.add(t.Id);
                                }
                            }
        List<EmailMessage> emails = [SELECT ActivityId, Id
                                    FROM EmailMessage
                                    WHERE ActivityId in :emailRecords];
        Set<Id> emailIds = new Set<Id>();
        for (EmailMessage e : emails) {
            for (Task t : taskList) {
                if(e.ActivityId == t.Id)
                    t.MSCRM_ID__c = e.Id;
                    emailIds.add(e.Id);
            }        
        }
        List<EmailMessage> emailMessages =[SELECT Subject, RelatedToId, CreatedDate,
                                           TextBody, HtmlBody, CreatedById, Id,CreatedBy.Name,RelatedTo.Name,
                                           FromAddress, MessageDate
                                    FROM EmailMessage
                                    WHERE RelatedToId in :records and Id not in :emailIds];
        for (EmailMessage m : emailMessages) {
            Task t = new Task();            t.Description = m.TextBody;            t.TaskSubtype = 'Email';            t.Subject = m.Subject;            t.ActivityDate = Date.valueOf(m.MessageDate);            t.LastModifiedDate = m.MessageDate;            t.WhatId = m.RelatedToId;   t.MSCRM_ID__c = m.Id;t.ISR_Notes__c  = m.RelatedTo.Name;            t.Internal_Notes__c = m.FromAddress;            t.OwnerId = m.CreatedById;            t.Id = '00T4V00005xn8tjUAA';            taskList.add(t);                            
        }
        return taskList;
    }     
   
}