public with sharing class ReviewAllDivisionsHelper {
    
    @AuraEnabled()
    public static string sendDivisionReviewRequest(List<DivisionalReviewRequest> reviewRequests, string constructionProjectId, string constructionProjectName)
    {
        try{
            if(reviewRequests != null && reviewRequests.size() > 0)
            {   
                String projectId = SharePointDocumentManagementHelper.getSubRecordId('Construction_Project__c', constructionProjectId);                
                String documentLibraryUrl = SharePointDocumentManagementHelper.getOnlineLibraryUrl(constructionProjectId, projectId, true);
                for(DivisionalReviewRequest drr: reviewRequests)
                {
                    Divisional_Review__c request = new Divisional_Review__c();
                    String notesString = '';

                    if(drr.DivisionName != null && drr.DivisionName != '')
                        request.Name = drr.DivisionName;
                    else
                        request.Name = drr.DivSectionName;
                    
                    if(drr.DivisionName != null && drr.DivisionName != '')
                        request.Division__c = drr.DivisionName;
                    if(drr.DivSectionName != null && drr.DivSectionName != '')
                    {
                        request.Div_Section__c = drr.DivSectionName;
                        request.Division__c = 'Clickeze';
                    }

                    String toUserEmail = drr.ISR;
                    request.ISR__c = drr.ISR;

                    try {
                        List<UTO__c> utoList = [SELECT id, user__c, backup__c, Backup__r.Email, Date__c, createddate FROM uto__c WHERE user__r.Email = :drr.ISR and Date__c = :System.now().date()];
                        if (utoList.size() > 0)
                        {
                            UTO__c uto = utoList.get(0);
                            request.ISR__c = uto.Backup__c;
                            toUserEmail = uto.Backup__r.Email;
                        }
                    } catch (Exception ex) {
                        
                    }
                    request.Status__c = 'Pending';
                    request.Construction_Project__c = constructionProjectId;
                    if(drr.Notes != null && drr.Notes != '')
                    {
                        request.Submittal_Notes__c = drr.Notes;
                        notesString = drr.Notes;
                    }
                    
                    insert request;
    
                    String subject = '';
                    if(drr.DivSectionName != null && drr.DivSectionName != '')
                        subject = '[Clickeze - ' + drr.DivSectionName + '] Divisional Bid Review [' + constructionProjectName + ']';
                    else {
                        subject = '[' + drr.DivisionName + '] Divisional Bid Review [' + constructionProjectName + ']'; 
                    }
                    String body = 'Please indicate whether you would like your division to be included on ' +
                                  'this Construction Project by processing the \'Divisional Review\' (see link below). ' +
                                  'If you fail to respond within 5 business days of this bid date, you may ' +
                                  'miss the bid date. To view more ' + 
                                  'information about the Construction Project, please use the Construction Project link below.' +
                                  '<br/><br/>' +
                                  'Submittal Notes:<br/>' +
                                  notesString +
                                  '<br/><br/>' +
                                  'Construction Project Link:<br/>' +
                                  URL.getSalesforceBaseUrl().toExternalForm() + '/' + constructionProjectId +
                                  '<br/><br/>Divisional Review Link:<br/>' +
                                  URL.getSalesforceBaseUrl().toExternalForm() + '/' + request.Id +
                                  '<br/><br/>SharePoint Files Link:<br/>' +
                                  documentLibraryUrl;
    
                    EmailSendHelper.sendEmail(toUserEmail, '', subject, body);
                }
            }
            return 'Success!';
        }
        catch(Exception ex)
        {
            return 'Error! ' + ex.getMessage();
        }
    }

    @AuraEnabled()
    public static Construction_Project__c retrieveConstructionProject(string constructionProjectId)
    {
        String cpQuery = 'SELECT Name, Id, Territory__r.Ascend_ISR__r.Email, Territory__r.Clickeze_CCT_ISR__r.Email, Territory__r.Clickeze_WT_ISR__r.Email, Territory__r.Clickeze_ED12_ISR__r.Email, Territory__r.Clickeze_Webb_ISR__r.Email, Territory__r.Endurant_ISR__r.Email, Territory__r.JointMaster_ISR__r.Email, Territory__r.SignScape_ISR__r.Email, Territory__r.IPC_Team_Lead__r.Email FROM Construction_Project__c WHERE Id = :constructionProjectId LIMIT 1';
        List<Construction_Project__c> ConstructionProjects = Database.query(cpQuery);
        return ConstructionProjects[0];
    }

    public class DivisionalReviewRequest
    {
        @AuraEnabled
        public string DivisionName {get;set;}
        @AuraEnabled
        public string Notes {get;set;}
        @AuraEnabled
        public string ISR {get;set;}
        @AuraEnabled
        public string DivSectionName {get;set;}
    }
}