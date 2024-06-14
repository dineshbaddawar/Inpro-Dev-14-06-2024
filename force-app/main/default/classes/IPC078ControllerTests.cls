@isTest
private class IPC078ControllerTests {

    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', Color__c = 'Clamshell-0154', Document_Name__c = 'IPC.078 Test');
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 5, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', Color__c = 'Blue-0154', Document_Name__c = 'Test2');
        insert new List<QuoteLineItem>{line1, line2};
    }

    @isTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];

        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC078Controller iController = new IPC078Controller(sc);

        System.assertNotEquals(null, iController.customForm, 'customForm should not be null');
        System.assertNotEquals(null, iController.customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, iController.customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, iController.customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(1, iController.customForm.quoteLines.size(), 'There should be one quote line item');

        IPC078Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];

        System.assertEquals('855', customLine.ItemNumber, 'ItemNumber should be 855');
        System.assertEquals('Clamshell', customLine.colorName, 'colorName should be Clamshell');
        System.assertEquals('0154', customLine.colorNumber, 'colorNumber should be 0154');
        System.assertEquals(1, customLine.Quantity, 'Quantity should be 1');
        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false');

        System.assertNotEquals(null, customLine.ItemNumber, 'ItemNumber should not be null.');
        System.assertNotEquals(null, customLine.colorName, 'colorName should not be null.');
        System.assertNotEquals(null, customLine.colorNumber, 'colorNumber should not be null.');
    }
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC078Controller iController = new IPC078Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC078Controller.CustomFormWrapper customForm = new IPC078Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}