trigger ExpediteRequestTrigger on Expedite_Request__c (after update) {
    for(Expedite_Request__c expediteRequest:Trigger.new)
    {
        Expedite_Request__c oldExpediteRequest = Trigger.oldMap.get(expediteRequest.Id);

        if(expediteRequest.Expedite_Part_Number__c != oldExpediteRequest.Expedite_Part_Number__c)
        {       
            ExpediteProcessHelper.UpdateNetSuiteExpeditePartNumber(expediteRequest.Expedite_Part_Number__c,expediteRequest.NetSuite_ID__c);
        }
    }
}