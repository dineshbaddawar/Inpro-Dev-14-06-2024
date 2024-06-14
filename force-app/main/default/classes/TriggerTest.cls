@isTest
private class TriggerTest{

	@isTest static void testSampleRequestItemPostCreate(){
        Account account = new Account();
		account.Name = 'IT Test';
        account.AccountNumber = '12345';
        account.Phone = '123-123-1234';
        account.ShippingStreet = '123 Test St';
        account.ShippingCity = 'Wausau';
        account.ShippingState = 'Wisconsin';
        account.ShippingPostalCode = '54401';
        account.ShippingCountry = 'United States';
		insert account;

        Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Email = 'smith@inprocorp.invalid';
        contact.AccountId = account.Id;
        insert contact;
        Contact contact2 = new Contact();
        contact2.LastName = 'Apples';
        contact2.Email = 'Apples@inprocorp.invalid';
        contact2.AccountId = account.Id;
        insert contact2;

        Sample_Request__c sr = new Sample_Request__c();
        sr.Contact__c = contact.Id;
        sr.Type__c = 'Acquired Marketing Lead';
        sr.Type__c = 'Web Request';
        sr.Status__c = 'New';
        sr.ISR__c = [SELECT Id FROM USER LIMIT 1].Id;
        insert sr;

        sr.Contact__c = contact2.Id;
        update sr;

        Campaign campaign = new Campaign();
        campaign.Name = 'Super Fun Times';
        insert campaign;

        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        prod.Family = 'Literature';

        prod.Campaign__c = campaign.Id;
        insert prod;

        Sample_Request_Item__c sri = new Sample_Request_Item__c();
        sri.Sample_Request__c = sr.Id;
        sri.Sample_Product__c = prod.Id;
        
        //insert sri;
    }

    @isTest static void testProductTrigger(){
        Account account = new Account();
		account.Name = 'IT Test';
		insert account;

        Contact contact = new Contact();
        contact.LastName = 'Smith';
        contact.Email = 'smith@inprocorp.invalid';
        contact.AccountId = account.Id;
        insert contact;

        Sample_Request__c sr = new Sample_Request__c();
        sr.Contact__c = contact.Id;
        sr.Type__c = 'Acquired Marketing Lead';
        sr.Type__c = 'Web Request';
        sr.Status__c = 'New';
        sr.ISR__c = [SELECT Id FROM USER LIMIT 1].Id;
        insert sr;

        
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        prod.Family = 'Literature';
        prod.IsActive = true;
        insert prod;

        Sample_Request_Item__c sri = new Sample_Request_Item__c();
        sri.Sample_Product__c = prod.Id;
        sri.Sample_Request__c = sr.Id;
        insert sri;

        prod.IsActive = false;
        update prod;

        Sample_Request__c srAfterInactiveUpdate = [SELECT Id, Has_Inactive_Product__c FROM Sample_Request__c LIMIT 1];
        System.assert(srAfterInactiveUpdate.Has_Inactive_Product__c == true);

        prod.IsActive = true;
        update prod; 

        Sample_Request__c srAfterActiveUpdate = [SELECT Id, Has_Inactive_Product__c FROM Sample_Request__c LIMIT 1];
        System.assert(srAfterActiveUpdate.Has_Inactive_Product__c == false);
        
    }

    @isTest static void testEventTrigger(){
        Test.startTest();

        Account account = new Account();
		account.Name = 'IT Test';
        account.AccountNumber = '12345';
        account.Phone = '123-123-1234';
        account.ShippingStreet = '123 Test St';
        account.ShippingCity = 'Wausau';
        account.ShippingState = 'Wisconsin';
        account.ShippingPostalCode = '54401';
        account.ShippingCountry = 'United States';
		insert account;


        Event ev = new Event();
        ev.WhatId = account.Id;
        ev.DurationInMinutes = 60;
        ev.ActivityDateTime = Datetime.now();
        insert ev;
    }
    @isTest static void testWebserviceTriggerProxy(){
        Test.setMock(WebServiceMock.class, new sfdataTest());
        WebserviceTriggerProxy.AddAccountToNetSuite('');
        WebserviceTriggerProxy.ApproveEcomRegistration('');
    }

     @isTest static void testShipmentSampleTrigger(){
         try{
            zkmulti__MCShipment__c test = new zkmulti__MCShipment__c();
            insert test;
            test.zkmulti__Tracking_Stage__c = 'Delivered';
            update test;
         }catch(Exception ex){

         }
     }

