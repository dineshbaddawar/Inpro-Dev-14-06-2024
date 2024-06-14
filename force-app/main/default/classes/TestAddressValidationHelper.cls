@isTest
private class TestAddressValidationHelper{

	@testSetup static void setup(){

		Account accountObj = new Account (
			BillingStreet = '1507 N Hawley Rd', 
			BillingCity = 'Milwaukee', 
			BillingState = 'Wisconsin', 
			BillingPostalCode = '53208', 
			ShippingStreet = '1507 N Hawley Rd', 
			ShippingCity = 'Milwaukee', 
			ShippingState = 'Wisconsin', 
			ShippingPostalCode = '53208', 
			Name = 'BEN IT TEST'
		);
		insert accountObj;
		 
	}

	@isTest static void testGetObjectNameById() {
		// code_block	
		Account account = [SELECT Id FROM Account];
		String objectName = AddressValidationHelper.GetObjectNameById(account.Id);

		System.assertEquals('Account', objectName);
	}
}