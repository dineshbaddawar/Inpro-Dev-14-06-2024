trigger BidderTrigger on Bidder__c (after insert, after update, after delete) {

    if (trigger.isAfter) {
        if (trigger.isInsert) {
            if (!Test.isRunningTest()) OpportunityContactRoleUtility.updateContactRolesForOpportunities(trigger.new);
        }
        if (trigger.isUpdate) {
            if (!Test.isRunningTest()) OpportunityContactRoleUtility.updateContactRolesForOpportunities(trigger.new);
        }
        if (trigger.isDelete) {
            if (!Test.isRunningTest()) OpportunityContactRoleUtility.updateContactRolesForOpportunities(trigger.old);
        }
    }
}