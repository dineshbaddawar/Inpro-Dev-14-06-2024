@isTest
public class IPC275ControllerTest {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on', document_Name__c = 'IPC.275', Description_2__c='qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c ='430',Operator__c = '14',
            Item_Number__c = 'GT SS', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/4', document_Name__c = 'IPC.275', Description_2__c='qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Operator__c = '16',
            Item_Number__c = 'DW-BEND', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3', document_Name__c = 'IPC.214',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = 'D12345-BEND', Color__c = 'Clamshell-0154' );
        
        QuoteLineItem line4 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'cement on', document_Name__c = 'IPC.275',Operator__c = '18',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304', Description_2__c= 'qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui',
            Item_Number__c = 'SS', Color__c = 'Clamshell-0154' );
        
        insert new List<QuoteLineItem>{line1, line2, line3, line4};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quotes[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        
        IPC275Controller controller = new IPC275Controller();
        IPC275Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assertEquals(3, customForm.quoteLines.size(), 'Quote lines count should be 3');
        
        IPC275Controller.QuoteLineWrapper line1 = customForm.quoteLines[0];
        System.assertEquals('screw on', line1.quoteLineItem.Description);
        System.assertEquals('IPC.275', line1.quoteLineItem.Document_Name__c);
        System.assertEquals('qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui', line1.quoteLineItem.Description_2__c);
        System.assertEquals('430', line1.quoteLineItem.Alloy_Type__c);
        System.assertEquals('GT SS', line1.quoteLineItem.Item_Number__c);
        System.assertEquals('Clamshell', line1.colorName);
        System.assertEquals('0154', line1.colorNumber);
        

        IPC275Controller.QuoteLineWrapper line2 = customForm.quoteLines[1];
        System.assertEquals('4/4', line2.quoteLineItem.Description);
        System.assertEquals('IPC.275', line2.quoteLineItem.Document_Name__c);
        System.assertEquals('qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui', line2.quoteLineItem.Description_2__c);
        System.assertEquals(null, line2.quoteLineItem.Alloy_Type__c);
        System.assertEquals('DW-BEND', line2.quoteLineItem.Item_Number__c);
        System.assertEquals('Clamshell', line2.colorName);
        System.assertEquals('0154', line2.colorNumber);
        System.assertEquals(null, line2.MountingScrew);
        System.assertEquals(null, line2.MountingCementON);
        System.assertEquals(null, line2.FinishGT);
        System.assertEquals(null, line2.AlloyTypeZero);
        System.assertEquals(null, line2.AlloyTypeFour);
        
        IPC275Controller.QuoteLineWrapper line3 = customForm.quoteLines[2];
        System.assertEquals('cement on', line3.quoteLineItem.Description);
        System.assertEquals('IPC.275', line3.quoteLineItem.Document_Name__c);
        System.assertEquals('qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui qwertyui', line3.quoteLineItem.Description_2__c);
        System.assertEquals('304', line3.quoteLineItem.Alloy_Type__c);
        System.assertEquals('SS', line3.quoteLineItem.Item_Number__c);
        System.assertEquals('Clamshell', line3.colorName);
        System.assertEquals('0154', line3.colorNumber);
        System.assertEquals(null, line3.MountingScrew);
    }
    
    @IsTest
    static void testControllerWithoutQuoteId() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'True');
        
        IPC275Controller controller = new IPC275Controller();
        IPC275Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assert(controller.BlankForm, 'BlankForm should be true when quoteId is null');
    }
    
    @IsTest
    static void testControllerWithoutQuoteIdAndMetric() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        
        IPC275Controller controller = new IPC275Controller();
        IPC275Controller.CustomFormWrapper customForm = controller.customForm;
        
        System.assert(controller.BlankForm, 'BlankForm should be true when quoteId is null');
        System.assertEquals(false, controller.isMetric, 'isMetric should be false by default');
    }
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC275Controller.CustomFormWrapper customForm = new IPC275Controller().customForm;
        if (customForm != null && customForm.quoteLines != null) {
            Assert.areEqual(0, customForm.quoteLines.size(), 'Quote lines should be empty');
        }
    }
}