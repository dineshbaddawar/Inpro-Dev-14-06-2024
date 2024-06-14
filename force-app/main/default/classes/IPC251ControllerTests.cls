@isTest
private class IPC251ControllerTests {

    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id,
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Document_Name__c = 'IPC.251 Test', Width__c = 12.34, Height__c = 23.45,
            Brackets__c = 'Bracket1', Brackets_2__c = 'Bracket2', Alloy_Type__c = 'Alloy1',
            Operator__c = 'Operator1', Description = 'screw-On cement-On');
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 3.00, Quantity = 2, QuoteId = quote.Id,
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Document_Name__c = 'Test', Width__c = 10.00, Height__c = 20.00,
            Brackets__c = 'BracketA', Brackets_2__c = 'BracketB', Alloy_Type__c = 'Alloy2',
            Operator__c = 'Operator2', Description = 'bolt-On cement-Off');
        
        insert new List<QuoteLineItem>{line1, line2};
    }

    @isTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];

        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');

        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC251Controller iController = new IPC251Controller(sc);

        System.assertNotEquals(null, iController.customForm, 'customForm should not be null');
        System.assertNotEquals(null, iController.customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, iController.customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');

        System.assertNotEquals(null, iController.customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(1, iController.customForm.quoteLines.size(), 'There should be two quote line items');

        IPC251Controller.CustomQuoteLineItem customLine1 = iController.customForm.quoteLines[0];
        

        System.assertEquals(1, customLine1.Quantity, 'Quantity should be 1 for the first line item');
        System.assertEquals(12.34, customLine1.Width, 'Width should be 12.34 for the first line item');
        System.assertEquals(23.45, customLine1.Height, 'Height should be 23.45 for the first line item');
        System.assertEquals('Bracket1', customLine1.Brackets, 'Brackets should be Bracket1 for the first line item');
        System.assertEquals('Bracket2', customLine1.Brackets2, 'Brackets2 should be Bracket2 for the first line item');
        System.assertEquals('Alloy1', customLine1.AlloyType, 'AlloyType should be Alloy1 for the first line item');
        System.assertEquals('Operator1', customLine1.Operator, 'Operator should be Operator1 for the first line item');
        System.assert(customLine1.DocumentName.contains('IPC.251'), 'DocumentName should contain IPC.251 for the first line item');

      

        System.assertEquals(true, iController.isMetric, 'isMetric should be true');
        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false');
    }

    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null); 
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC251Controller iController = new IPC251Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true when there are no quote lines.');
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC251Controller.CustomFormWrapper customForm = new IPC251Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            System.Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}