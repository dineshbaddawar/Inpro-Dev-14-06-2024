public with sharing class QualificationHelper {
    @AuraEnabled
    public static string refreshQualifications(string quoteId) {       
        try {    
            List<Quote> quoteList = [select Id, Qualifications__c, Division__c, 
                                    Qualifications_Flick__c, Pricing_Account_Numbers_Flick__c, Pricing_Account_Numbers__c
                                     from Quote where Id =: quoteId LIMIT 1];       
            if(quoteList != null && quoteList.size() > 0)
            {
                Quote q = quoteList[0];  
                // delete the related Qualifications for the Quotes in this trigger
                if(q.Qualifications__c != null && (q.Qualifications_Flick__c == null || q.Qualifications__c != q.Qualifications_Flick__c))
                {
                    List<Qualification__c> oldList = [select Id from Qualification__c where Quote__c =: q.Id LIMIT 9999];            
                    if(!oldList.IsEmpty()) {
                        delete oldList;
                    }
                    
                    // get a list of the qualification descriptions on the Quote if Qualifications__c is not null
                    if(q.Qualifications__c != null) {               
                        List<String> descriptions = q.Qualifications__c.split('\\|~\\|');  // must escape the pipes            
                        // create a qualification record for each of the descriptions
                        List<Qualification__c> qualsToInsert = new List<Qualification__c>();
                        for(String description : descriptions) 
                        {
                            if(description.length() > 0) {
                                
                                // get the sequence number from the front of the description delimitted by the '-'
                                string sSequence = description.left(description.indexOf('-'));
                                string sDescription = description.removeStart(sSequence+'-'); 
                                integer iSequence = Integer.valueOf(sSequence); 
                                string qualificationType = 'General';            
                                
                                List<CT_Option__c> EstimatingOptionList = [select Id from CT_Option__c where OptionID__c =: iSequence AND CatID__c =: 'EQualifications' AND Division__c =: q.Division__c LIMIT 1];
                                if(!EstimatingOptionList.IsEmpty()) {
                                    qualificationType = 'Estimating';
                                }

                                //Qualification__c ql = new Qualification__c(Quote__c = q.Id, Sequence__c = iSequence, Description__c = sDescription);
                                
                                Qualification__c ql = new Qualification__c(Quote__c = q.Id, Sequence__c = iSequence, Description__c = sDescription, Qualification_Type__c = qualificationType);
                                qualsToInsert.add(ql);
                                
                            }
                        }
                        if(qualsToInsert.size() > 0)
                            insert qualsToInsert;                   
                    }
                    q.Qualifications_Flick__c = q.Qualifications__c;
                    update q;                
                }          
            }
            return 'qualification load successful';
        } catch (Exception ex) {
                return 'qualification load failed: ' + ex.getMessage();
        }
    }
}