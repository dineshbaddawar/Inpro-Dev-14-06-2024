public inherited sharing class SharePointDocumentManagementHelper {
    public SharePointDocumentManagementHelper() {
        
    }

    @AuraEnabled()
    public static string getSubRecordId(string EntityType, string SalesForceId)
    {
        if (EntityType == 'Quote')
        {
            String Id = [SELECT Id, OpportunityId FROM Quote WHERE Id = :SalesForceId LIMIT 1].OpportunityId;
            return Id;
        }
        else if (EntityType == 'Opportunity')
        {
            String ProjectNumber = [SELECT Id, Project_Number__c FROM Opportunity WHERE Id = :SalesForceId LIMIT 1].Project_Number__c;
            return ProjectNumber.replace('-','');
        }
        else if (EntityType == 'Construction_Project__c')
        {
            String ProjectNumber = [SELECT Id, Project_Number__c FROM Construction_Project__c WHERE ID = :SalesForceId LIMIT 1].Project_Number__c;
            if (ProjectNumber != null)
            {
                return ProjectNumber.replace('-','');
            }
        }
        else if (EntityType == 'Contract__c')
        {
            String OpportunityId = [SELECT Order__r.OpportunityId FROM Contract__c WHERE Id = :SalesforceId].Order__r.OpportunityId;
            return SalesForceId + ',' + OpportunityId;
        }
        return '';
    }

    @AuraEnabled()
    public static string getOnlineLibraryUrl(string EntityId, string ProjectId, Boolean IsConstructionProject)
    {
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;

        if (IsConstructionProject)
        {
            //Look for all opportunities with the same project number and grab the first one that was created
            DateTime dateValue = [SELECT Id, CreatedDate FROM Construction_Project__c WHERE Id = :EntityId LIMIT 1].CreatedDate;
            String subsiteName = dateValue.format('YYYY') + dateValue.format('MMM'); //EX: 2021Sep
            String url = service.GetOnlineLibraryUrl(subsiteName, ProjectId);
            return url;
        }
        else{
            String ProjectNumber = [SELECT Id, Project_Number__c FROM Opportunity WHERE Id = :EntityId LIMIT 1].Project_Number__c;
            Opportunity opp = [SELECT Id, CreatedDate, Construction_Project__c FROM Opportunity WHERE Id = :EntityId LIMIT 1];

            if (opp.Construction_Project__c != null){
                DateTime dateValue = [SELECT Id, CreatedDate FROM Construction_Project__c WHERE Id = :opp.Construction_Project__c LIMIT 1].CreatedDate;
                String subsiteName = dateValue.format('YYYY') + dateValue.format('MMM'); //EX: 2021Sep
                String url = service.GetOnlineLibraryUrl(subsiteName, ProjectId);
                return url;
            }
            else{
                //Look for all opportunities with the same project number and grab the first one that was created
                DateTime dateValue = opp.CreatedDate;
                String subsiteName = dateValue.format('YYYY') + dateValue.format('MMM'); //EX: 2021Sep
                String url = service.GetOnlineLibraryUrl(subsiteName, ProjectId);
                return url;
            }
        }
    }

    @AuraEnabled()
    public static string getFileModelsPrefix(string Environment, string EntityType, string SalesForceId, string Prefix)
    {
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;
        
        SharePointDocumentManagement.JobStatusRetrieve results = null;
        String MSCRM_ID = '';

        //Dynamically get value for field MSCRM_ID__c from entity, with some exceptions
        if (EntityTypeExceptionList.indexOf(EntityType) == -1)
        {
            String Query = 'SELECT Id, MSCRM_ID__c FROM ' + EntityType + ' WHERE Id = :SalesForceId LIMIT 1';
            sObject obj = Database.query(Query);
            MSCRM_ID = (String)obj.get('MSCRM_ID__c'); //External + Id for External orders
        }
           
        //Call service method and return JSONified results
        results = service.GetFileModels(Environment, Prefix + MSCRM_ID, Prefix + SalesForceId, EntityType);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string getRelatedFileModels(string Environment, string EntityType, string SalesForceId)
    {
        //String UserEmail = UserInfo.getUserEmail();
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;
        
        SharePointDocumentManagement.JobStatusRetrieve results = null;
        String MSCRM_ID = '';

        //Dynamically get value for field MSCRM_ID__c from entity, with some exceptions
        if (EntityType == 'Task')
        {
            Task task = [SELECT Id, MSCRM_ID__c, Type FROM Task WHERE Id = :SalesForceId];
            if (TaskFinanceTypeList.indexOf(task.Type) != -1)
            {
                EntityType = 'ipc_finance';
                if (task.Type == 'Credit Application')
                {
                    entityType = 'ipc_creditapplicationrequest';
                }
                results = service.GetFileModels(Environment, task.MSCRM_ID__c, SalesForceId, 'ipc_creditapplicationrequest');
            }
            else
            {
                results = service.GetFileModels(Environment, task.MSCRM_ID__c, SalesForceId, EntityType);
            }

            return JSON.serialize(results);
        }
        else if (EntityTypeExceptionList.indexOf(EntityType) == -1)
        {
            String Query = 'SELECT Id, MSCRM_ID__c FROM ' + EntityType + ' WHERE Id = :SalesForceId LIMIT 1';
            sObject obj = Database.query(Query);
            MSCRM_ID = (String)obj.get('MSCRM_ID__c');
        }
           
        //Call service method and return JSONified results
        results = service.GetRelatedFileModels(Environment, MSCRM_ID, SalesForceId, EntityType);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string getSPOFileModels(string Environment, string EntityType, string SalesForceId)
    {
        //String UserEmail = UserInfo.getUserEmail();
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;
        
        SharePointDocumentManagement.JobStatusRetrieve results = null;
           
        //Call service method and return JSONified results
        results = service.GetSPOFileModels(Environment, '', SalesForceId, EntityType);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string getFileModels(string Environment, string EntityType, string SalesForceId)
    {
        //String UserEmail = UserInfo.getUserEmail();
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;
        
        SharePointDocumentManagement.JobStatusRetrieve results = null;
        String MSCRM_ID = '';

        //Dynamically get value for field MSCRM_ID__c from entity, with some exceptions
        if (EntityTypeExceptionList.indexOf(EntityType) == -1)
        {
            String Query = 'SELECT Id, MSCRM_ID__c FROM ' + EntityType + ' WHERE Id = :SalesForceId LIMIT 1';
            sObject obj = Database.query(Query);
            MSCRM_ID = (String)obj.get('MSCRM_ID__c');
        }
           
        //Call service method and return JSONified results
        results = service.GetFileModels(Environment, MSCRM_ID, SalesForceId, EntityType);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string getLegacyFileModels(string Environment, string EntityType, string SalesForceId)
    {
        //String UserEmail = UserInfo.getUserEmail();
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;
        
        SharePointDocumentManagement.JobStatusRetrieve results = null;
        String MSCRM_ID = '';

        //Dynamically get value for field MSCRM_ID__c from entity, with some exceptions
        if (EntityTypeExceptionList.indexOf(EntityType) == -1)
        {
            String Query = 'SELECT Id, MSCRM_ID__c FROM ' + EntityType + ' WHERE Id = :SalesForceId LIMIT 1';
            sObject obj = Database.query(Query);
            MSCRM_ID = (String)obj.get('MSCRM_ID__c');
        }
           
        //Call service method and return JSONified results
        results = service.GetLegacyFileModels(Environment, MSCRM_ID, SalesForceId, EntityType);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string uploadFiles(string Environment, string EntityType, string SalesForceId, string FileIds)
    {
        String UserEmail = UserInfo.getUserEmail();

        if (UserEmail.indexOf('trafficgroup@inprocorp.com') != -1)
        {
            UserEmail = 'inprotraffic@inprocorp.com';
        }
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;

        SharePointDocumentManagement.JobStatus results = 
            service.UploadDocument(Environment, EntityType, SalesForceId, UserEmail, FileIds);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string deleteFile(string Environment, string EntityType, string EntityId, string FileName, string RelativeUrl)
    {
        String MSCRM_ID = '';
        if (EntityTypeExceptionList.indexOf(EntityType) == -1)
        {
            String Query = 'SELECT Id, MSCRM_ID__c FROM ' + EntityType + ' WHERE Id = :EntityId LIMIT 1';
            sObject obj = Database.query(Query);     
            MSCRM_ID = (String)obj.get('MSCRM_ID__c');   
        }
        
        SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
        service.timeout_x = 120000;

        String[] urlStr = RelativeUrl.split('/');
        String prefix = RelativeUrl.toLowerCase().indexOf('external' + EntityId.toLowerCase()) != -1 ? 'External' : '';
        urlStr[urlStr.size()-2] = prefix + EntityId;
        RelativeUrl = '';
        for(String str : urlStr)
        {
            RelativeUrl += str + '/';
        }
        RelativeUrl = RelativeUrl.substring(0,RelativeUrl.length()-1);

        SharePointDocumentManagement.JobStatus results = service.DeleteDocument(Environment, EntityType, MSCRM_ID, FileName, RelativeUrl);

        return JSON.serialize(results);
    }

    @AuraEnabled()
    public static string downloadFile(string Environment, string EntityType, string EntityId, string FileName, string RelativeUrl){
        try {
            String MSCRM_ID = '';
            
            if (EntityType == 'Contract_Version__c') //Special logic for this object
            {
                EntityType = 'Contract__c';
            }

            if (EntityTypeExceptionList.indexOf(EntityType) == -1)
            {
                String Query = 'SELECT Id, MSCRM_ID__c FROM ' + EntityType + ' WHERE Id = :EntityId LIMIT 1';
                sObject obj = Database.query(Query);     
                MSCRM_ID = (String)obj.get('MSCRM_ID__c');   
            }

            SharePointDocumentManagement.SharePointDocumentServiceSoap service = new SharePointDocumentManagement.SharePointDocumentServiceSoap();
            service.timeout_x = 120000;
            SharePointDocumentManagement.SPFile file = service.DownloadDocument(Environment, EntityId, MSCRM_ID, EntityType, FileName, RelativeUrl);
            
            return JSON.serialize(file);
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    private static List<string> EntityTypeExceptionList = new List<string>{
        'Lead',
        'Illustrator_Design_Request__c',
        'Order_Request__c',
        'Estimating'
    };

    private static List<string> TaskFinanceTypeList = new List<string>{
        'Unearned Discount',
        'Lien Waiver',
        'Past Due Invoice',
        'Refund Request',
        'Pay Application',
        'Important Note',
        '3rd Party Collections',
        'Sales Tax Issue',
        'Business Report',
        'Credit Application',
        'Freight Issue',
        'Bad Debt',
        'Advance Bill',
        'Credit Card Payment'
    };
}