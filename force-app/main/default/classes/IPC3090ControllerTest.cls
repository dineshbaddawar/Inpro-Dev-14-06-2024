@isTest
public class IPC3090ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on',document_Name__c = 'IPC.3090',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c = '18',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4',document_Name__c = 'IPC.3090',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Operator__c = '16',
            Item_Number__c = 'DW-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3',document_Name__c = 'IPC.214',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'D12345-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line4 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'cement on',document_Name__c = 'IPC.3090',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304',Operator__c = '20',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154' );
        QuoteLineItem line5 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '1/8',document_Name__c = 'IPC.3090',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304',Operator__c = '14',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154' );
        QuoteLineItem line6 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '3/4',document_Name__c = 'IPC.3090',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304',Operator__c = '14',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154' );


        insert new List<QuoteLineItem>{line1, line2,line3,line4,line5,line6};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC3090Controller controller = new IPC3090Controller();
        IPC3090Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertNotEquals(null, customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(5, customForm.quoteLines.size(), 'quoteLines size should be 3');
    }
    
    @IsTest
    static void testControllerWithNullQuoteId() {
        
        ApexPages.currentPage().getParameters().put('quoteId', null);
        IPC3090Controller controller = new IPC3090Controller();
        IPC3090Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');        
        System.assertEquals(null, customForm.quoteLines, 'quoteLines should be null when quoteId is null');
    }
    
    @IsTest
    static void testControllerWithMetricTrue() {
        
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        IPC3090Controller controller = new IPC3090Controller();
        IPC3090Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertEquals(true, controller.isMetric, 'isMetric should be true when isMetric parameter is set to True');
    }
    
    @IsTest
    static void testControllerWithNullMetric() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        IPC3090Controller controller = new IPC3090Controller();
        IPC3090Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertEquals(false, controller.isMetric, 'isMetric should be false when isMetric parameter is null');
    }
    
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC3090Controller.CustomFormWrapper customForm = new IPC3090Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}