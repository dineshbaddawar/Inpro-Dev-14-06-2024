@isTest
private class NewSampleRequestHelperTest 
{
    @isTest static void TestGetAddress()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        acc1.BillingStreet = '123 Test St';
        acc1.ShippingStreet = '456 Test Ln';
        insert acc1;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        con.OtherStreet = '789 Test Cr';
        insert con;
        Lead lead = new Lead();
        lead.Street = '123 Nope Blvd';
        lead.LastName = 'Sibley';
        lead.Company = 'Inpro Corporation';
        insert lead;

        List<string> results1Bad = NewSampleRequestHelper.GetAddress('Account - Billing','','','');
        List<string> results1Good = NewSampleRequestHelper.GetAddress('Account - Billing',acc1.Id,'','');
        List<string> results2Bad = NewSampleRequestHelper.GetAddress('Account - Shipping','','','');
        List<string> results2Good = NewSampleRequestHelper.GetAddress('Account - Shipping',acc1.Id,'','');
        List<string> results3Bad = NewSampleRequestHelper.GetAddress('Contact - Contact\'s Address','','','');
        List<string> results3Good = NewSampleRequestHelper.GetAddress('Contact - Contact\'s Address','',con.Id,'');
        List<string> results4Bad = NewSampleRequestHelper.GetAddress('Lead - Mailing','','','');
        List<string> results4Good = NewSampleRequestHelper.GetAddress('Lead - Mailing','','',lead.Id);
        List<string> results5Good = NewSampleRequestHelper.GetAddress('Inpro Europe','','','');
        List<string> results6Good = NewSampleRequestHelper.GetAddress('','','','');

