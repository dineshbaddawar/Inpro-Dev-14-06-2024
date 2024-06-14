public with sharing class TDMHelper {
    
    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> UserSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:user';
        List<User> users = [SELECT Id, Name, Email FROM User WHERE Name LIKE :key LIMIT 50];

        for (User user : users) {

            String fullname = user.Name;
            String id = user.Id;
            String subtitle = user.Email;
                
            results.add(new LookupSearchResult(id, 'user', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> EmployeeSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:user';

        List<Employee__c> employees = [SELECT Id,  Name, Email__c FROM Employee__c WHERE Active__c = true AND Name LIKE :key LIMIT 50];

        for (Employee__c employee : employees) {

            String fullname = employee.Name;
            String id = employee.Id;
            String subtitle = employee.Email__c;
                
            results.add(new LookupSearchResult(id, 'Employee__c', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }   

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> CampaignSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:user';
        

        List<Campaign> campaigns = [SELECT Id,  Name, Description FROM Campaign WHERE Name LIKE :key LIMIT 50];

        for (Campaign campaign : campaigns) {

            String fullname = campaign.Name;
            String id = campaign.Id;

            String subtitle = '';
            if (campaign.Description != null)
                subtitle = campaign.Description;

                
            results.add(new LookupSearchResult(id, 'Campaign', icon, fullname, '', subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> LanguageSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        String key = '%' + searchTerm + '%';
        List <LookupSearchResult> results = new List < LookupSearchResult > ();
        String icon = 'standard:user';
        

        List<Technical_Document_Language__c> languages = [SELECT Id,  Name FROM Technical_Document_Language__c WHERE Name LIKE :key LIMIT 50];

        for (Technical_Document_Language__c language : languages) {

            String fullname = language.Name;
            String id = language.Id;
            String subtitle = '';
                
            results.add(new LookupSearchResult(id, 'Technical_Document_Language__c', icon, fullname, subtitle, ''));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static Technical_Document_Language__c getDefaultLanaguage()
    {
        return [SELECT Id,  Name FROM Technical_Document_Language__c WHERE Name = 'English' limit 1];
    }

    @AuraEnabled(Cacheable = true)
    public static Technical_Document_Region__c getDefaultRegion()
    {
        return [SELECT Id,  Name FROM Technical_Document_Region__c WHERE Name = 'US & Canada' limit 1];
    }

    @AuraEnabled(Cacheable = true)
    public static List<Technical_Document_Product_Series__c> getSeries(){                         
        List<Technical_Document_Product_Series__c> series =  [SELECT Name,Id FROM Technical_Document_Product_Series__c ORDER BY Name];
        return series;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Technical_Document_Product_Category__c> getCategories(){                         
        List<Technical_Document_Product_Category__c> categories =  [SELECT Name, Id FROM Technical_Document_Product_Category__c ORDER BY Name];
        return categories;
    }    

    @AuraEnabled(Cacheable = true)
    public static List<String> GetMarketSegments(){          
        
        return new List<String>{
            'Commercial Office',
            'Education',
            'Entertainment',
            'Government (Non VA)',
            'Healthcare',
            'Hospitality',
            'Industrial',
            'Interior Design Firm',
            'Maritime Industries',
            'Mixed Use',
            'Multifamily',
            'Religious Organization',
            'Residential',
            'Restaurant',
            'Retail',
            'Transit'
        };
    }

    @AuraEnabled(Cacheable = true)
    public static List<String> GetDivisions(){ 
        return new List<String>{
            'AD',
            'CZ',
            'IPC',
            'EN',
            'Inpro',
            'Interiors',
            'JM',
            'SS'
        };
    }

    @AuraEnabled(Cacheable = true)
    public static List<Technical_Document_Region__c> GetRegions(){                         
        List<Technical_Document_Region__c> regions =  [SELECT Name FROM Technical_Document_Region__c LIMIT 50];
        return regions;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Technical_Document_Type__c> GetDocumentTypes(){                         
        List<Technical_Document_Type__c> documentTypes =  [SELECT Id, Name FROM Technical_Document_Type__c ORDER BY Name LIMIT 50 ];
        return documentTypes;
    }

    @AuraEnabled()
    public static string createDocument(string documentControl, string publishedName, string documentOwner, string requestor, string documentType, string division, string language, 
                                        string marketSegment, string campaign, string regions, string description, string sampleItemNo)
    {
        Technical_Document__c techDoc = new Technical_Document__c();
        techDoc.Document_Control__c = documentControl;        
        techDoc.Name = publishedName;
        techDoc.Document_Owner__c = documentOwner;
        techDoc.Technical_Document_Type__c = documentType;
        techDoc.OwnerId = requestor;
        techDoc.Division__c = division;
        if(language != null && language != '')
        techDoc.Technical_Document_Language__c = language;    
        if(marketSegment != null && marketSegment != '')
        techdoc.Market_Segment__c = marketSegment;
        if(campaign != null && campaign != '')
        techdoc.Campaign__c = campaign;
        techDoc.Description__c = description;
        //techDoc.sampleItemNo = sampleItemNo;
        if(documentControl == 'Uncontrolled')   
        {     
            techDoc.Status__c = 'Active';        
            integer Index = GetNextISONumber(documentControl, documentType);
            techDoc.ISO_Index__c = Index;
            techDoc.ISO_Number__c = 'UD'+Index;
            techDoc.Current_Revision__c = '1';
        }
        else 
            techDoc.Status__c = 'Pending';
        
        insert techDoc;

        // Technical_Document_Revision__c revision = new Technical_Document_Revision__c();
        // if(documentControl == 'Uncontrolled')
        // {            
        //     revision.Major_Revision__c = 1;
        //     if(isUserEditor())
        //     revision.Status__c = 'Approved';
        //     else
        //     revision.Status__c = 'Pending Approval';
        //     revision.Technical_Document__c = techDoc.Id;
        //     revision.Revision_Type__c = 'Major';
        //     revision.Release_Date__c = Datetime.now();   
        //     revision.Name = 'Rev 1'; 
        //     insert revision;
        // }

        if(regions != null && regions != '')
        {
            
            List<Tech_Doc_Document_Region__c> techDocRegions = new List<Tech_Doc_Document_Region__c>();
            List<string> regionIds = regions.split(',');
            for (string regionId : regionIds) {
                Tech_Doc_Document_Region__c techDocRegion = new Tech_Doc_Document_Region__c();
                techDocRegion.Technical_Document__c = techDoc.Id;
                techDocRegion.Technical_Document_Region__c = regionId;
                techDocRegion.Name = publishedName + ' Region';
                techDocRegions.add(techDocRegion);
            }

            insert techDocRegions;
        }
        if(documentControl == 'Uncontrolled')
            return techDoc.Id;
        else {
            
            String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + techDoc.Id;                         
            String Body = 'New Document Approval: '+techDoc.Name+' <br/><br/>' + 'Description: ' + description + '<br/><br/>' + 
                        '<a style=\"font-size:14px\" href=\"' + recordUrl + '\">Record Link</a>'; 
            EmailSendHelper.sendEmailMultipleRecipients(getTDMAdmins(), 'dsieraski@inprocorp.com', 'New Document To Approve', Body);
            return techDoc.Id;
        }
    }

    @AuraEnabled()
    public static string createRevision(string documentId, string type, string changeDetail)
    {
        if(isRevisionPending(documentId))
            return 'A revision is already pending approval.';

        Technical_Document__c currentDoc = new Technical_Document__c();
        currentDoc.Id = documentId;

        Technical_Document__c techDoc = getDocument(documentId);
        Technical_Document_Revision__c currentRev = getActiveRevision(documentId);

        Decimal majorRev = 0;        
        if(currentRev != null && currentRev.Major_Revision__c != null)
            majorRev = currentRev.Major_Revision__c;

        string minorRev = '';
        if(currentRev != null && currentRev.Minor_Revision__c != null)
            minorRev = currentRev.Minor_Revision__c;       

        Technical_Document_Revision__c revision = new Technical_Document_Revision__c();
         
        if(type == 'Major')
        {
           revision.Major_Revision__c = majorRev + 1;
           revision.Minor_Revision__c = '';
        }
        else if (type =='Minor')
        {
           String character = 'A'; 
           if(minorRev != null && minorRev != '')                
           {
               character = minorRev;
               Integer[] ASCIINumericRepresentation = character.getChars(); // [65]
               character = String.fromCharArray(new List<Integer> {ASCIINumericRepresentation[0] + 1}); // 66 = 'B'
           }
           
           revision.Minor_Revision__c = character;        
           revision.Major_Revision__c = majorRev;        
        }

        revision.Technical_Document__c = documentId;
        revision.Revision_Type__c = type;
        revision.Name = 'Rev ' + revision.Major_Revision__c + revision.Minor_Revision__c; 
        revision.Change_Details__c = changeDetail;

         if (techDoc.Document_Control__c == 'Uncontrolled' && isUserEditor())                  
         { 
            revision.Status__c = 'Approved';  
            currentDoc.Current_Revision__c = revision.Major_Revision__c + revision.Minor_Revision__c;
            update currentDoc;

            if(currentRev != null)
            {
                Technical_Document_Revision__c oldRev = new Technical_Document_Revision__c();
                oldRev.Id = currentRev.Id;
                oldRev.Status__c = 'Revised';
                update oldRev;
            }

            revision.Release_Date__c = Datetime.now();
         }
         else 
            revision.Status__c = 'Pending Approval';

        insert revision;

        if (techDoc.Document_Control__c == 'Controlled')                  
         { 
            String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + revision.Id;                         
                        String Body = 'New Revision for '+techDoc.Name+' <br/><br/>' + 'Details: ' + changeDetail + '<br/><br/>' + 
                                    '<a style=\"font-size:14px\" href=\"' + recordUrl + '\">Record Link</a>'; 
            EmailSendHelper.sendEmailMultipleRecipients(getTDMAdmins(), 'dsieraski@inprocorp.com', 'New Revision To Approve', Body);
         }

        return revision.Id;
    }

    private static Boolean isRevisionPending(string documentId)
    {
        List<Technical_Document_Revision__c> revisions = [SELECT Id, Technical_Document__c
        FROM Technical_Document_Revision__c
        WHERE Technical_Document__c = :documentId
        AND Status__c = 'Pending Approval' LIMIT 1];

        if(revisions.size() > 0)
        return true;
        else return false;
    }

    private static Technical_Document_Revision__c getActiveRevision(string documentId)
    {
        List<Technical_Document_Revision__c> revisions = [SELECT Id, Technical_Document__c,  Major_Revision__c, Minor_Revision__c
        FROM Technical_Document_Revision__c
        WHERE Technical_Document__c = :documentId
        AND Status__c = 'Approved' LIMIT 1];

        if(revisions != null && revisions.size() > 0)
        return revisions[0];
        else return null;
    }

    private static Technical_Document__c getDocument(string documentId)
    {
       List<Technical_Document__c> techDocs = [SELECT Campaign__c, CreatedById, CreatedDate, CurrencyIsoCode, Current_Revision__c, 
                Description__c, Division__c, Document_Control__c, Document_Owner__c, ISO_Index__c, 
                ISO_Number__c, Id, Image_Name__c, Image__c, IsDeleted, LastModifiedById, LastModifiedDate, 
                LastReferencedDate, LastViewedDate, MSCRM_ID__c, Market_Segment__c, Name, Notes__c, OwnerId, Parent_Document__c,
                 Status__c, SystemModstamp, Technical_Document_Language__c, Technical_Document_Name__c, Technical_Document_Type__c
        FROM Technical_Document__c
        WHERE Id = :documentId LIMIT 1];
        return techDocs[0];
    }

    @AuraEnabled()
    public static List<Technical_Document_Publish_Set__c> getOrphanedPublishSets(string documentId)
    {
        String sObjName = ((Id)documentId).getSObjectType().getDescribe().getName();  
        List<Technical_Document_Publish_Set__c> pubSets = null;
        
        if(sObjName == 'Technical_Document__c')
        {
         pubSets = [SELECT Status__c, Id, Name, Technical_Document_File__c, Location__c, Revision_Date__c,
                SharePoint_Site_Url__c, Technical_Document_PDF_Portal_Category__c,Technical_Document_PDF_Portal_Category__r.Name, Technical_Document_Revision__c,
                    Technical_Document__c, Web_Friendly_Name__c, CreatedDate
            FROM Technical_Document_Publish_Set__c
            WHERE Status__c = 'Active' AND 
            Technical_Document__c = :documentId AND
            Technical_Document_File__r.Technical_Document_Revision__r.Status__c != 'Approved'];
        }
        else {

            string revisionId = documentId;
            documentId = [SELECT Technical_Document__c FROM Technical_Document_Revision__c WHERE Id = :revisionId limit 1].Technical_Document__c;

            pubSets = [SELECT Status__c, Id, Name, Technical_Document_File__c, Location__c, Revision_Date__c,
                SharePoint_Site_Url__c, Technical_Document_PDF_Portal_Category__c,Technical_Document_PDF_Portal_Category__r.Name, Technical_Document_Revision__c,
                    Technical_Document__c, Web_Friendly_Name__c, CreatedDate
            FROM Technical_Document_Publish_Set__c
            WHERE Status__c = 'Active' AND 
            Technical_Document__c = :documentId AND
            Technical_Document_File__r.Technical_Document_Revision__r.Status__c = 'Approved'];
        }
            return pubSets;
    }

    @AuraEnabled()
    public static string updatePublishSets(List<Technical_Document_Publish_Set__c> publishSets)
    {
        if(isUserEditor())
        { 
            List<Technical_Document_Publish_Set__c> pubSetsToUpdate = new List<Technical_Document_Publish_Set__c>();
            List<Tech_Doc_Product_Category_Publish_Set__c> categoriesToCreate = new List<Tech_Doc_Product_Category_Publish_Set__c>();
            List<Tech_Doc_Product_Series_Publish_Set__c> seriesToCreate = new List<Tech_Doc_Product_Series_Publish_Set__c>();       

                for (Technical_Document_Publish_Set__c ps : publishSets) {
                    Technical_Document_Publish_Set__c newPS = new Technical_Document_Publish_Set__c();
                    Technical_Document_Publish_Set__c oldPS = new Technical_Document_Publish_Set__c();
                    if(ps.Status__c == 'Active')
                    {
                        Technical_Document_Publish_Set__c existingPS =  [SELECT
                        Location__c, 
                        Technical_Document__c,
                        Status__c, 
                        Id,
                        Name,
                        SharePoint_Site_Url__c,
                        Technical_Document_File__c,
                        Technical_Document_File__r.Name,
                        Technical_Document_File__r.Id,
                        Technical_Document__r.Name,
                        Web_Friendly_Name__c, Revision_Date__c,
                        Technical_Document_PDF_Portal_Category__c
                        FROM Technical_Document_Publish_Set__c
                        WHERE Id = :ps.Id LIMIT 1];

                        newPS = existingPS.clone(false, true, false, false);
                        newPS.Technical_Document_File__c = ps.Technical_Document_File__c;
                        newPS.Status__c = 'Active';
                        newPS.Technical_Document_PDF_Portal_Category__c = existingPS.Technical_Document_PDF_Portal_Category__c;
                        // newPS.Technical_Document_File__c = ps.Technical_Document_File__c;
                        // newPS.Location__c = existingPS.Location__c;
                        // newPS.Technical_Document__c = existingPS.Technical_Document__c;
                        // newPS.SharePoint_Site_Url__c = existingPS.SharePoint_Site_Url__c;
                        // newPS.Web_Friendly_Name__c = existingPS.Web_Friendly_Name__c;
                        newPS.Revision_Date__c = Datetime.now();
                        insert newPS;

                        List<Tech_Doc_Product_Category_Publish_Set__c> productCategories =
                        [SELECT Technical_Document_Publish_Set__c, Id, Technical_Document_Product_Category__c
                        FROM Tech_Doc_Product_Category_Publish_Set__c
                        WHERE Technical_Document_Publish_Set__c = :ps.Id];

                        if(productCategories != null && productCategories.size() > 0)
                            for (Tech_Doc_Product_Category_Publish_Set__c category : productCategories) {

                                Tech_Doc_Product_Category_Publish_Set__c cat = new Tech_Doc_Product_Category_Publish_Set__c();                        
                                cat.Technical_Document_Publish_Set__c = newPS.Id; 
                                cat.Technical_Document_Product_Category__c = category.Technical_Document_Product_Category__c;
                                categoriesToCreate.add(cat);
                            }

                        List<Tech_Doc_Product_Series_Publish_Set__c> productSeries = 
                        [SELECT Technical_Document_Publish_Set__c, Id, Technical_Document_Product_Series__c
                        FROM Tech_Doc_Product_Series_Publish_Set__c
                        WHERE Technical_Document_Publish_Set__c = :ps.Id];

                        if(productSeries != null && productSeries.size() > 0)
                            for (Tech_Doc_Product_Series_Publish_Set__c series : productSeries) {

                                Tech_Doc_Product_Series_Publish_Set__c ser = new Tech_Doc_Product_Series_Publish_Set__c();
                                ser.Technical_Document_Publish_Set__c = newPS.Id;
                                ser.Technical_Document_Product_Series__c = series.Technical_Document_Product_Series__c;
                                seriesToCreate.add(ser);
                            }
                    }
                    oldPS.Revision_Date__c = Datetime.now();
                    oldPS.Status__c = 'Inactive';
                    oldPS.Id = ps.Id;
                    pubSetsToUpdate.add(oldPS);
                }
                
                update pubSetsToUpdate;
                insert seriesToCreate;
                insert categoriesToCreate;

       
            return 'Success';
        }
        else return 'Permission Denied';
    }

    @AuraEnabled(Cacheable = true)
    public static List<Technical_Document_PDF_Portal_Category__c> getPdfPortalCategories(){                         
        List<Technical_Document_PDF_Portal_Category__c> categories =  [SELECT Name,Id FROM Technical_Document_PDF_Portal_Category__c ORDER BY Name];
        return categories;
    }

    public static Integer GetNextISONumber(string documentControl, string documentType)
    {
        if(documentControl == 'Uncontrolled')
        {
            return Math.Round([SELECT ISO_Index__c
                FROM Technical_Document__c
                WHERE Document_Control__c = 'Uncontrolled' and ISO_Index__c != null        
                ORDER BY ISO_Index__c DESC LIMIT 1].ISO_Index__c + 1);
        }
        else {
            return Math.Round( [SELECT ISO_Index__c
                FROM Technical_Document__c
                WHERE Document_Control__c = 'Controlled' and ISO_Index__c != null
                AND Technical_Document_Type__c = :documentType
                ORDER BY ISO_Index__c DESC LIMIT 1].ISO_Index__c + 1);
        }
    }

    @AuraEnabled()
    public static string FillTree()
    {
        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillTreeList('url'));
    }

    @AuraEnabled()
    public static string FillListFolders(Location location)
    {        
        tdmSvc.Location loc = new tdmSvc.Location();
        loc.ListTitle = location.ListTitle;

        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillListFolders(loc, 'url'));
    }

    @AuraEnabled()
    public static string FillListSubFolders(Location location)
    {        
        tdmSvc.Location loc = new tdmSvc.Location();
        loc.ListTitle = location.ListTitle;
        loc.FolderName = location.FolderName;
        loc.SubFolderName = location.SubFolderName;        

        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillFolderSubFolders(loc, 'url'));
    }

    @AuraEnabled()
    public static string FillList2SubFolders(Location location)
    {        
        tdmSvc.Location loc = new tdmSvc.Location();
        loc.ListTitle = location.ListTitle;
        loc.FolderName = location.FolderName;
        loc.SubFolderName = location.SubFolderName;        
        loc.SubFolderName2 = location.SubFolderName2;
        loc.SubFolderName3 = location.SubFolderName3;

        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillFolder2SubFolders(loc, 'url'));
    }

    @AuraEnabled()
    public static string FillList3SubFolders(Location location)
    {        
        tdmSvc.Location loc = new tdmSvc.Location();
        loc.ListTitle = location.ListTitle;
        loc.FolderName = location.FolderName;
        loc.SubFolderName = location.SubFolderName;        
        loc.SubFolderName2 = location.SubFolderName2;
        loc.SubFolderName3 = location.SubFolderName3;
        loc.SubFolderName4 = location.SubFolderName4;
        loc.SubFolderName5 = location.SubFolderName5;

        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillFolder3SubFolders(loc, 'url'));
    }

    @AuraEnabled()
    public static string FillList4SubFolders(Location location)
    {        
        tdmSvc.Location loc = new tdmSvc.Location();
        loc.ListTitle = location.ListTitle;
        loc.FolderName = location.FolderName;
        loc.SubFolderName = location.SubFolderName;        
        loc.SubFolderName2 = location.SubFolderName2;
        loc.SubFolderName3 = location.SubFolderName3;
        loc.SubFolderName4 = location.SubFolderName4;
        loc.SubFolderName5 = location.SubFolderName5;
        loc.SubFolderName6 = location.SubFolderName6;
        loc.SubFolderName7 = location.SubFolderName7;

        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillFolder4SubFolders(loc, 'url'));
    }

    @AuraEnabled()
    public static string FillList5SubFolders(Location location)
    {        
        tdmSvc.Location loc = new tdmSvc.Location();
        loc.ListTitle = location.ListTitle;
        loc.FolderName = location.FolderName;
        loc.SubFolderName = location.SubFolderName;        
        loc.SubFolderName2 = location.SubFolderName2;
        loc.SubFolderName3 = location.SubFolderName3;
        loc.SubFolderName4 = location.SubFolderName4;
        loc.SubFolderName5 = location.SubFolderName5;
        loc.SubFolderName6 = location.SubFolderName6;
        loc.SubFolderName7 = location.SubFolderName7;
        loc.SubFolderName8 = location.SubFolderName8;       

        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;        
        return JSON.serialize(service.FillFolder5SubFolders(loc, 'url'));
    }

    @AuraEnabled
    public static String uploadFile(String revisionId, String fileName,string fileData,string suggestedLocations, string WebsiteFriendlyName) 
    {
            Technical_Document_File__c file = new Technical_Document_File__c();
            file.Suggested_Publish_Location__c = suggestedLocations;
            file.Name = fileName.right(80);
            file.Technical_Document_Revision__c = revisionId;
            file.Suggested_Web_Friendly_Name__c = WebsiteFriendlyName;
            insert file;
            

        //ContentVersion cv = createContentVersion(fileData, fileName);
        ContentDocumentLink cdl = createContentLink(fileData, file.Id);
        //if (cv == null || cdl == null) { return null; }

        return [SELECT Technical_Document__c
        FROM Technical_Document_Revision__c
        WHERE Id = :revisionId LIMIT 1].Technical_Document__c;
        
    }

    @AuraEnabled                            
    public static Id uploadChunkedFile(String fileName, String fileContent, String contentVersionId,
                                         String revisionId, string suggestedLocations, string websiteFriendlyName)
    {
        try {
            fileContent = EncodingUtil.urlDecode(fileContent, 'UTF-8');
            if(String.isBlank(contentVersionId)) {

                Technical_Document_File__c file = new Technical_Document_File__c();
            file.Suggested_Publish_Location__c = suggestedLocations;
            file.Name = fileName;
            file.Technical_Document_Revision__c = revisionId;
            file.Suggested_Web_Friendly_Name__c = WebsiteFriendlyName;
            insert file;
 
                ContentVersion cvObj =new ContentVersion(); 
                cvObj.Title = fileName; 
                cvObj.VersionData = EncodingUtil.base64Decode(fileContent);
                cvObj.PathOnClient = '/' + fileName ;
                cvObj.IsMajorVersion = false;
                insert cvObj; 
                
                Id contentDocId = [select id, ContentDocumentId from ContentVersion WHERE Id =: cvObj.Id].ContentDocumentId;
                ContentDocumentLink cl = new ContentDocumentLink();
                cl.ContentDocumentId = contentDocId;
                cl.LinkedEntityId = file.Id; 
                cl.ShareType = 'V';
                cl.Visibility = 'AllUsers';
                insert cl;
                contentVersionId = cvObj.Id;
 
            } else {
 
                ContentVersion cvObj = [SELECT Id, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId];
                String existingFileContent = EncodingUtil.base64Encode(cvObj.VersionData);
                cvObj.VersionData = EncodingUtil.base64Decode(existingFileContent + fileContent); 
                update cvObj;
 
            }
            return Id.valueOf(contentVersionId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static ContentVersion createContentVersion(String base64, String filename, string Id) {
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(base64);
                cv.Title = filename;
                cv.PathOnClient = filename;
                cv.FirstPublishLocationId = Id;
                try {
                    insert cv;
                    return cv;
                } catch(DMLException e) {
                    System.debug(e);
                    return null;
                }
    }

    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
          if (contentVersionId == null || recordId == null) { return null; }
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    // cdl.ContentDocumentId = [
                    //     SELECT ContentDocumentId 
                    //     FROM ContentVersion 
                    //     WHERE Id =: contentVersionId
                    // ].ContentDocumentId;
                    cdl.ContentDocumentId = contentVersionId;
                    cdl.LinkedEntityId = recordId;
                    // ShareType is either 'V', 'C', or 'I'
                    // V = Viewer, C = Collaborator, I = Inferred
                    cdl.ShareType = 'V';
                    try {
                        insert cdl;
                        return cdl;
                    } catch(DMLException e) {
                        System.debug(e);
                        return null;
                    }
    }

    @AuraEnabled(Cacheable = true)
    public static List<Technical_Document_File__c> getFiles(string recordId){                
        
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();  
        string revisionId = recordId;
        if(sObjName == 'Technical_Document__c')
               revisionId = [SELECT Id
                            FROM Technical_Document_Revision__c
                            WHERE Technical_Document__c = :recordId 
                            AND Status__c = 'Approved'].Id;
        
        List<Technical_Document_File__c> files =  [SELECT Name, Id, Suggested_Publish_Location__c 
                                                   FROM Technical_Document_File__c 
                                                   WHERE Technical_Document_Revision__c = :revisionId];
        return files;
    }    

    @AuraEnabled
    public static string approveRevision(string recordId){

        if(!isUserEditor())
            return 'Permission Denied';
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();  

        if(sObjName == 'Technical_Document_Revision__c')
        {            
            List<Technical_Document_Revision__c> revsToUpdate = new List<Technical_Document_Revision__c>();
            List<Technical_Document_Revision__c> revs = [select CreatedBy.Email, Technical_Document__r.Name, Technical_Document__c, Revision_Number__c from Technical_Document_Revision__c where Id = :recordId limit 1];
            Technical_Document_Revision__c rev = revs[0];            
            rev.Status__c = 'Approved';
            rev.Release_Date__c = Datetime.now();
            rev.Approved_By__c = UserInfo.getUserId();
            Technical_Document_Revision__c currentRev = getActiveRevision(rev.Technical_Document__c);
            if(currentRev != null)
            {
                currentRev.Status__c = 'Revised';   
                if(currentRev.Id != rev.id)        
                    revsToUpdate.add(currentRev);
            }            
            revsToUpdate.add(rev);            
            update revsToUpdate;

            Technical_Document__c techDoc = new Technical_Document__c();
            techDoc.Id = rev.Technical_Document__c;
            techDoc.Current_Revision__c = rev.Revision_Number__c;
            update techDoc;

            //todo: email owner            
            String ChildDocMessage = '';
            List<Technical_Document__c> childDocs = getChildDocuments(rev.Technical_Document__c);
            if(childDocs != null && childDocs.size() > 0)
            {
                ChildDocMessage = 'Multiple languages are associated with document named: '+rev.Technical_Document__r.Name+' , please update associated documents as necessary. ' +
                'The following document(s) may be affected by the revision to the document listed above. Please review, and if appropriate, update the document and submit TDM revision request:';
                
                for (Technical_Document__c doc : childDocs) {
                    String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + doc.Id;                         
                    ChildDocMessage += '<br/>' +
                    '<a style=\"font-size:14px\" href=\"' + recordUrl + '\">' +doc.Name + ' (' + doc.ISO_Number__c + ')'+ '</a>'                     ;
                }
            }
            String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + rev.Technical_Document__c;                         
            String Body = 'Revision approved for '+ rev.Technical_Document__r.Name + ' <br/>' + 
                        '<a style=\"font-size:14px\" href=\"' + recordUrl + '\">Record Link</a><br/>' + 
                        ChildDocMessage; 
                        
            EmailSendHelper.sendEmail(rev.CreatedBy.Email, 'dsieraski@inprocorp.com', 'Revision Approved', Body);

            return 'Success';
        }
        else {
            return 'Failure';
        }
    }

    private static List<Technical_Document__c> getChildDocuments(string documentId)
    {
        return [SELECT Parent_Document__c, Name, ISO_Number__c
                FROM Technical_Document__c
                WHERE Parent_Document__c = :documentId];
    }

    @AuraEnabled()
    public static string createPublishSets(List<PublishSet> publishSets)
    {
        if(!isUserEditor())
        return 'Permission Denied';
        string status = 'Success';
        List<Tech_Doc_Product_Category_Publish_Set__c> cList = new List<Tech_Doc_Product_Category_Publish_Set__c>();
        List<Tech_Doc_Product_Series_Publish_Set__c> sList = new List<Tech_Doc_Product_Series_Publish_Set__c>();
        system.debug(publishSets);
        string documentId = publishSets[0].DocumentId;
        string revisionId = '';
        String sObjName = ((Id)documentId).getSObjectType().getDescribe().getName();  

        if(sObjName != 'Technical_Document__c')
        {
            revisionId = documentId;            
            List<Technical_Document_Revision__c> revs = [select Technical_Document__c, Revision_Number__c from Technical_Document_Revision__c where Id = :revisionId limit 1];
            Technical_Document_Revision__c rev = revs[0];
            documentId = rev.Technical_Document__c;    
            string results = approveRevision(revisionId);            
        }        

        String recId = revisionId;
        if(recId == '')
        recId = documentId;
        List<Technical_Document_Publish_Set__c> orphans = getOrphanedPublishSets(recId);
        for (Technical_Document_Publish_Set__c orphan : orphans) {
            orphan.Status__c = 'Inactive';   

            try 
            {
              status +=  deleteSharepointFile(orphan.Id);        
            } catch (Exception ex) {
                system.debug(ex.getMessage());
                status += ex.getMessage();
            }   
        }
        if(orphans != null && orphans.size() > 0)
            update orphans;

      for (PublishSet p : publishSets) {
            Technical_Document_Publish_Set__c pubSet = new Technical_Document_Publish_Set__c();            
            pubSet.Location__c = p.Location;
            if(p.Location == 'Website')
                pubset.Revision_Date__c = Datetime.now();
            pubSet.Name = p.Location + ' Publish Set';
            pubSet.Technical_Document__c = documentId;
            pubSet.SharePoint_Site_Url__c  = p.SharePointSiteUrl;
            pubSet.Technical_Document_File__c = p.TechnicalDocumentFile;
            pubSet.Web_Friendly_Name__c = p.WebFriendlyName;
            pubSet.Status__c = 'Active';            
            if(p.TechnicalDocumentPDFPortalCategory != null && p.TechnicalDocumentPDFPortalCategory != '')
            pubSet.Technical_Document_PDF_Portal_Category__c = p.TechnicalDocumentPDFPortalCategory;
            insert pubSet;

            if(p.Series != null && p.Series != '')
            {
                List<string> seriesIds = p.Series.split(',');
            for (string Id : seriesIds) {
                Tech_Doc_Product_Series_Publish_Set__c s = new Tech_Doc_Product_Series_Publish_Set__c();
                s.Technical_Document_Product_Series__c = Id;
                s.Technical_Document_Publish_Set__c = pubSet.Id;
                s.Name = Id; 
                sList.add(s);
            }
        }            

            if(p.Categories != null && p.Categories != '')
            {
                List<string> categoriesIds = p.Categories.split(',');
                    for (string Id : categoriesIds) {
                        Tech_Doc_Product_Category_Publish_Set__c c = new Tech_Doc_Product_Category_Publish_Set__c();
                        c.Technical_Document_Product_Category__c = Id;
                        c.Technical_Document_Publish_Set__c = pubSet.Id;
                        c.Name = Id;
                        cList.add(c);
                    } 
            }
        }

        if(sList.size() > 0)
            insert sList;
        if(cList.size() > 0)
            insert cList;

        return status;
    }

    @AuraEnabled(cacheable=true)
    public static List<file> getRelatedFiles(String recordId){
        List<File> files = new List<File>();

            for(ContentDocumentLink conLink : [SELECT 
                                                    ContentDocument.Id, 
                                                    ContentDocument.Title, 
                                                    ContentDocument.CreatedDate, 
                                                    ContentDocument.FileType
                                                        FROM ContentDocumentLink 
                                                            WHERE LinkedEntityId =:recordId]){
                File file = new File();
                file.Title = conLink.ContentDocument.Title;
                file.Id = conLink.ContentDocument.Id;
                file.CreatedDate = conLink.ContentDocument.CreatedDate;
                file.Type = conLink.ContentDocument.FileType;
                files.add(file);
            
        }
        return files;
    }    

    @AuraEnabled(cacheable=true)
    public static List<Technical_Document_Publish_Set__c> getPdfPortalPDFs(){
      return [SELECT Location__c, Status__c, 
                Technical_Document_File__c,
                Technical_Document_File__r.Name,
                Technical_Document_File__r.Id,
                Technical_Document__r.Name,
                Technical_Document_PDF_Portal_Category__c,
                Technical_Document_PDF_Portal_Category__r.Name,
                Technical_Document_PDF_Portal_Category__r.Id
                FROM Technical_Document_Publish_Set__c
                WHERE Status__c = 'Active' AND Location__c = 'PDF Portal' ORDER BY Technical_Document__r.Name];
    }

    @AuraEnabled
    public static string downloadCombinedPDF(string pdfs){
        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;                
        return service.DownloadPDFs(pdfs).Message;
    }

    @AuraEnabled()
    public static string deleteFile(string recordId){
        if(!isUserEditor())
        return 'Permission Denied';
        List<ContentVersion> contentVersions =  [SELECT ContentDocumentId
        FROM ContentVersion
        WHERE FirstPublishLocationId = :recordId LIMIT 1];
      
        if(contentVersions.size() > 0)
        {
            ContentDocument cd = new ContentDocument();
            cd.Id = contentVersions[0].ContentDocumentId;
            delete cd;
            return 'Success';
        }
        return 'File Not Found';
    }

    @AuraEnabled()
    public static string publishInproInsiderDocuments(string documentId){
        if(!isUserEditor())
        return 'Permission Denied';
        String sObjName = ((Id)documentId).getSObjectType().getDescribe().getName();  
        if(sObjName == 'Technical_Document_Revision__c')
        {
            documentId = [SELECT Technical_Document__c FROM Technical_Document_Revision__c WHERE Id = :documentId limit 1].Technical_Document__c;
        }

        List<Technical_Document_Publish_Set__c> pubSets =
        [SELECT Technical_Document_File__c      
        FROM Technical_Document_Publish_Set__c
        WHERE Technical_Document__c =:documentId 
        and Status__c = 'Active'
        and Location__c = 'Inpro Insider' LIMIT 10];      
        string status = 'Success ';
        for (Technical_Document_Publish_Set__c pubSet : pubSets) {
            status += uploadSharepointFile(pubSet.Technical_Document_File__c);
        }

        return status;
    }

    @AuraEnabled()
    public static string publishWebsiteDocuments(string documentId){
        if(!isUserEditor())
        return 'Permission Denied';
        String sObjName = ((Id)documentId).getSObjectType().getDescribe().getName();  
        if(sObjName == 'Technical_Document_Revision__c')
        {
            documentId = [SELECT Technical_Document__c FROM Technical_Document_Revision__c WHERE Id = :documentId limit 1].Technical_Document__c;
        }

        List<Technical_Document_Publish_Set__c> pubSets =
        [SELECT Id      
        FROM Technical_Document_Publish_Set__c
        WHERE Technical_Document__c =:documentId 
        and Status__c = 'Active'
        and Location__c = 'Website' LIMIT 10];      
        string status = 'Success ';

        for (Technical_Document_Publish_Set__c pubSet : pubSets) {
            pubSet.Revision_Date__c = Datetime.now();
        }
        update pubSets;

        return status;
    }

    @AuraEnabled
    public static string uploadSharepointFile(string recordId){
        if(!isUserEditor())
        return 'Permission Denied';
        tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
        service.timeout_x = 120000;                
        return service.UploadDocument(recordId).Message;
    }

    @AuraEnabled
    public static string deleteSharepointFile(string recordId){
        if(!isUserEditor())
        return 'Permission Denied';
        Technical_Document_Publish_Set__c pubSet = getPublishSet(recordId);
        if(pubSet != null && pubSet.Location__c == 'Inpro Insider')
        {
            string fileName = pubSet.Technical_Document_File__r.Name;
            string documentName = pubSet.Technical_Document__r.Name;
            string siteURL = pubSet.SharePoint_Site_Url__c;

            if(fileName != null && fileName != '' && 
                documentName != null && documentName != '' &&
                siteURL != null && siteURL != '')
            {
                tdmSvc.TDMServiceSoap service = new tdmSvc.TDMServiceSoap();
                service.timeout_x = 120000;                
                return service.DeleteAFile(fileName, documentName, siteURL).Message;
            }
        }

        return 'Failed To Delete Document.';
    }

    private static Technical_Document_Publish_Set__c getPublishSet(string Id)
    {
        return [SELECT
                Location__c, 
                Status__c, 
                SharePoint_Site_Url__c,
                Technical_Document_File__c,
                Technical_Document_File__r.Name,
                Technical_Document_File__r.Id,
                Technical_Document__r.Name                
                FROM Technical_Document_Publish_Set__c
                WHERE Id = :Id LIMIT 1];
    }

    @AuraEnabled()
    public static string removePublishSet(string recordId){
        if(!isUserEditor())
        return 'Permission Denied';
        String status = 'Success ';
        Technical_Document_Publish_Set__c pubSet = getPublishSet(recordId);
        Technical_Document_Publish_Set__c newPubSet = new Technical_Document_Publish_Set__c();

        newPubSet.Status__c = 'Inactive';
        newPubSet.Id = recordId;

        if(pubSet.Location__c == 'Website')
        {
            newPubSet.Revision_Date__c = Datetime.now();
        }

        if (pubSet.Location__c == 'Inpro Insider') 
        {
           status +=  deleteSharepointFile(recordId);
        }

        update newPubSet;
        
        return status;
    }

    private static List<string> getTDMAdmins()
    {        
        List<string> ToEmails = new List<string>();
        ToEmails.add('dsieraski@inprocorp.com');
        ToEmails.add('ttraczyk@inprocorp.com');
        ToEmails.add('JHAASSER@inprocorp.com');
        return ToEmails;
    }

    private static Boolean isUserEditor()
    {
     List<PermissionSetAssignment> permSets =  [SELECT PermissionSetId,PermissionSet.Name
                                                FROM PermissionSetAssignment 
                                                WHERE AssigneeId =  :UserInfo.getUserId()
                                                AND (PermissionSet.Name = 'TDM_Admin' or
                                                PermissionSet.Name = 'TDM_Editor')];
        if(permSets.size() > 0)
            return true;
        else return false;
    }

    @AuraEnabled    
    public static Boolean isUserAdmin()
    {
     List<PermissionSetAssignment> permSets =  [SELECT PermissionSetId,PermissionSet.Name
                                                FROM PermissionSetAssignment 
                                                WHERE AssigneeId =  :UserInfo.getUserId()
                                                AND (PermissionSet.Name = 'TDM_Admin')];
        if(permSets.size() > 0)
            return true;
        else return false;
    }

    @AuraEnabled()    
    public static string getDocumentImage(string documentId)
    {        
        
        List<ContentDocumentLink> links =  [SELECT Id, ContentDocument.LatestPublishedVersion.VersionData, 
                        ContentDocument.LatestPublishedVersion.Title, 
                        ContentDocument.LatestPublishedVersion.FileExtension,
                        ContentDocument.LatestPublishedVersion.FileType
                         FROM ContentDocumentLink WHERE LinkedEntityId =:documentId limit 1];
                         String existingFileContent = '';
                         if(links != null && links.size() > 0)
                         {
                            existingFileContent= EncodingUtil.base64Encode(links[0].ContentDocument.LatestPublishedVersion.VersionData);
                         }
        return existingFileContent;
    }

    @AuraEnabled()    
    public static string updateDocumentImage(Technical_Document__c document)
    {
        if(isUserEditor())
        {
            if(document != null)
            {
                deleteFile(document.Id);
                if(document.Image__c != null)
                    createContentVersion(document.Image__c, document.Image_Name__c, document.Id);        
            }
        }
        return 'Success';
    }

   @AuraEnabled
   public static Boolean hasExperlogixPublishSet(string documentId){

    String sObjName = ((Id)documentId).getSObjectType().getDescribe().getName();  

    if(sObjName == 'Technical_Document_Revision__c')
    {
        documentId = 
        [SELECT Technical_Document__c FROM Technical_Document_Revision__c WHERE Id = :documentId limit 1].Technical_Document__c;    
    }

    List<Technical_Document_Publish_Set__c> pubSets = 
      [SELECT Name FROM Technical_Document_Publish_Set__c WHERE Location__c = 'Experlogix' AND Status__c = 'Active' AND Technical_Document__c = :documentId limit 1];
        if(pubSets.size() > 0)
        return true;
        else return false;
   }    

    public class File{
        @AuraEnabled public String Title;
        @AuraEnabled public String Type;
        @AuraEnabled public Id Id;
        @AuraEnabled public Datetime CreatedDate;
    }

    public class Location
    {
        @AuraEnabled
        public string ListTitle { get; set;}
        @AuraEnabled
        public string Type { get; set; }
        @AuraEnabled
        public string FolderName { get; set; }
        @AuraEnabled
        public string FolderRelativeUrl { get; set; }
        @AuraEnabled
        public string SubFolderName { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl { get; set; }
        @AuraEnabled
        public string SubFolderName2 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl2 { get; set; }
        @AuraEnabled
        public string SubFolderName3 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl3 { get; set; }
        @AuraEnabled
        public string SubFolderName4 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl4 { get; set; }
        @AuraEnabled
        public string SubFolderName5 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl5 { get; set; }
        @AuraEnabled
        public string SubFolderName6 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl6 { get; set; }
        @AuraEnabled
        public string SubFolderName7 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl7 { get; set; }
        @AuraEnabled
        public string SubFolderName8 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl8 { get; set; }
        @AuraEnabled
        public string SubFolderName9 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl9 { get; set; }
        @AuraEnabled
        public string SubFolderName10 { get; set; }
        @AuraEnabled
        public string SubFolderRelativeUrl10 { get; set; }
    }   

    public class PublishSet
    {
        @AuraEnabled
        public string DocumentId { get; set; }
        @AuraEnabled
        public string Location { get; set; }
        @AuraEnabled
        public string SharePointSiteUrl { get; set; }
        @AuraEnabled
        public string TechnicalDocumentFile { get; set; }
        @AuraEnabled
        public string WebFriendlyName { get; set; }
        @AuraEnabled
        public string Status  { get; set; }        
        @AuraEnabled
        public string TechnicalDocumentPDFPortalCategory { get; set; }
        @AuraEnabled
        public string Series { get; set; }
        @AuraEnabled
        public string Categories { get; set; }
    }
}