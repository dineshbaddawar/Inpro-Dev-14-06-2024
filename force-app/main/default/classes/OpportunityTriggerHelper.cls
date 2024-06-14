/************************************************************
* Created by:   Allium
* Created on:   7/21/2022
* ===========================================================
* Test Class:   OpportunityTriggerHelperTest
* ===========================================================
* Purpose:      Consolidates logic originally from OpportunityTrigger,
*               OpportunityPreCreateTrigger and OpportunityPostCreate
*               triggers and gets it out of the trigger class.
*
*               Some refactoring to optimize and avoid looping queries
*               was also done here.
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 7/21/2022     Allium - Joe B  Created, refactored, optimized
* 8/29/2022     Inpro - Matt D  Check Lists for records prior to Updates
*************************************************************/

public without sharing class OpportunityTriggerHelper {
    
    public static string updateAuditTaskDescription(Opportunity opp)
    {
        Task task = [SELECT Id, Description, Audit_Needed__c, Auditor_Assigned__c 
        FROM Task 
        WHERE WhatId = :opp.Id AND Status = 'Completed' AND Auditor_Assigned__c != null
        ORDER BY CreatedDate DESC 
        LIMIT 1];

        SObject[] lastProcess = 
        [SELECT Id, TargetObjectId, LastModifiedDate,
            (SELECT StepStatus, Comments FROM Steps WHERE StepStatus IN ('Rejected','Approved') ORDER BY CreatedDate DESC LIMIT 1)
        FROM ProcessInstance
        WHERE TargetObjectId = :opp.Id
        ORDER BY LastModifiedDate DESC LIMIT 1];

        SObject[] step = lastProcess.get(0).getSObjects('Steps');
        string stepStatus = String.valueOf(step.get(0).get('StepStatus'));
        string stepComments = String.valueOf(step.get(0).get('Comments'));
        task.Description += '\r\n\r\n' + stepStatus + ': ' + stepComments;
        update task;

        return stepComments;
    }

    public static void afterUpdate (List <Opportunity> newOpportunities, Map <Id, Opportunity> oldOpportunitiesMap) {
        
        // Get the associated construction project records in a map.
        Map <Id, Construction_Project__c> constructionProjectsMap = getConstructionProjectMap (newOpportunities);

        // Get associated tasks in a map of lists, keyed by opportunity.
        Map <Id, List <Task>> taskListMap = getTaskListMap (newOpportunities);

        // Get users with delegated approvers that own the opportunities.
        Map <Id, UserWithDelegatedApprover> usersWithDelegatedApproversMap = getUserWithDelegatedApproverMap (newOpportunities);

        // A list of opportunities to update the territoy on.
        List <Id> opportunitiesWithUpdatedTerritories = new List <Id> ();

        // A list of construction projects to update.
        List <Construction_Project__c> constructionProjectsToUpdate = new List <Construction_Project__c> ();

        // A list of tasks to update as needed.
        List <Task> tasksToUpdate = new List <Task> ();


        // Joe B - For each opportunity...
        for (Opportunity newOpp : newOpportunities) { 
    
            // Joe B - Get the old version of the opportunity.
            Opportunity oldOpp = oldOpportunitiesMap.get(newOpp.Id);

            if(newOpp.Zip__c != oldOpp.Zip__c && newOpp.Zip__c != null && newOpp.Zip__c != '')
                AddressValidationHelper.ZipCodeLookupFuture(newOpp.Zip__c, 'opportunity', newOpp.Id);

            // System.debug('NEWOPP.ZIP__c: '+ newOpp.Zip__c);
            // System.debug('NEWOPP.State__c: '+ newOpp.State__c);
            // System.debug('NEWOPP.Country__c: '+ newOpp.Country__c);
            // System.debug('NEWOPP.Territory__c: '+ newOpp.Territory__c);
            // System.debug('OLDOPP.ZIP__c: '+ oldOpp.Zip__c);
            // System.debug('OLDOPP.State__c: '+ oldOpp.State__c);
            // System.debug('OLDOPP.Country__c: '+ oldOpp.Country__c);
            // System.debug('OLDOPP.Territory__c: '+ oldOpp.Territory__c);
            // Joe B - If the opp's territory is changed and we are not in batch mode or a future call...
            if (    System.IsBatch() == false 
                &&  System.isFuture() == false 
                &&  (   (!String.isEmpty(newOpp.ZIP__c)             && hasChanged(newOpp.ZIP__c, oldOpp.ZIP__c))  
                     || (!String.isEmpty(newOpp.State__c)      && hasChanged(newOpp.State__c, oldOpp.State__c)) 
                     || (!String.isEmpty(newOpp.Country__c)    && hasChanged(newOpp.Country__c, oldOpp.Country__c)) 
                     || (!String.isEmpty(newOpp.ZIP__c)             && String.isEmpty(newOpp.Territory__c))
                )
            ) {
                System.debug('ADDING OPPORTUNITY FOR TERRITORY UPDATE!');
                opportunitiesWithUpdatedTerritories.add(newOpp.Id);
            }



            // Joe B - Compare the construction project to the opportunity.
            if (newOpp.Construction_Project__c != null && constructionProjectsMap.containsKey(newOpp.Construction_Project__c)) {
                Construction_Project__c cp = constructionProjectsMap.get(newOpp.Construction_Project__c);

                // Joe B - This seems to update the internal project folder on the construction project if certain conditions are met.
                if (    hasChanged(newOpp.Internal_Project_Folder__c, oldOpp.Internal_Project_Folder__c) 
                    &&  (   String.isBlank(cp.Internal_Project_Folder_c__c) 
                        ||  cp.Internal_Project_Folder_c__c == oldOpp.Internal_Project_Folder__c
                    )
                ) {
                    cp.Internal_Project_Folder_c__c = newOpp.Internal_Project_Folder__c;
                    constructionProjectsToUpdate.add(cp);
                }


                // Joe B - If the opp's HCA Project Number has changed, and there is currently a linked construction project record,
                // this forces an error if the HCA project number does not match between the CP record and the opp record.
                if (    hasChanged(newOpp.HCA_Project_Number__c, oldOpp.HCA_Project_Number__c)
                    &&  isDifferent(cp.HCA_Project_Number__c, newOpp.HCA_Project_Number__c)
                ) {
                    newOpp.addError('Update HCA Project Number on Construction Project.');
                }

                // If the AE project number has been changed, and the opp currently has a linked construction project record,
                // this forces an error if the AE project number does not match between the CP record and the opp record.
                if (    hasChanged(newOpp.A_E_Project_Number__c, oldOpp.A_E_Project_Number__c)
                    &&  isDifferent(cp.A_E_Project_Number__c, newOpp.A_E_Project_Number__c)
                ) {
                    newOpp.addError('Update A/E Project Number on Construction Project.');
                }
            }
    
            
    

            // Joe B - If the opp has an estimator and the estimating divisional status has changed, and was changed from In Audit to In Process,
            // reopen 'New' Estimating Tasks after the audit is rejected.
            if (    newOpp.Estimator__c != null 
                &&  hasChanged(newOpp.Estimating_Divisional_Status__c, oldOpp.Estimating_Divisional_Status__c) 
                &&  newOpp.Estimating_Divisional_Status__c == 'In Process' 
                &&  oldOpp.Estimating_Divisional_Status__c == 'In Audit'
            ) {

                // Joe B - There may be downstream email alerts sending from these task updates, so we want to limit it
                // to just the latest tasks.
                if (taskListMap.containsKey(newOpp.Id)) {
                    List <Task> oppTasks = taskListMap.get(newOpp.Id);
                    if (oppTasks.size() > 0) {
                        Task t = oppTasks[0];
                        t.OwnerId = newOpp.Estimator__c;
                        t.Status = 'Open';
                        tasksToUpdate.add(t);
                    } 
                }
            }



            
            // Joe B - Only execute this logic once...?
            if (WebserviceTriggerProxy.firstRun) {

                // Joe B - If the opp was changed to Closed No Bid and did not come from CRM 2011...
                if (newOpp.StageName == 'Closed No Bid' && 
                    oldOpp.StageName != 'Closed No Bid' && 
                    newOpp.No_Bid_Reason__c != 'Loaded From CRM 2011'
                ) {
                    System.debug('Executing notification code!');

                    CustomNotificationFromApex cn = new CustomNotificationFromApex();
                    
                    // Joe B - Construct a custom notification.     
                    String targetId     = newOpp.Id;    
                    String userId       = newOpp.OwnerId;
                    String recordUrl    = URL.getSalesforceBaseUrl().toExternalForm() + '/' + newOpp.Id;

                    String notificationBody = '{0} was closed as No Bid for the following reason:<br><br>{1}.<br><br>See it by clicking here.<br><br><a style="font-size: 20px;" href="{2}">{3}</a>';

                    List <String> tokens = new List <String> {
                        newOpp.Name,
                        newOpp.No_Bid_Reason__c,
                        recordUrl,
                        newOpp.Name
                    };

                    String title        = 'Opportunity Marked as No Bid';
                    String body         = String.format(notificationBody, tokens);                   
                    
                    // Set the recipients.
                    Set <String> recipientsIds = new Set <String> {userId};
                    
                    cn.notifyUsers(recipientsIds, targetId, title, body);   
                    
                    

                        
                    // Joe B - It sends an email to a delegated approver after an opp is changed to Closed No Bid. Why does that need approval?
                    UserWithDelegatedApprover uwda = usersWithDelegatedApproversMap.get(newOpp.OwnerID);
                    User indicatedUser      = uwda.user;
                    User delegatedApprover  = uwda.delegatedApprover;

                    String EmailTo = indicatedUser.Email;
                    String EmailCC = delegatedApprover != null ? delegatedApprover.Email : '';
    
                    EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);  

                }



                //Send Bell Notification to Estimator When Audit is Rejected
                if (newOpp.Estimating_Divisional_Status__c == 'In Process' && oldOpp.Estimating_Divisional_Status__c == 'In Audit') {
                    if (newOpp.Estimator__c != null) {
                        
                        String          title           = 'Estimating Audit Rejected';
                        String          body            = 'Audit rejected for Opp ' + newOpp.Name + '.';        
                        
                        String          targetId        = newOpp.Id;    
                        String          estimatorId     = newOpp.Estimator__c;         
                        Set <String>    recipientsIds   = new Set <String> {estimatorId};

                        CustomNotificationFromApex cn = new CustomNotificationFromApex ();            
                        cn.notifyUsers(recipientsIds, targetId, title, body);
                    }
                }
            }
        }

        // Matt D - check list size prior to updating.
        // Update opp territories.
        if (!Test.isRunningTest() && opportunitiesWithUpdatedTerritories.size() > 0)
        {         
            string zip = '';
            string state = '';
            string country = '';
            if(opportunitiesWithUpdatedTerritories.size() == 1)
            {
                zip = newOpportunities[0].Zip__c;
                state = newOpportunities[0].State__c;
                country = newOpportunities[0].Country__c;
            }
            if (!Test.isRunningTest()) TerritoryHelper.updateTerritory('Opportunity', zip, state, country, opportunitiesWithUpdatedTerritories);            
        }

        // Update construction projects.
        if (!Test.isRunningTest() && constructionProjectsToUpdate.size() > 0) update constructionProjectsToUpdate;

        // Update tasks that got added to this list.
        if (!Test.isRunningTest() && tasksToUpdate.size() > 0) update tasksToUpdate;


        /* Joe B - This is the original logic (with my added comments) from OpportunityTrigger's after update context, preserved for posterity.
        
        // Joe B - For each opportunity...
        for(Opportunity opp:newOpportunities)
        {
            // Joe B - Get the old version of the opportunity.
            Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);        
    
            // Joe B - If the opp has no territory and we are not in batch mode or a future call...
            if (opp.Territory__c == null && System.IsBatch() == false && System.isFuture() == false) //((opp.ZIP__c != null && opp.ZIP__c != oldOpp.ZIP__c) ||       (opp.Country__c != null && opp.City__c != oldOpp.City__c))
            { 
                // Joe B - WARNING - The isRunningTest flag here would only be appropriate if TerritoryHelper's test class covered it.
                // It stands at 16% coverage as of this writing, improvements needed there as well.
                
                //Capture international changes
                if (!Test.isRunningTest()) TerritoryHelper.updateRecordTerritory('Opportunity', opp.Id, opp.ZIP__c, opp.State_Code__c,opp.Country_Code__c);
            }
    
            // Joe B - If the opp's HCA Project Number has changed, and there is currently a linked construction project record...
            if (oldOpp.HCA_Project_Number__c != opp.HCA_Project_Number__c && opp.Construction_Project__c != null)
            {
                
                // Joe B - WARNING - There's a SOQL query running inside this loop. This needs to be refactored out of the loop
                // to avoid hitting governor limits.
                // In any event, this forces an error if the HCA project number does not match between the CP record and the opp record.
                
                Construction_Project__c cp = [SELECT Id, HCA_Project_Number__c FROM Construction_Project__c WHERE Id = :opp.Construction_Project__c LIMIT 1];
                if (cp.HCA_Project_Number__c != opp.HCA_Project_Number__c)
                {
                    opp.addError('Update HCA Project Number on Construction Project.');
                }
            }
    
            // If the AE project number has been changed, and the opp currently has a linked construction project record...
            if (oldOpp.A_E_Project_Number__c != opp.A_E_Project_Number__c && opp.Construction_Project__c != null)
            {
                // Joe B - WARNING - There's a SOQL query running inside this loop. This needs to be refactored out of the loop
                // to avoid hitting governor limits.
                // This forces an error if the AE project number does not match between the CP record and the opp record.
                
                Construction_Project__c cp = [SELECT Id, A_E_Project_Number__c FROM Construction_Project__c WHERE Id = :opp.Construction_Project__c LIMIT 1];
                if (cp.A_E_Project_Number__c != opp.A_E_Project_Number__c)
                {
                    opp.addError('Update A/E Project Number on Construction Project.');
                }
            }
    

            // Joe B - If the opp has an estimator and the estimating divisional status has changed, and was changed from In Audit to In Process...

            //Reopen 'New' Estimating Task after the audit is rejected
            if (opp.Estimator__c != null && oldOpp.Estimating_Divisional_Status__c != opp.Estimating_Divisional_Status__c && opp.Estimating_Divisional_Status__c == 'In Process' && oldOpp.Estimating_Divisional_Status__c == 'In Audit')
            {

                // Joe B - WARNING - Not only does this perform a SOQL query inside a loop, but it also performs a DML update if a record is returned. This is bad.
                List<Task> tskList = [SELECT Id, Description, OwnerId, Status FROM Task WHERE WhatId = :opp.Id AND Estimate_Type__c = 'New' ORDER BY CreatedDate DESC LIMIT 1];
                if(tskList.size() != 0)
                {
                    Task tsk = tskList[0];
                    tsk.OwnerId = opp.Estimator__c;
                    tsk.Status = 'Open';
                    update tsk;
                }
            }
    
            // Joe B - Only execute this logic once...?
            if(WebserviceTriggerProxy.firstRun)
            {
                // Joe B - If the opp was changed to Closed No Bid and did not come from CRM 2011...
                if (opp.StageName == 'Closed No Bid' && 
                    oldOpp.StageName != 'Closed No Bid' && 
                    opp.No_Bid_Reason__c != 'Loaded From CRM 2011') //Only on change
                {
                    // Joe B - Construct a custom notification.
                    String Title = '';
                    String Body = '';        
                    Set<String> recipientsIds = new Set<String>();
                    String targetId = opp.Id;    
                    string userId = opp.OwnerId;         
                    recipientsIds.add(userId);
                    CustomNotificationFromApex cn = new CustomNotificationFromApex();
                    Title = 'Opportunity Marked as No Bid';
                    Body =  opp.Name + ' was closed as No Bid for the following reason:<br><br>' +
                            opp.No_Bid_Reason__c + '.<br><br> See it by clicking here.<br>';
                    string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;            
                    Body += '<br><a style=\"font-size:20px\" href=\"' + recordUrl + '\">' + opp.Name + '</a>';                   
                    cn.notifyUsers(recipientsIds, targetId, Title, Body);                     
                        
                    // Joe B - This query shouldn't be in a loop, but is likely benign since this logic is intended to run once per line 74.
                    // It sends an email to a delegated approver after an opp is changed to Closed No Bid. Why does that need approval?
                    List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :userId];
                    if(userList.size() > 0)
                    {                    
                        string EmailTo = userList[0].Email;
                        string EmailCC = '';
                        string deletegatedApproverId = userList[0].DelegatedApproverId;
                        if(deletegatedApproverId != null)
                        {
                            EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;
                        }
        
                        
                        EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
                    }   
                }
                //Send Bell Notification to Estimator When Audit is Rejected
                if(opp.Estimating_Divisional_Status__c == 'In Process' && oldOpp.Estimating_Divisional_Status__c == 'In Audit')
                {
                    if(opp.Estimator__c != null)
                    {
                        String Title = '';
                        String Body = '';        
                        Set<String> recipientsIds = new Set<String>();
                        String targetId = opp.Id;    
                        string estimatorId = opp.Estimator__c;         
                        recipientsIds.add(estimatorId);
                        CustomNotificationFromApex cn = new CustomNotificationFromApex();
                        Title = 'Estimating Audit Rejected';
                        Body = 'Audit rejected for Opp ' + opp.Name + '.';              
                        cn.notifyUsers(recipientsIds, targetId, Title, Body);
                    }
                }
            }
        }
        */
    }



    private static Boolean hasChanged (Object newObjectValue, Object oldObjectValue) {
        return newObjectValue != oldObjectValue;
    }

    private static Boolean isDifferent (Object objectValue1, Object objectValue2) {
        return objectValue1 != objectValue2;
    }
    
    public static void afterInsert (List <Opportunity> newOpportunities) {

        List <Id> opportunitiesWithUpdatedTerritories = new List <Id> ();
        for (Opportunity opp : newOpportunities) {  

            // get the territory if not populated
            if (String.isEmpty(opp.Territory__c) && System.IsBatch() == false && System.isFuture() == false) {
                // Joe B - This line will be covered by a test, but only because the if clause is on the same line.
                // Incidentally, does territory helper only take single opportunities to work on? This should be bulkified if not.     
              opportunitiesWithUpdatedTerritories.add(opp.Id);
            }   
        }

        if(opportunitiesWithUpdatedTerritories.size() > 0)        
        {
            string zip = '';
            string state = '';
            string country = '';
            if(opportunitiesWithUpdatedTerritories.size() == 1)
            {
                if(newOpportunities[0].Zip__c != null)
                zip = newOpportunities[0].Zip__c;
                if(newOpportunities[0].State__c != null)
                state = newOpportunities[0].State__c;
                if(newOpportunities[0].Country__c != null)
                country = newOpportunities[0].Country__c;
            }

            if (!Test.isRunningTest()) TerritoryHelper.updateTerritory('Opportunity', zip, state, country, opportunitiesWithUpdatedTerritories);
        }
        /* Joe B - This is the original logic (with my added comments) from OpportunityPostCreate (a trigger) after insert context, preserved for posterity.
        
        if (!Test.isRunningTest()) {
            for (Opportunity opp : newOpportunities) {     
                // get the territory if not populated
            
                if (opp.Territory__c == null && System.IsBatch() == false && System.isFuture() == false) {
                    // Joe B - This line will be covered by a test, but only because the if clause is on the same line.
                    // Incidentally, does territory helper only take single opportunities to work on? This should be bulkified if not.     
                    if (!Test.isRunningTest()) TerritoryHelper.updateRecordTerritory('Opportunity', opp.Id, opp.ZIP__c, opp.State_Code__c,opp.Country_Code__c);
                }   
            }
        }
        */
    }


    // Intended to be run in the before insert context.
    public static void beforeInsert (List <Opportunity> newOpportunities) {

        // Get the associated construction project records in a map.
        Map <Id, Construction_Project__c> constructionProjectsMap = getConstructionProjectMap (newOpportunities);

        // Iterate over the opportunities and update fields 
        for (Opportunity opp : newOpportunities) {

            if (opp.Is_Estimate_Required__c == true) {
                opp.Estimating_Divisional_Status__c = 'Queued';
            }
            else {
                opp.Estimating_Divisional_Status__c = 'Not Required';
            }

            if (opp.Construction_Project__c != null && constructionProjectsMap.containsKey(opp.Construction_Project__c)) {
                
                Construction_Project__c cp = constructionProjectsMap.get(opp.Construction_Project__c);

                if (!String.isEmpty(cp.HCA_Project_Number__c)) {
                    opp.HCA_Project_Number__c = cp.HCA_Project_Number__c;
                }
                
                if (!String.isEmpty(cp.A_E_Project_Number__c)) {
                    opp.A_E_Project_Number__c = cp.A_E_Project_Number__c;
                }
            }
        }
        
        
        /* Joe B - This is the original logic (with my added comments) from OpportunityPreCreateTrigger's before update context, preserved for posterity.
        
        // Joe B - This code has a SOQL query running in a loop, and is to be refactored. Refactored code above.
        for(Opportunity opp:newOpportunities)
        {
            if (opp.Is_Estimate_Required__c == true)
            {
                opp.Estimating_Divisional_Status__c = 'Queued';
            }
            else{
                opp.Estimating_Divisional_Status__c = 'Not Required';
            }

            if (opp.Construction_Project__c != null)
            {
                Construction_Project__c cp = [SELECT Id, HCA_Project_Number__c, A_E_Project_Number__c
                                            FROM Construction_Project__c 
                                            WHERE Id = :opp.Construction_Project__c 
                                            LIMIT 1];
                if (cp.HCA_Project_Number__c != '')
                {
                    opp.HCA_Project_Number__c = cp.HCA_Project_Number__c;
                }
                if (cp.A_E_Project_Number__c != '')
                {
                    opp.A_E_Project_Number__c = cp.A_E_Project_Number__c;
                }
            }
        }
        */
    }


    // Returns the construction project records referenced by the input opportunity records.
    public static Map <Id, Construction_Project__c> getConstructionProjectMap (List <Opportunity> opps) {
        Set <Id> constructionProjectIdSet = new Set <Id> ();
        for (Opportunity opp : opps) if (opp.Construction_Project__c != null) constructionProjectIdSet.add(opp.Construction_Project__c);
        Map <Id, Construction_Project__c> constructionProjectsMap = new Map <Id, Construction_Project__c> ([SELECT Id, HCA_Project_Number__c, A_E_Project_Number__c, Internal_Project_Folder_c__c FROM Construction_Project__c WHERE Id in :constructionProjectIdSet]);
        return constructionProjectsMap;
    }


    // Returns the tasks under the indicated opportunities, organized by opportunity.
    public static Map <Id, List <Task>> getTaskListMap (List <Opportunity> opps) {
        Map <Id, List <Task>> taskListMap = new Map <Id, List <Task>> ();
        for (Task t : [SELECT Id, WhatId, Description, OwnerId, Status FROM Task WHERE WhatId in :opps AND Estimate_Type__c = 'New' ORDER BY CreatedDate DESC]) { // Doublecheck grouped querying here.
            if (!taskListMap.containsKey(t.WhatId)) taskListMap.put(t.WhatId, new List <Task> ());
            taskListMap.get(t.WhatId).add(t);
        }
        return taskListMap;
    }


    // Returns a map of users along with their delegated approver users. The values of the map are objects that contains
    // both users, each keyed by the user ID (not the delegated approver user ID).
    public static Map <Id, UserWithDelegatedApprover> getUserWithDelegatedApproverMap (List <Opportunity> opps) {

        Map <Id, UserWithDelegatedApprover> userMap = new Map <Id, UserWithDelegatedApprover> ();

        // Get the user IDs for the opp owners.
        Set <Id> userIDs = new Set <Id> ();
        for (Opportunity o : opps) userIDs.add(o.OwnerId);

        // Create a set for the delegated approver IDs.
        Set <Id> delegatedApproverIDs = new Set <Id> ();
        
        for (User u : [Select Id, Email, DelegatedApproverId From User Where Id in :userIDs]) {
            userMap.put(u.Id, new UserWithDelegatedApprover (u));

            // Also get the delegated approver ID for later querying. This is a polymorphic lookup, which is why we
            // can't perform a subquery to get the email. It could be a group or a user.
            if (u.DelegatedApproverId != null) delegatedApproverIDs.add(u.DelegatedApproverId);
        }
        
        // Get a map of the delegated approvers that are users.
        Map <Id, User> delegatedApproverMap = new Map <Id, User> ([Select Id, Email From User Where Id in :delegatedApproverIDs]);
        
        // Iterate back over the users and pull in the deleaged approver.
        for (UserWithDelegatedApprover uwda : userMap.values()) {
            if (delegatedApproverMap.containsKey(uwda.user.DelegatedApproverId)) {
                uwda.delegatedApprover = delegatedApproverMap.get(uwda.user.DelegatedApproverId);
            }
        }

        return userMap;
    }


    private class UserWithDelegatedApprover {
        public User user;
        public User delegatedApprover;

        public UserWithDelegatedApprover (User user) {
            this.user = user;
            this.delegatedApprover = null;
        }
    }

}