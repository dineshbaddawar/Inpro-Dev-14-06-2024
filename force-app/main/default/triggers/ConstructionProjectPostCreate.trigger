trigger ConstructionProjectPostCreate on Construction_Project__c (after insert) {
   
    if (Trigger.isInsert) {    
        if(!Test.isRunningTest()) 
        for(Construction_Project__c c : Trigger.New) {     
            // get the territory if not populated
            if (c.Territory__c == null){         
                if (!Test.isRunningTest()) TerritoryHelper.updateRecordTerritory('Construction_Project__c', c.Id, c.ZIP__c, c.State_Code__c,c.Country_Code__c);
            }
        }
    }
}