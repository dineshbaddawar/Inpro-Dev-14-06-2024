public with sharing class ConstructionProjectFileLinkHelper {

    @AuraEnabled
    public static Construction_Project__c getConstructionProject(String recordId){
        String Query = 'SELECT Internal_Project_Folder_c__c, Internal_Sales_Link__c, Name FROM Construction_Project__c WHERE Id = :recordId LIMIT 1';
        Construction_Project__c Alternates = Database.query(Query);
        return Alternates;    
    }
}