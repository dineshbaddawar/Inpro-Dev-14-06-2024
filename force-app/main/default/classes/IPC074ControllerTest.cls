@isTest
public class IPC074ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on', document_Name__c = 'IPC.074',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154' );
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'w/ adh', document_Name__c = 'IPC.074',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'DW-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3', document_Name__c = 'IPC.0174',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'D12345-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line4 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'w/ adh', document_Name__c = 'IPC.07777',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154' );
        insert new List<QuoteLineItem>{line1, line2, line3, line4};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC074Controller controller = new IPC074Controller();
        IPC074Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assertNotEquals(null, customForm);
        System.assertEquals(2, customForm.quoteLines.size());
        System.assertEquals(false, controller.isMetric);
        System.assertEquals('Tolerance: +.060"/-0', customForm.isMetricExperssionTolerance);
        System.assertEquals('Max. 48"', customForm.isMetricHeightHorizontal);
        System.assertEquals('Max. 120', customForm.isMetricWidthHorizontal);
        System.assertEquals('Max. 120', customForm.isMetricHeightVertical);
        System.assertEquals('Max. 120', customForm.isMetricWidthVertical);
    }
    
    @IsTest
    static void testControllerWithMetric() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1]; 
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        IPC074Controller controller = new IPC074Controller();
        IPC074Controller.CustomFormWrapper customForm = controller.customForm;

        System.assertNotEquals(null, customForm);
        System.assertEquals(true, controller.isMetric);
        System.assertEquals('Tolerance: +0.1524cm/-0', customForm.isMetricExperssionTolerance);
        System.assertEquals('Max. 121.92cm', customForm.isMetricHeightHorizontal);
        System.assertEquals('Max. 304.8cm', customForm.isMetricWidthHorizontal);
        System.assertEquals('Max. 304.8cm', customForm.isMetricHeightVertical);
        System.assertEquals('Max. 121.92cm', customForm.isMetricWidthVertical);
    }
    
    @IsTest
    static void testControllerWithoutQuoteId() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        IPC074Controller controller = new IPC074Controller();
        IPC074Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assertNotEquals(null, customForm);
        System.assertEquals(true, controller.BlankForm);
        System.assertEquals(true, controller.isMetric);
        System.assertEquals('Tolerance: +0.1524cm/-0', customForm.isMetricExperssionTolerance);
        
        System.assertEquals('Max. 121.92cm', customForm.isMetricHeightHorizontal);
        System.assertEquals('Max. 304.8cm', customForm.isMetricWidthHorizontal);
        System.assertEquals('Max. 304.8cm', customForm.isMetricHeightVertical);
        System.assertEquals('Max. 121.92cm', customForm.isMetricWidthVertical);
    }
    
    @IsTest
    static void testControllerWithoutMetric() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        IPC074Controller controller = new IPC074Controller();
        IPC074Controller.CustomFormWrapper customForm = controller.customForm;

        System.assertNotEquals(null, customForm);
        System.assertEquals(true, controller.BlankForm);
        System.assertEquals(false, controller.isMetric);        
        System.assertEquals('Tolerance: +.060"/-0', customForm.isMetricExperssionTolerance);

        System.assertEquals('Max. 48"', customForm.isMetricHeightHorizontal);
        System.assertEquals('Max. 120', customForm.isMetricWidthHorizontal);
        System.assertEquals('Max. 120', customForm.isMetricHeightVertical);
        System.assertEquals('Max. 120', customForm.isMetricWidthVertical);
    }
    
    
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC074Controller.CustomFormWrapper customForm = new IPC074Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}