public with sharing class PrintQuoteHelper 
{
    @AuraEnabled
    public static string CreatePrintQuote(string jsonParams)
    {
        string quoteId; string formType; Boolean taxable; string metric; 
        string print; Decimal totalwTax; Decimal total; string alternates;
        string contactName;string contactEmail;string contactPhone;string fax;
        string toAddress;string ccAddress;string bccAddress;string emailSubject;
        Boolean hideQtys;string shipToAddress;string paymentTerms;string shippingTerms;
        string jobReference;string ourReference;string creditType;string material;
        Boolean submittalVersion;Boolean internal;string shipToName;string shipToStreet;
        string shipToCity;string shipToState;string shipToPostalCode;string shipToCountry;
        string poNumber;Boolean isCAD;Boolean isPrintingGrandTotal = false;
        Boolean isPrintingSummary;Boolean isPrintDetails;

        JSONParser parser = JSON.createParser(jsonParams);
        while(parser.nextToken() != null)
        {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if (parser.getText() == 'quoteId') { parser.nextToken();  quoteId = parser.getText(); }
                else if (parser.getText() == 'formType') { parser.nextToken(); formType = parser.getText(); }
                else if (parser.getText() == 'taxable') { parser.nextToken(); taxable = parser.getText() == 'true';}
                else if (parser.getText() == 'metric') { parser.nextToken();  metric = parser.getText(); }
                else if (parser.getText() == 'print') { parser.nextToken(); print = parser.getText(); }
                else if (parser.getText() == 'totalwTax') { parser.nextToken();  totalwTax = Decimal.valueOf(parser.getText().trim());}
                else if (parser.getText() == 'total') { parser.nextToken(); total = Decimal.valueOf(parser.getText().trim());}
                else if (parser.getText() == 'alternates') { parser.nextToken(); alternates = parser.getText(); }
                else if (parser.getText() == 'contactName') { parser.nextToken(); contactName = parser.getText(); }
                else if (parser.getText() == 'contactEmail') { parser.nextToken(); contactEmail = parser.getText(); }
                else if (parser.getText() == 'contactPhone') { parser.nextToken(); contactPhone = parser.getText(); }
                else if (parser.getText() == 'fax') { parser.nextToken(); fax = parser.getText(); }
                else if (parser.getText() == 'toAddress') { parser.nextToken(); toAddress = parser.getText(); }
                else if (parser.getText() == 'ccAddress') { parser.nextToken(); ccAddress = parser.getText(); }
                else if (parser.getText() == 'bccAddress') { parser.nextToken(); bccAddress = parser.getText(); }
                else if (parser.getText() == 'emailSubject') { parser.nextToken(); emailSubject = parser.getText(); }
                else if (parser.getText() == 'hideQtys') { parser.nextToken(); hideQtys = parser.getText() == 'true'; }
                else if (parser.getText() == 'shipToAddress') { parser.nextToken(); shipToAddress = parser.getText(); }
                else if (parser.getText() == 'paymentTerms') { parser.nextToken(); paymentTerms = parser.getText(); }
                else if (parser.getText() == 'shippingTerms') { parser.nextToken(); shippingTerms = parser.getText(); }
                else if (parser.getText() == 'jobReference') { parser.nextToken(); jobReference = parser.getText(); }
                else if (parser.getText() == 'ourReference') { parser.nextToken(); ourReference = parser.getText(); }
                else if (parser.getText() == 'creditType') { parser.nextToken(); creditType = parser.getText(); }
                else if (parser.getText() == 'material') { parser.nextToken(); material = parser.getText(); }
                else if (parser.getText() == 'submittalVersion') { parser.nextToken(); submittalVersion = parser.getText() == 'true'; }
                else if (parser.getText() == 'internal') { parser.nextToken(); internal = parser.getText() == 'true';}
                else if (parser.getText() == 'isPrintingGrandTotal') { parser.nextToken(); isPrintingGrandTotal = (parser.getText() == 'true');}
                else if (parser.getText() == 'isPrintSummary') { parser.nextToken(); isPrintingSummary = (parser.getText() == 'true');}
                else if (parser.getText() == 'isPrintDetails') { parser.nextToken(); isPrintDetails = (parser.getText() == 'true');}
                else if (parser.getText() == 'shipToName') { parser.nextToken(); shipToName = parser.getText(); }
                else if (parser.getText() == 'shipToStreet') { parser.nextToken(); shipToStreet = parser.getText(); }
                else if (parser.getText() == 'shipToCity') { parser.nextToken(); shipToCity = parser.getText(); }
                else if (parser.getText() == 'shipToState') { parser.nextToken(); shipToState = parser.getText(); }
                else if (parser.getText() == 'shipToPostalCode') { parser.nextToken(); shipToPostalCode = parser.getText(); }
                else if (parser.getText() == 'shipToCountry') { parser.nextToken(); shipToCountry = parser.getText(); }
                else if (parser.getText() == 'poNumber') { parser.nextToken(); poNumber = parser.getText(); }
                else if (parser.getText() == 'isCAD') { parser.nextToken(); isCAD = parser.getText() == 'true';}
            }
        }
        
        List<Alternate__c> alts = Database.query('SELECT Id, Freight_Group_Name__c FROM Alternate__c WHERE Id IN (' + 
            alternates + ') AND Freight_Group_Name__c != \'\'');
        
        Quote quote = [SELECT Id, Status, Inpro_Document_Number__c, Quote_Estimating_Notes__c, OpportunityId, ShippingCity, ShippingState, 
                              ShippingPostalCode, AdditionalCity, AdditionalState, AdditionalPostalCode 
                       FROM Quote 
                       WHERE Id = :quoteId];

        Opportunity opp = [SELECT Id, Name, Construction_Project__c FROM Opportunity WHERE Id = :quote.OpportunityId];

        Construction_Project__c cp = opp == null || opp.Construction_Project__c == null ? null : 
                [SELECT Id, Name, City__c, ZIP__c, State__c FROM Construction_Project__c WHERE Id = :opp.Construction_Project__c];

        Print_Quote__c printQuote = new Print_Quote__c();
        printQuote.Contact_Email__c = contactEmail;

        printQuote.To_Address__c = toAddress;
        printQuote.CC_Address__c = ccAddress;
        printQuote.BCC_Address__c = bccAddress;

        printQuote.Contact_Name__c = contactName;
        printQuote.Contact_Phone__c = contactPhone;
        printQuote.Credit_Type__c = creditType;
        
        printQuote.Currency_Code__c = isCAD ? 'CAD' : 'USD';
        printQuote.Currency_Symbol__c = '$';
        printQuote.Fax__c = fax;
        printQuote.Form_Type__c = formType;
        printQuote.Grand_Total__c = total;
        printQuote.Grand_Total_With_Tax__c = totalwTax;

        printQuote.Quote__c = quoteId;
        printQuote.Is_Taxable__c = taxable;
        printQuote.Is_Printing_Grand_Total__c = isPrintingGrandTotal;
        printQuote.Is_Submittal_Version__c = submittalVersion;
        printQuote.Is_Printing_Summary__c = isPrintingSummary;
        printQuote.Is_Printing_Details__c = isPrintDetails;

        if (isCAD)
        {
            CurrencyType_History__c currencyTypeHistory = 
                    [SELECT Id, IsActive__c, ConversionRate__c, CreatedById, CurrencyIsoCode, 
                        Name, Expiration_Date__c, LastModifiedById, OwnerId 
                    FROM CurrencyType_History__c
                    WHERE IsActive__c = true AND CurrencyIsoCode = 'CAD' LIMIT 1];

            //printQuote.Is_Taxable__c = false; //handled in Netsuite
            printQuote.Grand_Total__c *= currencyTypeHistory.ConversionRate__c;
            printQuote.Grand_Total_With_Tax__c *= currencyTypeHistory.ConversionRate__c;
        }

        if (quote.Inpro_Document_Number__c != null && 
            quote.Inpro_Document_Number__c.length() > 8 && 
            quote.Inpro_Document_Number__c.trim().indexOf('Q') == 0)
        {
            printQuote.Inpro_Document_Number__c = quote.Inpro_Document_Number__c.substring(0,8);
        }
        else
        {
            printQuote.Inpro_Document_Number__c = quote.Inpro_Document_Number__c;
        }

        printQuote.Has_Freight_Groups__c = alts.size() > 0;
        printQuote.Is_Hiding_Qty__c = hideQtys;
        printQuote.Is_Internal__c = internal || quote.Status == 'Draft';
        

        if(cp != null && (cp.City__c != null || cp.ZIP__c != null || cp.State__c != null))
        {
            printQuote.Location__c = cp.City__c + ', '
                                  + cp.State__c + ', '
                                  + cp.ZIP__c;
        }else{
            printQuote.Location__c = quote.AdditionalCity + ', '
                                  + quote.AdditionalState + ', '
                                  + quote.AdditionalPostalCode;
        }
        
        printQuote.Material__c = material;
        printQuote.Our_Reference__c = ourReference;
        printQuote.Payment_Terms__c = paymentTerms.replace('--p','%');
        printQuote.PO_Number__c = poNumber;
        printQuote.Project__c = cp != null ? cp.Name : opp.Name;
        printQuote.Quote_Estimating_Notes__c = quote.Quote_Estimating_Notes__c;
        printQuote.Ship_To_Street__c = shipToStreet;
        printQuote.Ship_To_City__c = shipToCity;
        printQuote.Ship_To_Country__c = shipToCountry;
        printQuote.Ship_To_Name__c = shipToName;
        printQuote.Ship_To_Postal_Code__c = shipToPostalCode;
        printQuote.Ship_To_State__c = shipToState;
        printQuote.Shipping_Terms__c = shippingTerms;
        printQuote.Your_Reference__c = jobReference;

        insert printQuote;

        return printQuote.Id;
    }

    @AuraEnabled
    public static string CheckSaveQuote(string quoteId){
        string query = 'SELECT Id FROM AsyncProcess__c WHERE ObjectId__c = \'' + quoteId + '\' AND Name = \'Save Quote\' AND Status__c = \'In-Process\'';
        List<AsyncProcess__c> async = Database.query(query);
        
        if (async.size() > 0)
        {
            return 'true';
        }
        else
        {
            return 'false';
        }
    }
    @AuraEnabled
    public static Contact GetContactInfo(string ContactId){
        Contact contact =
            [SELECT Id, AccountId, Name, Account_Name__c, Email, Phone, Fax
            FROM Contact
            WHERE Id = :ContactId ];
        return contact;
    }

    @AuraEnabled
    public static string GetDocumentNames(string alternateString){
        if (alternateString == '') return '';
        string query = 'SELECT Id, Document_Name__c, Alternate__c, QuoteId FROM QuoteLineItem WHERE Alternate__c IN (' + alternateString + ') AND Document_Name__c != \'\' ORDER BY Document_Name__c ASC';

        List<QuoteLineItem> qlis = Database.query(query);
        
        string docNumbers = '';
        for(QuoteLineItem qli : qlis)
        {
            if (docNumbers.indexOf(qli.Document_Name__c) == -1)
            {
                if (docNumbers.length() == 0) docNumbers = qli.Document_Name__c;
                else docNumbers += ', ' + qli.Document_Name__c;
            }
        }

        return docNumbers;
    }

    @AuraEnabled
    public static string GetGrandTotals(string quoteId, string alternateString, boolean isTaxable){
        if (alternateString == '')
        {
            return '0.0|0.0|0.0|0.0';
        }
        
        List<Alternate__c> alts = 
            Database.query('SELECT Id, Total_Material__c, Total_incl_Freight_Tax__c, Total_incl_Freight_No_Tax__c, ' +
            'Show_Unit_Pricing__c FROM Alternate__c WHERE Id IN (' + alternateString + ') ');

        double materialTotal = 0.0;
        double grandTotalTax = 0.0;
        double grandTotal = 0.0;

        for(Alternate__c alt : alts)
        {
            if (alt.Total_Material__c != null)
            {
                materialTotal += alt.Total_Material__c;
            }
            if (alt.Total_incl_Freight_No_Tax__c != null)
            {
                grandTotal += alt.Total_incl_Freight_No_Tax__c;
            }
            if (alt.Total_incl_Freight_Tax__c != null)
            {
                grandTotalTax += alt.Total_incl_Freight_Tax__c;
            }
        }

        alts = [SELECT Id, Total_Material__c, Total_incl_Freight_Tax__c, 
                    Total_incl_Freight_No_Tax__c, Show_Unit_Pricing__c 
                FROM Alternate__c 
                WHERE QuoteId__c = :quoteId ];

        double opportunityTotal = 0.0;

        for(Alternate__c alt : alts)
        {
            if (isTaxable)
            {
                opportunityTotal += alt.Total_incl_Freight_Tax__c;
            }
            else
            {
                opportunityTotal += alt.Total_incl_Freight_No_Tax__c;
            }
        }

        return materialTotal + '|' + opportunityTotal + '|' + grandTotal + '|' + grandTotalTax;
    }

    @AuraEnabled
    public static void UpdateOpportunityAmountAndStage(string Id, string NewAmount, string quoteId){        
        Opportunity opp = 
            [SELECT Id, Estimating_Divisional_Status__c, Is_Estimate_Required__c, Amount, StageName
            FROM Opportunity 
            WHERE Id = :Id ];

        opp.Amount = decimal.valueOf(newAmount);
        opp.StageName = 'Negotiation';
        if(quoteId != null && quoteId != '')
         opp.Last_Quote_Date_Time__c = [SELECT CreatedDate FROM Quote WHERE Id = :quoteId].CreatedDate;
        update opp;
    }

    @AuraEnabled
    public static List<Quote_Bidder__c> GetQuoteBidders(string QuoteId){
        List<Quote_Bidder__c> bidders = 
            [SELECT Id, Quote__c, Bidder__c, Contact_Email__c, Pricing_Group__c, Status__c, 
                Bidder_Status__c, Contact_Name__c, AccountId__c, Bidder_Name__c
             FROM Quote_Bidder__c
             WHERE Quote__c = :QuoteId ];
        
        return bidders;
    }

    @AuraEnabled
    public static void UpdateQuoteBiddersToSent(string BidderIds){
        String query = 'SELECT Id, Quote__c, Bidder__c, Pricing_Group__c, Status__c, ' +
            'Bidder_Status__c, Contact_Name__c, Contact_Email__c ' +
            'FROM Quote_Bidder__c ' +
            'WHERE Id IN (' + BidderIds + ') ';
        List<Quote_Bidder__c> bidders = Database.query(query);

        for(Quote_Bidder__c bidder : bidders)
        {
            bidder.Status__c = 'Sent';
        }
        update bidders;
    }

    @AuraEnabled
    public static void RevertQuoteParagraphs(string quoteId, string intro, string ending){
        Quote quote = 
            [SELECT Id, Introduction__c, Ending__c, Locked__c
            FROM Quote 
            WHERE Id = :quoteId ];

        //Unlock quote for editing
        boolean relock = false;
        if (quote.Locked__c)
        {
            relock = true;
            quote.Locked__c = false;
            update quote;
        }
        
        quote.Introduction__c = intro;
        quote.Ending__c = ending;

        if (relock)
        {
            quote.Locked__c = true;
        }
        
        update quote;
    }

    @AuraEnabled
    public static string GetPrintQuoteWrapper(string Id)
    {
        try{
            Quote quote = 
                [SELECT Id, AccountId, ContactId, Name, ShippingName, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, 
                    ShippingCountry, ShippingAddress, AdditionalStateCode, ShippingStateCode, 
                    BillingAddress, Status, BidQuote__c, Opportunity.Building_Owner_Parent__c,
                    PO_Number__c, Primary_Bidder__c, Inpro_Document_Number__c,Freight__c,OpportunityId, Revision_Number__c,
                    Introduction__c, Ending__c, Opportunity.Territory_Manager__r.Email
                FROM Quote 
                WHERE Id = :Id ];

            string contactEmail = '';
            try 
            {
                if (quote.ContactId != null)
                {
                    Contact contact = [SELECT Id, Email FROM Contact WHERE Id = :quote.ContactId LIMIT 1];
                    if (contact != null)
                    {
                        contactEmail = contact.Email;
                    }
                }
            } catch (Exception ex){
                //ignore
            }
            
            string isCad = 'false';

            if (quote.Opportunity.Building_Owner_Parent__c != null)
            {
                Account bop = [SELECT Id, Customer_Number__c FROM Account WHERE Id = :quote.Opportunity.Building_Owner_Parent__c];
                if(bop.Customer_Number__c == '755515')
                {
                    isCad = 'true';
                }
            }
            
            List<Contact> contacts =
                [SELECT Id, AccountId, Name, Account_Name__c
                FROM Contact
                WHERE Inactive_Contact__c = false AND (AccountId = :quote.AccountId 
                OR AccountId = :quote.Primary_Bidder__c 
                OR Id = :quote.ContactId )
                ORDER BY Name ASC];

            List<Contact> tempContacts = new List<Contact>();
            for(Contact c : contacts){
                if (c.AccountId != null)
                {
                    tempContacts.add(c);
                }
            }
            contacts = tempContacts;

            Opportunity opp = 
                [SELECT Id, Estimating_Divisional_Status__c, Is_Estimate_Required__c, Amount, Name, Owner.Email
                FROM Opportunity 
                WHERE Id = :quote.OpportunityId ];

                
            List<Alternate__c> alts = 
                [SELECT Id, QuoteId__c, Name__c, Group_Sequence_Number__c, Sequence_Number__c,Show_Unit_Pricing__c,
                    Freight_Group_Name__c, Freight_Amount__c, Yield__c, Total_incl_Freight_Tax__c,Total_incl_Freight_No_Tax__c
                FROM Alternate__c 
                WHERE QuoteId__c = :Id ];

            boolean runAlternateCalculation = false;

            //Ensure CM and Yield are calculated
            alts = AlternateHelper.getAlternates(Id);
            
            List<Tax_Exempt_Certificate__c> taxCerts = 
                [SELECT Id, Account__c, Account__r.Name, Tax_Exempt__c, Certificate_Type__c, States_Where_Valid__c, 
                    Expiration_Date__c, Effective_Date__c, Note_Subject__c, Tax_Reciprocity__c, Tax_Reciprocity__r.Name
                FROM Tax_Exempt_Certificate__c 
                WHERE Account__c = :quote.Primary_Bidder__c 
                AND Approval_Status__c = 'Approved' 
                AND (Expiration_Date__c = null OR Expiration_Date__c >= :System.Today())
                ORDER BY Expiration_Date__c ASC ];

            List<Tax_Exempt_Certificate__c> temp = new List<Tax_Exempt_Certificate__c>();

            for(Tax_Exempt_Certificate__c tec : taxCerts)
            {
                if (
                        (
                            tec.States_Where_Valid__c == null
                        ) || 
                        (
                            tec.States_Where_Valid__c != null && 
                            (
                                tec.Certificate_Type__c == 'Job Specific' && quote.AdditionalStateCode != null &&
                                tec.States_Where_Valid__c.indexOf(quote.AdditionalStateCode) != -1
                            ) ||
                            (
                                tec.Certificate_Type__c != 'Job Specific' && quote.ShippingStateCode != null &&
                                tec.States_Where_Valid__c.indexOf(quote.ShippingStateCode) != -1
                            )
                        )
                    )
                {
                    temp.add(tec);
                }
            }

            taxCerts = temp;
            
            List<Qualification__c> q = 
                [SELECT Id, Quote__c 
                FROM Qualification__c 
                WHERE Quote__c = :Id ];

            List<QuoteLineItem> qlis = 
                [SELECT Id, QuoteId 
                FROM QuoteLineItem 
                WHERE QuoteId = :Id ];

            SObjectField picklistUsingGlobal = SObjectType.Account.fields.Payment_Terms__c.getSObjectField();
            List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();

            return JSON.serialize(new PrintQuoteWrapper(quote, opp, alts, contacts, taxCerts, q, qlis, entries, contactEmail, isCad));
        }
        catch(Exception ex)
        {
            return ex.getMessage() + ', ' + ex.getStackTraceString();
        }
    }

    @AuraEnabled
    public static void UpdateQuote(string id, string introduction, string ending, string updateNumber, string updateStatus){
        Quote quote = [SELECT Id, Name, Status, Locked__c, QuoteNumber, PrintNumber__c, Introduction__c, Ending__c FROM Quote WHERE Id = :id ];

        boolean relock = false;
        if (quote.Locked__c)
        {
            //Unlock quote for editing
            quote.Locked__c = false;
            relock = true;
            try{
                update quote;
            }catch(Exception ex)
            {
                //ignore if quote is locked
            }
        }
        
        
        //Update fields
        if (updateNumber == 'true') {
            if (quote.PrintNumber__c != null )quote.PrintNumber__c += 1;
            else quote.PrintNumber__c = 1;
        } else if (quote.PrintNumber__c == null) quote.PrintNumber__c = 1;

        quote.Introduction__c = introduction;
        quote.Ending__c = ending;
        quote.Inpro_Document_Number__c = quote.Name + '-' + quote.QuoteNumber + '-' + quote.PrintNumber__c;

        if (updateStatus == 'true')
        {
            quote.Status = 'Sent to Customer';
        }
        
        //Update quote
        try{
            update quote;
        }catch(Exception ex)
        {
            //ignore if quote is locked
        }

        if (relock)
        {
            //Lock it
            quote.Locked__c = true;
            try{
                update quote;
            }catch(Exception ex)
            {
                //ignore if quote is locked
            }
        }
        
    }

    @AuraEnabled
    public static string GeneratePrintPDF(string QuoteId, string FileName, string PageName, string Params){
        string currentValue = '';
        try{
            PageReference reportPage;

            if(PageName == 'Quote_ProForma_PDF'){
                reportPage = Page.Quote_ProForma_PDF;
            }
            else if(PageName == 'Quote_ProFormaInvoiceForLetterCredit_PDF'){
                reportPage = Page.Quote_ProFormaInvoiceForLetterCredit_PDF;
            }
            else if(PageName == 'Quote_ProFormaInvoiceWireTransfer'){
                reportPage = Page.Quote_ProFormaInvoiceWireTransfer;
            }
            else if(PageName == 'Quote_w_Pricing_PDF'){
                reportPage = Page.Quote_w_Pricing_PDF;
            }
            else if(PageName == 'Quote_Bid_Format_PDF'){
                reportPage = Page.Quote_Bid_Format_PDF;
            }
            else if(PageName == 'Quote_w_LumpSumPricing_PDF'){
                reportPage = Page.Quote_w_LumpSumPricing_PDF;
            }
            else if (PageName == 'Quote_PDF_Global'){
                reportPage = Page.Quote_PDF_Global;
            }
            if (reportPage == null) return null;
    
            for(string param : Params.split('&'))
            {
                currentValue = param;
                string[] keyValuePair = param.split('=');
                if (keyValuePair.size() == 1) reportPage.getParameters().put(keyValuePair[0],'');
                else reportPage.getParameters().put(keyValuePair[0],keyValuePair[1]);
                
            }

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

            //Return id for email
            return contentVersion_1.Id;
        }catch(Exception ex){
            return currentValue + '...' + ex.getMessage() + '\r\n' + ex.getStackTraceString();
        }
        
    }
    
    @AuraEnabled
    public static string CreateAsyncProcess(string QuoteId){
         //Create task to finish later
         AsyncProcess__c asyncProcess = new AsyncProcess__c();                
         asyncProcess.CreatedDate__c = Datetime.now();                
         //asyncProcess.Log__c = '';
         asyncProcess.Name = 'Print Quote';
         asyncProcess.ObjectId__c = QuoteId;                
         asyncProcess.Status__c = 'In-Process';                   
         insert asyncProcess;

         return asyncProcess.Id;
    }

    @AuraEnabled
    public static string SendCustomFormsEmail(string QuoteId, string AsyncProcessId, string ToAddress, string CcAddress, string BccAddress, 
    string Subject, string BodyHtml, string AttachmentIds, string CustomForms){
        Quote quote = [SELECT Id, Division_Lookup__r.MSCRM_ID__c FROM Quote WHERE Id = :QuoteId];
            
        //Fire off async process and handle email in service layer
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
        service.timeout_x = 120000;
        service.CreateCustomFormsForPrintQuote(QuoteId, AsyncProcessId, 
            AttachmentIds, CustomForms, false, false, 'dsj8U73_3nv3Dhba', quote.Division_Lookup__r.MSCRM_ID__c, 
            ToAddress, CcAddress, BccAddress, Subject, 
            '<html><head><style>p{margin-top:2px;margin-bottom:2px;}</style></head><body>' + BodyHtml + '</body></html>',
            UserInfo.getUserId(), UserInfo.getUserEmail());

        return 'SUCCESS_CUSTOM';
    }

    @AuraEnabled
    public static string SendEmail(string QuoteId, string ToAddress, string CcAddress, string BccAddress, 
        string Subject, string BodyHtml, string AttachmentIds)
    {
        string[] toAddresses = new string[]{};
        if (ToAddress != '')toAddresses = toAddress.split(',');
        string[] ccAddresses = new string[]{};
        if (CcAddress != '')ccAddresses = CcAddress.split(',');
        string[] bccAddresses = new string[]{};
        if (BccAddress != '')bccAddresses = BccAddress.split(',');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.toaddresses = toAddresses;
        if (ccAddresses.size() > 0) message.ccaddresses = ccAddresses;
        if (bccAddresses.size() > 0) message.bccaddresses = bccAddresses;
        message.optOutPolicy = 'FILTER';
        message.subject = Subject;
        message.htmlbody = '<html><head><style>p{margin-top:2px;margin-bottom:2px;}</style></head><body>' + BodyHtml + '</body></html>';
        
        message.setReplyTo(UserInfo.getUserEmail());
        message.setWhatId(QuoteId);
        message.setSaveAsActivity(true);
        
        if (AttachmentIds != '')
        {
            string Query = 'SELECT Title, PathOnClient, FileType, FileExtension, VersionData FROM ContentVersion WHERE Id IN (' + AttachmentIds + ') OR ContentDocumentId IN (' + AttachmentIds + ')';
            List<ContentVersion> files = Database.query(Query);
            List<Id> fileIds = new List<Id>();
            List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
            for(ContentVersion file : files)
            {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.fileName = file.Title+'.'+file.FileExtension;
                efa.body =file.VersionData;
                efas.add(efa);
                fileIds.add(file.Id);
                //message.htmlbody += '<br><a href="' + file.PathOnClient + '">' + efa.fileName + '</a>';
            }
            //message.setFileAttachments(efas);
            message.setEntityAttachments(fileIds);
        }
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(message);

        try {
            Messaging.SendEmailResult results = Messaging.sendEmail(allmsg)[0];
            if (results.success){
                return '';
            } 
            else return results.errors[0].getMessage();
        } catch (Exception e) {
            return e.getMessage() + ': ' + e.getStackTraceString();       
        }
    }

    @AuraEnabled
    public static List<EmailTemplate> GetUserEmailTemplates(string userId){
        /*List<EmailTemplate> templates = 
            [SELECT ApiVersion, Body, BrandTemplateId, CreatedById, CreatedDate, Description, DeveloperName, 
                    Encoding, EnhancedLetterheadId, FolderId, FolderName, HasSalesforceFiles, HtmlValue, Id, 
                    IsActive, IsBuilderContent, LastModifiedById, LastModifiedDate, LastUsedDate, Markup, Name, 
                    NamespacePrefix, OwnerId, RelatedEntityType, Subject, SystemModstamp, TemplateStyle, 
                    TemplateType, TimesUsed, UiType
             FROM EmailTemplate
             WHERE OwnerId = :UserId AND RelatedEntityType = 'Quote' 
             ORDER BY Name ASC];*/
        return [SELECT HtmlValue, Id, IsActive, Name, OwnerId, RelatedEntityType, Subject
                FROM EmailTemplate
                WHERE OwnerId = :UserId AND IsActive = true
                ORDER BY Name ASC];
    }

    @AuraEnabled
    public static string CreateNewQuoteEmailTemplate(string userId, string name, string html)
    {
        try
        {
            Folder f = [SELECT Id,AccessType,Name FROM Folder WHERE Name = 'Print Quote Lightning Templates'];
            EmailTemplate et = new EmailTemplate();
            et.Name = 'Print Quote - ' + name;
            //et.RelatedEntityType = 'Quote';
            et.Description = 'Email Template created for the Print Quote application. To create a new email signature for that' +
                ' application, please go through that application; otherwise, make sure to set the Related Entity Type value of your' +
                ' new template to "Quote" so that it is visible to that application';
            et.Subject = name;
            et.DeveloperName = 'Print_Quote_' + userId + '_' + Datetime.now().getTime();
            et.HtmlValue = html;
            et.OwnerId = userId;
            et.FolderId =  f.Id;
            et.TemplateType = 'custom';
            insert et;
    
            return 'Success';
        }
        catch(Exception e){
            return e.getMessage() + ': ' + e.getStackTraceString();       
        }
    }

    @AuraEnabled
    public static Boolean PricingAccountsChanged(string quoteId){         
            Boolean changed = false;
            Quote quote = [SELECT Pricing_Account_Numbers_Flick__c, Pricing_Account_Numbers__c
                               FROM Quote
                               WHERE Id =: quoteId 
                               LIMIT 1];       
            if(quote != null)
            {
                if (quote.Pricing_Account_Numbers_Flick__c == null)
                {
                    quote.Pricing_Account_Numbers_Flick__c = quote.Pricing_Account_Numbers__c;
                    update quote;
                    return false;
                }

                string flick = quote.Pricing_Account_Numbers_Flick__c.replace('null','');
                if(quote.Pricing_Account_Numbers_Flick__c !=  quote.Pricing_Account_Numbers__c) 
                    changed = true;
            }

            return changed;
        }

    @AuraEnabled
    public static void updatePricingAccountsFlick(string quoteId){         
        
        List<Quote> quoteList = [select 
                                Pricing_Account_Numbers_Flick__c, Pricing_Account_Numbers__c
                                from Quote where Id =: quoteId LIMIT 1];       
        if(quoteList != null && quoteList.size() > 0)
        {
            Quote q = new Quote();
            q.Id = quoteList[0].Id;
            q.Pricing_Account_Numbers_Flick__c = quoteList[0].Pricing_Account_Numbers__c;                
            update q;
        }
    } 
}