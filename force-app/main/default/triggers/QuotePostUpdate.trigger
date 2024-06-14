trigger QuotePostUpdate on Quote (after update) {
    
    //List<string> quoteIdsToRollup = new List<string>();
    
    if(Trigger.New.size() == 1)
    for(Quote q : Trigger.New) 
    {
        Quote oldQuote = Trigger.oldMap.get(q.Id);
        
        // if there are qualifications
        if(q.Qualifications__c != null && q.Qualifications__c != oldQuote.Qualifications__c)
         {
            
            if (Trigger.isUpdate) {
            
                // delete the related Qualifications for the Quotes in this trigger
                List<Qualification__c> oldList = [select Id from Qualification__c where Quote__c =: q.Id LIMIT 9999];
                
                if(!oldList.IsEmpty()) {
                    delete oldList;
                }
            }
            
            // get a list of the qualification descriptions on the Quote if Qualifications__c is not null
            if(q.Qualifications__c != null) {
                
                List<String> descriptions = q.Qualifications__c.split('\\|~\\|');  // must escape the pipes
            
                // create a qualification record for each of the descriptions
                List<Qualification__c> qualsToInsert = new List<Qualification__c>();
                for(String description : descriptions) 
                {
                    if(description.length() > 0) {
                        
                        // get the sequence number from the front of the description delimitted by the '-'
                        string sSequence = description.left(description.indexOf('-'));
                        string sDescription = description.removeStart(sSequence+'-'); 
                        integer iSequence = Integer.valueOf(sSequence); 
                        string qualificationType = 'General';            
                        
                        List<CT_Option__c> EstimatingOptionList = [select Id from CT_Option__c where OptionID__c =: iSequence AND CatID__c =: 'EQualifications' AND Division__c =: q.Division__c LIMIT 1];
                        if(!EstimatingOptionList.IsEmpty()) {
                            qualificationType = 'Estimating';
                        }

                        //Qualification__c ql = new Qualification__c(Quote__c = q.Id, Sequence__c = iSequence, Description__c = sDescription);
                        
                        Qualification__c ql = new Qualification__c(Quote__c = q.Id, Sequence__c = iSequence, Description__c = sDescription, Qualification_Type__c = qualificationType);
                        qualsToInsert.add(ql);
                        
                    }
                }
                if(qualsToInsert.size() > 0)
                    insert qualsToInsert;
                
            }
        }    
        
        if (q.Status == 'Sent to Customer' && oldQuote.Status != 'Sent to Customer')
        {
            Opportunity opp = [SELECT StageName, OwnerId, Name, Id FROM Opportunity WHERE Id = :q.OpportunityId];

            if (!q.ISR_Task_Trigger__c && q.Requires_Follow_Up__c)
            {
                List<Task> existingFollowUps = [SELECT Id, Type, WhatId FROM Task WHERE Type = 'Quote Follow Up' AND WhatId = :q.OpportunityId];

                if (existingFollowUps.size() == 0)
                {
                    //add follow up task to list
                    Task t = new Task();
                    t.Subject = 'Follow Up Task';
                    t.OwnerId = opp.OwnerId;
                    t.Status = 'Open';
                    t.WhatId = opp.Id;
                    t.Type = 'Quote Follow Up';
                    t.Description = ' Please review this quote: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.Id;
                    
                    //due date is 5 business days out after sent to customer
                    string weekday = Datetime.now().addDays(5).format('E');

                    if (weekday == 'Sun')
                    {
                        t.ActivityDate = Datetime.now().addDays(6).date();
                    }
                    else if (weekday == 'Sat')
                    {
                        t.ActivityDate = Datetime.now().addDays(7).date();
                    }
                    else
                    {
                        t.ActivityDate = Datetime.now().addDays(5).date();
                    }

                    insert t;
                }
            }
        }
        else if(q.Status == 'Approved' && oldQuote.Status == 'Submitted for Approval' && q.CreatedById != UserInfo.getUserId() && 
        ((q.Biggest_Alternate_Discount__c != null && q.Biggest_Alternate_Discount__c >= 10) || (q.Requires_Discount_Manager_Approval__c != null && q.Requires_Discount_Manager_Approval__c)) && q.BidQuote__c != 'Estimate Detail' &&
        q.BidQuote__c != 'Estimate Summary' && q.BidQuote__c != 'Estimate Super Summary')
        {
            ProcessInstance processInstance = [SELECT Id, TargetObjectId, 
                        (SELECT Id, StepStatus, Actor.Name, ElapsedTimeInDays, CreatedDate, ProcessNodeId, ProcessNode.Name, Comments 
                        FROM StepsAndWorkitems
                        ORDER BY CreatedDate DESC) 
                    FROM ProcessInstance 
                    WHERE TargetObjectId = :q.Id 
                    ORDER BY CreatedDate DESC LIMIT 1];
            List<ProcessInstanceHistory> history = processInstance.StepsAndWorkitems;

            if(history != null && history[0] != null && history[0].ProcessNode != null && 
                (history[0].ProcessNode.Name == 'Manager Approval' || history[0].ProcessNode.Name == 'Contribution Margin Approval'))
            {
                User Creator = [SELECT Id, Email, Name, DelegatedApproverId FROM User WHERE Id = :q.CreatedById];
                Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :q.OpportunityId];
                string EmailTo = Creator.Email;
                string EmailCC = '';

                string Title = 'Quote ' + q.Name + ' has been Approved for ' + opp.Name + '!';
                string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.Id;            
                string Body = 'Dear ' + Creator.Name +',<br><br>' +
                            'Quote ' + q.Name + ' has been Approved for ' + opp.Name + '!<br><br>' +
                            'Here\'s a link to the view the quote:<br><br>'+
                            recordUrl;

                if(Creator.DelegatedApproverId != null)
                {
                    String deletegatedApproverId = Creator.DelegatedApproverId;                        
                    User user = [SELECT Id, Email  FROM User  WHERE Id = :deletegatedApproverId];
                    EmailCC = user.Email;
                }

                EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
            }
        }
        else if(q.Status == 'Rejected' && oldQuote.Status == 'Submitted for Approval' && //q.CreatedById != UserInfo.getUserId() && 
            (q.Requires_Discount_Manager_Approval__c != null && q.Requires_Discount_Manager_Approval__c) && q.BidQuote__c != 'Estimate Detail' &&
            q.BidQuote__c != 'Estimate Summary' && q.BidQuote__c != 'Estimate Super Summary')
        {           
            ProcessInstance processInstance = [SELECT Id, TargetObjectId, 
                                                (SELECT Id, StepStatus, Actor.Name, ElapsedTimeInDays, CreatedDate, ProcessNodeId, ProcessNode.Name, Comments 
                                                 FROM StepsAndWorkitems
                                                 ORDER BY CreatedDate DESC) 
                                               FROM ProcessInstance 
                                               WHERE TargetObjectId = :q.Id 
                                               ORDER BY CreatedDate DESC LIMIT 1];
            List<ProcessInstanceHistory> history = processInstance.StepsAndWorkitems;

            User Creator = [SELECT Id, Email, Name, DelegatedApproverId FROM User WHERE Id = :q.CreatedById];
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :q.OpportunityId];
            string EmailTo = Creator.Email;
            string EmailCC = '';

            if(Creator.DelegatedApproverId != null)
            {
                String deletegatedApproverId = Creator.DelegatedApproverId;                        
                User user = [SELECT Id, Email  FROM User  WHERE Id = :deletegatedApproverId];
                EmailCC = user.Email;
            }

            if(history != null && history[0] != null && history[0].ProcessNode != null && history[0].ProcessNode.Name == 'Manager Approval')
            {
                User Rejector = [SELECT Id, Name FROM User WHERE ID = :history[0].ActorId];
                String Comments = Rejector.Name + ': ' + history[0].Comments + '<br><br>'; //first item in list was rejection with comments

                string Title = 'Quote ' + q.Name + ' has been Rejected for ' + opp.Name + '!';
                
                string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + q.Id;            
                string Body = 'Dear ' + Creator.Name +',<br><br>' +
                            'Quote ' + q.Name + ' has been Rejected for ' + opp.Name + '! Any comments by the person that rejected the Quote are shown below:<br><br>' +
                            Comments +
                            'Here\'s a link to the view the quote:<br><br>'+
                            recordUrl;

                EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
            }
        }
    }

    //AlternateRollupHelper altRollupHelper = new AlternateRollupHelper();
    //altRollupHelper.UpdateAlternateTotals(quoteIdsToRollup);
}