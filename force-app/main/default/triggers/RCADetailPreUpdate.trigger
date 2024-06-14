trigger RCADetailPreUpdate on RCA_Detail__c (before update) {
    if(Trigger.isUpdate) 
    {
        for(RCA_Detail__c r : Trigger.New) { 
            String rcaId = r.RCA__c;
            String rcaStatus = [select Status__c from RCA__c where Id = :rcaId].Status__c;        
            if(rcaStatus != 'Open' && rcaStatus != 'CEO Rejected' && rcaStatus != 'Primary Rejected' && rcaStatus != 'Senior Manager Rejected' && rcaStatus != 'Traffic Rejected')
            {
                r.RecordTypeId = [select Id from RecordType where Name = 'RCA Detail (Submitted)' and SobjectType = 'RCA_Detail__c'].Id;
            }
            else
            {
                r.RecordTypeId = [select Id from RecordType where Name = 'Unlocked (Default)' and SobjectType = 'RCA_Detail__c'].Id;
            }
        }
    }
}