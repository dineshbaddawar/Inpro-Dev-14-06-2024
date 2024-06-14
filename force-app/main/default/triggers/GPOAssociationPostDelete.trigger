trigger GPOAssociationPostDelete on GPO_Association__c (after delete) {
    if (Trigger.isDelete) {
        for(GPO_Association__c o : Trigger.Old) {
            
            // delete this GPO_Association__c from the dataWarehouse...
            WebServiceTriggerProxy.DeleteRecord('GPO_Association__c', o.Id);
        }
    }
}