@isTest
public class QuoteBidPDFControllerTest {
    @testSetup static void setup(){
		/*CurrencyType_History__c cth = new CurrencyType_History__c();
        cth.CurrencyIsoCode = [SELECT Id, IsoCode FROM CurrencyType LIMIT 1].IsoCode;
        cth.IsActive__c = true;
        cth.ConversionRate__c = 1.3;
        cth.OwnerId = [SELECT Id from USER LIMIT 1].Id;
        insert cth;*/
	}

    @isTest static void testQuoteBidPDFController(){
        String pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        List<sObject> accounts = Test.loadData(Account.sObjectType, 'testAccounts');
        

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
            AccountId = accounts.get(0).id
        );
        insert opp;
        
        Quote quote = new Quote (
            Name = 'test value', 
            OpportunityId = opp.Id,
            Inpro_Document_Number__c = 'Q1234567 Test Bad Guy'
        );
        insert quote;
        Contact contactObj = new Contact (
            AccountId = accounts.get(0).Id, 
            FirstName = 'test value', 
            LastName = 'test value'
        );
        insert contactObj;
        
        
        Alternate__c alt1 = new Alternate__c(
            Group_Name__c = 'Group',
            Number__c = 111,
            Name__c = 'Alternate CZ',
            QuoteId__c = quote.Id,
            Sequence_Number__c = 1,
            Tax_Percent__c = 5
        );
        insert alt1;

        Quotelineitem quotelineitemObj = new Quotelineitem (
            Description = 'test value', 
            Alternate__c = alt1.Id, 
            Custom_Pricing_Requested__c = false, 
            Customer_Priced_On__c = 'test value', 
            Description_2__c = 'Test Value', 
            Document_Name__c = 'test value', 
            Is_Custom_Product__c = true, 
            Quantity = 1.1, 
            UnitPrice = 1.1,
            Item_Number__c = '123',
            ParentID__c = '123',
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Product2Id = prod.Id,
            LineNumber__c = 1,
            Sequence_Number__c = 1,
            Alternate_Number__c = 1,
            Unit_Weight__c = 1
        );
        insert quotelineitemObj;
       
        string strAlternates = '';
        for( QuoteLineItem Item:[SELECT Id,Alternate__c FROM QuoteLineItem where QuoteId =: quote.Id])
        {
            strAlternates += Item.Alternate__c+'%2C';          
        }

        Print_Quote__c printQuote = new Print_Quote__c();
        printQuote.Project__c = 'IPC - Test';
        printQuote.Location__c = 'Muskego, wisconsin, 53150';
        printQuote.Quote__c = quote.Id;
        printQuote.User__c = [SELECT Id from USER LIMIT 1].Id;
        insert printQuote;

        string url='/apex/Quote_w_Pricing_PDF?printquoteId=' + printQuote.Id + '&alternates=' + strAlternates + '&quoteId=' + quote.Id;
        PageReference pageRef = new PageReference(url);
        Test.setCurrentPage(pageRef);
        QuoteBidPDFController PDFController = new QuoteBidPDFController();
        
        Test.startTest();
    }
    
    
}