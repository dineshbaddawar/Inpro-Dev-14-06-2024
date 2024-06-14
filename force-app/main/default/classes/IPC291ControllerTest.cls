@isTest
public class IPC291ControllerTest {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on',document_Name__c = 'IPC.287',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',
            Item_Number__c = 'GTVR', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4',document_Name__c = 'IPC.254',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'DW-BEND AR', Color__c = 'Clamshell-0154' );
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4',document_Name__c = 'IPC.254',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'DW-BE', Color__c = 'Clamshell-0154' );
        
        insert new List<QuoteLineItem>{line1, line2,line3};
            }
    
    
  @isTest
    static void testConstructorWithQuoteId() {
        Test.startTest();
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('quoteId', testQuote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC291Controller controller = new IPC291Controller();
        System.assert(controller.isMetric, 'isMetric should be true');
        System.assert(controller.customForm != null, 'customForm should be instantiated');
        System.assert(controller.customForm.quoteRecord != null, 'customForm.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, testQuote.Id, 'customForm.quoteRecord should be the testQuote');
        System.assert(controller.customForm.quoteLines != null, 'customForm.quoteLines should not be null');
        System.assert(controller.customForm.quoteLines.size() == 2, 'customForm.quoteLines should contain 2 items');
        System.assert(!controller.BlankForm, 'BlankForm should be false because quoteId is provided and there are valid quote lines');
        
        Test.stopTest();
    }
    
    @isTest
    static void testConstructorWithEmptyQuoteLines() {
        Test.startTest();
         Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', testQuote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC291Controller controller = new IPC291Controller();
        System.assert(controller.isMetric, 'isMetric should be true');
        System.assert(controller.customForm != null, 'customForm should be instantiated');
        System.assert(controller.customForm.quoteRecord != null, 'customForm.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, testQuote.Id, 'customForm.quoteRecord should be the testQuote');
        Test.stopTest();
    }
       @IsTest
    static void testControllerWithNullQuoteId() {
        
        ApexPages.currentPage().getParameters().put('quoteId', null);
        IPC291Controller controller = new IPC291Controller();
        IPC291Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');        
        System.assertEquals(null, customForm.quoteLines, 'quoteLines should be null when quoteId is null');
    }
    
}