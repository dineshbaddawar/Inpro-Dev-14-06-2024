trigger ShipmentPostUpdate on zkmulti__MCShipment__c (after insert, after update) 
{
    if(Trigger.isUpdate) 
    { 
        for(zkmulti__MCShipment__c s : Trigger.New) 
        {  
            zkmulti__MCShipment__c oldS = Trigger.oldMap.get(s.Id);

            if (s.zkmulti__Tracking_Stage__c == 'Delivered' || 
                //An unexpected change to delivery occurred, but it WAS delivered eventually
                (s.zkmulti__Tracking_Stage__c == 'Exception' && s.zkmulti__Status_Description__c.indexOf(') Delivered') != -1))
            {
                Sample_Request__c sampleRequest = [SELECT Id, Status__c FROM Sample_Request__c  WHERE Id = :s.Sample_Request__c LIMIT 1];
                if (sampleRequest.Status__c != 'Delivered')
                {
                    sampleRequest.Status__c = 'Delivered';
                    update sampleRequest;
                }
            }
            else if (oldS.zkmulti__Tracking_Stage__c != s.zkmulti__Tracking_Stage__c &&
                oldS.zkmulti__Tracking_Stage__c == 'Label Created')
            {
                Sample_Request__c sampleRequest = [SELECT Id, Status__c FROM Sample_Request__c  WHERE Id = :s.Sample_Request__c LIMIT 1];
                sampleRequest.Status__c = 'Shipped';
                update sampleRequest;
            }
        }
    }
}