@isTest
public class ConsProjectReferralControllerTest {
    
    @testSetup
    public static void createTestData() {
        system.debug('#@# ConsProjectReferralControllerTest.createTestData:BEGIN');
        Google_API_Setting__c sobj = new Google_API_Setting__c(
            Request_Path__c = 'json',
            API_Key__c = 'xxxxxxx',
            Base_URL__c = 'https://map.google.com/'
        );
        insert sobj;
        
        RecordType rt = [
            SELECT Id, DeveloperName, SobjectType
            FROM RecordType
            WHERE DeveloperName = 'Specialty_Contractor' AND SobjectType = 'Account'
        ];
        
        List<Account> contractors = new List<Account>();
        
        Account cont1 = new Account(
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
            Market_Segment__c = 'Contractor',
            Sub_Segment__c = 'Specialty Contractor',
            ShippingPostalCode = '80828'
        );
        contractors.add(cont1);
        Account cont2 = new Account(
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
            Market_Segment__c = 'Contractor',
            Sub_Segment__c = 'Specialty Contractor'
        );
        contractors.add(cont2);
        Account cont3 = new Account(
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
            Market_Segment__c = 'Contractor',
            Sub_Segment__c = 'Specialty Contractor',
            ShippingPostalCode = '55406'
        );
        contractors.add(cont3);
        
        insert contractors;
        
        List<Contact> contacts = new List<Contact>();
        
        Contact cont1Contact = new Contact(
            FirstName = 'Alex',
            LastName = 'Blaster',
            Email = 'Alex.Blaster@mailinator.com',
            AccountId = cont1.Id
        );
        contacts.add(cont1Contact);
        Contact cont2Contact = new Contact(
            FirstName = 'Chelsey',
            LastName = 'Downey',
            Email = 'Chlsey.Downey@mailinator.com',
            AccountId = cont2.Id
        );
        contacts.add(cont2Contact);
        Contact cont3Contact = new Contact(
            FirstName = 'Eric',
            LastName = 'Freuhoffen',
            Email = 'Eric.Freuhoffen@mailinator.com',
            AccountId = cont3.Id
        );
        contacts.add(cont3Contact);
        
        insert contacts;
        
        List<AccountContactRelation> accRelList = new List<AccountContactRelation>();
        for(AccountContactRelation accRel:[ SELECT Id, AccountId, ContactId, Account.Name, 
                                           Contact.Email, Contact.Name, Roles
                                           FROM AccountContactRelation]){
                                               accRel.Roles = 'Lead Recipient';
                                               accRelList.add(accRel);
                                           }
        update accRelList;

        system.debug('#@# ConsProjectReferralControllerTest.createTestData:END');
      
    }
    
    @isTest
    public static void referConProj() {
        system.debug('#@# ConsProjectReferralControllerTest.referConProj:BEGIN');
        Test.setMock(WebServiceMock.class, new sfdataTest());
          Test.setMock(WebServiceMock.class, new datawarehouseTest());

        Account architectAcct = new Account(
            BillingStreet = GeolocationUtilitiesCalloutMock.testStreet,
            BillingCity = GeolocationUtilitiesCalloutMock.testCity,
            BillingState = GeolocationUtilitiesCalloutMock.testState,
            BillingPostalCode = GeolocationUtilitiesCalloutMock.testZip,
            BillingCountry = GeolocationUtilitiesCalloutMock.testCountry,
            BillingLatitude = GeolocationUtilitiesCalloutMock.testLatitude,
            BillingLongitude = GeolocationUtilitiesCalloutMock.testLongitude,

            Name = 'New Opp Acct'
        );
        
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past new Account');

        // lookup recordtype
        RecordType architect = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = 'Architect_Specifier'
        ];
        if (architect != null) {
            architectAcct.RecordTypeId = architect.Id;
        }
        architectAcct.Market_Segment__c = 'Architectural Firm';
        architectAcct.Sub_Segment__c = 'Architectural Firm';
        insert architectAcct;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past architectAcct');
        
        Account alreadyAssgnedAcct = [Select Id,Name from Account where Name='Contractor 1'];
        
        Construction_Project__c conProjObj = new Construction_Project__c(
            Name = 'Test Opp',
            Architect_Firm__c = architectAcct.Id,
            Street_Address__c = GeolocationUtilitiesCalloutMock.testStreet,
            City__c = GeolocationUtilitiesCalloutMock.testCity,
            State__c = GeolocationUtilitiesCalloutMock.testState,
            Zip_or_Postal_Code__c = GeolocationUtilitiesCalloutMock.testZip,
            Country__c = GeolocationUtilitiesCalloutMock.testCountry,
            Project_Location__Latitude__s = 39.194847,
            Project_Location__Longitude__s = -103.758507,
            Market_Segment__c = 'Healthcare',
            Sub_Segment__c ='Dentist'
        );
        insert conProjObj;
        Construction_Project__c conProject=ConstructionProjectReferralController.getConProjRecord(conProjObj.Id);
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past Construction Project');
        
        List<Substitution_Line_Item__c> sliList = new List<Substitution_Line_Item__c>();
        Substitution_Line_Item__c sliObj = new Substitution_Line_Item__c();
        sliObj.ConstructionProject__c = conProject.Id;
        sliObj.Sales_Team__c = 'IB- National';
        sliObj.Product_FamilyG__c = 'Commercial Showers';
        sliObj.Product_Sub_FamilyG__c = 'Cab Panel System';
        sliObj.Status__c = 'Pre-Qualified';
        sliList.add(sliObj);
        insert sliList;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past sliList');
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past contentVersion_1');
        
        List<ContentDocument> conDoc = [SELECT Id FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = sliObj.id;
        cdl.ContentDocumentId = conDoc[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past cdl');
        
        Blob bodyBlob1 = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersion_2 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob1,
            origin = 'H'
        );
        insert contentVersion_2;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past contentVersion_2');
        
        List<ContentDocument> conDoc1 = [SELECT Id FROM ContentDocument];
        
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = conProject.id;
        cdl1.ContentDocumentId = conDoc1[0].Id;
        cdl1.shareType = 'V';
        insert cdl1;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past cdl1');
        
        Opportunity_Referral__c oppRef = new Opportunity_Referral__c(
            ConstructionProject__c = conProject.Id,
            Account__c = alreadyAssgnedAcct.Id
        );
        insert oppRef;
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past oppRef');
        
        ConstructionProjectReferralController.getSubstitutionRequests(conProject.Id);
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past getSubstitutionRequests');
        
        List<RecordType> accRecordTypeList=ConstructionProjectReferralController.getAccountRecordTypes();
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past getAccountRecordTypes');
        List<ConstructionProjectReferralController.AccountTypeWrapper> accTypeList=ConstructionProjectReferralController.getAccountTypePLValues(accRecordTypeList);
        system.debug('#@# ConsProjectReferralControllerTest.referConProj: made it past getAccountTypePLValues');
        system.debug('accRecordTypeList'+accRecordTypeList);
        system.debug('accTypeList'+accTypeList);
        List<ConstructionProjectReferralController.AccountWrapper> accWrapperList=ConstructionProjectReferralController.getAccounts(conProject.Id, 'Contractor', accRecordTypeList, accTypeList);
        List<Id> accIdList = new List<Id>();
        for(ConstructionProjectReferralController.AccountWrapper acc:accWrapperList){
            if(acc.assigned == false)
                accIdList.add(acc.acct.id);
        }
        //ConstructionProjectReferralController.doAssignOpp(conProject.Id, accIdList, sliList);
        
        system.debug('#@# ConsProjectReferralControllerTest.referConProj:END');

    }
    
}