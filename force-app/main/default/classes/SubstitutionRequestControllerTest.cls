@isTest(seealldata=true)
public class SubstitutionRequestControllerTest {
    
    
    public static testmethod void testFn(){
        
        Division__c division = new Division__c();
        division.Name='Test Division';
        insert division;
        
        Business_Unit__c buUnit = new Business_Unit__c();
        buUnit.Name='BU Unit';
        buUnit.Division__c=division.Id;
        insert buUnit;
        
        Business_Unit_Brand__c buBrand = new Business_Unit_Brand__c();
        buBrand.Business_Unit__c=buUnit.Id;
        buBrand.Name='BU Brand';
        insert buBrand;
        
        
        Contact objContact = new Contact();
        objContact.email = 'TEST@TEST.com'; 
        objContact.Lastname = 'TestContact';
        insert objContact;
        
        Product_Brand__c pb1 = new Product_Brand__c();
        pb1.Name = 'Test1';
        pb1.Business_Unit_Brand__c=buBrand.Id;
        pb1.Business_UnitG__c='Clickeze';
        pb1.Product_FamilyG__c = 'Commercial Window Treatments'; 
        pb1.Product_Sub_FamilyG__c = 'Roller Shades';
        insert pb1;
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert contentVersion_1;
        
        List<ContentDocument> conDoc = [SELECT Id FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = pb1.id;
        cdl.ContentDocumentId = conDoc[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
       
        
        
        Product_Brand__c pb2 = new Product_Brand__c();
        pb2.Name = 'Test2';
        pb2.Business_UnitG__c='Clickeze';
        pb2.Product_FamilyG__c = 'Commercial Window Treatments'; 
        pb2.Product_Sub_FamilyG__c = 'Roller Shades';
        insert pb2;
        
         Blob bodyBlob1 = Blob.valueOf('Unit Test ContentVersion Body');
        ContentVersion contentVersion_2 = new ContentVersion(
            Title = 'Header_Picture1',
            PathOnClient = '/Header_Picture1.jpg',
            VersionData = bodyBlob1,
            origin = 'H'
        );
        insert contentVersion_2;
        
        List<ContentDocument> conDoc1 = [SELECT Id FROM ContentDocument];
        
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = pb2.id;
        cdl1.ContentDocumentId = conDoc1[0].Id;
        cdl1.shareType = 'V';
        insert cdl1;
        
        Construction_Project__c constProjObj=new Construction_Project__c();
        constProjObj.Name='Test';
        constProjObj.Architect_Contact__c=objContact.Id;
        insert constProjObj;
        
        Substitution_Line_Item__c subsLineObj= new Substitution_Line_Item__c();
        //subsLineObj.Name='Test';
        subsLineObj.ConstructionProject__c=constProjObj.Id;
        subsLineObj.Substitute_Product_1__c=pb1.id;
        subsLineObj.Substitute_Product_2__c=pb2.Id;
        subsLineObj.Specification_Status__c='Competitors, Basalite not Included';
        insert subsLineObj;
        
        
        
        
        Test.setCurrentPageReference(new PageReference('Page.SubstitutionRequest')); 
        System.currentPageReference().getParameters().put('id', constProjObj.Id);
        System.currentPageReference().getParameters().put('selectedIds', subsLineObj.Id);
        
        
        SubstitutionRequestController contObj=new SubstitutionRequestController();
        
        contObj.showSubstitutionPage();
        contObj.SendEmailToArchitect();
        contObj.Cancel();
        contObj.InsertCoverDoc();
        
    }
    
    public static testmethod void testEmailFn(){
        
        Contact objContact = new Contact();
        objContact.email = 'test@test.com'; 
        objContact.Lastname = 'TestContact';
        insert objContact;
        
        Construction_Project__c constProjObj=new Construction_Project__c();
        constProjObj.Name='Test';
        constProjObj.Architect_Contact__c=objContact.Id;
        insert constProjObj;
        
        Substitution_Line_Item__c subsLineObj= new Substitution_Line_Item__c();
        //subsLineObj.Name='Test';
        subsLineObj.ConstructionProject__c=constProjObj.Id;
        insert subsLineObj;
        
        
        
        Test.setCurrentPageReference(new PageReference('Page.SubstitutionRequest')); 
        System.currentPageReference().getParameters().put('id', constProjObj.Id);
        System.currentPageReference().getParameters().put('selectedIds', subsLineObj.Id);
        
        SubstitutionRequestController contObj=new SubstitutionRequestController();
        contObj.SendEmailToArchitect();
    }
    
    @isTest
    public static void simpleExerciser() {
        
        
        Contact objContact = new Contact();
        objContact.email = 'test@test.com'; 
        objContact.Lastname = 'TestContact';
        insert objContact;
        
        Construction_Project__c constProjObj=new Construction_Project__c();
        constProjObj.Name='Test';
        constProjObj.Architect_Contact__c=objContact.Id;
        insert constProjObj;
        
        Substitution_Line_Item__c subsLineObj= new Substitution_Line_Item__c();
        //subsLineObj.Name='Test';
        subsLineObj.ConstructionProject__c=constProjObj.Id;
        insert subsLineObj;
        
        
        Test.setCurrentPageReference(new PageReference('Page.SubstitutionRequest')); 
        System.currentPageReference().getParameters().put('id', constProjObj.Id);
        System.currentPageReference().getParameters().put('selectedIds', subsLineObj.Id);
        
        SubstitutionRequestController contObj=new SubstitutionRequestController();
        contObj.errormsg = 'testme';
        
        SubstitutionRequestController.WrapProductFiles wpf = new SubstitutionRequestController.WrapProductFiles();
        
        SubstitutionRequestController.AttachmentProductFiles attProdFile=new SubstitutionRequestController.AttachmentProductFiles();
        attProdFile.DocumentId = subsLineObj.Id;
        attProdFile.Links = 'xxx';
        
        List<SubstitutionRequestController.AttachmentProductFiles> attProdFileList =new List<SubstitutionRequestController.AttachmentProductFiles>();
        attProdFileList.add(attProdFile);
        wpf.attchFiles=attProdFileList;
        
        SubstitutionRequestController.WrapDoc wd = new SubstitutionRequestController.WrapDoc();
        wd.DocVersionId = 'xxxxxxx';
        
        system.assert(contObj != null);    
    }
}