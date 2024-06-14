/************************************************************
* Created by:   The Hunley Group
* Created on:   3/26/2021
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/26/2021       THG - Tyler    Created
*************************************************************/
@isTest
public with sharing class AccountParentSyncBatch_Test {

    @isTest
    static void test() {

        // List<Account> parentAccList = new List<Account>();
        // for (Integer i=0;i<90;i++) {
        //     Account acc = new Account();
        //     acc.Name='Parent Account'+i;
        //     parentAccList.add(acc);
        // } 
        // insert parentAccList;

        // List<Account> childAccList = new List<Account>();
        // for (Account acc:parentAccList) {
        //     Account child = new Account();
        //     child.Name='Child Account - '+acc.Name;
        //     child.ParentId=acc.Id;
        //     childAccList.add(child);
        // }
        // insert childAccList;

        // Account grandParent = new Account();
        // grandParent.Name = 'Grandparent account';
        // insert grandParent;

        // Account parentToUpdate = parentAccList[0];
        // parentToUpdate.ParentId = grandParent.Id;
        // update parentToUpdate;

        // Test.startTest();
        // AccountParentSyncBatch c = new AccountParentSyncBatch();
        // //Database.executeBatch(c);
        // c.execute(null);
        // Test.stopTest();

        // // Verify accounts updated
        // List<Account> parentList = [SELECT Id,Is_Parent__c FROM Account where Name like 'Parent%'];
        // for(Account a:parentList)
        //     system.assertEquals(a.Is_Parent__c, true);

        // List<Account> childList = [SELECT Id,Is_Parent__c FROM Account where Name like 'Child%'];
        // for(Account a:childList)
        //     system.assertEquals(a.Is_Parent__c, false);

    }
}