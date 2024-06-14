@isTest
private class NewBidderHelperTest 
{
    @isTest static void TestGetDivisionPicklist()
    {
        Division__c div = new Division__c();
        div.Name = 'IPC';
        insert div;

        System.assertEquals(NewBidderHelper.GetDivisionPicklist().size(), 1);
    }

    @istest static void TestGetDivSectionPicklist()
    {
        System.assert(NewBidderHelper.GetDivSectionPicklist().size() > 0);
    }

    @istest static void TestGetPricingGroupPicklist()
    {
        System.assert(NewBidderHelper.GetPricingGroupPicklist().size() > 0);
    }

    @istest static void TestGetSourcePicklist()
    {
        System.assert(NewBidderHelper.GetSourcePicklist().size() > 0);
    }

    @istest static void TestGetInstallationTypePicklist()
    {
        System.assert(NewBidderHelper.GetInstallationTypePicklist().size() > 0);
    }

    @istest static void TestGetQuoteStatusPicklist()
    {
        System.assert(NewBidderHelper.GetQuoteStatusPicklist().size() > 0);
    }

    @isTest static void TestGetAccountsOnConstructionProject()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test 1';
        insert acc1;
        Account acc2 = new Account();
        acc2.Name = 'Test 2';
        insert acc2;
        Construction_Project__c cp = new Construction_Project__c();
        cp.Parent_Account__c = acc1.Id;
        cp.Building_Owner__c = acc2.Id;
        cp.Name = 'Test CP';
        insert cp;
        
        List<Account> results = NewBidderHelper.GetAccountsOnConstructionProject(cp.Id);

        System.assertEquals(results.size(),2);
    }

    @isTest static void TestCreateBidder()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test 1';
        insert acc1;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'Joe';
        con.AccountId = acc1.Id;
        insert con;
        Account acc2 = new Account();
        acc2.Name = 'Test 2';
        insert acc2;
        Construction_Project__c cp = new Construction_Project__c();
        cp.Parent_Account__c = acc1.Id;
        cp.Building_Owner__c = acc2.Id;
        cp.Name = 'Test CP';
        insert cp;
        Division__c div = new Division__c();
        div.Name = 'IPC';
        insert div;

        List<string> results = 
            NewBidderHelper.CreateBidder(cp.Id, acc1.Id, con.Id, null,null,'Cold Call',
                null,null,null,
                new List<string>{div.Id},null);
        
        System.assertEquals(results.size(), 1);
    }

    @isTest static void TestCreateBidder_Exception()
    {
        Account acc1 = new Account();
        acc1.Name = 'Test 1';
        insert acc1;
        Contact con = new Contact();
        con.LastName = 'Sibley';
        con.FirstName = 'Joe';
        con.AccountId = acc1.Id;
        insert con;
        Account acc2 = new Account();
        acc2.Name = 'Test 2';
        insert acc2;
        Construction_Project__c cp = new Construction_Project__c();
        cp.Parent_Account__c = acc1.Id;
        cp.Building_Owner__c = acc2.Id;
        cp.Name = 'Test CP';
        insert cp;
        Division__c div = new Division__c();
        div.Name = 'IPC';
        insert div;

        List<string> results = 
            NewBidderHelper.CreateBidder(cp.Id, null, con.Id, null,null,'Cold Call',
                null,null,null,
                new List<string>{div.Id},null);
        
        System.assertEquals(results.size(), 3);
        System.assertEquals(results[0],'Failure');
    }
}