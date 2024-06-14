public with sharing class SampleRequestController {
    public Id recordId {get;set;}
    public Sample_Request__c sampleRequest {get;set;}
    public string desiredShipping {get;set;}
    public string desiredPackaging {get;set;}
    
    public SampleRequestController() {
        recordId = apexpages.currentpage().getparameters().get('id');
        sampleRequest = [SELECT Id, Desired_Shipping_Method__c, Desired_Package_Type__c, Status__c FROM Sample_Request__c WHERE Id = :recordId];

        desiredShipping = sampleRequest.Desired_Shipping_Method__c;
        desiredPackaging = sampleRequest.Desired_Package_Type__c;
    }

    public void ChangeToUPS()
    {
        sampleRequest.Desired_Shipping_Method__c = 'UPS_Ground';
        sampleRequest.Desired_Package_Type__c = 'UPS Your Packaging';
        update sampleRequest;
        RefreshSampleRequest();
    }

    public void ChangeToFedEx()
    {
        sampleRequest.Desired_Shipping_Method__c = 'STANDARD_OVERNIGHT';
        sampleRequest.Desired_Package_Type__c = 'FedEx Your Packaging';
        update sampleRequest;
        RefreshSampleRequest();
    }

    public void ChangeToUSPS()
    {
        sampleRequest.Desired_Shipping_Method__c = 'Priority';
        sampleRequest.Desired_Package_Type__c = '';
        update sampleRequest;
        RefreshSampleRequest();
    }

    public void ChangeToUSPSFlatRateEnvelope()
    {
        sampleRequest.Desired_Package_Type__c = 'USPS Flat Rate Envelope';
        update sampleRequest;
        RefreshSampleRequest();
    }

    public void ChangeToUSPSPaddedFlatRateEnvelope()
    {
        sampleRequest.Desired_Package_Type__c = 'USPS Padded Flat Rate Envelope';
        update sampleRequest;
        RefreshSampleRequest();
    }

    private void RefreshSampleRequest()
    {
        sampleRequest = [SELECT Id, Desired_Shipping_Method__c, Desired_Package_Type__c, Status__c FROM Sample_Request__c WHERE Id = :sampleRequest.Id];
    }
}