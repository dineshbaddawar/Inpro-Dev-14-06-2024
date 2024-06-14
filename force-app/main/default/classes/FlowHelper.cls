global with sharing class FlowHelper {
    @invocablemethod
    public static void UploadFiles(List<FileDTO> FileList)
    {
        string Environment = URL.getSalesforceBaseUrl().toExternalForm(); 
        //https://inprocorporation2019--beta.my.salesforce.com
        //'inprocorporation2019--beta.lightning.force.com';
        if(Environment.contains('beta'))
        {
            Environment = 'inprocorporation2019--beta.lightning.force.com';
        }
        else {
            Environment = 'inprocorporation2019.lightning.force.com';
        }
        string EntityType = FileList[0].EntityType;
        string SalesForceId = FileList[0].RecordId;        

        List<FileUploadDTO> fileUploadList = new List<FileUploadDTO>();
        List<string> fileIds = FileList[0].FileId.split(';');
        List<Id> Ids = new List<Id>();
       for (string s : fileIds) {
           Ids.add(s);
       }

       string Query = 'SELECT contentdocument.id, FileExtension, ContentDocument.Title FROM ContentVersion where contentdocument.id in :Ids';
       List<ContentVersion> contentList = Database.query(Query);
        
        for (ContentVersion file : contentList) {
            FileUploadDTO f = new FileUploadDTO();
            f.Id = file.ContentDocument.id;
            f.Name = file.ContentDocument.Title + '.' + file.FileExtension;
            fileUploadList.add(f);
        }

        string fileJSON = '';
        if (fileUploadList.size() > 0) {
            fileJSON = JSON.serialize(fileUploadList);
        }

        SharePointDocumentManagementHelper.uploadFiles(Environment, EntityType, SalesForceId, fileJSON);
    }    

    global class FileDTO {
        @InvocableVariable
        global string FileId;
    
        @InvocableVariable
        global ID RecordId;
    
        @InvocableVariable
        global string FileName;

        @InvocableVariable
        global string EntityType;
      }

      public class FileUploadDTO
      {
        public string Id;
        public string Name;
      }
}