@IsTest
private class IPC166ControllerTests {

    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);

        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1.00, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Document_Name__c = 'IPC.166', Color__c = 'Clamshell-0154', Width__c = 100.256, Height__c = 200, 
            Operator__c = 'Manual', Vendor__c = 'Vendor1', Pattern__c = 'Pattern1', Room_Location__c = 'Living Room', 
            Mounting_Type__c = 'Wall Mount', Fabric_Width__c = 300, Fabric_Vertical_Repeat__c = 50, 
            Sewing_Type__c = 'Type1', Fullness__c = 'Full',
            Draw_Type__c = 'Right', Master_Carrier__c = 'Carrier1', Return__c = 10, Lining__c = 'Lining1', 
            Weights__c = 'Heavy', Rod_Part_Number__c = 'Rod123', Pin_Setting__c = 'Pin1', Rod_Style__c = 'Style1');

        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 3.00, Quantity = 2.00, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Document_Name__c = 'personal', Color__c = 'Ocean-0258', Width__c = 150.5, Height__c = 250, 
            Operator__c = 'Automatic', Vendor__c = 'Vendor2', Pattern__c = 'Pattern2', Room_Location__c = 'Bedroom', 
            Mounting_Type__c = 'Ceiling Mount', Fabric_Width__c = 350, Fabric_Vertical_Repeat__c = 60, 
            Sewing_Type__c = 'Type2', Fullness__c = 'Half', Ripple_Fold_Tape_Clear__c = 'No', 
            Draw_Type__c = 'Left', Master_Carrier__c = 'Carrier2', Return__c = 15, Lining__c = 'Lining2', 
            Weights__c = 'Light', Rod_Part_Number__c = 'Rod456', Pin_Setting__c = 'Pin2', Rod_Style__c = 'Style2');

        insert new List<QuoteLineItem>{line1, line2};
    }

    @IsTest
    static void testController() {
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];

        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC166Controller iController = new IPC166Controller(sc);

        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false when there are quote lines.');

        List<IPC166Controller.CustomQuoteLineItem> customLines = iController.customForm.quoteLines;
        System.assertEquals(1, customLines.size(), 'Expected to find 1 CustomQuoteLineItem.');
        IPC166Controller.CustomQuoteLineItem customLine1 = customLines[0];

        System.assertEquals(1.00, customLine1.Quantity, 'Quantity should be 1.00');
        System.assertEquals(100.256, customLine1.Width, 'Width should be 100.256');
        System.assertEquals(200, customLine1.Height, 'Height should be 200');
        System.assertEquals('Manual', customLine1.Operator, 'Operator should be Manual');
        System.assertEquals('IPC.166', customLine1.DocumentName, 'DocumentName should be IPC.166');
        System.assertEquals('Vendor1', customLine1.vendor, 'Vendor should be Vendor1');
        System.assertEquals('Pattern1', customLine1.Pattern, 'Pattern should be Pattern1');
        System.assertEquals('Clamshell-0154', customLine1.Color, 'Color should be Clamshell-0154');
        System.assertEquals('Clamshell', customLine1.colorName, 'colorName should be Clamshell');
        System.assertEquals('0154', customLine1.colorNumber, 'colorNumber should be 0154');
        System.assertEquals('Living Room', customLine1.RoomLocation, 'RoomLocation should be Living Room');
        System.assertEquals('Wall Mount', customLine1.MountingType, 'MountingType should be Wall Mount');
        System.assertEquals(300, customLine1.FabricWidth, 'FabricWidth should be 300');
        System.assertEquals(50, customLine1.FabricVerticalRepeat, 'FabricVerticalRepeat should be 50');
        System.assertEquals('Type1', customLine1.SewingType, 'SewingType should be Type1');
        System.assertEquals('Full', customLine1.Fullness, 'Fullness should be Full');
        System.assertEquals('Right', customLine1.DrawType, 'DrawType should be Right');
        System.assertEquals('Carrier1', customLine1.MasterCarrier, 'MasterCarrier should be Carrier1');
        System.assertEquals(10, customLine1.returnSize, 'returnSize should be 10');
        System.assertEquals('Lining1', customLine1.Lining, 'Lining should be Lining1');
        System.assertEquals('Heavy', customLine1.Weights, 'Weights should be Heavy');
        System.assertEquals('Rod123', customLine1.RodPartNumber, 'RodPartNumber should be Rod123');
        System.assertEquals('Pin1', customLine1.PinSetting, 'PinSetting should be Pin1');
        System.assertEquals('Style1', customLine1.RodStyle, 'RodStyle should be Style1');
        
        System.assertNotEquals(null, customLine1.DocumentName, 'DocumentName should not be null.');
        System.assertNotEquals(null, customLine1.vendor, 'Vendor should not be null.');
        System.assertNotEquals(null, customLine1.Pattern, 'Pattern should not be null.');
        System.assertNotEquals(null, customLine1.Color, 'Color should not be null.');
        System.assertNotEquals(null, customLine1.colorName, 'colorName should not be null.');
    }

    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC166Controller iController = new IPC166Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
}