    @isTest static void contractVersionTriggerTest(){
        Contract__c contract = new Contract__c();
        contract.Status__c = 'Activated';
        contract.Contract_Admin__c = '0054V00000BolB3QAJ';
        insert contract;
        
        Contract_Version__c test = new Contract_Version__c();
        test.Inpro_Contract__c = contract.Id;
        insert test;

        test.Status__c = 'Completed';
        update test;

        test.Status__c = 'Follow Up';
        update test;

        test.Status__c = 'Submitted';
        update test;
    }

    @isTest static void orderRequestTriggerTest(){
        // Create a unique UserName
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@org.com';
        Order_Request__c orderRequest = new Order_Request__c();
        // Pick the Profile you want to test under here
        String profileName = 'Standard User';
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

        // Create a User object that uses that Profile
        User u = new User(
            UserName = uniqueUserName,
            ProfileId = p.Id,
            Alias = 'standt',
            Email = 'user@org.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert u;
        
        System.runAs(u)
        {
            
            orderRequest.Approval_Status__c = 'Submitted';
            insert orderRequest;
        }

        // Create a unique UserName
        String uniqueUserName2 = 'user' + DateTime.now().getTime() + '@org.com';

        // Pick the Profile you want to test under here
        String profileName2 = 'Standard User';
        Profile p2 = [SELECT Id FROM Profile WHERE Name = :profileName];

        // Create a User object that uses that Profile
        User u2 = new User(
            UserName = uniqueUserName2,
            ProfileId = p2.Id,
            Alias = 'standt',
            Email = 'user@org.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert u2;
        System.runAs(u2)
        {
            orderRequest.Approval_Status__c = 'Approved';
            update orderRequest;
        }      
    }

	@isTest static void testQuotePostUpdateTrigger()
    {
        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User();
        u.IsActive = true;
        u.Username = 'elep@kshdfksfh.com';
        u.LastName = 'Lep';
        u.Email = 'elep@kshdfksfh.com';
        u.Alias = 'ELEP';
        u.TimeZoneSidKey = 'America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = p.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;

		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today()
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id,
            Pricebook2Id = pricebookId,
            Status = 'Submitted for Approval'
		);
		insert quoteObj;
        Quote quoteObj2 = new Quote (
			Name = 'This is my Quote 2', 
			OpportunityId = opp.Id,
            Pricebook2Id = pricebookId,
            Status = 'Submitted for Approval'
		);
		insert quoteObj2;

        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(quoteObj.Id);

        req1.setSubmitterId(u.Id); 

        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Contribution_Margin_Approval_v2');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

        Test.startTest();

        quoteObj.Status = 'Approved';
        update quoteObj;

    }

    @isTest static void accountPostCreateTest(){
        Account testAccount = new Account();
        //testAccount.ParentId = '0016g000009eq6yAAA';
        testAccount.Name = 'TEST';
        testAccount.Status__c = 'Prospect';
        testAccount.AccountSource = 'eCommerce';
        testAccount.RecordTypeId = '0124V000001q74UQAQ';
        testAccount.RecordTypeId = '0124V000001q74UQAQ';
        insert testAccount;
    }

    @isTest static void orderRequestTriggerTest2(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User();
        u.IsActive = true;
        u.Username = 'elep@kshdfksfh.com';
        u.LastName = 'Lep';
        u.Email = 'elep@kshdfksfh.com';
        u.Alias = 'ELEP';
        u.TimeZoneSidKey = 'America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = p.Id;
        u.LanguageLocaleKey = 'en_US';
        insert u;

        User u2 = new User();
        u2.IsActive = true;
        u2.Username = 'elep2@kshdfksfh.com';
        u2.LastName = 'Lep';
        u2.Email = 'elep2@kshdfksfh.com';
        u2.Alias = 'ELEP2';
        u2.TimeZoneSidKey = 'America/Chicago';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.ProfileId = p.Id;
        u2.LanguageLocaleKey = 'en_US';
        insert u2;
        
        Order_Request__c orderRequest = new Order_Request__c();
        system.RunAs(u)
        {            
            //testAccount.ParentId = '0016g000009eq6yAAA';
            orderRequest.Required_Approvals__c = 'Credit Hold';
            orderRequest.Order_Amount__c = 10000;
            insert orderRequest;
        }

        system.RunAs(u2)
        {
            orderRequest.Approval_Status__c = 'Approved';
            update orderRequest;
        }

        system.RunAs(u)
        {            
            orderRequest.Approval_Status__c = 'Rejected';
            update orderRequest;
        }
    }   
}