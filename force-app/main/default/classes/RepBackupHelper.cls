public with sharing class RepBackupHelper 
{
    @AuraEnabled
    public static List<User> getTeamMembers(string managerId)
    {
        List<User> team = [SELECT Id, Name, ManagerId FROM User WHERE Managerid = :managerId AND IsActive = true];
            
        return team;
        
    }

    @AuraEnabled
    public static List<Holiday> getHolidays(string year)
    {
        List<Holiday> holidays = [SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = THIS_YEAR];

        return holidays;
    }

    @AuraEnabled
    public static List<UTO__c> getUTO(string userId){
        List<UTO__c> uto = [SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate 
                            FROM UTO__c 
                            WHERE User__c = :userId 
                            ORDER BY Date__c ASC];

        return uto;
    }

    @AuraEnabled
    public static List<UTO__c> getFutureUTO(string userId){
        List<UTO__c> uto = [SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate 
                            FROM UTO__c 
                            WHERE User__c = :userId AND Date__c >= :Date.today()
                            ORDER BY Date__c ASC];

        return uto;
    }

    @AuraEnabled
    public static List<UTO__c> getBackupsToday(string userId)
    {
        List<UTO__c> uto = [SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate 
        FROM UTO__c 
        WHERE Backup__c = :userId AND Date__c = :Date.today()
        ORDER BY User__r.Name ASC];

        return uto;
    }

    @AuraEnabled
    public static List<UTO__c> getFutureBackups(string userId)
    {
        List<UTO__c> uto = [SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate 
        FROM UTO__c 
        WHERE Backup__c = :userId AND Date__c >= :Date.today()
        ORDER BY Date__c ASC];

        return uto;
    }

    @AuraEnabled
    public static List<UTO__c> getBackups(string userId)
    {
        List<UTO__c> uto = [SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate 
        FROM UTO__c 
        WHERE Backup__c = :userId 
        ORDER BY Date__c ASC];

        return uto;
    }
    
    @AuraEnabled
    public static List<UTO__c> getUnavailableByDateList(string userId, List<string> dates)
    {
        User current = [SELECT Id, ManagerId FROM User WHERE Id = :userId];
        List<User> team = [SELECT Id, Name FROM User WHERE IsActive = true AND Id != :current.Id];
        string teamIdStr = '';
        string dateStr = '';

        for(User u: team)
        {
            if (teamIdStr != '') teamIdStr += ',';
            teamIdStr += '\'' + u.Id + '\'';
        }
        teamIdStr = '(' + teamIdStr + ')';

        for(string d: dates)
        {
            if (dateStr != '') dateStr += ',';
            dateStr += getSoqlDate(d);
        }
        dateStr = '(' + dateStr + ')';

        string query = 'SELECT Id, Date__c, User__c, User__r.Name FROM UTO__c WHERE User__c IN ' + teamIdStr + ' AND Date__c IN ' + dateStr;
        
        List<UTO__c> teamUTO = Database.query(query);

        return teamUTO;
    }

    @AuraEnabled
    public static List<User> getAvailableByDateList(string userId, List<string> dates)
    {
        User current = [SELECT Id, ManagerId FROM User WHERE Id = :userId];
        List<User> team = [SELECT Id, Name FROM User WHERE IsActive = true AND Id != :current.Id];
        string teamIdStr = '';
        string dateStr = '';

        for(User u: team)
        {
            if (teamIdStr != '') teamIdStr += ',';
            teamIdStr += '\'' + u.Id + '\'';
        }
        teamIdStr = '(' + teamIdStr + ')';

        for(string d: dates)
        {
            if (dateStr != '') dateStr += ',';
            dateStr += d;
        }
        dateStr = '(' + dateStr + ')';

        string query = 'SELECT Id, User__c FROM UTO__c WHERE User__c IN ' + teamIdStr + ' AND Date__c IN ' + dateStr;
        
        List<UTO__c> teamUTO = Database.query(query);
        List<Id> teamIds = new List<Id>();
        for(UTO__c uto : teamUTO)
        {
            teamIds.add(uto.User__c);
        }

        List<User> availableMembers = new List<User>();
        for(User user : team)
        {
            if (!teamIds.contains(user.Id))
            {
                availableMembers.add(user);
            }
        }

        availableMembers.sort();

        return availableMembers;
    }

    @AuraEnabled
    public static List<UTO__c> getMarkedBackupsDateRange(string userId, string startDate, string endDate)
    {
        string start = getSoqlDate(startDate);
        string endD = null;
        string query = '';

        if (endDate != null && endDate != '')
        {
            endD = getSoqlDate(endDate);
            query = 'SELECT Id, User__c FROM UTO__c WHERE Backup__c = \'' + userId + '\' AND Date__c >= ' + start + ' AND Date__C <= ' + endD;
        }
        else
        {
            query = 'SELECT Id, User__c FROM UTO__c WHERE Backup__c = \'' + userId + '\' AND Date__c = ' + start;
        }

        List<UTO__c> backups = Database.query(query);

        return backups;
    }

    @AuraEnabled
    public static List<UTO__c> getMarkedBackupsDateList(string userId, List<string> dates)
    {
        string whereStr = '';
        for(string dateStr : dates)
        {
            if (whereStr != '') whereStr += ' OR ';
            whereStr += '( Backup__c = \'' + userId + '\' AND Date__c = ' + getSoqlDate(dateStr) + ')';
        }
        
        List<UTO__c> existingBackupUTO = Database.query('SELECT Id, User__r.Name, User__r.Email, Backup__r.Name, Date__c, CreatedDate FROM UTO__c '+
                                            'WHERE ' + whereStr);
        
        return existingBackupUTO;
    }


    @AuraEnabled
    public static List<User> getAvailable(string userId, string startDate, string endDate, string isTeam)
    {
        List<User> team = new List<User>();
        User current = [SELECT Id, ManagerId FROM User WHERE Id = :userId];

        if (isTeam == 'true')
        {
            team = [SELECT Id, Name FROM User WHERE (Managerid = :current.ManagerId or Id = :current.ManagerId) 
                                AND IsActive = true AND Id != :current.Id];
        }
        else
        {
            team = [SELECT Id, Name FROM User WHERE IsActive = true AND Id != :current.Id];
        }
        
        string teamIdStr = '';
        for(User u: team)
        {
            if (teamIdStr != '') teamIdStr += ',';
            teamIdStr += '\'' + u.Id + '\'';
        }
        teamIdStr = '(' + teamIdStr + ')';

        string start = getSoqlDate(startDate);
        string endD = null;
        string query = '';
        if (endDate != null && endDate != '')
        {
            endD = getSoqlDate(endDate);
            query = 'SELECT Id, User__c FROM UTO__c WHERE User__c IN ' + teamIdStr + ' AND Date__c >= ' + start + ' AND Date__C <= ' + endD;
        }
        else
        {
            query = 'SELECT Id, User__c FROM UTO__c WHERE User__c IN ' + teamIdStr + ' AND Date__c = ' + start;
        }
        
        List<UTO__c> teamUTO = Database.query(query);
        List<Id> teamIds = new List<Id>();
        for(UTO__c uto : teamUTO)
        {
            teamIds.add(uto.User__c);
        }

        List<User> availableMembers = new List<User>();
        for(User user : team)
        {
            if (!teamIds.contains(user.Id))
            {
                availableMembers.add(user);
            }
        }

        availableMembers.sort();

        return availableMembers;
    }

    @AuraEnabled
    public static List<string> verifyAvailabilityEdit(string userId, List<string> backups, List<string> dates)
    {
        string whereStr = '';
        Integer index = 0;
        for(string b : backups)
        {
            Date d = Date.parse(dates.get(index++));
            if (whereStr != '') whereStr += ' OR ';
            whereStr += '( User__c = \'' + b + '\' AND Date__c = ' + d.year() + '-' + 
                (d.month() < 10 ? '0' + string.valueOf(d.month()) : string.valueOf(d.month())) + '-' + 
                (d.day() < 10 ? '0' + string.valueOf(d.day()) : string.valueOf(d.day())) + ' ) '; 
        }
        
        List<UTO__c> existingBackupUTO = Database.query('SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate FROM UTO__c '+
                                            'WHERE ' + whereStr);

        List<string> messages = new List<string>();
        if (existingBackupUTO.size() > 0)
        {
            for(UTO__c uto : existingBackupUTO)
            {
                messages.add(uto.User__r.Name + ' is not available on ' + uto.Date__c.format());
            }
        }
        return messages;
    }

    @AuraEnabled
    public static List<string> verifyAvailability(string userId, string backupId, string startDate, string endDate)
    {
        List<UTO__c> existingBackupUTO = Database.query('SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate FROM UTO__c '+
                                            'WHERE User__c = \'' + backupId + 
                                            '\' AND Date__c >= ' + startDate +
                                            ' AND Date__c <= ' + endDate);

        List<UTO__c> existingUserUTO = Database.query('SELECT Id, User__r.Name, Backup__r.Name, Date__c, CreatedDate FROM UTO__c '+
                                            'WHERE User__c = \'' + userId + 
                                            '\' AND Date__c >= ' + startDate +
                                            ' AND Date__c <= ' + endDate);
        List<string> messages = new List<string>();
        if (existingBackupUTO.size() > 0)
        {
            for(UTO__c uto : existingBackupUTO)
            {
                messages.add(uto.User__r.Name + ' is not available on ' + uto.Date__c.format());
            }
        }
        if (existingUserUTO.size() > 0)
        {
            for(UTO__c uto : existingUserUTO)
            {
                messages.add('UTO already exists on ' + uto.Date__c.format());
            }
        }
        return messages;
    }

    @AuraEnabled
    public static string addUTO(string userId, List<string> backups, List<string> dates){
        try 
        {
            List<UTO__c> newUTOList = new List<UTO__c>();
            Integer index = 0;
            for(string backup : backups)
            {
                UTO__c newUTO = new UTO__c();
                newUTO.User__c = userId;
                newUTO.Backup__c = backup;
                newUTO.Date__c = Date.parse(dates.get(index));
                newUTOList.add(newUTO);
                index++;
            }

            insert newUTOList;

            emailMarkedBackups(userId, dates);

            return '';
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string editUTO(string userId, List<string> utoIds, List<string> backups, List<string> dates){
        try 
        {
            List<UTO__c> updatedUTOList = new List<UTO__c>();
            Integer index = 0;

            for(string backup : backups)
            {
                UTO__c updatedUTO = new UTO__c();
                updatedUTO.Id = utoIds.get(index);
                updatedUTO.User__c = userId;
                updatedUTO.Backup__c = backup;
                updatedUTO.Date__c =  Date.parse(dates.get(index));
                updatedUTOList.add(updatedUTO);
                index++;
            }

            update updatedUTOList;

            emailMarkedBackups(userId, dates);
            
            return '';
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void emailMarkedBackups(string userId, List<string> dates)
    {
        List<UTO__c> markedBackups = getMarkedBackupsDateList(userId, dates);

        string dateStr = dates.size() > 1 ? ' for multiple dates.' : ' for that date.';
        if (markedBackups.size() > 0)
        {
            List<string> uniqueUsers = new List<string>();
            for(UTO__c uto : markedBackups)
            {
                if (uniqueUsers.indexOf(uto.User__c) == -1)
                {
                    uniqueUsers.add(uto.User__c);
                    EmailSendHelper.sendEmail(uto.User__r.Email, 'bsibley@inprocorp.com', 
                        'Your backup is taking UTO on ' + uto.Date__c.format(), 'This is an automated message. <br><br>You selected ' + uto.Backup__r.Name + 
                        ' as your backup on ' + uto.Date__c.format() + ', and they have added UTO' + dateStr + 
                        '<br>Please choose another backup or reach out to them.<br><br>Thank you,<br><br><br>CRM System Account.');
                }
            }
        }
    }

    @AuraEnabled
    public static string deleteUTO(string utoId)
    {
        try 
        {
            UTO__c uto = [SELECT Id FROM UTO__c WHERE Id = :utoId];

            delete uto;

            return '';
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteUTOList(List<string> utoIdList)
    {
        try 
        {
            string utoListStr = '(';
            for(string utoId : utoIdList)
            {
                utoListStr += '\'' + utoId + '\',';
            }
            utoListStr =  utoListStr.substring(0, utoListStr.length()-1) + ')';
            //return utoListStr;
            
            List<UTO__c> uto = Database.query('SELECT Id FROM UTO__c WHERE Id IN ' + utoListStr);
            
            delete uto;

            return '';
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static string getSoqlDate(string dateStr)
    {
        if (dateStr.indexOf('-') != -1) return dateStr; //already formatted
        Date d = Date.parse(dateStr);
        
        return d.year() + '-' + 
            (d.month() < 10 ? '0' + string.valueOf(d.month()) : string.valueOf(d.month())) + '-' + 
            (d.day() < 10 ? '0' + string.valueOf(d.day()) : string.valueOf(d.day()));
    }
    
}