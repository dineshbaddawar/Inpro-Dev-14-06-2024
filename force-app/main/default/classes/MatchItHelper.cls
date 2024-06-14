public with sharing class MatchItHelper {

    public class MatchItDTO
    {
        public String RowId {get;set;}
        public String Name {get;set;}
        public String Address {get;set;}
        public String Zip {get;set;}
        public String City {get;set;}
        public String MembershipId {get;set;}
        public String ParentAccount {get;set;}
        public String StartDate {get;set;}

        public String MatchedGPOName {get;set;}
        public String MatchedMembershipId {get;set;}
        public String MatchedDivisions {get;set;}
        public String MatchedGPOStatus {get;set;}
        public string MatchedGPOStartDate {get;set;}
        public Integer MatchScore {get;set;}
        public String AccountNumber {get;set;}
        public String MatchedName {get;set;}
        public String MatchedAddressType {get;set;}
        public String MatchedAddress {get;set;}
        public String MatchedCity {get;set;}
        public String MatchedZip {get;set;}
        public String MatchedPhone {get;set;}
        public String MatchedParentAccount {get;set;}
        public String MatchedParentAccountId {get;set;}
        public String MatchedAccountId {get;set;}
    }

    @AuraEnabled
    public static Boolean isDebugUser(string userId)
    {
        User user = [SELECT Id, Name, UserRole.Name FROM User Where Id = :userId];

        if (user.UserRole != null && user.UserRole.Name == 'System Administrator')
        return true;
        else return false;
    }
    @AuraEnabled
    public static string getRows(string fileId)
    {
        ContentVersion file = [SELECT FileExtension, FileType, ContentUrl, VersionData, ContentSize, ContentDocument.Title
                                FROM ContentVersion
                                WHERE ContentDocument.Id = :FileId];

        string csvFile = blobToString(file.VersionData, 'ISO-8859-1');

        List<string> fileLines = csvFile.split('\n');

        return JSON.serialize(fileLines);
    }

    @AuraEnabled
    public static string saveResults(string fileId, string resultsJson)
    {
        ContentVersion file = [SELECT FileExtension, FileType, ContentUrl, VersionData, ContentSize, ContentDocument.Title
                               FROM ContentVersion
                               WHERE ContentDocument.Id = :fileId];

        Account_Match_Result__c result = new Account_Match_Result__c();
        result.OwnerId = UserInfo.getUserId();
        result.Upload_Name__c = file.ContentDocument.Title +  ' ' + System.now().format('MM/dd/yyyy h:mm a');
        insert result;

        Blob txtBlob = Blob.valueOf(resultsJson); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name = fileId + '_resultsJson.txt';  
        attach.Body = txtBlob;
        attach.ContentType= 'text/plain'; //Signal what the file's MIME type is
        attach.ParentID = result.Id;
        insert attach;

        result.File_Id__c = attach.Id;
        update result;

        return result.File_Id__c;
    }

    @AuraEnabled
    public static List<Account_Match_Result__c> getPreviousResults()
    {
        return [SELECT Id, Upload_Name__c, File_Id__c, CreatedDate FROM Account_Match_Result__c WHERE OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
    }

    @AuraEnabled
    public static void renameResultName(string fileId, string name){
        Account_Match_Result__c previousRecord = [SELECT Id, Upload_Name__c, File_Id__c, CreatedDate FROM Account_Match_Result__c WHERE File_Id__c = :fileId LIMIT 1];
        Account_Match_Result__c record = new Account_Match_Result__c();
        record.Id = previousRecord.Id;
        record.Upload_Name__c = name;
        update record;
    }

    @AuraEnabled
    public static string getResultsJson(string fileId){
        Account_Match_Result__c result = [SELECT Id, Upload_Name__c, File_Id__c FROM Account_Match_Result__c WHERE File_Id__c = :fileId];

        Attachment file = [SELECT Id,Body,ContentType FROM Attachment  WHERE Id = :fileId];
        
        String resultsJson = file.Body.toString();

        return resultsJson;
    }

    @AuraEnabled
    public static string updateResultsJson(string resultId, string resultsJson)
    {
        Account_Match_Result__c result = [SELECT Id, Upload_Name__c, File_Id__c FROM Account_Match_Result__c WHERE File_Id__c = :resultId];

        Attachment file = [SELECT Id,Body,ContentType FROM Attachment  WHERE Id = :result.File_Id__c];
        
        delete file;

        Blob txtBlob = Blob.valueOf(resultsJson); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name = resultId + '_resultsJson.txt';  
        attach.Body = txtBlob;
        attach.ContentType= 'text/plain'; //Signal what the file's MIME type is
        attach.ParentID = result.Id;
        insert attach;

        result.File_Id__c = attach.Id;
        update result;

        return attach.Id;
    }

    @AuraEnabled
    public static string deleteAllAccountMatchResults(){
        List<Account_Match_Result__c> results = [SELECT Id, Upload_Name__c, File_Id__c FROM Account_Match_Result__c WHERE OwnerId = :UserInfo.getUserId()];

        for(Account_Match_Result__c result : results)
        {
            Attachment file = [SELECT Id,Body,ContentType FROM Attachment  WHERE Id = :result.File_Id__c];
        
            delete file;
        }
        
        delete results;

        return '';
    }

    @AuraEnabled
    public static string deleteAccountMatchResult(string fileId){
        Account_Match_Result__c result = [SELECT Id, Upload_Name__c, File_Id__c FROM Account_Match_Result__c WHERE File_Id__c = :fileId];

        Attachment file = [SELECT Id,Body,ContentType FROM Attachment  WHERE Id = :fileId];
        
        delete file;
        delete result;

        return '';
    }

    public static Map<String,List<MatchItDTO>> buildResults(Map<String, List<MatchItDTO>> matchMap, List<Account> accounts, List<GPO_Association__c> gpos,
        string index, string name, string address, string zipCode, string city, string membershipId, string parentAccount, string startDate)
    {
        Map<String, String> abbrMap = GetAbbreviationMap();

        for(Account acc : accounts)
        {
            
            MatchItDTO match = new MatchItDTO();
            match.RowId = index;
            match.Name = name;
            match.Address = address;
            if (match.Address == null) match.Address = '';
            match.Zip = zipCode;
            match.City = city;
            match.MembershipId = membershipId;
            match.ParentAccount = parentAccount;
            match.MatchedName = acc.Name;
            match.StartDate = startDate;
            String trimmedZip = zipCode.split('-')[0];
            String leadingZip = trimmedZip;
            while (leadingZip.length() < 5) //for Puerto Rico or 0#### zips
            {
                leadingZip = '0' + leadingZip;
            }
            String shippingStreet = acc.ShippingStreet;
            if (shippingStreet != null) shippingStreet = shippingStreet.replace('.', '');
            else shippingStreet = '';

            String compareMatchAddress = matchAbbreviations(abbrMap, match.Address.replace('.', ''), shippingStreet);

            Integer ss1 = shippingStreet == '' && match.Address != '' ? 100 : GetScore(compareMatchAddress, shippingStreet, 10, 25, true);
            Integer ss2 = GetScore(trimmedZip, acc.ShippingPostalCode, 25, 500, false);

            match.MatchedAddressType = 'Shipping';
            match.MatchedAddress = acc.ShippingStreet;
            match.MatchedZip = acc.ShippingPostalCode;
            match.MatchedCity = acc.ShippingCity;
            match.MatchedPhone = acc.Phone;
            match.MatchedAccountId = acc.Id;
            match.AccountNumber = acc.Customer_Number__c;
            match.MatchedParentAccount = acc.Parent != null ? acc.Parent.Name : '';
            match.MatchedParentAccountId = acc.Parent != null ? String.valueOf(acc.Parent.Id) : '';

            Integer nameScore = GetScore(name, acc.Name, 0, 5, false);
            Integer addressScore = ss1 + ss2;

            match.MatchScore = nameScore + addressScore;
            match.MatchedDivisions = '';
            match.MatchedGPOName = '';

            Boolean hasInactive = false;
            Boolean hasActive = false;

            for(GPO_Association__c gpo : gpos )
            {
                if (gpo.Account__c == acc.Id)
                {
                    if (!gpo.Inactive__c)
                    {
                        String gpoName = !gpo.Inactive__c ? gpo.Group_Purchasing_Organization__r.Name : gpo.Group_Purchasing_Organization__r.Name + ' (I)';
                        match.MatchedGPOName += match.MatchedGPOName.indexOf(gpoName) == -1 ? 
                            match.MatchedGPOName == '' ? gpoName : ', ' + gpoName : '';
    
                        match.MatchedMembershipId =  gpo.Membership_ID__c;
                        match.MatchedDivisions += gpo.Division__c != null && gpo.Division__c != 'null' && match.MatchedDivisions.indexOf(gpo.Division__c) == -1 ?
                                match.MatchedDivisions == '' ? gpo.Division__c : ', ' + gpo.Division__c : '';
                    }
                    

                    if (gpo.Inactive__c) hasInactive = true;
                    else hasActive = true;

                    match.MatchedGPOStatus = (hasInactive && hasActive) ? 'Some Inactive' : hasInactive ? 'Inactive' : hasActive ? 'Active' : '';
                }
            }
            match.MatchedDivisions = match.MatchedDivisions.replaceAll(';', '; ');

            if (matchMap.keySet().contains(match.Name))
            {
                matchMap.get(match.Name).add(match);
            } 
            else 
            {
                matchMap.put(match.Name, new List<MatchItDTO>{match});
            }
        }

        return matchMap;
    }

    private static string cleanString(string str)
    {
        return str.replaceAll('[^a-zA-Z0-9\\s+]', ' ').replace('\r','').trim();
    }

    private static string matchAbbreviations(Map<String, String> abbrMap, string input, string source)
    {
        input = input.toLowerCase();
        source = source.toLowerCase();

        for(String key : abbrMap.keySet())
        {
            string longStr = key.toLowerCase();
            string shortStr = abbrMap.get(key).toLowerCase();
            if (input.indexOf(longStr) != -1 && source.indexOf(shortStr) != -1)
            {
                return input.replace(longStr, shortStr);
            }
            else if (input.indexOf(shortStr) != -1 && source.indexOf(longStr) != -1)
            {
                return input.replace(shortStr,longStr);
            }
        }
        return input;
    }

    @AuraEnabled
    public static string getResult(string row, string index, 
        string nameIndex, string addressIndex, string zipIndex, string cityIndex, 
        string membershipIndex, string parentAccountIndex, string startDateIndex, string accountDebug)
    {
        MatchItDTO result = new MatchItDTO();

        Map<String, List<MatchItDTO>> matchMap = new Map<String, List<MatchItDTO>>();

        String[] inputValues = row.split(',');
        
        String name = '';

        /*if (inputValues.size() > 5) //commas present in name
        {
            membershipIndex = String.valueOf(inputValues.size()-1);
            cityIndex = String.valueOf(inputValues.size()-2);
            zipIndex = String.valueOf(inputValues.size()-3);
            addressIndex = String.valueOf(inputValues.size()-4); //assuming commas not also present in address
            for(Integer i = 0; i < inputValues.size()-4; i++)
            {
                name += name == '' ? inputValues[i] : ', ' + inputValues[i];
            }
        }*/

        if (name == '')  name = nameIndex != '-1' ? cleanString(inputValues[Integer.valueOf(nameIndex)]) : '';
        else name = cleanString(name);

        Boolean addressFound = addressIndex != '-1';
        Boolean zipFound = zipIndex != '-1';
        Boolean cityFound = cityIndex != '-1';
        Boolean parentFound = parentAccountIndex != '-1';
        Boolean membershipFound = membershipIndex != '-1';
        Boolean startDateFound = startDateIndex != '-1';

        String address = addressIndex != '-1' ? cleanString(inputValues[Integer.valueOf(addressIndex)]) : '';
        String zipCode = zipFound ? cleanString(inputValues[Integer.valueOf(zipIndex)]) : '';
        String city = cityFound ? cleanString(inputValues[Integer.valueOf(cityIndex)]) : '';
        String parentAccount = parentFound ? cleanString(inputValues[Integer.valueOf(parentAccountIndex)]) : '';
        String membershipId = membershipFound ? 
            inputValues[Integer.valueOf(membershipIndex)] != null ?  cleanString(inputValues[Integer.valueOf(membershipIndex)]) : ''
            : '';
        String startDate = startDateFound ? inputValues[Integer.valueOf(startDateIndex)]: '';
        String query1 = 'SELECT Id, Name, Customer_Number__c, Territory_Lookup__c, Customer_Type__c, Phone,' +
        'ShippingStreet, ShippingPostalCode, ShippingCity, Parent.Name, Parent.Id FROM Account WHERE Inactive__c = false ';
        
        String fieldquery = '';
        if (addressFound || zipFound ) //|| cityFound
        {
            Boolean prevAdded = false;
            fieldquery += 'AND (';
            if (addressFound)
            {
                fieldquery += ' ShippingStreet like \'%' + address + '%\' ';
                prevAdded = true;
            }
            /*if (cityFound)
            {
                if (prevAdded) fieldquery += ' OR ';
                fieldquery += ' (ShippingCity != \'\' AND ShippingCity = \'' + city + '\') ';
                prevAdded = true;
            }*/
            if (zipFound)
            {
                if (prevAdded) fieldquery += ' OR ';
                fieldquery += ' ShippingPostalCode = \'' + zipCode.split('-')[0] + '\' ';
            }
            
            fieldQuery += ')';
        }

        query1 += fieldquery + ' LIMIT 50';

        List<Account> accounts = new List<Account>();

        accounts = Database.query(query1);

        
        String accountIds = '';

        for(Account acc: accounts)
        {
            accountIds += accountIds == '' ? '\'' + acc.Id + '\'' : ',\'' +acc.Id + '\'';
        }

        List<GPO_Association__c> gpos = new List<GPO_Association__c>();

        system.debug('membershipFound ? ' + membershipFound);
        if (membershipFound && membershipId != '')
        {
            String gpoQuery =   'SELECT Id, Group_Purchasing_Organization__r.Name, Membership_ID__c, Account__c, Account__r.Name, ' +
                        'Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingPostalCode, Account__r.Customer_Number__c, ' +
                        'Account__r.Phone, Inactive__c, Division__c ' + 
                    'FROM GPO_Association__c ' +
                    'WHERE Membership_ID__c = \'' + membershipId + '\'';

            gpos = Database.query(gpoQuery);

            system.debug('gpo size ? ' + gpos.size());
            if (gpos.size() > 0)
            {
                GPO_Association__c gpo = gpos.get(0);
                accounts = [SELECT Id, Name, Customer_Number__c, Territory_Lookup__c, Customer_Type__c, Phone,
                                               ShippingStreet, ShippingPostalCode, ShippingCity, Parent.Name, Parent.Id 
                                        FROM Account WHERE Id = :gpo.Account__c]; 
            }
            else
            {
                if (accountIds != '')
                {
                    gpoQuery += ' OR Account__c IN (' + accountIds + ')';

                    gpos = Database.query(gpoQuery);
                }
            }
        }

        if (accountDebug == 'true') return JSON.serialize(accounts);


        if (accounts.size() > 0)
        {
            matchMap = buildResults(matchMap, accounts, gpos, index, name, address, zipCode, city, membershipId, parentAccount, startDate);
        }
        else
        {
            MatchItDTO match = new MatchItDTO();
            match.RowId = index;
            match.Name = name;
            match.Address = address;
            match.Zip = zipCode;
            match.City = city;
            match.MembershipId = membershipId;
            match.ParentAccount = parentAccount;
            match.StartDate = startDate;
            match.MatchScore = 100;
            match.MatchedName = '';
            match.MatchedAddress = '';
            match.MatchedCity = '';
            match.MatchedZip = '';
            match.MatchedPhone = '';
            match.MatchedAccountId = '';
            match.AccountNumber = '';
            match.MatchedDivisions = '';
            match.MatchedGPOName = '';
            
            Boolean hasInactive = false;
            Boolean hasActive = false;
                
            for(GPO_Association__c gpo : gpos )
            {
                if (gpo.Membership_ID__c == membershipId)
                {
                    accounts =  Database.query('SELECT Id, Name, Customer_Number__c, Territory_Lookup__c, Customer_Type__c, ' +
                                    'ShippingStreet, ShippingPostalCode, Phone, Parent.Name, Parent.Id FROM Account ' + 
                                    'WHERE Inactive__c = false AND Id = \'' + gpo.Account__c + '\' LIMIT 20');

                    matchMap = buildResults(matchMap, accounts, gpos, index, name, address, zipCode, city, membershipId, parentAccount, startDate);
                    
                }
            }

            matchMap.put(match.Name, new List<MatchItDTO>{match});
        }

        for(String key : matchMap.keySet())
        {
            Boolean firstMatch = false;
            List<MatchItDTO> matches = matchMap.get(key);
            
            Integer bestScore = 100;
            MatchItDTO bestMatch = matches.get(0);

            for(MatchItDTO match: matches)
            {
                if (!firstMatch || match.MatchScore < bestScore)
                {
                    firstMatch = true;
                    bestScore = match.MatchScore;
                    bestMatch = match;
                }
            }
            
            bestMatch.MatchScore = 100 - bestMatch.MatchScore;
            if (bestMatch.MatchScore > 100) bestMatch.MatchScore = 100;
            if (bestMatch.MatchScore < 0) bestMatch.MatchScore = 0;
            
            //If not exact match, this can't be marked a 100% match
            if (bestMatch.MatchScore == 100 && (bestMatch.Address.replace('.', '') != bestMatch.MatchedAddress.replace('.', '') || bestMatch.Zip != bestMatch.MatchedZip))
            {
                bestMatch.MatchScore -= 1;
            }

            result = bestMatch;
        }

        //Check if best match has a GPO and pull it through
        if ((result.MatchedMembershipId == null || result.MatchedMembershipId == '') && result.MatchedAccountId != '')
        {
            String gpoQuery2 =   'SELECT Id, Group_Purchasing_Organization__r.Name, Membership_ID__c, Account__c, Account__r.Name, ' +
                                        'Account__r.ShippingStreet, Account__r.ShippingPostalCode, Account__r.Customer_Number__c, ' +
                                        'Account__r.Phone, Inactive__c, Division__c ' + 
                                    'FROM GPO_Association__c ' +
                                    'WHERE Account__c = \'' + result.MatchedAccountId + '\' ORDER BY CreatedDate DESC  LIMIT 20';

            List<GPO_Association__c> gpos2 = new List<GPO_Association__c>();
            gpos2 = Database.query(gpoQuery2);

            Boolean hasInactive = false;
            Boolean hasActive = false;
            for(GPO_Association__c gpo : gpos2 )
            {
                if (!gpo.Inactive__c)
                {
                    String gpoName = !gpo.Inactive__c ? gpo.Group_Purchasing_Organization__r.Name : gpo.Group_Purchasing_Organization__r.Name + ' (I)';
                    result.MatchedGPOName += result.MatchedGPOName.indexOf(gpoName) == -1 ? 
                    result.MatchedGPOName == '' ? gpoName : '; ' + gpoName : '';
    
                    result.MatchedMembershipId =  gpo.Membership_ID__c;
                    result.MatchedDivisions += gpo.Division__c != null && gpo.Division__c != 'null' && result.MatchedDivisions.indexOf(gpo.Division__c) == -1 ?
                    result.MatchedDivisions == '' ? gpo.Division__c : '; ' + gpo.Division__c : '';
                }
               
                if (gpo.Inactive__c) hasInactive = true;
                else hasActive = true;

                result.MatchedGPOStatus = (hasInactive && hasActive) ? 'Some Inactive' : hasInactive ? 'Inactive' : hasActive ? 'Active' : '';
            }
        }

        return JSON.serialize(result);
    }

    private static Integer GetScore(String s, String t, Integer goodWeight, Integer badWeight, Boolean frontHeavy)
    {
        Integer score = 0;
        Integer extra = 0;

        if (s == null || s == '')
        {
            if (t == null || t == '')
                return 0;
            return t.trim().length();
        }

        if (t == null || t == '' )
        {
            return s.trim().length();
        }
        s = s.trim().toLowerCase();
        t = t.trim().toLowerCase();

        if (s.length() > t.length())
        {
            for(Integer i = 0; i < s.length(); i++)
            {
                if (i < t.length() && s.charAt(i) == t.charAt(i))
                {
                    score -= 1;
                }
                else
                {
                    score += 1;
                }
            }
        }
        else if (t.length() > s.length())
        {
            for(Integer i = 0; i < t.length(); i++)
            {
                if (i < s.length() && t.charAt(i) == s.charAt(i))
                {
                    score -= 1;
                }
                else
                {
                    score += 1;
                }
            }
        }
        else
        {
            for(Integer i = 0; i < s.length(); i++)
            {
                if (s.charAt(i) == t.charAt(i))
                {
                    score -= 1;
                }
                else
                {
                    score += 1;
                }
            }
        }
        
        String[] arrA = s.Split(' ');
        String[] arrB = t.Split(' ');
        Integer index = 0;
        for(String a : arrA)
        {
            if (!arrB.Contains(a)) 
            {
                if (frontHeavy && index == 0) extra += badWeight * 3;
                else extra += badWeight;
            }
            else extra -= goodWeight;

            index++;
        }
        return score + extra;
    }

    //Copied from https://blog.webnersolutions.com/salesforce-read-csv-file-insert-objects-and-get-results-back-in-apex-visualforce-page/
    public static String blobToString(Blob input, String inCharset){ 
        String hex = EncodingUtil.convertToHex(input); 
        System.assertEquals(0, hex.length() & 1); 
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
        bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

    private static Map<String,String> GetAbbreviationMap()
    {
        Map<String,String> abbrMap = new Map<String,String>();
        abbrMap.put('Avenue','Ave');
        abbrMap.put('Boulevard','Blvd');
        abbrMap.put('Center','Ctr');
        abbrMap.put('Circle','Cir');
        abbrMap.put('Court','Ct');
        abbrMap.put('Drive','Dr');
        abbrMap.put('Expressway','Expy');
        abbrMap.put('Heights','Hts');
        abbrMap.put('Highway','Hwy');
        abbrMap.put('Island','Is');
        abbrMap.put('Junction','Jct');
        abbrMap.put('Lake','Lk');
        abbrMap.put('Lane','Ln');
        abbrMap.put('Mountain','Mtn');
        abbrMap.put('Parkway','Pkwy');
        abbrMap.put('Place','Pl');
        abbrMap.put('Plaza','Plz');
        abbrMap.put('Ridge','Rdg');
        abbrMap.put('Square','Sq');
        abbrMap.put('Street','St');
        abbrMap.put('Station','Sta');
        abbrMap.put('Terrace','Ter');
        abbrMap.put('Trail','Trail');
        abbrMap.put('Turnpike','Tpke');
        abbrMap.put('Valley','Vly');
        abbrMap.put('Way','Way');
        abbrMap.put('North','N');
        abbrMap.put('South','S');
        abbrMap.put('East','E');
        abbrMap.put('West','W');
        abbrMap.put('Northeast','NE');
        abbrMap.put('Northwest','NW');
        abbrMap.put('Southeast','SE');
        abbrMap.put('Southwest','SW');

        return abbrMap;
    }
}