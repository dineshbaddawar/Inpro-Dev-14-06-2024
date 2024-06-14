/************************************************************
* Created by:   The Hunley Group
* Created on:   3/26/2021
* ===========================================================
* Test Class:  AccountParentSyncBatch
* ===========================================================
* Purpose: Keeps the account parenting structure in sync.
*
*          Should be scheduled to run daily (or as needed)
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/26/2021       THG - Tyler    Created
*************************************************************/
global without sharing class AccountParentSyncBatch implements Database.Batchable<sObject>, Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountParentSyncBatch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('#@# AccountParentSyncBatch.start(Batch)');

        String query = 'Select Id, Name, Is_Parent__c, Ultimate_Parent_Account__c, Ultimate_Parent_Formula__c, '
                        + '(select Id, Name from ChildAccounts LIMIT 1) from Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){
        system.debug('#@# AccountParentSyncBatch.execute(Batch): BEGIN');
        List<Account> accsToUpdate =new List<Account>();
        for(Account acc:scope){

            system.debug('#@# AccountParentSyncBatch.execute(Batch):1: acc.Name = ' + acc.Name);
            system.debug('#@# AccountParentSyncBatch.execute(Batch):1: acc.Ultimate_Parent_Account__c = ' + acc.Ultimate_Parent_Account__c);
            system.debug('#@# AccountParentSyncBatch.execute(Batch):1: acc.Ultimate_Parent_Formula__c = ' + acc.Ultimate_Parent_Formula__c);

            boolean oldValueParent = acc.Is_Parent__c;

            // set new parenting values:
            if(acc.ChildAccounts.isEmpty()) {
                acc.Is_Parent__c = false;
            } else {
                acc.Is_Parent__c = true;
            }

            Boolean changeMade = false;
            if (acc.Ultimate_Parent_Account__c != acc.Ultimate_Parent_Formula__c) {
                changeMade = true;
                acc.Ultimate_Parent_Account__c = acc.Ultimate_Parent_Formula__c;
            }

            system.debug('#@# AccountParentSyncBatch.execute(Batch):2: acc.Ultimate_Parent_Account__c = ' + acc.Ultimate_Parent_Account__c);
            system.debug('#@# AccountParentSyncBatch.execute(Batch):2: acc.Ultimate_Parent_Formula__c = ' + acc.Ultimate_Parent_Formula__c);

            // only add to 'update' list if value changed:
            if (oldValueParent != acc.Is_Parent__c || changeMade) {
                system.debug('#@# AccountParentSyncBatch.execute(Batch): ADDing this account to accsToUpdate: acc.Name = ' + acc.Name);
                accsToUpdate.add(acc);
            } else {
                system.debug('#@# AccountParentSyncBatch.execute(Batch): NOT Adding this account to accsToUpdate: acc.Name = ' + acc.Name);
            }
        }
        if (accsToUpdate.size() > 0) {
            system.debug('#@# AccountParentSyncBatch.execute(Batch): updating accsToUpdate: accsToUpdate.size() = ' + accsToUpdate.size());
            Database.SaveResult[] srList = Database.update(accsToUpdate, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors 
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('#@# AccountParentSyncBatch.execute(Batch): The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage()); 
                        System.debug('#@# AccountParentSyncBatch.execute(Batch): Fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            
        }
        system.debug('#@# AccountParentSyncBatch.execute(Batch): END');
    }


    global void finish(Database.BatchableContext BC){
        system.debug('#@# AccountParentSyncBatch.finish: job finished');
    }
}