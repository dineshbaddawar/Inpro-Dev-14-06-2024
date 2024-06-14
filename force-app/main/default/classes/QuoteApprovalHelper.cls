public with sharing class QuoteApprovalHelper {
    
    @AuraEnabled
    public static string initiateApprovalProcess(string quoteId, string userId, string comments){
        try {
            string quoteDivision = '';
            Decimal minimumDivisionalCM = 0;
            Boolean requiresManagerApproval = false;
            Boolean requiresDirectorApproval = false;
            Boolean userSpecialPricingApprovalProcess = false;
            string quoteType = '';
            string quoteCreatorId = '';
            string submittedByName = '';
            string territoryName = '';
            Boolean isINTL = false;

            //Do not allow submit for approval if Experlogix is still saving back onto the quote.
            //This will throw an exception if no rows come back
            String Query = 'SELECT Id, Name FROM AsyncProcess__c WHERE ObjectId__c = :quoteId AND Status__c = ' +
                '\'In-Process\' and Name = \'Save Quote\' LIMIT 1';
            List<AsyncProcess__c> asyncList = Database.query(Query);
            
            if(asyncList.size() != 0)
                return 'Error: The quote is currently being saved. Please submit the quote for approval after ' + 
                    'the save is complete. You will be notified when it is finished. (Bell icon in the upper right corner)';


            Quote quote = [SELECT Division__c, Id, CreatedById, BidQuote__c, OpportunityId, Opportunity.OwnerId, 
                                  Opp_Owner_s_Manager__c, ShippingCountry, Territory__c 
                           FROM Quote 
                           WHERE Id = :quoteId];
            
            if(quote != null)
            {
                if(quote.Opp_Owner_s_Manager__c == null)
                    return 'Error: There is no \'opportunity owner\'s manager\' specified on the quote.';
                else 
                {
                    //Estimating audit needs to be complete so that the ENTITY_IS_LOCKED error isn't triggered.
                    Opportunity opp = [SELECT Id, Estimating_Divisional_Status__c 
                                       FROM Opportunity 
                                       WHERE Id = :quote.OpportunityId];

                    if (opp.Estimating_Divisional_Status__c == 'In Audit')
                    {
                        return 'Error: The opportunity is currently in estimating audit. Please contact the opportunity ' +
                            'approver before submitting this quote.';
                    }

                    quoteDivision = quote.Division__c;
                    quoteType = quote.BidQuote__c;
                    quoteCreatorId = quote.CreatedById;
                    if(quote.Territory__c != null)
                        territoryName = quote.Territory__c;
                    if(quote.ShippingCountry != null && quote.ShippingCountry != 'United States')
                        isINTL = true;
                }                
            }
            else {
                return 'Error: The quote could not be retrieved.';
            }

            User user = [SELECT Special_Pricing_Approval_Process__c, Id FROM User WHERE Id = :quoteCreatorId];
            userSpecialPricingApprovalProcess = user.Special_Pricing_Approval_Process__c;

            User submittedByUser = [SELECT Name, Id FROM User WHERE Id = :userId];
            submittedByName = submittedByUser.Name;
            
            //This may fail if division was not properly set in the quote flow
            try{
                Division__c division = [SELECT Minimum_Director_Discount_CM__c, Id FROM Division__c WHERE Division__c = :quoteDivision];
                minimumDivisionalCM = division.Minimum_Director_Discount_CM__c;
            }
            catch(Exception ex){
                return 'Error: The division could not be retrieved.';
            }

            //Alternate Helper Logic Extracted
            List<Alternate__c> alts = AlternateHelper.getAlternates(quoteId);

            Decimal quoteTotalCost = 0;
            Decimal quoteTotalMaterial = 0;
            Decimal quoteTotalListPrice = 0;
            for(Alternate__c alt : alts)
            {
                if(alt.Total_Cost__c != null)
                    quoteTotalCost += alt.Total_Cost__c;
                if(alt.Total_Material__c != null)
                    quoteTotalMaterial += alt.Total_Material__c;
                if(alt.Total_List_Price__c != null)
                    quoteTotalListPrice += alt.Total_List_Price__c;
            }

            //Determine if manager or director approval is required
            Decimal yield = 100;
            Decimal contributionMargin = 100;
            if(quoteTotalListPrice != null && quoteTotalListPrice != 0)
                yield = (quoteTotalMaterial / quoteTotalListPrice) * 100;
            if(quoteTotalMaterial != null && quoteTotalMaterial != 0)
                contributionMargin = (1 - (quoteTotalCost/quoteTotalMaterial)) * 100;
            if(yield < 89 && !isINTL)
                requiresManagerApproval = true;
            if (yield < 99 && contributionMargin < minimumDivisionalCM && !isINTL)
                requiresDirectorApproval = true;
            if (yield < 99 && isINTL)
            {
                if((territoryName.startsWith('IL') || territoryName.startsWith('IC')) && contributionMargin < 30)
                    requiresDirectorApproval = true;
                else if ((territoryName.startsWith('II') || territoryName.startsWith('IE') || territoryName.startsWith('IN')) && contributionMargin < 4.99)
                    requiresDirectorApproval = true;
                else if (contributionMargin < 30) {
                    requiresDirectorApproval = true;    
                }
            }

            //Division specific email logic
            if(quoteDivision == 'JointMaster' && requiresDirectorApproval && quoteType != 'Estimate Detail' && quoteType != 'Estimate Summary' && quoteType != 'Estimate Super Summary')
            {
                string jmNotificationEmailBody = 'Please be advised this quote contains pricing below the divisional threshold.  Approval is not required: <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + quoteId + '">Quote</a><br><br>';
                EmailSendHelper.sendEmail('rlindberg@inprocorp.com', 'eleptich@inprocorp.com', 'JointMaster Low CM Quote Notification', jmNotificationEmailBody);
            }
            if(quoteDivision == 'SignScape' || quoteDivision == 'JointMaster')
            {
                requiresManagerApproval = false;
                requiresDirectorApproval = false;
            }

            //Update quote record's alt values
            Quote quoteToUpdate = new Quote();
            quoteToUpdate.Id = quoteId;
            quoteToUpdate.Alternate_Total_Cost__c = quoteTotalCost;
            quoteToUpdate.Alternate_Total_Material__c = quoteTotalMaterial;

            //Update quote record's approval fields
            if(requiresManagerApproval && userSpecialPricingApprovalProcess && quoteType != 'Estimate Detail' && quoteType != 'Estimate Summary' && quoteType != 'Estimate Super Summary')
                quoteToUpdate.Requires_Discount_Manager_Approval__c = true;
            else {
                quoteToUpdate.Requires_Discount_Manager_Approval__c = false;
            }
            if(requiresDirectorApproval && quoteType != 'Estimate Detail' && quoteType != 'Estimate Summary' && quoteType != 'Estimate Super Summary')
            {
                quoteToUpdate.Requires_Discount_Manager_Approval__c = true;
                quoteToUpdate.Requires_Discount_Director_Approval__c = true;
            }
            else {
                quoteToUpdate.Requires_Discount_Director_Approval__c = false;
            }

            update quoteToUpdate;
        
            //Create approval record
            comments = comments != null ? 
                'Submitted By: ' + submittedByName + '      ' + comments : 
                'Submitted By: ' + submittedByName;

            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments(comments);
            approvalRequest.setObjectId(quoteId);
            approvalRequest.setSubmitterId(quoteCreatorId); 
            Approval.ProcessResult result = Approval.process(approvalRequest);

            if(result.isSuccess())
                return 'Success!';
            else {
                string errorMessage;
                Integer count = 1;
                List<Database.Error> errors = result.getErrors();
                for(Database.Error error : result.getErrors())
                {
                    errorMessage += ('Error ' + String.valueOf(count) + ': ' + errors[0].message + ' || ');
                }                
                return errorMessage;
            }                     
        } catch (Exception ex) {
            return ex.getMessage() + '...' + ex.getStackTraceString();
        }
    }
}