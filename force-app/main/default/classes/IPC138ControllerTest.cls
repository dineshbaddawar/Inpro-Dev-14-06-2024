@isTest
public class IPC138ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '3/4',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', Color__c = 'Clamshell-0154', Document_Name__c = 'IPC.138');
        
        QuoteLineItem line2 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '3/4',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'A855', Color__c = 'Clamshell-0154',Document_Name__c = 'IPC.138');
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '3/4',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '1255', Color__c = 'Clamshell-0154',Document_Name__c = 'IPC.8');
        
        insert new List<QuoteLineItem>{line1, line2, line3};
            }
    
    @IsTest
    static void testController() {
        
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'false');
        IPC138Controller controller = new IPC138Controller();
        IPC138Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertEquals(false, controller.BlankForm, 'BlankForm should be false');
        System.assertEquals(false, controller.isMetric, 'isMetric should be true');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(2, customForm.quoteLines.size(), 'quoteLines size should be 2');
    } 
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC138Controller.CustomFormWrapper customForm = new IPC138Controller().customForm;
        
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
    @IsTest
    static void testController1() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC138Controller.CustomFormWrapper customForm = new IPC138Controller().customForm;
        System.assertNotEquals(null, customForm);
    }
    
}