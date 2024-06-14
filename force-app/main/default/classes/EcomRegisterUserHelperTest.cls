@isTest
private class EcomRegisterUserHelperTest{	

	@isTest static void testContainsEmail() {

 		string expectedResult = 'Contact registered.';
		Contact contact = createTestContact('testEmail@gmail.com');
		User user = createTestUser();		
		callRegisterUser(contact.Id, user.Id, expectedResult);		
	}

	@isTest static void testMissingEmail() {
		string expectedResult = 'Contact is missing an email.';
		Contact contact = createTestContact('');
		User user = createTestUser();		
		callRegisterUser(contact.Id, user.Id, expectedResult);		
	}

	@future(callout=true)
	private static void callRegisterUser(string ContactId, string UserId, string expectedResult)
	{
		Test.setMock(WebServiceMock.class, new sfdataTest());
		string result = EcomRegisterUserHelper.registerUser(ContactId, UserId);
		System.assertEquals(result, expectedResult);
	}

	private static Contact createTestContact(String Email) {
		
		Contact contactObj = new Contact (
			FirstName = 'test value', 
			Email = Email, 
			LastName = 'test value'
		);
        insert contactObj;
        return contactObj;
	}  
	
	private static User createTestUser() {	
		
		Profile pf= [Select Id from profile LIMIT 1];
		
		User userObj = new User(	
			ProfileId = pf.Id, 	
			LastName = 'last',
			Email = 'testEmail@gmail.com',
			Username = 'testEmail@gmail.com' + System.currentTimeMillis(),
			CompanyName = 'TEST',
			Title = 'title',
			Alias = 'alias',
			TimeZoneSidKey = 'America/Los_Angeles',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US'
	   );

        insert userObj;
        return userObj;
    }
}