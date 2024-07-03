@isTest
public class IPC1646ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        QuoteLineItem line1 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '304 16 18 Wall 20 ga Panel', Description = 'Wall Panel', Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'SSWPGT', Color__c = 'Clamshell-0154');
        QuoteLineItem line2 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '304 18 20 ga Corner', Description = 'Corner', Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'DW-SSWP1PDW-BEND', Color__c = 'Clamshell-0154');
        QuoteLineItem line3 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '18 16 Wall Panel', Description = 'Wall Panel', Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'DSF3PD12345-BEND', Color__c = 'Clamshell-0154');
        QuoteLineItem line4 = new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description_2__c = '16 Corner', Description = 'Corner', Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'SSWPGT', Color__c = 'Clamshell-0154');
        insert new List<QuoteLineItem>{line1, line2, line3, line4};
            }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'false');
        IPC1646Controller controller = new IPC1646Controller();
        IPC1646Controller.CustomFormWrapper customForm = controller.customForm;
        System.assertNotEquals(null, customForm, 'customForm should not be null');
        System.assertNotEquals(null, customForm.quoteRecord, 'quoteRecord should not be null');
        System.assertEquals(quote.Id, customForm.quoteRecord.Id, 'quoteRecord.Id should match the inserted quote Id');
        System.assertNotEquals(null, customForm.quoteLines, 'quoteLines should not be null');
        System.assertEquals(3, customForm.quoteLines.size(), 'quoteLines size should be 4');
        System.assertEquals(false, controller.isMetric, 'isMetric should be false');
        System.assertEquals(false, controller.BlankForm, 'BlankForm should be false');
        for (IPC1646Controller.QuoteLineWrapper lineWrapper : customForm.quoteLines) {
            if (lineWrapper.quoteLineItem.Description_2__c.containsIgnoreCase('304') && lineWrapper.quoteLineItem.Description.containsIgnoreCase('Wall Panel')) {
                System.assertEquals(controller.checked, lineWrapper.AlloyThreeZeroFourForWall, 'AlloyThreeZeroFourForWall should be checked');
                System.assertEquals(controller.unchecked, lineWrapper.AlloyThreeZeroFourForCorner, 'AlloyThreeZeroFourForCorner should be unchecked');
            }
            if (lineWrapper.quoteLineItem.Description_2__c.containsIgnoreCase('304') && lineWrapper.quoteLineItem.Description.containsIgnoreCase('Corner')) {
                System.assertEquals(controller.unchecked, lineWrapper.AlloyThreeZeroFourForWall, 'AlloyThreeZeroFourForWall should be unchecked');
                System.assertEquals(controller.checked, lineWrapper.AlloyThreeZeroFourForCorner, 'AlloyThreeZeroFourForCorner should be checked');
            }
            if (lineWrapper.quoteLineItem.Description_2__c.containsIgnoreCase('18') && lineWrapper.quoteLineItem.Description.containsIgnoreCase('Wall Panel')) {
                System.assertEquals(controller.checked, lineWrapper.Eighteen_Standard_Wall, 'Eighteen_Standard_Wall should be checked');
                System.assertEquals(controller.unchecked, lineWrapper.Sixteen_Standard_Corner, 'Sixteen_Standard_Corner should be unchecked');
            }
            if (lineWrapper.quoteLineItem.Description_2__c.containsIgnoreCase('16') && lineWrapper.quoteLineItem.Description.containsIgnoreCase('Corner')) {
                System.assertEquals(controller.unchecked, lineWrapper.Eighteen_Standard_Wall, 'Eighteen_Standard_Wall should be unchecked');
                System.assertEquals(controller.checked, lineWrapper.Sixteen_Standard_Corner, 'Sixteen_Standard_Corner should be checked');
            }
        }
    }
    
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', null);
        IPC1646Controller controller = new IPC1646Controller();
        System.assertEquals(true, controller.BlankForm, 'BlankForm should be true');
    }
    
    @IsTest
    static void testControllerIsMetricTrue() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC1646Controller controller = new IPC1646Controller();
        System.assertEquals(true, controller.isMetric, 'isMetric should be true');
    }
    
    @IsTest
    static void testControllerNoQuoteId() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        IPC1646Controller controller = new IPC1646Controller();
        System.assertEquals(true, controller.BlankForm, 'BlankForm should be true');
    }
}