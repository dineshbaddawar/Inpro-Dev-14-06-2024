public with sharing class RelatedRecordNotificationHelper {

    @AuraEnabled
    public static Boolean doRecordsExist(string Id, string ObjectName) 
    {    
        List<SObject> recordList = new List<SObject>();
        if(ObjectName == 'GPO_Association__c')                     
            recordList = [SELECT Id FROM GPO_Association__c where Account__c = :Id and Inactive__c = false LIMIT 1];         

        if(recordList.size() > 0)                  
            return true;
        else 
            return false;
    }
}