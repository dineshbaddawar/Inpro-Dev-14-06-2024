public with sharing class SampleRequestHelper {
    public void SubmitSamplesRequestsForApproval() {
        
        // List<Sample_Request__c> SampleRequests = [SELECT Id FROM Sample_Request__c WHERE Status__c = 'New' AND Type__c = 'Web Request'];

        // for (Sample_Request__c sr : SampleRequests) {         
        //     try {
        //         Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        //         req.setComments('Auto-Submitted from Website.');        
        //         req.setObjectId(sr.id);                
        //         Approval.ProcessResult result = Approval.process(req);
        //     } catch (Exception ex) {
        //         EmailSendHelper.sendEmail('dsieraski@inprocorp.com', '', 'Sample Request Approval Job - Failure', JSON.serialize(ex));
        //     }
            
        // }    
    }

    @AuraEnabled
    public static string updateDates(){
        List<Sample_Request__c> sr = [SELECT Id FROM Sample_Request__c WHERE Shipped_Date__c = null AND Status__c = 'Delivered' ORDER BY CreatedDate DESC LIMIT 400];
        
        String idStr = '';
        for(Sample_Request__c s : sr)
        {
            idStr += idStr == '' ? '\'' + s.Id + '\'' : ',\'' + s.Id + '\'';
        }

        List<ProcessInstance> processInstances = Database.query('SELECT Id, Status, TargetObjectId, LastModifiedDate  ' +
                                               'FROM ProcessInstance WHERE TargetObjectId IN ('+idStr+')'+
                                               'ORDER BY CreatedDate DESC');

        List<zkmulti__MCShipment__c> shipments = Database.query('SELECT zkmulti__Ship_Date__c, CreatedDate, Sample_Request__c FROM zkmulti__MCShipment__c WHERE Sample_Request__c IN ('+idStr+')');

        Integer success = 0;
        Integer total = sr.size();
        
        List<Sample_Request__c> srToUpdate = new List<Sample_Request__c>();

        for(Sample_Request__c s : sr)
        {
            Sample_Request__c newSr = new Sample_Request__c();
            newSr.Id = s.Id;
            Boolean isUpdating = false;

            for(ProcessInstance pI : processInstances)
            {
                if (pI.TargetObjectId == s.Id && pI.Status == 'Approved')
                {
                    newSr.Approved_Date__c = pI.LastModifiedDate;
                    isUpdating = true;
                }
            }
            
            
            for (zkmulti__MCShipment__c shipment: shipments)
            {
                if (shipment.Sample_Request__c == s.Id)
                {
                    newSr.Shipped_Date__c = shipment.CreatedDate;
                    isUpdating = true;
                }
            }

            if (isUpdating)
            {
                srToUpdate.add(newSr);
                success++;
            }
        }

        update srToUpdate;

        return 'Total complete: (' + success + '/' + total + ')';
    }

    @future(callout=true)
    public static void UpdateRateService(string recordId)
    {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        service.UpdateSampleRates(recordId);    
    }
}