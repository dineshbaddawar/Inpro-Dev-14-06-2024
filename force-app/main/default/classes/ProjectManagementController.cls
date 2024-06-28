public with sharing class ProjectManagementController {
    @AuraEnabled(cacheable=true)
    public static List<Project_Management_Milestone__c> getMilestones(Id projectId) {
        return [
            SELECT Id, Division__c, Milestone__c, Date_Created__c, Date_Completed__c
            FROM Project_Management_Milestone__c
            WHERE Project_Management__c = :projectId
            ORDER BY Date_Created__c DESC
        ];
    }
 
    @AuraEnabled(cacheable=true)
    public static List<Project_Manager__c> getManagers(Id projectId) {
        return [
            SELECT Id, Division__c, User__r.Name, Div_Section__c
            FROM Project_Manager__c
            WHERE Project_Management__c = :projectId
        ];
    }

    @AuraEnabled
    public static void saveNewMilestone(Project_Management_Milestone__c milestone) {
        try {
            insert milestone;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveNewManager(Project_Manager__c manager) {
        try {
            insert manager;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getUsers(Id projectId)
    {
        return [
            SELECT Id, Name
            FROM User
            ORDER BY Name ASC
        ];
    }
}