@isTest
private class NewSampleItemHelperTest 
{
    @isTest static void TestBasic_NewSampleItemHelper()
    {
        Territory__c ter = new Territory__c();
        ter.Name = 'Test01';
        ter.Area__c = 'Central US';
        insert ter;
        Account acc1 = new Account();
        acc1.Name = 'Test Super Duper Name';
        acc1.Territory_Lookup__c = ter.Id;
        acc1.ARC_FAC__c = 'FAC';
        insert acc1;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.StageName = 'Negotiation';
        opp.Territory__c = ter.Id;
        opp.CloseDate = Date.today();
        insert opp;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'John';
        con.AccountId = acc1.Id;
        insert con;
        Lead lead = new Lead();
        lead.Street = '123 Nope Blvd';
        lead.LastName = 'Sibley';
        lead.Territory__c = ter.Id;
        lead.Company = 'Inpro Corporation';
        insert lead;

        string results1 = NewSampleRequestHelper.CreateSampleRequest(string.valueOf(acc1.Id), string.valueOf(opp.Id), string.valueOf(con.Id), string.valueOf(lead.Id),
            'UPS Ground', 'Account - Billing', 'Web Request',
            '123 Test St','Wausau','WI','54401','US');
        
        Sample_Request__c sr = NewSampleItemHelper.GetSampleRequest(results1);

        /*String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;

        String results2 = NewSampleItemHelper.CreateSampleRequestItem(sr.Id, prod.Id, '1');
        List<Sample_Request_Item__c> sri = NewSampleItemHelper.GetSampleRequestItems(results2);

        String results3 = NewSampleItemHelper.CreateSampleRequestItems(sr.Id, new List<string>{prod.Id}, new List<string>{'1'});

        String results4 = NewSampleItemHelper.DeleteSampleRequestItems(new List<string>{results2});
        
        List<String> results5 = NewSampleItemHelper.GetProductFamilyPicklist();
        List<String> results6 = NewSampleItemHelper.GetDivisionPicklist();

        List<Product2> results7 = NewSampleItemHelper.AdvancedProductSearch('Bronze','','','');

        System.assert(results3 == 'Success');
        System.assert(results4 == 'Success');
        System.assert(results5.size() > 0);
        System.assert(results6.size() > 0);*/
    }
}