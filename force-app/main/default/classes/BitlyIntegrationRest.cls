/*************************************************************
* Created by:   The Hunley Group
* Created on:    4/21/2020
* ===========================================================
* Test Class:   LunchandLeanControllerTEST
* ===========================================================
* Purpose:   Apex class with bitly integration to shorten 
*            the attendance URL. 
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 4/21/2020     THG - JP        Created
*
************************************************************/
public class BitlyIntegrationRest {
    
    @Future(callout=true)
    public static void UrlShorten(String id)
    {
        //?
    }
    
    public String ReturnAccessToken (String code)
    {        
        String reqbody = 'client_id='+LunchandLearnUtils.GetMetadataValue('Client_Id__c')+'&client_secret='+LunchandLearnUtils.GetMetadataValue('Client_Secret__c')+'&code='+code+'&redirect_uri='+LunchandLearnUtils.GetMetadataValue('Redirect_URI__c');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept','application/json');
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint('https://api-ssl.bitly.com/oauth/access_token');
        HttpResponse res = h.send(req);
        system.debug('resPONSE'+res.getBody());
        BitlyIntegrationAccessRes resp1 = (BitlyIntegrationAccessRes)JSON.deserialize(res.getbody(),BitlyIntegrationAccessRes.class);
        system.debug('ReturnAccessToken-access_token@@'+resp1.access_token );
        BitlyAccessToken__c bitlysettings =  BitlyAccessToken__c.getInstance('Credentials');
        bitlysettings.Access_Token__c=resp1.access_token;
        bitlysettings.API_Key__c=resp1.apikey; 
        bitlysettings.user_name__c=resp1.login;
        update bitlysettings;
        return null;
    }
    
    /*@Future(callout=true)
    public static void UrlShortenAttendanceLink( id landlEventId) {
        
        LunchAndLearnEvent__c    e = [select id,Name,Location1__c,Attendance_Link1__c,Advance_Registration_Link__c
                                      from LunchAndLearnEvent__c   where id =: landlEventId];
        String accessToken;
        BitlyAccessToken__c bitlyaccess= new BitlyAccessToken__c();
        bitlyaccess =  [select Access_Token__c,API_Key__c,user_name__c from BitlyAccessToken__c limit 1];
        system.debug('bitlyaccess'+bitlyaccess);
        String endPoint = 'https://api-ssl.bitly.com/v3/shorten?access_token='+bitlyaccess.Access_Token__c+'&longUrl='+e.Attendance_Link1__c;
        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setMethod('GET');
        req1.setEndpoint(endPoint);
        HttpResponse res1 = new HttpResponse();
        if(!Test.isRunningTest()) {
            res1 = h2.send(req1);
        } else {
            res1 = BitlyMockCallout.respond(req1);
        }
        system.debug('URL Short' + res1.getBody()); 
        String trimmedResponse = res1.getBody().unescapeCsv().remove('\\');
        BitlyIntegrationCalloutResponse resp = (BitlyIntegrationCalloutResponse)JSON.deserialize(res1.getbody(),BitlyIntegrationCalloutResponse.class);
        BitlyIntegrationCalloutResponse.DataClass dataObj = new BitlyIntegrationCalloutResponse.DataClass();
        dataObj = resp.data;
        system.debug('@@@trimmedResponse@@'+trimmedResponse);
        system.debug('@@@getBody@@'+dataObj.url);
        e.Attendance_Link__c = dataObj.url;
        update e;
        // system.debug('@@@ status_code@@'+resp.status_code());
        // Update related calendar event description
        Event eventObj=[Select Id,Description,Lunch_and_Learn_Event__c from Event where 
                        Lunch_and_Learn_Event__c=:landlEventId];
        eventobj.Description=e.Name+'\n'+'Location: '+e.Location1__c+'\n'+'Registration Link for course: '+dataObj.url;
        update eventObj;
    }
    
    
    @Future(callout=true)
    public static void UrlShortenAdvanceLink( id landlEventId) {
        LunchAndLearnEvent__c    e = [select id,Name,Location1__c,Attendance_Link1__c,Advance_Registration_Link__c
                                      from LunchAndLearnEvent__c   where id =: landlEventId];
        String accessToken;
        BitlyAccessToken__c bitlyaccess= new BitlyAccessToken__c();
        bitlyaccess =  [select Access_Token__c,API_Key__c,user_name__c from BitlyAccessToken__c limit 1];
        system.debug('bitlyaccess'+bitlyaccess);
        String endPoint = 'https://api-ssl.bitly.com/v3/shorten?access_token='+bitlyaccess.Access_Token__c+'&longUrl='+e.Advance_Registration_Link__c;
        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Authorization','Bearer ' + accessToken);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setMethod('GET');
        req1.setEndpoint(endPoint);
        HttpResponse res1 = new HttpResponse();
        if(!Test.isRunningTest()) {
            res1 = h2.send(req1);
        } else {
            res1 = BitlyMockCallout.respond(req1);
        }
        system.debug('URL Short' + res1.getBody()); 
        String trimmedResponse = res1.getBody().unescapeCsv().remove('\\');
        BitlyIntegrationCalloutResponse resp = (BitlyIntegrationCalloutResponse)JSON.deserialize(res1.getbody(),BitlyIntegrationCalloutResponse.class);
        BitlyIntegrationCalloutResponse.DataClass dataObj = new BitlyIntegrationCalloutResponse.DataClass();
        dataObj = resp.data;
        system.debug('@@@trimmedResponse@@'+trimmedResponse);
        system.debug('@@@getBody@@'+dataObj.url);
        e.Advance_Registration_Link_Small__c = dataObj.url;
        update e;
        
    }*/
    
