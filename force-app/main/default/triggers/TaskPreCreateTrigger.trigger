trigger TaskPreCreateTrigger on Task (before insert) {
    for(Task task:Trigger.new)
    {
        //Assign to Estimator or Estimating Queue if this is a new Estimating Request task
        if (task.RecordTypeId ==  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Estimating_Request').getRecordTypeId())
        {
            task.OwnerId = 
                (task.Divisional_Opportunity__c != null && task.Divisional_Opportunity__r.Estimator__c != null && task.Divisional_Opportunity__r.Estimator__r.IsActive) ?
                task.Divisional_Opportunity__r.Estimator__c :
                [SELECT Id FROM Group WHERE Name = 'Estimating Queue' AND Type = 'Queue'].Id;
        }
        //Update subject here so that validation rules aren't triggered (ie. Estimating hours validation rule for New Estimate Task Types)
        if (task.Divisional_Opportunity__c != null)
        {
            Opportunity opp = [SELECT Id, Large_Project__c, Division_Lookup__c FROM Opportunity WHERE Id = :task.Divisional_Opportunity__c LIMIT 1];

            if (opp.Division_Lookup__c != null )
            {

                Division__c div = [SELECT Id, Abbreviation__c FROM Division__c WHERE Id = :opp.Division_Lookup__c LIMIT 1];

                //Ensure division is prepended to CSR Request in the subject line
                if (task.RecordType.Name == 'CCS Request' && task.Subject.indexOf(div.Abbreviation__c) == -1)
                {
                    task.Subject = div.Abbreviation__c + ' - ' + task.Subject;
                }
                
            }
            if  (opp != null && opp.Large_Project__c &&
                    (task.Type == 'Doc Update' || task.Type == 'SDR' || task.Type == 'Estimating Task' || 
                    task.Type == 'Order Request' || task.Type == 'CSR Request')
                )
            {
                task.Subject = 'Large Project - ' + task.Subject;
            }
        }
        else if (task.Quote__c != null)
        {
            Quote quote = [SELECT Id, Division_Lookup__c FROM Quote WHERE ID = :task.Quote__c LIMIT 1];
            if (quote.Division_Lookup__c != null)
            {
                Division__c div = [SELECT Id, Name, Abbreviation__c FROM Division__c WHERE Id = :quote.Division_Lookup__c];
                //Ensure division is prepended to CSR Request in the subject line
                if (task.RecordType.Name == 'CCS Request' && task.Subject.indexOf(div.Abbreviation__c) == -1)
                {
                    task.Subject = div.Abbreviation__c + ' - ' + task.Subject;
                }
                
            }
        }
    }
}