@IsTest
public class IPC1225ControllerTest {
    @testSetup
    static void makeData() {
        Quote quote = CommonSetup.InsertQuote();
        PricebookEntry pricebookEntry = CommonSetup.InsertProductAndPrice('Test product', 2.25);
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{
            new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on', document_Name__c = 'IPC.1225',
                              Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14',
                              Item_Number__c = 'P-3DHB2GKU', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87', Material_Allocation_Note__c = 'Test'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'screw on', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14',
                                  Item_Number__c = 'P-3DHB35HJ', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87', Material_Allocation_Note__c = 'Test'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14',
                                  Item_Number__c = 'P-3DVMA25KKKK', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87', Material_Allocation_Note__c = 'Test 1'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'Lip', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'P-3DHMB253GK', Color__c = 'Clamshell-0154', Material_Allocation_Note__c = 'Test 2'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = '4/3', document_Name__c = 'IPC.214',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Item_Number__c = 'P-3DHTC25-BEND', Color__c = 'Clamshell-0154', Material_Allocation_Note__c = 'Test 3'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'cement on', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '304', Item_Number__c = 'P-3DICF2GI', Color__c = 'Clamshell-0154', Material_Allocation_Note__c = 'Test 6'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14', Item_Number__c = 'P-3DICP2GKI', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14', Item_Number__c = 'P-3DOCF2GKI', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14', Item_Number__c = 'P-3DOCP2GKI', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14', Item_Number__c = 'P-3DVB2IKI', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14', Item_Number__c = 'P-3DTC2GKI', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87'),
                new QuoteLineItem(UnitPrice = 2.50, Quantity = 1, QuoteId = quote.Id, Description = 'SAS', document_Name__c = 'IPC.1225',
                                  Product2Id = pricebookEntry.Product2Id, PricebookEntryId = pricebookEntry.Id, Alloy_Type__c = '430', Operator__c = '14', Item_Number__c = 'HKOCP2GKI', Color__c = 'Clamshell-0154', Brackets_2__c = '87', Custom_Angle__c = '87')
                };
                    insert quoteLineItems;
    }
    
    @IsTest
    static void testController() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC1225Controller.CustomFormWrapper customForm = new IPC1225Controller().customForm;
        System.assertNotEquals(null, customForm.quoteRecord);
        System.assertEquals(false, new IPC1225Controller().isMetric);
    }
    
    @IsTest
    static void testControlle1() {
        List<Quote> quote = [SELECT Id FROM Quote LIMIT 1];
        ApexPages.currentPage().getParameters().put('quoteId', quote[0].Id);
        ApexPages.currentPage().getParameters().put('isMetric', 'False');
        IPC1225Controller.CustomFormWrapper customForm = new IPC1225Controller().customForm;
        List<QuoteLineItem> quoteLineItems = CustomFormHelper.GetQuoteLineData(quote[0].Id);
        
        String[] partNumbers = System.Label.IPC1225PartNumber.split(';');
        String[] decorativePartNumbers = System.Label.IPC1225PartNumberDecorativeMoldingVerticalHorizontal.split(';');
        String[] verticalBoardPartNumbers = System.Label.IPC1225PartNumberVerticalBoard.split(';');
        String[] trimShoeTrimCapPartNumbers = System.Label.IPC1225PartNumberTrimShoeTrimCap.split(';');
        String[] insideCornerPartialHeightPartNumbers = System.Label.IPC1225PartNumberInsideCornerPartialHeight.split(';');
        String[] outsideCornerPartialHeightPartNumbers = System.Label.IPC1225PartNumberOutsideCornerPartialHeight.split(';');
        String[] insideCornerFullHeightPartNumbers = System.Label.IPC1225PartNumberInsideCornerFullHeight.split(';');
        String[] outsideCornerFullHeightPartNumbers = System.Label.IPC1225PartNumberOutsidCornerFullHeight.split(';');
        
        for (QuoteLineItem line : quoteLineItems) {
            Boolean found = false;
            // Check in IPC1225PartNumber
            for (String partNumber : partNumbers) {
                if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                    found = true;
                    System.assertNotEquals(line.Item_Number__c, partNumber);
                    break;
                }
            }
            
            // Check in IPC1225PartNumberDecorativeMoldingVerticalHorizontal
            if (!found) {
                for (String partNumber : decorativePartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            // Check in IPC1225PartNumberVerticalBoard
            if (!found) {
                for (String partNumber : verticalBoardPartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            // Check in IPC1225PartNumberTrimShoeTrimCap
            if (!found) {
                for (String partNumber : trimShoeTrimCapPartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            // Check in IPC1225PartNumberInsideCornerPartialHeight
            if (!found) {
                for (String partNumber : insideCornerPartialHeightPartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            // Check in IPC1225PartNumberOutsideCornerPartialHeight
            if (!found) {
                for (String partNumber : outsideCornerPartialHeightPartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            // Check in IPC1225PartNumberInsideCornerFullHeight
            if (!found) {
                for (String partNumber : insideCornerFullHeightPartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            // Check in IPC1225PartNumberOutsideCornerFullHeight
            if (!found) {
                for (String partNumber : outsideCornerFullHeightPartNumbers) {
                    if (line.Item_Number__c.startsWithIgnoreCase(partNumber)) {
                        found = true;
                        System.assertNotEquals(line.Item_Number__c, partNumber);
                        break;
                    }
                }
            }
            
            if (!found) {
                System.debug('Could Not Find Matching Item Number: ' + line.Item_Number__c);
            }
        }
        
    }
}