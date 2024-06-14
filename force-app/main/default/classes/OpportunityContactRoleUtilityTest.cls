@IsTest
public class OpportunityContactRoleUtilityTest {

    @TestSetup
    public static void createTestData () {
        
        // Account
        Account a = new Account ();
        a.Name = 'Test Account';
        insert a;
        
        // Contacts
        List <Contact> contacts = new List <Contact> ();
        for (Integer i = 0; i < 3; i++) {
        	Contact c = new Contact ();
            c.AccountId = a.Id;
            c.FirstName = 'Test'+i;
            c.LastName 	= 'McTesterson';
            c.Email 	= 'test'+i+'.mctesterson@testers.com';
            contacts.add(c);
        }
        insert contacts;
        
        // Construction Project
        Construction_Project__c cp = new Construction_Project__c ();
        cp.Construction_Stage__c 	= 'Concept';
        cp.Market_Segment__c 		= 'Commercial Office';
        cp.Sub_Segment__c 			= 'Offices';
        cp.ARC_FAC__c 				= 'ARC';
        cp.A_E_Project_Number__c 	= '12345';
        cp.HCA_Project_Number__c 	= '12345';
        cp.Architect_Firm__c 		= a.Id;
        cp.General_Contractor__c	= a.Id;
        cp.Architect_Contact__c 	= contacts[0].Id;
        cp.Primary_Contact__c 		= contacts[1].Id;
        cp.GC_Contact__c 			= contacts[2].Id;
        insert cp;
        
        // Opportunity
        Opportunity opp = new Opportunity ();
        opp.AccountId 				= a.Id;
        opp.StageName 				= 'New';
        opp.CloseDate 				= Date.today();
        opp.Name 					= 'Test Opp';
        opp.Market_Segment__c 		= 'Commercial Office';
        opp.Sub_Segment__c 			= 'Offices';
        opp.ARC_FAC__c 				= 'ARC';
        opp.Bid_Date_GC_to_Owner__c = DateTime.now();
        opp.Construction_Project__c = cp.Id;
        opp.Estimating_Divisional_Status__c = 'In Audit';
		insert opp;
        
        // Bidders
        List <Bidder__c> bidders = new List <Bidder__c> ();
        for (Integer i = 0; i < 2; i++) {
            Bidder__c bidder = new Bidder__c ();
            bidder.Opportunity__c = opp.Id;
            bidder.Contact__c = contacts[i].Id;
            bidder.Bidder__c = a.Id;
            bidder.Construction_Project__c = cp.Id;
            bidders.add(bidder);
        }
        insert bidders;
    }
    
    
    public static testmethod void testUpdateContactRolesForOpportunities () {
                
        Test.startTest();{
            
            //OpportunityContactRoleUtility.resetAlreadyRanFlag();
            
            // Update the opp to trigger the process.
            Opportunity opp = [Select Id, Construction_Project__c, HCA_Project_Number__c, A_E_Project_Number__c, Estimator__c, Estimating_Divisional_Status__c From Opportunity Limit 1];
        	update opp;
            OpportunityContactRoleUtility.updateContactRolesForOpportunity(opp);
            
            System.assertEquals(5, [Select Count() From OpportunityContactRole Where OpportunityId = :opp.Id]);
            //OpportunityContactRoleUtility.resetAlreadyRanFlag();
            
            // Delete the bidders.
            List <Bidder__c> bidders = [Select Id, Opportunity__c From Bidder__c];
            delete bidders;
            OpportunityContactRoleUtility.updateContactRolesForOpportunities(bidders);
            
            System.assertEquals(3, [Select Count() From OpportunityContactRole Where OpportunityId = :opp.Id]);
            //OpportunityContactRoleUtility.resetAlreadyRanFlag();
            
            // Delete the contacts on the construction project.
            Construction_Project__c cp = [Select Id, Architect_Contact__c, Primary_Contact__c, GC_Contact__c From Construction_Project__c];
            cp.Architect_Contact__c = null;
            cp.Primary_Contact__c 	= null;
            cp.GC_Contact__c 		= null;
            update cp;
            OpportunityContactRoleUtility.updateContactRolesForOpportunities(new List <Construction_Project__c> {cp});
            
            System.assertEquals(0, [Select Count() From OpportunityContactRole Where OpportunityId = :opp.Id]);
            
        }Test.stopTest();
    }
}