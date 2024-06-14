@isTest
public class SubstitutionLineItemTriggerHandlerTest {
    public static testMethod void testfn() {
        setUpData();
        lineItem1.ICP_Revenue__c=1000;
        lineItem1.Status__c = 'Closed Won';
        update lineItem1;
        Construction_Project__c conProj = [
            SELECT Id, Internal_Status__c
            FROM Construction_Project__c
            WHERE Id = :projObj.id
        ];
        system.assertNotEquals('Closed Lost', conProj.Internal_Status__c);
        lineItem2.Status__c = 'Closed Lost';
        update lineItem2;
        Construction_Project__c conProj1 = [
            SELECT Id, Internal_Status__c
            FROM Construction_Project__c
            WHERE Id = :projObj.id
        ];
    }
    
    // any subreq lines should get auto-populated with matching SalesTeam if family/subfamily match
    @isTest
    public static void testSalesteamsGetPopulated() {
        setUpData();
        
        lineItem1 = [
            SELECT Id, Sales_Team__c
            FROM Substitution_Line_Item__c
            WHERE id = :lineItem1.Id
        ];
        lineItem2 = [
            SELECT Id, Sales_Team__c
            FROM Substitution_Line_Item__c
            WHERE id = :lineItem2.Id
        ];
        
        system.assertEquals('IB- National', lineItem1.Sales_Team__c);
        system.assertEquals('IB- National', lineItem2.Sales_Team__c);
    }
    
    // if any sub req line.Status changed, and equals "Substitution Accepted" or "Qualified"
    // then set the correct SalesTeam field to 'Ready for Sales'
    @isTest
    public static void testReqLineStatusToQualifiedSetsSalesTeam() {
        setUpData();
        
        lineItem1.Status__c = 'Substitution Accepted';
        update lineItem1;
        lineItem2.Status__c = 'Qualified';
        update lineItem2;
        
        // reload con project
        projObj = QueryConstructionProjectForId(projObj.Id);
        
        // system.assertEquals('Ready for Rep', projObj.Status_Flooring__c);
    }
    
    // if all sub req lines for a given sales team change to "Sent to Contractors",
    // then set the correct SalesTeam field to 'Rep has Referred'
    @isTest
    public static void testAllReqLineStatusToSentToContractorCausesChange() {
        setUpData();
        
        Division__c division = new Division__c();
        division.Name='California';
        insert division;
        
        Business_Unit__c buUnit = new Business_Unit__c();
        buUnit.Name='BU Unit';
        buUnit.Division__c=division.Id;
        insert buUnit;
        
        Business_Unit_Brand__c buBrand = new Business_Unit_Brand__c();
        buBrand.Business_Unit__c=buUnit.Id;
        buBrand.Name='BU Brand';
        insert buBrand;
        // set our relationship2 to flooring team so both relationships are same Flooring team:
        relationship2.Business_Unit_Brand__c = buBrand.Id;
        update relationship2;
        lineItem2.Sales_Team__c = 'HC Muddox';
        update lineItem2;
        
        lineItem1.Status__c = 'Sent to Contractors';
        update lineItem1;
        // only setting one of the lines to this status should NOT cause change
        
        // reload con project
        projObj = QueryConstructionProjectForId(projObj.Id);
        
        // system.assertNotEquals('Rep Has Referred', projObj.Status_Flooring__c);
        
        lineItem2.Status__c = 'Sent to Contractors';
        update lineItem2;
        
        // reload con project
        projObj = QueryConstructionProjectForId(projObj.Id);
        
        // system.assertEquals('Rep Has Referred', projObj.Status_Flooring__c);
    }
    
    // if all sub req lines for a given sales team change to "Sent to Contractors",
    // then set the correct SalesTeam field to 'Rep has Referred'
    @isTest
    public static void testAllReqLineStatusReferralAcceptedCausesChange() {
        setUpData();
        
        Division__c division = new Division__c();
        division.Name='California';
        insert division;
        
        Business_Unit__c buUnit = new Business_Unit__c();
        buUnit.Name='BU Unit';
        buUnit.Division__c=division.Id;
        insert buUnit;
        
        Business_Unit_Brand__c buBrand = new Business_Unit_Brand__c();
        buBrand.Business_Unit__c=buUnit.Id;
        buBrand.Name='BU Brand';
        insert buBrand;
        // set our relationship2 to flooring team so both relationships are same Flooring team:
        relationship2.Business_Unit_Brand__c = buBrand.Id;
        update relationship2;
        lineItem2.Sales_Team__c = 'HC Muddox';
        update lineItem2;
        
        lineItem1.Status__c = 'Referral Accepted';
        update lineItem1;
        // only setting one of the lines to this status should NOT cause change
        
        // reload con project
        projObj = QueryConstructionProjectForId(projObj.Id);
        
        // system.assertNotEquals('Contractor Accepted', projObj.Status_Flooring__c);
        
        lineItem2.Status__c = 'Referral Accepted';
        update lineItem2;
        
        // reload con project
        projObj = QueryConstructionProjectForId(projObj.Id);
        
        // system.assertEquals('Contractor Accepted', projObj.Status_Flooring__c);
    }
    
    @isTest
    public static void testConstructionProjectStatusMaps() {
        ConstructionProjectStatusMaps cpMaps = new ConstructionProjectStatusMaps();
        System.assert(cpMaps != null);
    }
    
