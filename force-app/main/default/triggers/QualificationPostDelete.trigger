trigger QualificationPostDelete on Qualification__c (after delete) {
    if (Trigger.isDelete) {
        for(Qualification__c o : Trigger.Old) {
            
            // delete this Qualification__c from the dataWarehouse...
            WebServiceTriggerProxy.DeleteRecord('Qualification__c', o.Id);
        }
    }
}