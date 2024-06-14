@isTest
global class sfExpediteTest implements WebServiceMock {
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

            if (responseType == 'sfExpedite.UpdateExpeditePartNumberInNetSuiteResponse_element') 	
            {
                sfExpedite.UpdateExpeditePartNumberInNetSuiteResponse_element response_x = new sfExpedite.UpdateExpeditePartNumberInNetSuiteResponse_element();
                response.put('response_x', response_x); 
            }
            else if (responseType == 'sfExpedite.UpdateSupplierOptionInNetSuiteResponse_element')
            {
                sfExpedite.UpdateSupplierOptionInNetSuiteResponse_element response_x = new sfExpedite.UpdateSupplierOptionInNetSuiteResponse_element();
                response.put('response_x', response_x); 
            }
        }           
}