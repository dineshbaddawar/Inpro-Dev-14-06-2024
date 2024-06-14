trigger OpportunityPostCreate on Opportunity (after insert) {
    /*
    // Joe B - Original logic preserved for posterity. 
    // Moved to OpportunityTriggerHelper.afterInsert() and optimzed.

    if (Trigger.isInsert) {    
        if(!Test.isRunningTest()) 
        for(Opportunity opp : Trigger.New) {     
            // get the territory if not populated
            
                if (opp.Territory__c == null && System.IsBatch() == false && System.isFuture() == false){         
                    if (!Test.isRunningTest()) TerritoryHelper.updateRecordTerritory('Opportunity', opp.Id, opp.ZIP__c, opp.State_Code__c,opp.Country_Code__c);
                }
            
        }
    }
    */
}