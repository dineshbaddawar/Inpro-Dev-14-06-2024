@IsTest
private class IPC3211ControllerTests {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 12, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Document_Name__c = 'IPC.3211', Brackets__c = 'Bracket1', Brackets_2__c = 'Bracket2', 
            Height__c = 10.5, Width__c = 20.0, 
            Item_Number__c = 'SS-123', Alloy_Type__c = '430', Operator__c = '14', Description = 'screw-On'
        );
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 12, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Document_Name__c = 'IPC.3211', Brackets__c = 'Bracket1', Brackets_2__c = 'Bracket2', 
            Height__c = 10.5, Width__c = 20.0, 
            Item_Number__c = 'SS-123', Alloy_Type__c = '304', Operator__c = '18', Description = 'screw-On'
        );
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 12, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Document_Name__c = 'IPC.3211', Brackets__c = 'Bracket1', Brackets_2__c = 'Bracket2', 
            Height__c = 10.5, Width__c = 20.0, 
            Item_Number__c = 'SS-123', Alloy_Type__c = '304', Operator__c = '16', Description = 'cement-On'
        );
        
        insert new List<QuoteLineItem>{line,line2};
    }

    @IsTest
    static void testControllerWithMetricTrue() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC3211Controller iController = new IPC3211Controller(sc);
        
        IPC3211Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];
        
        System.assertEquals('Bracket1', customLine.Bracket, 'Expected Bracket to be Bracket1.');
        System.assertEquals('Bracket2', customLine.Bracket2, 'Expected Bracket2 to be Bracket2.');
        System.assertEquals(10.5, customLine.Height, 'Expected Height to be 10.5.');
        System.assertEquals(20.0, customLine.Width, 'Expected Width to be 20.0.');
        System.assertEquals('333', customLine.SteelType, 'Expected SteelType to be checked.');
        System.assertEquals('333', customLine.AllyType430, 'Expected AllyType430 to be checked.');
        System.assertEquals('333', customLine.Operator14, 'Expected Operator14 to be checked.');
        System.assertEquals('333', customLine.MountingScrew, 'Expected MountingScrew to be checked.');
    }

    @IsTest
    static void testControllerWithMetricFalse() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'false');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC3211Controller iController = new IPC3211Controller(sc);
        
        IPC3211Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];
        
        System.assertEquals('Bracket1', customLine.Bracket, 'Expected Bracket to be Bracket1.');
        System.assertEquals('Bracket2', customLine.Bracket2, 'Expected Bracket2 to be Bracket2.');
        System.assertEquals(10.5, customLine.Height, 'Expected Height to be 10.5.');
        System.assertEquals(20.0, customLine.Width, 'Expected Width to be 20.0.');
        System.assertEquals('333', customLine.SteelType, 'Expected SteelType to be checked.');
        System.assertEquals('333', customLine.AllyType430, 'Expected AllyType430 to be checked.');
        System.assertEquals('333', customLine.Operator14, 'Expected Operator14 to be checked.');
        System.assertEquals('333', customLine.MountingScrew, 'Expected MountingScrew to be checked.');
    }

    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC3211Controller iController = new IPC3211Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true when there are no quote lines.');
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC3211Controller.CustomFormWrapper customForm = new IPC3211Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            System.Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}