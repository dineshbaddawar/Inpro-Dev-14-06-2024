@isTest
public class IPC139ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            QuoteId = quote.Id,
            Description = 'Test Item 1',
            Document_Name__c = 'IPC.139 Test Document 1',
            Item_Number__c = '123',
            Quantity = 5,
            Custom_Angle__c = '45',
            Color__c = 'Red-1234', Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Description_2__c = 'tape-on description',
            UnitPrice = 2.50
        );
        
        QuoteLineItem line2 = new QuoteLineItem(
            QuoteId = quote.Id,
            Description = 'Test Item 2',
            Document_Name__c = 'IPC.139 Test Document 2',
            Item_Number__c = '456',
            Quantity = 10,
            Custom_Angle__c = '90',
            Color__c = 'Blue-5678',Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Metric_Description_2__c = 'tape-on metric description',
            UnitPrice = 2.50
        );
        QuoteLineItem line3 = new QuoteLineItem(
            QuoteId = quote.Id,
            Description = 'Test Item 2',
            Document_Name__c = 'IPC.139 Test Document 2',
            Item_Number__c = '456',
            Quantity = 10,
            Custom_Angle__c = '90',
            Color__c = 'Blue-5678',Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Description_2__c = 'no tape metric description',
            UnitPrice = 2.50
        );
        insert new List<QuoteLineItem>{line1, line2,line3};
            }
    
    @isTest
    static void testControllerWithoutParameters() {
        Test.startTest();
        PageReference pageRef = Page.IPC139; 
        Test.setCurrentPage(pageRef);
        IPC139Controller controller = new IPC139Controller();
        System.assertNotEquals(null, controller.customForm);
        System.assertEquals(true, controller.BlankForm);
        Test.stopTest();
    }
    
    @isTest
    static void testControllerWithQuoteId() {
        Test.startTest();
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        PageReference pageRef = Page.IPC139; 
        pageRef.getParameters().put('quoteId', testQuote.Id);
        Test.setCurrentPage(pageRef);
        IPC139Controller controller = new IPC139Controller();
        System.assertNotEquals(null, controller.customForm);
        
        for(IPC139Controller.QuoteLineWrapper line : controller.customForm.quoteLines) {
            if (line.quoteLineItem.Description_2__c != null && line.quoteLineItem.Description_2__c.toLowerCase().contains('tape-on')) {
                System.assertEquals('333', line.checkYesTrue);
                System.assertEquals('fff', line.checkNoTrue);
            } else if (line.quoteLineItem.Description_2__c != null && line.quoteLineItem.Description_2__c.toLowerCase().contains('no tape')) {
                System.assertEquals('fff', line.checkYesTrue);
                System.assertEquals('333', line.checkNoTrue);
            }
            if (line.quoteLineItem.Description_2__c != null && line.quoteLineItem.Description_2__c.toLowerCase().contains('tape-on')) {
                System.assertNotEquals('fff', line.checkYesTrue);
                System.assertNotEquals('333', line.checkNoTrue);
            } else if (line.quoteLineItem.Description_2__c != null && line.quoteLineItem.Description_2__c.toLowerCase().contains('no tape')) {
                System.assertNotEquals('333', line.checkYesTrue);
                System.assertNotEquals('fff', line.checkNoTrue);
            }
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testControllerWithQuoteIdAndIsMetric() {
        Test.startTest();
        Quote testQuote = [SELECT Id FROM Quote LIMIT 1];
        PageReference pageRef = Page.IPC139; 
        pageRef.getParameters().put('quoteId', testQuote.Id);
        pageRef.getParameters().put('isMetric', 'true');
        Test.setCurrentPage(pageRef);        
        IPC139Controller controller = new IPC139Controller();
        System.assertNotEquals(null, controller.customForm);
        Test.stopTest();
    }
    
}