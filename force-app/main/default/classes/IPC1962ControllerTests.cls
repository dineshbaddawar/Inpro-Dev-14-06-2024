@isTest
public class IPC1962ControllerTests {
    @testSetup
    static void makeData() {
       
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on', document_Name__c = 'IPC.1962',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id );
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'w/ adh', document_Name__c = 'IPC.1962',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id );
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3', document_Name__c = 'IPC.1962',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id );
        
        QuoteLineItem line4 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'w/ adh', document_Name__c = 'IPC.07777',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id );
        
        insert new List<QuoteLineItem>{line1, line2, line3, line4};
    }
    
    @IsTest
    static void testController() {
        
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
       
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        
        IPC1962Controller controller = new IPC1962Controller();
        IPC1962Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertNotEquals(null, customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(3, customForm.quoteLines.size(), 'quoteLines size should be 3');
    }
    
    @IsTest
    static void testControllerWithNullQuoteId() {
        
        ApexPages.currentPage().getParameters().put('quoteId', null);
        
        IPC1962Controller controller = new IPC1962Controller();
        IPC1962Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertEquals(null, customForm.quoteLines, 'quoteLines should be null when quoteId is null');
    }
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC1962Controller.CustomFormWrapper customForm = new IPC1962Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}