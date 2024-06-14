@isTest
public class IPC255ControllerTests {
    
    @IsTest
    static void testControllerWithQuoteAndMetricTrue() {
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17'));
        insert opportunity;
        
        Quote quote = new Quote(Name = 'Quote1', OpportunityId = opportunity.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert quote;
        
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '9 x 8', 
             Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Color__c = 'white-0154',
            Mounting_Type__c = 'Screws', Length__c = 15.5, Document_Name__c = 'IPC.255'); 
        insert line1;
        
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('quoteId', quote.Id);
        pageRef.getParameters().put('isMetric', 'true');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC255Controller controller = new IPC255Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertEquals(controller.isMetric, true, 'isMetric should be true');
        System.assertEquals(controller.isMetricExperssion, '(cm):', 'isMetricExperssion should be (cm):');
        System.assertEquals(controller.isMetricDrywallThickness, 'e.g.(1.5875cm,1.5875cm show above)', 'isMetricDrywallThickness should be correct');
        System.assertEquals(controller.isMetricEndWallHeight1, '1.2192m', 'isMetricEndWallHeight1 should be correct');
        
        System.assertNotEquals(controller.customForm, null, 'CustomFormWrapper instance should not be null');
        System.assertNotEquals(controller.customForm.quoteRecord, null, 'CustomFormWrapper.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, quote.Id, 'Quote record Id should match the inserted quote Id');
        
        System.assertNotEquals(controller.customForm.quoteLines, null, 'CustomFormWrapper.quoteLines should not be null');
        System.assertEquals(controller.customForm.quoteLines.size(), 1, 'There should be one quote line item');
        
        IPC255Controller.CustomQuoteLineItem customLine = controller.customForm.quoteLines[0];
        System.assertEquals(customLine.Quantity, 1, 'Quantity should be 1');
        System.assertEquals(customLine.colorName, 'white', 'colorName should be white');
        System.assertEquals(customLine.colorNumber, '0154', 'colorNumber should be 0154');
        System.assertEquals(customLine.DescriptionLower, '9 x 8', 'DescriptionLower should be correct');
    }
    
    @IsTest
    static void testControllerWithQuoteAndMetricFalse() {
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17'));
        insert opportunity;
        
        Quote quote = new Quote(Name = 'Quote1', OpportunityId = opportunity.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert quote;
        
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '4', 
             Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Mounting_Type__c = 'Screws', Length__c = 15.5, Document_Name__c = 'IPC.255');
        insert line1;
        
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('quoteId', quote.Id);
        pageRef.getParameters().put('isMetric', 'false');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC255Controller controller = new IPC255Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertEquals(controller.isMetric, false, 'isMetric should be false');
        System.assertEquals(controller.isMetricExperssion, '(in.):', 'isMetricExperssion should be (in.):');
        System.assertEquals(controller.isMetricDrywallThickness, 'e.g.(5/8",5/8" show above)', 'isMetricDrywallThickness should be correct');
        System.assertEquals(controller.isMetricEndWallHeight1, '4', 'isMetricEndWallHeight1 should be correct');
        
        System.assertNotEquals(controller.customForm, null, 'CustomFormWrapper instance should not be null');
        System.assertNotEquals(controller.customForm.quoteRecord, null, 'CustomFormWrapper.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, quote.Id, 'Quote record Id should match the inserted quote Id');
        
        System.assertNotEquals(controller.customForm.quoteLines, null, 'CustomFormWrapper.quoteLines should not be null');
        System.assertEquals(controller.customForm.quoteLines.size(), 1, 'There should be one quote line item');
        
        IPC255Controller.CustomQuoteLineItem customLine = controller.customForm.quoteLines[0];
        System.assertEquals(customLine.Quantity, 1, 'Quantity should be 1');
        System.assertEquals(customLine.DescriptionLower, '4', 'DescriptionLower should be correct');
        System.assertEquals(customLine.WallHeight1, '333', 'WallHeight1 should be checked');
    }
    
    
    @IsTest
    static void testControllerWithQuoteAndMetricFalse1() {
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17'));
        insert opportunity;
        
        Quote quote = new Quote(Name = 'Quote1', OpportunityId = opportunity.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert quote;
        
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '8', 
             Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Mounting_Type__c = 'Screws', Length__c = 15.5, Document_Name__c = 'IPC.255');
        insert line3;
        
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('quoteId', quote.Id);
        pageRef.getParameters().put('isMetric', 'false');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC255Controller controller = new IPC255Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertEquals(controller.isMetric, false, 'isMetric should be false');
        System.assertEquals(controller.isMetricExperssion, '(in.):', 'isMetricExperssion should be (in.):');
        System.assertEquals(controller.isMetricDrywallThickness, 'e.g.(5/8",5/8" show above)', 'isMetricDrywallThickness should be correct');
        System.assertEquals(controller.isMetricEndWallHeight1, '4', 'isMetricEndWallHeight1 should be correct');
        
        System.assertNotEquals(controller.customForm, null, 'CustomFormWrapper instance should not be null');
        System.assertNotEquals(controller.customForm.quoteRecord, null, 'CustomFormWrapper.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, quote.Id, 'Quote record Id should match the inserted quote Id');
        
        System.assertNotEquals(controller.customForm.quoteLines, null, 'CustomFormWrapper.quoteLines should not be null');
        System.assertEquals(controller.customForm.quoteLines.size(), 1, 'There should be one quote line item');
        
        IPC255Controller.CustomQuoteLineItem customLine = controller.customForm.quoteLines[0];
        System.assertEquals(customLine.Quantity, 1, 'Quantity should be 1');
        System.assertEquals(customLine.DescriptionLower, '8', 'DescriptionLower should be correct');
        System.assertEquals(customLine.WallHeight2, '333', 'WallHeight1 should be checked');
    }
    @IsTest
    static void testControllerWithQuoteAndMetricFalse2() {
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17'));
        insert opportunity;
        
        Quote quote = new Quote(Name = 'Quote1', OpportunityId = opportunity.Id, Pricebook2Id = Test.getStandardPricebookId());
        insert quote;
        
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '10 ', 
             Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Mounting_Type__c = 'Screws', Length__c = 15.5, Document_Name__c = 'IPC.255');
        insert line3;
        
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('quoteId', quote.Id);
        pageRef.getParameters().put('isMetric', 'false');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC255Controller controller = new IPC255Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertEquals(controller.isMetric, false, 'isMetric should be false');
        System.assertEquals(controller.isMetricExperssion, '(in.):', 'isMetricExperssion should be (in.):');
        System.assertEquals(controller.isMetricDrywallThickness, 'e.g.(5/8",5/8" show above)', 'isMetricDrywallThickness should be correct');
        System.assertEquals(controller.isMetricEndWallHeight4, '10', 'isMetricEndWallHeight4 should be correct');
        
        System.assertNotEquals(controller.customForm, null, 'CustomFormWrapper instance should not be null');
        System.assertNotEquals(controller.customForm.quoteRecord, null, 'CustomFormWrapper.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, quote.Id, 'Quote record Id should match the inserted quote Id');
        
        System.assertNotEquals(controller.customForm.quoteLines, null, 'CustomFormWrapper.quoteLines should not be null');
        System.assertEquals(controller.customForm.quoteLines.size(), 1, 'There should be one quote line item');
        
        IPC255Controller.CustomQuoteLineItem customLine = controller.customForm.quoteLines[0];
        System.assertEquals(customLine.Quantity, 1, 'Quantity should be 1');
        System.assertEquals(customLine.DescriptionLower, '10', 'DescriptionLower should be correct');
        System.assertEquals(customLine.WallHeight4, '333', 'WallHeight4 should be checked');
    }
    
    @IsTest
    static void testControllerBlankForm() {
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('quoteId', null);
        pageRef.getParameters().put('isMetric', 'true');
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC255Controller controller = new IPC255Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertEquals(controller.BlankForm, true, 'BlankForm should be true when there are no quote lines');
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        PageReference pageRef = Page.IPC255;
        pageRef.getParameters().put('isMetric', 'true');
        pageRef.getParameters().put('quoteId', quote1.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote1);
        IPC255Controller controller = new IPC255Controller(sc);
        
        System.assertNotEquals(controller, null, 'Controller instance should not be null');
        System.assertNotEquals(controller.customForm, null, 'CustomFormWrapper instance should not be null');
        System.assertNotEquals(controller.customForm.quoteRecord, null, 'CustomFormWrapper.quoteRecord should not be null');
        System.assertEquals(controller.customForm.quoteRecord.Id, quote1.Id, 'Quote record Id should match the inserted quote Id');
        
        System.assertNotEquals(controller.customForm.quoteLines, null, 'CustomFormWrapper.quoteLines should not be null');
        System.assertEquals(controller.customForm.quoteLines.size(), 0, 'Quote lines should be empty');
    }
}