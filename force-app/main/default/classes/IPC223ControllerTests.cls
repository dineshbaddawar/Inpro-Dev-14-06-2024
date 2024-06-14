@isTest
private class IPC223ControllerTests {

    @testSetup
    static void makeData() {
      
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', Color__c = 'Clamshell-0154', Size__c = '256sr', 
            Type__c = '1', Vendor__c = 'Text 2', Document_Name__c = 'IPC.223 Test', 
            Pattern__c = 'stright', Style__c = 'Ripplefold - Overlap Master');
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 5, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', Color__c = 'Blue-0154', Size__c = '512sr', 
            Type__c = '2', Vendor__c = 'Text 3', Document_Name__c = 'Test2', 
            Pattern__c = 'curved', Style__c = 'Pleated');
        insert new List<QuoteLineItem>{line1, line2};
    }

    @isTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];

        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC223Controller iController = new IPC223Controller(sc);

        System.assertNotEquals(null, iController.customForm, 'customForm should not be null');
        System.assertNotEquals(null, iController.customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, iController.customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, iController.customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(1, iController.customForm.quoteLines.size(), 'There should be one quote line item');

        IPC223Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];

        System.assertEquals('855', customLine.ItemNumber, 'ItemNumber should be 855');
        System.assertEquals('Clamshell-0154', customLine.Color, 'Color should be Clamshell-0154');
        System.assertEquals('Clamshell', customLine.colorName, 'colorName should be Clamshell');
        System.assertEquals('0154', customLine.colorNumber, 'colorNumber should be 0154');
        System.assertEquals(1, customLine.Quantity, 'Quantity should be 1');
        System.assertEquals('256sr', customLine.size, 'size should be 256sr');
        System.assertEquals('1', customLine.type, 'type should be 1');
        System.assertEquals('Text 2', customLine.vendor, 'vendor should be Text 2');
        System.assertEquals('stright', customLine.patten, 'patten should be stright');
        System.assertEquals('Ripplefold - Overlap Master', customLine.style, 'style should be Ripplefold - Overlap Master');

        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false');
        System.assert(customLine.DocumentName.startsWith('IPC.223'), 'Document_Name__c should start with IPC.223');

     
        System.assertNotEquals(null, customLine.ItemNumber, 'ItemNumber should not be null.');
        System.assertNotEquals(null, customLine.Color, 'Color should not be null.');
        System.assertNotEquals(null, customLine.size, 'Size should not be null.');
        System.assertNotEquals(null, customLine.type, 'Type should not be null.');
        System.assertNotEquals(null, customLine.vendor, 'Vendor should not be null.');
        System.assertNotEquals(null, customLine.patten, 'Patten should not be null.');
        System.assertNotEquals(null, customLine.style, 'Style should not be null.');
    }
      @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC223Controller iController = new IPC223Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC223Controller.CustomFormWrapper customForm = new IPC223Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
           System.Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
            
        }
    }
}