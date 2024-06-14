trigger CustomPricingTrigger on Custom_Pricing__c (after update) {

    for(Custom_Pricing__c cp:Trigger.new)
    {
        String Title = '';
        String Body = '';        
        Set<String> recipientsIds = new Set<String>();
        String targetId = cp.Id; //'0Q06C000000PLA1SAO';
        //recipientsIds.add('0056g000004ah22AAA'); //david
        //recipientsIds.add('0056g000001a8vGAAQ');	//matt		
        recipientsIds.add(cp.CreatedById);
        CustomNotificationFromApex cn = new CustomNotificationFromApex();   
        
        if(cp.Status__c == 'Complete')
        {           
            Title = 'Custom Pricing Complete';
            Body =  cp.Subject__c + ' completed, see it by clicking here.';                     
            cn.notifyUsers(recipientsIds, targetId, Title, Body);              
        }
        else if (cp.Status__c == 'Rejected')
        {
            Title = 'Custom Pricing Rejected';
            Body =  cp.Subject__c + ' rejected, see it by clicking here.';                     
            cn.notifyUsers(recipientsIds, targetId, Title, Body);        
        }

        if (cp.Status__c == 'Complete' || cp.Status__c == 'Rejected')
        {           
            List<QuoteLineItem> quoteLines = [SELECT Id FROM QuoteLineItem WHERE Custom_Pricing__c = :targetId];
            List<QuoteLineItem> quoteLinesToUpdate = new List<QuoteLineItem>();
            for (QuoteLineItem qli : quoteLines) {
                QuoteLineItem line = new QuoteLineItem();
                line.Id = qli.Id;
                line.Custom_Pricing_Requested__c = false;
                quoteLinesToUpdate.add(line);
            }

            update quoteLinesToUpdate;
        }

    }   

}