public with sharing class TrafficDocumentHelper {
    public TrafficDocumentHelper() {

    }

    @AuraEnabled()
    public static string getAccountContacts(string OrderId)
    {
        String Query = 'SELECT AccountId FROM Order WHERE Id = :OrderId LIMIT 1';
        sObject order = Database.query(Query);
        string AccountId = ((Order)order).AccountId;
        
        String Query2 = 'SELECT Id, FirstName, LastName, Email, Title FROM Contact WHERE AccountId = :AccountId ORDER BY LastName asc';
        List<sObject> results = Database.query(Query2);
        return JSON.serialize(results);
    }

    @AuraEnabled
    public static string sendContactEmail(string OrderId, string[] EmailTo)
    {
        try {
            
            String orderNumber = getOrderNumber(OrderId);
            String AccountNumber = '';
            String AccountName = '';
            
            //TODO: Need to still set these variables
            String consolidationNumber = ''; //OrderId tied with
            String PO = '';
            String ConsolidatedOrders = '';
            String ConsolidatedPOs = '';
            //Set account attributes
            Account Account = getOrderAccount(OrderId);
            AccountNumber = Account.AccountNumber;
            AccountName = Account.Name;

            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            sfdata.ConsolidatedOrderResult result = service.GetConsolidatedPONumbers(OrderId, 'dsj8U73_3nv3Dhba');

            consolidationNumber = result.Name;
            PO = result.PONumber;

            List<sfdata.ConsolidatedOrder> orders = result.ConsolidatedOrders.ConsolidatedOrder;

            for(sfdata.ConsolidatedOrder item : orders)
            {
                consolidationNumber = item.ConsolidationNumber;
                if (string.isEmpty(ConsolidatedOrders)) {
                    ConsolidatedOrders = item.ExternalId;
                }else{
                    ConsolidatedOrders += ', ' + item.ExternalId;
                }
            }
            //Create email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = EmailTo;
            message.bccaddresses = new string[] { 'bsibley@inprocorp.com' };
            message.optOutPolicy = 'FILTER';
            message.subject = 'Shipping Document Notification: ' + orderNumber;

            //Compose body message
            String outputMessage = '';
            if (consolidationNumber != 'consolidationNumber')
            {
                outputMessage += 'Inpro has just posted documentation online regarding <b>Consolidation Number: ' + consolidationNumber + '.</b><br/>';
            }
            else{
                outputMessage += 'Inpro has just posted documentation online regarding <b>Order Number: ' + orderNumber + '.</b><br/>';
            }

            //ACCOUNT NUMBER
            outputMessage += 'Customer Account: ' + AccountNumber;
            outputMessage += '<br/>';
            //ACCOUNT NAME
            outputMessage += 'Customer Name: ' + AccountName;
            outputMessage += '<br/>';
            //PO NUMBER
            if (!String.isEmpty(ConsolidationNumber))
            {
                outputMessage += 'Orders: ' + ConsolidatedOrders;
                outputMessage += '<br />';
                outputMessage += 'Purchase Orders: ' + ConsolidatedPOs;
            }
            else
            {
                outputMessage += 'Purchase Order:  ' + PO;
            }
                
            outputMessage += '<br />';
            outputMessage += buildDocumentText(OrderId);
            outputMessage += '<br/><br/>';
            outputMessage += 'The Order history section is currently undergoing enhancements to improve the user experience. Thank you for your patience while we work through our changes.';
            outputMessage += '<br/><br/>';
            outputMessage += 'Visit us at <a href=\'http://www.inprocorp.com\'>inprocorp.com</a> to view this new documentation.<br/>';
            outputMessage += '<br/>';
            outputMessage += 'Thanks,<br/>';
            outputMessage += '<br/>';
            outputMessage += 'Your friends at Inpro</span>';

            message.htmlbody = outputMessage;
            //return message.htmlbody; //TODO: Undo this once enabling emails in beta
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            if (results[0].success) {
                return 'The email was sent successfully.';
            } else {
                return 'The email failed to send: ' + results[0].errors[0].message;
            }
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string createTrafficDocument(string OrderId, string Type, string Name){
        try 
        {
            String Query = 'SELECT Id FROM Traffic_Document__c WHERE Order__c = :OrderId and Type__c = :Type and Name = :Name LIMIT 1';
            sObject[] doc = Database.query(Query);
            if (doc.size() > 0)
            {
                Traffic_Document__c trafficDoc = (Traffic_Document__c)doc[0];
                trafficDoc.Order__c = OrderId;
                trafficDoc.Type__c = Type;
                trafficDoc.OwnerId = UserInfo.getUserId();
                trafficDoc.Name = Name;
                
                upsert trafficDoc;
            }
            else{
                Traffic_Document__c trafficDoc = new Traffic_Document__c();
                trafficDoc.Order__c = OrderId;
                trafficDoc.Type__c = Type;
                trafficDoc.Name = Name;
                
                insert trafficDoc;
            }
            
            return 'true';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string deleteTrafficDocument(string OrderId, string Type, string Name){
        String Query = 'SELECT Id FROM Traffic_Document__c WHERE Order__c = :OrderId and Type__c = :Type and Name = :Name LIMIT 1';
        sObject[] doc = Database.query(Query);
        if (doc.size() > 0)
        {
            delete doc[0];
            return 'true';
        }
        else{
            return 'false';
        }
    }

    /*** HELPER METHODS ***/

    private static string getOrderNumber(string OrderId)
    {
        String Query = 'SELECT OrderNumber FROM Order WHERE Id = :OrderId LIMIT 1';
        sObject order = Database.query(Query);
        return ((Order)order).OrderNumber;
    }
    
    private static Account getOrderAccount(string OrderId)
    {
        //Get Account
        String Query = 'SELECT AccountId FROM Order WHERE Id = :OrderId LIMIT 1';
        sObject order = Database.query(Query);
        string AccountId = ((Order)order).AccountId;
        
        String Query2 = 'SELECT Id, Name, AccountNumber FROM Account WHERE Id = :AccountId LIMIT 1';
        Account Account = (Account)Database.query(Query2);
        return Account;
    }

    private static string buildDocumentText(string OrderId)
    {
        String Documents = '';
        //Retrieve traffic documents
        String Query = 'SELECT Id, Type__c, Name FROM Traffic_Document__c WHERE Order__c = :OrderId';
        sObject[] docs = Database.query(Query);

        Boolean hasCommercialInvoice = false;
        Boolean hasCertificateOfOrigin = false;
        Boolean hasTransportDocument = false;
        Boolean hasWTFYP = false;
        List<String> miscDocNames = new List<String>();

        for(sObject doc : docs)
        { //Check for document types and set flags
            Traffic_Document__c trafficDoc = (Traffic_Document__c)doc;
            if (trafficDoc.Type__c == 'Commercial Invoice')
            {
                hasCommercialInvoice = true;
            }
            else if (trafficDoc.Type__c == 'Certificate of Origin')
            {
                hasCertificateOfOrigin = true;
            }
            else if (trafficDoc.Type__c == 'Transport Document')
            {
                hasTransportDocument = true;
            }
            else if (trafficDoc.Type__c == 'WTFYP')
            {
                hasWTFYP = true;
            }
            else if (trafficDoc.Type__c == 'Miscellaneous')
            {
                miscDocNames.add(trafficDoc.Name);
            }
        }
        //Document text
        Documents = '<br/>Documents available: <br/><ul>';
        if (hasCommercialInvoice) Documents += '<li>Commercial Invoice</li>';
        if (hasWTFYP) Documents += '<li>Where To Find Your Product</li>';
        if (hasCertificateOfOrigin) Documents += '<li>Certificate of Origin</li>';
        if (hasTransportDocument) Documents += '<li>Transport Document</li>';
        for(String name : miscDocNames)
        {
            Documents += '<li>' + name + '</li>';
        }
        Documents += '</ul>';

        return Documents;
    }
}