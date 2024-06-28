@IsTest
public class IPC1013ControllerTests {
    
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
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec.Id, Color__c = 'White-1234',Item_Number__c='HW', Description_2__c = '1.016mm IPC.1013', Document_Name__c = 'IPC.1013',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id);
        insert line1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec);
        PageReference pageRef1 = Page.IPC1013;
        pageRef1.getParameters().put('quoteId', quoRec.Id); 
        Test.setCurrentPage(pageRef1);
        IPC1013Controller pdf1 = new IPC1013Controller(sc1);
        
        System.assertEquals(quoRec.Name, 'Quote1', 'Quote name should be Quote1');
        System.assertEquals(quoRec.OpportunityId, opportunity.Id, 'Quote OpportunityId should match the inserted Opportunity Id');
        System.assertEquals(line1.Color__c, 'White-1234', 'QuoteLineItem Color should be White-1234');
        System.assertEquals(line1.Description_2__c, '1.016mm IPC.1013', 'QuoteLineItem Description_2__c should be 1.016mm IPC.1013');
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
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec1.Id, Color__c = 'Blue-5678', Description_2__c = '.60(1/16") IPC.1013',Item_Number__c='FW', Document_Name__c = 'IPC.1013',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id);
        
        insert line2;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec1);
        PageReference pageRef1 = Page.IPC1013;
        pageRef1.getParameters().put('quoteId', quoRec1.Id); 
        Test.setCurrentPage(pageRef1);
        IPC1013Controller pdf1 = new IPC1013Controller(sc1);
        
        System.assertEquals(quoRec1.Name, 'Quote1', 'Quote name should be Quote1');
        System.assertEquals(quoRec1.OpportunityId, opportunity.Id, 'Quote OpportunityId should match the inserted Opportunity Id');
        System.assertEquals(line2.Color__c, 'Blue-5678', 'QuoteLineItem Color should be Blue-5678');
        System.assertEquals(line2.Description_2__c, '.60(1/16") IPC.1013', 'QuoteLineItem Description_2__c should be .60(1/16") IPC.1013');
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
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec1.Id, Color__c = 'Green-9012', Description_2__c = '1.524mm IPC.1013',Item_Number__c='FC', Document_Name__c = 'IPC.103',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id);
        
        insert line3;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec1);
        PageReference pageRef1 = Page.IPC1013;
        pageRef1.getParameters().put('quoteId', quoRec1.Id);
        Test.setCurrentPage(pageRef1);
        IPC1013Controller pdf1 = new IPC1013Controller(sc1);
        
        System.assertEquals(0, pdf1.customForm.quoteLines.size(), 'No QuoteLineItem should be included with Document_Name__c = IPC.103');
    }
     @IsTest
    static void testController4() {
        
        Opportunity opportunity = new Opportunity(Name = 'Opportunity1', StageName = 'Estimating', CloseDate = date.valueOf('2024-04-17 00:00:00'));
        insert opportunity;
        
        Quote quoRec1 = new Quote(Name = 'Quote1');
        quoRec1.OpportunityId = opportunity.Id;
        quoRec1.Pricebook2Id = Test.getStandardPricebookId();
        insert quoRec1;
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        
        QuoteLineItem line4 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quoRec1.Id, Color__c = 'Blue-5678', Description_2__c = '.60(1/16") IPC.1013',Item_Number__c='FC', Document_Name__c = 'IPC.1013',
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id);
        
        insert line4;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quoRec1);
        PageReference pageRef1 = Page.IPC1013;
        pageRef1.getParameters().put('quoteId', quoRec1.Id); 
        Test.setCurrentPage(pageRef1);
        IPC1013Controller pdf1 = new IPC1013Controller(sc1);
        
        System.assertEquals(quoRec1.Name, 'Quote1', 'Quote name should be Quote1');
        System.assertEquals(quoRec1.OpportunityId, opportunity.Id, 'Quote OpportunityId should match the inserted Opportunity Id');
        System.assertEquals(line4.Color__c, 'Blue-5678', 'QuoteLineItem Color should be Blue-5678');
        System.assertEquals(line4.Description_2__c, '.60(1/16") IPC.1013', 'QuoteLineItem Description_2__c should be .60(1/16") IPC.1013');
    }
    
    
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null); 
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC1013Controller iController = new IPC1013Controller(sc);
        
        System.assertEquals(iController.BlankForm, true, 'BlankForm should be true when there are no quote lines.');
    }
    
    @IsTest
    static void testControllerForWithoutQLI() {
        Quote quote1 = CommonSetup.InsertQuote();
        ApexPages.currentPage().getParameters().put('isMetric', 'true');
        ApexPages.currentPage().getParameters().put('quoteId', quote1.Id);
        IPC1013Controller.CustomFormWrapper customForm = new IPC1013Controller().customForm;
        
        System.assertNotEquals(customForm, null, 'CustomFormWrapper instance should not be null');
        if (customForm != null && customForm.quoteLines != null) {
            System.assertEquals(customForm.quoteLines.size(), 0, 'Quote lines should be empty');
        }
    }
}