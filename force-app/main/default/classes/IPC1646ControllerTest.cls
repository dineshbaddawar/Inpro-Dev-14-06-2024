@isTest
public class IPC1646ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
       QuoteLineItem line1 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = 'screw HUU', Description = 'screw on', Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'SSWPGT', Color__c = 'Clamshell-0154');
        QuoteLineItem line2 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = 'GHU IPC', Description = 'w/ adh',  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'DW-SSWP1PDW-BEND', Color__c = 'Clamshell-0154');
        QuoteLineItem line3 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = 'screw IPC', Description = '4/3',  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'DSF3PD12345-BEND', Color__c = 'Clamshell-0154');
        insert new List<QuoteLineItem>{line1, line2, line3};
    }

    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'false');
        IPC1646Controller controller = new IPC1646Controller();
        IPC1646Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertNotEquals(null, customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(2, customForm.quoteLines.size(), 'quoteLines size should be 2');
        System.assertEquals(false, controller.isMetric, 'isMetric should be false');
        System.assertEquals(false, controller.BlankForm, 'BlankForm should be false');
    }

    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        IPC1646Controller controller = new IPC1646Controller();
        System.assertEquals(true, controller.BlankForm, 'BlankForm should be true');
    }

    @IsTest
    static void testControllerIsMetricTrue() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC1646Controller controller = new IPC1646Controller();
        System.assertEquals(true, controller.isMetric, 'isMetric should be true');
    }
    
    @IsTest
    static void testControllerNoQuoteId() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC1646Controller controller = new IPC1646Controller();
        System.assertEquals(true, controller.BlankForm, 'BlankForm should be true');
    }
    
}