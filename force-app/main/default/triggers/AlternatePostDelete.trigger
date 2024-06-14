trigger AlternatePostDelete on Alternate__c (after delete) {
    if (Trigger.isDelete) {
        for(Alternate__c o : Trigger.Old) {
            
            // delete this Alternate from the dataWarehouse...
            WebServiceTriggerProxy.DeleteRecord('Alternate__c', o.Id);
        }
    }
}