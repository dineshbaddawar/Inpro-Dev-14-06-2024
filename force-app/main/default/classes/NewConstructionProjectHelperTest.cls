@isTest
private class NewConstructionProjectHelperTest{

	@testSetup static void setup()
	{
		Account acc = new Account();
		acc.Name = 'Test';
		insert acc;

		Contact con = new Contact();
		con.LastName = 'Smith';
		con.AccountId = acc.Id;
		insert con;

		Territory__c ter = new Territory__c();
		ter.Name = 'MW1';
		ter.Area__c = 'Central US';
		insert ter;
	}

	@isTest static void testGetPicklistValues() {
		List<string> values = NewConstructionProjectHelper.GetPicklistValues('Construction_Project__c', 'Market_Segment__c');
		List<string> values2 = NewConstructionProjectHelper.GetDependentPicklistValues('Construction_Project__c', 'Market_Segment__c', 'Yes');
	}

	@isTest static void testCreate() {
		string jsonString = '{"Name":"20221213 Test 3","Market_Segment__c":"Commercial Office","Construction_Stage__c":"Concept","Sub_Segment__c":"Offices","Project_Source__c":"Sales","ARC_FAC__c":"ARC","Category__c":"Healthcare","Large_Project__c":"","Construction_Project__c":"Yes","Country__c":"United States","Street_Address__c":"1507 N Hawley Rd","City__c":"Milwaukee","ZIP__c":"53208"}';

		string newId = NewConstructionProjectHelper.CreateConstructionProject(jsonString);

		System.assert(newId != '');
	}

	@isTest static void testContactFilterSearch()
	{
		NewConstructionProjectHelper.ContactFilterSearch('Smith', [SELECT Id FROM Account LIMIT 1].Id);
	}

	@isTest static void testTerritorySearch()
	{
		NewConstructionProjectHelper.TerritorySearch('MW', '', new List<string>());
	}
}