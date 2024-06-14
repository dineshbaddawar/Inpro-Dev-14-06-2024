@isTest
global class InproRCATest implements WebServiceMock {
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

		if (responseType == 'InproRCA.SubmitRCAResponse_element') {		
            InproRCA.SubmitRCAResponse_element response_x = new InproRCA.SubmitRCAResponse_element();
            response_x.SubmitRCAResult = 'Success';
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.RetrieveRCANumberResponse_element') {		
            InproRCA.RetrieveRCANumberResponse_element response_x = new InproRCA.RetrieveRCANumberResponse_element();
            response_x.RetrieveRCANumberResult = new InproRCA.RetrieveRCANumberResult();
            response_x.RetrieveRCANumberResult.RCANumber = 12345;
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.SendRCAToNetSuiteResponse_element') {		
            InproRCA.SendRCAToNetSuiteResponse_element response_x = new InproRCA.SendRCAToNetSuiteResponse_element();
            response_x.SendRCAToNetSuiteResult = 'Success';
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.ApproveRCARequestResponse_element') {		
            InproRCA.ApproveRCARequestResponse_element response_x = new InproRCA.ApproveRCARequestResponse_element();
            response_x.ApproveRCARequestResult = 'Success';
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.CreateRCARecordFromStagingResponse_element') {		
            InproRCA.CreateRCARecordFromStagingResponse_element response_x = new InproRCA.CreateRCARecordFromStagingResponse_element();
            response_x.CreateRCARecordFromStagingResult = new InproRCA.JobStatus();
            response_x.CreateRCARecordFromStagingResult.Status = true;
            response_x.CreateRCARecordFromStagingResult.Message = 'Success';
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.CreateRCAFromSalesforceResponse_element') {		
            InproRCA.CreateRCAFromSalesforceResponse_element response_x = new InproRCA.CreateRCAFromSalesforceResponse_element();
            response_x.CreateRCAFromSalesforceResult = 'Success';
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.RejectRCARequestResponse_element') {		
            InproRCA.RejectRCARequestResponse_element response_x = new InproRCA.RejectRCARequestResponse_element();
            response_x.RejectRCARequestResult = 'Success';
            response.put('response_x', response_x);
        }
        else if (responseType == 'InproRCA.RetrieveOrderTaxResponse_element') {		
            InproRCA.RetrieveOrderTaxResponse_element response_x = new InproRCA.RetrieveOrderTaxResponse_element();
            response_x.RetrieveOrderTaxResult = new InproRCA.RetrieveOrderTaxResult();
            response_x.RetrieveOrderTaxResult.Tax = 0.65;
            response.put('response_x', response_x);
        }
        else response.put('response_x', null);
    }
}