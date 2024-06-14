/*************************************************************
* Created by:   The Hunley Group
* Created on:   04/08/2021
* ===========================================================
* Test Class:   BatchTerritoryUpdates_Test
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/08/2021     THG - JAK       Created
*
************************************************************/
global without sharing class BatchTerritoryUpdates_Runner implements Schedulable {

    global void execute(SchedulableContext sc) {
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: BEGIN');

        Set<String> territoryIDs = new Set<String>();
        List<Territory__c> terrsBefore = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Territory_Refresh_Required__c = true];
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: terrsBefore.size()=' + terrsBefore.size());
        for (Territory__c t : terrsBefore) {
            territoryIDs.add(t.id);
        }

        // run the batch, processing all Accounts in updated territories
        // this will run AFTER the flags are cleared below, which is why I am passing in the territoryIDs in the batch process constructor
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: Running BatchAccountTerritoryUpdates');
        BatchAccountTerritoryUpdates batchA = new BatchAccountTerritoryUpdates(territoryIDs);
        Database.executeBatch(batchA, 100);
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: DONE Running BatchAccountTerritoryUpdates');

        // run the batch, processing all Construction Projects in updated territories
        // this will run AFTER the flags are cleared below, which is why I am passing in the territoryIDs in the batch process constructor
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: Running BatchConstructionProjectTerritoryUpdates');
        BatchConstructionProjectTerritoryUpdates batchCP = new BatchConstructionProjectTerritoryUpdates(territoryIDs);
        Database.executeBatch(batchCP, 100);
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: DONE Running BatchConstructionProjectTerritoryUpdates');

        // clear the flag on the territories
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: Resetting flags on Territories');
        List<Territory__c> terrs = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Territory_Refresh_Required__c = true];
        for (Territory__c t : terrs) {
            t.Territory_Refresh_Required__c = false;
        }
        update terrs;
 
        system.debug('#@# BatchTerritoryUpdates_Runner.execute: END');
   }
}