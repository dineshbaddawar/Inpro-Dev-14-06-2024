@isTest
public class IPC614ControllerTests {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', description = 'product Mubet');
        
        QuoteLineItem line2 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'PWP-PNLVL', description = 'hor grain-0154');
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'PWP-PNLVL', description = 'Clamshell-0154');  
        
        insert new List<QuoteLineItem>{line1, line2, line3};
            }
    
    @IsTest
    static void testController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote[0]);
        IPC614Controller iController = new IPC614Controller(sc);
        
        System.assertNotEquals(null, iController.customForm, 'customForm should not be null');
        System.assertNotEquals(null, iController.customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote[0].Id, iController.customForm.quoteRecord.Id, 'quoteRecord ID should match the test quote ID');
        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false');
        
        List<QuoteLineItem> expectedQuoteLines = [SELECT Id, Description FROM QuoteLineItem WHERE QuoteId = :quote[0].Id AND Item_Number__c LIKE 'PWP-PNLVL%'];
        System.assertEquals(expectedQuoteLines.size(), iController.customForm.quoteLines.size(), 'Number of filtered QuoteLineItems should match');
        
        for (QuoteLineItem qli : iController.customForm.quoteLines) {
            if (qli.Description != null) {
                String lowerDesc = qli.Description.toLowerCase();
                if (lowerDesc.contains('vert grain')) {
                    System.assertEquals('Vertical', qli.Description, 'Description should be Vertical');
                } else if (lowerDesc.contains('hor grain')) {
                    System.assertEquals('Horizontal', qli.Description, 'Description should be Horizontal');
                } 
            }
        }
    }
    
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC614Controller iController = new IPC614Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
    
}