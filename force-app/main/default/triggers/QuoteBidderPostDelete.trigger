trigger QuoteBidderPostDelete on Quote_Bidder__c (after delete) {
    if (Trigger.isDelete) {
        for(Quote_Bidder__c o : Trigger.Old) {
            
            // delete this Quote_Bidder__c from the dataWarehouse...
            WebServiceTriggerProxy.DeleteRecord('Quote_Bidder__c', o.Id);
        }
    }
}