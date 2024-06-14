@isTest
public class IPC092ControllerTest {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pbe1 = CommonSetup.InsertProductAndPrice('IPC.092', 1.05);
        QuoteLineItem testLineItem1 = new QuoteLineItem(
            UnitPrice = 2.15, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pbe1.Product2Id, PricebookEntryId = pbe1.Id, 
            document_Name__c = 'IPC.092', Description = '.040 4\' x 8\' Sheet w/ Adh', Color__c = 'Clamshell-0154'
        );
        QuoteLineItem testLineItem2 = new QuoteLineItem(
            UnitPrice = 2.25, Quantity = 2, QuoteId = quote.Id, 
            Product2Id = pbe1.Product2Id, PricebookEntryId = pbe1.Id, 
            document_Name__c = 'IPC.092', Description = 'item2', Color__c = 'Clamshell-0154'
        );
        QuoteLineItem testLineItem3 = new QuoteLineItem(
            UnitPrice = 2.35, Quantity = 3, QuoteId = quote.Id, 
            Product2Id = pbe1.Product2Id, PricebookEntryId = pbe1.Id, 
            document_Name__c = 'DW-BEND8-W-32', Description = '.320 4\' x 8\' Sheet w/o Adh', Color__c = 'Clamshell-0154'
        );
        insert new List<QuoteLineItem>{testLineItem1, testLineItem2, testLineItem3};
            }
    
    @isTest
    static void testConstructorWithAssertions() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC092Controller.CustomFormWrapper customForm = new IPC092Controller().customForm;
        Test.setCurrentPage(Page.IPC092); 
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        IPC092Controller controller = new IPC092Controller();
        System.assertNotEquals(controller.customForm, null, 'customForm should not be null');
        System.assertEquals(controller.checked, '333', 'Checked should be "333"');
        System.assertEquals(controller.unchecked, 'fff', 'Unchecked should be "fff"');
        System.assertEquals(controller.BlankForm, false, 'BlankForm should be false when quoteId is provided');
    }
    
    
    @isTest
    static void testConstructorWithFalseMetric() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC092Controller.CustomFormWrapper customForm = new IPC092Controller().customForm;
        Test.setCurrentPage(Page.IPC092); 
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        IPC092Controller controller = new IPC092Controller();
        System.assertNotEquals(controller.customForm, null, 'customForm should not be null');
        System.assertEquals(controller.checked, '333', 'Checked should be "333"');
        System.assertEquals(controller.unchecked, 'fff', 'Unchecked should be "fff"');
        System.assert(!controller.isMetric, 'isMetric should be false');
        System.assert(controller.isMetricExperssionisProductView.equals('Tolerance: +.060\'\'/-0'), 'isMetricExperssionisProductView should match expected value for false metric');
        System.assert(controller.isMetricExperssionisWidthHeight.equals('(Max. 48\'\')'), 'isMetricExperssionisWidthHeight should match expected value for false metric');
        System.assertEquals(controller.BlankForm, false, 'BlankForm should be false when quoteId is provided');
    }
    
}