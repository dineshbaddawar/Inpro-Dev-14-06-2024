@IsTest
private class IPC1106ControllerTests {
    
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);

        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Document_Name__c = 'IPC.1106', Color__c = 'Clamshell-0154', Width__c = 100.2356, Height__c = 200, 
            Operator__c = 'Manual', Vendor__c = 'Vendor1', Pattern__c = 'Pattern1', Room_Location__c = 'Living Room', 
            Mounting_Type__c = 'Wall Mount', Fabric_Width__c = 300, Fabric_Vertical_Repeat__c = 50, 
            Sewing_Type__c = 'Type1', Fullness__c = 'Full', 
            Draw_Type__c = 'Right', Master_Carrier__c = 'Carrier1', Return__c = 10, Lining__c = 'Lining1', 
            Weights__c = 'Heavy', Rod_Part_Number__c = 'Rod123', Style__c = 'Modern',
            Height_3__c = '10', Rod_Diameter__c = '5', Pin_Setting__c = 'Center', Note__c = 'Test Note');

        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 3.00, Quantity = 2, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Document_Name__c = 'id', Color__c = 'Blue-1234', Width__c = 150.4567, Height__c = 250, 
            Operator__c = 'Automatic', Vendor__c = 'Vendor2', Pattern__c = 'Pattern2', Room_Location__c = 'Bedroom', 
            Mounting_Type__c = 'Ceiling Mount', Fabric_Width__c = 400, Fabric_Vertical_Repeat__c = 60, 
            Sewing_Type__c = 'Type2', Fullness__c = 'Partial', 
            Draw_Type__c = 'Left', Master_Carrier__c = 'Carrier2', Return__c = 20, Lining__c = 'Lining2', 
            Weights__c = 'Light', Rod_Part_Number__c = 'Rod456', Style__c = 'Contemporary',
            Height_3__c = '20', Rod_Diameter__c = '6', Pin_Setting__c = 'Left', Note__c = 'Test Note 2');

        insert new List<QuoteLineItem>{line1, line2};
    }
    
    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];
        
        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC1106Controller iController = new IPC1106Controller(sc);
         System.assertEquals(false, iController.BlankForm, 'BlankForm should be true when there are no quote lines.');
        
        List<IPC1106Controller.CustomQuoteLineItem> customLines = iController.customForm.quoteLines;
        System.assertEquals(1, customLines.size(), 'Expected to find 2 CustomQuoteLineItems.');
        
        
        IPC1106Controller.CustomQuoteLineItem customLine1 = customLines[0];
        System.assert(customLine1.DocumentName.startsWith('IPC.1106'), 'Document name must start with IPC.1106.');
        System.assertEquals('Clamshell', customLine1.colorName, 'Expected colorName to be Clamshell.');
        System.assertEquals('0154', customLine1.colorNumber, 'Expected colorNumber to be 0154.');
        System.assertEquals(1, customLine1.Quantity, 'Expected Quantity to be 1.');
        System.assertEquals(100.2356, customLine1.Width, 'Expected Width to be 100.2356.');
        System.assertEquals(200, customLine1.Height, 'Expected Height to be 200.');
        System.assertEquals('Manual', customLine1.Operator, 'Expected Operator to be Manual.');
        System.assertEquals('Vendor1', customLine1.vendor, 'Expected vendor to be Vendor1.');
        System.assertEquals('Pattern1', customLine1.Pattern, 'Expected Pattern to be Pattern1.');
        System.assertEquals('Living Room', customLine1.RoomLocation, 'Expected RoomLocation to be Living Room.');
        System.assertEquals(300, customLine1.FabricWidth, 'Expected FabricWidth to be 300.');
        System.assertEquals(50, customLine1.FabricVerticalRepeat, 'Expected FabricVerticalRepeat to be 50.');
        System.assertEquals('Type1', customLine1.SewingType, 'Expected SewingType to be Type1.');
        System.assertEquals('Full', customLine1.Fullness, 'Expected Fullness to be Full.');
        System.assertEquals('Right', customLine1.DrawType, 'Expected DrawType to be Right.');
        System.assertEquals('Carrier1', customLine1.MasterCarrier, 'Expected MasterCarrier to be Carrier1.');
        System.assertEquals(10, customLine1.returntype, 'Expected returntype to be 10.');
        System.assertEquals('Lining1', customLine1.Lining, 'Expected Lining to be Lining1.');
        System.assertEquals('Heavy', customLine1.Weights, 'Expected Weights to be Heavy.');
        System.assertEquals('Rod123', customLine1.RodPartNumber, 'Expected RodPartNumber to be Rod123.');
        System.assertEquals('Modern', customLine1.style, 'Expected style to be Modern.');
        System.assertEquals('10', customLine1.Height3, 'Expected Height3 to be 10.');
        System.assertEquals('5', customLine1.RodDiameter, 'Expected RodDiameter to be 5.');
        System.assertEquals('Center', customLine1.PinSetting, 'Expected PinSetting to be Center.');
        System.assertEquals('Test Note', customLine1.Notes, 'Expected Notes to be Test Note.');

      System.assertNotEquals(null, customLine1.DocumentName, 'DocumentName should not be null.');
        System.assertNotEquals(null, customLine1.Color, 'Color should not be null.');
        System.assertNotEquals(null, customLine1.colorName, 'colorName should not be null.');
        System.assertNotEquals(null, customLine1.colorNumber, 'colorNumber should not be null.');
        
    }
    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC1106Controller iController = new IPC1106Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
        
}