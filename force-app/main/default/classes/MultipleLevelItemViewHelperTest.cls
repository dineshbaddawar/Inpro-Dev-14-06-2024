@isTest
private class MultipleLevelItemViewHelperTest{

	@testSetup static void setup(){

		Test.startTest();
	}

	@isTest static void testGetMIVItemInformation() {
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<MultipleLevelItemViewHelper.item> items = MultipleLevelItemViewHelper.getMIVItemInformation('12345','12345');

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetMIVItemDetailInformation(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<MultipleLevelItemViewHelper.itemDetail> items = MultipleLevelItemViewHelper.getMIVItemDetailInformation('12345','location');

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetIMItemCostInformation(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<MultipleLevelItemViewHelper.itemCost> items = MultipleLevelItemViewHelper.getIMItemCostInformation('12345');

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetFOItemInformation(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<MultipleLevelItemViewHelper.Feature> items = MultipleLevelItemViewHelper.getFOItemInformation('12345');

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetFOItemDetailInformation(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<MultipleLevelItemViewHelper.featureOption> items = MultipleLevelItemViewHelper.getFOItemDetailInformation('12345');

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetBOMItemDetailInformation(){
		Test.setMock(WebServiceMock.class, new sfdataTest());

		List<MultipleLevelItemViewHelper.billOfMaterial> items = MultipleLevelItemViewHelper.getBOMItemDetailInformation('12345');

		System.assertEquals(1,items.size());
	}

	@isTest static void testGetUserPermissionSets(){
		String query = 'Select Id from User Limit 1';
		User user = Database.query(query);

		List<PermissionSetAssignment> permissions = MultipleLevelItemViewHelper.GetUserPermissionSets(user.Id);

		//No permissions for test user
		System.assertEquals(0,permissions.size());
	}
}