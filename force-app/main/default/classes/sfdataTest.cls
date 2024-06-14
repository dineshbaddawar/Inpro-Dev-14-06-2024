@isTest
global class sfdataTest implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        // start - specify the response you want to send
        // calculatorServices.doAddResponse response_x = 
        //     new calculatorServices.doAddResponse();
		// response_x.return_x = 3.0;

		if (responseType == 'sfdata.EstimatingWriteConfigsDWResponse_element') 	
		{
			sfdata.EstimatingWriteConfigsDWResponse_element response_x = new sfdata.EstimatingWriteConfigsDWResponse_element();
			response_x.EstimatingWriteConfigsDWResult = new sfdata.Result();
			response_x.EstimatingWriteConfigsDWResult.Message = '';
			response_x.EstimatingWriteConfigsDWResult.Status = true;
			response_x.EstimatingWriteConfigsDWResult.RecordID = '';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.SaveQuoteResponse_element')
		{
			sfdata.SaveQuoteResponse_element response_x = new sfdata.SaveQuoteResponse_element();
			response_x.SaveQuoteResult = '';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.EstimatingImportDWResponse_element')
		{
			sfdata.EstimatingImportDWResponse_element response_x = new sfdata.EstimatingImportDWResponse_element();
			response_x.EstimatingImportDWResult = new sfdata.ImportStatus();
			response_x.EstimatingImportDWResult.Message = '';
			response_x.EstimatingImportDWResult.Status = true;
			response_x.EstimatingImportDWResult.Products = new sfdata.ArrayOfProduct();
			response_x.EstimatingImportDWResult.Products.Product = new List<sfdata.Product>();
			sfdata.Product product = new sfdata.Product();
			product.AlternateName = ''; product.Color = ''; product.ColorPallette = '';
			product.Deduct = false; product.Description1 = ''; product.Description2 = '';
			product.ExperlogixNotes = ''; product.Height = 1; product.IsSpecialPalette = false;
			product.ItemNumber = '1'; product.LetterCode = 'A'; product.MetricDescription1 = '';
			product.MetricDescription2 = ''; product.MismatchedColor = false; product.Notes = '';
			product.Obsolete = ''; product.Qty = '1'; product.Quantity = 1.0;
			product.UnitCost = 1.0; product.UnitWeight = 1.0; product.UOM = '';
			product.ValidExperlogix = true; product.ValidMacola = false; product.ValidProduct = true;
			product.Width = 1;
			response_x.EstimatingImportDWResult.Products.Product.add(product);
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.ImportConfigXMLResponse_element')
		{
			sfdata.ImportConfigXMLResponse_element response_x = new sfdata.ImportConfigXMLResponse_element();
			response_x.ImportConfigXMLResult = '';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.LoadConfigXMLResponse_element')
		{
			sfdata.LoadConfigXMLResponse_element response_x = new sfdata.LoadConfigXMLResponse_element();
			response_x.LoadConfigXMLResult = '';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.BuildDiscountConfigurationResponse_element')
		{
			sfdata.BuildDiscountConfigurationResponse_element response_x = new sfdata.BuildDiscountConfigurationResponse_element();
			response_x.BuildDiscountConfigurationResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GenerateOrderReportResponse_element')
		{
			sfdata.GenerateOrderReportResponse_element response_x = new sfdata.GenerateOrderReportResponse_element();
			response_x.GenerateOrderReportResult = new sfdata.GenerateOrderReportResult();
			response_x.GenerateOrderReportResult.Status = true;
			response_x.GenerateOrderReportResult.PdfData = '';
			response_x.GenerateOrderReportResult.Message = '';
			response_x.GenerateOrderReportResult.FileLocation = '';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.ForceCancelAsyncTaskResponse_element')
		{
			sfdata.ForceCancelAsyncTaskResponse_element response_x = new sfdata.ForceCancelAsyncTaskResponse_element();
			response_x.ForceCancelAsyncTaskResult = '';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.GetDiscountMultiplierByQuoteResponse_element')
		{
			sfdata.GetDiscountMultiplierByQuoteResponse_element response_x = new sfdata.GetDiscountMultiplierByQuoteResponse_element();
			response_x.GetDiscountMultiplierByQuoteResult = 1.0;
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.CheckOverridePrice_QuoteResponse_element')
		{
			sfdata.CheckOverridePrice_QuoteResponse_element response_x = new sfdata.CheckOverridePrice_QuoteResponse_element();
			response_x.CheckOverridePrice_QuoteResult = 1.0;
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.ProcessOrderResponse_element')
		{
			sfdata.ProcessOrderResponse_element response_x = new sfdata.ProcessOrderResponse_element();
			response_x.ProcessOrderResult = new sfdata.ProcessOrderStatus();
			response_x.ProcessOrderResult.Message = '';
			response_x.ProcessOrderResult.Status = false;
			response_x.ProcessOrderResult.OrderNumber = '12345';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.EstimatingImportJMResponse_element')
		{
			sfdata.EstimatingImportJMResponse_element response_x = new sfdata.EstimatingImportJMResponse_element();
			response_x.EstimatingImportJMResult = new sfdata.ImportStatus();
			response_x.EstimatingImportJMResult.Message = '';
			response_x.EstimatingImportJMResult.Status = true;
			response_x.EstimatingImportJMResult.Products = new sfdata.ArrayOfProduct();
			response_x.EstimatingImportJMResult.Products.Product = new List<sfdata.Product>();
			sfdata.Product product = new sfdata.Product();
			product.AlternateName = null; product.Color = null; product.ColorPallette = null;
			product.Deduct = false; product.Description1 = null; product.Description2 = null;
			product.ExperlogixNotes = null; product.Height = 1; product.IsSpecialPalette = false;
			product.ItemNumber = null; product.LetterCode = null; product.MetricDescription1 = null;
			product.MetricDescription2 = null; product.MismatchedColor = false; product.Notes = null;
			product.Obsolete = null; product.Qty = null; product.Quantity = 1.0;
			product.UnitCost = 1.0; product.UnitWeight = 1.0; product.UOM = null;
			product.ValidExperlogix = true; product.ValidMacola = false; product.ValidProduct = true;
			product.Width = 1;
			response_x.EstimatingImportJMResult.Products.Product.add(product);
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.ApproveUserRegistrationResponse_element')
		{
			sfdata.ApproveUserRegistrationResponse_element response_x = new sfdata.ApproveUserRegistrationResponse_element();
			response_x.ApproveUserRegistrationResult = 'Success';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.CheckOverridePriceResponse_element')
		{
			sfdata.CheckOverridePriceResponse_element response_x = new sfdata.CheckOverridePriceResponse_element();
			response_x.CheckOverridePriceResult = 1.0;
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.GetPriceLevelByQuoteResponse_element')
		{
			sfdata.GetPriceLevelByQuoteResponse_element response_x = new sfdata.GetPriceLevelByQuoteResponse_element();
			response_x.GetPriceLevelByQuoteResult = 'A';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.LoadConfigurationResponse_element') {			
		
			sfdata.LoadConfigurationResponse_element response_x = new sfdata.LoadConfigurationResponse_element();	
			sfdata.ArrayOfExpConfiguration results = new sfdata.ArrayOfExpConfiguration();	
			results.ExpConfiguration = new List<sfdata.ExpConfiguration>();
			sfdata.ExpConfiguration config = new sfdata.ExpConfiguration();
			config.Options = new sfdata.ArrayOfExpOption();
			config.Options.ExpOption = new List<sfdata.ExpOption>();
			sfdata.ExpOption option = new sfdata.ExpOption();
			option.ItemNumber = '405';
			config.Options.ExpOption.add(option);
			results.ExpConfiguration.add(config);
			config.MoreRecords = false;
			response_x.LoadConfigurationResult = results;
			// end
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.SaveConfigurationResponse_element') {
			sfdata.SaveConfigurationResponse_element response_x = new sfdata.SaveConfigurationResponse_element();
			response_x.SaveConfigurationResult = 'true';
			response.put('response_x', response_x); 
		}
		//END CHECK FOR COVERAGE
		else if (responseType == 'sfdata.RetrieveMountingTypesResponse_element')
		{
			sfdata.RetrieveMountingTypesResponse_element response_x = new sfdata.RetrieveMountingTypesResponse_element();
			response_x.RetrieveMountingTypesResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveMountingTypesResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveMountingTypesResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveFontSizesResponse_element')
		{
			sfdata.RetrieveFontSizesResponse_element response_x = new sfdata.RetrieveFontSizesResponse_element();
			response_x.RetrieveFontSizesResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveFontSizesResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveFontSizesResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveFontTypesResponse_element')
		{
			sfdata.RetrieveFontTypesResponse_element response_x = new sfdata.RetrieveFontTypesResponse_element();
			response_x.RetrieveFontTypesResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveFontTypesResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveFontTypesResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveHorizontalJustificationsResponse_element')
		{
			sfdata.RetrieveHorizontalJustificationsResponse_element response_x = new sfdata.RetrieveHorizontalJustificationsResponse_element();
			response_x.RetrieveHorizontalJustificationsResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveHorizontalJustificationsResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveHorizontalJustificationsResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveVerticalJustificationsResponse_element')
		{
			sfdata.RetrieveVerticalJustificationsResponse_element response_x = new sfdata.RetrieveVerticalJustificationsResponse_element();
			response_x.RetrieveVerticalJustificationsResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveVerticalJustificationsResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveVerticalJustificationsResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveCollectionsResponse_element')
		{
			sfdata.RetrieveCollectionsResponse_element response_x = new sfdata.RetrieveCollectionsResponse_element();
			response_x.RetrieveCollectionsResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveCollectionsResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveCollectionsResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveProductionTypesResponse_element')
		{
			sfdata.RetrieveProductionTypesResponse_element response_x = new sfdata.RetrieveProductionTypesResponse_element();
			response_x.RetrieveProductionTypesResult = new sfdata.ArrayOfSignOption();
			response_x.RetrieveProductionTypesResult.SignOption = new List<sfdata.SignOption>();
			sfdata.SignOption signOption = new sfdata.SignOption();
			signOption.LabelField = 'Test';
			signOption.SeqField = 1;
			response_x.RetrieveProductionTypesResult.SignOption.add(signOption);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveSignsResponse_element'){
			sfdata.RetrieveSignsResponse_element response_x = new sfdata.RetrieveSignsResponse_element();
			response_x.RetrieveSignsResult = new sfdata.ArrayOfString();
			response_x.RetrieveSignsResult.string_x = new List<string>();
			response_x.RetrieveSignsResult.string_x.add('Test');
			response.put('response_x', response_x);
		}
		else if(responseType == 'sfdata.GetFreightQuoteResponse_element')
		{
			sfdata.GetFreightQuoteResponse_element response_x = new sfdata.GetFreightQuoteResponse_element();
			response_x.GetFreightQuoteResult = new sfdata.ArrayOfQuote();
			response_x.GetFreightQuoteResult.Quote = new List<sfdata.Quote>();
			sfdata.Quote quote = new sfdata.Quote();
			quote.AlternateId  = '1';
			quote.LiftGateChrg = 50;
			quote.CarrierCode = 'NegotiatedFreight';
			quote.ManualFreightQuotes = new sfdata.ArrayOfManualFreightQuote();
			quote.ManualFreightQuotes.ManualFreightQuote = new List<sfdata.ManualFreightQuote>();
			sfdata.ManualFreightQuote mfq = new sfdata.ManualFreightQuote();
			quote.ManualFreightQuotes.ManualFreightQuote.add(mfq);
			sfdata.Quote quote1 = new sfdata.Quote();
			quote1.AlternateId  = '1';
			quote1.LiftGateChrg = 50;
			quote1.CarrierCode = 'MFQ';
			response_x.GetFreightQuoteResult.Quote.add(quote);	
			response_x.GetFreightQuoteResult.Quote.add(quote1);			
			response.put('response_x', response_x); 
		}
		else if(responseType == 'sfdata.ActivateResetEcommerceResponse_element')
		{
			sfdata.ActivateResetEcommerceResponse_element response_x = new sfdata.ActivateResetEcommerceResponse_element();
			response_x.ActivateResetEcommerceResult = 'Contact registered.';
			response.put('response_x', response_x); 
		}
		else if(responseType == 'sfdata.AddAccountToNetSuiteResponse_element')
		{
			sfdata.AddAccountToNetSuiteResponse_element response_x = new sfdata.AddAccountToNetSuiteResponse_element();
			response_x.AddAccountToNetSuiteResult = 'Success';
			response.put('response_x', response_x); 
		}
		else if(responseType == 'sfdata.GetCustomFormsResponse_element')
		{
			sfdata.GetCustomFormsResponse_element response_x = new sfdata.GetCustomFormsResponse_element();
			response_x.GetCustomFormsResult = new sfdata.ArrayOfCustomForm();
			response_x.GetCustomFormsResult.CustomForm = new List<sfdata.CustomForm>();	
			sfdata.CustomForm  customForm = new sfdata.CustomForm();
			customForm.ISOName = 'test';
			response_x.GetCustomFormsResult.CustomForm.add(customForm);			
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.DownloadCustomFormResponse_element')
		{
			sfdata.DownloadCustomFormResponse_element response_x = new sfdata.DownloadCustomFormResponse_element();
			response_x.DownloadCustomFormResult = new sfdata.DownloadStatus();
			response_x.DownloadCustomFormResult.Status = true;
			response_x.DownloadCustomFormResult.FileData = 'test';
			response_x.DownloadCustomFormResult.Message = 'test';
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.GetEDIHeadersResponse_element')
		{
			sfdata.GetEDIHeadersResponse_element response_x = new sfdata.GetEDIHeadersResponse_element();
			response_x.GetEDIHeadersResult = new sfdata.ArrayOfString();
			response_x.GetEDIHeadersResult.string_x = new List<String>();
			response_x.GetEDIHeadersResult.string_x.add('test');
			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.CopyQuoteResponse_element')
		{
			sfdata.CopyQuoteResponse_element response_x = new sfdata.CopyQuoteResponse_element();
			response_x.CopyQuoteResult = new sfdata.Result();
			response_x.CopyQuoteResult.Message = 'Success Test';
			response_x.CopyQuoteResult.Status = true;
			response_x.CopyQuoteResult.RecordID = '12345';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GetConsolidatedPONumbersResponse_element')
		{
			sfdata.GetConsolidatedPONumbersResponse_element response_x = new sfdata.GetConsolidatedPONumbersResponse_element();
			
			response_x.GetConsolidatedPONumbersResult = new sfdata.ConsolidatedOrderResult();
			response_x.GetConsolidatedPONumbersResult.Name = 'Test';
			response_x.GetConsolidatedPONumbersResult.PONumber = 'PO Number';
			response_x.GetConsolidatedPONumbersResult.ConsolidatedOrders = new sfdata.ArrayOfConsolidatedOrder();
			response_x.GetConsolidatedPONumbersResult.ConsolidatedOrders.ConsolidatedOrder = new List<sfdata.ConsolidatedOrder>();
			
			sfdata.ConsolidatedOrder dummyOrder = new sfdata.ConsolidatedOrder();
			dummyOrder.AccountNumber = '12345';
			dummyOrder.ConsolidationNumber = '12345';
			dummyOrder.ExternalId = '12345';
			dummyOrder.InternalId = '12345';
			dummyOrder.InternationalCustomerNotes = 'Notes';
			dummyOrder.InternationalInternalNotes = 'Notes';
			dummyOrder.Notes = 'Notes';
			dummyOrder.PONumber = '12345';
			dummyOrder.ShippingDate = '1/1/1900';
			dummyOrder.ShipToAddress1 = '123 Test St';
			dummyOrder.ShipToAddress3 = 'Wausau, WI 54401';
			dummyOrder.ShipViaCd = 'Test';
			dummyOrder.Status = '1';
			dummyOrder.UpdatedBy = 'Ben Sibley';
			dummyOrder.UpdatedOn = '1/1/1900';

			response_x.GetConsolidatedPONumbersResult.ConsolidatedOrders.ConsolidatedOrder.add(dummyOrder);

			response.put('response_x', response_x); 
		}
		else if (responseType == 'sfdata.RetrieveSearchItemsResponse_element')
		{
			sfdata.RetrieveSearchItemsResponse_element response_x = new sfdata.RetrieveSearchItemsResponse_element();
			response_x.RetrieveSearchItemsResult = new sfdata.ArrayOfSearchItem();
			List<sfdata.SearchItem> items = new List<sfdata.SearchItem>();
			response_x.RetrieveSearchItemsResult.SearchItem = items;

			sfdata.SearchItem item = new sfdata.SearchItem();
			item.ItemNumber = '12345';
			item.Location = 'Location';
			item.ItemDesc1 = 'Item 1';
			item.ItemDesc2 = 'Item 2';
			item.QtyOnHand = 1.0;
			item.QtyAllocated = 1.0;
			item.QtyAvailable = 1.0;
			item.OnOrderQty = 1.0;
			item.QtyInTransit = 1.0;
			item.SoldPTD = 1.0;
			item.SoldYTD = 1.0;
			item.SoldPY = 1.0;
			item.UsagePTD = 1.0;
			item.UsageYTD = 1.0;
			item.UsagePy = 1.0;
			items.add(item);

			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveSearchItemDetailResponse_element')
		{
			sfdata.RetrieveSearchItemDetailResponse_element response_x = new sfdata.RetrieveSearchItemDetailResponse_element();
			response_x.RetrieveSearchItemDetailResult = new sfdata.ArrayOfSearchItemDetail();
			response_x.RetrieveSearchItemDetailResult.SearchItemDetail = new List<sfdata.SearchItemDetail>();
			sfdata.SearchItemDetail item = new sfdata.SearchItemDetail();
			item.BackgroundColor = 'White';
			item.Desc1 = 'Desc 1';
			item.Desc2 = 'Desc 2';
			item.DueDate = '1/1/21';
			item.FontWeight = true;
			item.LineItem = '12345';
			item.OrderNumber = '12345';
			item.QtyAllocated = '1';
			item.QtyOnHand = '1';
			item.QtyPurchased = '0';
			item.RunningTotal = '100';
			item.ShipDate = '1/1/21';
			item.WOStartColor = 'White';
			response_x.RetrieveSearchItemDetailResult.SearchItemDetail.add(item);

			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveItemMasterCostsResponse_element')
		{
			sfdata.RetrieveItemMasterCostsResponse_element response_x = new sfdata.RetrieveItemMasterCostsResponse_element();
			response_x.RetrieveItemMasterCostsResult = new sfdata.ArrayOfItemMasterCost();
			response_x.RetrieveItemMasterCostsResult.ItemMasterCost = new List<sfdata.ItemMasterCost>();
			sfdata.ItemMasterCost item = new sfdata.ItemMasterCost();
			item.ItemCost = '10.00';
			item.ItemNumber = '12345';
			item.Location = 'Muskego';
			item.StockLocation1 = 'AZ';
			item.StockLocation2 = '';

			response_x.RetrieveItemMasterCostsResult.ItemMasterCost.add(item);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveFeaturesResponse_element'){
			sfdata.RetrieveFeaturesResponse_element response_x = new sfdata.RetrieveFeaturesResponse_element();
			response_x.RetrieveFeaturesResult = new sfdata.ArrayOfFeature();
			response_x.RetrieveFeaturesResult.Feature = new List<sfdata.Feature>();
			sfdata.Feature item = new sfdata.Feature();
			item.ItemNumber = '12345';
			item.ItemDescription = 'Desc';
			item.FeatureNumber = '12345';
			item.FeatureMinimum = '12345';
			item.FeatureInternalID = '12345';
			item.FeatureDescription = 'Desc';
			response_x.RetrieveFeaturesResult.Feature.add(item);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveFeatureOptionsResponse_element')
		{
			sfdata.RetrieveFeatureOptionsResponse_element response_x = new sfdata.RetrieveFeatureOptionsResponse_element();
			response_x.RetrieveFeatureOptionsResult = new sfdata.ArrayOfFeatureOption();
			response_x.RetrieveFeatureOptionsResult.FeatureOption = new List<sfdata.FeatureOption>();
			sfdata.FeatureOption item = new sfdata.FeatureOption();
			item.ComponentDescription = 'Desc 1';
			item.FeatureDescription = 'Desc';
			item.FeatureNumber = '12345';
			item.ItemNumber = '12345';
			item.ParentItemNumber = '12345';
			item.QtyPerPar = '1';
			response_x.RetrieveFeatureOptionsResult.FeatureOption.add(item);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveBOMProductsResponse_element'){
			sfdata.RetrieveBOMProductsResponse_element response_x = new sfdata.RetrieveBOMProductsResponse_element();
			response_x.RetrieveBOMProductsResult = new sfdata.ArrayOfBillOfMaterial();
			response_x.RetrieveBOMProductsResult.BillOfMaterial = new List<sfdata.BillOfMaterial>();
			sfdata.BillOfMaterial item = new sfdata.BillOfMaterial();
			item.CompItemNumber = '12345';
			item.Desc1 = 'Desc 1';
			item.Desc2 = 'Desc 2';
			item.GroupByText = 'Text';
			item.HasSubLevelItems = false;
			item.ItemNumber = '12345';
			item.Location = 'AZ';
			item.QtyPerPart = '1';
			item.UOM = 'UOM';
			response_x.RetrieveBOMProductsResult.BillOfMaterial.add(item);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GetQuoteDiscountsResponse_element')
		{
			sfdata.GetQuoteDiscountsResponse_element response_x = new sfdata.GetQuoteDiscountsResponse_element();
			response_x.GetQuoteDiscountsResult = new sfdata.ArrayOfExpConfiguration();
			response_x.GetQuoteDiscountsResult.ExpConfiguration = new List<sfdata.ExpConfiguration>();
			sfdata.ExpConfiguration config = new sfdata.ExpConfiguration();
			config.ID = 1;
			config.DivisionID = 'Test';
			config.MadeChanges = false;
			config.Name = 'Test 1';
			config.Options = new sfdata.ArrayOfExpOption();
			config.Options.ExpOption = new List<sfdata.ExpOption>();
			sfdata.ExpOption option = new sfdata.ExpOption();
			option.AccentColor = 'Test'; option.acColorCode = 'Test'; option.acColorPallette = 'Test';
			option.AlternateName = 'Test'; option.BasePrice = 1.0; option.bpColorCode = 'Test';
			option.bpColorPallette = 'Test'; option.CategoryID = 'Test'; option.CM = 1.0;
			option.Collection = 'Test'; option.ColorCode = 'Test'; option.CompetitorColor = 'Test';
			option.CustombpColor = 'Test'; option.CustomfpColor = 'Test'; option.CustomtxColor = 'Test';
			option.Description = 'Test'; option.Description2 = 'Test'; option.Discount = 1.0;
			option.DiscountType = 'Test'; option.FontSize = 'Test'; option.FontType = 'Test';
			option.fpColorCode = 'Test'; option.fpColorPallette = 'Test'; option.HasContractPricing = false;
			option.HorizontalAlign = 'Test'; option.ItemNumber = '12345'; option.LetterCode = 'Test';
			option.LetterCodeCB = 'Test'; option.MountingType = 'Test'; option.NormalProductAccentColor = 'Test';
			option.Note = 'Test'; option.NoteCB = 'Test'; option.PickSequence = 1; option.Price = 1.0;
			option.ProductionType = 'Test'; option.Qty = 1.0; option.QuoteDiscountMinimumCM = 0.0;
			option.rId = 'Test'; option.txColorCode = 'Test'; option.txColorPallette = 'Test';
			option.UnitCost = 1.0; option.VerticalAlign = 'Test'; option.Yield = 100.0;
			config.Options.ExpOption.add(option);
			response_x.GetQuoteDiscountsResult.ExpConfiguration.add(config);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.EstimatingWriteConfigsJMResponse_element')
		{
			sfdata.EstimatingWriteConfigsJMResponse_element response_x = new sfdata.EstimatingWriteConfigsJMResponse_element();
			response_x.EstimatingWriteConfigsJMResult = new sfdata.Result();
			response_x.EstimatingWriteConfigsJMResult.RecordID = '';
			response_x.EstimatingWriteConfigsJMResult.Message = '';
			response_x.EstimatingWriteConfigsJMResult.Status = true;
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GetSalesRepNumberLookupResponse_element')
		{
			sfdata.GetSalesRepNumberLookupResponse_element response_x = new sfdata.GetSalesRepNumberLookupResponse_element();
			response_x.GetSalesRepNumberLookupResult = new sfdata.SalesRepNumberLookupResult();
			response_x.GetSalesRepNumberLookupResult.Message = 'Success';
			response_x.GetSalesRepNumberLookupResult.Status = true;
			response_x.GetSalesRepNumberLookupResult.SalesRepNumbers = new sfdata.ArrayOfSalesRepNumber();
			response_x.GetSalesRepNumberLookupResult.SalesRepNumbers.SalesRepNumber = new List<sfdata.SalesRepNumber>();
			sfdata.SalesRepNumber rep = new sfdata.SalesRepNumber();
			rep.Name = 'Tester';
			rep.Number_x = '12345';
			response_x.GetSalesRepNumberLookupResult.SalesRepNumbers.SalesRepNumber.add(rep);
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveFullSavedImageResponse_element')
		{
			sfdata.RetrieveFullSavedImageResponse_element response_x = new sfdata.RetrieveFullSavedImageResponse_element();
			response_x.RetrieveFullSavedImageResult = new sfdata.RetrieveSavedImagesResult();
			sfdata.RetrieveFullSavedImage_element request_x = (sfdata.RetrieveFullSavedImage_element)request;

			if (request_x.quoteNumber != null)
			{
				response_x.RetrieveFullSavedImageResult.Message = 'Success!';
				response_x.RetrieveFullSavedImageResult.Status = true;
				response_x.RetrieveFullSavedImageResult.SavedImages = new sfdata.ArrayOfSavedImage();
				response_x.RetrieveFullSavedImageResult.SavedImages.SavedImage = new List<sfdata.SavedImage>();
				sfdata.SavedImage image = new sfdata.SavedImage();
				image.AlternateId = '12345';
				image.AltName = 'Name';
				image.AltNumber = 12345;
				image.CreatedOn = System.now();
				image.FileData = 'Test data';
				image.ImageId = '12345';
				image.IsCustom = true;
				image.IsOrphaned = true;
				image.ItemNumber = '12345';
				image.Qty = 1;
				image.QuoteDetailId = '12345';
				image.QuoteId = '12345';
				image.QuoteName = 'Test';
				image.QuoteRev = 1;
	
				response_x.RetrieveFullSavedImageResult.SavedImages.SavedImage.add(image);
			}
			else{
				response_x.RetrieveFullSavedImageResult.Message = 'Error!';
				response_x.RetrieveFullSavedImageResult.Status = false;
				response_x.RetrieveFullSavedImageResult.SavedImages = new sfdata.ArrayOfSavedImage();
			}
			
			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RetrieveSavedImagesResponse_element')
		{
			sfdata.RetrieveSavedImagesResponse_element response_x = new sfdata.RetrieveSavedImagesResponse_element();
			response_x.RetrieveSavedImagesResult = new sfdata.RetrieveSavedImagesResult();
			response_x.RetrieveSavedImagesResult.Status = true;
			sfdata.RetrieveSavedImages_element request_x = (sfdata.RetrieveSavedImages_element)request;

			if (request_x.quoteNumber != null)
			{
				response_x.RetrieveSavedImagesResult.Message = 'Success!';
				response_x.RetrieveSavedImagesResult.Status = true;
				response_x.RetrieveSavedImagesResult.SavedImages = new sfdata.ArrayOfSavedImage();
				response_x.RetrieveSavedImagesResult.SavedImages.SavedImage = new List<sfdata.SavedImage>();
				sfdata.SavedImage image = new sfdata.SavedImage();
				image.AlternateId = '12345';
				image.AltName = 'Name';
				image.AltNumber = 12345;
				image.CreatedOn = System.now();
				image.FileData = 'Test data';
				image.ImageId = '12345';
				image.IsCustom = true;
				image.IsOrphaned = true;
				image.ItemNumber = '12345';
				image.Qty = 1;
				image.QuoteDetailId = '12345';
				image.QuoteId = '12345';
				image.QuoteName = 'Test';
				image.QuoteRev = 1;
	
				response_x.RetrieveSavedImagesResult.SavedImages.SavedImage.add(image);
			}
			else{
				response_x.RetrieveSavedImagesResult.Message = 'Error!';
				response_x.RetrieveSavedImagesResult.Status = false;
				response_x.RetrieveSavedImagesResult.SavedImages = new sfdata.ArrayOfSavedImage();
			}
			
			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.DeleteSavedImageResponse_element')
		{
			sfdata.DeleteSavedImageResponse_element response_x = new sfdata.DeleteSavedImageResponse_element();
			response_x.DeleteSavedImageResult = new sfdata.Result();

			sfdata.DeleteSavedImage_element request_x = (sfdata.DeleteSavedImage_element)request;

			if (request_x.imageId != '')
			{
				response_x.DeleteSavedImageResult.Message = '';
				response_x.DeleteSavedImageResult.Status = true;
				response_x.DeleteSavedImageResult.RecordID = '12345';
			}
			else{
				response_x.DeleteSavedImageResult.Message = 'Error!';
				response_x.DeleteSavedImageResult.Status = false;
				response_x.DeleteSavedImageResult.RecordID = '';
			}
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.CopySavedImageResponse_element')
		{
			sfdata.CopySavedImageResponse_element response_x = new sfdata.CopySavedImageResponse_element();
			response_x.CopySavedImageResult = new sfdata.Result();

			sfdata.CopySavedImage_element request_x = (sfdata.CopySavedImage_element)request;
			if(request_x.quoteId != null)
			{
				response_x.CopySavedImageResult.Message = '';
				response_x.CopySavedImageResult.Status = true;
				response_x.CopySavedImageResult.RecordID = '12345';
			}
			else{
				response_x.CopySavedImageResult.Message = 'Error!';
				response_x.CopySavedImageResult.Status = false;
				response_x.CopySavedImageResult.RecordID = '';
			}

			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.SaveSignsResponse_element'){
			sfdata.SaveSigns_element request_x = (sfdata.SaveSigns_element)request;
			sfdata.SaveSignsResponse_element response_x = new sfdata.SaveSignsResponse_element();
			response_x.SaveSignsResult = new sfdata.SaveSignsResult();
			if (request_x.jsonSigns != null)
			{
				response_x.SaveSignsResult.Status = true;
				response_x.SaveSignsResult.Message = '';
				response_x.SaveSignsResult.InvalidImages = false;
				response_x.SaveSignsResult.MissingData = false;
			}
			else{
				response_x.SaveSignsResult.Status = false;
				response_x.SaveSignsResult.Message = 'Error!';
				response_x.SaveSignsResult.InvalidImages = true;
				response_x.SaveSignsResult.MissingData = true;
			}
			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.EmailSignsResponse_element'){
			sfdata.EmailSigns_element request_x = (sfdata.EmailSigns_element)request;
			sfdata.EmailSignsResponse_element response_x = new sfdata.EmailSignsResponse_element();
			response_x.EmailSignsResult = new sfdata.Result();

			if (request_x.jsonSigns != null)
			{
				response_x.EmailSignsResult.Message = '';
				response_x.EmailSignsResult.RecordID = '';
				response_x.EmailSignsResult.Status = true;
			}
			else{
				response_x.EmailSignsResult.Message = 'Error!';
				response_x.EmailSignsResult.RecordID = '';
				response_x.EmailSignsResult.Status = false;
			}
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.UploadSignScheduleResponse_element')
		{
			sfdata.UploadSignSchedule_element request_x = (sfdata.UploadSignSchedule_element)request;
			sfdata.UploadSignScheduleResponse_element response_x = new sfdata.UploadSignScheduleResponse_element();
			response_x.UploadSignScheduleResult = new sfdata.UploadStatus();
			if (request_x.quoteId != null)
			{
				response_x.UploadSignScheduleResult.Message = '';
				response_x.UploadSignScheduleResult.Status = true;
			}
			else{
				response_x.UploadSignScheduleResult.Message = 'Error!';
				response_x.UploadSignScheduleResult.Status = false;
			}

			response_x.UploadSignScheduleResult.SignSchedules = new sfdata.ArrayOfSignSchedule();
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.DownloadSignScheduleResponse_element')
		{
			sfdata.DownloadSignSchedule_element request_x = (sfdata.DownloadSignSchedule_element)request;
			sfdata.DownloadSignScheduleResponse_element response_x = new sfdata.DownloadSignScheduleResponse_element();
			response_x.DownloadSignScheduleResult = new sfdata.DownloadStatus();
			if (request_x.quoteId != null)
			{
				response_x.DownloadSignScheduleResult.FileData = '{testdata}';
				response_x.DownloadSignScheduleResult.Message = '';
				response_x.DownloadSignScheduleResult.Status = true;
			}
			else{
				response_x.DownloadSignScheduleResult.FileData = '';
				response_x.DownloadSignScheduleResult.Message = 'Error!';
				response_x.DownloadSignScheduleResult.Status = false;
			}
			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.CreateSignProResponse_element')
		{
			sfdata.CreateSignPro_element request_x  = (sfdata.CreateSignPro_element)request;
			sfdata.CreateSignProResponse_element response_x = new sfdata.CreateSignProResponse_element();
			response_x.CreateSignProResult = new sfdata.DownloadStatus();
			if (request_x.quoteId != null)
			{
				response_x.CreateSignProResult.Status = true;
				response_x.CreateSignProResult.Message = '';
				response_x.CreateSignProResult.FileData = '{testdata}';
			}
			else{
				response_x.CreateSignProResult.Status = false;
				response_x.CreateSignProResult.Message = 'Error!';
			}

			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RenderSignResponse_element')
		{
			sfdata.RenderSign_element request_x = (sfdata.RenderSign_element)request;
			sfdata.RenderSignResponse_element response_x = new sfdata.RenderSignResponse_element();
			response_x.RenderSignResult = new sfdata.RenderSignResult();
			if (request_x.quoteDetailId != null && request_x.signScheduleItemId != null)
			{
				response_x.RenderSignResult.Message = '';
				response_x.RenderSignResult.Data = 'data';
				response_x.RenderSignResult.Status = true;
			}
			else{
				response_x.RenderSignResult.Message = 'Error!';
				response_x.RenderSignResult.Status = false;
			}

			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.ValidateContentWidthResponse_element')
		{
			sfdata.ValidateContentWidthResponse_element response_x = new sfdata.ValidateContentWidthResponse_element();
			response_x.ValidateContentWidthResult = new sfdata.ValidateContentWidthResult();
			response_x.ValidateContentWidthResult.Status = true;
			response_x.ValidateContentWidthResult.Valid = true;
			response_x.ValidateContentWidthResult.Message = '';
			response_x.ValidateContentWidthResult.LineWidth = 1;
			response_x.ValidateContentWidthResult.WorkableAreaWidth = 1;
			response_x.ValidateContentWidthResult.MissingPictoGram = false;
			response_x.ValidateContentWidthResult.MissingTemplate = false;
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.SaveCustomImageResponse_element')
		{
			sfdata.SaveCustomImage_element request_x = (sfdata.SaveCustomImage_element)request;
			sfdata.SaveCustomImageResponse_element response_x = new sfdata.SaveCustomImageResponse_element();
			response_x.SaveCustomImageResult = new sfdata.Result();

			if (request_x.quoteId != null)
			{
				response_x.SaveCustomImageResult.Message = '';
				response_x.SaveCustomImageResult.Status = true;
				response_x.SaveCustomImageResult.RecordID = 'record id';
			}
			else{
				response_x.SaveCustomImageResult.Message = 'Error!';
				response_x.SaveCustomImageResult.Status = false;
				response_x.SaveCustomImageResult.RecordID = '';
			}
			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.CheckCustomImagesResponse_element')
		{
			sfdata.CheckCustomImages_element request_x = (sfdata.CheckCustomImages_element)request;
			sfdata.CheckCustomImagesResponse_element response_x = new sfdata.CheckCustomImagesResponse_element();

			response_x.CheckCustomImagesResult = new sfdata.CustomImageExistsResult();
			if (request_x.quoteDetailId != null)
			{
				response_x.CheckCustomImagesResult.Message = '';
				response_x.CheckCustomImagesResult.Status = true;
				response_x.CheckCustomImagesResult.ImageId = 'image id';
				response_x.CheckCustomImagesResult.FileData = '{filedata}';
			}
			else{
				response_x.CheckCustomImagesResult.Message = '';
				response_x.CheckCustomImagesResult.Status = false;
				response_x.CheckCustomImagesResult.ImageId = '';
				response_x.CheckCustomImagesResult.FileData = '';
			}
			
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.RequestManualFreightQuoteResponse_element')
		{
			sfdata.RequestManualFreightQuoteResponse_element response_x = new sfdata.RequestManualFreightQuoteResponse_element();
			response_x.RequestManualFreightQuoteResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.UpdateManualFreightQuoteResponse_element')
		{
			sfdata.UpdateManualFreightQuoteResponse_element response_x = new sfdata.UpdateManualFreightQuoteResponse_element();
			response_x.UpdateManualFreightQuoteResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GetTerritoryIdResponse_element')
		{
			sfdata.GetTerritoryIdResponse_element response_x = new sfdata.GetTerritoryIdResponse_element();
			response_x.GetTerritoryIdResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GetTerritoryIdByCountryCodeResponse_element')
		{
			sfdata.GetTerritoryIdByCountryCodeResponse_element response_x = new sfdata.GetTerritoryIdByCountryCodeResponse_element();
			response_x.GetTerritoryIdByCountryCodeResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.SyncGPOAssociationToChildAccountsResponse_element')
		{
			sfdata.SyncGPOAssociationToChildAccountsResponse_element response_x = new sfdata.SyncGPOAssociationToChildAccountsResponse_element();
			response_x.SyncGPOAssociationToChildAccountsResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.UpsertSyncDivPriceLevelToChildAccountsResponse_element')
		{
			sfdata.UpsertSyncDivPriceLevelToChildAccountsResponse_element response_x = new sfdata.UpsertSyncDivPriceLevelToChildAccountsResponse_element();
			response_x.UpsertSyncDivPriceLevelToChildAccountsResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.SyncPriceLevelToChildAccountsResponse_element')
		{
			sfdata.SyncPriceLevelToChildAccountsResponse_element response_x = new sfdata.SyncPriceLevelToChildAccountsResponse_element();
			response_x.SyncPriceLevelToChildAccountsResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.DeleteSyncDivPriceLevelToChildAccountsResponse_element')
		{
			sfdata.DeleteSyncDivPriceLevelToChildAccountsResponse_element response_x = new sfdata.DeleteSyncDivPriceLevelToChildAccountsResponse_element();
			response_x.DeleteSyncDivPriceLevelToChildAccountsResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.UpsertSyncDivPriceLevelToChildAccountsResponse_element')
		{
			sfdata.UpsertSyncDivPriceLevelToChildAccountsResponse_element response_x = new sfdata.UpsertSyncDivPriceLevelToChildAccountsResponse_element();
			response_x.UpsertSyncDivPriceLevelToChildAccountsResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.FullPricingSyncToChildAccountsResponse_element')
		{
			sfdata.FullPricingSyncToChildAccountsResponse_element response_x = new sfdata.FullPricingSyncToChildAccountsResponse_element();
			response_x.FullPricingSyncToChildAccountsResult = 'Success';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.GetHistoricalActivitiesResponse_element')
		{
			sfdata.GetHistoricalActivitiesResponse_element response_x = new sfdata.GetHistoricalActivitiesResponse_element();
			response_x.GetHistoricalActivitiesResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.UpdateContractVersionFollowupsResponse_element')
		{
			sfdata.UpdateContractVersionFollowupsResponse_element response_x = new sfdata.UpdateContractVersionFollowupsResponse_element();
			response_x.UpdateContractVersionFollowupsResult = new sfdata.Result();
			response_x.UpdateContractVersionFollowupsResult.Message = '';
			response_x.UpdateContractVersionFollowupsResult.Status = true;
			response_x.UpdateContractVersionFollowupsResult.RecordID = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.VerifyAddressResponse_element')
		{
			sfdata.VerifyAddressResponse_element response_x = new sfdata.VerifyAddressResponse_element();
			response_x.VerifyAddressResult = new sfdata.ValidateAddressResult();
			response_x.VerifyAddressResult.Message = '';
			response_x.VerifyAddressResult.Status = false;
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.VerifyConfigurationResponse_element')
		{
			sfdata.VerifyConfigurationResponse_element response_x = new sfdata.VerifyConfigurationResponse_element();
			response_x.VerifyConfigurationResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.retrieveNetSuiteFilterValuesResponse_element')
		{
			sfdata.retrieveNetSuiteFilterValuesResponse_element response_x = new sfdata.retrieveNetSuiteFilterValuesResponse_element();
			response_x.retrieveNetSuiteFilterValuesResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.runNetSuiteSavedSearchResponse_element')
		{
			sfdata.runNetSuiteSavedSearchResponse_element response_x = new sfdata.runNetSuiteSavedSearchResponse_element();
			response_x.runNetSuiteSavedSearchResult = '';
			response.put('response_x', response_x);
		}
		else if (responseType == 'sfdata.VerifyAddressResponse_element')
		{
			sfdata.VerifyAddressResponse_element response_x = new sfdata.VerifyAddressResponse_element();
			response_x.VerifyAddressResult = new sfdata.ValidateAddressResult();
			response_x.VerifyAddressResult.Message = '';
			response_x.VerifyAddressResult.Status = true;
			response_x.VerifyAddressResult.City = 'Muskego';
			response_x.VerifyAddressResult.State = 'Wisconsin';
			response.put('response_x', response_x);
		}
		else response.put('response_x', null);
   }
}