/**************************************************************************
* Created by:   The Hunley Group
* Created on:   4/21/2020
* ==========================================================================
* Test Class:   LunchandLearnController_Test
* ==========================================================================
* Purpose:      This is the controller class for LunchandLearnComponent.
*
* ==========================================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   --------------------------------------------
* 4/21/2020     THG - JP        Created
*
****************************************************************************/
public class LunchandLearnCampaign {
    @auraEnabled
    public static list<Course__c> Campaign() {
        list<Course__c> camp = new List<Course__c>();
        camp = [
            SELECT Id, Name, IsActive__c
            FROM Course__c
            WHERE IsActive__c = true
            ORDER BY Name
        ];
        system.debug('camp' + camp);
        return camp;
    }
    
    @auraEnabled
    public static id createEvent(string accid, string location, string campaignname, id campaignid, string dateTimes) {
        string dateTimetoconvert = dateTimes.replace('T', ' ').replace('Z', '');
        Datetime formatted = Datetime.valueOf(dateTimetoconvert);
        string dateTime1 = dateTimes.substring(0, 10);
        system.debug('formatted: ' + formatted);
        system.debug('dateTime1: ' + dateTime1);
        LunchAndLearnEvent__c evt = new LunchAndLearnEvent__c();
        evt.StartDateTime__c = formatted;
        evt.EndDateTime__c = formatted.addHours(1);
        evt.Course_Name__c = campaignid;
        
        String eventNameLocation = '';
        if (String.isNotBlank(location)) {
            eventNameLocation = location;
            evt.Location__c = location;
        }
        if (String.isNotBlank(accid)) {
            Account locAcc = [SELECT id, name FROM Account WHERE id = :accid];
            eventNameLocation = locAcc.name;
            evt.Related_To__c = accid;
        }
        String eventName =
            campaignname +
            ' - ' +
            eventNameLocation +
            ' -  ' +
            formatted.month() +
            '/' +
            formatted.day() +
            '/' +
            formatted.year();
        
        if (eventName.length() > 79) {
            evt.Name = eventName.substring(0, 78);
        } else {
            evt.Name = eventName;
        }
        system.debug('Coursename' + evt);
        insert evt;
        return evt.id;
    }
    
    public static Datetime getLocalDateTime(Datetime g) {
        Datetime l = g.Date();
        l = l.addHours(g.hour());
        l = l.addMinutes(g.minute());
        l = l.addSeconds(g.second());
        return l;
    }
    @auraEnabled
    public static LunchAndLearnEvent__c searchDuplicateEvents(
        string accid,
        string location,
        id campaignid,
        string dateTimes
    ) {
        system.debug('dateTimes' + dateTimes);
        Datetime EntryDate = Datetime.now();
        EntryDate = EntryDate.addYears(-3);
        
        String queryStr = 'SELECT Id, Name, StartDateTime__c, Location__c ';
        queryStr += 'FROM LunchAndLearnEvent__c ';
        queryStr += 'WHERE StartDateTime__c > :EntryDate AND Course_Name__c = :campaignid ';
        if (String.isNotBlank(accid)) {
            queryStr += 'AND Related_To__c = :accid ';
        } else if (String.isNotBlank(location)) {
            queryStr += 'AND Location__c = :location ';
        }
        queryStr += 'ORDER BY StartDateTime__c DESC';
        
        List<LunchAndLearnEvent__c> oldEvents = Database.query(queryStr);
        System.debug('queryStr: ' + queryStr);
        System.debug('oldEvents' + oldEvents);
        
        if (oldEvents.size() > 0) {
            return oldEvents[0];
        } else
            return null;
    }
    
    @AuraEnabled
    public static String searchDB(Integer lim, String searchText) {
        searchText = '\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        String query = 'SELECT Name ,Id,BillingCity, BillingState FROM Account WHERE Name LIKE ' + searchText + ' LIMIT ' + lim;
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        for (SObject s : sobjList) {
            
            String[] addr = new String[] {String.valueOf(s.get('BillingCity')), String.valueOf(s.get('BillingState'))};
                for(Integer i = 1; i >= 0; i--) {
                    if(addr[i] == null) {
                        addr.remove(i);
                    }
                }
            
            String theAddr = String.join(addr, ', ');
            
            ResultWrapper obj = new ResultWrapper();
            obj.objName = 'Account';
            obj.text = String.valueOf(s.get('Name'));
            obj.val = String.valueOf(s.get('Id'));
            obj.address  = theAddr;
            lstRet.add(obj);
        }
        return JSON.serialize(lstRet);
    }
    public class ResultWrapper {
        public String objName { get; set; }
        public String text { get; set; }
        public String val { get; set; }
        public String address { get; set; }
    }
}