@isTest
private class EstimatingNoTakeoffHelperTest{

	@testSetup static void setup(){
        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User m = new User(Alias = 'est2', Email='estimatingUser2@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='estimatingUser2@test.com');
        insert m;

        User u = new User(Alias = 'est1', Email='estimatingUser1@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='estimatingUser1@test.com', ManagerId = m.Id);
        insert u;

        Contact contact = new Contact(
            AccountId = accounts.get(0).Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Quote/Bid Complete',
            CloseDate = Date.today(),
            Pricebook2Id = pricebookId,
            AccountId = accounts.get(0).id,
            Territory_Manager__c = u.Id
        );
        insert opp;
        
        Quote quote = new Quote (
            Name = 'test value', 
            OpportunityId = opp.Id,
            Inpro_Document_Number__c = 'Q1234567 Test Bad Guy'
        );
        insert quote;

        Task task = new Task(
            Subject = 'Test Subject',
            WhatId = opp.Id,
            Status = 'Open'
        );
        insert task;
    }

    @isTest static void testGetTaskStatus() {
        Task task = [SELECT Id, Status FROM Task LIMIT 1];
        String status = EstimatingNoTakeoffHelper.getTaskStatus(task.Id);
        System.assertEquals(task.Status, status);
    }

    @isTest static void testUpdateOpportunityAndTask() {
        Task task = [SELECT Id, Status FROM Task LIMIT 1];
        string result = EstimatingNoTakeoffHelper.updateOpportunityAndTask(task.Id, 'Not Enough Information', 'Test', '1.0');
        Task canceledTask = [SELECT Id, Status FROM Task WHERE Id = :task.Id LIMIT 1];
        System.assertEquals('Canceled', canceledTask.Status);
    }

}