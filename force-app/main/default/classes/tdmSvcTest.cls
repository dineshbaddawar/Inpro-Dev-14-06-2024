@isTest
global class tdmSvcTest implements WebServiceMock {
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

		if (responseType == 'tdmSvc.UploadDocumentResponse_element') 	
		{
			tdmSvc.UploadDocumentResponse_element response_x = new tdmSvc.UploadDocumentResponse_element();			
            tdmSvc.JobStatus jStatus = new tdmSvc.JobStatus();
            jStatus.Message = 'Success';
            jStatus.Status = true;
            response_x.UploadDocumentResult = jStatus;
			response.put('response_x', response_x); 
		}
        else if(responseType == 'tdmSvc.DeleteAFileResponse_element')
        {
            tdmSvc.DeleteAFileResponse_element response_x = new tdmSvc.DeleteAFileResponse_element();
            tdmSvc.JobStatus jStatus = new tdmSvc.JobStatus();
            jStatus.Message = 'Success';
            jStatus.Status = true;            
            response_x.DeleteAFileResult = jStatus;
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.DownloadPDFsResponse_element')
        {
            tdmSvc.DownloadPDFsResponse_element response_x = new tdmSvc.DownloadPDFsResponse_element();
            tdmSvc.JobStatus jStatus = new tdmSvc.JobStatus();
            jStatus.Message = 'Success';
            jStatus.Status = true;
            response_x.DownloadPDFsResult = jStatus;            
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.FillTreeListResponse_element')
        {
            tdmSvc.FillTreeListResponse_element response_x = new tdmSvc.FillTreeListResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            
            response_x.FillTreeListResult = loc;            
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.FillFolder2SubFoldersResponse_element')
        {
            tdmSvc.FillFolder2SubFoldersResponse_element response_x = new tdmSvc.FillFolder2SubFoldersResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            response_x.FillFolder2SubFoldersResult = loc;            
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.FillFolder3SubFoldersResponse_element')
        {
            tdmSvc.FillFolder3SubFoldersResponse_element response_x = new tdmSvc.FillFolder3SubFoldersResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            response_x.FillFolder3SubFoldersResult = loc;            
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.FillFolder4SubFoldersResponse_element')
        {
            tdmSvc.FillFolder4SubFoldersResponse_element response_x = new tdmSvc.FillFolder4SubFoldersResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            response_x.FillFolder4SubFoldersResult= loc;            
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.FillFolder5SubFoldersResponse_element')
        {
            tdmSvc.FillFolder5SubFoldersResponse_element response_x = new tdmSvc.FillFolder5SubFoldersResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            response_x.FillFolder5SubFoldersResult = loc;            
			response.put('response_x', response_x); 
        }          
        else if(responseType == 'tdmSvc.FillFolderSubFoldersResponse_element')
        {
            tdmSvc.FillFolderSubFoldersResponse_element response_x = new tdmSvc.FillFolderSubFoldersResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            response_x.FillFolderSubFoldersResult = loc;
			response.put('response_x', response_x); 
        }     
        else if(responseType == 'tdmSvc.FillListFoldersResponse_element')
        {
            tdmSvc.FillListFoldersResponse_element response_x = new tdmSvc.FillListFoldersResponse_element();
            tdmSvc.ArrayOfLocation loc = new tdmSvc.ArrayOfLocation();
            tdmSvc.Location location = new tdmSvc.Location();
            location.FolderName = 'test';
            loc.Location  = new List<tdmSvc.Location>();
            loc.Location.add(location);
            response_x.FillListFoldersResult = loc;
			response.put('response_x', response_x); 
        }     
    }
}