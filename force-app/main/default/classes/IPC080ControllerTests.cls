@isTest
public class IPC080ControllerTests {
    
    @isTest
    static void testControllerWithLineItems() { 
       
        Quote testQuote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
              QuoteLineItem validLineItem = new QuoteLineItem(
            UnitPrice = 2.50,
            Quantity = 1,
            QuoteId = testQuote.Id,
            Product2Id = pricebookEntry.Product2Id,
            PricebookEntryId = pricebookEntry.Id,
            Color__c = 'Clamshell-0154',
            Item_Number__c = 'DW-BEND 5456'
        );
        insert validLineItem;
        
        QuoteLineItem invalidLineItem = new QuoteLineItem(
            UnitPrice = 3.00,
            Quantity = 1,
            QuoteId = testQuote.Id,
            Product2Id = pricebookEntry.Product2Id,
            PricebookEntryId = pricebookEntry.Id,
            Color__c = 'InvalidColor',
            Item_Number__c = 'InvalidItem'
        );
        insert invalidLineItem;
        
        
        ApexPages.currentPage().getParameters().put('quoteId', testQuote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        IPC080Controller controller = new IPC080Controller(sc);
         
       
        IPC080Controller.CustomQuoteLineItem validCustomLine = controller.customForm.quoteLines[0];
        System.assertEquals('Clamshell', validCustomLine.colorName, 'Expected colorName to be Clamshell.');
        System.assertEquals('0154', validCustomLine.colorNumber, 'Expected colorNumber to be 0154.');
        System.assertEquals(1, validCustomLine.Quantity, 'Expected Quantity to be 1.');
        System.assertEquals(true, validCustomLine.ItemNumber.contains('DW-BEND'), 'Expected true.');
        System.assertEquals(false, controller.BlankForm, 'BlankForm should be false when there are quote lines.');
   
        controller.customForm.quoteLines = new List<IPC080Controller.CustomQuoteLineItem>();
        System.assertEquals(false, controller.BlankForm, 'BlankForm should be true when there are no quote lines.');
             
        System.assertNotEquals(true, controller.BlankForm, 'Expected BlankForm to be false for invalid item.');
        
        System.assertNotEquals(true, controller.BlankForm, 'Expected BlankForm to be false for invalid item.');
        System.assertNotEquals(null, validCustomLine.ItemNumber, 'ItemNumber should not be null.');
        System.assertNotEquals(null, validCustomLine.colorName, 'colorName should not be null.');
        System.assertNotEquals(null, validCustomLine.colorNumber, 'colorNumber should not be null.');
        
    }
     @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC080Controller iController = new IPC080Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
}