    // these allow our methods to access our setup data:
    private static Substitution_Line_Item__c lineItem1 = null;
    private static Substitution_Line_Item__c lineItem2 = null;
    private static Construction_Project__c projObj = null;
    private static Product_Brand__c relationship1 = null;
    private static Product_Brand__c relationship2 = null;
    
    private static void setUpData() {
        // setup SalesTeamField Automation Mappings
        /*Sales_Team_Field_Automation_Mapping__c stam1 = new Sales_Team_Field_Automation_Mapping__c();
        Sales_Team_Field_Automation_Mapping__c stam2 = new Sales_Team_Field_Automation_Mapping__c();
        List<Sales_Team_Field_Automation_Mapping__c> stams = new List<Sales_Team_Field_Automation_Mapping__c>();
        stams.add(stam1);
        stams.add(stam2);
        
        stam1.Construction_Project_Rep_Field__c = 'Territory_Owner_Dry_Treat__c';
        stam1.Construction_Project_Team_Field__c = 'Status_DryTreat__c';
        stam1.Sales_Team__c = 'California';
        stam2.Construction_Project_Rep_Field__c = 'Territory_Owner_Flooring__c';
        stam2.Construction_Project_Team_Field__c = 'Status_Flooring__c';
        stam2.Sales_Team__c = 'California';
        
        insert stams;*/
        
        // // we need to read possible ProductFamily values --- read picklist values
        // Schema.DescribeFieldResult fieldResult = Substitution_Line_Item__c.Product_FamilyG__c.getDescribe();
        // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        // String family = ple.get(2).getValue();
        // String family2 = ple.get(1).getValue();
        // system.debug('family' + family);
        // system.debug('family2' + family2);
        // // we need to read possible ProductSubFamily values --- read picklist values, including dependencies
        // Map<Object, List<String>> result = HunleyTestUtils.getDependentPicklistValues(
        //   Substitution_Line_Item__c.Product_Sub_FamilyG__c
        // );
        // system.debug('result' + result);
        // String subfamily = result.get(family).get(0);
        // String subfamily2 = result.get(family2).get(0);
        
        // setup product relationship mappings
        // 
        Business_Unit__c businessUnit=new Business_Unit__c();
        businessUnit.Name='Paving';
        insert businessUnit;
        
        Business_Unit_Brand__c busBrand= new Business_Unit_Brand__c();
        busBrand.Business_Unit__c=businessUnit.Id;
        busBrand.Name='Business Unit Brand';
        insert busBrand;
        
        Business_Unit__c businessUnit2=new Business_Unit__c();
        businessUnit2.Name='Terrazzo';
        insert businessUnit2;
        
        Business_Unit_Brand__c busBrand2= new Business_Unit_Brand__c();
        busBrand2.Business_Unit__c=businessUnit2.Id;
        busBrand2.Name='Business Unit Brand';
        insert busBrand2;
        
        List<Product_Brand__c> pbs = new List<Product_Brand__c>();
        Product_Brand__c pb1 = new Product_Brand__c();
        pb1.Business_Unit_Brand__c=busBrand.Id;
        pb1.Business_UnitG__c='Clickeze';
        pb1.Product_FamilyG__c = 'Commercial Window Treatments'; 
        pb1.Product_Sub_FamilyG__c = 'Roller Shades';
        pbs.add(pb1);
        
        Product_Brand__c pb2 = new Product_Brand__c();
        pb2.Business_Unit_Brand__c=busBrand2.Id;
        pb1.Business_UnitG__c='Clickeze';
        pb1.Product_FamilyG__c = 'Commercial Window Treatments'; 
        pb1.Product_Sub_FamilyG__c = 'Roller Shades';
        pbs.add(pb2);
        
        insert pbs;
        
        relationship1 = pb1;
        relationship2 = pb2;
        
        projObj = new Construction_Project__c();
        projObj.Name = 'Test Construction Project';
        projObj.Construction_Stage__c = 'Concept';
        projObj.Project_Source__c = 'Other';
        projObj.Internal_Status__c = 'New';
        insert projObj;
        
        lineItem1 = new Substitution_Line_Item__c();
        lineItem1.ConstructionProject__c = projObj.Id;
        lineItem1.Sales_Team__c = 'IB- National';
        lineItem1.Product_FamilyG__c = 'Commercial Showers';
        lineItem1.Product_Sub_FamilyG__c = 'Cab Panel System';
        lineItem1.Status__c = 'Pre-Qualified';
        lineItem1.Specification_Status__c = 'No Spec Yet';
        insert lineItem1;
        
        lineItem2 = new Substitution_Line_Item__c();
        lineItem2.ConstructionProject__c = projObj.Id;
        lineItem2.Sales_Team__c = 'IB- National';
        lineItem2.Product_FamilyG__c = 'Commercial Showers';
        lineItem2.Product_Sub_FamilyG__c = 'Cab Panel System';
        lineItem2.Status__c = 'Pre-Qualified';
        lineItem2.Specification_Status__c = 'No Spec Yet';
        insert lineItem2;
    }
    
    private static Construction_Project__c QueryConstructionProjectForId(
        String id
    ) {
        return [
            SELECT
            Id
            
            FROM Construction_Project__c
            WHERE id = :id
        ];
    }
}