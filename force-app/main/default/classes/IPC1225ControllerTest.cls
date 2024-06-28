@IsTest
public class IPC1225ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on', document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c ='14',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154',Brackets_2__c = '87',Custom_Angle__c = '87' );
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS',document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c ='14',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154',Brackets_2__c = '87',Custom_Angle__c = '87' );
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'Lip',document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'DW-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line4 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3',document_Name__c = 'IPC.214',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'D12345-BEND', Color__c = 'Clamshell-0154' );
        QuoteLineItem line5 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'cement on',document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line6 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS',document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c ='14',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154',Brackets_2__c = '87',Custom_Angle__c = '87' );
        
        QuoteLineItem line7 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS',document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c ='18',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154',Brackets_2__c = '93',Custom_Angle__c = '93' );
        
        QuoteLineItem line8 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS',document_Name__c = 'IPC.1225',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c ='16',
            Item_Number__c = 'GT', Color__c = 'Clamshell-0154',Brackets_2__c = '90',Custom_Angle__c = '90' );
        insert new List<QuoteLineItem>{line1, line2, line3, line4, line5, line6, line7, line8};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC1225Controller.CustomFormWrapper customForm = new IPC1225Controller().customForm;
        
        System.assertEquals(7, customForm.quoteLines.size());
        System.assertNotEquals(0, customForm.quoteLines.size());
        System.assertNotEquals(null, customForm.quoteRecord);
        System.assertEquals(false, new IPC1225Controller().isMetric);
    }
    
    @IsTest
    static void testController1() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        IPC1225Controller.CustomFormWrapper customForm = new IPC1225Controller().customForm;
        
        System.assertEquals(null, customForm.quoteRecord);
        System.assertEquals(true, new IPC1225Controller().isMetric);
        System.assertEquals(true, new IPC1225Controller().BlankForm);
    }
    
    @IsTest
    static void testController2() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        IPC1225Controller.CustomFormWrapper customForm = new IPC1225Controller().customForm;
        
        System.assertEquals(null, customForm.quoteRecord);
        System.assertEquals(false, new IPC1225Controller().isMetric);
        System.assertEquals(true, new IPC1225Controller().BlankForm);
    }
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC1225Controller.CustomFormWrapper customForm = new IPC1225Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}