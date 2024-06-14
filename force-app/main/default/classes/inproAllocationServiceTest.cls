@isTest
global class inproAllocationServiceTest implements WebServiceMock {
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

		if (responseType == 'inproAllocationService.calculateAllocationsResponse_element') {		
            inproAllocationService.calculateAllocationsResponse_element response_x = new inproAllocationService.calculateAllocationsResponse_element();
            inproAllocationService.calculateAllocations_element request_x = (inproAllocationService.calculateAllocations_element)request;

            response_x.CalculateAllocationsResult = new inproAllocationService.CalculateAllocationsResult();
            if (request_x.quoteId != ''){
                response_x.CalculateAllocationsResult.Message = 'Success';
                response_x.CalculateAllocationsResult.Status = true;
            }
            else {
                response_x.CalculateAllocationsResult.Status = false;
                response_x.CalculateAllocationsResult.Message = 'Test';
            }
            
            response_x.CalculateAllocationsResult.QuoteProducts = new inproAllocationService.ArrayOfQuoteProduct();
            inproAllocationService.QuoteProduct qp = new inproAllocationService.QuoteProduct();
            qp.Allocation = 1.0;
            qp.AllocationMaps = new inproAllocationService.ArrayOfAllocationMap();
            inproAllocationService.AllocationMap am = new inproAllocationService.AllocationMap();
            am.GroupNumber = 1;
            am.Image = '';
            am.SheetNumber = 1;
            qp.AllocationMaps.AllocationMap = new List<inproAllocationService.AllocationMap>();
            qp.AllocationMaps.AllocationMap.add(am);
            qp.AlternateName = '';
            qp.BackgroundColorB = 1;
            qp.BackgroundColorG = 1;
            qp.BackgroundColorR = 1;
            qp.BackSplashHeight = 1.0;
            qp.BackSplashLength = 1.0;
            qp.Color = '';
            qp.ConfigNum = 1;
            qp.CutParts = new inproAllocationService.ArrayOfCutPart();
            qp.CutParts.CutPart = new List<inproAllocationService.CutPart>();
            inproAllocationService.CutPart cp = new inproAllocationService.CutPart();
            cp.Color = '';
            cp.Description = '';
            cp.GroupId = '';
            cp.GroupNumber = 1;
            cp.H = 1.0;
            cp.Id = '';
            cp.ItemNumber = '';
            cp.PartNumber = 1;
            cp.Rotated = true;
            cp.StockNo = 1;
            cp.SubPart = false;
            cp.W = 1.0;
            cp.X = 1.0;
            cp.Y = 1.0;
            qp.CutParts.CutPart.add(cp);
            qp.Description = '';
            qp.Description2 = '';
            qp.DoubleSided = false;
            qp.EdgeBandingWidth = 1.0;
            qp.EdgeHeight = 1.0;
            qp.EdgeLeftLength = 1.0;
            qp.EdgeLength = 1.0;
            qp.EdgeRightLength = 1.0;
            qp.ExpRecordId = '';
            qp.FrontApronHeight = 1.0;
            qp.FrontApronLength = 1.0;
            qp.Group_x = 1;
            qp.GroupId = '';
            qp.Id = '';
            qp.IncludeEdgeBanding = false;
            qp.ItemNumber = '';
            qp.Length = 1.0;
            qp.NumberOfSheets = 1;
            qp.Quantity = 1.0;
            qp.SheetSize = '';
            qp.SideApronLeftHeight = 1.0;
            qp.SideApronLeftLength = 1.0;
            qp.SideApronRightHeight = 1.0;
            qp.SideApronRightLength = 1.0;
            qp.SideSplashLeftHeight = 1.0;
            qp.SideSplashLeftLength = 1.0;
            qp.SideSplashRightHeight = 1.0;
            qp.SideSplashRightLength = 1.0;
            qp.Thickness = 1.0;
            qp.TotalArea = 1.0;
            qp.Width = 1.0;
            //response_x.CalculateAllocationsResult.QuoteProducts.QuoteProduct.add(new inproAllocationService.QuoteProduct());
            response_x.CalculateAllocationsResult.QuoteProducts.QuoteProduct = new List<inproAllocationService.QuoteProduct>();
            response_x.CalculateAllocationsResult.QuoteProducts.QuoteProduct.add(qp);
            response.put('response_x', response_x); 
        }
        else response.put('response_x', null);
    }
}