public without sharing class GeoLocationUtilities {
    
    private static Decimal EARTH_RADIUS = 6372.80; // Radius in Kilometers default 6371.00
    
    //Public method that will calculate the distance in MILES between two lat/long coordinates
    public static Decimal calculateDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2){
        SYSTEM.debug('lat1'+lat1);
        SYSTEM.debug('lon1'+lon1);
        SYSTEM.debug('lat2'+lat2);
        SYSTEM.debug('lon2'+lon2);
        Decimal Radius = 6372.80;
        Decimal dLat = GeoLocationUtilities.toRadians(lat2-lat1);
        Decimal dLon = GeoLocationUtilities.toRadians(lon2-lon1);            
        Decimal a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(GeoLocationUtilities.toRadians(lat1)) *   Math.cos(GeoLocationUtilities.toRadians(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
        Decimal c = 2 * Math.asin(Math.sqrt(a));
        Decimal rt = (Radius * c) / 1.609344;    // For miles, divide km by 1.609344
        
        return rt.setScale(3);
    }
    
    //Public method to convert radians to degrees
    public static Decimal toRadians(Decimal degree){
        // Value degree * Pi/180
        Decimal res = degree * 3.1415926 / 180;
        
        return res;  
    }
    
    //Public method that returns a map of variables with the results of the geoloation request.
    //This method is used by the future methods below, so that addresses can be updated inside of triggers.
    public static Map<String, String> getLatLong(String addr) {
        
        //NOTE: enter the client's API key below
        String apiKey = ''; 
        String baseAddress = 'http://geoservices.tamu.edu/Services/Geocode/WebService/GeocoderWebServiceHttpNonParsed_V04_01.aspx?apiKey='+apiKey+'&format=csv&version=4.01&';
        
        Google_API__mdt apiEntry = [Select DeveloperName, URL__c, API_Key__c from Google_API__mdt where DeveloperName = 'Google_Geocoding_API'];
        
        Map<String, String> mgeo = new Map<String, String>();
        String lat = '0';
        String lon = '0';
        mgeo.put('lat',lat);
        mgeo.put('lon',lon);
        mgeo.put('qua','');
        mgeo.put('err','0');     
        
        if (addr != '') {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            //req.setEndpoint(baseAddress+addr);
            req.setEndpoint(apiEntry.URL__c+'json?address='+addr+'&key='+apiEntry.API_Key__c);
            //req.setMethod('GET');
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setHeader('Content-Type','application/json');
            String s = '';
            req.setBody(s);
            
            //try{
                // callout
                HttpResponse res = new HttpResponse();
                if(!Test.isRunningTest()) {
                    res = h.send(req);
                } else {
                    String responseString = GeolocationUtilitiesCalloutMock.jsonResponse;
                    res.setStatusCode(200);
                    res.setBody(responseString);
                }
                
                if (res.getStatusCode()==200 && res.getBody().length()>0) {
                    GoogleGeoWrapper wrapResult = GoogleGeoWrapper.parse(res.getBody());
                    
                    System.debug('geo wrapper: ' + wrapResult);
                    System.debug('status code: ' + res.getStatusCode());
                    System.debug('body : ' + res.getBody());
                    
                    if(wrapResult.Status == 'OVER_QUERY_LIMIT') {
                        mgeo.put('err', 'Over query limit');
                    } else if(wrapResult.Results.size()>0) {
                        GoogleGeoWrapper.Results firstResult = wrapResult.Results[0];

                        mgeo.put('lat', String.valueOf(firstResult.geometry.location.lat));
                        mgeo.put('lon', String.valueOf(firstResult.geometry.location.lng));
                        mgeo.put('qua', firstResult.geometry.location_type);
                    }

                    /*String csvResp = res.getBody();
                    system.debug('==========================csv=================='+csvResp);
                    List<String> respList = csvResp.split(',');
                    
                    if (!respList.isEmpty()) {
                        String qual = respList[5]+';'+respList[8]+';'+respList[11];
                        
                        if (respList[3]!='') {
                            lat = respList[3];
                        }
                        if (respList[4]!='') {
                            lon = respList[4];
                        }
                        
                        mgeo.put('lat',lat);
                        mgeo.put('lon',lon);
                        mgeo.put('qua', qual);
                        
                    }  */
                } else {
                    mgeo.put('err', String.valueOf(res.getStatusCode()));
                    System.debug('Error in Google API: ' + res.GetStatusCode() + ' - ' + res.getBody());
                }
            /*} catch (Exception e) {
                // if needed track error
            }*/
        }
        
        return mgeo;
        
    }
    
    //Public static method that will take a list of lead IDs and use the geolocation services to populate
    //the lat/long for the addresses of the lead records.
    /* ********As of April 2018, the standard Data Clean rules have been enabled and Leads do not currently
    have any custom address fields that would need to have the lat/long popualted*********
    @future (callout=true)
    public static void getLatLongLead(set<Id> newRecords){
        
        if (!newRecords.IsEmpty()) {
            
            list<Lead> lUpdt = new list<Lead>();
            
            for (lead l : [select Id, Street, City, State, PostalCode from Lead where Id in : newRecords]) {
                
                String address = '';
                if (l.Street != null)
                    address += 'streetAddress=' + EncodingUtil.urlEncode(l.Street, 'UTF-8') +'&';
                if (l.City != null)
                    address += 'city=' + EncodingUtil.urlEncode(l.City, 'UTF-8') +'&';
                if (l.State != null)
                    address += 'state=' + EncodingUtil.urlEncode(l.State, 'UTF-8') +'&';
                if (l.PostalCode != null)
                    address += 'zip=' + EncodingUtil.urlEncode(l.PostalCode, 'UTF-8') +' ';
                
                system.debug('=====================================base addr+addr========================='+address);
                
                map<string, string> mg = getLatLong(address);
                
                if (!mg.isEmpty() && mg.get('err')=='0') {
                    decimal lat = 0;
                    decimal lon = 0;
                    if (mg.get('lat')!=null) {
                        lat = decimal.valueOf(mg.get('lat'));
                    }
                    if (mg.get('lon')!=null) {
                        lon = decimal.valueOf(mg.get('lon'));
                    }
                    lUpdt.add(new Lead(Id=l.Id, Latitude = lat, Longitude = lon, Geocode_Quality__c = mg.get('qua')));
                } else {
                    lUpdt.add(new Lead(Id=l.Id, Geocode_Quality__c = string.valueOf(mg.get('err'))));
                }
                
            }
            
            if (!lUpdt.isEmpty()) {
                update lUpdt;
            }
        }
    }*/

    //Public static method that will take a list of account IDs and use the geolocation services to populate
    //the lat/long for the custom address fields of the account records.
    //@future (callout=true)
    public static void getLatLongAccount(set<Id> newRecords){
        if (!newRecords.IsEmpty() && newRecords.size() <= 100) {
            
            List<Account> acctsToUpdate = new List<Account>();
            
            for (Account a : [select Id, Billing_Street_Address__c, Billing_City__c, Billing_State__c, Billing_Postal_Code__c,
                              BillingStreet,BillingCity,BillingState,BillingPostalCode
            					from Account where Id in : newRecords]) {
                
                String address = '';
                /*if (a.Billing_Street_Address__c != null)
                    address += 'streetAddress=' + EncodingUtil.urlEncode(a.Billing_Street_Address__c, 'UTF-8') +'&';
                if (a.Billing_City__c != null)
                    address += 'city=' + EncodingUtil.urlEncode(a.Billing_City__c, 'UTF-8') +'&';
                if (a.Billing_State__c != null)
                    address += 'state=' + EncodingUtil.urlEncode(a.Billing_State__c, 'UTF-8') +'&';
                if (a.Billing_Postal_Code__c != null)
                    address += 'zip=' + EncodingUtil.urlEncode(a.Billing_Postal_Code__c, 'UTF-8') +' ';*/
                                    
                /*if (a.Billing_Street_Address__c != null)
                    address += EncodingUtil.urlEncode(a.Billing_Street_Address__c, 'UTF-8') +',';
                if (a.Billing_City__c != null)
                    address += EncodingUtil.urlEncode(a.Billing_City__c, 'UTF-8') +',';
                if (a.Billing_State__c != null)
                    address += EncodingUtil.urlEncode(a.Billing_State__c, 'UTF-8') +',';
                if (a.Billing_Postal_Code__c != null)
                    address += EncodingUtil.urlEncode(a.Billing_Postal_Code__c, 'UTF-8');*/
                                    
                if (a.BillingStreet != null)
                    address += EncodingUtil.urlEncode(a.BillingStreet, 'UTF-8') +',';
                if (a.BillingCity != null)
                    address += EncodingUtil.urlEncode(a.BillingCity, 'UTF-8') +',';
                if (a.BillingState != null)
                    address += EncodingUtil.urlEncode(a.BillingState, 'UTF-8') +',';
                if (a.BillingPostalCode  != null)
                    address += EncodingUtil.urlEncode(a.BillingPostalCode, 'UTF-8');                   
                                  
                                    
                Map<String, String> results = getLatLong(address);
                
                if (!results.isEmpty() && results.get('err')=='0') {
                    decimal lat = 0;
                    decimal lon = 0;
                    if (results.get('lat')!=null) {
                        lat = decimal.valueOf(results.get('lat'));
                    }
                    if (results.get('lon')!=null) {
                        lon = decimal.valueOf(results.get('lon'));
                    }
                    acctsToUpdate.add(new Account(Id=a.Id, Contractor_Location__Latitude__s = lat, Contractor_Location__longitude__s = lon, Geocode_Quality__c = results.get('qua'), Queue_Geolocation__c=false));
                } else {
                    acctsToUpdate.add(new Account(Id=a.Id, Geocode_Quality__c = string.valueOf(results.get('err')), Queue_Geolocation__c = false));
                }
                
            }
            
            System.debug('accounts to set geolocation: ' + acctsToUpdate);

            if (!acctsToUpdate.isEmpty()) {
                update acctsToUpdate;
            }
        }      
    }
    
    public static void getLatLongConstructionProject(set<Id> newRecords){
        if (!newRecords.IsEmpty() && newRecords.size() <= 100) {
            
            List<Construction_Project__c> projsToUpdate = new List<Construction_Project__c>();
            
            for (Construction_Project__c a : [select Id, Street_Address__c, City__c, State__c, ZIP_or_Postal_Code__c from Construction_Project__c where Id in : newRecords]) {
                
                String address = '';
                
                if (a.Street_Address__c != null)
                    address += EncodingUtil.urlEncode(a.Street_Address__c, 'UTF-8') +',';
                if (a.City__c != null)
                    address += EncodingUtil.urlEncode(a.City__c, 'UTF-8') +',';
                if (a.State__c != null)
                    address += EncodingUtil.urlEncode(a.State__c, 'UTF-8') +',';
                if (a.ZIP_or_Postal_Code__c != null)
                    address += EncodingUtil.urlEncode(a.ZIP_or_Postal_Code__c, 'UTF-8');
                
                Map<String, String> results = getLatLong(address);
                
                if (!results.isEmpty() && results.get('err')=='0') {
                    decimal lat = 0;
                    decimal lon = 0;
                    if (results.get('lat')!=null) {
                        lat = decimal.valueOf(results.get('lat'));
                    }
                    if (results.get('lon')!=null) {
                        lon = decimal.valueOf(results.get('lon'));
                    }
                    projsToUpdate.add(new Construction_Project__c(Id=a.Id, Project_Location__Latitude__s = lat, Project_Location__Longitude__s = lon, Queue_Geolocation__c=false));
                } else {
                    projsToUpdate.add(new Construction_Project__c(Id=a.Id, Queue_Geolocation__c = false));
                }
                
            }
            
            System.debug('accounts to set geolocation: ' + projsToUpdate);

            if (!projsToUpdate.isEmpty()) {
                update projsToUpdate;
            }
        }      
    }
    
    

}