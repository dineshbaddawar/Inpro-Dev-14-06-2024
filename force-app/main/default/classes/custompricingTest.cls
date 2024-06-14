@isTest
global class custompricingTest implements WebServiceMock {
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

		if (responseType == 'custompricing.SubmitCustomPricingActivitiesResponse_element') {		
            custompricing.SubmitCustomPricingActivitiesResponse_element response_x = new custompricing.SubmitCustomPricingActivitiesResponse_element();

            response_x.SubmitCustomPricingActivitiesResult = new custompricing.Result();
            response_x.SubmitCustomPricingActivitiesResult.Message = 'Activity Completed Successfully.';
            response_x.SubmitCustomPricingActivitiesResult.Status = true;

            response.put('response_x', response_x); 
        }
        else if (responseType == 'custompricing.CreateCustomPricingActivitiesResponse_element')
        {
            custompricing.CreateCustomPricingActivitiesResponse_element response_x = new custompricing.CreateCustomPricingActivitiesResponse_element();
            response_x.CreateCustomPricingActivitiesResult = new custompricing.Result();
            response_x.CreateCustomPricingActivitiesResult.Message = 'Activities Completed Successfully.';
            response_x.CreateCustomPricingActivitiesResult.Status = true;

            response.put('response_x', response_x); 
        }
        ////
        else if (responseType == 'sfdata.GetEDIHeadersResponse_element')
		{
			sfdata.GetEDIHeadersResponse_element response_x = new sfdata.GetEDIHeadersResponse_element();
			response_x.GetEDIHeadersResult = new sfdata.ArrayOfString();
			response_x.GetEDIHeadersResult.string_x = new List<String>();
			response_x.GetEDIHeadersResult.string_x.add('test');
			response.put('response_x', response_x); 
		}
        ////
        else response.put('response_x', null);
    }
}