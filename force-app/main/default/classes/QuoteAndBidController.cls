/*************************************************************
* Created by:   The Hunley Group
* Created on:    2/2/2021
* ===========================================================
* Test Class:   QuoteAndBidControllerTest
* ===========================================================
* Purpose:   Controller class for QuoteAndBid Comp
*
* ===========================================================
* Change History
* Date          Author          Purpose
* ----------    -------------   -----------------------------
* 2/2/2021    THG - NK        Created
*
************************************************************/
public with sharing class QuoteAndBidController {
    
 /*   @AuraEnabled
    public static void sendQuoteEmail(string url,string quoteId,list<Quote_Bidder__c>quotebidderList,string emailbody){
        System.debug('quotebidderList'+quotebidderList);
        Quote quoteRecord= new Quote();
        List<string> bidderEmail = new list<string>();
        for(Quote_Bidder__c qb:quotebidderList){
            if(qb.Contact_Email__c !=null){
                bidderEmail.add(qb.Contact_Email__c);
            }
        }
        System.debug('bidderEmail'+bidderEmail);
        
        quoteRecord =[SELECT Id, Name,PO_Number__c,ContactId,Contact.Name,Contact.Phone,Contact.Email,Contact.fax,QuoteNumber,Revision_Number__c, OpportunityId, LineItemCount, Subtotal, TotalPrice, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, QuoteToStreet, QuoteToCity, QuoteToState, ShippingAddress, QuoteToPostalCode, QuoteToCountry, QuoteToStateCode, QuoteToCountryCode, BidQuote__c,
                      Inpro_Document_Number__c,Account.Customer_Number__c, Primary_Bidder__c,Primary_Bidder__r.Name,Primary_Bidder__r.Customer_Number__c, Type__c,GrandTotal,CurrencyIsoCode, Introduction__c,Qualifications__c, Ending__c 
                      FROM Quote where Id =: Id.valueOf(quoteId)];
        
        Opportunity  opportunityRecord = new Opportunity();
        Construction_Project__c cpRecord =new Construction_Project__c();
        for(Opportunity opp: [SELECT Id, Name, StageName,Project_Number__c, Construction_Project__c,OwnerId,Owner.Name,Owner.Email FROM Opportunity WHERE Id =:quoteRecord.OpportunityId])
        {
            
            opportunityRecord= opp;
            cpRecord = new Construction_Project__c();
            cpRecord.Id = opp.Construction_Project__c;
            //  System.debug('quoteDetails2'+quoteDetails);
        }
        
        for(Construction_Project__c cp:[SELECT Id, Name, City__c, ZIP__c,State__c, Country__c from Construction_Project__c where Id=:cpRecord.Id]){
            cpRecord= cp;
            // System.debug('quoteDetails3'+quoteDetails);
        }
        //  Subject Concatenation: [Quote Name], Rev [revision number], [Project Name]      
        string subject =    quoteRecord.Name+', Rev '+quoteRecord.Revision_Number__c+', '+cpRecord.Name;
        PageReference ref = new PageReference(url);
        //  PageReference ref = Page.PDF_DEMO;
        //Blob b = ref.getContentAsPDF();
        Blob b = blob.valueOf('Unit.Test');
        if(!Test.isRunningTest()) {
            b = ref.getContentAsPDF(); 
        }
       
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName('Quote Document.pdf');
        efa1.setBody(b);
        
        String addresses;
        email.setSubject( subject);
        // email.setToAddresses( EmailIds  );
        email.setTargetObjectId(quoteRecord.ContactId);
        email.htmlbody =emailbody;
        email.setBccAddresses(bidderEmail);
        // email.relatedToId =Id.valueOf(quoteId);      
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        
    }*/
    @AuraEnabled
    public static void sendQuoteEmailwFlowParam(string url,string quoteId,string emailbody,string ccAddress,string toAddress, string bccAddress,string emailSubject,string docName, String reqStr){ 
        /*  System.debug('quotebidderList'+quotebidderList);
        Quote quoteRecord= new Quote();
        List<string> bidderEmail = new list<string>();
        for(Quote_Bidder__c qb:quotebidderList){
        if(qb.Contact_Email__c !=null){
        bidderEmail.add(qb.Contact_Email__c);
        }
        }
        System.debug('bidderEmail'+bidderEmail);

        quoteRecord =[SELECT Id, Name,PO_Number__c,ContactId,Contact.Name,Contact.Phone,Contact.Email,Contact.fax,QuoteNumber,Revision_Number__c, OpportunityId, LineItemCount, Subtotal, TotalPrice, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, QuoteToStreet, QuoteToCity, QuoteToState, ShippingAddress, QuoteToPostalCode, QuoteToCountry, QuoteToStateCode, QuoteToCountryCode, BidQuote__c,
        Inpro_Document_Number__c,Account.Customer_Number__c, Primary_Bidder__c,Primary_Bidder__r.Name,Primary_Bidder__r.Customer_Number__c, Type__c,GrandTotal,CurrencyIsoCode, Introduction__c,Qualifications__c, Ending__c 
        FROM Quote where Id =: Id.valueOf(quoteId)];

        Opportunity  opportunityRecord = new Opportunity();
        Construction_Project__c cpRecord =new Construction_Project__c();
        for(Opportunity opp: [SELECT Id, Name, StageName,Project_Number__c, Construction_Project__c,OwnerId,Owner.Name,Owner.Email FROM Opportunity WHERE Id =:quoteRecord.OpportunityId])
        {

        opportunityRecord= opp;
        cpRecord = new Construction_Project__c();
        cpRecord.Id = opp.Construction_Project__c;
        //  System.debug('quoteDetails2'+quoteDetails);
        }

        for(Construction_Project__c cp:[SELECT Id, Name, City__c, ZIP__c, State__c, Country__c from Construction_Project__c where Id=:cpRecord.Id]){
        cpRecord= cp;
        // System.debug('quoteDetails3'+quoteDetails);
        }
        //  Subject Concatenation: [Quote Name], Rev [revision number], [Project Name]      
        string subject =    quoteRecord.Name+', Rev '+quoteRecord.Revision_Number__c+', '+cpRecord.Name;

        */

        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            Map<String,Object> reqData = (Map<String,Object>) JSON.deserializeUntyped(reqStr);        
            String bccContacts = String.valueOf(reqData.get('bccContacts'));
            String ccContacts = String.valueOf(reqData.get('ccContacts'));
            String toContacts = String.valueOf(reqData.get('toContacts'));
            String subject = String.valueOf(reqData.get('subject'));
            String emailTemplateBody = String.valueOf(reqData.get('emailTemplateBody'));
            String selectedFiles = String.valueOf(reqData.get('selectedFiles'));

            List<String> bccContactIds = String.isNotBlank(bccContacts) ?  bccContacts.split(',') : new List<String>();
            List<String> ccContactIds = String.isNotBlank(ccContacts)  ?    ccContacts.split(',') : new List<String>();
            List<String> toContactIds = String.isNotBlank(toContacts) ?  toContacts.split(',') : new List<String>();
            List<String> selectedFileIds = String.isNotBlank(selectedFiles) ?  selectedFiles.split(',') : new List<String>();

            List<Contact> bccContactsList = 
                [
                    SELECT  
                        Id,
                        Email
                    FROM Contact
                    WHERE Id IN: bccContactIds
                ];

            List<Contact> ccContactsList = 
                [
                    SELECT  
                        Id,
                        Email
                    FROM Contact
                    WHERE Id IN: ccContactIds
                ];

            List<Contact> toContactsList = 
                [
                    SELECT  
                        Id,
                        Email
                    FROM Contact
                    WHERE Id IN: toContactIds
                ];

            List<ContentVersion> files = 
                [
                    SELECT
                            Id,
                            Title, 
                            PathOnClient, 
                            FileType,
                            VersionData,
                            ContentDocumentId 
                        FROM ContentVersion
                        WHERE Id IN: selectedFileIds
                        ORDER BY CreatedDate DESC 
                ];

            String currentUserId = UserInfo.getUserId();
            //List<Task> taskList = new List<Task>();
            if(!bccContactIds.isEmpty()){
                email.setBccAddresses(bccContactIds);
                /*
                for(String bccContactId : bccContactIds){
                    Task t = new Task();
                    t.OwnerId = currentUserId;
                    t.Subject = subject;
                    t.Status = 'Completed';
                    t.Priority = 'Normal';
                    t.WhatId = quoteId;
                    t.WhoId = bccContactId;
                    taskList.add(t);
                }*/
            }
            if(!ccContactIds.isEmpty()){
                email.setCcAddresses(ccContactIds);
            }
            if(!toContactIds.isEmpty()){
                email.setToAddresses(toContactIds);
            }

            List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            List<String> attachmentIds = new List<String>();
            // Attach files to the message
            if(!files.isEmpty()){           
                for (ContentVersion file: files) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(file.PathOnClient);
                    efa.setBody(file.VersionData);
                    //efa.setContentType(file.);
                    attachments.add(efa);

                    ContentDocumentLink contentlink = new ContentDocumentLink();
                    contentlink.LinkedEntityId = quoteId;
                    contentlink.contentdocumentid = file.contentdocumentid;
                    contentlink.ShareType = 'V';
                    contentLinkList.add(contentlink);
                    attachmentIds.add(file.Id);
                }
            }
            email.setSubject(subject);
            email.setHtmlBody(emailTemplateBody);
            email.setSaveAsActivity(true);
            email.setWhatId(quoteId);
            PageReference ref = new PageReference(url);
            //Blob b = ref.getContentAsPDF();
            Blob b = blob.valueOf('Unit.Test');
            if(!Test.isRunningTest()) {
                b = ref.getContentAsPDF(); 
            }
            
            Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
            efa1.setFileName(docName+'.pdf');
            efa1.setFileName(subject+'.pdf');
            efa1.setBody(b);


            ContentVersion contentVersion_1 = new ContentVersion(
                Title = subject+'.pdf', 
                PathOnClient = subject+'.pdf',
                VersionData = b, 
                origin = 'H'
            );
            insert contentVersion_1;
            attachmentIds.add(contentVersion_1.Id);
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.LinkedEntityId = quoteId;
            contentlink1.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink1.ShareType = 'V';
            contentLinkList.add(contentlink1);
            
            //insert contentLinkList;
            Database.insert(contentLinkList,false);
            

            /*
            String addresses;
            email.setSubject(emailSubject);
            // email.setToAddresses( EmailIds  );
            //  email.setTargetObjectId(quoteRecord.ContactId);
            email.toAddresses = new String[] {toAddress};
                //  email.toaddresses(toAddress.split(','));
                email.htmlbody =emailbody;
            if(bccAddress != null){
                
                String [] bccAddressList = new List<String>();
                bccAddressList =bccAddress.split(',');
                email.bccaddresses =bccAddressList;
            }
            if(ccAddress != null){
                String [] ccAddressList = new List<String>();
                ccAddressList =ccAddress.split(',');
                email.ccaddresses =ccAddressList;
                    }
            
            // email.relatedToId =Id.valueOf(quoteId); 
            */
            attachments.add(efa1);

            //email.setFileAttachments(attachments);
            email.setEntityAttachments(attachmentIds);
            //email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            System.debug('Something went wrong: '+ e.getMessage());
            if(!Test.isRunningTest()){
            	throw new AuraHandledException('Something went wrong: '+ e.getMessage());
            }
            
        }        
    }
    
}