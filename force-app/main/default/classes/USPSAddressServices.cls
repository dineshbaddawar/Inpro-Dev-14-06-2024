public class USPSAddressServices {

    private static string BASE_URL = 'https://production.shippingapis.com/ShippingAPITest.dll';
    // NOTE: enter valid api key below
    private static string API_USERID = '728THEHU0618';

    public List<ResolvedZip> resolveZipcodes(Set<String> zipcodes) {
        
        System.debug('USPSAddressServices: resolveZipcodes: ' + zipcodes );
        
        // build XML request
        String xml = '<CityStateLookupRequest USERID="' + API_USERID + '">';
        for(String z : zipcodes) {
            xml += '<ZipCode ID= "' + z + '"><Zip5>' + z + '</Zip5></ZipCode>';
        }
        xml += '</CityStateLookupRequest>';
       
        string url = BASE_URL + '?API=CityStateLookup&XML=' + EncodingUtil.urlEncode(xml, 'UTF-8');
       
        String resp = makeGetCallout(url, '','');
       
        return parseZipXml(resp);
    }

    private List<ResolvedZip> parseZipXml(String xml) {
    
        System.debug('response: ' + xml);
        
        List<ResolvedZip> outZips = new List<ResolvedZip>();
        
        Dom.document doc = new Dom.Document();
    
        doc.load(xml); 
    
        //Retrieve the root element for this document.
        Dom.XMLNode address = doc.getRootElement();
        
        
        // Alternatively, loop through the child elements.
        // This prints out all the elements of the address
        for(Dom.XMLNode child : address.getChildElements()) {
           if (child.getChildren().size() != 3 && child.getChildren().size() != 7) {
               System.debug('XML Error Node: ' + child.getName() + ' : ' + child.getChildren().size());
               System.debug('XML Raw Node: ' + child);
               continue;
           }
           ResolvedZip rz = new ResolvedZip();
           rz.zipcode = child.getChildElement('Zip5', null).getText();
           rz.city = child.getChildElement('City', null).getText();
           rz.state = child.getChildElement('State', null).getText();
           System.debug('Got back resolved zipcode: ' + rz.zipcode);
           outZips.add(rz); 
        }
        system.debug(outZips);
        return outZips;
    }


    private String getTestXml() {
        String xml = 
            //'<?xml version="1.0" encoding="UTF-8"?>' + 
            '<CityStateLookupResponse>' + 
            '    <ZipCode ID="35811">' + 
            '        <Zip5>35811</Zip5>' + 
            '        <City>HUNTSVILLE</City>' + 
            '        <State>AL</State>' + 
            '    </ZipCode>' + 
            '    <ZipCode ID="37722">' + 
            '        <Zip5>37722</Zip5>' + 
            '        <City>COSBY</City>' + 
            '        <State>TN</State>' + 
            '    </ZipCode>' + 
            '</CityStateLookupResponse>';
       return xml; 
    }



    // util methods: 
    private String makeGetCallout(String url, String basicUsername, String basicPassword) {
        return makeCallout(url, basicUsername, basicPassword, false, null);
    }
    
    private String makePostCallout(String url, String basicUsername, String basicPassword, String postBody) {
        return makeCallout(url, basicUsername, basicPassword, true, postBody);
    }
    
    
    private String makeCallout(String url, String basicUsername, String basicPassword, boolean isPost, String postBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        if (isPost) {
            request.setMethod('POST');
        } else {
            request.setMethod('GET');
        }
        if (isPost) {
            request.setbody(postBody);
        } 
        
        HttpResponse response = null;
        
        // don't actually make callout if running test:
        if (!Test.isRunningTest()) {
            response = http.send(request);
        } else {
            response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(getTestXml());
        }
        
        // If the request is successful, parse the JSON response.
        if (response != null && response.getStatusCode() == 200) {
            //system.debug(response.getBody());
        } else {
            if (response == null) {
                system.debug('makeCallout: got a null response back');
            } else {
                system.debug('Bad response code: ' + response.getStatusCode());
                system.debug('Bad response body: ' + response.getBody());
            }
        }
        if (response == null) {
            return '';
        }
        return response.getBody();
    }


    // inner classes:
    public class ResolvedZip {
        public string zipcode {get;set;}
        public string city {get;set;}
        public string state {get;set;}
    }

}