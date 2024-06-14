public with sharing class CustomPartNumberConfigHelper {

    @AuraEnabled
    public static string getLockedStatus(string TaskId){
        try {
            Task task = [SELECT Id, Status, WhatId FROM Task WHERE Id = :TaskId LIMIT 1];
            Quote quote = [SELECT Id, Status FROM Quote WHERE Id = :task.WhatId LIMIT 1];

            return task.Status == 'Completed' ? 'Locked' : 'Open';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getDivision(string TaskId){
        try {
            Task task = [SELECT WhatId, Id FROM Task WHERE Id = :TaskId LIMIT 1];
            Quote quote = [SELECT Id, Division__c FROM Quote WHERE Id = :task.WhatId LIMIT 1];

            return quote.Division__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getCustomPartNumbers(string TaskId){
        try {
            String query = 'SELECT WhatId, Id FROM Task WHERE Id = :TaskId LIMIT 1';
            Task quoteAction = (Task)Database.query(Query);
            String QuoteId = quoteAction.WhatId;

            String query2 = 'SELECT Id, QuoteId, Item_Number__c, Custom_Part_Number__c, Description, Description_2__c, Material_Allocation_Note__c,Alternate_Name__c FROM QuoteLineItem Where QuoteId = :QuoteId AND Item_Number__c LIKE \'%custom%\'';
            sObject[] lineItems = Database.query(query2);

            return JSON.serialize(lineItems);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateCustomPartNumbers(string QuoteProducts){
        try {           

            List<QuoteLineItem> lineItems = (List<QuoteLineItem>)JSON.deserialize(QuoteProducts,List<QuoteLineItem>.class);

            Quote q = new Quote();
            q.Id = lineItems[0].QuoteId;
            q.Automation_Date_Time__c = Datetime.now();            
            update q;           

            for(QuoteLineItem item : lineitems)
            {
                update item;
            }
            return 'success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}