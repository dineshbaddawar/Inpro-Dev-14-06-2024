@isTest
private class RepBackupHelperTest{

	@testSetup static void setup(){

		User u = new User();
        u.IsActive = true;
        u.Username = 'elep@test.com';
        u.LastName = 'Lep';
        u.Email = 'elep@test.com';
        u.Alias = 'ELEP';
        u.TimeZoneSidKey = 'America/Chicago';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = '00e4V000002KjxAQAS';
		u.UserRoleId = '00E6g000000gh7rEAA';
        u.LanguageLocaleKey = 'en_US';
        insert u;

		User u2 = new User();
        u2.IsActive = true;
        u2.Username = 'bsib@test.com';
        u2.LastName = 'Sib';
        u2.Email = 'bsib@test.com';
        u2.Alias = 'BSIB';
        u2.TimeZoneSidKey = 'America/Chicago';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.ProfileId = '00e4V000002KjxAQAS';
		u2.UserRoleId = '00E6g000000gh7rEAA';
        u2.LanguageLocaleKey = 'en_US';
        insert u2;

		Test.startTest();	 
	}

	@isTest static void testBasicGetCoverage()
	{
		User user = [SELECT Id FROM User WHERE LastName = 'Lep'];
		User user2 = [SELECT Id FROM User WHERE LastName = 'Sib'];
		UTO__c uto1 = new UTO__c();
		uto1.User__c = user.Id;
		uto1.Backup__c = user2.Id;
		uto1.Date__c = Date.today();
		insert uto1;

		List<User> uto = RepBackupHelper.getTeamMembers(user.Id);
		List<Holiday> holidays = RepBackupHelper.getHolidays('2022');
		List<UTO__c> uto2 = RepBackupHelper.getFutureUTO(user.Id);
		List<UTO__c> uto3 = RepBackupHelper.getBackupsToday(user.Id);
		List<UTO__c> uto4 = RepBackupHelper.getFutureBackups(user.Id);
		List<UTO__c> uto5 = RepBackupHelper.getUnavailableByDateList(user.Id, new List<string>{ '2022-11-23'});
		List<User> uto6 = RepBackupHelper.getAvailableByDateList(user.Id, new List<string>{ '2022-11-23'});
		List<User> uto7 = RepBackupHelper.getAvailable(user.Id, '2022-11-22','2022-11-23', 'false');
		List<User> uto13 = RepBackupHelper.getAvailable(user.Id, '2022-11-22','2022-11-23', 'true');
		List<UTO__c> uto8 = RepBackupHelper.getMarkedBackupsDateRange(user.Id, '2022-11-22','2022-11-23');
		List<UTO__c> uto12 = RepBackupHelper.getMarkedBackupsDateRange(user.Id, '2022-11-22','');
		List<UTO__c> uto9 = RepBackupHelper.getMarkedBackupsDateList(user.Id, new List<string>{ '2022-11-23'});
		List<string> uto10 = RepBackupHelper.verifyAvailabilityEdit(user.Id, new List<string>{ user2.Id}, new List<string>{ '11/23/2022'});
		List<string> uto11 = RepBackupHelper.verifyAvailability(user.Id, user2.Id, '2022-11-22','2022-11-23');
	}

	@isTest static void testGetUTO() {
		User user = [SELECT Id FROM User WHERE LastName = 'Lep'];
		User user2 = [SELECT Id FROM User WHERE LastName = 'Sib'];
		UTO__c uto1 = new UTO__c();
		uto1.User__c = user.Id;
		uto1.Backup__c = user2.Id;
		uto1.Date__c = Date.today();
		insert uto1;

		List<UTO__c> uto = RepBackupHelper.getUTO(user.Id);

		System.assertEquals(1, uto.size());
	}

	@isTest static void testGetBackups()
	{
		User user = [SELECT Id, Name, UserRole.Name FROM User WHERE UserRole.Name LIKE '%Sales%' LIMIT 1];

		List<UTO__c> backups = RepBackupHelper.getBackups(user.Id);
	}

	@isTest static void testAddUTO()
	{
		User user = [SELECT Id, Name, UserRole.Name FROM User WHERE UserRole.Name LIKE '%Sales%' LIMIT 1];
		User user2 = [SELECT Id FROM User WHERE LastName = 'Sib'];

		List<string> dates = new List<string>();
		List<string> backups = new List<string>();

		dates.add(Date.today().format());
		backups.add(user2.Id);

		string result = RepBackupHelper.addUTO(user.Id, backups, dates);
		UTO__c newUTO = [SELECT Id, User__c, Backup__c, Date__c FROM UTO__c];

		System.assertEquals('',result);
		System.assert(newUTO != null);
	}

	@isTest static void testAddUTO_Exception() 
	{
		try{
			RepBackupHelper.addUTO('',null,null);
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest static void testEditUTO()
	{
		User user = [SELECT Id, Name, UserRole.Name FROM User WHERE UserRole.Name LIKE '%Sales%' LIMIT 1];
		User user2 = [SELECT Id FROM User WHERE LastName = 'Sib'];
		UTO__c uto1 = new UTO__c();
		uto1.User__c = user.Id;
		uto1.Backup__c = user2.Id;
		uto1.Date__c = Date.today();
		insert uto1;
		Date tomorrow = Date.today().addDays(1);

		RepBackupHelper.editUTO(user.Id, new List<string>{uto1.Id}, new List<string>{user2.Id}, new List<string>{tomorrow.format()});

		UTO__c newUTO = [SELECT Id, User__c, Backup__c, Date__c FROM UTO__c];

		System.assertEquals(tomorrow.format(), newUTO.Date__c.format());
	}

	@isTest static void testEditUTO_Exception() 
	{
		try{
			RepBackupHelper.editUTO(null,null,null,null);
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest static void testDeleteUTO()
	{
		User user = [SELECT Id, Name, UserRole.Name FROM User WHERE UserRole.Name LIKE '%Sales%' LIMIT 1];
		User user2 = [SELECT Id FROM User WHERE LastName = 'Sib'];
		UTO__c uto1 = new UTO__c();
		uto1.User__c = user.Id;
		uto1.Backup__c = user2.Id;
		uto1.Date__c = Date.today();
		insert uto1;

		RepBackupHelper.deleteUTO(uto1.Id);

		List<UTO__c> newUTO = [SELECT Id, User__c, Backup__c, Date__c FROM UTO__c];

		System.assertEquals(0, newUTO.size());
	}

	@isTest static void testDeleteUTO_Exception() 
	{
		try{
			RepBackupHelper.deleteUTO('');
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}

	@isTest static void testDeleteUTOList()
	{
		User user = [SELECT Id, Name, UserRole.Name FROM User WHERE UserRole.Name LIKE '%Sales%' LIMIT 1];
		User user2 = [SELECT Id FROM User WHERE LastName = 'Sib'];
		UTO__c uto1 = new UTO__c();
		uto1.User__c = user.Id;
		uto1.Backup__c = user2.Id;
		uto1.Date__c = Date.today();
		insert uto1;

		List<string> utoList = new List<string>();
		utoList.add(uto1.Id);

		RepBackupHelper.deleteUTOList(utoList);

		List<UTO__c> newUTO = [SELECT Id, User__c, Backup__c, Date__c FROM UTO__c];

		System.assertEquals(0, newUTO.size());
	}

	@isTest static void testDeleteUTOList_Exception() 
	{
		try{
			RepBackupHelper.deleteUTOList(null);
			System.assert(false);
		}catch(Exception ex){
			System.assert(true);
		}
	}
}