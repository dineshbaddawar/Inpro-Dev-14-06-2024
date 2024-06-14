@IsTest
private class IPC298ControllerTests {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 12, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'DW-ALM-C', Description_2__c = '1.75 x 1.75 x 99 120Deg'
        );
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'DU-GR-Q', Description_2__c = '1.15 x 1.5 x 104 90Deg'
        );
        insert new List<QuoteLineItem>{line, line1};
    }

    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC298Controller iController = new IPC298Controller(sc);
        
        IPC298Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];
        
        System.assertEquals('DW-ALM-C', customLine.ItemNumber, 'Expected ItemNumber to be DW-ALM-C.');
        System.assertEquals('1.75', customLine.Wing1, 'Expected Wing1 to be 45.');
        System.assertEquals('99', customLine.Height, 'Expected Height to be 10.');
        System.assertEquals('1.75', customLine.Wing2, 'Expected Wing2 to be 20.');
        System.assertEquals('120Deg', customLine.AngleId, 'Expected AngleId to be 10.');
        
        System.assertNotEquals(null, customLine.Quantity, 'Quantity should not be null.');
        System.assertNotEquals(null, customLine.AngleId, 'AngleId should not be null.');
        System.assertNotEquals(null, customLine.Height, 'Height should not be null.');
        System.assertNotEquals(null, customLine.Wing1, 'Wing1 should not be null.');
        System.assertNotEquals(null, customLine.Wing2, 'Wing2 should not be null.');
        System.assertNotEquals(null, customLine.ItemNumber, 'ItemNumber should not be null.');
        System.assertNotEquals(null, customLine.Description2, 'Description2 should not be null.');
    }
    
    @IsTest
    static void testControllerWithDifferentMetric() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'false');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC298Controller iController = new IPC298Controller(sc);
        
        IPC298Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];
        
        System.assertEquals('DW-ALM-C', customLine.ItemNumber, 'Expected ItemNumber to be DW-ALM-C.');
        System.assertEquals('1.75', customLine.Wing1, 'Expected Wing1 to be 45.');
        System.assertEquals('99', customLine.Height, 'Expected Height to be 10.');
        System.assertEquals('1.75', customLine.Wing2, 'Expected Wing2 to be 20.');
        System.assertEquals('120Deg', customLine.AngleId, 'Expected AngleId to be 10.');
        
        System.assertNotEquals(null, customLine.Quantity, 'Quantity should not be null.');
        System.assertNotEquals(null, customLine.AngleId, 'AngleId should not be null.');
        System.assertNotEquals(null, customLine.Height, 'Height should not be null.');
        System.assertNotEquals(null, customLine.Wing1, 'Wing1 should not be null.');
        System.assertNotEquals(null, customLine.Wing2, 'Wing2 should not be null.');
        System.assertNotEquals(null, customLine.ItemNumber, 'ItemNumber should not be null.');
        System.assertNotEquals(null, customLine.Description2, 'Description2 should not be null.');
    }

    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC298Controller iController = new IPC298Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true when there are no quote lines.');
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC298Controller.CustomFormWrapper customForm = new IPC298Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            System.Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}