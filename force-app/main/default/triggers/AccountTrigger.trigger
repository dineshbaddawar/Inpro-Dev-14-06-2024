/************************************************************
* Created by:   The Hunley Group
* Created on:   3/25/2021
* ===========================================================
* Test Class:  Standard Trigger Handler for Accounts
* ===========================================================
* Purpose:     
* 
* ===========================================================
* Change History
* Date          Author              Purpose
* ----------    -------------       -----------------------------
* 3/25/2021     THG - Tyler         Created
* 4/14/2021     THG - Jason Kurant  Updated for Inpro
*************************************************************/
trigger AccountTrigger on Account (after insert, before update, after update, after delete, before insert, before delete) {

    // if our trigger is disabled, exit now:
    // We do not have Project Account Roles in this org
    // if (!HunleyTriggerUtilities.IsTriggerEnabled('ProjectAccountRoleTrigger')) return; 
    if(!System.IsBatch() && !System.isFuture())
    {
    if(trigger.isAfter && HunleyTriggerUtilities.runOnce('AccountTrigger')) {

        if (trigger.isInsert) {
            AccountTriggerHandler handler = new AccountTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterInsert();
        }
        if (trigger.isUpdate) {
            AccountTriggerHandler handler = new AccountTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterUpdate();
            if (Test.isRunningTest())
            {
                return;
            }
            List<Id> shippingChanges = new List<Id>();
            List<Id> billingChanges = new List<Id>();
            for(Account a : Trigger.New)
            {
                Account oldAccount = Trigger.oldMap.get(a.Id);
                
                //If shipping address changed
                if (oldAccount.ShippingCity != a.ShippingCity ||
                    oldAccount.ShippingCountry != a.ShippingCountry ||
                    oldAccount.ShippingPostalCode != a.ShippingPostalCode ||
                    oldAccount.ShippingState != a.ShippingState ||
                    oldAccount.ShippingStateCode != a.ShippingStateCode ||
                    oldAccount.ShippingStreet != a.ShippingStreet)
                {
                    shippingChanges.add(a.Id);
                }

                //if billing address changed
                if (oldAccount.BillingCity != a.BillingCity ||
                        oldAccount.BillingCountry != a.BillingCountry ||
                        oldAccount.BillingPostalCode != a.BillingPostalCode ||
                        oldAccount.BillingState != a.BillingState ||
                        oldAccount.BillingStateCode != a.BillingStateCode ||
                        oldAccount.BillingStreet != a.BillingStreet)
                {
                    billingChanges.add(a.Id);
                }
            }

            AddressValidationHelper.ValidateAddressMap(shippingChanges, billingChanges);
        }
        if (trigger.isDelete) {
            AccountTriggerHandler handler = new AccountTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterDelete();
        }


    } else if (trigger.isBefore) {
        if(trigger.isInsert) {
            AccountTriggerHandler handler = new AccountTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeInsert();
        }
        if(trigger.isUpdate) {
            for(Account a : Trigger.New)
            {
                Account oldAccount = Trigger.oldMap.get(a.Id);
                // if billing address changed
                if (oldAccount.BillingCity != a.BillingCity ||
                    oldAccount.BillingCountry != a.BillingCountry ||
                    oldAccount.BillingPostalCode != a.BillingPostalCode ||
                    oldAccount.BillingState != a.BillingState ||
                    oldAccount.BillingStateCode != a.BillingStateCode ||
                    oldAccount.BillingStreet != a.BillingStreet)
                {
                    a.Billing_Address_Validated__c = 'Not Valid';//reset validation
                }
    
                // if shipping address changed
                if (oldAccount.ShippingCity != a.ShippingCity ||
                    oldAccount.ShippingCountry != a.ShippingCountry ||
                    oldAccount.ShippingPostalCode != a.ShippingPostalCode ||
                    oldAccount.ShippingState != a.ShippingState ||
                    oldAccount.ShippingStateCode != a.ShippingStateCode ||
                    oldAccount.ShippingStreet != a.ShippingStreet)
                {
                    a.Shipping_Address_Validated__c = 'Not Valid';//reset validation
                }
            }
            
            AccountTriggerHandler handler = new AccountTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeUpdate();
        }
        if(trigger.isDelete) {
            AccountTriggerHandler handler = new AccountTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.beforeDelete();
        }
    }
}
}