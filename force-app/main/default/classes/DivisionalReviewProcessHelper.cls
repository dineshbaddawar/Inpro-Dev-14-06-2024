public with sharing class DivisionalReviewProcessHelper {
    
    @AuraEnabled()
    public static string processDivisionalReview(string divisionalReviewId, string notes, string status, string currentUserId)
    {
        try
        {
            String userQuery = 'SELECT Email FROM User WHERE Id = :currentUserId LIMIT 1';
            List<User> Users = Database.query(userQuery);
            
            if(Users != null && Users.size() > 0 && Users[0].Email != null)
            {
                Divisional_Review__c review = new Divisional_Review__c();
                review.Id = divisionalReviewId;
                review.Processing_Notes__c = notes;
                review.Processed_By__c = Users[0].Email;
                review.Status__c = status;
                update review;
    
                return 'Success!';
            }
            else {
                return 'Error: The current user cannot be found.';
            }        
        }
        catch(Exception ex)
        {
            return 'Error! ' + ex.getMessage();
        }
    }

    @AuraEnabled()
    public static Divisional_Review__c retrieveDivisionalReview(string divisionalReviewId)
    {
        String cpQuery = 'SELECT Id, Construction_Project__c, Division__c, Div_Section__c, Status__c FROM Divisional_Review__c WHERE Id = :divisionalReviewId LIMIT 1';
        List<Divisional_Review__c> divisionalReviews = Database.query(cpQuery);
        return divisionalReviews[0];
    }

    @AuraEnabled()
    public static string retrieveDivisionId(string divisionName)
    {
        String cpQuery = 'SELECT Id, Name FROM Division__c WHERE Name = :divisionName LIMIT 1';
        List<Division__c> divisionalReviews = Database.query(cpQuery);
        if(divisionalReviews != null && divisionalReviews.size() > 0)
            return divisionalReviews[0].Id;
        else
            return '';
    }
}