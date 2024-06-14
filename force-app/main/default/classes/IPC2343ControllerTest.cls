@isTest
public class IPC2343ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'K41', Color__c = 'Clamshell-0154');
        
        QuoteLineItem line2 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'K42', Color__c = 'Clamshell-0154');
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '1255', Color__c = 'Clamshell-0154');
        insert new List<QuoteLineItem>{line1, line2, line3};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC2343Controller controller = new IPC2343Controller();
        IPC2343Controller.CustomFormWrapper customForm = controller.customForm;

        System.assertNotEquals(null, customForm);
        System.assertEquals('available - minimums and/or set-ups apply.', customForm.isMetricExpressionForThickness);
        System.assertEquals('.040"', customForm.isMetricExpressionFourZero);
        System.assertEquals('available - minimums and/or set-ups apply.', customForm.isMetricExpressionSixZero);
        System.assertNotEquals(null, customForm.quoteRecord);
        System.assertEquals(2, customForm.quoteLines.size()); 
        System.assertEquals('K41', customForm.quoteLines[0].quoteLineItem.Item_Number__c);
        System.assertEquals('K42', customForm.quoteLines[1].quoteLineItem.Item_Number__c);
        System.assertEquals('Clamshell', customForm.quoteLines[0].colorName);
        System.assertEquals('0154', customForm.quoteLines[0].colorNumber);
    }

    @IsTest
    static void testController1() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        IPC2343Controller controller = new IPC2343Controller();
        IPC2343Controller.CustomFormWrapper customForm = controller.customForm;

        System.assertNotEquals(null, customForm);
        System.assertEquals('2.032mm available - minimums and/or set-ups apply.', customForm.isMetricExpressionForThickness);
        System.assertEquals('1.016mm', customForm.isMetricExpressionFourZero);
        System.assertEquals('2.032mm available - minimums and/or set-ups apply.', customForm.isMetricExpressionSixZero);
        System.assertEquals(true, controller.BlankForm);
    }

    @IsTest
    static void testController2() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        IPC2343Controller controller = new IPC2343Controller();
        IPC2343Controller.CustomFormWrapper customForm = controller.customForm;

        System.assertNotEquals(null, customForm);
        System.assertEquals('available - minimums and/or set-ups apply.', customForm.isMetricExpressionForThickness);
        System.assertEquals('.040"', customForm.isMetricExpressionFourZero);
        System.assertEquals('available - minimums and/or set-ups apply.', customForm.isMetricExpressionSixZero);
        System.assertEquals(true, controller.BlankForm);
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC254Controller.CustomFormWrapper customForm = new IPC254Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}