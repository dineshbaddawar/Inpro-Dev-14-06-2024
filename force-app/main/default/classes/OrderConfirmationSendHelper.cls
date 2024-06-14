public with sharing class OrderConfirmationSendHelper {
    @AuraEnabled
    public static Order GetOrderInformation(string recordId)
    {
        if(recordId != null && recordId != '')
        {
            return [SELECT NetSuite_Id__c, AccountId, NetSuite_TranId__c, Opportunity.Name, Quote.Name, Processed_By__r.Email, Opportunity_Owner__r.Email, Opportunity.Territory_Manager__r.Email, QuoteId 
            FROM Order WHERE Id = :recordId LIMIT 1];
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static string GeneratePrintPDF(string QuoteId, string FileName, string netSuiteInternalId, string orderId){
        string currentValue = '';
        try{
            PageReference reportPage = Page.OrderConfirmation; 
            reportPage.getParameters().put('internalId',netSuiteInternalId);       

            //Create pdf record 
            ContentVersion contentVersion_1 = new ContentVersion();
            contentVersion_1.Title = FileName;
            contentVersion_1.PathOnClient = FileName + '.pdf';
            contentVersion_1.VersionData = reportPage.getContentaspdf();
            contentVersion_1.origin = 'H';
            insert contentVersion_1;

            //Link to quote
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = QuoteId;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;

            UpdateOrderConfirmationSentFlag(orderId);

            //Return id for email
            return contentVersion_1.Id;
        }catch(Exception ex){
            return currentValue + '...' + ex.getMessage() + '\r\n' + ex.getStackTraceString();
        }        
    }

    @AuraEnabled
    public static string UpdateOrderConfirmationSentFlag(string orderId){
        try{
            // Order ord = new Order();
            // ord.Id = orderId;
            // ord.Order_Confirmation_Sent__c = true;
            // update ord;
            return '';
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static string RetrieveShippingNotificationEmail(string orderInternalId) 
    {        
        try {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            return service.RetrieveShippingNotificationEmail(orderInternalId, 'dsj8U73_3nv3Dhba');  
        } catch (Exception ex) {
            return 'error';
        }       
    }

    @AuraEnabled
    public static string RetrieveOrderEditLink(string orderInternalId) 
    {        
        try {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            return service.retrieveOrderEditLink(orderInternalId, 'dsj8U73_3nv3Dhba');  
        } catch (Exception ex) {
            return 'error';
        }       
    }
}