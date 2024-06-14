public with sharing class AccountSubReqTriggerHandler {
    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;
    private List<Account> newAcctList;
    
    
    //Constructor for Before Insert and After Insert trigger context 
    public AccountSubReqTriggerHandler(List<Account> acctList,Map<Id, Account> triggerNewMap) {
        this.newAcctList = acctList;
        this.newMap = triggerNewMap;
        this.oldMap = new Map<Id, Account>();
        
        
    }
    
    //Constructor for Before Update and After Update trigger context
    public AccountSubReqTriggerHandler(Map<Id, Account> newAcctMap, Map<Id, Account> oldAcctMap) {
        this.newMap = newAcctMap;
        this.oldMap = oldAcctMap;
        this.newAcctList = newAcctMap.values();
    }
    
    //Public method called by the trigger to perform Before Insert logic
    public void beforeInsert() {
        queueBillingGeolocation(newAcctList, oldMap);
    }
    
    //Public method called by the trigger to perform Before Update logic
    public void beforeUpdate() {
        queueBillingGeolocation(newAcctList, oldMap);
        handleResolvingZipcodes();
    }
    public void afterInsert() {
        handleResolvingZipcodes();
    }
    
    
    
    private void queueBillingGeolocation(List<Account> newAcctList, Map<Id, Account> oldAcctMap) {
        
        if(oldAcctMap.size() == 0) {
            for(Account a : newAcctList) {
                
                if(!String.isBlank(a.BillingStreet) || !String.isBlank(a.BillingCity) ||
                   !String.isBlank(a.BillingState) || !String.isBlank(a.BillingCountry) ||
                   !String.isBlank(a.BillingPostalCode)) {
                       a.Queue_Geolocation__c = true;
                   }
            }
        } else {
            for(Account a : newAcctList) {
                Account oldA = oldAcctMap.get(a.Id);
                if((!String.isBlank(a.BillingStreet) && oldA.BillingStreet != a.BillingStreet)
                   || (!String.isBlank(a.BillingCity) && oldA.BillingCity != a.BillingCity)
                   || (!String.isBlank(a.BillingState) && oldA.BillingState != a.BillingState)
                   || (!String.isBlank(a.BillingCountry) && oldA.BillingCountry != a.BillingCountry)
                   || (!String.isBlank(a.BillingPostalCode) && oldA.BillingPostalCode != a.BillingPostalCode)) {
                       a.Queue_Geolocation__c = true;
                   } else if ((!String.isBlank(a.BillingStreet) || !String.isBlank(a.BillingCity) ||
                               !String.isBlank(a.BillingState) || !String.isBlank(a.BillingCountry) ||
                               !String.isBlank(a.BillingPostalCode)) && (String.isBlank(String.valueOf(a.Contractor_Location__latitude__s)) ||
                                                                              String.isBlank(String.valueOf(a.Contractor_Location__longitude__s)))) {
                                                                                  a.Queue_Geolocation__c = true;
                                                                              } else if (String.isBlank(a.BillingStreet) && String.isBlank(a.BillingCity) &&
                                                                                         String.isBlank(a.BillingState) && String.isBlank(a.BillingCountry) &&
                                                                                         String.isBlank(a.BillingPostalCode) && !String.isBlank(string.Valueof(a.Contractor_Location__latitude__s))
                                                                                         && !String.isBlank(string.ValueOf(a.Contractor_Location__longitude__s))) {
                                                                                             a.Contractor_Location__longitude__s = null;
                                                                                             a.Contractor_Location__latitude__s = null;
                                                                                         }
            }
        }
    }
    
    
    
        public void handleResolvingZipcodes() {
    
	    // we can't launch our future method from a batch or another future call, so just exit here 
		// if it matches those modes:
		if (System.isBatch() || System.isFuture()) {
			return;
		}

        Pattern isnumbers = Pattern.Compile('^[0-9]+$');
        Matcher postalMatch;
        
        system.debug('In handleResolvingZipcodes()');
        integer batchSize = 10;
        List<Account> accsNeedingProcessing = new List<Account>();
        List<Account> accsNeedingShippingProcessing = new List<Account>();
        for(String key : this.newMap.keySet()) {
            Account nAcc = this.newMap.get(key);
            
            if (!String.IsEmpty(nAcc.BillingPostalCode) && (String.IsEmpty(nAcc.BillingState) || String.IsEmpty(nAcc.BillingCity))) {
                if (nAcc.BillingPostalCode.length() >= 5) {
                    postalMatch = isnumbers.matcher(nAcc.BillingPostalCode.subString(0, 5));
                    if (postalMatch.Matches()) {
                        accsNeedingProcessing.add(nAcc);
                    }
                }
            }
            
            if (!String.IsEmpty(nAcc.ShippingPostalCode) && (String.IsEmpty(nAcc.ShippingState) || String.IsEmpty(nAcc.ShippingCity))) {
                if (nAcc.ShippingPostalCode.length() >= 5) {
                    postalMatch = isnumbers.matcher(nAcc.ShippingPostalCode.subString(0, 5));
                    if (postalMatch.Matches()) {
                        accsNeedingShippingProcessing.add(nAcc);
                    }
                }
            }
        }
        List<String> accIdsNeedingProcessing = new List<String>();
        List<String> accIdsNeedingShippingProcessing = new List<String>();
        integer counter = 0;
        for(Account l : accsNeedingProcessing) {
        
            accIdsNeedingProcessing.add(l.Id);
            
            counter++;
            if (math.mod(counter, batchSize) == 0) {
                system.debug('handleResolvingZipcodes(): scheduling Batch: ' + accIdsNeedingProcessing);
                resolveZipcodesFutureCall(accIdsNeedingProcessing);    
                accIdsNeedingProcessing.clear();
            }
        }
        counter = 0;    
        for(Account l : accsNeedingShippingProcessing) {
        
            accIdsNeedingShippingProcessing.add(l.Id);
            
            counter++;
            if (math.mod(counter, batchSize) == 0) {
                system.debug('handleResolvingZipcodes(): scheduling Batch: ' + accIdsNeedingShippingProcessing);
                resolveZipcodesShippingFutureCall(accIdsNeedingShippingProcessing);    
                accIdsNeedingShippingProcessing.clear();
            }
        }    
        // call one last time for our 'odd' numbered batch
        if (accIdsNeedingProcessing.size() > 0) {
            system.debug('handleResolvingZipcodes(): schedulingLastBatch: ' + accIdsNeedingProcessing);
            resolveZipcodesFutureCall(accIdsNeedingProcessing);    
        }
        
        if (accIdsNeedingShippingProcessing.size() > 0) {
            system.debug('handleResolvingZipcodes(): schedulingLastBatch: ' + accIdsNeedingShippingProcessing);
            resolveZipcodesShippingFutureCall(accIdsNeedingShippingProcessing);    
        }
    }
    
    
    @future(callout=true)
    public static void resolveZipcodesFutureCall(List<String> leadIds) {   
        
        List<Account> accsToProcess = [Select Id, BillingPostalCode, BillingCity, BillingState from Account where Id in :leadIds];
        List<Account> accsToUpdate = new List<Account>();
        Set<String> zipcodes = new Set<String>();
        for(Account l : accsToProcess) {
            if (!String.IsEmpty(l.BillingPostalCode)) {
                if (l.BillingPostalCode.length() >= 5) {   // these should have been validated coming in, so we just
                                                    // verify length to avoid an exception
                    zipcodes.add(l.BillingPostalCode.subString(0,5));
                }
            }
        }
        if (zipcodes.size() > 0) {
            USPSAddressServices serv = new USPSAddressServices();
            List<USPSAddressServices.ResolvedZip> rzs = serv.resolveZipcodes(zipcodes); 
            for(USPSAddressServices.ResolvedZip rz : rzs) {
                // find leads which match this zip:
                for(Account l : accsToProcess) {
                    if (l.BillingPostalCode == rz.zipcode) {
                        l.BillingCity = rz.city;
                        l.BillingState = rz.state;
                        accsToUpdate.add(l);   
                    }
                }
            }
        }
        if (accsToUpdate.size() > 0) {
            update accsToUpdate;
        }   
            
    }
    
    
    @future(callout=true)
    public static void resolveZipcodesShippingFutureCall(List<String> leadIds) {   
        
        List<Account> accsToProcess = [Select Id, ShippingPostalCode, ShippingCity, ShippingState from Account where Id in :leadIds];
        List<Account> accsToUpdate = new List<Account>();
        Set<String> zipcodes = new Set<String>();
        for(Account l : accsToProcess) {
            if (!String.IsEmpty(l.ShippingPostalCode)) {
                if (l.ShippingPostalCode.length() >= 5) {   // these should have been validated coming in, so we just
                                                    // verify length to avoid an exception
                    zipcodes.add(l.ShippingPostalCode.subString(0,5));
                }
            }
        }
        if (zipcodes.size() > 0) {
            USPSAddressServices serv = new USPSAddressServices();
            List<USPSAddressServices.ResolvedZip> rzs = serv.resolveZipcodes(zipcodes); 
            for(USPSAddressServices.ResolvedZip rz : rzs) {
                // find leads which match this zip:
                for(Account l : accsToProcess) {
                    if (l.ShippingPostalCode == rz.zipcode) {
                        l.ShippingCity = rz.city;
                        l.ShippingState = rz.state;
                        accsToUpdate.add(l);   
                    }
                }
            }
        }
        if (accsToUpdate.size() > 0) {
            update accsToUpdate;
        }   
            
    }
    
}