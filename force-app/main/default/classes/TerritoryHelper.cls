public with sharing class TerritoryHelper {

    @invocablemethod
    public static List<string> getTerritory(List<ZipDTO> zipDTO) {
        List<string> stringList = new List<string>();
        stringList.add( getTerritoryId(zipDTO[0].ZipCode, zipDTO[0].StateCode));        
       return stringList;
    }

    @AuraEnabled()
    public static string getTerritoryId(string ZipCode, string StateCode)
    {        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        return service.GetTerritoryId(ZipCode, StateCode, 'dsj8U73_3nv3Dhba');        
    }

    @AuraEnabled()
    @future (callout = true)
    public static void updateRecordTerritory(string RecordType, string RecordId, string ZipCode, string StateCode, string CountryCode) {                
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;    
        
        //EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'TerritoryHelper for Test Competitor', 'RecordType: ' + RecordType + '<br>RecordId:' + RecordId + '<br>ZipCode' + ZipCode + '<<br>StateCode: ' + StateCode );

        string territoryId = '';
        try 
        {
          
          if((ZipCode != null && ZipCode != '') || (StateCode != null && StateCode != '') || (CountryCode != null && CountryCode != '') )
          {
            if(CountryCode == 'US' || CountryCode == 'CA' || CountryCode == 'Canada' || CountryCode == 'United States'  || CountryCode == '' )    
              territoryId = service.GetTerritoryId(ZipCode, StateCode, 'dsj8U73_3nv3Dhba');   
            else if(CountryCode != null && CountryCode != '')
              territoryId = service.GetTerritoryIdByCountryCode(CountryCode, 'dsj8U73_3nv3Dhba');   
          }
          
        } catch (Exception ex) {
          //EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'TerritoryHelper Failure', ex.getMessage());
        }

         if(territoryId != null && territoryId != '')
         {
             if(RecordType == 'Account')
             {
                Account a = new Account();
                a.Id = RecordId;
                a.territory_lookup__c  = territoryId;
                system.debug('Account data - ' + a);
                update a;
             }
             else if (RecordType == 'Construction_Project__c')
             {
                Construction_Project__c c = new Construction_Project__c();
                c.Id = RecordId;
                c.Territory__c = territoryId;
                system.debug('Construction Project data - ' + c);
                update c;
             }
             else if (RecordType == 'Lead')
             {
                Lead l = new Lead();
                l.Id = RecordId;
                l.Territory__c = territoryId;
                system.debug('Lead data - ' + l);
                update l;
             }
             else if (RecordType == 'Opportunity')
             {
               Opportunity o = new Opportunity();
               o.Id = RecordId;
               o.Territory__c = territoryId;
               o.Flick__c = true;
               system.debug('Opportunity data - ' + o);
               update o;
             }
         }
    } 
    
    @AuraEnabled()
    @future (callout = true)
    public static void bulkUpdateTerritories(string RecordType, List<string> RecordIds) {                
          sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
          service.timeout_x = 120000;            
        try 
        {          
          sfdata.ArrayOfString stringArray = new sfdata.ArrayOfString();
          stringArray.string_x = RecordIds;
          string result = service.BulkUpdateTerritories(stringArray, RecordType, 'dsj8U73_3nv3Dhba');
          //EmailSendHelper.sendEmail('dsieraski@inprocorp.com', '', 'Bulk Update Territory Results', result);
        } catch (Exception ex) {
          //EmailSendHelper.sendEmail('bsibley@inprocorp.com', '', 'TerritoryHelper Failure', ex.getMessage());
        }         
    } 

    public static void updateTerritory(string RecordType, string ZipCode, string StateCode, string CountryCode, List<string>  RecordIds)
    {
      if(RecordIds.size() == 0)
        return;
      
        if(RecordIds.size() > 1)
        {
          bulkUpdateTerritories(RecordType, RecordIds);
        }
        else {
          updateRecordTerritory(RecordType, RecordIds[0], ZipCode, StateCode, CountryCode);
        }

    }

    public class ZipDTO
    {
        @InvocableVariable
      public string ZipCode;
      @InvocableVariable
      public string StateCode;
    }
    
}