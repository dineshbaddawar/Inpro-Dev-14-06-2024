/************************************************************
* Created by:   The Hunley Group
* Created on:   3/25/2021
* ===========================================================
* Test Class:  NA
* ===========================================================
* Purpose: Test class for AccountTriggerHandler
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 03/25/2021    THG - Tyler     Created
* 11/29/2021    Inpro - Ben     Renamed
*************************************************************/
@IsTest
public class AccountTriggerHandlerTest {

    // @isTest
    // public static void testAddAndRemoveChild() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);

    //     // verify account1 has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account2.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);

    //     // remove account 2 from account 1 hierarchy
    //     account2.ParentId = null;

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);


    //     // verify account1 has Is_Parent__c set to false:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];

    //     system.assert(account1.Is_Parent__c == false);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);


    //     system.assert(account2.Ultimate_Parent_Account__c == null);
    // }

    // @isTest
    // public static void testAddAndDeleteChild() {

    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }



    //     // verify account1 has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c from Account where Id = :account1.Id];
    //     system.assert(account1.Is_Parent__c == true);

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     delete(account2);


    //     // verify account1 has Is_Parent__c set to false:
    //     account1 = [Select Id, Is_Parent__c from Account where Id = :account1.Id];
    //     system.assert(account1.Is_Parent__c == false);
    // }

    // @isTest
    // public static void testSwapParents() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account3 = new Account();
    //     account3.Name = 'TEST Account DEF';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     // set account3 as parent on account2
    //     account2.ParentId = account3.Id;

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);

    //     // verify account1 has Is_Parent__c set to true:
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];

    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account2.Ultimate_Parent_Account__c == account3.Id);
    //     system.assert(account3.Ultimate_Parent_Account__c == null);

    //     // verify account1 has Is_Parent__c set to false:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];

    //     system.assert(account1.Is_Parent__c == false);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);

    // }

    // /*@isTest
    // public static void testMultipleParentsAndOneChildRemoved() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account3 = new Account();
    //     account3.Name = 'FGH Account DEF';
    //     account3.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     // set account3 as parent on account2
    //     account2.ParentId = null;

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);

    //     // verify account1 still has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);
    //     system.assert(account2.Ultimate_Parent_Account__c == null);
    //     system.assert(account3.Ultimate_Parent_Account__c == account1.Id);

    // }*/

    // @isTest
    // public static void testParentTheParent() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account3 = new Account();
    //     account3.Name = 'FGH Account FGH';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     // set account3 as parent on account1
    //     account1.ParentId = account3.Id;


    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account1);

    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account1.Ultimate_Parent_Account__c == account3.Id);


    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account3.Ultimate_Parent_Account__c == null);
    // }


    // @isTest
    // public static void testBasicUltimateParentHierarchy() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account3 = new Account();
    //     account3.Name = 'FGH Account DEF';
    //     account3.ParentId = account2.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account4 = new Account();
    //     account4.Name = 'GHI Account DEF';
    //     account4.ParentId = account3.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account4);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account5 = new Account();
    //     account5.Name = 'HIJ Account DEF';
    //     account5.ParentId = account4.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account5);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account6 = new Account();
    //     account6.Name = 'IJK Account DEF';
    //     account6.ParentId = account5.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account6);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);

    //     // verify account1 still has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account4 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account4.Id];
    //     account5 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account5.Id];
    //     account6 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account6.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account2.Is_Parent__c == true);
    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account4.Is_Parent__c == true);
    //     system.assert(account5.Is_Parent__c == true);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);
    //     system.assert(account2.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account3.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account4.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account5.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account6.Ultimate_Parent_Account__c == account1.Id);

    // }

    // /*@isTest
    // public static void testUltimateParentHierarchyDeleteMiddleChild() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account3 = new Account();
    //     account3.Name = 'FGH Account DEF';
    //     account3.ParentId = account2.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account4 = new Account();
    //     account4.Name = 'GHI Account DEF';
    //     account4.ParentId = account3.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account4);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account5 = new Account();
    //     account5.Name = 'HIJ Account DEF';
    //     account5.ParentId = account4.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account5);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account6 = new Account();
    //     account6.Name = 'IJK Account DEF';
    //     account6.ParentId = account5.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account6);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);

    //     // verify account1 still has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account4 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account4.Id];
    //     account5 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account5.Id];
    //     account6 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account6.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account2.Is_Parent__c == true);
    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account4.Is_Parent__c == true);
    //     system.assert(account5.Is_Parent__c == true);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);
    //     system.assert(account2.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account3.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account4.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account5.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account6.Ultimate_Parent_Account__c == account1.Id);


    //     // now, delete child 3
    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     delete account3;

    //     // verify hierarchy shows new parenting:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     //account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account4 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account4.Id];
    //     account5 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account5.Id];
    //     account6 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account6.Id];

    //     system.assert(account1.Ultimate_Parent_Account__c == null);
    //     system.assert(account2.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account4.Ultimate_Parent_Account__c == null);
    //     system.assert(account5.Ultimate_Parent_Account__c == account4.Id);
    //     system.assert(account6.Ultimate_Parent_Account__c == account4.Id);
    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account2.Is_Parent__c == false);
    //     system.assert(account4.Is_Parent__c == true);
    //     system.assert(account5.Is_Parent__c == true);


    //     // now, recreate child 3 and add back in chain:
    //     account3 = new Account();
    //     account3.Name = 'FGH Account DEF';
    //     account3.ParentId = account2.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     // reparent account 4 to account 3:
    //     account4.parentId = account3.Id;
    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     update(account4);


    //     // verify account1 still has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account4 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account4.Id];
    //     account5 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account5.Id];
    //     account6 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account6.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account2.Is_Parent__c == true);
    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account4.Is_Parent__c == true);
    //     system.assert(account5.Is_Parent__c == true);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);
    //     system.assert(account2.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account3.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account4.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account5.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account6.Ultimate_Parent_Account__c == account1.Id);

    // }*/



    // /*@isTest
    // public static void testUltimateParentHierarchySignificantReparent() {
    //     Account account1 = new Account();
    //     account1.Name = 'ABC Account ABC';

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account1);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account2 = new Account();
    //     account2.Name = 'DEF Account DEF';
    //     // set account2 as parent on account1
    //     account2.ParentId = account1.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account2);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account3 = new Account();
    //     account3.Name = 'FGH Account DEF';
    //     account3.ParentId = account2.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account3);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     Account account4 = new Account();
    //     account4.Name = 'GHI Account DEF';
    //     account4.ParentId = account3.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account4);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account5 = new Account();
    //     account5.Name = 'HIJ Account DEF';
    //     account5.ParentId = account4.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account5);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     Account account6 = new Account();
    //     account6.Name = 'IJK Account DEF';
    //     account6.ParentId = account5.Id;

    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         insert(account6);
    //     } catch (DmlException e) {
    //         throw(e);
    //     }

    //     HunleyTriggerUtilities.resetRun('AccountTrigger');
    //     upsert(account2);

    //     // verify account1 still has Is_Parent__c set to true:
    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account4 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account4.Id];
    //     account5 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account5.Id];
    //     account6 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account6.Id];

    //     system.assert(account1.Is_Parent__c == true);
    //     system.assert(account2.Is_Parent__c == true);
    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account4.Is_Parent__c == true);
    //     system.assert(account5.Is_Parent__c == true);
    //     system.assert(account1.Ultimate_Parent_Account__c == null);
    //     system.assert(account2.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account3.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account4.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account5.Ultimate_Parent_Account__c == account1.Id);
    //     system.assert(account6.Ultimate_Parent_Account__c == account1.Id);


    //     // do a big parent flip
    //     account4.parentId = account6.Id;
    //     account5.parentId = null;
    //     account1.parentId = account3.Id;
    //     account2.parentId = null;


    //     List<Account> aUp = new List<Account>();
    //     aUp.add(account4);
    //     aUp.add(account5);
    //     aUp.add(account1);
    //     aUp.add(account2);


    //     try {
    //         HunleyTriggerUtilities.resetRun('AccountTrigger');
    //         upsert aUp;
    //     } catch (DmlException e) {
    //         throw(e);
    //     }


    //     account1 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account1.Id];
    //     account2 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account2.Id];
    //     account3 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account3.Id];
    //     account4 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account4.Id];
    //     account5 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account5.Id];
    //     account6 = [Select Id, Is_Parent__c, Ultimate_Parent_Account__c from Account where Id = :account6.Id];

    //     system.assert(account2.Is_Parent__c == true);
    //     system.assert(account3.Is_Parent__c == true);
    //     system.assert(account5.Is_Parent__c == true);
    //     system.assert(account6.Is_Parent__c == true);
    //     system.assert(account1.Is_Parent__c == false);
    //     system.assert(account4.Is_Parent__c == false);
    //     system.assert(account1.Ultimate_Parent_Account__c == account2.Id);
    //     system.assert(account2.Ultimate_Parent_Account__c == null);
    //     system.assert(account3.Ultimate_Parent_Account__c == account2.Id);
    //     system.assert(account4.Ultimate_Parent_Account__c == account5.Id);
    //     system.assert(account5.Ultimate_Parent_Account__c == null);
    //     system.assert(account6.Ultimate_Parent_Account__c == account5.Id);

    // }*/


}