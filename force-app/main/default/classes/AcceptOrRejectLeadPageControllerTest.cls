@isTest
public class AcceptOrRejectLeadPageControllerTest {
    
    static testMethod void testFunc() {
          Test.setMock(WebServiceMock.class, new sfdataTest());
          Test.setMock(WebServiceMock.class, new datawarehouseTest());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusericp@testorg.com');
        
        System.runAs(u) {
            Blob b = Blob.valueOf('Test Data');
            contact conObj = new contact();
            conObj.LastName='testname';
            conObj.Email='teat@gmail.com';
            insert conObj;
            
            Google_API_Setting__c sobj = new Google_API_Setting__c(
                Request_Path__c = 'json',
                API_Key__c = 'xxxxxxx',
                Base_URL__c = 'https://map.google.com/'
            );
            insert sobj;
            
            Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Specialty Contractor').getRecordTypeId();
            account accObj = new account(Name='Test account');
            accObj.Market_Segment__c = 'Contractor';
            accObj.Sub_Segment__c = 'Specialty Contractor';
            accObj.RecordTypeId = contractorRecordTypeId;
            accObj.ShippingPostalCode = '45633';
            insert accObj;
            Construction_Project__c conProjObj =new Construction_Project__c(Name='Construction project test');
            conProjObj.Market_Segment__c = 'Healthcare';
            conProjObj.Sub_Segment__c ='Dentist';
            insert conProjObj;
            Opportunity_Referral__c oppRefObj = new Opportunity_Referral__c();
            oppRefObj.ConstructionProject__c=conProjObj.Id;
            oppRefObj.Account__c=accObj.Id;
            oppRefObj.Contractor_Status__c = 'Accepted Lead';
            insert oppRefObj;
            Lead_Recipients__c lr= new Lead_Recipients__c();
            lr.Refer_Lead__c=oppRefObj.Id;
            lr.Referral_Status_Response__c='Closed Won';
            insert lr;
            attachment attObj =new attachment();
            attObj.ParentId=conProjObj.Id;
            attObj.Name='test';
            attObj.Body=b;    
            insert attObj;
            
            Substitution_Line_Item__c sli=new Substitution_Line_Item__c();
            sli.ConstructionProject__c=conProjObj.Id;
            insert sli;
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='Header_Picture1', 
                PathOnClient ='/Header_Picture1.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            List<ContentDocument> conDoc=[Select Id from ContentDocument];
            
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = sli.id;
            cdl.ContentDocumentId = conDoc[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            Blob bodyBlob1=Blob.valueOf('Unit Test ContentVersion Body'); 
            ContentVersion contentVersion_2 = new ContentVersion(
                Title='Header_Picture1', 
                PathOnClient ='/Header_Picture1.jpg',
                VersionData = bodyBlob1, 
                origin = 'H'
            );
            insert contentVersion_2;
            
            List<ContentDocument> conDoc1=[Select Id from ContentDocument];
            
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = conProjObj.id;
            cdl1.ContentDocumentId = conDoc1[0].Id;
            cdl1.shareType = 'V';
            insert cdl1;
            
            Test.setCurrentPageReference(new PageReference('Page.AcceptOrRejectLeadPage')); 
            System.currentPageReference().getParameters().put('oppReferralId', oppRefObj.Id);
            System.currentPageReference().getParameters().put('statusResponse', 'accept');
            System.currentPageReference().getParameters().put('subLineItems', sli.id);
            System.currentPageReference().getParameters().put('userId', u.id);
            System.currentPageReference().getParameters().put('leadRecId', lr.id);
            
            AcceptOrRejectLeadPageController controllerObj= new AcceptOrRejectLeadPageController();
            controllerObj.acceptOrReject();
        }
    }
    
}