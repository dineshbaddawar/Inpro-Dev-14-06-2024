@isTest
public class IPC225ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '3/4',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            document_Name__c = 'IPC.225', Color__c = 'Clamshell-0154' );
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            document_Name__c = 'IPC.225', Color__c = 'Clamshell-0154' );
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            document_Name__c = 'DW-BEND', Color__c = 'Clamshell-0154' );
        insert new List<QuoteLineItem>{line1, line2, line3};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        IPC225Controller.CustomFormWrapper customForm = new IPC225Controller().customForm;
        
        Assert.areEqual(2, customForm.quoteLines.size());
        
        for (IPC225Controller.QuoteLineWrapper quoteLine : customForm.quoteLines){
            Assert.isNotNull(quoteLine.quoteLineItem, 'QuoteLineItem should not be null');
            Assert.isTrue(quoteLine.quoteLineItem.document_Name__c.startsWith('IPC.225'), 'Document name should start with IPC.225');
            Assert.isNotNull(quoteLine.colorName, 'Color name should not be null');
            Assert.isNotNull(quoteLine.colorNumber, 'Color number should not be null');
            Assert.isTrue(quoteLine.colorNumber.length() == 4, 'Color number should be 4 digits');
            Assert.isTrue(quoteLine.colorNumber.isNumeric(), 'Color number should be numeric');
            Assert.isNotNull(quoteLine.currentDate, 'Current date should not be null');
        }
    }
    
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC225Controller.CustomFormWrapper customForm = new IPC225Controller().customForm;
        
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
    
    @IsTest
    static void testControllerForQuoteIdNull() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', null);
        IPC225Controller.CustomFormWrapper customForm = new IPC225Controller().customForm;
        
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}