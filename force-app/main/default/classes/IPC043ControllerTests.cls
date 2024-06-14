@isTest
public class IPC043ControllerTests {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25); 
        QuoteLineItem line1 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = '6000V-CC', Color__c = 'Clamshell-0154');
        insert new List<QuoteLineItem>{line1};
            }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        IPC043Controller controller = new IPC043Controller();
        IPC043Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'CustomFormWrapper object should not be null');
    }
}