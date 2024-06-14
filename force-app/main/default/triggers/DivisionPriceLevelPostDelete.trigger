trigger DivisionPriceLevelPostDelete on Division_Price_Level__c (after delete) {
    if (Trigger.isDelete) {
        for(Division_Price_Level__c d : Trigger.Old) {
            
            // delete this Alternate from the dataWarehouse...
            WebServiceTriggerProxy.DeleteRecord('Division_Price_Level__c', d.Id);
        }
    }
}