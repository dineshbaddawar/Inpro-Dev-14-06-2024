@IsTest
private class IPC1871ControllerTests { 

    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);

        QuoteLineItem line1 = new QuoteLineItem(
            UnitPrice = 2.50, Quantity = 1.00, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Document_Name__c = 'IPC.1871', Color__c = 'Clamshell-0154', Width__c = 100.256, Height__c = 200, 
            Vendor__c = 'Vendor1', Pattern__c = 'Pattern1', Room_Location__c = 'Living Room', 
            Mounting_Type__c = 'Wall Mount', Fabric_Width__c = 300, Fabric_Vertical_Repeat__c = 50, 
            Sewing_Type__c = 'Type1', Fullness__c = 'Full', Rod_Style__c = 'Style1', Draw_Type__c = 'Right', 
            Lining__c = 'Lining1', Weights__c = 'Heavy', rod_Diameter__c = '2.0', Grommet_Color__c = 'Black', 
            Note__c = 'Note1'
        );

        QuoteLineItem line2 = new QuoteLineItem(
            UnitPrice = 3.00, Quantity = 2.00, QuoteId = quote.Id, 
            Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, 
            Document_Name__c = 'personal', Color__c = 'Ocean-0258', Width__c = 150.5, Height__c = 250, 
            Vendor__c = 'Vendor2', Pattern__c = 'Pattern2', Room_Location__c = 'Bedroom', 
            Mounting_Type__c = 'Ceiling Mount', Fabric_Width__c = 350, Fabric_Vertical_Repeat__c = 60, 
            Sewing_Type__c = 'Type2', Fullness__c = 'Half', Rod_Style__c = 'Style2', Draw_Type__c = 'Left', 
            Lining__c = 'Lining2', Weights__c = 'Light', rod_Diameter__c = '1.5', Grommet_Color__c = 'White', 
            Note__c = 'Note2'
        );

        insert new List<QuoteLineItem>{line1, line2};
    }

    @IsTest
    static void testController() {
       
        List<Quote> quotes = [SELECT Id FROM Quote LIMIT 1];
        System.assertEquals(1, quotes.size(), 'Expected to find one Quote in the database.');
        Quote quote = quotes[0];

        ApexPages.currentPage().getParameters().put('quoteId', quote.Id);

       
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        IPC1871Controller iController = new IPC1871Controller(sc);

        System.assertEquals(false, iController.BlankForm, 'BlankForm should be false when there are quote lines.');

        List<IPC1871Controller.CustomQuoteLineItem> customLines = iController.customForm.quoteLines;
        System.assertEquals(1, customLines.size(), 'Expected to find 1 CustomQuoteLineItem.');
        IPC1871Controller.CustomQuoteLineItem customLine1 = customLines[0];

        System.assertEquals(1.00, customLine1.Quantity, 'Quantity should be 1.00');
        System.assertEquals(100.256, customLine1.Width, 'Width should be 100.256');
        System.assertEquals(200, customLine1.Height, 'Height should be 200');
        System.assertEquals('IPC.1871', customLine1.DocumentName, 'DocumentName should be IPC.1871');
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
        System.assertEquals('Style1', customLine1.RodStyle, 'RodStyle should be Style1');
        System.assertEquals('Right', customLine1.DrawType, 'DrawType should be Right');
        System.assertEquals('Lining1', customLine1.Lining, 'Lining should be Lining1');
        System.assertEquals('Heavy', customLine1.Weights, 'Weights should be Heavy');
        System.assertEquals('2.0', customLine1.RodDiameter, 'RodDiameter should be 2.0');
        System.assertEquals('Black', customLine1.GromentColor, 'GromentColor should be Black');
        System.assertEquals('Note1', customLine1.Note, 'Note should be Note1');
    }

    @IsTest
    static void testControllerBlankForm() {
        ApexPages.currentPage().getParameters().put('quoteId', null);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Quote());
        IPC1871Controller iController = new IPC1871Controller(sc);
        System.assertEquals(true, iController.BlankForm, 'BlankForm should be true');
    }
}