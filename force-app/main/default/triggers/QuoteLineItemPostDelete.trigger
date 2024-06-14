trigger QuoteLineItemPostDelete on QuoteLineItem (after delete) {
    // if (Trigger.isDelete) {
    //     for(QuoteLineItem i : Trigger.Old) {
            
    //         if(i.SeriesID__c != null && i.SeriesID__c != '')
    //         {
    //         // check for other QuoteLineItems under this Alternate
    //         List<QuoteLineItem> qList = [select Id from QuoteLineItem where QuoteId =: i.QuoteId and Alternate_Name__c =: i.Alternate_Name__c];
                
    //         if(qList.size() == 0){
    //             // if there aren't any, delete the Alternate if it still exists
    //             List<Alternate__c> aList = [select Id from Alternate__c where QuoteId__c =: i.QuoteId and Name__c =: i.Alternate_Name__c];
    //             for(Alternate__c alt : aList){
    //                 delete alt;
    //             }
    //         }
    //     }
    //     else {
    //          // check for other QuoteLineItems under this Alternate
    //          List<QuoteLineItem> qList = [select Id from QuoteLineItem where QuoteId =: i.QuoteId and Alternate_Number__c =: i.Alternate_Number__c];
                
    //          if(qList.size() == 0){
    //              // if there aren't any, delete the Alternate if it still exists
    //              List<Alternate__c> aList = [select Id from Alternate__c where QuoteId__c =: i.QuoteId and Number__c =: i.Alternate_Number__c];
    //              for(Alternate__c alt : aList){
    //                  delete alt;
    //              }
    //          }
    //     }
            
    //         // delete this QuoteLineItem from the dataWarehouse...
    //         WebServiceTriggerProxy.DeleteRecord('QuoteLineItem', i.Id);
    //     }
    // }
}