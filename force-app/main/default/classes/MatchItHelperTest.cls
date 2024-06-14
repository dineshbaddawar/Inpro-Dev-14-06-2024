@isTest
private class MatchItHelperTest{

	@testSetup static void setup()
	{
		Account gpoAcc = new Account();
		gpoAcc.Name = 'GPO Tier One';
		gpoAcc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe()
								.getRecordTypeInfosByName().get('Group Purchasing Organization').getRecordTypeId();
		gpoAcc.Status__c = 'Prospect';
		insert gpoAcc;

		Account acc = new Account();
		acc.Name = 'Test Account';
		insert acc;

		Account subAcc = new Account();
		subAcc.Name = 'Sub Marine';
		subAcc.ParentId = acc.Id;
		subAcc.ShippingStreet = '123 Test St';
		subAcc.ShippingCity = 'Milwaukee';
		subAcc.ShippingState = 'Wisconsin';
		subAcc.ShippingPostalCode = '53208';
		insert subAcc;

		GPO_Association__c gpo = new GPO_Association__c();
		gpo.Account__c = subAcc.Id;
		gpo.Division__c = 'IPC';
		gpo.Effective_Date__c = System.now().date();
		gpo.Group_Purchasing_Organization__c = gpoAcc.Id;
		gpo.Membership_ID__c = '12345';
		insert gpo;


		Account_Match_Result__c am = new Account_Match_Result__c();
		am.OwnerId = UserInfo.getUserId();
		am.Upload_Name__c = 'Test';
		insert am;
		Attachment attachObj = new Attachment(Name = 'Unit Test Attachment', Body = Blob.valueOf('test body'), parentId = am.Id);
		insert attachObj;
		am.File_Id__c = attachObj.Id;
		update am;

		Account_Match_Result__c am2 = new Account_Match_Result__c();
		am2.OwnerId = UserInfo.getUserId();
		am2.Upload_Name__c = 'Test 2';
		insert am2;
		Attachment attachObj2 = new Attachment(Name = 'Unit Test Attachment', Body = Blob.valueOf('test body'), parentId = am.Id);
		insert attachObj2;
		am2.File_Id__c = attachObj2.Id;
		update am2;

		ContentVersion file = new ContentVersion(
			Title = 'Penguins',
			PathOnClient = 'Penguins.jpg',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true);
		insert file;
	}

	@isTest static void testGetRows() {
		string result = MatchItHelper.getRows([SELECT ContentDocument.Id FROM ContentVersion LIMIT 1].ContentDocument.Id);

		System.assert(result != null);
	}

	@isTest static void testGetResult() {
		string result = MatchItHelper.getResult('Test,123 Test,53208,123-456-7890,12345','1','0','1','2','3','4','-1','-1','-1');
		MatchItHelper.MatchItDTO dto = (MatchItHelper.MatchItDTO)JSON.deserialize(result, MatchItHelper.MatchItDTO.class);

		string result2 = MatchItHelper.getResult(',,,,165432','2','0','1','2','3','4','-1','-1','-1');
		MatchItHelper.MatchItDTO dto2 = (MatchItHelper.MatchItDTO)JSON.deserialize(result2, MatchItHelper.MatchItDTO.class);

		string result3 = MatchItHelper.getResult('Sub Marine,123 Test St,53208,123-456-7890, ','1','0','1','2','3','4','-1','-1','-1');
		MatchItHelper.MatchItDTO dto3 = (MatchItHelper.MatchItDTO)JSON.deserialize(result3, MatchItHelper.MatchItDTO.class);

		System.assert(dto.MatchedMembershipId == '12345');
		System.assert(dto2.MatchedMembershipId != '12345');
		System.assert(dto3.MatchedMembershipId == '12345');
	}

	@isTest static void testSaveResults(){
		string results = MatchItHelper.saveResults([SELECT ContentDocument.Id FROM ContentVersion LIMIT 1].ContentDocument.Id,'Test text');

		System.assert(results != '');
	}

	@isTest static void testGetPreviousResults()
	{
		List<Account_Match_Result__c> test = MatchItHelper.getPreviousResults();

		System.assert(test.size() > 0);

	}

	@istest static void testDeleteAccountMatchResult()
	{
		System.assertEquals('',MatchItHelper.deleteAccountMatchResult([SELECT File_Id__c FROM Account_Match_Result__c WHERE Upload_Name__c = 'Test 2'].File_Id__c));
	}

	@istest static void testGetResultsJson()
	{
		System.assertNotEquals('', MatchItHelper.getResultsJson([SELECT File_Id__c FROM Account_Match_Result__c WHERE Upload_Name__c = 'Test'].File_Id__c));
	}

	@istest static void testUpdateResultsJson()
	{
		Account_Match_Result__c am = [SELECT Id, File_Id__c FROM Account_Match_Result__c WHERE Upload_Name__c = 'Test'];
		String newAttachmentId = MatchItHelper.updateResultsJson(am.File_Id__c, 'Test 2 Text');
		System.assertNotEquals(am.File_Id__c, newAttachmentId);
	}
}