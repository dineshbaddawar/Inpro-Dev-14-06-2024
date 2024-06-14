@isTest
public class IPC287ControllerTest {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on',document_Name__c = 'IPC.287',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4',document_Name__c = 'IPC.254',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'DW-BEND', Color__c = 'Clamshell-0154' );
        
        insert new List<QuoteLineItem>{line1, line2};
            }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC287Controller controller = new IPC287Controller();
        IPC287Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertNotEquals(null, customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(1, customForm.quoteLines.size(), 'quoteLines size should be 1');
    }
    
      @IsTest
    static void testControllerWithNullQuoteId() {
        
        ApexPages.currentPage().getParameters().put('quoteId', null);
        IPC287Controller controller = new IPC287Controller();
        IPC287Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');        
        System.assertEquals(null, customForm.quoteLines, 'quoteLines should be null when quoteId is null');
    }
    
}