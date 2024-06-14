public with sharing class QuoteComparisonHelper {

    private static List<ComparedAlternate> parseWrapper(string altsStr)
    {
        List<ComparedAlternate> alts = new List<ComparedAlternate>();

        JSONParser parser = JSON.createParser(altsStr);
        while (parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.START_ARRAY)
            {
                while (parser.nextToken() != null){
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT){
                        ComparedAlternate alt = (ComparedAlternate)parser.readValueAs(ComparedAlternate.class);
                        
                        alts.add(alt);
                        parser.skipChildren();
                    }
                }
            }
        }
        //(List<ComparedAlternate>)JSON.deserialize(altsStr, List<ComparedAlternate>.class);
        return alts;
    }


    @AuraEnabled
    public static string createAddDeductPreview(string quote1Id, string quote2Id, string description, string quoteType, string revision, 
        string matchedAlts, string noMatchOneAlts, string noMatchTwoAlts, string manualMatchAlts){
        try{
            List<ComparedAlternate> alts = parseWrapper(matchedAlts);
            List<ComparedAlternate> oneAlts = parseWrapper(noMatchOneAlts); 
            List<ComparedAlternate> twoAlts = parseWrapper(noMatchTwoAlts);
            List<ComparedAlternate> manualAlts = parseWrapper(manualMatchAlts);
    
            Map<String,ComparedAlternate> totalMap = new Map<String,ComparedAlternate>();
            for(ComparedAlternate alt : alts)
            {
                totalMap.put(alt.key,alt);
            }
            for(ComparedAlternate alt : oneAlts)
            {
                totalMap.put(alt.key,alt);
            }
            for(ComparedAlternate alt : twoAlts)
            {
                totalMap.put(alt.key,alt);
            }
            for(ComparedAlternate alt : manualAlts)
            {
                totalMap.put(alt.key,alt);
            }
            System.debug('Test');
            
            List<ExpConfiguration> configs = new List<ExpConfiguration>();
            for(String key : totalMap.keySet())
            {
                ComparedAlternate alt = totalMap.get(key);
    
                ExpConfiguration addConfig = new ExpConfiguration();
                addConfig.RemovedOptions = new List<ExpOption>();
                addConfig.Options = new List<ExpOption>();
                addConfig.Name = 'ADD - ' + alt.key;
                addConfig.MadeChanges = true;
                addConfig.ID = -1;
                
                ExpConfiguration deductConfig = new ExpConfiguration();
                deductConfig.RemovedOptions = new List<ExpOption>();
                deductConfig.Options = new List<ExpOption>();
                deductConfig.Name = 'DEDUCT - ' + alt.key;
                deductConfig.MadeChanges = true;
                deductConfig.ID = -1;
    
                for(ComparedRow row : alt.value)
                {
                    Integer pickSequence = 0;
                    Boolean isDeduct = false;
                    if (row.changes)
                    {
                        ExpOption option = new ExpOption();
                        QuoteLineItem first = row.first.item;
                        QuoteLineItem second = row.second.item;
                        QuoteLineItem item;
                        if (first == null && second != null)
                        {
                            item = second;
                            option.Qty = item.Quantity;
                            isDeduct = true;
                        }
                        else if (first != null && second == null)
                        {
                            item = first;
                            item.UnitPrice = - item.UnitPrice;
                            option.Qty = item.Quantity;
                        }
                        else if (first != null && second != null)
                        {
                            if (second.Quantity == 0)
                            {
                                item = first;
                            }
                            else
                            {
                                item = second;
                            }

                            option.Qty = Math.abs(second.Quantity - first.Quantity);
                            
                            if (second.Quantity - first.Quantity < 0)
                            {
                                item.UnitPrice = - item.UnitPrice;
                                isDeduct = true;
                            }
                            System.debug(item);
                        }
    
                        option.ItemNumber = item.Item_Number__c;
                        option.ColorCode = item.Color__c;
                        
                        option.Description = item.Description == null ? '' : item.Description;
                        option.Description2 = item.Description_2__c == null ? '' : item.Description_2__c;
                        option.Note = item.Note__c == null ? '' : item.Note__c;
                        option.rId = '00000000-0000-0000-0000-000000000000';
                        //option.ID = -1;
                        option.PickSequence = pickSequence++;
                        option.Discount = 0.0;
                        option.DiscountType = '';
                        option.Height = item.Height__c == null ? 0 : item.Height__c;
                        option.AlloyType = item.Alloy_Type__c == null ? '' : item.Alloy_Type__c;
                        option.Radius = item.Radius__c == null ? '' : item.Radius__c;
                        option.UnitWeight = item.Unit_Weight__c == null ? 0 : item.Unit_Weight__c;
                        option.BasePrice = item.Base_Price__c == null ? 0 : item.Base_Price__c;
                        option.Price = item.UnitPrice == null ? 0 :item.UnitPrice;
                        option.Width = item.Width__c == null ? 0 : item.Width__c;
                        option.Length = item.Length__c == null ? 0 : item.Length__c;

                        //Decimal values aren't being saved - should not map these over until SalesforceData has this mapped properly!
                        option.Brackets = item.Brackets__c == null ? 0 : Integer.valueOf(Math.floor(Decimal.valueOf(item.Brackets__c)));
                        option.Brackets2 = item.Brackets_2__c == null ? 0 :  Integer.valueOf(Math.floor(Decimal.valueOf(item.Brackets_2__c)));
                        
                        if (second.Quantity > first.Quantity)
                        {
                            addConfig.Options.add(option);
                        }
                        else if (first.Quantity > second.Quantity)
                        {
                            deductConfig.Options.add(option);
                        }
                    }
                }
    
                if (addConfig.Options.size() > 0)
                {
                    configs.add(addConfig);
                }
                if (deductConfig.Options.size() > 0)
                {
                    configs.add(deductConfig);
                }
            }
    
            return JSON.serialize(configs);
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw ex;
        }
    }

    @AuraEnabled
    public static string createAddDeductQuote(string quote1Id, string quote2Id, string accountId, string description, string quoteType, string revision, 
        string addConfigsJson, string deductConfigsJson)
    {
        List<ExpConfiguration> addConfigs = (List<ExpConfiguration>)JSON.deserialize(addConfigsJson, List<ExpConfiguration>.class);
        List<ExpConfiguration> deductConfigs = (List<ExpConfiguration>)JSON.deserialize(deductConfigsJson, List<ExpConfiguration>.class);
        List<ExpConfiguration> configs = new List<ExpConfiguration>();
        configs.addAll(addConfigs);
        configs.addAll(deductConfigs);

        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        sfdata.Result result = service.CreateComparisonQuote(quote1Id, quote2Id, accountId, UserInfo.getUserId(), description, quoteType, revision, 'dsj8U73_3nv3Dhba');

        String json = JSON.serialize(configs);

        String results2 = service.SaveComparisonConfiguration(result.RecordID, json, 'dsj8U73_3nv3Dhba');

        CreateReferenceFile(result.RecordID, addConfigsJson, deductConfigsJson);

        return result.RecordID; 
    }

    @AuraEnabled
    public static void CreateReferenceFile(string quoteId, string addJson, string deductJson)
    {
        Blob txtBlob = Blob.valueOf(addJson +'\n'+deductJson); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name = quoteId + '_resultsJson.txt';  
        attach.Body = txtBlob;
        attach.ContentType= 'text/plain'; //Signal what the file's MIME type is
        attach.ParentID = quoteId;
        insert attach;
    }

    @AuraEnabled
    public static string CreateExportReferenceFile(string recordId, string exportOptions, string exportColumns, 
        string quoteOneName, string quoteTwoName, string comparedJson)
    {
        //Compare
        string url = URL.getSalesforceBaseUrl().toExternalForm().replace('https://','');
        Blob txtBlob = Blob.valueOf(exportOptions + '\n' + exportColumns + '\n' + 
            quoteOneName + '\n' + quoteTwoName + '\n' + url + '\n' + comparedJson); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name = recordId + '_exportJson.txt';  
        attach.Body = txtBlob;
        attach.ContentType= 'text/plain'; //Signal what the file's MIME type is
        attach.ParentID = recordId;
        insert attach;

        //GetQuoteComparisonExport
        return attach.Id;
    }

    @AuraEnabled
    public static string GetExcelFile(string recordId, string attachmentId)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.DownloadStatus response = service.GetQuoteComparisonExport(recordId, attachmentId, 'dsj8U73_3nv3Dhba');

        return response.Message;
    }

    private static List<ExpConfiguration> GetQuoteProducts(string recordId)
    {
        integer page = 0;
        Boolean loadMore = true;        
        List<ExpConfiguration> qProductList = new List<ExpConfiguration>();
        while (loadMore) 
        {
            loadMore = false;
            sfdata.ArrayOfExpConfiguration results = getConfigs(recordId, page); 
            page++;   
            List<ExpConfiguration> qProducts = getProducts(results);
            if(results != null && results.ExpConfiguration != null)
            {
                sfdata.ExpConfiguration config = results.ExpConfiguration[0];
                if(config.MoreRecords)
                {
                    loadMore = true;
                }
            }
            for (ExpConfiguration qp : qProducts) 
            {
                qProductList.add(qp);
            } 
        } 

        return qProductList;
    }

    private static List<AlternateWrapper> GetMockQuoteProducts(string recordId)
    {
        integer page = 0;
        Boolean loadMore = true;        
        List<AlternateWrapper> qProductList = new List<AlternateWrapper>();
        while (loadMore) 
        {
            loadMore = false;
            sfdata.ArrayOfExpConfiguration results = getConfigs(recordId, page); 
            page++;   
            List<AlternateWrapper> qProducts = getMockProducts(results);
            if(results != null && results.ExpConfiguration != null)
            {
                sfdata.ExpConfiguration config = results.ExpConfiguration[0];
                if(config.MoreRecords)
                {
                    loadMore = true;
                }
            }
            for (AlternateWrapper qp : qProducts) 
            {
                qProductList.add(qp);
            } 
        } 

        return qProductList;
    }

    public class AlternateWrapper
    {
        public Alternate__c Alternate { get; set; }
        public List<QuoteLineItem> QuoteLineItems { get; set; }
    }

    private static sfdata.ArrayOfExpConfiguration getConfigs(string recordId, integer page)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        sfdata.ArrayOfExpConfiguration results = service.LoadConfiguration(recordId, page, 'dsj8U73_3nv3Dhba');
        return results;
    }

    private static List<ExpConfiguration> getProducts(sfdata.ArrayOfExpConfiguration results) {
        List<ExpConfiguration> qProductList = new List<ExpConfiguration>();
        if(results != null && results.ExpConfiguration != null)
        {
            for (sfdata.ExpConfiguration config: results.ExpConfiguration) 
            {           
                ExpConfiguration x = new ExpConfiguration();
                x.Options = new List<ExpOption>();
                x.Name = config.Name;
                if(config.Options != null && config.Options.ExpOption != null)
                {
                    for (sfdata.ExpOption option: config.Options.ExpOption) 
                    {
                        ExpOption product = new ExpOption();

                        product.Id = option.rId;
                        product.rId = option.rId;
                        product.Name = option.ItemNumber;
                        product.ItemNumber = option.ItemNumber;
                        product.ColorCode = option.ColorCode;
                        product.Quantity = option.Qty;
                        product.Description = option.Description;
                        product.Description2 = option.Description2;
                        product.Note = option.Note;
                        product.Price = option.Price;
                        product.Qty = option.Qty;

                        product.AlternateId = config.ID;
                        product.rAlternateId = config.ID;
                        product.AlternateName = config.Name;                
                        product.PickSequence = option.PickSequence;                    
                        product.ColorPalette = option.acColorPallette;
                        product.bpColorCode = option.bpColorCode;
                        product.bpColorPallette = option.bpColorPallette;
                        product.txColorCode = option.txColorCode;
                        product.txColorPallette = option.txColorPallette;
                        product.acColorCode = option.acColorCode;
                        product.acColorPallette = option.acColorPallette;
                        product.fpColorCode = option.fpColorCode;
                        product.fpColorPallette = option.fpColorPallette;
                        product.AccentColor = option.AccentColor;
                        product.MountingType = option.MountingType;
                        product.FontType = option.FontType;
                        product.FontSize = option.FontSize;
                        product.HorizontalAlign = option.HorizontalAlign;
                        product.VerticalAlign = option.VerticalAlign; 
                        string temp = JSON.serialize(option);
                        product = (ExpOption)JSON.deserialize(temp, ExpOption.class);
                        x.Options.Add(product);
                    }
                }
                qProductList.add(x);
            }
        }
        return qProductList;     
    }

    
    private static List<AlternateWrapper> getMockProducts(sfdata.ArrayOfExpConfiguration results) {
        List<AlternateWrapper> result = new List<AlternateWrapper>();
        

        if(results != null && results.ExpConfiguration != null)
        {
            for (sfdata.ExpConfiguration config: results.ExpConfiguration) 
            {        
                Alternate__c mockAlternate = new Alternate__c();
                List<QuoteLineItem> products = new List<QuoteLineItem>();   
                mockAlternate.Description__c = String.valueOf(config.ID); //hijack this field for exp Id
                mockAlternate.Name__c = config.Name;
                mockAlternate.Freight_Amount__c = 0;
                
                if(config.Options != null && config.Options.ExpOption != null)
                {
                    for (sfdata.ExpOption option: config.Options.ExpOption) 
                    {
                        QuoteLineItem product = new QuoteLineItem();

                        product.Item_Number__c = option.ItemNumber;
                        product.Color__c = option.ColorCode;
                        product.Quantity = option.Qty;
                        product.Price_Per_Unit__c = option.Price;
                        product.UnitPrice = option.Price;
                        product.Description = option.Description;
                        product.Description_2__c = option.Description2;
                        product.Note__c = option.Note;
                        product.Alternate__r = mockAlternate;
                        
                        products.Add(product);
                    }
                }
                AlternateWrapper wrapper = new AlternateWrapper();
                wrapper.Alternate = mockAlternate;
                wrapper.QuoteLineItems = products;
                result.add(wrapper);
            }
        }
        return result;     
    }

    @AuraEnabled
    public static string GetValidationFileLink(string quoteId)
    {
        Quote quote = [SELECT Id, CreatedById, CreatedBy.Email, Name FROM Quote WHERE Id = :quoteId];
        string fileName = quoteId + '_resultsJson.txt';
        Attachment attachment = Database.query('SELECT Id,Body,ContentType FROM Attachment  WHERE ParentId = :quoteId AND Name = \'' + fileName + '\'');
        return 'https://inprocorporation2019--beta.sandbox.lightning.force.com/lightning/r/Attachment/' + attachment.Id;
    }
    
    @future(callout = true)
    public static void VerifyAddDeductQuote(string quoteId)
    {
        Quote quote = [SELECT Id, CreatedById, CreatedBy.Email, Name FROM Quote WHERE Id = :quoteId];
        try {

            string fileName = quoteId + '_resultsJson.txt';
            List<Attachment> fileList = Database.query('SELECT Id,Body,ContentType FROM Attachment  WHERE ParentId = :quoteId AND Name = \'' + fileName + '\'');

            if (fileList.size() > 0)
            {
                Attachment file = fileList[0];

                String addsJson = file.Body.toString().split('\n')[0];
                String deductsJson = file.Body.toString().split('\n')[1];

                List<ExpConfiguration> adds = (List<ExpConfiguration>)JSON.deserialize(addsJson, List<ExpConfiguration>.class);
                List<ExpConfiguration> deducts = (List<ExpConfiguration>)JSON.deserialize(deductsJson, List<ExpConfiguration>.class);
                List<ExpConfiguration> expected = adds;
                expected.addAll(deducts);

                List<ExpConfiguration> actual = GetQuoteProducts(quoteId);

                List<ExpConfiguration> missing = new List<ExpConfiguration>();
                for(ExpConfiguration a : expected)
                {
                    Boolean aFound = false;
                    List<ExpOption> missingItems = new List<ExpOption>();

                    for(ExpConfiguration b : actual)
                    {
                        if (a.Name.toLowerCase() == b.Name.toLowerCase())
                        {
                            aFound = true;
                            List<ExpOption> qlis = b.Options;

                            for(ExpOption aItem : a.Options)
                            {
                                Boolean aItemFound = false;

                                for(ExpOption bItem : qlis)
                                {
                                    aItem.Description =  aItem.Description == null ? '' : aItem.Description.trim();
                                    aItem.Description2 =  aItem.Description2 == null ? '' : aItem.Description2.trim();
                                    aItem.Note =  aItem.Note == null ? '' : aItem.Note.trim();
                                    aItem.ColorCode =  aItem.ColorCode == null ? '' : aItem.ColorCode.trim();

                                    bItem.Description =  bItem.Description == null ? '' : bItem.Description.trim();
                                    bItem.Description2 =  bItem.Description2 == null ? '' : bItem.Description2.trim();
                                    bItem.Note =  bItem.Note == null ? '' : bItem.Note.trim();
                                    bItem.ColorCode =  bItem.ColorCode == null ? '' : bItem.ColorCode.trim();

                                    if (aItem.ItemNumber == bItem.ItemNumber &&
                                        aItem.Description == bItem.Description &&
                                        aItem.Description2 == bItem.Description2 &&
                                        aItem.Note == bItem.Note &&
                                        aItem.Price == bItem.Price &&
                                        aItem.Qty == bItem.Qty &&
                                        aItem.ColorCode == bItem.ColorCode)
                                    {
                                        aItemFound = true;
                                    }
                                }

                                if (!aItemFound)
                                {
                                    missingItems.add(aItem);
                                }
                            }
                        }
                    }
                    if (!aFound || missingItems.size() > 0)
                    {
                        ExpConfiguration c = new ExpConfiguration();
                        c.Name = a.Name;
                        c.Options = missingItems;
                        missing.add(a);
                    }
                }
                
                string body = '';
                string subject = '';
                if (missing.size() == 0)
                {
                    subject = 'ADD/DEDUCT Quote Success! ' + quote.Name;
                    body = 'Your ADD/DEDUCT quote from the Quote Comparison Tool finished without error. <br>';
                    body += '<a href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Quote/' + quoteId + '/view\">Link to Quote</a><br>';
                }
                else
                {
                    subject = 'ADD/DEDUCT Quote Error! ' + quote.Name;
                     body = 'Some items did not save correctly in your recent ADD/DEDUCT quote creation from the Quote Comparison Tool. <br>' +
                        'Item descriptions may have changed, or items did not save back at all.<br>' +
                        '<a href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Quote/' + quoteId + '/view\">Link to Quote</a><br>' +
                        'Please review the below items: <br><br>' + BuildMissingConfigTableHTML(missing) + '<br><br>';//
                        //+ 'Actual JSON:<br>' + JSON.serialize(actual) + '<br><br>Expected JSON:<br>' + JSON.serialize(expected);
                }

                EmailSendHelper.sendEmail(quote.CreatedBy.Email, 'bsibley@inprocorp.com', subject, body);

                delete file;
            }
            else {
                sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
                service.timeout_x = 120000;
                service.VerifyConfiguration(quoteId, 'dsj8U73_3nv3Dhba');
            }
        } catch (Exception ex) {
            EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'ADD/DEDUCT Quote Error', ex.getMessage() + '\r\n' + ex.getStackTraceString());
        }
    }

    private static List<Alternate__c> GetAlternates(string quoteId)
    {
        try{
            Quote quote = [SELECT Id, MSCRM_Id__c FROM Quote WHERE Id = :quoteId];
            if (quote.MSCRM_ID__c != '' && quote.MSCRM_ID__c != null)
            {
                List<AlternateWrapper> results = GetMockQuoteProducts(quoteId);
                List<Alternate__c> alts = new List<Alternate__c>();
                
                for(AlternateWrapper aw : results)
                {
                    alts.add(aw.Alternate);
                }

                return alts;
            }
            else
            {
                return [SELECT Id, Total_Weight__c, Total_Material__c, Total_List_Price__c, Total_incl_Shipping_Tax__c, 
                Total_Discount_Amount__c, Total_Cost__c, Tax_Percent__c, Show_Unit_Pricing__c, Shipping_Location__c, 
                Service_Call_Note__c, Service_Call_Charge__c, Service_Call__c, Sequence_Number__c, Quoted_From_Location__c, 
                QuoteId__c, Product_Tax__c, Originating_Alternate__c, Number__c, Name__c,  Mixed_Shipping_Locations__c, 
                Manual_Shipping_Description__c, Manual_Freight_Quote_Request_Link__c, Manual_Freight_Quote_Request_ID__c,
                Manual_Freight_Quote_ID__c, Loading_Dock_Charge__c, Loading_Dock__c, Lift_Gate_Charge__c, Lift_Gate__c, Inside_Delivery_Charge__c,
                Inside_Delivery__c, Has_Zero_Weight_Items__c, Has_Invalid_Freight__c, Has_Drop_Ship_Items__c, Group_Number__c, Group_Name__c, 
                Freight_Tax__c, Freight_Group_Name__c, Freight_Carrier__c, Freight_Amount__c, Driver_Wait_Charge__c, Driver_Wait__c,  
                Description__c, CurrencyIsoCode, Contains_Custom_Parts__c,  Bid_Format_Unit_Price__c, Additional_Information__c FROM Alternate__c
                WHERE QuoteId__c = :quoteId];
            }
        }
        catch(Exception ex) 
        {
            return new List<Alternate__c>();
        }
        
    }

    private static List<QuoteLineItem> GetQuoteLineItems(string alternateId, string quoteId)
    {
        try {
            Quote quote = [SELECT Id, MSCRM_Id__c FROM Quote WHERE Id = :quoteId];
            if (quote.MSCRM_ID__c != '' && quote.MSCRM_ID__c != null)
            {
                List<AlternateWrapper> results = GetMockQuoteProducts(quoteId);
                List<Alternate__c> alts = new List<Alternate__c>();
                
                for(AlternateWrapper aw : results)
                {
                    if (aw.Alternate.Id == alternateId)
                    {
                        return aw.QuoteLineItems;
                    }
                }

                return new List<QuoteLineItem>();
            }
            else
            {
                return [SELECT Id, Material_Allocation_Note__c, SignScheduleId__c, Yards_Per_Line__c, Windows__c, Window_Depth__c, Width__c, Weights__c, W_Note__c, Vertical_Alignment__c, 
                Vendor_2__c, Vendor__c, Valance_2__c, Valance__c, UnitPrice, Unit_Weight__c, Unit_of_Measure__c, Unit_Cost__c, Type__c, 
                Total_Yards__c, Tilt_2__c, Tilt__c, Thickness__c, Taxable__c, T_Note_3__c, T_Note_2__c,
                T_Note__c, Surface_Paint__c, Substrate__c, Style__c, Stiffener__c, SortOrder, Size_2__c, Size__c, Side_Splash_Right_Length__c, Side_Splash_Right_Height__c, 
                Side_Splash_Left_Length__c, Side_Splash_Left_Height__c, Side_Apron_Right_Length__c, Side_Apron_Right_Height__c, Side_Apron_Left_Length__c, 
                Side_Apron_Left_Height__c, Sheet_Size__c, Sewing_Type_2__c, Sewing_Type__c, ServiceDate, Sequence_Number__c, Room_Location__c, Rod_Style__c, 
                Rod_Part_Number__c, Rod_Diameter__c, Rod_Color__c, Ripple_Fold_Tape_Clear__c, Ripple_Fold_Fullness__c, Return__c, Rendering_Required__c, 
                Rendering_Part_Number__c, RecordId__c, Recalculate_Allocation__c, Radius__c, Railroad__c, QuoteId, Quote_Note__c, Quantity, Qualifications__c, 
                Production_Type__c, Product2Id, Product_Number__c, Product_Description__c, Privacy_Slat__c, Pricing_Updated_On__c, PricebookEntryId, Price_Per_Unit_Base__c,
                Price_Per_Unit__c, Price_Level__c, Pin_Setting__c, Pick_Sequence__c, Pattern_2__c, Panels__c, Pattern__c, P_Note__c, Originating_Alternate_Header_Id__c,
                Order_Item_Breakout__c, OpportunityLineItemId, Operator_Location__c, Operator__c, Obsolete__c, Note__c, NestedLineNumber__c, Mounting_Type__c, 
                Metric_Description_2__c, Metric_Description_1__c, Mesh__c, Mesh_Height__c, Master_Carrier__c, Listello_Pattern__c, Lining__c, LineNumber__c,
                Line_Number__c, Lift_2__c, Lift__c, Length__c, Labor__c, Item_Type__c,
                Item_Number__c, Item_Allocation_2__c, Item_Allocation__c, Is_Parent__c, Is_Hardware__c, Is_Custom_Product__c, Installation__c, Include_Edge_Banding__c, 
                Horizontal_Alignment__c, Hem_Bar__c, Height_3__c, Height_2__c, Height__c, Fullness__c, Grommet_Color__c, Front_Apron_Length__c, Front_Apron_Height__c,
                Freight_Code__c, Font_Type__c, Font_Size_2__c, Font_Size__c, Flip__c, Flat_Panel_Pins__c, Fabric_Width_2__c, Fabric_Vertical_Repeat_2__c, Fabric_Width__c,
                Fabric_Vertical_Repeat__c, Fabric_Tape__c, Fabric_Horizontal_Repeat__c, EDI_Vendor_Item__c, EDI_Line_Number__c, EDI_Inpro_Item__c,
                Edge_Right_Length__c, Edge_Length__c, Edge_Left_Length__c, Edge_Height__c, Edge_Banding_Width__c, Edge__c, Draw_Type__c, Double_Sided__c,
                Document_Name__c, Do_Not_Print__c, Discount, Digital_Print__c, Description, Description_2__c, Cut_List__c, Customer_Priced_On__c,
                Custom_Pricing_Requested__c, Custom_Angle__c, Cord_Position__c, Cord_Length__c, Color_Class__c, Color_7__c, Color_6__c,
                Color_5__c, Color_4__c, Color_3__c, Color_2__c, Color__c, Chain_Guide__c, Ceiling_to_Curtain__c, Ceiling_Height__c, Bulk_Pack_Group__c, 
                Braille__c, Brackets_2__c, Brackets__c, Baston_Length__c, Base_Price__c, Backsplash_Length__c, Backsplash_Height__c, Back_Plate_Substrate__c,
                Alternate_Number__c, Alternate_Name__c, Alternate__c, Alloy_Type__c, Allocation_Width__c, Allocation_Length__c, Additional_Liner__c, 
                Above_Floor_Finish__c, Accessory__c,Custom_Part_Number__c FROM QuoteLineItem WHERE Alternate__c = :alternateId];
            }
            
        } catch (Exception ex) {
            return new List<QuoteLineItem>();
        }
    }

    private static string BuildMissingConfigTableHTML(List<ExpConfiguration> configsNotFound)
    {
        string thTag = '<th style=\'text:bold;border-bottom:1px solid black;border-right:1px solid black;\'>';
        string tdTag = '<td style=\'border-bottom:1px solid black;border-right:1px solid black;\'>';
        string html = '';
        for(ExpConfiguration config : configsNotFound)
        {
            html += '<b>Alternate: ' + config.Name + '</b>';

            html += '<table style=\'padding-top:10px;\'><tr>' + thTag + 'Item Number</th>' + thTag + 'Item Color</th>' +
                    '' + thTag + 'Price</th>' + thTag + 'Qty</th>' + thTag + 'Description 1</th>' + thTag + 'Description2</th>' + thTag + 'Note</th></tr>';
            for (ExpOption item : config.Options)
            {
                html += '<tr>' + tdTag + item.ItemNumber + '</td>' + tdTag + item.ColorCode + '</td>' + tdTag + item.Price + '</td>' + tdTag + '' +
                     item.Qty + '</td>' + tdTag + item.Description + '</td>' + tdTag + item.Description2 + '</td>' + tdTag + item.Note + '</td></tr>';
            }
            html += '</table><br><br>';
        }

        return html;
    }

    @AuraEnabled
    public static List<Account> getBidders(string quote1Id, string quote2Id)
    {
        try
        {
            List<Quote_Bidder__c> bidders = [SELECT Id, AccountId__c FROM Quote_Bidder__c WHERE Quote__c = :quote1Id or Quote__c = :quote2Id];

            string str = '';
    
            for(Quote_Bidder__c bidder : bidders)
            {
                str += str == '' ? '\'' + bidder.AccountId__c + '\'' : ',\'' + bidder.AccountId__c + '\'';
            }
    
            List<Account> accounts = Database.query('SELECT Id, Name FROM Account WHERE Id IN (' + str + ')');
            return accounts;
        }
        catch (Exception ex)
        {
            return new List<Account>();
        }
    }

    @AuraEnabled
    public static List<Quote> getQuotes(string opportunityId){
        return [SELECT Id, OpportunityId, QuoteNumber, Name, Revision_Number__c, BidQuote__c, AccountId, Account_Name_Formula__c, Locked__c,
                       Division__c, Division_Lookup__c, Created_Date__c, CreatedDate, Version_Description__c, Status, QuoteToName, MSCRM_ID__c
                FROM Quote
                WHERE OpportunityId = :opportunityId
                ORDER BY CreatedDate DESC];
    }

    @AuraEnabled
    public static string getPreComparedMap(string firstQuoteId, string secondQuoteId)
    {
        Map<String, List<QuoteLineItem>> altsOne = GetMap(firstQuoteId);
        Map<String, List<QuoteLineItem>> altsTwo = GetMap(secondQuoteId);
        PreComparisonDTO preComparedMap = GetPreComparedMap(altsOne,altsTwo);
        return JSON.serialize(preComparedMap);
    }

    @AuraEnabled
    public static string createComparison2(string preComparedMapJson)
    {
        List<List<QuoteLineItem>> rowsToCompare = (List<List<QuoteLineItem>>)JSON.deserialize(preComparedMapJson, List<List<QuoteLineItem>>.class);
        
        return JSON.serialize(GetRows(rowsToCompare));
    }

    @AuraEnabled
    public static string createComparisonMatch(string altOneId, string altTwoId, string quoteOneId, string quoteTwoId)
    {
        List<List<QuoteLineItem>> temp = new List<List<QuoteLineItem>>();
        temp.add( GetQuoteLineItemsByAlternateId(altOneId, quoteOneId));
        temp.add( GetQuoteLineItemsByAlternateId(altTwoId, quoteTwoId));

        return JSON.serialize(GetRows(temp));
    }

    private static ComparisonDTO GetComparedMap(PreComparisonDTO preComparedMap)
    {
        Map<String, List<ComparedRow>> matchedAlts = new Map<String, List<ComparedRow>>();

        for(String key : preComparedMap.matchedAlts.keySet())
        {
            matchedAlts.put(key, GetRows(preComparedMap.matchedAlts.get(key)));
        }

        ComparisonDTO dto = new ComparisonDTO();
        dto.matchedAlts = matchedAlts;

        return dto;
    }

    private static List<ComparedRow> GetRows(List<List<QuoteLineItem>> lists)
    {
        List<ComparedRow> rows = new List<ComparedRow>();

        List<QuoteLineItem> first = lists.get(0);
        List<QuoteLineItem> second = lists.get(1);

        if (first.size() == 0)
        {
            for(QuoteLineItem item : second)
            {
                ComparedRow row = new ComparedRow();
                row.second = new QuoteLineItemWrapper(item);
                rows.add(row);
            }
        }
        else if (second.size() == 0)
        {
            for(QuoteLineItem item : first)
            {
                ComparedRow row = new ComparedRow();
                row.first = new QuoteLineItemWrapper(item);
                rows.add(row);
            }
        }
        else
        {
            QuoteLineItem bestMatch;
            Integer bestScore = 0;
            Boolean isReversed = false;
            if (second.size() > first.size())
            {
                List<QuoteLineItem> temp = first;
                first = second;
                second = temp;
                isReversed = true;
            }

            for(QuoteLineItem item : second)
            {
                for(QuoteLineItem item2 : first)
                {
                    Integer score = item2.Item_Number__c != item.Item_Number__c ? 1000 : 0;
                    score += GetScore(item2.Color__c, item.Color__c, false);
                    score += GetScore(String.valueOf(item2.Quantity), String.valueOf(item.Quantity), false);
                    score += GetScore(String.valueOf(item2.Price_Per_Unit__c), String.valueOf(item.Price_Per_Unit__c), false);
                    score += GetScore(item2.Description, item.Description, false);
                    score += GetScore(item2.Description_2__c, item.Description_2__c, false);
                    score += GetScore(item2.Note__c, item.Note__c, true);

                    if (score < bestScore)
                    {
                        bestMatch = item2;
                        bestScore = score;
                    }
                }

                ComparedRow row = new ComparedRow();
                if (isReversed)
                {
                    row.second = new QuoteLineItemWrapper(bestMatch);
                    row.first = new QuoteLineItemWrapper(item);
                    rows.add(row);
                }
                else 
                {
                    row.first = new QuoteLineItemWrapper(bestMatch);
                    row.second = new QuoteLineItemWrapper(item);
                    rows.add(row);
                }
                

                if (bestMatch != null)
                {
                    first.remove(first.indexOf(bestMatch));
                    bestMatch = null;
                    bestScore = 0;
                }
            }
            second = new List<QuoteLineItem>();

            bestMatch = null;
            bestScore = 0;

            for(QuoteLineItem item2 : first)
            {
                ComparedRow row = new ComparedRow();
                if (isReversed)
                {
                    row.second = new QuoteLineItemWrapper(item2);
                    row.first = new QuoteLineItemWrapper(bestMatch);
                }
                else
                {
                    row.first = new QuoteLineItemWrapper(item2);
                    row.second = new QuoteLineItemWrapper(bestMatch);
                }
                
                rows.add(row);
            }
        }

        rows.sort();
        return rows;
    }

    private static PreComparisonDTO GetPreComparedMap(Map<String, List<QuoteLineItem>> altsOne, Map<String, List<QuoteLineItem>> altsTwo)
    {
        PreComparisonDTO dto = new PreComparisonDTO();
        Map<String, List<List<QuoteLineItem>>> matchedAlts = new Map<String, List<List<QuoteLineItem>>>();

        for(String keyOne : altsOne.keySet())
        {
            if (altsTwo.containsKey(keyOne))
            {
                List<List<QuoteLineItem>> tempList = new List<List<QuoteLineItem>>();
                tempList.add(altsOne.get(keyOne));
                tempList.add(altsTwo.get(keyOne));
                matchedAlts.put(keyOne,tempList);
            }
            else
            {
                List<List<QuoteLineItem>> tempList = new List<List<QuoteLineItem>>();
                tempList.add(altsOne.get(keyOne));
                tempList.add(new List<QuoteLineItem>());
                matchedAlts.put(keyOne,tempList);
            }
        }
        for(String keyTwo : altsTwo.keySet())
        {
            if (!altsOne.containsKey(keyTwo))
            {
                List<List<QuoteLineItem>> tempList = new List<List<QuoteLineItem>>();
                tempList.add(new List<QuoteLineItem>());
                tempList.add(altsTwo.get(keyTwo));
                matchedAlts.put(keyTwo,tempList);
            }
        }

        dto.matchedAlts = matchedAlts;

        return dto;
    }

    public class PreComparisonDTO
    {
        Map<String, List<List<QuoteLineItem>>> matchedAlts {get;set;}
    }

    public class ComparisonDTO
    {
        Map<String, List<ComparedRow>> matchedAlts {get;set;}
        Map<String, List<ComparedRow>> noMatchOneAlts {get;set;}
        Map<String, List<ComparedRow>> noMatchTwoAlts {get;set;}
    }

    public class ComparedAlternate
    {
        public string AlternateId {get;set;}
        public string freightOne {get;set;}
        public string freightOneName {get;set;}
        public string freightTwo {get;set;}
        public string freightTwoName {get;set;}
        public Boolean isProcessed {get;set;}
        public Boolean isSelected {get;set;}
        public string key {get;set;}
        public Integer order {get;set;}
        public string totalOne {get;set;}
        public string totalTwo {get;set;}
        public List<ComparedRow> value {get;set;}
        public Boolean visible {get;set;}
    }

    public class ComparedRow implements Comparable
    {
        public string key {get;set;}
        public Boolean changes {get;set;}
        QuoteLineItemWrapper first {get;set;}
        QuoteLineItemWrapper second {get;set;}
        public Boolean visible {get;set;}

        public Integer compareTo(Object compareTo) {

            ComparedRow other = (ComparedRow)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (second != null && second.item != null && other.second != null && other.second.item != null) {
                return second.item.Item_Number__c.compareTo(other.second.item.Item_Number__c);
            } 
            else if (second == null || second.item == null)
            {
                return 1;
            }
            else return -1;
        }
    }

    public virtual class QuoteLineItemWrapper 
    {
        public QuoteLineItemWrapper(QuoteLineItem item)
        {
            this.item = item;
        }

        public String Id {get;set;}
        public String UnitPriceFormat {get;set;}
        public QuoteLineItem item {get;set;}
    }

    private static List<QuoteLineItem> GetQuoteLineItemsByAlternateId(string altId, string quoteId)
    {
        Quote quote = [SELECT Id, MSCRM_Id__c FROM Quote WHERE Id = :quoteId];
        if (quote.MSCRM_ID__c != '' && quote.MSCRM_ID__c != null)
        {
            List<AlternateWrapper> results = GetMockQuoteProducts(quoteId);
            List<Alternate__c> alts = new List<Alternate__c>();
            
            for(AlternateWrapper aw : results)
            {
                if (aw.Alternate.Description__c == altId)
                {
                    return aw.QuoteLineItems;
                }
            }

            return new List<QuoteLineItem>();
        }
        else
        {
            return [SELECT Id,Product__c, Alternate__c, Color__c, Alternate_Name__c, Item_Number__c, Description, Description_2__c, Quantity, RecordId__c,
                            TotalPrice, UnitPrice, Note__c, Height__c, Custom_Angle__c, Allocation_Length__c, Allocation_Width__c, Radius__c, 
                            LineNumber__c, Sequence_Number__c, Price_Per_Unit__c, Unit_Cost__c, Length__c, Width__c,
                            Product2Id, PricebookEntryId, Discount, Taxable__c, Unit_Weight__c, Brackets__c, Brackets_2__c, Operator__c,
                            Alternate__r.Name__c, Alternate__r.Total_Cost__c, Alternate__r.Freight_Amount__c, Alternate__r.Freight_Carrier__r.Name
                    FROM QuoteLineItem 
                    WHERE Alternate__c = :altId
                    ORDER BY Item_Number__c ASC];
        }
    }

    private static List<QuoteLineItem> GetQuoteLineItemsByQuoteId(string quoteId)
    {
        return   [SELECT Id,Product__c, Alternate__c, Color__c, Alternate_Name__c, Item_Number__c, Description, Description_2__c, Quantity, RecordId__c,
                        TotalPrice, UnitPrice, Note__c, Height__c, Custom_Angle__c, Allocation_Length__c, Allocation_Width__c, Radius__c, 
                        LineNumber__c, Sequence_Number__c, Price_Per_Unit__c, Unit_Cost__c, Base_Price__c, Length__c, Width__c,
                        Product2Id, PricebookEntryId, Discount, Taxable__c, Unit_Weight__c, Brackets__c, Brackets_2__c, Operator__c,
                        Alternate__r.Name__c, Alternate__r.Total_Cost__c, Alternate__r.Freight_Amount__c, Alternate__r.Freight_Carrier__r.Name
                  FROM QuoteLineItem 
                  WHERE QuoteId = :quoteId
                  ORDER BY Item_Number__c ASC];
    }

    private static Map<String, List<QuoteLineItem>> GetMap(string quoteId)
    {
        Quote quote = [SELECT Id, MSCRM_Id__c FROM Quote WHERE Id = :quoteId];
        if (quote.MSCRM_ID__c != '' && quote.MSCRM_ID__c != null)
        {
            List<AlternateWrapper> results = GetMockQuoteProducts(quoteId);
            List<Alternate__c> alts = new List<Alternate__c>();
            
            Map<String, List<QuoteLineItem>> altsOne = new Map<String, List<QuoteLineItem>>();

            for(AlternateWrapper aw : results)
            {
                altsOne.put(aw.Alternate.Name__c, aw.QuoteLineItems);
            }

            return altsOne;
        }
        else 
        {
            List<QuoteLineItem> qliOne =   [SELECT Id,Product__c, Alternate__c, Color__c, Alternate_Name__c, Item_Number__c, Description, Description_2__c, Quantity, RecordId__c,
                                                TotalPrice, UnitPrice, Note__c, Height__c, Custom_Angle__c, Allocation_Length__c, Allocation_Width__c, Radius__c, 
                                                LineNumber__c, Sequence_Number__c, Price_Per_Unit__c, Unit_Cost__c, Base_Price__c,
                                                Product2Id, PricebookEntryId, Discount, Taxable__c, Unit_Weight__c, Brackets__c, Brackets_2__c, Operator__c,
                                                Alternate__r.Name__c, Alternate__r.Total_Cost__c, Alternate__r.Freight_Amount__c, Alternate__r.Freight_Carrier__r.Name
                                        FROM QuoteLineItem 
                                        WHERE QuoteId = :quoteId
                                        ORDER BY Item_Number__c ASC];

            Map<String, List<QuoteLineItem>> altsOne = new Map<String, List<QuoteLineItem>>();

            for(QuoteLineItem qli : qliOne)
            {
                if (altsOne.containsKey(qli.Alternate__r.Name__c))
                {
                    List<QuoteLineItem> qliTemp = altsOne.get(qli.Alternate__r.Name__c);
                    qliTemp.add(qli);
                    altsOne.put(qli.Alternate__r.Name__c, qliTemp);
                }
                else
                {
                    List<QuoteLineItem> qliTemp = new List<QuoteLineItem>();
                    qliTemp.add(qli);
                    altsOne.put(qli.Alternate__r.Name__c, qliTemp);
                }
            }

            return altsOne;
        }
    }

    private static Integer GetScore(string s, string t, boolean weighted)
    {
        Integer score = 0;
        Integer extra = 0;

        if (s == null || s == '')
        {
            if (t == null || t == '')
                return 0;
            return t.trim().length();
        }

        if (t == null || t == '' )
        {
            return s.trim().length();
        }
        s = s.trim().toLowerCase();
        t = t.trim().toLowerCase();

        if (s.length() > t.length())
        {
            for(Integer i = 0; i < s.length(); i++)
            {
                if (i < t.length() && s.charAt(i) == t.charAt(i))
                {
                    score -= 1;
                }
                else
                {
                    score += 1;
                }
            }
        }
        else if (t.length() > s.length())
        {
            for(Integer i = 0; i < t.length(); i++)
            {
                if (i < s.length() && t.charAt(i) == s.charAt(i))
                {
                    score -= 1;
                }
                else
                {
                    score += 1;
                }
            }
        }
        else
        {
            for(Integer i = 0; i < s.length(); i++)
            {
                if (s.charAt(i) == t.charAt(i))
                {
                    score -= 1;
                }
                else
                {
                    score += 1;
                }
            }
        }
        
        if (weighted)
        {
            String[] arrA = s.Split(' ');
            String[] arrB = t.Split(' ');
            for(String a : arrA)
            {
                if (!arrB.Contains(a)) extra += 5;
                else extra -= 5;
            }
        }

        return score + extra;
    }

    public class ExpConfiguration
    {
        public string Name { get; set; }
        public integer ID { get; set; }
        public List<ExpOption> Options { get; set; }
        public List<ExpOption> RemovedOptions { get; set; }
        public Boolean MadeChanges { get; set; }
    }

    public class ExpOption
    {
        public string ItemNumber { get; set; }
        public string ColorCode { get; set; }
        public decimal Qty { get; set; }
        public Integer PickSequence { get; set; }
        public string Description { get; set; }
        public string Description2 { get; set; }
        public string Color { get; set;}
        public Integer AlternateId { get; set;}
        public Decimal Quantity { get; set;}
        public Integer rAlternateId { get; set;}
        public string ColorPalette { get; set;}
        public string qProductList { get; set;}
        public string Note { get; set; }
        public string rId { get; set; }
        public string ID { get; set; }
        public string Name { get; set; }
        public string CompetitorColor { get; set; }
        public string bpColorCode { get; set; }
        public string fpColorCode { get; set; }
        public string txColorCode { get; set; }
        public string acColorCode { get; set; }
        public string HorizontalAlign { get; set; }
        public string VerticalAlign { get; set; }
        public string FontSize { get; set; }
        public string FontType { get; set; }
        public string bpColorPallette { get; set; }
        public string fpColorPallette { get; set; }
        public string txColorPallette { get; set; }
        public string acColorPallette { get; set; }
        public string MountingType { get; set; }

        public string AccentColor { get; set; }
        public string NormalProductAccentColor { get; set; }
        public string ProductionType { get; set; }
        public string Collection { get; set; }
        public string CustombpColor { get; set; }
        public string CustomfpColor { get; set; }
        public string CustomtxColor { get; set; }
        public string AlternateName { get; set; }
        public string NoteCB { get; set; }
        public string LetterCodeCB { get; set; }
        public string CategoryID { get; set; }
        public string LetterCode { get; set; }        
        public String DiscountType {get;set;}
        public Decimal Discount{get;set;}
        public Decimal Height{get;set;}
        public String AlloyType {get;set;}
        public String Radius {get;set;}
        public Decimal UnitWeight{get;set;}
        public Decimal BasePrice{get;set;}
        public Decimal Price{get;set;}
        public Decimal Length { get; set; }
        public Decimal Width { get; set; }
        public Integer Brackets { get; set; }
        public Integer Brackets2 { get; set; }
    }

    @AuraEnabled
    public static Opportunity GetOpportunity(string recordId)
    {
        return [SELECT Id, Name FROM Opportunity WHERE Id = :recordId];
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> OpportunitySearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:opportunity';
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE Name LIKE :key LIMIT 50];

        for (Opportunity opp : opps) {

            String fullname = opp.Name;
            String id = opp.Id;
            String subtitle ='';// user.Email;
                
            results.add(new LookupSearchResult(id, 'opportunity', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

}