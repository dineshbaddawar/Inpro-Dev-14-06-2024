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
private class IPC070ControllerTests {

    @testSetup
    static void makeData() 
    {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);

        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '855', Color__c = 'Clamshell-0154');

        QuoteLineItem line2 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'A855', Color__c = 'Clamshell-0154');

        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '1255', Color__c = 'Clamshell-0154');

        QuoteLineItem line4 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'A1255', Color__c = 'Clamshell-0154');

        QuoteLineItem line5 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Item_Number__c = '1455', Color__c = 'Clamshell-0154');

        QuoteLineItem line6 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = '1655', Color__c = 'Clamshell-0154');

        QuoteLineItem line7 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = '5055', Color__c = 'Clamshell-0154');

        QuoteLineItem line8 = new QuoteLineItem( 
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id,
            Item_Number__c = 'FOO', Color__c = 'Clamshell-0154');

        insert new List<QuoteLineItem>{line1, line2, line3, line4, line5, line6, line7};
    }

    @IsTest
    static void testController() 
    {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        IPC070Controller.CustomFormWrapper customForm = new IPC070Controller().customForm;
        Assert.areEqual(7, customForm.quoteLines.size());

        String checked = '333';
        String unchecked = 'fff';
        for (IPC070Controller.QuoteLineWrapper quoteLine : customForm.quoteLines)
        {
            String num = quoteLine.quoteLineItem.Item_Number__c;
            Assert.areEqual(num == '855' ? checked : unchecked, quoteLine.check_855V);
            Assert.areEqual(num == 'A855' ? checked : unchecked, quoteLine.check_A855V);
            Assert.areEqual(num == '1255' ? checked : unchecked, quoteLine.check_1255V);
            Assert.areEqual(num == 'A1255' ? checked : unchecked, quoteLine.check_A1255V);
            Assert.areEqual(num == '1455' ? checked : unchecked, quoteLine.check_1455V);
            Assert.areEqual(num == '1655' ? checked : unchecked, quoteLine.check_1655V);
            Assert.areEqual(num == '5055' ? checked : unchecked, quoteLine.check_5055V);
        }
    }

    @isTest
    static void TestControllerBlankReport() {

        ApexPages.currentPage().getParameters().put('quoteId', '');
        IPC070Controller.CustomFormWrapper customForm = new IPC070Controller().customForm;

        Assert.areEqual(1, customForm.quoteLines.size());
        for (IPC070Controller.QuoteLineWrapper quoteLine : customForm.quoteLines)
        {
            Assert.areEqual(' ', quoteLine.quoteLineItem.Description);
            System.debug(quoteLine.check_855V);
            Assert.areEqual('fff', quoteLine.check_855V);
            Assert.areEqual('fff', quoteLine.check_A855V);
            Assert.areEqual('fff', quoteLine.check_1255V);
            Assert.areEqual('fff', quoteLine.check_A1255V);
            Assert.areEqual('fff', quoteLine.check_1455V);
            Assert.areEqual('fff', quoteLine.check_1655V);
            Assert.areEqual('fff', quoteLine.check_5055V);
        }
    }

    @isTest
    static void TestFilterSelection() {
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '855'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = 'A855'));
        quoteLineItems.add(new QuoteLineItem(Description = 'No Match', Item_Number__c = 'A 855'));
        quoteLineItems.add(new QuoteLineItem(Description = 'No Match', Item_Number__c = 'Start 855'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '855 more text'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '855VVVVVV '));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '1255'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = 'A1255'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '1455'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '1655'));
        quoteLineItems.add(new QuoteLineItem(Description = 'Included', Item_Number__c = '5055'));

        List<QuoteLineItem> filteredLineItems = IPC070Controller.FilterIPC070(quoteLineItems);
        Assert.areEqual(9, filteredLineItems.size());
        for (QuoteLineItem line : filteredLineItems )
        {
            Assert.areEqual('Included', line.Description);
        }
    }
}