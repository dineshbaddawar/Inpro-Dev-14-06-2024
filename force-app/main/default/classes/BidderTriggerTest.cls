@IsTest
public class BidderTriggerTest {

    public static testmethod void testTrigger () {

        // Account
        Account a = new Account ();
        a.Name = 'Test Account';
        insert a;
        
        // Contacts
        Contact c = new Contact ();
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName 	= 'McTesterson';
        c.Email 	= 'test.mctesterson@testers.com';
        insert c;
        
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
        cp.Architect_Contact__c 	= c.Id;
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
        
        // Bidder
        Bidder__c bidder = new Bidder__c ();
        bidder.Opportunity__c = opp.Id;
        bidder.Contact__c = c.Id;
        bidder.Bidder__c = a.Id;
        bidder.Construction_Project__c = cp.Id;
        


        insert bidder;
        update bidder;
        delete bidder;

    }

}