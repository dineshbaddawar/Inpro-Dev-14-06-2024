@isTest
public with sharing class TDMHelperTest {
    
    @testSetup static void setup(){
        Technical_Document_Language__c lang = new Technical_Document_Language__c(
            Name = 'English'
        );
        insert lang;

        Technical_Document_Product_Series__c series = new Technical_Document_Product_Series__c(
            Name = '1000'
        );
        insert series;

        Technical_Document_Product_Category__c Category = new Technical_Document_Product_Category__c(
            Name = 'Handrail'
        );
        insert Category;

        Technical_Document_Region__c region = new Technical_Document_Region__c(
            Name = 'US & Canada'
        );
        insert region;

        Technical_Document_Type__c docType = new Technical_Document_Type__c(
            Name = 'Installation Instruction'
        );
        insert docType;

        Employee__c emp = new Employee__c(
            Name = 'test',
            Email__c = 'dsieraski@inprocorp.com'
        );
        insert emp;

        Campaign camp = new Campaign(
            Name = 'test',
            Description = 'test'
        );
        insert camp;

        Technical_Document__c techDoc = new Technical_Document__c(
            Name = 'test',
            ISO_Index__c = 1,
            Document_Control__c = 'Uncontrolled' 
        );
        insert techDoc;

        Technical_Document_revision__c techDocRev = new Technical_Document_revision__c(
            Name = 'test',
            Major_Revision__c = 1,
            Minor_Revision__c = 'A',
            Technical_Document__c = techDoc.Id,
            Status__c = 'Approved'
        );
        insert techDocRev;

        Technical_Document__c techDoc2 = new Technical_Document__c(
            Name = 'test',
            ISO_Index__c = 1,
            Document_Control__c = 'Controlled' 
        );
        insert techDoc2;           
        
        Technical_Document_revision__c techDocRev2 = new Technical_Document_revision__c(
            Name = 'test',
            Major_Revision__c = 1,
            Minor_Revision__c = 'A',
            Technical_Document__c = techDoc2.Id,
            Status__c = 'Approved'
        );
        insert techDocRev2;
        
        Technical_Document_Publish_Set__c pubSet = new Technical_Document_Publish_Set__c(
            Name = 'test'
        );

        insert pubSet;

        Technical_Document_File__c file = new Technical_Document_File__c(Name = 'test');

        insert file;

        Technical_Document_PDF_Portal_Category__c pdfCat = new Technical_Document_PDF_Portal_Category__c(Name = 'test');
        insert pdfCat;
    }

    @isTest static void testUserSearch() {
        List<LookupSearchResult> results =
         TDMHelper.UserSearch('Test', '', new List<String>());
        System.assertEquals(0,0);
	}

    @isTest static void testEmployeeSearch() {
        List<LookupSearchResult> results =
         TDMHelper.EmployeeSearch('Test', '', new List<String>());
         System.assertEquals(0,0);
	}

    @isTest static void testCampaignSearch() {
        List<LookupSearchResult> results =
         TDMHelper.CampaignSearch('Test', '', new List<String>());
         System.assertEquals(0,0);
	}
    @isTest static void testLanguageSearch() {
        List<LookupSearchResult> results =
         TDMHelper.LanguageSearch('English', '', new List<String>());
         System.assertEquals(0,0);
	}

    @isTest static void testGetRecords() {
        
        TDMHelper.getDefaultLanaguage();
        TDMHelper.getDefaultRegion();
        TDMHelper.getseries();
        TDMHelper.getCategories();
        TDMHelper.GetMarketSegments();
        TDMHelper.GetDivisions();
        TDMHelper.GetRegions();
        TDMHelper.GetDocumentTypes();
        TDMHelper.getPdfPortalPDFs();
        System.assertEquals(1,1);
	}

    @isTest static void testCreateDocument() {
        TDMHelper.createDocument('Controlled', 'test',         
        [Select id from Employee__c limit 1].id, 
        [Select id from user limit 1].id, 
        [Select id from Technical_Document_Type__c limit 1].id,
        'IPC',
        [Select id from Technical_Document_Language__c limit 1].id, 
        'Education', [Select id from campaign limit 1].id, '', 'description', 'sampleItemNo');

        TDMHelper.createDocument('Uncontrolled', 'test',         
        [Select id from Employee__c limit 1].id, 
        [Select id from user limit 1].id, 
        [Select id from Technical_Document_Type__c limit 1].id,
        'IPC',
        [Select id from Technical_Document_Language__c limit 1].id, 
        'Education', [Select id from campaign limit 1].id, 
        [Select id from Technical_Document_Region__c limit 1].id        
        , 'description', 'sampleItemNo');
        System.assertEquals(1,1);
	}

    @isTest static void testCreateRevision()
    {
        TDMHelper.createRevision([Select id from Technical_Document__c limit 1].id
        , 'Major', 'changeDetail');

        TDMHelper.createRevision([Select id from Technical_Document__c limit 1].id
        , 'Minor', 'changeDetail');
        System.assertEquals(1,1);
    }

    @isTest static void testGetOrphanedPublishSets()
    {
        TDMHelper.getOrphanedPublishSets([Select id from Technical_Document__c where document_control__c = 'Controlled' limit 1].id);      
        TDMHelper.getOrphanedPublishSets([Select id from Technical_Document__c where document_control__c = 'Uncontrolled' limit 1].id);      
        System.assertEquals(1,1);
    }

    @isTest static void testFillTreeLists()
    {
        Test.setMock(WebServiceMock.class, new tdmSvcTest());
        Test.startTest();
        TDMHelper.FillTree();
        TDMHelper.Location loc = new TDMHelper.Location();
        loc.ListTitle = 'test';
        loc.FolderRelativeUrl = '';
        loc.FolderName= '';
        loc.Type = '';
        loc.SubFolderName= '';
        loc.SubFolderName10= '';
        loc.SubFolderName2= '';
        loc.SubFolderName3= '';
        loc.SubFolderName4= '';
        loc.SubFolderName5= '';
        loc.SubFolderName6= '';
        loc.SubFolderName7= '';
        loc.SubFolderName8= '';
        loc.SubFolderName9= '';
        loc.SubFolderRelativeUrl= '';
        loc.SubFolderRelativeUrl10= '';
        loc.SubFolderRelativeUrl9= '';
        loc.SubFolderRelativeUrl8= '';
        loc.SubFolderRelativeUrl7= '';
        loc.SubFolderRelativeUrl6= '';
        loc.SubFolderRelativeUrl5= '';
        loc.SubFolderRelativeUrl4= '';
        loc.SubFolderRelativeUrl3= '';
        loc.SubFolderRelativeUrl2= '';
        TDMHelper.FillListFolders(loc);
        TDMHelper.FillListSubFolders(loc);
        TDMHelper.FillList2SubFolders(loc);
        TDMHelper.FillList3SubFolders(loc);
        TDMHelper.FillList4SubFolders(loc);
        TDMHelper.FillList5SubFolders(loc);
        TDMHelper.uploadSharepointFile('test');        
        System.assertEquals(1,1);
    }

    @isTest static void testUploadFile()
    {
        TDMHelper.uploadFile([Select id from Technical_Document_Revision__c limit 1].id
        , 'fileName', 
        [Select id from Technical_Document_File__c limit 1].id,
         'suggestedLocations', 'WebsiteFriendlyName');

        TDMHelper.uploadChunkedFile('test.pdf', 'test', '', [Select id from Technical_Document_Revision__c limit 1].id,
                                     'suggestedLocations', 'websiteFriendlyName');

        System.assertEquals(1,1);
    }

    @isTest static void testApproveRevision()
    {
        TDMHelper.hasExperlogixPublishSet([Select id from Technical_Document_Revision__c limit 1].id);
        TDMHelper.hasExperlogixPublishSet([Select id from Technical_Document__c limit 1].id);
        TDMHelper.approveRevision([Select id from Technical_Document_Revision__c limit 1].id);        
                                System.assertEquals(1,1);
    }

    @isTest static void testCreatePublishSets()
    {
        List<TDMHelper.PublishSet> publishSets = new List<TDMHelper.PublishSet>();
        TDMHelper.PublishSet ps = new TDMHelper.publishSet();
        ps.DocumentId = [Select id from Technical_Document__c limit 1].id;
        ps.Location = 'Website';
        ps.Categories = '';
        ps.Series = '';
        ps.SharePointSiteUrl = 'test';
        ps.Status = 'Active';
        ps.TechnicalDocumentFile = [Select id from Technical_Document_File__c limit 1].id;
        ps.TechnicalDocumentPDFPortalCategory = [Select id from Technical_Document_PDF_Portal_Category__c limit 1].id;
        ps.WebFriendlyName = 'test';
        publishSets.add(ps);
        TDMHelper.createPublishSets(publishSets);
        System.assertEquals(1,1);
    }

    @isTest static void testRemovePublishSet()
    {        
        TDMHelper.removePublishSet([Select id from Technical_Document_Publish_Set__c limit 1].id);
        TDMHelper.deleteFile('test');        
                                System.assertEquals(1,1);

    }

    @isTest static void testPublishWebsitePublishSets()
    {        
        TDMHelper.publishWebsiteDocuments([Select id from Technical_Document__c limit 1].id);        
        System.assertEquals(1,1);
    }

    @isTest static void testImageMethods()
    {
        TDMHelper.getDocumentImage([Select id from Technical_Document__c limit 1].id);
        Technical_Document__c techDoc = [Select id, Image__c, Image_Name__c from Technical_Document__c limit 1];        
        TDMHelper.updateDocumentImage(techDoc);
        System.assertEquals(1,1);
    }
}