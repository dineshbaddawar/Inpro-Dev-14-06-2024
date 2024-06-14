/*************************************************************
* Created by:   The Hunley Group
* Created on:    3/22/2021
* ===========================================================
* Test Class:   BatchTerritoryUpdates_Test
* ===========================================================
* Purpose:   To update Construction Projects that are in a 
*            territory that was recently updated and has a 
*            flag set
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/23/2021     THG - JAK       Created
*
************************************************************/
public without sharing class BatchConstructionProjectTerritoryUpdates implements Database.Batchable < sObject > {

    public Set<String> territoryIDs;

    public BatchConstructionProjectTerritoryUpdates( Set<String> terrIDs) {
        this.territoryIDs = terrIDs;
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        system.debug('#@# BatchConstructionProjectTerritoryUpdates.start: territoryIDs.size()=' + territoryIDs.size());

        return Database.getQueryLocator([
            SELECT Id, Name, Territory__c
            FROM Construction_Project__c 
            WHERE Territory__c IN :territoryIDs]);
    }

    public void execute(Database.BatchableContext BC, List<Construction_Project__c> CPs) {
        // save all the territories for the Construction Projects
        Map<Id, Id> cpIDToTerritoryMap = new Map<Id,Id>();
        for (Construction_Project__c cp : CPs) {
            cpIDToTerritoryMap.put(cp.Id, cp.Territory__c);
        }

        List<Construction_Project__c> cpsToUpdateClear = new List<Construction_Project__c>();
        List<Construction_Project__c> cpsToUpdateSet = new List<Construction_Project__c>();

        // clear out the territory on all Construction Projects
        for (Construction_Project__c cp : CPs) {
            system.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: cp.Name = ' + cp.Name);
            cp.Territory__c = null;
            cpsToUpdateClear.add(cp);
        }
        Database.SaveResult[] srList = Database.update(cpsToUpdateClear, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 1) Successfully updated account. Construction Project ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 1) The following error has occurred.');                    
                    System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 1) ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 1) Account fields that affected this error: ' + err.getFields());
                }
            }
        }        

        // set the territory back to what it was on all accounts
        for (Construction_Project__c cp : CPs) {
            cp.Territory__c = cpIDToTerritoryMap.get(cp.Id);
            cpsToUpdateSet.add(cp);
        }
        srList = Database.update(cpsToUpdateSet, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 2) Successfully updated account. Construction Project ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 2) The following error has occurred.');                    
                    System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 2) ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('#@# BatchConstructionProjectTerritoryUpdates.execute: 2) Account fields that affected this error: ' + err.getFields());
                }
            }
        }        
    }

    public void finish(Database.BatchableContext BC) {
        system.debug('#@# BatchConstructionProjectTerritoryUpdates.finish: Finish');
    }

}