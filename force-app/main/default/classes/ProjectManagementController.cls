public with sharing class ProjectManagementController {
    @AuraEnabled(cacheable=true)
    public static List<Project_Management_Milestone__c> getProjects(Id projectId) {
        return [
            SELECT Id, Division__c, Milestone__c, Date_Created__c, Date_Completed__c
            FROM Project_Management_Milestone__c
            WHERE Project_Management__c = :projectId
        ];
    }
}