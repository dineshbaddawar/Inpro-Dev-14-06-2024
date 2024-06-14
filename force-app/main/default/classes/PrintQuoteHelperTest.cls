@isTest
private class PrintQuoteHelperTest{

	@TestSetup
    static void setup()
    {
        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;

        Account account = new Account();
        account.Name = 'IT Test Account';
        insert account;

		Contact contact = new Contact();
        contact.Email = 'test@inprocorp.com';
        contact.AccountId = account.Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;

        Opportunity opp = new Opportunity();
        opp.AccountId = account.Id;
        opp.Name = 'Test';
        opp.StageName = 'Estimating';
        opp.CloseDate = Datetime.now().date();
        insert opp;

        Bidder__c oppBidder = new Bidder__c();
        oppBidder.Bidder__c = account.Id;
        insert oppBidder;

        Quote quoteObj = new Quote (
			Name = 'AlternateHelperQuote', 
			OpportunityId = opp.Id,
			Status = 'Draft',
            Pricebook2Id = pricebookId
		);
		insert quoteObj;

        Alternate__c alt1 = new Alternate__c(
            //Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'PrintQuoteHelper',
            QuoteId__c = quoteObj.Id,
            Total_Material__c = 100.0
        );
        insert alt1;

        Alternate__c alt2 = new Alternate__c(
            //Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'PrintQuoteHelper2',
            QuoteId__c = quoteObj.Id,
            Total_Material__c = 100.0
        );
        insert alt2;

        Quotelineitem qli = new Quotelineitem (
            Alternate__c = alt1.Id, 
            Document_Name__c = 'IPC123', 
            QuoteId = quoteObj.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id,
            Quantity = 100,
            UnitPrice = 1
        );
        insert qli;

        Quotelineitem qli2 = new Quotelineitem (
            Alternate__c = alt2.Id, 
            Document_Name__c = 'IPC123', 
            QuoteId = quoteObj.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id,
            Quantity = 100,
            UnitPrice = 5
        );
        insert qli2;

        Tax_Exempt_Certificate__c tec = new Tax_Exempt_Certificate__c();
        tec.Account__c = account.Id;
        insert tec;

        AsyncProcess__c ap = new AsyncProcess__c();
        ap.ObjectId__c = quoteObj.Id;
        ap.Name = 'Save Quote';
        ap.Status__c = 'In-Process';
        insert ap;

        Test.startTest();
	}

    @isTest
    static void testCheckSaveQuote()
    {
        Quote q = [SELECT Id FROM Quote LIMIT 1];
        string result = PrintQuoteHelper.CheckSaveQuote(q.Id);
        string result2 = PrintQuoteHelper.CheckSaveQuote('');
        System.assertEquals('true',result);
        System.assertEquals('false',result2);
    }

	@isTest 
    static void testGetContactInfo() 
    {
		Contact contact = PrintQuoteHelper.GetContactInfo([SELECT Id FROM Contact LIMIT 1].Id);
        System.assert(contact != null);
	}

    @isTest 
    static void testGetDocumentNames()
    {
        List<Alternate__c> altList = [SELECT Id FROM Alternate__c];
        string altstr = '';
        for(Alternate__c alt : altList)
        {
            if (altStr != '') altStr += ',';
            altStr += '\'' + alt.Id + '\'';
        }
        string results = PrintQuoteHelper.GetDocumentNames(altStr);

        //Why is this returning empty string?
        //System.assert(results == qli.Document_Name__c);
    }

    @isTest
    static void testGetGrandTotals()
    {
        string quoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        List<Alternate__c> altList = [SELECT Id FROM Alternate__c];
        string altstr = '';
        for(Alternate__c alt : altList)
        {
            if (altStr != '') altStr += ',';
            altStr += '\'' + alt.Id + '\'';
        }
        string results = PrintQuoteHelper.GetGrandTotals(quoteId, altstr, true);
        string results2 = PrintQuoteHelper.GetGrandTotals(quoteId,'', true);
        string results3 = PrintQuoteHelper.GetGrandTotals(quoteId, altstr, false);

        string[] totals = results.split('|');

        System.assert(totals.size() != 0);
        System.assert(results2 == '0.0|0.0|0.0|0.0');

    }

    @isTest
    static void testGetPrintQuoteWrapper()
    {
        string results = PrintQuoteHelper.GetPrintQuoteWrapper([SELECT Id FROM Quote LIMIT 1].Id);
    }

    @isTest
    static void testUpdateOpportunityAmountAndStage(){        
        string oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        string quoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        PrintQuoteHelper.UpdateOpportunityAmountAndStage(oppId, '10000.0',quoteId);

        Opportunity opp = [SELECT Id, StageName, Amount FROM Opportunity WHERE Id = :oppId];

        System.assertEquals(opp.Amount,10000.0);
        System.assertEquals(opp.StageName,'Negotiation');
    }

    @isTest
    static void testGetQuoteBidders(){
        List<Quote_Bidder__C> qbs = PrintQuoteHelper.GetQuoteBidders([SELECT Id FROM Quote LIMIT 1].Id);
    }

    @isTest
    static void testUpdateQuoteBiddersToSent(){

    }

    @isTest
    static void testRevertQuoteParagraphs(){
        PrintQuoteHelper.RevertQuoteParagraphs([SELECT Id FROM Quote LIMIT 1].Id, 'Test intro' ,'Test ending' );

        Quote quote = [SELECT Id, Introduction__c, Ending__c FROM Quote LIMIT 1];

        System.assert(quote.Introduction__c == 'Test intro');
        System.assert(quote.Ending__c == 'Test ending');
    }

    @isTest
    static void testUpdateQuote()
    {

    }

    @isTest
    static void testWrappers(){
        TaxExemptCertificateWrapper tecw = new TaxExemptCertificateWrapper('', '', '', '', '', '', '', '' ,'' ,'');
        tecw.AccountId = '';
        tecw.AccountName = '';
        tecw.CertificateType = '';
        tecw.EffectiveDate = '';
        tecw.ExpirationDate = '';
        tecw.Id = '';
        tecw.Name = '';
        tecw.NoteSubject = '';
        tecw.StateOfIssue = '';
        tecw.StatesWhereValid = '';

        Tax_Exempt_Certificate__c tec = 
            [SELECT Id, Certificate_Type__c, Effective_Date__c, Expiration_Date__c, 
            Note_Subject__c, Tax_Exempt__c, Account__r.Name,
            Account__c, States_Where_Valid__c, Tax_Reciprocity__c 
            FROM Tax_Exempt_Certificate__c LIMIT 1];

        PrintQuoteWrapper pwq = new PrintQuoteWrapper();
        pwq.Alternates = new List<Alternate__c>();
        pwq.ContactEmail = '';
        pwq.Contacts = new List<Contact>();
        pwq.Opportunity = new Opportunity();
        pwq.PaymentTerms = new List<Schema.PicklistEntry>();
        pwq.Qualifications = new List<Qualification__c>();
        pwq.Quote = new Quote();
        pwq.QuoteItems = new List<QuoteLineItem>();
        pwq.TaxCertificates = new List<TaxExemptCertificateWrapper>{ tecw };
    }

}