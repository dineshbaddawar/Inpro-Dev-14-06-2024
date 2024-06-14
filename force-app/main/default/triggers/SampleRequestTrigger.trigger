trigger SampleRequestTrigger on Sample_Request__c (before update, after update) {
    if(Trigger.isUpdate) 
    { 
        for(Sample_Request__c s : Trigger.New) {  
            Sample_Request__c oldS = Trigger.oldMap.get(s.Id);
           
            if (s.Street_Address__c != olds.Street_Address__c ||
                s.City__c != olds.City__c ||
                s.State__c != olds.State__c ||
                s.Postal_Code__c != olds.Postal_Code__c)
            {
                if (Trigger.isBefore)
                {
                    s.Address_Validated__c = 'Not Valid';
                }
                else if (Trigger.isAfter)
                {
                    //Run validation on sample request if address changed
                    if (!Test.isRunningTest())
                    {
                        AddressValidationHelper.ValidateAddressOneTrigger(s.Id, 'Sample_Request__c');
                    }
                }
                
            }
            if(s.Status__c != oldS.Status__c && s.Status__c == 'Delivered')
            { 
                if(s.ISR__c != null)
                {
                    String sampleId = s.Id;
                    List<zkmulti__MCShipment__c> shipments = [SELECT Id, zkmulti__Service_Type_Name__c  FROM zkmulti__MCShipment__c  WHERE Sample_Request__c = :sampleId LIMIT 1];

                    if(shipments.size() > 0)
                    {
                        if(shipments[0].zkmulti__Service_Type_Name__c != null)
                        {
                            String shipmentMOT = shipments[0].zkmulti__Service_Type_Name__c;

                            if(shipmentMOT.contains('Next Day Air'))
                            {               
                                String Title = 'Expedited Sample Delivered: ' + s.Name;
                                String Body = '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + s.Id + '\">Sample Request</a>' + '<br>';      
                                String isrId = s.ISR__c;
                                
                                List<User> userList = [SELECT DelegatedApproverId, Email  FROM User  WHERE Id = :isrId LIMIT 1];
                                
                                if(userList.size() > 0)
                                {
                                    string EmailTo = userList[0].Email;
                                    string EmailCC = '';

                                    if(userList[0].DelegatedApproverId != null && userList[0].DelegatedApproverId != '')
                                    {
                                        String deletegatedApproverId = userList[0].DelegatedApproverId; 
                                        List<User> backupList = [SELECT Email FROM User WHERE Id = :deletegatedApproverId LIMIT 1];
                                
                                        if(backupList.size() > 0)
                                            EmailCC = backupList[0].Email;                         
                                    }                                           
                                    EmailSendHelper.sendEmailAsCRM365(EmailTo, EmailCC, Title, Body);
                                }
                            }
                        }
                    }
                }
                if(s.Contact__c != null && s.Account__c != null)
                {
                    try {
                        List<Sample_Request_Item__c> items = [SELECT Id, Sample_Product__r.Box_Set_Type__c FROM Sample_Request_Item__c WHERE Sample_Request__c = :s.Id AND Sample_Product__r.Box_Set_Type__c != null];
                        if(items.size() > 0)
                        {
                            for (Integer i = 0; i < items.size(); i++) {      
                                Box_Set__c bs = new Box_Set__c();
                                bs.Contact__c = s.Contact__c;
                                bs.Placement_Status__c = 'Active';
                                bs.Account__c = s.Account__c;
                                bs.Box_Set_Type__c = items[i].Sample_Product__r.Box_Set_Type__c;
                                insert bs;
                            }            
                        }
                    } catch (Exception ex) {
                        EmailSendHelper.sendEmail('eleptich@inprocorp.com', '', 'Failure Creating Box Set from Sample Request', '');
                    }                   
                }
            }
        }
    }
}