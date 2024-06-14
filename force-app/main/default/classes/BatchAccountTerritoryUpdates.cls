/*************************************************************
* Created by:   The Hunley Group
* Created on:    3/22/2021
* ===========================================================
* Test Class:   BatchTerritoryUpdates_Test
* ===========================================================
* Purpose:   To update Accounts that are in a territory that
*            was recently updated and has a flag set
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/23/2021     THG - JAK       Created
*
************************************************************/
public without sharing class BatchAccountTerritoryUpdates implements Database.Batchable < sObject > {

    public Set<String> territoryIDs;

    public BatchAccountTerritoryUpdates( Set<String> terrIDs) {
        this.territoryIDs = terrIDs;
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        // Find all the Accounts with the flag set
        system.debug('#@# BatchAccountTerritoryUpdates.start: territoryIDs.size()=' + territoryIDs.size());

        return Database.getQueryLocator([
            SELECT Id, Name, Territory_Lookup__c
            FROM Account 
            WHERE Territory_Lookup__c IN :territoryIDs]);
    }

    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        system.debug('#@# BatchAccountTerritoryUpdates.execute: processing ' + accounts.size() + ' accounts');
        // save all the territories for the accounts
        Map<Id, Id> accountIDToTerritoryMap = new Map<Id,Id>();
        for (Account a : accounts) {
            accountIDToTerritoryMap.put(a.Id, a.Territory_Lookup__c);
        }

        List<Account> accountsToUpdateClear = new List<Account>();
        List<Account> accountsToUpdateSet = new List<Account>();

        // clear out the territory on all accounts
        for (Account account : accounts) {
            system.debug('#@# BatchAccountTerritoryUpdates.execute: account.Name = ' + account.Name);
            account.Territory_Lookup__c = null;
            accountsToUpdateClear.add(account);
        }
        Database.SaveResult[] srList = Database.update(accountsToUpdateClear, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('#@# BatchAccountTerritoryUpdates.execute: 1) Successfully updated account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('#@# BatchAccountTerritoryUpdates.execute: 1) The following error has occurred.');                    
                    System.debug('#@# BatchAccountTerritoryUpdates.execute: 1) ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('#@# BatchAccountTerritoryUpdates.execute: 1) Account fields that affected this error: ' + err.getFields());
                }
            }
        }        

        // set the territory back to what it was on all accounts
        for (Account account : accounts) {
            account.Territory_Lookup__c = accountIDToTerritoryMap.get(account.Id);
            accountsToUpdateSet.add(account);
        }
        srList = Database.update(accountsToUpdateSet, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('#@# BatchAccountTerritoryUpdates.execute: 2) Successfully updated account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('#@# BatchAccountTerritoryUpdates.execute: 2) The following error has occurred.');                    
                    System.debug('#@# BatchAccountTerritoryUpdates.execute: 2) ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('#@# BatchAccountTerritoryUpdates.execute: 2) Account fields that affected this error: ' + err.getFields());
                }
            }
        }        

    }

    public void finish(Database.BatchableContext BC) {
        system.debug('#@# BatchAccountTerritoryUpdates.finish: Finish');
    }

}