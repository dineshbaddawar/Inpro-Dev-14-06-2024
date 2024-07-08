@isTest
public class IPC782ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on',document_Name__c = 't-IPC.777',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,Width__c=2.22,Length__c=1.23, 
            Item_Number__c = 'DSWSPWL', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4',document_Name__c = 'IPC.777',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Width__c=22.22,Length__c=12.23,
            Item_Number__c = 'DSWSPWO-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3',document_Name__c = 'IPC.214',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'D12345-BEND');
        
        insert new List<QuoteLineItem>{line1, line2,line3};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC782Controller controller = new IPC782Controller();
        IPC782Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertNotEquals(null, customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(2, customForm.quoteLines.size(), 'quoteLines size should be 2');
        
        for (IPC782Controller.QuoteLineWrapper qlw : customForm.quoteLines) {
            if (qlw.quoteLineItem.Item_Number__c.startsWithIgnoreCase('DSWSPWL')) {
                System.assertEquals('Clamshell-0154', qlw.colorName, 'Color should match for line 1');
                System.assertEquals(1, qlw.QuantityValue, 'Quantity should match for line 1');
                System.assertEquals(2.22, qlw.WidthValue, 'Width should match for line 1');
                System.assertEquals(1.23, qlw.LengthValue, 'Length should match for line 1');
            } else if (qlw.quoteLineItem.Item_Number__c.startsWithIgnoreCase('DSWSPWO')) {
                System.assertEquals('Clamshell-0154', qlw.colorName, 'Color should match for line 2');
                System.assertEquals(1, qlw.QuantityValue, 'Quantity should match for line 2');
                System.assertEquals(22.22, qlw.WidthValue, 'Width should match for line 2');
                System.assertEquals(12.23, qlw.LengthValue, 'Length should match for line 2');
            }
        }
    }
    
    @IsTest
    static void testControllerWithNullQuoteId() {
        
        ApexPages.currentPage().getParameters().put('quoteId', null);
        IPC782Controller controller = new IPC782Controller();
        IPC782Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');        
        System.assertEquals(null, customForm.quoteLines, 'quoteLines should be null when quoteId is null');
    }

    
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC782Controller.CustomFormWrapper customForm = new IPC782Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}