@IsTest
public class OpportunityTriggerHelperTest {
    
    @TestSetup
    static void makeData () {
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
            c.LastName  = 'McTesterson';
            c.Email     = 'test'+i+'.mctesterson@testers.com';
            contacts.add(c);
        }
        insert contacts;
        
        // Construction Project
        Construction_Project__c cp = new Construction_Project__c ();
        cp.Construction_Stage__c        = 'Concept';
        cp.Market_Segment__c            = 'Commercial Office';
        cp.Sub_Segment__c               = 'Offices';
        cp.ARC_FAC__c                   = 'ARC';
        cp.A_E_Project_Number__c        = '12345';
        cp.HCA_Project_Number__c        = '12345';
        cp.Architect_Firm__c            = a.Id;
        cp.General_Contractor__c        = a.Id;
        cp.Architect_Contact__c         = contacts[0].Id;
        cp.Primary_Contact__c           = contacts[1].Id;
        cp.GC_Contact__c                = contacts[2].Id;
        cp.Internal_Project_Folder_c__c   = 'asdf';
        insert cp;
        
        // Opportunity
        Opportunity opp = new Opportunity ();
        opp.AccountId                       = a.Id;
        opp.StageName                       = 'New';
        opp.CloseDate                       = Date.today();
        opp.Name                            = 'Test Opp';
        opp.Market_Segment__c               = 'Commercial Office';
        opp.Sub_Segment__c                  = 'Offices';
        opp.ARC_FAC__c                      = 'ARC';
        opp.Bid_Date_GC_to_Owner__c         = DateTime.now();
        opp.Construction_Project__c         = cp.Id;
        opp.Estimating_Divisional_Status__c = 'In Audit';
        opp.Country_Code__c                 = 'US';
        opp.Zip__c                          = '12345';
        opp.State_Code__c                   = 'IL';
        opp.Internal_Project_Folder__c      = 'asdf';
        opp.Estimating_Divisional_Status__c = 'In Audit';
        opp.Estimator__c                    = UserInfo.getUserId();
        opp.Is_Estimate_Required__c         = false;
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

