@isTest
public class IPC1001ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id,
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = '350', Width__c = 12.34, Height__c = 23.45,
            Brackets__c = 'Bracket1', Brackets_2__c = 'Bracket2', Alloy_Type__c = 'Alloy1',
            Operator__c = 'Operator1', Description = 'screw-On cement-On');
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 3.00, Quantity = 2, QuoteId = quote.Id,
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = '49787', Width__c = 10.00, Height__c = 20.00,
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
        IPC1001Controller iController = new IPC1001Controller(sc);
        
        System.assertNotEquals(null, iController.customForm, 'customForm should not be null');
        System.assertNotEquals(null, iController.customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, iController.customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        
        System.assertNotEquals(null, iController.customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(1, iController.customForm.quoteLines.size(), 'There should be two quote line items');
        
        System.assertEquals(true, iController.isMetric, 'isMetric should be true');
        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false');
    }
}