trigger QuoteLineItemPreCreate on QuoteLineItem (before insert) {
    // if (Trigger.isInsert) {
    //     for(QuoteLineItem i : Trigger.New) {
            
    //         i.Alternate_Number__c = i.LineNumber__c;
    //         List<Alternate__c> aList;
    //         if(i.SeriesID__c != null && i.SeriesID__c != '')
    //         {
    //         // Get the related Alternates for the QuoteLineItems in this trigger
    //             aList = [select Id from Alternate__c where QuoteId__c =: i.QuoteId and Name__c =: i.Alternate_Name__c];
    //         }
    //         else {
    //             aList = [select Id from Alternate__c where QuoteId__c =: i.QuoteId and Number__c =: i.Alternate_Number__c ];
    //         }
                
    //         if(aList.size() == 0){
    //             // create the Alternate if it doesn't exist
    //             Alternate__c a = new Alternate__c(Name__c = i.Alternate_Name__c, 
    //                                               Number__c = i.Alternate_Number__c, 
    //                                               QuoteId__c = i.QuoteId,
    //                                               Sequence_Number__c = i.Sequence_Number__c);
                
    //             insert a;
    //             i.Alternate__c = a.Id;
                
    //         }
    //         else{
    //             i.Alternate__c = aList[0].Id;
    //         }
        
    //     }
    // }
}