@isTest
private class GeoCodeTest{
    public testmethod static void untiTest(){
      Test.setMock(WebServiceMock.class, new sfdataTest());
          Test.setMock(WebServiceMock.class, new datawarehouseTest());
        String strRes = '{"location":{"lat": 11,"lng":22}}';
        Google_API_Setting__c sobj = new Google_API_Setting__c(
            Request_Path__c = 'json',
            API_Key__c = 'xxxxxxx',
            Base_URL__c = 'https://map.google.com/'
        );
        insert sobj;
        
        // dt_company__c obj = new dt_company__c(
        //     Name = 'test',
        //     contact_Street__c = 'Street', 
        //     contact_City__c = 'City', 
        //     contact_State__c = 'State', 
        //     contact_Country__c = 'Country'
        // );
        // insert obj;
        
        // GeoCode.updateGeoLocationDtCompanyObj(new Set<Id>{obj.Id});
        GeoCode.fetchLatLongFromResponse(strRes);
        
        // Contact_Owner__c co = new Contact_Owner__c(
        //     SF_User_ID__c = UserInfo.getUserId(), 
        //     Contact_Country__c = 'Country', 
        //     State__c = 'State'
        // );
        // insert co;
        

        Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Specialty Contractor').getRecordTypeId();
        Account acc =new Account();
        acc.Name='Test acc';
        acc.Billing_Street_Address__c='test street';
        acc.Market_Segment__c = 'Contractor';
        acc.Sub_Segment__c = 'Specialty Contractor';
        acc.RecordTypeId = contractorRecordTypeId;
        acc.ShippingPostalCode = '27513';
        acc.shippingstreet = 'street';
        acc.shippingcity = 'city';
        acc.shippingstate = 'North Carolina';
        acc.shippingcountry = 'United States';
        insert acc;
        
        GeoCode.updateGeoLocationAccountsObj(new Set<Id>{acc.Id});
        
        // AccountTriggerHandler.updateActTypeByDtCompany(new List<Account>{aobj});
        
        Contact con = new Contact(
            FirstName = 'a',
            LastName = 'a',
            Email = 'atest@test.test',
            AccountId = acc.Id,
            othercountry = 'United States',
            otherstate = 'North Carolina'
        );
        insert con;
    }
}