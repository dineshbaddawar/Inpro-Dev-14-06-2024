trigger AccountPreUpdate on Account (before update) {  
    for(Account a : Trigger.New) {           
        //if (Trigger.isUpdate) {                              
            //if(a.ParentId != null && a.Sync_Price_Level__c)
            //{
                ////retrieve parent account
                //List<Account> aList = [select Id, Price_Level__c from Account where Id =: a.ParentId];
                ////if the account has a parent account and the sync price level checkbox is checked
                //for(Account acc : aList){
                //    a.Price_Level__c = acc.Price_Level__c;
                //}               
            //}
        //}
    }
}