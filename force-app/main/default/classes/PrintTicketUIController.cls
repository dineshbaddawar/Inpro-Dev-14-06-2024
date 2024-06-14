public class PrintTicketUIController {
    
      @AuraEnabled 
    public static List<SampleRequestListWrapper> fetchSampleRequestWrapper(){     
        List<SampleRequestListWrapper> lstSampleRequestListWrapper = new List<SampleRequestListWrapper>();
        // query account records and create 'SampleRequestListWrapper' class instance for each record. 
        for(Sample_Request__c sr : [Select Id,Name,Account__c,Status__c,Print_Date__c,Account__r.Name
                           From Sample_Request__c Where Status__c = 'Approved' order by CreatedDate desc
                           Limit 5000]){
                               // by default checkbox should be false 
                               lstSampleRequestListWrapper.add(new SampleRequestListWrapper(false,sr));
                           } 
        // return the 'lstaccountListWrapper' list 
        return lstSampleRequestListWrapper; 
    }
    @AuraEnabled 
    public static void pdfAction(List<Sample_Request__c> sampleReq){
        System.debug('sampleReq'+sampleReq);
        for (Sample_Request__c sr :sampleReq){
            sr.Print_Date__c = system.now();
        }
        if(sampleReq.size()>0){
            update sampleReq; 
        }
        
        
    }
    
    // wrapper class //  
    public class SampleRequestListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Sample_Request__c objSampleRequest {get;set;}
        public SampleRequestListWrapper(boolean isChecked, Sample_Request__c objSampleRequest){
            this.isChecked = isChecked;
            this.objSampleRequest = objSampleRequest;
        }
    }
  /*  @AuraEnabled 
    public static List<accountListWrapper> fetchAccountWrapper(){     
        List<accountListWrapper> lstaccountListWrapper = new List<accountListWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
        for(Account acc : [Select id,Name,Type,Phone
                           From Account
                           Limit 1000]){
                               // by default checkbox should be false 
                               lstaccountListWrapper.add(new accountListWrapper(false,acc));
                           } 
        // return the 'lstaccountListWrapper' list 
        return lstaccountListWrapper; 
    }
    
    // wrapper class //  
    public class accountListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  account objAccount{get;set;}
        public accountListWrapper(boolean isChecked, account objAccount){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
        }
    }
*/
}