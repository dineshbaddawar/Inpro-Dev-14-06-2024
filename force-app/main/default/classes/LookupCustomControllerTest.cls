/************************************************************
* Created by:   The Hunley Group
* Created on:   3/13/2020
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/13/2020       THG - Tyler    Created
*************************************************************/
@IsTest
private class LookupCustomControllerTest {
    @IsTest
    static void testLookup() {
        Test.setMock(WebServiceMock.class, new sfdataTest());

        Profile p = [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true LIMIT 1];


        User user1 = new User();
        user1.Alias = 'guest2';
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.FirstName = 'UserClaim';
        user1.LanguageLocaleKey = 'en_US';
        user1.LastName = 'Site Guest User';
        user1.LocaleSidKey = 'en_US';
        user1.ProfileId = p.Id;
        user1.TimeZoneSidKey = 'GMT';
        user1.Username = 'unittest22@turner.force.com.projrazorxx.inpro';
        user1.Email = 'unittest22@turner.force.com.projrazorxx.inpro';
        insert(user1);


        String res = LookupCustomController.searchDB(
                'User',
                'LastName',
                'Email',
                1000,
                'LastName',
                'Guest'
        );
        system.debug(res);

    }
}