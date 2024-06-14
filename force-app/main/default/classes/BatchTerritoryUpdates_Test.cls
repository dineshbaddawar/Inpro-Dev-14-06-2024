@isTest
public without sharing class BatchTerritoryUpdates_Test {
    
    @testSetup
    public static void createTestData() {
        system.debug('#@# BatchTerritoryUpdates_Test.createTestData: BEGIN');

        User currentUser = [SELECT id, Name, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
        FROM User WHERE id =: UserInfo.getUserId()];
        system.debug('#@# BatchTerritoryUpdates_Test.createTestData: currentUser.Id = ' + currentUser.Id + '; currentUser.Name = ' + currentUser.Name);

        // create the Default Domestic and Default International territories becuase there is a flow that sets the account ownership
        // based on these records
        Territory__c defaultDomesticTerritory = new Territory__c(
            Name = 'Default Domestic',
            Area__c = 'Central US',
            Healthcare_OSR__c = UserInfo.getUserId()
        );
        insert defaultDomesticTerritory;

        Territory__c defaultInternationalTerritory = new Territory__c(
            Name = 'Default International',
            Area__c = 'International',
            Healthcare_OSR__c = UserInfo.getUserId()
        );
        insert defaultInternationalTerritory;
        system.debug('#@# BatchTerritoryUpdates_Test.createTestData: inserted 2 Territories');

        // create a territory that we will update
        Territory__c territoryA = new Territory__c(
            Name = 'Territory A',
            Area__c = 'Central US',
            Healthcare_OSR__c = UserInfo.getUserId()
        );
        insert territoryA;
        system.debug('#@# BatchTerritoryUpdates_Test.createTestData: inserted 1 Territory');


        RecordType rt = [
            SELECT Id, DeveloperName, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'Specialty_Contractor' AND SobjectType = 'Account'
        ];
        
        List<Account> accounts = new List<Account>();
        
        Account account1 = new Account(
            Name = 'Contractor 1',
            BillingStreet = '1221 Snider Street',
            BillingCity = 'Limon',
            BillingState = 'Colorado',
            BillingPostalCode = '80828',
            BillingCountry = 'United States',
            BillingLatitude = 39.194847,
            BillingLongitude = -103.758507,
            RecordTypeId = rt.Id,
            Type = 'General Contractor',
            maps__AssignmentRule__c = null,
            Territory_Lookup__c = territoryA.Id
        );
        account1.OwnerId = UserInfo.getUserId();
        accounts.add(account1);

        Account account2 = new Account(
            Name = 'Contractor 2',
            ShippingStreet = '3485 Raver Croft Drive',
            ShippingCity = 'Johnson City',
            ShippingState = 'Tennessee',
            ShippingPostalCode = '37601',
            ShippingCountry = 'United States',
            ShippingLatitude = 36.229813,
            ShippingLongitude = -82.411324,
            RecordTypeId = rt.Id,
            Type = 'General Contractor',
            maps__AssignmentRule__c = null, 
            OwnerId = UserInfo.getUserId(),
            Territory_Lookup__c = territoryA.Id
        );
        accounts.add(account2);
        system.debug('#@# BatchTerritoryUpdates_Test.createTestData: cont2.OwnerId=' + account2.OwnerId);

        Account account3 = new Account(
            Name = 'Contractor 3',
            Billing_Street_Address__c = '1943 Willison Street',
            Billing_City__c = 'Minneapolis',
            Billing_State__c = 'Minnesota',
            Billing_Postal_Code__c = '55406',
            Billing_Country__c = 'United States',
            Contractor_Location__latitude__s = 44.879208,
            Contractor_Location__longitude__s = -93.157440,
            RecordTypeId = rt.Id,
            Type = 'General Contractor',
            maps__AssignmentRule__c = null, 
            OwnerId = UserInfo.getUserId(),
            Territory_Lookup__c = territoryA.Id
        );
        accounts.add(account3);
       
        insert accounts;
        
        // Create Construction Projects
        Account architectAcct = new Account(
            BillingStreet = GeolocationUtilitiesCalloutMock.testStreet,
            BillingCity = GeolocationUtilitiesCalloutMock.testCity,
            BillingState = GeolocationUtilitiesCalloutMock.testState,
            BillingPostalCode = GeolocationUtilitiesCalloutMock.testZip,
            BillingCountry = GeolocationUtilitiesCalloutMock.testCountry,
            BillingLatitude = GeolocationUtilitiesCalloutMock.testLatitude,
            BillingLongitude = GeolocationUtilitiesCalloutMock.testLongitude,
            Name = 'New Opp Acct',
            Territory_Lookup__c = territoryA.Id
        );
        
        // lookup recordtype
        RecordType architect = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'Architect_Specifier'
        ];
        if (architect != null) {
            architectAcct.RecordTypeId = architect.Id;
        }
        
        insert architectAcct;
        
        Account alreadyAssgnedAcct = [SELECT Id, Name FROM Account WHERE Name='Contractor 1'];
        
        List<Construction_Project__c> ConstructionProjects = new List<Construction_Project__c>();
        for (Integer x = 0; x < 20; x++) {
            Construction_Project__c conProjObj = new Construction_Project__c(
                Name = ('Test Opp #' + x),
                Architect_Firm__c = architectAcct.Id,
                Street_Address__c = GeolocationUtilitiesCalloutMock.testStreet,
                City__c = GeolocationUtilitiesCalloutMock.testCity,
                State__c = GeolocationUtilitiesCalloutMock.testState,
                Zip_or_Postal_Code__c = GeolocationUtilitiesCalloutMock.testZip,
                Country__c = GeolocationUtilitiesCalloutMock.testCountry,
                Project_Location__Latitude__s = 39.194847,
                Project_Location__Longitude__s = -103.758507,
                Market_Segment__c = 'Education',
                Sub_Segment__c = 'University/College',
                Territory__c = territoryA.Id
            );
            ConstructionProjects.add(conProjObj);
        }
        insert ConstructionProjects;

        system.debug('#@# BatchTerritoryUpdates_Test.createTestData: END');
    }
    
    @IsTest
    public static void testAccounts() {
        system.debug('#@# BatchTerritoryUpdates_Test.testAccounts: BEGIN');
        
        Territory__c territoryA = [SELECT Id, Name FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        territoryA.Spaces_OSR__c = UserInfo.getUserId();
        update territoryA;

        Territory__c territoryRefreshed = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        system.assertEquals(true, territoryRefreshed.Territory_Refresh_Required__c, 'Territory_Refresh_Required__c checkbox should be checked');


        system.debug('#@# BatchTerritoryUpdates_Test.testAccounts: starting test');
        Test.startTest();
        BatchAccountTerritoryUpdates batch = new BatchAccountTerritoryUpdates(new Set<String>{territoryA.Id});
        Database.executeBatch(batch, 200);
        Test.stopTest();
        system.debug('#@# BatchTerritoryUpdates_Test.testAccounts: stopping test');

        List<Account> accountsNotUpdated = [SELECT Id, Name FROM Account WHERE Territory_Refresh_Required__c = true];
        system.debug('#@# BatchTerritoryUpdates_Test.testAccounts: accountsNotUpdated.size() = ' + accountsNotUpdated.size());

        List<Account> accountsUpdated = [SELECT Id, Name FROM Account WHERE Territory_Refresh_Required__c = false];
        system.debug('#@# BatchTerritoryUpdates_Test.testAccounts: accountsUpdated.size() = ' + accountsUpdated.size());

        system.assertEquals(0, accountsNotUpdated.size(), 'All accounts should have been updated');
        system.assertEquals(4, accountsUpdated.size(), 'No accounts should still have the flag set');
        system.debug('#@# BatchTerritoryUpdates_Test.testAccounts: END');
    }
    
    @IsTest
    public static void testConstructionProjects() {
        system.debug('#@# BatchTerritoryUpdates_Test.testConstructionProjects: BEGIN');

        Territory__c territoryA = [SELECT Id, Name FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        territoryA.Spaces_OSR__c = UserInfo.getUserId();
        update territoryA;

        Territory__c territoryRefreshed = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        system.assertEquals(true, territoryRefreshed.Territory_Refresh_Required__c, 'Territory_Refresh_Required__c checkbox should be checked');

        system.debug('#@# BatchTerritoryUpdates_Test.testConstructionProjects: starting test');
        Test.startTest();
        BatchConstructionProjectTerritoryUpdates batch = new BatchConstructionProjectTerritoryUpdates(new Set<String>{territoryA.Id});
        Database.executeBatch(batch, 200);
        Test.stopTest();
        system.debug('#@# BatchTerritoryUpdates_Test.testConstructionProjects: stopping test');

        List<Construction_Project__c> cpsNotUpdated = [SELECT Id, Name FROM Construction_Project__c WHERE Territory_Refresh_Required__c = true];
        system.debug('#@# BatchTerritoryUpdates_Test.testConstructionProjects: cpsNotUpdated.size() = ' + cpsNotUpdated.size());

        List<Construction_Project__c> cpsUpdated = [SELECT Id, Name FROM Construction_Project__c WHERE Territory_Refresh_Required__c = false];
        system.debug('#@# BatchTerritoryUpdates_Test.testConstructionProjects: cpsUpdated.size() = ' + cpsUpdated.size());

        system.assertEquals(0, cpsNotUpdated.size(), 'All Construction Projects should have been updated');
        system.assertEquals(20, cpsUpdated.size(), 'No Construction Project should still have the flag set');
        system.debug('#@# BatchTerritoryUpdates_Test.testConstructionProjects: END');
    }

    @IsTest
    public static void testRunner() {    
        Territory__c territoryA = [SELECT Id, Name FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        territoryA.Spaces_OSR__c = UserInfo.getUserId();
        update territoryA;

        List<Territory__c> terrs = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Territory_Refresh_Required__c = true];
        system.assertEquals(1, terrs.size(), 'There should be 1 territory with the Territory_Refresh_Required__c = true. terrs.size()=' + terrs.size());

        BatchTerritoryUpdates_Runner runner = new BatchTerritoryUpdates_Runner();
        runner.execute(null);

        List<Territory__c> terrsLeft = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Territory_Refresh_Required__c = true];
        system.assertEquals(0, terrsLeft.size(), 'There should be no territories left with the Territory_Refresh_Required__c = true. terrsLeft.size()=' + terrsLeft.size());
    }


    @IsTest
    public static void testTerritoryUpdate() {
        Territory__c territoryA = [SELECT Id, Name FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        territoryA.Spaces_OSR__c = UserInfo.getUserId();
        update territoryA;

        Territory__c territoryRefreshed = [SELECT Id, Name, Territory_Refresh_Required__c FROM Territory__c WHERE Name = 'Territory A' LIMIT 1];
        system.assertEquals(true, territoryRefreshed.Territory_Refresh_Required__c, 'Territory_Refresh_Required__c checkbox should be checked');
    }


}