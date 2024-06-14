global class MassUnlockAccounts implements Database.batchable<sObject> {
    //Start of this batch job
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Account LIMIT 50000000 '; //50 Million records
        return Database.getQueryLocator(query);
    }
    //Exeution of batch job
    global void execute(Database.BatchableContext BC, List<Account> scope) { //Scope max = 2000
        List<Account> accountLockList = new List<Account>();
        for(Account c : scope)
        {
            if(Approval.isLocked(c.id)){
                accountLockList.add(c);
            }
        }
        
        if(!accountLockList.isEmpty()){
            //Unlock records
            List<Approval.UnlockResult> ulrList = Approval.unlock(accountLockList, false);
            
            // Iterate through each returned result
            for(Approval.UnlockResult  ulr : ulrList) {
                if (ulr.isSuccess()) {
                    //Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully locked account with ID: ' + ulr.getId());
                }
                else {
                    //Operation failed, so get all errors                
                    for(Database.Error err : ulr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    //finish job
    global void finish(Database.BatchableContext BC) {
    }
}