@isTest
public class IPC257ControllerTests {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '3/4 description', document_Name__c = 'IPC.257',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c = '18',Custom_Angle__c = '110',
            Brackets__c = 'wing1', Brackets_2__c = 'wing2', Height__c = 10.5);
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, document_Name__c = 'IPC.257',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Operator__c = '16',
           Description = '1/8" description',Alloy_Type__c ='304');
        
        insert new List<QuoteLineItem>{line1, line2};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quotes[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        
        IPC257Controller controller = new IPC257Controller(new ApexPages.StandardController(new Quote()));
        IPC257Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assertNotEquals(null, customForm, 'CustomFormWrapper should not be null');
        System.assertEquals(2, customForm.quoteLines.size(), 'Quote lines count should be 2');
        
        IPC257Controller.CustomQuoteLineItem line1 = customForm.quoteLines[0];
        System.assertEquals(1, line1.Quantity);
        System.assertEquals('wing1', line1.Wing1);
        System.assertEquals('wing2', line1.Wing2);
        System.assertEquals(10.5, line1.Height);
        System.assertEquals('110', line1.AngleID);
       
        
        IPC257Controller.CustomQuoteLineItem line2 = customForm.quoteLines[1];
        System.assertEquals(null, line2.Wing1);
        System.assertEquals(null, line2.Wing2);
        System.assertEquals(null, line2.Height);
    }
    
    @IsTest
    static void testControllerWithoutQuoteId() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        
        IPC257Controller controller = new IPC257Controller(new ApexPages.StandardController(new Quote()));
        IPC257Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assert(controller.BlankForm, 'BlankForm should be true when quoteId is null');
    }
    
    @IsTest
    static void testControllerWithoutQuoteIdAndMetric() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        
        IPC257Controller controller = new IPC257Controller(new ApexPages.StandardController(new Quote()));
        IPC257Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assert(controller.BlankForm, 'BlankForm should be true when quoteId is null');
        System.assertEquals(false, controller.isMetric, 'isMetric should be false by default');
    }
    
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC257Controller.CustomFormWrapper customForm = new IPC257Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}