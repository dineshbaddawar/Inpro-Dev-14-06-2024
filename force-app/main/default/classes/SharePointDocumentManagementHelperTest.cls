@isTest
public with sharing class SharePointDocumentManagementHelperTest{

    @TestSetup
    static void makeData(){
        String pricebookId = Test.getStandardPricebookId();
		Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
		insert prod;
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert pbe;


        Account testAccount = new Account(name = 'Test Account');
        insert testAccount;

        Construction_Project__c cp = new Construction_Project__c(
            Project_Number__c = '12345'
        );
        insert cp;

        Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Quote/Bid Complete',
            Construction_Project__c = cp.Id,
			CloseDate = Date.today(),
			Pricebook2Id = pricebookId,
            Project_Number__c = '12345'
		);
		insert opp;

        Quote quoteObj = new Quote (
			Name = 'This is my Quote', 
			OpportunityId = opp.Id
		);
		insert quoteObj;

        Test.startTest();
    }

    @istest
    static void testGetSubRecordId()
    {
        Quote quote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];
        SharePointDocumentManagementHelper test = new SharePointDocumentManagementHelper();
        Opportunity opp = [SELECT Id, Project_Number__c FROM Opportunity LIMIT 1];
        Construction_Project__c cp = [SELECT Id, Project_Number__c FROM Construction_Project__c LIMIT 1];

        String id = SharePointDocumentManagementHelper.getSubRecordId('Quote', quote.Id);
        String oppProjectNumberId = SharePointDocumentManagementHelper.getSubRecordId('Opportunity', opp.Id);
        String cpProjectNumberId = SharePointDocumentManagementHelper.getSubRecordId('Construction_Project__c', cp.Id);
        String emptyId = SharePointDocumentManagementHelper.getSubRecordId('', quote.Id);

        System.assertEquals(quote.OpportunityId, id);
        System.assertEquals(opp.Project_Number__c, oppProjectNumberId);
        System.assertEquals(cp.Project_Number__c, cpProjectNumberId);
        System.assertEquals('', emptyId);
    }
    @istest 
    static void testGetFileModels() {
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileName = 'test.csv';

        //String results = SharePointDocumentManagementHelper.downloadFile('inprocorporation2019--beta', 'Account', testAccount.Id, fileName, '/test.csv');

        String results = SharePointDocumentManagementHelper.getFileModels('inprocorporation2019--beta', 'Account', String.valueOf(testAccount.Id));

        SharePointDocumentManagement.JobStatusRetrieve fileResults = 
            (SharePointDocumentManagement.JobStatusRetrieve)JSON.deserialize(results, SharePointDocumentManagement.JobStatusRetrieve.class);
        //String deserializedResults = (string)JSON.deserialize(results, String.class);
        
        
        // Verify that a fake result is returned
        System.assertEquals(1, fileResults.SPOFileList.SPOFile.size());
    }

    @istest 
    static void testRelatedGetFileModels() {
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileName = 'test.csv';

        String results = SharePointDocumentManagementHelper.getRelatedFileModels('inprocorporation2019--beta', 'Account', testAccount.Id);

        SharePointDocumentManagement.JobStatusRetrieve fileResults = 
            (SharePointDocumentManagement.JobStatusRetrieve)JSON.deserialize(results, SharePointDocumentManagement.JobStatusRetrieve.class);
        
        // Verify that a fake result is returned
        System.assertEquals(1, fileResults.SPOFileList.SPOFile.size());
    }

    @istest 
    static void testGetFileModelsPrefix() {
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileName = 'test.csv';

        //String results = SharePointDocumentManagementHelper.downloadFile('inprocorporation2019--beta', 'Account', testAccount.Id, fileName, '/test.csv');

        String results = SharePointDocumentManagementHelper.getFileModelsPrefix('inprocorporation2019--beta', 'Account', testAccount.Id, 'Prefix');

        SharePointDocumentManagement.JobStatusRetrieve fileResults = 
            (SharePointDocumentManagement.JobStatusRetrieve)JSON.deserialize(results, SharePointDocumentManagement.JobStatusRetrieve.class);
        //String deserializedResults = (string)JSON.deserialize(results, String.class);
        
        
        // Verify that a fake result is returned
        System.assertEquals(1, fileResults.SPOFileList.SPOFile.size());
    }

    @isTest
    static void testUploadFiles()
    {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileNames = '[\"test.csv\"]';

        String results = SharePointDocumentManagementHelper.uploadFiles('inprocorporation2019--beta', 'Account', testAccount.Id, fileNames);

        SharePointDocumentManagement.JobStatus file = 
            (SharePointDocumentManagement.JobStatus)JSON.deserialize(results, SharePointDocumentManagement.JobStatus.class);

        //Assert that the service finished successfully
        System.assertEquals(true, file.Status);
    }

    @isTest
    static void testDownloadFiles_Success()
    {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileName = 'test.csv';

        String results = SharePointDocumentManagementHelper.downloadFile('inprocorporation2019--beta', 'Account', testAccount.Id, fileName, '/test.csv');

        SharePointDocumentManagement.SPFile file = 
            (SharePointDocumentManagement.SPFile)JSON.deserialize(results, SharePointDocumentManagement.SPFile.class);

        //Assert that a file came back
        System.assertEquals('x', file.FileContents);
    }

    @isTest
    static void testDownloadFiles_Failure()
    {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileName = 'test.csv';

        String results = SharePointDocumentManagementHelper.downloadFile('inprocorporation2019--beta', 'BAD ENTITY', testAccount.Id, fileName, '/test.csv');

        //Assert that a simple string exception message was returned
        System.assert(results.indexof('sObject') != -1);
    }
    @isTest
    static void testDeleteFiles()
    {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());
        // Call the method that invokes a callout       
        Account testAccount = [SELECT Id From Account WHERE Name='Test Account' LIMIT 1];

        String fileName = 'test.csv';

        String results = SharePointDocumentManagementHelper.deleteFile('inprocorporation2019--beta', 'Account', testAccount.Id, fileName, '/test.csv');

        SharePointDocumentManagement.JobStatus file = 
            (SharePointDocumentManagement.JobStatus)JSON.deserialize(results, SharePointDocumentManagement.JobStatus.class);

        //Assert that the service finished successfully
        System.assertEquals(true, file.Status);
    }

    @isTest
    static void testGetOnlineLibraryUrl()
    {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SharePointDocumentManagementTest());

        Opportunity opp = [SELECT Id, Project_Number__c FROM Opportunity LIMIT 1];
        Construction_Project__c cp = [SELECT Id FROM Construction_Project__c LIMIT 1];
        String url1 = SharePointDocumentManagementHelper.getOnlineLibraryUrl(opp.Id, '12345', false);
        String url2 = SharePointDocumentManagementHelper.getOnlineLibraryUrl(cp.Id, '12345', true);

        System.assertEquals('https://test.com/', url1);
        System.assertEquals('https://test.com/', url2);
    }
}