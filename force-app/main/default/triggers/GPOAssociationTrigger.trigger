trigger GPOAssociationTrigger on GPO_Association__c (after insert, after update) {
    for(GPO_Association__c ga:Trigger.new)
    {
        if(ga.Inactive__c != null && ga.Inactive__c != true)
        {
            List<GPO_Association__c> gList = [select Id from GPO_Association__c where Inactive__c = FALSE AND Division__c =: ga.Division__c AND Account__c =: ga.Account__c ];
            if(gList.size() > 1)
                ga.Division__c.addError('Error: An account can only have one active GPO Association per division. There is already an active GPO Association on this account for (' + ga.Division__c + ').');               
        }    
    }
}