        // Tasks
        Task t = new Task ();
        t.WhatId            = opp.Id;
        t.Status            = 'Open';
        t.Estimate_Type__c  = 'New';
        insert t;
    }


    private static List <Opportunity> getOpportunities () {
        return new List <Opportunity> ([Select Id, Name, ZIP__c, State__c, State_Code__c,Country__c, Country_Code__c, Territory__c, Internal_Project_Folder__c, HCA_Project_Number__c, A_E_Project_Number__c, Estimator__c, Estimating_Divisional_Status__c, StageName, No_Bid_Reason__c, OwnerId, Construction_Project__c, Is_Estimate_Required__c From Opportunity]);
    }

    private static Map <Id, Opportunity> cloneOpportunitiesToMap (List <Opportunity> opportunityList) {
        Map <Id, Opportunity> clonedOpportunityMap = new Map <Id, Opportunity> ();
        for (Opportunity opp : opportunityList) {
            Opportunity clonedOpp = opp.clone(true, true, true, true);
            clonedOpportunityMap.put(clonedOpp.Id, clonedOpp);
        }
        return clonedOpportunityMap;
    }

    private static List <Construction_Project__c> getConstructionProjects () {
        return new List <Construction_Project__c> ([Select Id, Name, Opportunity__c, HCA_Project_Number__c, A_E_Project_Number__c, Internal_Project_Folder_c__c From Construction_Project__c]);
    }


    // public static testmethod void testAfterUpdate () {

    //     // Query the test opportunities and clone them to a map so we can pass them
    //     // to trigger functionality.
    //     List    <Opportunity>       newOpps = getOpportunities();
    //     Map     <Id, Opportunity>   oldOpps = cloneOpportunitiesToMap(newOpps);

    //     Test.startTest();{

    //         // Change some fields so trigger helper functionality is hit.
    //         Opportunity newOpp = newOpps[0];
    //         newOpp.Zip__c                           = '54321';
    //         newOpp.State_Code__c                    = 'WI';
    //         newOpp.Territory__c                     = null;
    //         newOpp.Internal_Project_Folder__c       = 'erty';
    //         newOpp.HCA_Project_Number__c            = '54321';
    //         newOpp.A_E_Project_Number__c            = '54321';
    //         newOpp.Estimating_Divisional_Status__c  = 'In Process';
    //         newOpp.StageName                        = 'Closed No Bid';

    //         OpportunityTriggerHelper.afterUpdate(newOpps, oldOpps);

    //     }Test.stopTest();
    // }

    // public static testmethod void testAfterUpdate_UpdateTerritory () {

    //     // Query the test opportunities and clone them to a map so we can pass them
    //     // to trigger functionality.
    //     List    <Opportunity>       newOpps = getOpportunities();
    //     Map     <Id, Opportunity>   oldOpps = cloneOpportunitiesToMap(newOpps);

    //     Test.startTest();{

    //         // Change some fields so trigger helper functionality is hit.
    //         Opportunity newOpp = newOpps[0];
    //         Opportunity oldOpp = oldOpps.get(newOpp.Id);

    //         newOpp.Zip__c                           = '54321';
    //         newOpp.State_Code__c                    = 'WI';
    //         newOpp.Territory__c                     = null;
    //         newOpp.Internal_Project_Folder__c       = 'erty';
    //         newOpp.HCA_Project_Number__c            = '54321';
    //         newOpp.A_E_Project_Number__c            = '54321';
    //         newOpp.Estimating_Divisional_Status__c  = 'In Process';
    //         newOpp.StageName                        = 'Closed No Bid';

    //         System.debug('TEST - NEWOPP.ZIP__c'+ newOpp.Zip__c);
    //         System.debug('TEST - NEWOPP.State_Code__c'+ newOpp.State_Code__c);
    //         System.debug('TEST - NEWOPP.Country_Code__c'+ newOpp.Country_Code__c);
    //         System.debug('TEST - NEWOPP.Territory__c'+ newOpp.Territory__c);
    //         System.debug('TEST - OLDOPP.ZIP__c'+ oldOpp.Zip__c);
    //         System.debug('TEST - OLDOPP.State_Code__c'+ oldOpp.State_Code__c);
    //         System.debug('TEST - OLDOPP.Country_Code__c'+ oldOpp.Country_Code__c);
    //         System.debug('TEST - OLDOPP.Territory__c'+ oldOpp.Territory__c);

    //         OpportunityTriggerHelper.afterUpdate(newOpps, oldOpps);

    //     }Test.stopTest();
    // }


    public static testmethod void testAfterInsert () {

        // Query the test opportunities and clone them to a map so we can pass them
        // to trigger functionality.
        List    <Opportunity>       newOpps = getOpportunities();

        Test.startTest();{

            // Change some fields so trigger helper functionality is hit.
            Opportunity newOpp = newOpps[0];
            newOpp.Territory__c = null;

            OpportunityTriggerHelper.afterInsert(newOpps);

        }Test.stopTest();
    }


    public static testmethod void testBeforeInsert () {

        // Query the test opportunities and construction projects.
        List    <Opportunity>               newOpps = getOpportunities();
        List    <Construction_Project__c>   cps     = getConstructionProjects();

        Test.startTest();{

            
            
            OpportunityTriggerHelper.beforeInsert(newOpps);


            // Change some fields so trigger helper functionality is hit.
            // The construction project requires an update.
            Opportunity             newOpp  = newOpps[0];
            Construction_Project__c cp      = cps[0];

            newOpp.Is_Estimate_Required__c = true;

            cp.HCA_Project_Number__c = null;
            cp.A_E_Project_Number__c = null;
            update cp;

            OpportunityTriggerHelper.beforeInsert(newOpps);

        }Test.stopTest();
    }

}