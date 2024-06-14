@istest
public with sharing class accountToNSHelperTest {
    @testSetup static void setup(){
        List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');

        Account subAccount = new Account(
            Sync_Price_Level__c = true,
            ParentId = accounts.get(0).Id,
            Name = 'Test'
        );
        insert subAccount;

        Task task = new Task(
            Type = 'Line of Credit Change',
            Status = 'Completed'
        );
        insert task;
        Test.startTest();
    }

    @istest 
    static void testAddAccountToNetSuite() {
       // This causes a fake response to be generated
       Test.setMock(WebServiceMock.class, new sfdataTest());
       // Call the method that invokes a callout
       string accountId = 'test';       
       string result = accountToNSHelper.AddAccountToNetSuite(accountId);
       // Verify that a fake result is returned       
       System.assertEquals('Success', result);
    }    
}