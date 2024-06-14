/************************************************************
* Created by:   Allium
* Created on:   6/28/2022
* ===========================================================
* Test Class:   OpportunityContactRoleUtilityTest
* ===========================================================
* Purpose:      Manages the contact roles associated with an opportunity.
*               Does so by analyzing the state of the associated construction project record,
*               and the related list of Bidder records.
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 6/28/2022     Allium - Joe B  Created
*************************************************************/

public without sharing class OpportunityContactRoleUtility {
    
    private static Boolean alreadyRan = false;
    public static Boolean hasNotAlreadyRan () {
        if (!alreadyRan) {
            alreadyRan = true;
            return true;
        }
        else {
            return false;
        }
    }
    
    
    @TestVisible
    public static void resetAlreadyRanFlag () {
        alreadyRan = false;
    }
    
    
    
    public static final String ARCHITECT_ROLE_NAME 						= 'Architect';
    public static final String PRIMARY_CONSTRUCTION_CONTACT_ROLE_NAME 	= 'Primary Construction Project Contact';
    public static final String CM_CONTACT_ROLE_NAME 					= 'CM Contact';
    public static final String BIDDER_ROLE_NAME 						= 'Bidder';
    
    
    
    public static void updateContactRolesForOpportunities (List <Bidder__c> bidders) {
        Set <Id> oppIds = new Set <Id> ();
        for (Bidder__c bidder : bidders) oppIds.add(bidder.Opportunity__c);
        List <Opportunity> opps = new List <Opportunity> ([Select Id From Opportunity Where Id in :oppIds]);
        updateContactRolesForOpportunities(opps);
    }
    
    
    public static void updateContactRolesForOpportunities (List <Construction_Project__c> constructionProjects) {
        for (Construction_Project__c cp : constructionProjects) System.debug('CP ID: '+ cp.Id);
        List <Opportunity> opps = new List <Opportunity> ([Select Id From Opportunity Where Construction_Project__c in :constructionProjects]);
        System.debug('Opps: '+opps);
        updateContactRolesForOpportunities(opps);
    }


    public static void updateContactRolesForOpportunity (Opportunity opp) {
        updateContactRolesForOpportunities(new List <Opportunity> {opp});
    }
    
    
    public static void updateContactRolesForOpportunities (List <Opportunity> inputOpps) {
        
        // Get the opportunities and related records we need to examine.
        List <Opportunity> opps = getOppsAndRelatedRecords(inputOpps);
        
        // Create lists of opportunity contact roles to insert or delete.
        List <OpportunityContactRole> ocrsToDelete = new List <OpportunityContactRole> ();
        List <OpportunityContactRole> ocrsToInsert = new List <OpportunityContactRole> ();
        
        // For each opp, examine the roles to match them up with the related construction project records.
        for (Opportunity opp : opps) processOCRs(opp, ocrsToDelete, ocrsToInsert);
        
        // DML our deletes and inserts.
        delete ocrsToDelete;
        insert ocrsToInsert;
    }
    
    
    private static void processOCRs (Opportunity opp, List <OpportunityContactRole> ocrsToDelete, List <OpportunityContactRole> ocrsToInsert) {
		        
        // Figure out what our main roles are and map them.
        Map <String, OpportunityContactRole> mainRolesMap = mapMainRoles(opp.OpportunityContactRoles);
        
        // These will be populated with the IDs of contacts on the linked construction project, if possible.
        // If the CP is null or the indicated contact is null, it indicates the absence of a contact.
        // Passing null into the processRole method below will effectively remove that opportunity contact role,
        // but passing a value will add one.
        Id architectContactId 	= null;
        Id primaryContactId 	= null;
        Id gcContactId			= null;
        
        // If we have a linked construction project, check the roles on it.
        if (opp.Construction_Project__r != null) {
            Construction_Project__c cp = opp.Construction_Project__r;
            
            if 	(cp.Architect_Contact__c != null)	architectContactId 	= cp.Architect_Contact__c;
            if 	(cp.Primary_Contact__c != null)		primaryContactId 	= cp.Primary_Contact__c;
            if 	(cp.GC_Contact__c != null) 			gcContactId 		= cp.GC_Contact__c;
        }
        
        processRole(opp.Id, architectContactId, ARCHITECT_ROLE_NAME, 					mainRolesMap, ocrsToDelete, ocrsToInsert);
        processRole(opp.Id, primaryContactId, 	PRIMARY_CONSTRUCTION_CONTACT_ROLE_NAME, mainRolesMap, ocrsToDelete, ocrsToInsert);
        processRole(opp.Id, gcContactId, 		CM_CONTACT_ROLE_NAME, 					mainRolesMap, ocrsToDelete, ocrsToInsert);
        

        // Now, we need to scan the construction projects in the related list and the roles for bidders. Map both.
        Map <Id, OpportunityContactRole> 	bidderOCRMap 	= mapBidderOCRs(opp.OpportunityContactRoles);
        Set <Id> 							bidderCPSet 	= mapBidders(opp.Bidders__r);

        // Cross-compare the map and set to figure out what bidders we want to add or remove.
        processBidders(opp.Id, bidderOCRMap, bidderCPSet, ocrsToDelete, ocrsToInsert);
    }
    
    
    private static void processBidders (Id oppId, Map <Id, OpportunityContactRole> bidderOCRMap, Set <Id> bidderSet, List <OpportunityContactRole> ocrsToDelete, List <OpportunityContactRole> ocrsToInsert) {
		
        // Look through the current contact roles. If they don't exist in the construction project
        // related list, we can remove them.
        for (OpportunityContactRole ocr : bidderOCRMap.values()) {
            if(!bidderSet.contains(ocr.ContactId)) {
                ocrsToDelete.add(ocr);
            }
        }

        // On the other hand, if a construction project exists but isn't a contact role, add that.
        for (Id contactId : bidderSet) {
            if (!bidderOCRMap.containsKey(contactId)) {
                ocrsToInsert.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = contactId, Role = BIDDER_ROLE_NAME));
            }
        }
    }
    
    
    private static Map <String, OpportunityContactRole> mapMainRoles (List <OpportunityContactRole> ocrList) {

        // Create a map that will contain the roles we already have on the opportunity.
        Map <String, OpportunityContactRole> mainRolesMap = new Map<String, OpportunityContactRole> ();
        
        // Iterate over the opp's roles and pick out the ones that match specific role names we're looking for.
        for (OpportunityContactRole ocr : ocrList) {
            if 		(ocr.Role == ARCHITECT_ROLE_NAME) 						mainRolesMap.put(ARCHITECT_ROLE_NAME, 						ocr);
			else if (ocr.Role == PRIMARY_CONSTRUCTION_CONTACT_ROLE_NAME) 	mainRolesMap.put(PRIMARY_CONSTRUCTION_CONTACT_ROLE_NAME, 	ocr);
			else if (ocr.Role == CM_CONTACT_ROLE_NAME) 						mainRolesMap.put(CM_CONTACT_ROLE_NAME, 						ocr);
        }
        
        return mainRolesMap;
    }
    
    
    public static void processRole (Id oppId, Id contactId, String roleName, Map <String, OpportunityContactRole> mainRolesMap,  
                                   List<OpportunityContactRole> ocrsToDelete, List<OpportunityContactRole> ocrsToInsert) {
	
        // Get the existing role (if any) out of the roles map for the opp.
        OpportunityContactRole ocr = mainRolesMap.get(roleName);                               
        
        // If we have a contact to check...              
        if (contactId != null) {
            
            // If the map contains the role being checked for...
            if (mainRolesMap.containsKey(roleName)) {

                // ... and if the existing contact does not match the indicated contact for the role...
                if (ocr.contactId != contactId) {
    				
                    // Slate the existing role for deletion, and add the new role for insertion.
                    ocrsToDelete.add(ocr);
                    ocrsToInsert.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = contactId, Role = roleName));
                }
            } 
            else {
    			
                // We didn't find the existing role, so just add the indicated contact for insertion.
                ocrsToInsert.add(new OpportunityContactRole(OpportunityId = oppId, ContactId = contactId, Role = roleName));
            }
        } 
        else {
            
            // If we're here, the indicated contact is null (we didn't find that relationship in the associated construction project).
            if (mainRolesMap.containsKey(roleName)) {
				
                // We have an existing role but no matching contact, so slate the existing role for deletion.
                ocrsToDelete.add(ocr);
            }
        }
    }
    
    
    private static List <Opportunity> getOppsAndRelatedRecords (List <Opportunity> inputOpps) {
        return new List <Opportunity> ([
            Select 
            	Id,
            	Name,
            	Construction_Project__c,
            	Construction_Project__r.Architect_Contact__c, 
                Construction_Project__r.Primary_Contact__c,	
                Construction_Project__r.GC_Contact__c, 
            	(Select Id, Contact__c From Bidders__r Where Contact__c != null),
            	(Select Id, ContactId, OpportunityId, Role From OpportunityContactRoles)
            From
            	Opportunity
            Where
            	Id in :inputOpps
            Order By
            	AccountId, 
                Id			
        ]);
    }
    


    

    


    public static Map <Id, OpportunityContactRole> mapBidderOCRs (List <OpportunityContactRole> ocrList) {

        // Map just the roles which are bidders.
        Map <Id, OpportunityContactRole> ocrsByContactIdMap = new Map<Id, OpportunityContactRole>();

        for (OpportunityContactRole ocr : ocrList) {
            if (ocr.Role == BIDDER_ROLE_NAME) {
                ocrsByContactIdMap.put(ocr.contactId, ocr);
            }
        }

        return ocrsByContactIdMap;
    }

    
    
    public static Set <Id> mapBidders (List <Bidder__c> bidderList) {

        Set <Id> bidderContactIDs = new Set <Id> ();

        for (Bidder__c bidder : bidderList) {
            bidderContactIDs.add(bidder.Contact__c); 
        }

        return bidderContactIDs;
    }
    
    
    
}