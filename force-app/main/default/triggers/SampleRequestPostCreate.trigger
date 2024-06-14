trigger SampleRequestPostCreate on Sample_Request__c (after insert) {

    if(Trigger.isAfter) 
    { 
        for(Sample_Request__c s : Trigger.New) 
        {  
            // if(s.Type__c != null && s.Type__c == 'Web Request')
            // {
            //     string ownerid =  [SELECT ownerId FROM Lead  WHERE Id = :s.Lead__c LIMIT 1].ownerId; //[SELECT Lead__r.OwnerId  FROM Sample_Request__c  WHERE Id = :s.Id LIMIT 1].Lead__r.OwnerId;

            //     if(ownerid.startsWith('005'))
            //     {
            //         s.ISR__c = ownerid;
            //         s.OwnerId = ownerid;
            //         update s;
            //     }                
            // }
        }
    }
}