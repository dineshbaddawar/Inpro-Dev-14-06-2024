@isTest
global class EDISvcTest implements WebServiceMock {
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

		if (responseType == 'EDISvc.RetrieveXMLLineItemsResponse_element') 	
		{
			EDISvc.RetrieveXMLLineItemsResponse_element response_x = new EDISvc.RetrieveXMLLineItemsResponse_element();			
            response_x.RetrieveXMLLineItemsResult  = '';
			response.put('response_x', response_x); 
		}
        else if(responseType == 'RetrieveGraingerMacolaPartsResponse_element')
        {
            EDISvc.RetrieveGraingerMacolaPartsResponse_element response_x = new EDISvc.RetrieveGraingerMacolaPartsResponse_element();
            response_x.RetrieveGraingerMacolaPartsResult  = '';
			response.put('response_x', response_x); 
        }
        else if(responseType == 'UpdateXMLLineItemsResponse_element')
        {
            EDISvc.UpdateXMLLineItemsResponse_element response_x = new EDISvc.UpdateXMLLineItemsResponse_element();
            response_x.UpdateXMLLineItemsResult = new EDISvc.EDIJobStatus();
            response_x.UpdateXMLLineItemsResult.Status = true;
            response_x.UpdateXMLLineItemsResult.Message = '';
			response.put('response_x', response_x); 
        }
        else if(responseType == 'PriceCheckResponse_element')
        {
            EDISvc.PriceCheckResponse_element response_x = new EDISvc.PriceCheckResponse_element();
            response_x.PriceCheckResult = 12;            
			response.put('response_x', response_x); 
        }       
        else if(responseType == 'ProcessPOResponse_element')
        {
            EDISvc.ProcessPOResponse_element response_x = new EDISvc.ProcessPOResponse_element();
            response_x.ProcessPOResult = new EDISvc.EDIJobStatus();
            response_x.ProcessPOResult.Message = '';
            response_x.ProcessPOResult.Status = true;
			response.put('response_x', response_x); 
        }       
    }
}