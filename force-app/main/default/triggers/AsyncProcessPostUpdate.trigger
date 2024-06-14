trigger AsyncProcessPostUpdate on AsyncProcess__c (after update) {
    
    for(AsyncProcess__c p : Trigger.New) {
        
        AsyncProcess__c oldProcess = Trigger.oldMap.get(p.Id);
        
		// if there are qualifications
        if(p.Status__c != oldProcess.Status__c) {
        
        }	
    
    }
    
}