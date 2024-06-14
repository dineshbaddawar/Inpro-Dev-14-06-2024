@isTest
public class LeadConversionControllerTest {
    
    @isTest(SeeAllData=false)
    public static void convertLeadTest() {

          Test.setMock(WebServiceMock.class, new datawarehouseTest());
        Territory__c newTerritory = new Territory__c();
        newTerritory.name = 'Test';
        newTerritory.Area__c = 'China';
        insert newTerritory;

        Test.setMock(WebServiceMock.class, new sfdataTest());
                
        LeadConversionController.getStageValues();
        LeadConversionController.getUser();
        
        Lead lead = new Lead();
        lead.LastName = 'test Lead';
        lead.Company = 'test company';
        lead.Email = 'test@inprocorp.invalid';
        lead.Market_Segment__c ='Architectural Firm';
        lead.Sub_Segment__c ='Architectural Firm';
        lead.Account_Record_Type_To_Create__c = 'Architect/Specifier/Consultant ';
        //lead.Country='US';
        insert lead;
        
        // Lead lead2 = new Lead();
        // lead2.LastName = 'te2st Lead2';
        // lead2.Company = 'te2st comp2any2';
        // lead2.Email = 'test@inprocorp.invalid';
        // lead2.Market_Segment__c ='Architectural Firm';
        // lead2.Sub_Segment__c    ='Architectural Firm';
        // lead2.Account_Record_Type_To_Create__c = 'Architect/Specifier/Consultant';
        // //lead.Country='US';
        // lead2.Project_Role__c ='Bidding Contractor';
        // insert lead2;
        
        LeadConversionController.getRecordTypes(lead.Id);
        LeadConversionController.getLeadDetails(lead.Id); 
        
        LeadConversionController.FilterWrapper filters= LeadConversionController.getFilterWrapper();
        LeadConversionController.DuplicateListWrapper duplicateAccAndConRecs= LeadConversionController.allowDuplicates(lead.Id);

        
        List<LeadConversionController.customObjectWrapper> custObjList= LeadConversionController.getCustomObjectsFromMetadata(lead.Id, filters.defaultFilter, true);
        custObjList= LeadConversionController.getCustomObjectsFromMetadata(lead.Id, filters.defaultFilter, true);
        
        
        
        Account existAcc= new Account();
        existAcc.Name='Company Name';
        insert existAcc;
        
        Contact existCon= new Contact();
        existCon.FirstName='Test';
        existCon.LastName='New Lead';
        insert existCon;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Quote/Bid Complete',
            CloseDate = Date.today(),
            AccountId = existAcc.Id
        );
        insert opp;
        List <LeadConversionController.CreatedRecords>records = new list<LeadConversionController.CreatedRecords>();
        LeadConversionController.CreatedRecords rcd = new LeadConversionController.CreatedRecords();
        LeadConversionController.CreatedRecords rcdOpp = new LeadConversionController.CreatedRecords();
        rcd.Id      =   existAcc.Id;    
        rcd.objName =   'Account';  
        rcd.Name    =   'Account';  
        records.add(rcd);
        rcdOpp.Id       =   opp.Id; 
        rcdOpp.objName  =   'Opportunity';  
        rcdOpp.Name     =   'Opportunity';  
        LeadConversionController.convertedLeadWrapper convLeadWrap= LeadConversionController.convertLeadrecord('Converted', lead.Id, 'accName','Builder/Developer', 'confName', 'conlName','testing@hunleygroup.com','8547713742','Title','Standard Contact', existAcc.id, existCon.Id, false, false,'accBillingStreet','accBillingCity','accBillingState','accBillingPostalCode','accBillingCountry','2345678909','accFax',null,null);
        //LeadConversionController.convertedLeadWrapper convLeadWrap1= LeadConversionController.convertLeadrecord('Converted', lead2.Id, 'accName','Architect/Specifier/Consultant', 'confName', 'conlName','testing@hunleygroup.com','8547713742','Title','Standard Contact', null, null, true, true,'accBillingStreet','accBillingCity',null,'12345',null,'2345678909','accFax',null,null);
        
        //LeadConversionController.updateLookupForCustomObjects(lead2.id,existAcc.id, existCon.id);
        
        // Contact convContact=convLeadWrap.convContact;
        // LeadConversionController.insertBidderRecords(JSON.serialize(records),JSON.serialize(rcdOpp),lead2.id);
        // system.assertEquals(existCon.Id, convContact.Id);

        boolean a = new LeadConversionController.DuplicateListWrapper().allowConDupe;
        List<String> filterValues =  new LeadConversionController.FilterWrapper().filterValues ;
        String filterLabel = new LeadConversionController.FilterWrapper().filterLabel ;

        /*
        test.startTest();
            Construction_Project__c constructionproject = new Construction_Project__c();
            constructionproject.name = 'Construction_Project';
            constructionproject.project_Role__c = 'Bidding Contractor';
            insert constructionproject;
            LeadConversionController.CreatedRecords rcdOpp1 = new LeadConversionController.CreatedRecords();
               
                rcdOpp1.Id      =   constructionproject.Id; 
                rcdOpp1.objName     =   'Construction_Project__c';  
                rcdOpp1.Name    =   'Construction_Project'; 
                LeadConversionController.insertBidderRecords(JSON.serialize(records),JSON.serialize(rcdOpp1),lead2.id);
        test.stopTest();
        */
        
        
    }
    
}