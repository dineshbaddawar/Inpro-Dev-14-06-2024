/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class IPC076ControllerTests {


    @testSetup
    static void makeData() 
    {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pbe1 = CommonSetup.InsertProductAndPrice('DW-BEND8-W-4', 1.05);
        PricebookEntry pbe2 = CommonSetup.InsertProductAndPrice('B855V123', 1.15);
        PricebookEntry pbe3 = CommonSetup.InsertProductAndPrice('DW-BEND8-W-32', 1.25);

        QuoteLineItem testLineItem1 = new QuoteLineItem(
            UnitPrice = 2.15, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pbe1.Product2Id, PricebookEntryId = pbe1.Id, 
            Item_Number__c = 'DW-BEND8-W-4', Description = '.040 4\' x 8\' Sheet w/ Adh', Color__c = 'Clamshell-0154'
        );
        QuoteLineItem testLineItem2 = new QuoteLineItem(
            UnitPrice = 2.25, Quantity = 2, QuoteId = quote.Id, 
            Product2Id = pbe2.Product2Id, PricebookEntryId = pbe2.Id, 
            Item_Number__c = 'B855V123', Description = 'item2', Color__c = 'Clamshell-0154'
        );
        QuoteLineItem testLineItem3 = new QuoteLineItem(
            UnitPrice = 2.35, Quantity = 3, QuoteId = quote.Id, 
            Product2Id = pbe3.Product2Id, PricebookEntryId = pbe3.Id, 
            Item_Number__c = 'DW-BEND8-W-32', Description = '.320 4\' x 8\' Sheet w/o Adh', Color__c = 'Clamshell-0154'
        );
        insert new List<QuoteLineItem>{testLineItem1, testLineItem2, testLineItem3};
    }
    
    
    @isTest
    static void TestController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        IPC076Controller.CustomFormWrapper customForm = new IPC076Controller().customForm;

        Assert.areEqual('.040', customForm.quoteLines[0].materialThickness);
        Assert.areEqual('Clamshell', customForm.quoteLines[0].colorName);
        Assert.areEqual('0154', customForm.quoteLines[0].colorNumber);
        Assert.areEqual(2, customForm.quoteLines.size());
        for (IPC076Controller.QuoteLineWrapper quoteLine : customForm.quoteLines)
        {
            Assert.isTrue(quoteLine.quoteLineItem.Item_Number__c.startsWith('DW-BEND'));
            if (quoteLine.quoteLineItem.Item_Number__c == 'DW-BEND8-W-4')
            {
                Assert.areEqual('333', quoteLine.peelStickAdhYes);
                Assert.areEqual('fff', quoteLine.peelStickAdhNo);
            }
            if (quoteLine.quoteLineItem.Item_Number__c == 'DW-BEND8-W-32')
            {
                Assert.areEqual('fff', quoteLine.peelStickAdhYes);
                Assert.areEqual('333', quoteLine.peelStickAdhNo);
            }
        }
    }

    @isTest
    static void TestControllerBlankReport() {

        ApexPages.currentPage().getParameters().put('quoteId', '');
        IPC076Controller.CustomFormWrapper customForm = new IPC076Controller().customForm;

        Assert.areEqual(1, customForm.quoteLines.size());
        for (IPC076Controller.QuoteLineWrapper quoteLine : customForm.quoteLines)
        {
            Assert.areEqual(' ', quoteLine.quoteLineItem.Description);
            Assert.areEqual('fff', quoteLine.peelStickAdhYes);
            Assert.areEqual('fff', quoteLine.peelStickAdhNo);
        }
    }

    @isTest
    static void TestFilterSelection() {
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        QuoteLineItem y1 = new QuoteLineItem(Description = 'Included', Item_Number__c = 'DW-BEND8-W-4');
        quoteLineItems.add(y1);
        QuoteLineItem n2 = new QuoteLineItem(Description = 'No Match', Item_Number__c = 'DW-OTHER-W-4');
        quoteLineItems.add(n2);
        QuoteLineItem y3 = new QuoteLineItem(Description = 'Included', Item_Number__c = 'DW-BEND4-W-4-more stuff');
        quoteLineItems.add(y3);
        QuoteLineItem n4 = new QuoteLineItem(Description = 'No Match', Item_Number__c = 'START-DW-OTHER-W-4');
        quoteLineItems.add(n4);


        List<QuoteLineItem> filteredLineItems = IPC076Controller.FilterIPC076(quoteLineItems);
        Assert.areEqual(2, filteredLineItems.size());
        for (QuoteLineItem line : filteredLineItems )
        {
            Assert.areEqual('Included', line.Description);
        }
    }

    @isTest
    static void TestHasAdhesive() {

        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w/ Adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w/Adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w Adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('w/ Adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('w/Adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('w Adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' SHEET W/ ADH'));
        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' SHEET W/ADH'));
        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' sheet w adh'));
        Assert.isTrue(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w/ Adhesive'));

        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w/o Adh'));
        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w/oAdh'));
        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet wo Adh'));
        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet w/  Adh'));
        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet wo Adh'));
        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet with Adhesive'));
        Assert.isFalse(IPC076Controller.HasAdhesive('.040 4\' x 8\' Sheet wo Adhesive'));
    }

    @isTest
    static void TestHasNoAdhesive() {

        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w/o Adh'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w/oAdh'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('w/o Adh'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('w/oAdh'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' SHEET W/O ADH'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' SHEET W/OADH'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' sheet w/o adh'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' sheet w/oadh'));
        Assert.isTrue(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w/o Adhesive'));

        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w/ Adh'));
        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w/Adh'));
        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w Adh'));
        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet wo Adh'));
        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet w/o  Adh'));
        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet with Adhesive'));
        Assert.isFalse(IPC076Controller.HasNoAdhesive('.040 4\' x 8\' Sheet wo Adhesive'));
    }

}