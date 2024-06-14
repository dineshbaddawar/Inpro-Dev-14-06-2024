@isTest
global class datawarehouseTest implements WebServiceMock {
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

		if (responseType == 'datawarehouse.DeleteRecordResponse_element') {		
            datawarehouse.DeleteRecordResponse_element response_x = new datawarehouse.DeleteRecordResponse_element();
            response_x.DeleteRecordResult = 'Success';
			response.put('response_x', response_x); 
		}
      else if(responseType == 'sfdata.AddAccountToNetSuiteResponse_element')
		{
			sfdata.AddAccountToNetSuiteResponse_element response_x = new sfdata.AddAccountToNetSuiteResponse_element();
			response_x.AddAccountToNetSuiteResult = 'Success';
			response.put('response_x', response_x); 
		}
		else response.put('response_x', null);
   }
}