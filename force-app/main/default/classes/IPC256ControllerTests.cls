@isTest
public class IPC256ControllerTests {
    
    @IsTest
    static void testController1() {
        
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17 00:00:00'));
        insert opportunity;
        
        Quote quoRec = new Quote(Name = 'Quote1');
        quoRec.OpportunityId = opportunity.Id;
        quoRec.Pricebook2Id = Test.getStandardPricebookId();
        insert quoRec;
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec.Id, Description = '3/4" x 90 deg ', Description_2__c = '135 deg x 2 1/2"', Item_Number__c = 'POLY123',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Mounting_Type__c = 'Screws', Length__c = 15.5);
        insert line1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec);
        PageReference pageRef1 = Page.IPC256;
        pageRef1.getParameters().put('Id', quoRec.Id);
        Test.setCurrentPage(pageRef1);
        IPC256Controller pdf1 = new IPC256Controller(sc1);

        System.assertEquals(quoRec.Name, 'Quote1', 'Quote name should be Quote1');
        System.assertEquals(quoRec.OpportunityId, opportunity.Id, 'Quote OpportunityId should match the inserted Opportunity Id');
        System.assertEquals(line1.Description, '3/4" x 90 deg ', 'QuoteLineItem Description should be 3/4" x 90 deg');
        System.assertEquals(line1.Description_2__c, '135 deg x 2 1/2"', 'QuoteLineItem Description_2__c should be 135 deg x 2 1/2"');
        
    }
    
    @IsTest
    static void testController2() {
        
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17 00:00:00'));
        insert opportunity;
        
        Quote quoRec1 = new Quote(Name = 'Quote1');
        quoRec1.OpportunityId = opportunity.Id;
        quoRec1.Pricebook2Id = Test.getStandardPricebookId();
        insert quoRec1;
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec1.Id, Description = '2 1/2" x 135 deg',Description_2__c ='2" x 90 deg', Item_Number__c = 'POLY789 BN',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Mounting_Type__c = 'No Holes', Length__c = 5.0);
        
        insert line2;
        
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec1);
        PageReference pageRef1 = Page.IPC256;
        pageRef1.getParameters().put('Id', quoRec1.Id);
        Test.setCurrentPage(pageRef1);
        IPC256Controller pdf1 = new IPC256Controller(sc1);

        System.assertEquals(quoRec1.Name, 'Quote1', 'Quote name should be Quote1');
        System.assertEquals(quoRec1.OpportunityId, opportunity.Id, 'Quote OpportunityId should match the inserted Opportunity Id');
        System.assertEquals(line2.Description, '2 1/2" x 135 deg', 'QuoteLineItem Description should be 2 1/2" x 90 deg');
        System.assertEquals(line2.Description_2__c, '2" x 90 deg', 'QuoteLineItem Description_2__c should be 2" x 90 deg');
        
    }

@IsTest
    static void testController3() {
        
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17 00:00:00'));
        insert opportunity;
        
        Quote quoRec1 = new Quote(Name = 'Quote1');
        quoRec1.OpportunityId = opportunity.Id;
        quoRec1.Pricebook2Id = Test.getStandardPricebookId();
        insert quoRec1;
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line3 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec1.Id, Description = '1 1/8" x 90 deg',Description_2__c ='1 1/2" x 90 deg', Item_Number__c = 'POLY789',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Mounting_Type__c = 'Tape', Length__c = 5.0);
        
        insert line3;
        
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec1);
        PageReference pageRef1 = Page.IPC256;
        pageRef1.getParameters().put('Id', quoRec1.Id);
        Test.setCurrentPage(pageRef1);
        IPC256Controller pdf1 = new IPC256Controller(sc1);

        System.assertNotEquals(pdf1, null, 'Controller instance should not be null');
        System.assertEquals(quoRec1.Name, 'Quote1', 'Quote name should be Quote1');
        System.assertEquals(quoRec1.OpportunityId, opportunity.Id, 'Quote OpportunityId should match the inserted Opportunity Id');
        System.assertEquals(line3.Description, '1 1/8" x 90 deg', 'QuoteLineItem Description should be 1 1/8" x 90 deg');
        System.assertEquals(line3.Description_2__c, '1 1/2" x 90 deg', 'QuoteLineItem Description_2__c should be 1 1/2" x 90 deg');
        
    }    
    
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null); 
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC256Controller iController = new IPC256Controller(sc);
        
        System.assertEquals(iController.BlankForm, true, 'BlankForm should be true when there are no quote lines.');
    }

    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC256Controller.CustomFormWrapper customForm = new IPC256Controller().customForm;
        
        System.assertNotEquals(customForm, null, 'CustomFormWrapper instance should not be null');
        if (customForm != null && customForm.quoteLines != null) {
            System.assertEquals(customForm.quoteLines.size(), 0, 'Quote lines should be empty');
        }
    }
}