trigger DivisionPriceLevelTrigger on Division_Price_Level__c (after insert, before delete, after update) {
    if(WebserviceTriggerProxy.firstRun && System.isBatch() == false && System.isFuture() == false)
    {
        WebserviceTriggerProxy.firstRun = false;
        Boolean accountSyncPriceLevel = false;
        if (Trigger.isDelete) {
            for(Division_Price_Level__c d : Trigger.Old) {
                //Retrieve Lookup values from Account
                List<Division_Price_Level__c> dList = [select Id, Account__r.Sync_Price_Level__c from Division_Price_Level__c where Id =: d.Id];
                for(Division_Price_Level__c dpl : dList){
                    if (dpl.Account__r.Sync_Price_Level__c != null)
                    {
                        accountSyncPriceLevel = dpl.Account__r.Sync_Price_Level__c;
                    }
                }
                if(accountSyncPriceLevel)
                { 
                    AccountHelper.deleteSyncDivPriceLevelToChildAccounts(d.Account__c, d.Division__c);
                }
            }
        }
        else if (Trigger.isUpdate || Trigger.isInsert)
        {
            for(Division_Price_Level__c d : Trigger.New) {
                //Retrieve Lookup values from Account
                List<Division_Price_Level__c> dList = [select Id, Account__r.Sync_Price_Level__c from Division_Price_Level__c where Id =: d.Id];
                for(Division_Price_Level__c dpl : dList){
                    if (dpl.Account__r.Sync_Price_Level__c != null)
                    {
                        accountSyncPriceLevel = dpl.Account__r.Sync_Price_Level__c;
                    }
                }
            
                if(accountSyncPriceLevel)
                {          
                    String discount = '';
                    if(d.Discount__c != null)
                        discount = String.valueOf(d.Discount__c);

                    AccountHelper.upsertSyncDivPriceLevelToChildAccounts(d.Account__c, d.Price_Level__c, d.Division__c, discount);               
                }  
            }       
        }         
    }               
}