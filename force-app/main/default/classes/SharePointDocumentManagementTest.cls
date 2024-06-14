@isTest
global class SharePointDocumentManagementTest implements WebServiceMock {
   global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) 
        // start - specify the response you want to send
        // calculatorServices.doAddResponse response_x = 
        //     new calculatorServices.doAddResponse();
		// response_x.return_x = 3.0;

    {
        if (responseType == 'SharePointDocumentManagement.DownloadDocumentResponse_element') {			
    
            SharePointDocumentManagement.DownloadDocumentResponse_element response_x = 
                new SharePointDocumentManagement.DownloadDocumentResponse_element();
            
            SharePointDocumentManagement.SPFile results = new SharePointDocumentManagement.SPFile();
            results.Created = Datetime.now();
            results.CreatedBy = 'Tester';
            results.FileContents = 'x';
            results.FileName = 'File';
            results.Modified = Datetime.now();
            results.ModifiedBy = 'Tester';
            results.RelativeUrl = 'test.url';
            results.Selected = false;
            response_x.DownloadDocumentResult = results;
            // end
            response.put('response_x', response_x); 
        }
        else if (responseType == 'SharePointDocumentManagement.GetRelatedFileModelsResponse_element') {			
    
            SharePointDocumentManagement.GetRelatedFileModelsResponse_element response_x = 
            new SharePointDocumentManagement.GetRelatedFileModelsResponse_element();
            SharePointDocumentManagement.ArrayOfSPOFile data = new SharePointDocumentManagement.ArrayOfSPOFile();
            
            SharePointDocumentManagement.SPOFile file = new SharePointDocumentManagement.SPOFile();
            file.CreatedOn = '12/01/21';
            file.CreatedBy = 'Tester';
            file.DocumentType = 'csv';
            file.Name = 'File';
            file.ModifiedOn = '12/01/21';
            file.ModifiedBy = 'Tester';
            file.ServerURL = 'test.url';
            file.Id = '1';

            data.SPOFile = new List<SharePointDocumentManagement.SPOFile>();
            data.SPOFile.add(file);
            
            SharePointDocumentManagement.JobStatusRetrieve results = new SharePointDocumentManagement.JobStatusRetrieve();
            results.Status = true;
            results.Message = 'Success';
            results.SPOFileList = data;
            response_x.GetRelatedFileModelsResult = results;
            // end
            response.put('response_x', response_x); 
        }
        else if (responseType == 'SharePointDocumentManagement.GetFileModelsResponse_element')
        {
            SharePointDocumentManagement.GetFileModelsResponse_element response_x = 
            new SharePointDocumentManagement.GetFileModelsResponse_element();
            SharePointDocumentManagement.ArrayOfSPOFile data = new SharePointDocumentManagement.ArrayOfSPOFile();
            
            SharePointDocumentManagement.SPOFile file = new SharePointDocumentManagement.SPOFile();
            file.CreatedOn = '12/01/21';
            file.CreatedBy = 'Tester';
            file.DocumentType = 'csv';
            file.Name = 'File';
            file.ModifiedOn = '12/01/21';
            file.ModifiedBy = 'Tester';
            file.ServerURL = 'test.url';
            file.Id = '1';

            data.SPOFile = new List<SharePointDocumentManagement.SPOFile>();
            data.SPOFile.add(file);
            
            SharePointDocumentManagement.JobStatusRetrieve results = new SharePointDocumentManagement.JobStatusRetrieve();
            results.Status = true;
            results.Message = 'Success';
            results.SPOFileList = data;
            response_x.GetFileModelsResult = results;
            // end
            response.put('response_x', response_x); 
        }
        else if (responseType == 'SharePointDocumentManagement.UploadDocumentResponse_element')
        {
            SharePointDocumentManagement.UploadDocumentResponse_element response_x = 
            new SharePointDocumentManagement.UploadDocumentResponse_element();
            
            SharePointDocumentManagement.JobStatus results = new SharePointDocumentManagement.JobStatus();
            results.Message = 'Test upload success';
            results.Status = true;

            response_x.UploadDocumentResult = results;
            // end
            response.put('response_x', response_x); 
        }
        else if (responseType == 'SharePointDocumentManagement.DeleteDocumentResponse_element')
        {
            SharePointDocumentManagement.DeleteDocumentResponse_element response_x = 
            new SharePointDocumentManagement.DeleteDocumentResponse_element();
            
            SharePointDocumentManagement.JobStatus results = new SharePointDocumentManagement.JobStatus();
            results.Message = 'Test delete success';
            results.Status = true;

            response_x.DeleteDocumentResult = results;
            // end
            response.put('response_x', response_x); 
        }
        else if (responseType == 'SharePointDocumentManagement.GetOnlineLibraryUrlResponse_element')
        {
            SharePointDocumentManagement.GetOnlineLibraryUrlResponse_element response_x =
            new SharePointDocumentManagement.GetOnlineLibraryUrlResponse_element();

            response_x.GetOnlineLibraryUrlResult = 'https://test.com/';
            response.put('response_x', response_x);
        }
    }
}