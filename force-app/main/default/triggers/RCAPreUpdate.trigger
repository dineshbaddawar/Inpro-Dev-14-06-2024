trigger RCAPreUpdate on RCA__c (before update) {
    if(Trigger.isUpdate) 
    { 
        for(RCA__c r : Trigger.New) {  
                    
            if (r.Inactive__c == true)
            {
                r.RecordTypeId = [select Id from RecordType where Name = 'RCA (Submitted)' and SobjectType = 'RCA__c'].Id;
            }
            else if (r.Status__c != 'Open' && r.Status__c != 'CEO Rejected' && r.Status__c != 'Primary Rejected' && r.Status__c != 'Senior Manager Rejected' && r.Status__c != 'Traffic Rejected')
            {
                r.RecordTypeId = [select Id from RecordType where Name = 'RCA (Submitted)' and SobjectType = 'RCA__c'].Id;
            }
            else
            {
                r.RecordTypeId = [select Id from RecordType where Name = 'Unlocked (Default)' and SobjectType = 'RCA__c'].Id;
            }
        }
    }
}