        System.assertEquals(results1Bad[0],'');
        System.assertEquals(results1Good[0],'123 Test St');
        System.assertEquals(results2Bad[0],'');
        System.assertEquals(results2Good[0],'456 Test Ln');
        System.assertEquals(results3Bad[0],'');
        System.assertEquals(results3Good[0],'789 Test Cr');
        System.assertEquals(results4Bad[0],'');
        System.assertEquals(results4Good[0],'123 Nope Blvd');
        System.assertEquals(results5Good[0],'');
        System.assertEquals(results6Good[0],'');
    }

    @isTest static void TestGetAccountName()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        insert acc1;

        String name = NewSampleRequestHelper.GetAccountName(acc1.Id);

        System.assertEquals(acc1.Name, name);
    }

    @isTest static void TestGetContactDetails()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        insert acc1;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        insert con;

        Contact result = NewSampleRequestHelper.GetContactDetails(con.Id);

        System.assertEquals(result.Id,con.Id);
    }

    @isTest static void TestGetOpportunity()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        insert acc1;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.StageName = 'Negotiation';
        opp.CloseDate = Date.today();
        insert opp;

        Opportunity result = NewSampleRequestHelper.GetOpportunity(opp.Id);
        System.assertEquals(opp.Id,result.Id);
    }

    @isTest static void TestContactSearch(){
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        insert acc1;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.StageName = 'Negotiation';
        opp.CloseDate = Date.today();
        insert opp;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        insert con;

        List<LookupSearchResult> results1 = NewSampleRequestHelper.ContactSearch('Sibley', 'Sibley', new List<string>(), acc1.Id, opp.Id);
        List<LookupSearchResult> results2 = NewSampleRequestHelper.ContactSearch('Sibley', 'Sibley', new List<string>(), acc1.Id, '');
        List<LookupSearchResult> results3 = NewSampleRequestHelper.ContactSearch('Sibley', 'Sibley', new List<string>(), '', opp.Id);

        System.assertEquals(results1.size(),1);
        System.assertEquals(results2.size(),1);
        System.assertEquals(results3.size(),1);
    }

    @isTest static void TestOpportunitySearch()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        insert acc1;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.StageName = 'Negotiation';
        opp.CloseDate = Date.today();
        insert opp;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        insert con;

        List<LookupSearchResult> results1 = NewSampleRequestHelper.OpportunitySearch('Test', 'Test', new List<string>());

        System.assertEquals(results1.size(),1);
    }

    @isTest static void TestGetDesiredShippingMethodPicklist()
    {
        System.assert(NewSampleRequestHelper.GetDesiredShippingMethodPicklist().size() > 0);
    }

    @isTest static void TestGetShipToPicklist()
    {
        System.assert(NewSampleRequestHelper.GetShipToPicklist().size() > 0);
    }

    @isTest static void TestGetTypePicklist()
    {
        System.assert(NewSampleRequestHelper.GetTypePicklist().size() > 0);
    }

    @isTest static void TestGetContactsFromAccounts()
    {
        Territory__c ter = new Territory__c();
        ter.Name = 'Test01';
        ter.Area__c = 'Central US';
        insert ter;
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        acc1.Territory_Lookup__c = ter.Id;
        insert acc1;
        Account acc2 = new Account();
        acc2.Name = 'Test Super Duper Name 2';
        acc1.Territory_Lookup__c = ter.Id;
        insert acc2;
        Account acc3 = new Account();
        acc3.Name = 'Test Super Duper Name 3';
        acc1.Territory_Lookup__c = ter.Id;
        insert acc3;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.Building_Owner__c = acc2.Id;
        opp.Building_Owner_Parent__c = acc3.Id;
        opp.StageName = 'Negotiation';
        opp.Territory__c = ter.Id;
        opp.CloseDate = Date.today();
        insert opp;
        Contact con1 = new Contact();
        con1.LastName = 'Smith';
        con1.FirstName = 'Philip';
        con1.AccountId = acc1.Id;
        insert con1;
        Contact con2 = new Contact();
        con2.LastName = 'Smith';
        con2.FirstName = 'Joseph';
        con2.AccountId = acc2.Id;
        insert con2;
        Contact con3 = new Contact();
        con3.LastName = 'Smith';
        con3.FirstName = 'Ann';
        con3.AccountId = acc3.Id;
        insert con3;

        List<Contact> results = NewSampleRequestHelper.GetContactsFromAccounts(acc1.Id, opp.Id);

        System.assertEquals(results.size(),3);
    }

    @isTest static void TestCreateSampleRequest()
    {
        Territory__c ter = new Territory__c();
        ter.Name = 'Test01';
        ter.Area__c = 'Central US';
        insert ter;
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        acc1.Territory_Lookup__c = ter.Id;
        insert acc1;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.StageName = 'Negotiation';
        opp.CloseDate = Date.today();
        opp.Territory__c = ter.Id;
        insert opp;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        insert con;
        Lead lead = new Lead();
        lead.Street = '123 Nope Blvd';
        lead.LastName = 'Sibley';
        lead.Company = 'Inpro Corporation';
        lead.Territory__c = ter.Id;
        insert lead;

        string results1 = NewSampleRequestHelper.CreateSampleRequest(string.valueOf(acc1.Id), string.valueOf(opp.Id), string.valueOf(con.Id), string.valueOf(lead.Id),
            'UPS Ground', 'Account - Billing', 'Web Request',
            '123 Test St','Wausau','WI','54401','US');
        string results2 = NewSampleRequestHelper.CreateSampleRequest(string.valueOf(acc1.Id), string.valueOf(opp.Id), string.valueOf(con.Id), string.valueOf(lead.Id),
            'UPS Next Day', 'Account - Billing', 'Web Request',
            '123 Test St','Wausau','WI','54401','US');
        string results3 = NewSampleRequestHelper.CreateSampleRequest(string.valueOf(acc1.Id), string.valueOf(opp.Id), string.valueOf(con.Id), string.valueOf(lead.Id),
            'UPS Second Day Air', 'Account - Billing', 'Web Request',
            '123 Test St','Wausau','WI','54401','US');
        string results4 = NewSampleRequestHelper.CreateSampleRequest(string.valueOf(acc1.Id), string.valueOf(opp.Id), string.valueOf(con.Id), string.valueOf(lead.Id),
            'UPS Third Day Select', 'Account - Billing', 'Web Request',
            '123 Test St','Wausau','WI','54401','US');

        Sample_Request__c sr1 = [SELECT Id FROM Sample_Request__c WHERE Desired_Shipping_Method__c = 'UPS_Ground'];
        Sample_Request__c sr2 = [SELECT Id FROM Sample_Request__c WHERE Desired_Shipping_Method__c = 'UPS_NEXT_DAY_AIR'];
        Sample_Request__c sr3 = [SELECT Id FROM Sample_Request__c WHERE Desired_Shipping_Method__c = 'UPS_SECOND_DAY_AIR'];
        Sample_Request__c sr4 = [SELECT Id FROM Sample_Request__c WHERE Desired_Shipping_Method__c = 'UPS_THREE_DAY_SELECT'];

        System.assertEquals(sr1.Id, results1);
        System.assertEquals(sr2.Id, results2);
        System.assertEquals(sr3.Id, results3);
        System.assertEquals(sr4.Id, results4);
    }
}