    @Future(callout=true)
    public static void shortenLandLRegistrationLinks(id landlEventId, string regLongFieldAPIName, string regShortFieldAPIName) {
         
        String landlEventSOQL = 'Select Id,Name,Location1__c,'+ regLongFieldAPIName + ' FROM LunchAndLearnEvent__c WHERE Id =: landlEventId' ;
        LunchAndLearnEvent__c landlEvent = database.query(landlEventSOQL);
        
        BitlyAccessToken__c bitlyaccess= new BitlyAccessToken__c();
        bitlyaccess =  [select Endpoint__c,Group_guid__c,Access_Token__c from BitlyAccessToken__c limit 1];
        system.debug('bitlyaccess'+bitlyaccess);
        
        BitlyRequestBody jsonBody = new BitlyRequestBody();
        jsonBody.long_url = String.valueOf(landlEvent.get(regLongFieldAPIName));
        jsonBody.group_guid = bitlyaccess.Group_guid__c;
        
        HttpResponse res1 = new HttpResponse();
        HttpRequest req1 = new HttpRequest();
        if(!Test.isRunningTest()) {
            Http h2 = new Http();
        
        req1.setHeader('Authorization','Bearer ' + bitlyaccess.Access_Token__c);
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setMethod('POST');
        req1.setEndpoint(bitlyaccess.Endpoint__c);
        req1.setBody(JSON.serialize(jsonBody));        
        system.debug('req1'+req1);
            res1 = h2.send(req1);
        } else {
            res1 = BitlyMockCallout.respond(req1);
        }
        system.debug('URL Short' + res1.getBody()); 

        BitlyIntegrationCalloutResponse resp = (BitlyIntegrationCalloutResponse)JSON.deserialize(res1.getbody(),BitlyIntegrationCalloutResponse.class);

        system.debug('@@@getBody@@'+resp.created_at);
        landlEvent.put(regShortFieldAPIName,resp.link);
        update landlEvent;
        
        if(regLongFieldAPIName == 'Attendance_Link1__c'){
            Event eventObj=[Select Id from Event where 
                            Lunch_and_Learn_Event__c=:landlEventId];
            eventobj.Description=landlEvent.Name+'\n'+'Location: '+landlEvent.Location1__c+'\n'+'Registration Link for course: '+resp.link;
            update eventObj;
        }
        
    }
    
    public class BitlyRequestBody {
        public String long_url;
        public String group_guid;
    }
    
}