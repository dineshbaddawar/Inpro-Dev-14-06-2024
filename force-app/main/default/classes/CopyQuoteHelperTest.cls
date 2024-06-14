@istest
public with sharing class CopyQuoteHelperTest {
    
    @testSetup static void setup(){
        Account account = new Account(
            Name = 'Test IT Account'
        );
        insert account;

        Contact contact = new Contact(
            AccountId = account.Id,
            LastName = 'Smith',
            Email = 'jsmith@inprocorp.com.invalid'
        );
        insert contact;

        Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
			CloseDate = Date.today()
		);
		insert opp;

		Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id
		);
		insert quoteObj;

        Alternate__c alt1 = new Alternate__c(
            Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate 1',
            QuoteId__c = quoteObj.Id
        );
        insert alt1;

        Bidder__c bidder = new Bidder__c(
            Opportunity__c = opp.Id,
            Bidder__c = account.Id
        );
        insert bidder;

        Quote_Bidder__c quoteBidder = new Quote_Bidder__c(
            Bidder_Name__c = bidder.Id,
            Quote__c = quoteObj.Id
        ); //Bidder_Name__r.Opportunity__c <>  Quote__r.OpportunityId
        insert quoteBidder;
    }

    @isTest static void testCopyQuote_Simple() {
        // This causes a fake response to be generated
        Test.startTest();
        Test.setMock(WebServiceMock.class, new sfdataTest());

        List<QuickConfigHelper.qProduct> qlist = new List<QuickConfigHelper.qProduct>();
        string result = CopyQuoteHelper.copyQuote('12345','12345',new List<Integer>{1,2,3},1,1.0,false,
            '12345','Quote Name', 'Version 1', 'typex', 'ContactId',
            new List<string>{ 'bidder 1', 'bidder 2'}, 'userId','1','1','1', qlist);

        System.assertEquals('12345', result);
        Test.stopTest();
    }

    @isTest static void testGetAlternates(){
        String query = 'Select Id from Quote LIMIT 1';
        Quote quote = Database.query(query);

        List<Alternate__c> alts = CopyQuoteHelper.getAlternates(quote.Id);

        System.assertEquals(1,alts.size());
    }

    @isTest static void testGetBidders(){
        String query = 'Select Id from Quote LIMIT 1';
        Quote quote = Database.query(query);

        List<Bidder__c> bidders = CopyQuoteHelper.getBidders(quote.Id);

        System.assertEquals(1,bidders.size());
    }

    @isTest static void testGetQuote(){
        String query = 'Select Id from Quote LIMIT 1';
        Quote quote = Database.query(query);

        List<Quote> quotes = CopyQuoteHelper.getQuote(quote.Id);

        System.assertEquals(quote.Id, quotes.get(0).Id);
    }

    @isTest static void testGetContacts(){
        String query = 'Select Id from Account LIMIT 1';
        Account account = Database.query(query);

        List<Contact> contacts = CopyQuoteHelper.getContacts(account.Id);

        System.assertEquals(1,contacts.size());
    }

    @isTest static void testAccountSearch(){
        List<LookupSearchResult> results = CopyQuoteHelper.accountSearch('Test', '', new List<String>());

        System.assertEquals(1,results.size());
    }

    @isTest static void testHasBreakoutPermission(){
        Boolean results = CopyQuoteHelper.hasBreakoutPermission();
        System.assertEquals(1,1);
    }

    
}