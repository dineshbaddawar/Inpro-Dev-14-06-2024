@isTest
global class sfTaxTest implements WebServiceMock {
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

		if (responseType == 'sfTax.CalculateTaxResponse_element') {			
            sfTax.CalculateTax_element request_x = (sfTax.CalculateTax_element)request;
			sfTax.CalculateTaxResponse_element response_x = new sfTax.CalculateTaxResponse_element();
            response_x.CalculateTaxResult = new sfTax.CalcTaxResults();
            response_x.CalculateTaxResult.Message = '';
            response_x.CalculateTaxResult.Status = true;
            response_x.CalculateTaxResult.TaxPercent = .07;
            response_x.CalculateTaxResult.TotalFreightTax = .07;
            response_x.CalculateTaxResult.TotalTax = 12.34;
			response.put('response_x', response_x); 
		}
		else response.put('response_x', null);
   }
}