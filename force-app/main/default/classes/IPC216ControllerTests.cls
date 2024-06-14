@isTest
private class IPC216ControllerTests {

    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'K41', Color__c = 'Clamshell-0154');
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'K42', Color__c = 'Clamshell-0154');
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'TABC81', Color__c = 'Clamshell-0154');
        insert new List<QuoteLineItem>{line, line1, line2};
    }

    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC216Controller iController = new IPC216Controller(sc);
        List<IPC216Controller.CustomQuoteLineItem> customLines = iController.customForm.quoteLines;
        System.assertEquals(2, customLines.size(), 'Expected to find two CustomQuoteLineItems.');
        for (IPC216Controller.CustomQuoteLineItem customLine : customLines) {
            System.assertEquals('Clamshell', customLine.colorName, 'Expected colorName to be Clamshell.');
            System.assertEquals('0154', customLine.colorNumber, 'Expected colorNumber to be 0154.');
            System.assertEquals(1, customLine.Quantity, 'Expected Quantity to be 1.');
        }
    }

    @IsTest
    static void testController1() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC216Controller iController = new IPC216Controller(sc);
        List<IPC216Controller.CustomQuoteLineItem> customLines = iController.customForm.quoteLines;
        System.assertEquals(2, customLines.size(), 'Expected to find two CustomQuoteLineItems.');
        Set<String> itemNumbers = new Set<String>();
        for (IPC216Controller.CustomQuoteLineItem customLine : customLines) {
            itemNumbers.add(customLine.ItemNumber);
            System.assertEquals('Clamshell', customLine.colorName, 'Expected colorName to be Clamshell.');
            System.assertEquals('0154', customLine.colorNumber, 'Expected colorNumber to be 0154.');
            System.assertEquals(1, customLine.Quantity, 'Expected Quantity to be 1.');
        }
        System.assert(itemNumbers.contains('K41'), 'Expected ItemNumber to include K41.');
        System.assert(itemNumbers.contains('K42'), 'Expected ItemNumber to include K42.');
    }
    
    @IsTest
    static void testControllerBlankForm() {
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('quoteId', null);
        pageRef.getParameters().put('isMetric', 'true');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC216Controller controller = new IPC216Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertEquals(controller.BlankForm, true, 'BlankForm should be true when there are no quote lines');
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('isMetric', 'true');
        pageRef.getParameters().put('quoteId', quote1.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote1);
        IPC216Controller controller = new IPC216Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertNotEquals(controller.customForm, null, 'CustomFormWrapper instance should not be null');
        System.assertNotEquals(controller.customForm.quoteRecord, null, 'CustomFormWrapper.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, quote1.Id, 'Quote record Id should match the inserted quote Id');
        
        System.assertNotEquals(controller.customForm.quoteLines, null, 'CustomFormWrapper.quoteLines should not be null');
        System.assertEquals(controller.customForm.quoteLines.size(), 0, 'Quote lines should be empty');
    }
}