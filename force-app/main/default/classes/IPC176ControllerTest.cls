@IsTest
private class IPC176ControllerTest {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,Document_Name__c ='IPC.176', Color__c = 'WaterBlue-2154',Custom_Angle__c = '115');
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,Document_Name__c ='IPC.106', Color__c = 'WaterBlue-2154',Custom_Angle__c = '115');
        insert new List<QuoteLineItem>{line,line1};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC176Controller iController = new IPC176Controller(sc);
        IPC176Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];
        System.assertEquals('WaterBlue', customLine.colorName, 'Expected colorName to be WaterBlue.');
        System.assertEquals('2154', customLine.colorNumber, 'Expected colorNumber to be 2154.');
        System.assertEquals(1, customLine.Quantity, 'Expected Quantity to be 1.');
        System.assertEquals('115', customLine.customAngle, 'Expected customAngle to be 115.');
        
      
        System.assertNotEquals(null, customLine.colorName, 'Color name should not be null.');
        System.assertNotEquals(null, customLine.colorNumber, 'Color number should not be null.');
        System.assertNotEquals(null, customLine.Quantity, 'Quantity should not be null.');
        System.assertNotEquals(null, customLine.customAngle, 'Custom angle should not be null.');
    }
    
    @IsTest
    static void testController1() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'false');
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC176Controller iController = new IPC176Controller(sc);
        IPC176Controller.CustomQuoteLineItem customLine = iController.customForm.quoteLines[0];
         System.assertEquals(false, iController.BlankForm, 'BlankForm should be true when there are no quote lines.');
        System.assertEquals('WaterBlue', customLine.colorName, 'Expected colorName to be WaterBlue.');
        System.assertEquals('2154', customLine.colorNumber, 'Expected colorNumber to be 2154.');
        System.assertEquals(1, customLine.Quantity, 'Expected Quantity to be 1.');
        System.assertEquals('115', customLine.customAngle, 'Expected customAngle to be 115.');
        
        
        System.assertNotEquals(null, customLine.colorName, 'Color name should not be null.');
        System.assertNotEquals(null, customLine.colorNumber, 'Color number should not be null.');
        System.assertNotEquals(null, customLine.Quantity, 'Quantity should not be null.');
        System.assertNotEquals(null, customLine.customAngle, 'Custom angle should not be null.');
    }
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC176Controller iController = new IPC176Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC176Controller.CustomFormWrapper customForm = new IPC176Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
           System.Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
            
        }
    }
}