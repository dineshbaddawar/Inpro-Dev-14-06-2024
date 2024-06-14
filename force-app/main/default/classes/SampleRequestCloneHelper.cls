public with sharing class SampleRequestCloneHelper {

    @AuraEnabled
    public static string CloneSampleRequest(string recordJson, string sampleRequestItemIds)
    {
        try {
            Sample_Request__c sr = (Sample_Request__c)JSON.deserialize(recordJson, Sample_Request__c.class);
            sr.Status__c = 'New';
            sr.Print_Date__c = null;
            sr.Tracking_Code__c = null;
            sr.Manual_Tracking_Number__c = null;

            List<Sample_Request_Item__c> allItems = NewSampleItemHelper.GetSampleRequestItems(sr.Id);

            List<string> ids = sampleRequestItemIds.split(',');
            List<string> productIds = new List<string>();
            List<string> quantities = new List<string>();

            for(Sample_Request_Item__c item : allItems)
            {
                if (ids.indexOf(item.Id) != -1)
                {
                    productIds.add(item.Sample_Product__c);
                    quantities.add(String.valueOf(item.Quantity__c));
                }
            }


            sr.Id = null;

            insert sr;

            NewSampleItemHelper.CreateSampleRequestItems( sr.Id,productIds, quantities);

            return  sr.Id;
        } catch (Exception ex) {
            return 'Error: ' + ex.getMessage() + '\r\n ' + ex.getStackTraceString();
        }
    }
}