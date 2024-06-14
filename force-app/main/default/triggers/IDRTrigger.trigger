trigger IDRTrigger on Illustrator_Design_Request__c (after update) {
    for(Illustrator_Design_Request__c idr:Trigger.new)
    {
        Illustrator_Design_Request__c oldIDR = Trigger.oldMap.get(idr.Id);
        if(idr.Status__c != oldIDR.Status__c && (idr.Status__c == 'Canceled' || idr.Status__c == 'Complete' || idr.Status__c == 'Hold'))
        {                                        
            List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :idr.CreatedById];
            if(userList.size() > 0)
            {  
                string EmailTo = userList[0].Email;
                string EmailCC = '';
                string deletegatedApproverId = userList[0].DelegatedApproverId;

                String Title = '';
                String Body = '';        
                Set<String> recipientsIds = new Set<String>();
                String targetId = idr.Id;    
                string userId = idr.CreatedById;         
                recipientsIds.add(deletegatedApproverId);
                CustomNotificationFromApex cn = new CustomNotificationFromApex();
                
                if(idr.Status__c == 'Canceled')
                {
                    Title =  idr.Name + ' Canceled';
                    Body =  idr.Name + ' canceled, see it by clicking here.';
                }
                else if(idr.Status__c == 'Complete') {
                    Quote quote = [SELECT Id, Name,Opportunity_Name__c FROM Quote WHERE Id = :idr.Quote__c];

                    Title =  idr.Name + ' Complete';
                    Body =  idr.Name + ' for ' + quote.Name + ' related to Opportunity ' + quote.Opportunity_Name__c + 
                        ' has been completed by the Design Team.<br/><br/>Notes:<br/>' + idr.Notes__c + '<br/><br/>Click the link below to go to the IDR record:<br>';
                }
                else if(idr.Status__c == 'Hold')
                {
                    Quote quote = [SELECT Id, Name,Opportunity_Name__c FROM Quote WHERE Id = :idr.Quote__c];
                    Title =  idr.Name + ' On Hold';
                    Body =  idr.Name + ' for ' + quote.Name + ' related to Opportunity ' + quote.Opportunity_Name__c + 
                        ' has been put on hold by the Design Team.<br/><br/>Notes:<br/>' + idr.Notes__c + '<br/><br/>Click the link below to go to the IDR record:<br>';
                }
                                     
                cn.notifyUsers(recipientsIds, targetId, Title, Body);
                                
                if(deletegatedApproverId != null)
                    EmailCC = [SELECT Email  FROM User  WHERE Id = :deletegatedApproverId].Email;

                string recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + idr.Id;            
                    Body = Body + 
                    '<br><a style=\"font-size:20px\" href=\"' + recordUrl + '\">' + idr.Name + '</a>';

                EmailSendHelper.sendEmail(EmailTo, EmailCC, Title, Body);
            }
        }
    }
}