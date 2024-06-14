@isTest
private class IPC089ControllerTests {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = '855',Document_Name__c ='IPC.089', Color__c = 'Clamshell-0154');
        insert new List<QuoteLineItem>{line1};
            }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC089Controller iController = new IPC089Controller(sc);
    }
    
}