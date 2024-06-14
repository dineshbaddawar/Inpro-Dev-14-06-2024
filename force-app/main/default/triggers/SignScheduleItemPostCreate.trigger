trigger SignScheduleItemPostCreate on Sign_Schedule_Item__c (after insert) {

    if (Trigger.isAfter) {
        for(Sign_Schedule_Item__c s : Trigger.New) {           
                    if(s.SavedToCRM__c == true && s.SavedReferenceID__c != null)
                    {
                            string quoteId = '';
                            string quoteNumber = '';
                            string imageId = s.SavedReferenceID__c;                         
                            string quoteLineId = '';   
                            string signScheduleItemId = s.Id;               
                            string signScheduleId = s.SignScheduleId__c;    
                            string userId = s.CreatedById;                            
                            SignImageLibraryHelper.cloneSignImages(userId, imageId, signScheduleItemId, signScheduleId, quoteId, quoteLineId, quoteNumber);                            
                       
                    }
        }
    }

}