public with sharing class GeoCode{
    
    @future (callout=true) 
    public static void updateGeoLocationAccountsObj(Set<Id> ids){
        List<account> rcrdList = [select shippingstreet, shippingcity, shippingstate, shippingpostalcode, shippingcountry from account where Id in :ids ];
        for(account a :rcrdList){
            Cooridinates crd = getAllLocationAccountsObj(a); 
            if (crd != null){
                // if(crd.Lon != null && crd.Lon != 0.0)a.ShippingLatitude = crd.Lat;   
                // if(crd.Lat != null && crd.Lat != 0.0)a.ShippingLongitude = crd.Lon;
                if(crd.Lat != null && crd.Lat != 0.0)a.Shipping_Address_Location__Latitude__s = crd.Lat;
                if(crd.Lon != null && crd.Lon != 0.0)a.Shipping_Address_Location__Longitude__s = crd.Lon;
                
            }
        }
        update rcrdList;
    }

    // @future (callout=true) 
    // public static void updateGeoLocationDtCompanyObj(Set<Id> ids){
    //     List<dt_company__c> rcrdList = [select contact_Street__c, contact_City__c, contact_State__c, contact_zip__c, contact_Country__c from dt_company__c where Id in :ids ]; 
    //     for(dt_company__c o :rcrdList){
    //         Cooridinates crd = getAllLocationDtCompanyObj(o);
    //         if (crd != null){
    //             if(crd.Lat != null && crd.Lat != 0.0)o.Location__Latitude__s = crd.Lat;
    //             if(crd.Lon != null && crd.Lon != 0.0)o.Location__Longitude__s = crd.Lon;
    //         }
    //     }
    //     update rcrdList;
    // }

    public static Cooridinates getAllLocationAccountsObj(account theAccount) { 
        String address = '';
        if (theAccount.shippingstreet != null) { address += theAccount.shippingstreet +', '; }
        if (theAccount.shippingcity != null) { address += theAccount.shippingcity +', '; }        
        if (theAccount.shippingstate != null) { address += theAccount.shippingstate +', '; } 
        if (theAccount.shippingpostalcode != null) { address += theAccount.shippingpostalcode +', '; } 
        if (theAccount.shippingcountry != null) { address += theAccount.shippingcountry; }         
        address = EncodingUtil.urlEncode(address, 'UTF-8');
                        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
                
        Google_API_Setting__c settings = GetSettings();
        system.debug('settings'+settings);
        String path = settings.Request_Path__c;        
        String apiKey = settings.API_Key__c;
        system.debug('apiKey'+apiKey);
        apiKey = apiKey.replace('-', '+').replace('_', '/');
        Blob apiKeyBlob = EncodingUtil.base64Decode(apiKey);        
        String baseRequest = path +'?address=' + address; 
        Blob urlBlob = Blob.valueOf(baseRequest); 
        String signature = settings.API_Key__c; //signature = signature.replace('+', '-').replace('/', '_');
        
        req.setEndpoint(settings.Base_URL__c + baseRequest + '&sensor=false&key=' + signature);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
            System.debug('::res.getStatusCode()::'+res.getStatusCode());
            if(res.getStatusCode() == 200) { 
                return fetchLatLongFromResponse(res.getBody());     
            } else { return null; } 
        } else { return null; }
    }
    
    // public static Cooridinates getAllLocationDtCompanyObj(dt_company__c theDTCmpny) { 
    //     String address = ''; 
    //     if (theDTCmpny.contact_Street__c != null) { address += theDTCmpny.contact_Street__c +', '; }
    //     if (theDTCmpny.contact_City__c != null) { address += theDTCmpny.contact_City__c +', '; }
    //     if (theDTCmpny.contact_State__c != null) { address += theDTCmpny.contact_State__c +' '; }
    //     if (theDTCmpny.contact_zip__c != null) { address += theDTCmpny.contact_zip__c+', '; }
    //     if (theDTCmpny.contact_Country__c != null) { address += theDTCmpny.contact_Country__c; }
    //     address = EncodingUtil.urlEncode(address, 'UTF-8');
        
    //     Http h = new Http();
    //     HttpRequest req = new HttpRequest();
                
    //     Google_API_Setting__c settings = GetSettings();
    //     String path = settings.Request_Path__c;        
    //     String apiKey = settings.API_Key__c;
    //     apiKey = apiKey.replace('-', '+').replace('_', '/');
    //     Blob apiKeyBlob = EncodingUtil.base64Decode(apiKey);        
    //     String baseRequest = path +'?address=' + address; 
    //     Blob urlBlob = Blob.valueOf(baseRequest); 
    //     String signature = settings.API_Key__c; //signature = signature.replace('+', '-').replace('/', '_');
        
    //     req.setEndpoint(settings.Base_URL__c + baseRequest + '&sensor=false&key=' + signature);
    //     req.setMethod('GET');
    //     req.setTimeout(60000);
        
    //     if(!Test.isRunningTest()){
    //         HttpResponse res = h.send(req);
    //         System.debug('::res.getStatusCode()::'+res.getStatusCode());
    //         if(res.getStatusCode() == 200) { 
    //             return fetchLatLongFromResponse(res.getBody());     
    //         } else { return null; } 
    //     }else { return null; }
    // }
    
    public static Cooridinates fetchLatLongFromResponse(String strResponse){
        JSONParser parser = JSON.createParser(strResponse);
        System.debug('::response::'+ strResponse);
        double lat = null;
        double lon = null; 
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')) { 
                parser.nextToken(); 
                while (parser.nextToken() != JSONToken.END_OBJECT) {
                    String txt = parser.getText();
                    parser.nextToken();
                    if(txt == 'lat') { lat = parser.getDoubleValue(); } 
                    else if(txt == 'lng') { lon = parser.getDoubleValue(); }
                } 
            } 
        } 
        return new Cooridinates(lat, lon);
    }
    
    private static Google_API_Setting__c GetSettings() { 
        return Google_API_Setting__c.getOrgDefaults(); 
    }
    
    public class Cooridinates { 
        public Double Lat {get; private set;} 
        public Double Lon {get; private set;}
        
        public Cooridinates(Double newLat, Double newLong) { 
            this.Lat = newLat; 
            this.Lon = newLong; 
        } 
    }
}