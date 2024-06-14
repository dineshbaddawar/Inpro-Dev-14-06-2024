/************************************************************
* Created by:   The Hunley Group
* Created on:   3/25/2021
* ===========================================================
* Test Class:   
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 3/25/2021       THG - Tyler    Created
*************************************************************/
public with sharing class AccountTriggerHandler {
    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;
    private List<Account> trigNew;
    private List<Account> trigOld;
    private Boolean isDelete;



    // Constructor used for Before/After Update handler
    public AccountTriggerHandler(Map<Id, Account> triggerOldMap,  Map<Id, Account> triggerNewMap, List<Account> triggerOld, List<Account> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;

        setupData();
    }

    //Private void method that will stage local variables and related data for use within the rest of the handler
    private void setupData() {
    }

    public void beforeInsert() {
        doIsParentCheckOnAnyParentAccount();
    }

    public void beforeDelete() {
    }

    //Public void method called After Delete from the Account Trigger
    public void afterDelete() {
        doIsParentCheckOnAnyParentAccount();
    }


    //Public void method called After Insert from the Account Trigger
    public void afterInsert() {
    }

    //Public void method called Before Update from the Account Trigger
    public void beforeUpdate() {
    }

    //Public void method called After Update from the Account Trigger
    public void afterUpdate() {
        doIsParentCheckOnAnyParentAccount();
        //handleUltimateParentChangesOnUpdate();
    }

    private Set<Id> handleUltimateParentChangesOnUpdate() {
        Set<Id> recomputeUltimateParents = new Set<Id>();
        Set<Id> recomputeAllChildren = new Set<Id>();

        for(Id aid : this.newMap.keySet()) {
            Account oldA = this.oldMap.get(aid);
            Account newA = this.newMap.get(aid);

            // NEW LOGIC
            //  if my parent changed, then myself and any other accounts that match my ultimate parent, or i was parent to must be re-evaluated
            if (oldA.ParentId != newA.ParentId) {  // if a change in parent took place:
                recomputeAllChildren.add(oldA.Id);
                if (oldA.Ultimate_Parent_Account__c != null) {
                    recomputeAllChildren.add(oldA.Ultimate_Parent_Account__c);
                }
                if (oldA.ParentId != null) {
                    recomputeAllChildren.add(oldA.ParentId);
                }
                if (newA.ParentId != null) {
                    recomputeAllChildren.add(newA.ParentId);
                }

            }
        }

        List<Account> recomputers = [SELECT Id FROM Account WHERE Ultimate_Parent_Account__c IN :recomputeAllChildren OR Id IN :recomputeAllChildren OR ParentId IN :recomputeAllChildren];
        for(Account ac : recomputers) {
            recomputeUltimateParents.add(ac.Id);
        }
        return recomputeUltimateParents;
    }


    private void doIsParentCheckOnAnyParentAccount() {
        system.debug('#@# AccountTriggerHandler.doIsParentCheckOnAnyParentAccount: BEGIN');
        
        Map<Id, Integer> x = new Map<Id, Integer>();//add map
        List<Account> updates = new List<Account>();//change set to list
        
        Set<Id> childrenThatChanged = new Set<Id>();
        Set<Id> recomputeUltimateParents = new Set<Id>();

        if (this.trigOld == null) {  // on before insert
            Set<Id> accountsToQuery = new Set<Id>();
            for(Account ac : this.trigNew) {
                if (ac.ParentId != null) {
                    accountsToQuery.add(ac.ParentId);
                }
            }
            Map<Id, Account> accts = new Map<Id, Account>([SELECT Id, Is_Parent__c, Ultimate_Parent_Account__c FROM Account WHERE Id IN :accountsToQuery]);
            for(Account a : accts.values()) {
                if (!a.Is_Parent__c) {
                    a.Is_Parent__c = true;
                    if (!updates.contains(a)) {
                        updates.add(a);
                    }
                }
                // loop thru all new accounts....for each one, determine if the parent ID is the ultimate, or not
                // (if MY parent has an ultimate parent, that one is ALSO my ultimate parent)
                for(Account ac : this.trigNew) {
                    if (ac.ParentId == a.Id) {
                        if (a.Ultimate_Parent_Account__c != null) {
                            ac.Ultimate_Parent_Account__c = a.Ultimate_Parent_Account__c;
                        } else {
                            ac.Ultimate_Parent_Account__c = a.Id;
                        }
                    }
                }
            }

        } else if (this.trigNew == null) {  // after delete
            Set<Id> oldParentAccountsToQuery = new Set<Id>();
            Set<Id> allDeletedAccounts = new Set<Id>();
            Set<Id> allDeletedAccountsUltimateParents = new Set<Id>();

            // find any parent accounts set for the records we are about to delete
            for(Account ac : this.trigOld) {
                if (ac.ParentId != null) {
                    oldParentAccountsToQuery.add(ac.ParentId);
                }
                if (ac.Ultimate_Parent_Account__c != null) {
                    allDeletedAccountsUltimateParents.add(ac.Ultimate_Parent_Account__c);
                }
                allDeletedAccounts.Add(ac.Id);
            }
            Map<Id, Account> allChildAccts = new Map<Id, Account>([SELECT Id, Is_Parent__c, ParentId, Ultimate_Parent_Account__c FROM Account
            where ParentId in :new List<Id>(oldParentAccountsToQuery)]);
            for(Account a : allChildAccts.values()) {
                // if a child acct is found, remove this one from our update id list:
                if (oldParentAccountsToQuery.contains(a.ParentId)) {
                    oldParentAccountsToQuery.remove(a.ParentId);
                }
            }
            // set each remaining account to have isparent flagged to false:
            List<Account> updatess = [SELECT Id, Is_Parent__c FROM Account WHERE Id IN :(new List<Id>(oldParentAccountsToQuery))];
            for(Account a : updatess) {
                a.Is_Parent__c = false;
                updates.add(a);
            }
            // find all accounts where Ultimate parent was one of our deleted accounts OR one of our deleted acct's ultimate parents:
            Map<Id, Account> orphanedPreviousUltimates = new Map<Id, Account>([SELECT Id, Is_Parent__c, ParentId, Ultimate_Parent_Account__c FROM Account
            WHERE Ultimate_Parent_Account__c IN :allDeletedAccounts
            OR Ultimate_Parent_Account__c IN :allDeletedAccountsUltimateParents
            ]);
            for(Account ac : orphanedPreviousUltimates.values()) {
                recomputeUltimateParents.add(ac.Id);
            }

        } else { // after update:

            Set<Id> newParentsToFlag = new Set<Id>();
            Set<Id> parentsToCheckForClear = new Set<Id>();

            for(Id aid : this.newMap.keySet()) {
                Account oldA = this.oldMap.get(aid);
                Account newA = this.newMap.get(aid);

                if (oldA.ParentId != newA.ParentId) {  // if a change in parent took place:

                    childrenThatChanged.add(aid);

                    if (oldA.ParentId != null && newA.ParentId != null) { // if a parent was swapped for a parent:
                        parentsToCheckForClear.add(oldA.ParentId);
                        newParentsToFlag.add(newA.ParentId);
                    } else if (newA.ParentId != null) {  // old was null, now have new parent
                        newParentsToFlag.add(newA.ParentId);
                        parentsToCheckForClear.add(newA.Id);  // old may have been a parent...check it
                    } else {   // new is null, old must be populated
                        parentsToCheckForClear.add(oldA.ParentId);
                    }
                }
            }



            // autoflag all of our ADDS:
            Map<Id, Account> accts = new Map<Id, Account>([SELECT Id, Is_Parent__c, ParentId FROM Account
            WHERE Id IN :(new List<Id>(newParentsToFlag))]);
            for(Account a : accts.values()) {
                if (!a.Is_Parent__c) {  // if previously was NOT a parent
                    a.Is_Parent__c = true;
                    updates.add(a);
                }
            }


            // check all of our possible CLEARS:
            accts = new Map<Id, Account>([SELECT Id, Is_Parent__c, ParentId FROM Account
            WHERE ParentId IN :(new List<Id>(parentsToCheckForClear))]);
            for(Account a : accts.values()) {
                // if a child acct is found, remove this one from our update id list:
                if (parentsToCheckForClear.contains(a.ParentId)) {
                    parentsToCheckForClear.remove(a.ParentId);
                }
            }
            // set each remaining account to have isparent flagged to false:
            List<Account> clears = [SELECT Id, Is_Parent__c FROM Account WHERE Id IN :(new List<Id>(parentsToCheckForClear))];
            for(Account a : clears) {
                if (a.Is_Parent__c) {  // if previously WAS a parent
                    a.Is_Parent__c = false;
                    updates.add(a);
                }
            }

            // finally, call out ultimate parent handler function:
            recomputeUltimateParents = handleUltimateParentChangesOnUpdate();

        }

        //recomputeUltimateParents(recomputeUltimateParents, updates);

        system.debug('Updating accounts: ' + updates);
        update new List<Account>(updates);

        // append any updates to our childrenThatChanged list:
        for(Account up : new List<Account>(updates)) {
            childrenThatChanged.add(up.Id);
        }
/* Inpro does not have Project Account Roles nor Opportunity Account Roles
        // finally, call our OpportunityAccountRole handler to handle any matching OARs for these children that changed
        if (childrenThatChanged.size() > 0) {
            ProjectAccountRoleTriggerHandler.forceAccountParentResync(childrenThatChanged);
        }
*/
    system.debug('#@# AccountTriggerHandler.doIsParentCheckOnAnyParentAccount: END');
}

    /**
    private void recomputeUltimateParents(Set<Id> accts, List<Account> updates) {
        system.debug('#@# AccountTriggerHandler.recomputeUltimateParents: BEGIN');

//New_____________________________
        Set<Id> accountUpdateIdSet = new Set<Id>();

        for (Account uac : updates) {
            accountUpdateIdSet.add(uac.id);
        } 
//___________________________________________


        List<Account> accounts = [SELECT Id,
                Parent.Id,
                Parent.Parent.Id,
                Parent.Parent.Parent.Id,
                Parent.Parent.Parent.Parent.Id,
                Parent.Parent.Parent.Parent.Parent.Id,
                Ultimate_Parent_Account__c
        from Account
        WHERE Id IN :accts];

        for(Account ac : accounts) {


            String originalUltimate = ac.Ultimate_Parent_Account__c;
            if (ac.Parent.Parent.Parent.Parent.Parent.Id != null) {
                ac.Ultimate_Parent_Account__c = ac.Parent.Parent.Parent.Parent.Parent.Id;
            } else if (ac.Parent.Parent.Parent.Parent.Id != null) {
                ac.Ultimate_Parent_Account__c = ac.Parent.Parent.Parent.Parent.Id;
            } else if (ac.Parent.Parent.Parent.Id != null) {
                ac.Ultimate_Parent_Account__c = ac.Parent.Parent.Parent.Id;
            } else if (ac.Parent.Parent.Id != null) {
                ac.Ultimate_Parent_Account__c = ac.Parent.Parent.Id;
            } else if (ac.Parent.Id != null) {
                ac.Ultimate_Parent_Account__c = ac.Parent.Id;
            } else {
                ac.Ultimate_Parent_Account__c = null;
            }

            // IF a legit change took place (we ONLY want to include records that actually changed for updates because of some validation rule issues)
            if (ac.Ultimate_Parent_Account__c != originalUltimate) {

                boolean foundInUpdates = false;
                
                if(accountUpdateIdSet.contains(ac.id)) {
                    for (Account uac : updates) {
                        if (uac.Id == ac.Id) {
                            uac.Ultimate_Parent_Account__c = ac.Ultimate_Parent_Account__c;
                            foundInUpdates = true;
                            break;
                        }
                    }
                } else {
                    updates.add(ac);
                    accountUpdateIdSet.add(ac.id);
                    //x.put();
                }
            }
        }
        system.debug('#@# AccountTriggerHandler.recomputeUltimateParents: END');

    }
*/
}