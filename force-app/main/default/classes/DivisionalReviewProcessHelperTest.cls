@istest
public with sharing class DivisionalReviewProcessHelperTest {
    @isTest static void testDivisionalReviewProcess() {

       Divisional_Review__c createdReview = new Divisional_Review__c();
       createdReview.Name = 'TEST';
       insert createdReview;

       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User u = new User();
       u.IsActive = true;
       u.Username = 'elep@kshdfksfh.com';
       u.LastName = 'Lep';
       u.Email = 'elep@kshdfksfh.com';
       u.Alias = 'ELEP';
       u.TimeZoneSidKey = 'America/Chicago';
       u.LocaleSidKey = 'en_US';
       u.EmailEncodingKey = 'UTF-8';
       u.ProfileId = p.Id;
       u.LanguageLocaleKey = 'en_US';
       insert u;

       Division__c div = new Division__c();
        div.Name = 'Test Division';
        div.Abbreviation__c = 'Test';       
        //insert div;

       Divisional_Review__c review = DivisionalReviewProcessHelper.retrieveDivisionalReview(createdReview.Id);
       string divisionName = DivisionalReviewProcessHelper.retrieveDivisionId('IPC');
       string updateResult = DivisionalReviewProcessHelper.processDivisionalReview(createdReview.Id,'TEST','Approved',u.Id);
    }

    @isTest static void testDivisionalReviewLWCActions() {
        Construction_Project__c cp = new Construction_Project__c();
        cp.Name = 'TEST';
        insert cp;
        Construction_Project__c cProject = ReviewAllDivisionsHelper.retrieveConstructionProject(cp.Id);

        List<ReviewAllDivisionsHelper.DivisionalReviewRequest> reviewRequests = new List<ReviewAllDivisionsHelper.DivisionalReviewRequest>();
        ReviewAllDivisionsHelper.DivisionalReviewRequest request = new ReviewAllDivisionsHelper.DivisionalReviewRequest();
        request.DivisionName = 'IPC';
        request.ISR = 'eleptich@inprocorp.com';
        request.Notes = '';
        reviewRequests.add(request);
        string result = ReviewAllDivisionsHelper.sendDivisionReviewRequest(reviewRequests, cp.Id, 'Project Name');
     }
}