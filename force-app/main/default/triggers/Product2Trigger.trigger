trigger Product2Trigger on Product2 (after update) {
    List<Id> productIdsThatChanged = new List<Id>();

    //Get all products whose active flag has changed
    for(Product2 newProduct:Trigger.new)
    {
        for(Product2 oldProduct : Trigger.Old) 
        {
            if (((oldProduct.IsActive && !newProduct.IsActive) || 
                (!oldProduct.IsActive && newProduct.IsActive)) && 
                !productIdsThatChanged.contains(newProduct.Id))
            {
                productIdsThatChanged.add(newProduct.Id);
            }
        }
    }
    if (productIdsThatChanged.size() > 0)
    {
        //Only get affected sample request items from sample requests in new or submitted status
        List<Sample_Request_Item__c> activeSampleRequestItems = 
            [SELECT Id, Sample_Request__c, Sample_Product__r.Id, Sample_Request__r.Status__c 
             FROM Sample_Request_Item__c 
             WHERE (Sample_Product__r.Id IN :productIdsThatChanged)
               AND (Sample_Request__r.Status__c = 'New' OR Sample_Request__r.Status__c = 'Submitted')];

        //Build sample request id list
        List<Id> sampleRequestIds = new List<Id>();
        for(Sample_Request_Item__c sri : activeSampleRequestItems)
        {
            if (!sampleRequestIds.contains(sri.Sample_Request__c))
            {
                sampleRequestIds.add(sri.Sample_Request__c);   
            }
        }

        //Get those sample requests
        List<Sample_Request__c> sampleRequests =
            [SELECT Id, Has_Inactive_Product__c 
             FROM Sample_Request__c 
             WHERE Id IN :sampleRequestIds];

        //Get all sample requests' items
        List<Sample_Request_Item__c> allSampleRequestItems =
            [SELECT Id, Sample_Request__c, Product_Is_Active__c
             FROM Sample_Request_Item__c
             WHERE Sample_Request__c IN :sampleRequestIds];

        //iterate through each sample request and determine if it has an inactive product or not
        for(Sample_Request__c s : sampleRequests)
        {
            Boolean hasInactiveProduct = false;
            for(Sample_Request_Item__c sri : allSampleRequestItems)
            {
                if (sri.Sample_Request__c == s.Id && !sri.Product_Is_Active__c)
                {
                    hasInactiveProduct = true;
                    break;
                }
            }
            s.Has_Inactive_Product__c = hasInactiveProduct;
        }

        //update any changes to Has Inactive Product flag
        update sampleRequests;
    }
}