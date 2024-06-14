public inherited sharing class RequestOrderHelper {
    @AuraEnabled()
    public static Quote getQuote(String recordId)
    {
        List<Quote> quote = [SELECT Primary_Bidder__r.Point_of_Contact__c, Opportunity.Owner.NetSuite_Id__c, Subtotal,Primary_Bidder__r.Customer_Number__c,
                                    Account.Customer_Number__c, AccountId, Primary_Bidder__c, Primary_Bidder__r.Id,  Primary_Bidder__r.Name,  Name, Account.Name, 
                                    Account.Credit_Hold__c, Account.Payment_Terms__c, Opportunity.Market_Segment__c, ShippingName, ShippingStreet, ShippingCity, 
                                    ShippingState, ShippingPostalCode, ShippingCountry, Opportunity.Building_Owner_Parent__r.Customer_Number__c, OpportunityId,
                                    Opportunity.Building_Owner_Parent__r.Level__c, Opportunity.Building_Owner_Parent__r.Job_Number_Excluded__c, OwnerId,
                                    Opp_Owner_s_Manager__c, Division__c, Primary_Bidder__r.Inactive__c, AdditionalStateCode, ShippingStateCode, Opportunity.OwnerId,
                                    Opportunity.Building_Owner_Parent__c, Opportunity.Building_Owner__c, Grand_Total__c, Type__c
                             FROM Quote WHERE Id = :recordId LIMIT 1];        
        return quote[0];    
    }

    @AuraEnabled()
    public static RetrievedContract getContractById(String contractId)
    {
        RetrievedContract contract = new RetrievedContract();
        contract.isExecuted = true;       
        
        string contractVersionQuery = 'SELECT Inpro_Contract__c, Inpro_Contract__r.Original_PO_Contract_No__c, Status__c, Inpro_Contract__r.Payment_Terms__c ' +
                                        'FROM Contract_Version__c ' +
                                        'WHERE Inpro_Contract__c = :contractId'; 
        
        List<Contract_Version__c> contractVersions = Database.query(contractVersionQuery);
        if(contractVersions != null && contractVersions.size() > 0)
        {
            for(Contract_Version__c cv : contractVersions)
            {
                contract.Id = cv.Inpro_Contract__c;
                if(cv.Inpro_Contract__r != null && cv.Inpro_Contract__r.Original_PO_Contract_No__c != null)
                    contract.PONumber = cv.Inpro_Contract__r.Original_PO_Contract_No__c;
                if(cv.Status__c != null && cv.Status__c != 'Completed')
                    contract.isExecuted = false;
                if(cv.Inpro_Contract__r.Payment_Terms__c != null)
                    contract.paymentTerms = cv.Inpro_Contract__r.Payment_Terms__c;
            }
        }
        return contract;            
    }

    @AuraEnabled()
    public static List<AlternateDetail> getAlternates(String quoteId)
    {
        List<AlternateDetail> alternateDetails = new List<AlternateDetail>();
        List<Alternate__c> alternates = [SELECT Id, Name__c, Sequence_Number__c, Total_Material__c, Freight_Amount__c, Total_Tax__c, Total_incl_Freight_Tax__c, Total_incl_Freight_No_Tax__c
                                         FROM Alternate__c WHERE QuoteId__c = :quoteId];
                                         
        for(Alternate__c alt : alternates)
        {
            AlternateDetail det = new AlternateDetail();
            det.Id = alt.Id;
            det.name = alt.Name__c;
            det.sequenceNumber = alt.Sequence_Number__c;
            det.totalMaterial = alt.Total_Material__c;
            det.freightAmount = alt.Freight_Amount__c;
            det.totalTax = alt.Total_Tax__c;
            det.totalInclFreightTax = alt.Total_incl_Freight_Tax__c;
            det.totalInclFreightNoTax = alt.Total_incl_Freight_No_Tax__c;
            //initiate this as false, but run additional logic later
            det.bulkPackagable = false;
            alternateDetails.add(det);
        }

        //bulk packaging logic
        // try {
            List<BulkPackageDetail> bulkPackageDetails = new List<BulkPackageDetail>();
            List<QuoteLineItem> quoteItems = [SELECT Quantity, Bulk_Pack_Group__c, Alternate__c, Item_Number__c
                                              FROM QuoteLineItem WHERE Bulk_Pack_Group__c != null AND QuoteId =: quoteId];

            if(quoteItems != null && quoteItems.size() > 0)
            {
                for(QuoteLineItem i : quoteItems)
                {
                    if(bulkPackageDetails.size() == 0)
                    {
                        BulkPackageDetail bpd = new BulkPackageDetail();
                        bpd.bulkPackageGroup = i.Bulk_Pack_Group__c;
                        bpd.bulkPackageGroupQty = decimal.valueOf((i.Bulk_Pack_Group__c.toLowerCase().replace('sheet_','')));
                        bpd.qtyOnAlternate = i.Quantity;
                        bpd.alternateId = i.Alternate__c;
                        bpd.itemNumbers = i.Item_Number__c + ' || ';
                        bulkPackageDetails.add(bpd);
                    }
                    else {
                        Boolean bulkPackageGroupFound = false;
                        for(BulkPackageDetail b : bulkPackageDetails)
                        {
                            if(b.alternateId == i.Alternate__c && b.bulkPackageGroup == i.Bulk_Pack_Group__c)
                            {
                                bulkPackageGroupFound = true;
                                b.itemNumbers += i.Item_Number__c + ' || ';
                                b.qtyOnAlternate += i.Quantity;
                            }
                        }
                        if(!bulkPackageGroupFound)
                        {
                            BulkPackageDetail bpd = new BulkPackageDetail();
                            bpd.bulkPackageGroup = i.Bulk_Pack_Group__c;
                            bpd.bulkPackageGroupQty = decimal.valueOf((i.Bulk_Pack_Group__c.toLowerCase().replace('sheet_','')));
                            bpd.qtyOnAlternate = i.Quantity;
                            bpd.alternateId = i.Alternate__c;
                            bpd.itemNumbers = i.Item_Number__c;
                            bulkPackageDetails.add(bpd);
                        }
                    }
                }

                if(bulkPackageDetails.size() > 0)
                {
                    for(BulkPackageDetail b : bulkPackageDetails)
                    {
                        if(b.qtyOnAlternate >= b.bulkPackageGroupQty)
                        {
                            for(AlternateDetail ad : alternateDetails)
                            {
                                if(ad.Id == b.alternateId)
                                {
                                    ad.bulkPackagable = true;
                                    ad.bulkPackageItems = b.itemNumbers;
                                }
                            }
                        }
                    }
                }
            }
        // } 
        // catch (Exception ex) 
        // {
        //     return alternateDetails;
        // }
        return alternateDetails;    
    }

    @AuraEnabled()
    public static Boolean isBidderTaxExempt(String accountId, String additionalStateCode, String shippingStateCode)
    {
        Boolean isTaxExempt = false;
        List<Tax_Exempt_Certificate__c> taxCerts = 
                [SELECT Id, Account__c, Account__r.Name, Tax_Exempt__c, Certificate_Type__c, States_Where_Valid__c, 
                    Expiration_Date__c, Effective_Date__c, Note_Subject__c, Tax_Reciprocity__c, Tax_Reciprocity__r.Name
                FROM Tax_Exempt_Certificate__c 
                WHERE Account__c = :accountId
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
                            tec.Certificate_Type__c == 'Job Specific' && additionalStateCode != null &&
                            tec.States_Where_Valid__c.indexOf(additionalStateCode) != -1
                        ) ||
                        (
                            tec.Certificate_Type__c != 'Job Specific' && shippingStateCode != null &&
                            tec.States_Where_Valid__c.indexOf(shippingStateCode) != -1
                        )
                    )
                )
                {
                    isTaxExempt = true;
                }
        }

        return isTaxExempt;
    }

    @AuraEnabled
    public static string getSalesRepNumbers()
    {
        try {
            //if ('true' == 'true'){ throw new AuraHandledException('getSalesRepNumbers');}
            // sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();          
            // service.timeout_x = 120000;

            //salesrep.Name,
            //salesrep.Number_x

            String Query = 'SELECT NetSuite_Id__c, Name  FROM User  WHERE NetSuite_Id__c != null ORDER BY Name';
            List<User> users = Database.query(Query);                  

            //sfdata.SalesRepNumberLookupResult sResults = service.GetSalesRepNumberLookup('dsj8U73_3nv3Dhba');
            return JSON.serialize(users);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled()
    public static string createOrderRequest(String recordId, RequestOrder orderRequest, Boolean needsOverContractApproval, 
                    string notesToApprover, string userId, Boolean needsContractNotExecutedApproval, Boolean needsCreditHoldApproval, string selectedBulkPackageAction)
    {
        Quote q = new Quote();
        q.Id = recordId;
        q.Automation_Date_Time__c = Datetime.now();
        q.ShippingName = orderRequest.shipToName;
        update q;

        Order_Request__c rOrder = new Order_Request__c();

        //Assign to the CCS Queue
        String Query = 'SELECT Id FROM Group WHERE Type = \'Queue\' AND Name = \'Customer Care Queue\' LIMIT 1';
        List<Group> Queues = Database.query(Query);
        if(Queues != null && Queues.size() > 0)
        { 
            Group g = Queues[0];
            rOrder.OwnerId = g.Id;
        }
        if(needsOverContractApproval || needsContractNotExecutedApproval || needsCreditHoldApproval)
        {
            rOrder.Required_Approvals__c = '';
            if(needsOverContractApproval)
                rOrder.Required_Approvals__c = 'Over Contract;';
            if(needsContractNotExecutedApproval)
                rOrder.Required_Approvals__c += 'Contract Not Executed;';
            if(needsCreditHoldApproval)
                rOrder.Required_Approvals__c += 'Credit Hold;';
            if(rOrder.Required_Approvals__c != null && rOrder.Required_Approvals__c != '')
                rOrder.Required_Approvals__c = (rOrder.Required_Approvals__c).substring(0,rOrder.Required_Approvals__c.length()-1);
        }

        rOrder.Description__c = '';
        //orderRequest.CreditApproval;       
        rOrder.Same_Day__c = orderRequest.SameDayOrder;
        rOrder.No_Charge__c =  orderRequest.NoChargeOrder;
        //orderRequest.InvoiceDetail;
        rOrder.PO_Number__c = orderRequest.PO;
        rOrder.Sales_Rep_Number__c = orderRequest.RepNumber;
        rOrder.ContactId__c = orderRequest.ContactId;
        if(orderRequest.InvoiceDetail)
        {
            rOrder.Invoice_Report_Type__c = 'LumpSum';
        }
        if(orderRequest.bypassBuildingOwner != null && orderRequest.bypassBuildingOwner)
            rOrder.Building_Owner_Logic_Bypassed__c = true;
        //orderRequest.NationalAccount;
        rOrder.Shipping_Instructions__c = orderRequest.ShippingInstructions;
        rOrder.Installer_Email__c = orderRequest.InstallerEmail;
        rOrder.QuoteId__c = recordId;       
        rOrder.Account__c = orderRequest.Bidder;
        rOrder.Order_Amount__c = orderRequest.OrderAmount;
        if(orderRequest.ContractId != null && orderRequest.ContractId != '')
            rOrder.Inpro_Contract__c = orderRequest.ContractId;
        //rOrder.OwnerId = Customer Care Queue
        if(orderRequest.NoChargeOrder == true)
        {
            string noChargeinfo ='No Charge Information:' + ' '  +
            '<br/>Original Order #:' + ' '  + orderRequest.OriginalOrderNumber + '<br/>' +
            'Original Invoice #:' + ' '  + orderRequest.OriginalInvoiceNumber+ '<br/>' +
            //'Reason Category:' + ' '  + orderRequest.ReasonCategory + '<br/>'+
            //'Reason Code:' + ' '  + orderRequest.ReasonCode+ '<br/>' +
            'No Charge Comments:' + ' '  + orderRequest.Explanation;
            rOrder.Description__c += noChargeInfo;

            rOrder.RCA_Category__c = orderRequest.ReasonCategory;
            rOrder.RCA_Reason__c = orderRequest.ReasonCode;
        }

        rOrder.Ship_To_Address_1__c = orderRequest.shipToAddress1;
        rOrder.Ship_To_Address_2__c = orderRequest.shipToAddress2;
        rOrder.Ship_To_City__c = orderRequest.shipToCity;
        rOrder.Ship_To_Contact_Name__c = orderRequest.shipToContactName;
        rOrder.Ship_To_Contact_Phone_Number__c = orderRequest.shipToContactPhoneNumber;
        rOrder.Ship_To_Country__c = orderRequest.shipToCountry;
        rOrder.Ship_To_Name__c = orderRequest.shipToName;
        rOrder.Ship_To_State_Province__c = orderRequest.shipToState;
        rOrder.Ship_To_Zip_Postal_Code__c = orderRequest.shipToZip;    
        string comments = '';
        if(orderRequest.OrderInformation != null && orderRequest.OrderInformation != '')
            comments = orderRequest.OrderInformation;
        if(notesToApprover != null && notesToApprover != '')
            comments += '\n' + notesToApprover.replace('<br/>', '\n');
        rOrder.Order_Request_Comments__c = comments;
        rOrder.Job_Number__c = orderRequest.NationalAccount;
        if(needsOverContractApproval)
            rOrder.Requires_Over_Contract_Approval__c = true;
        if(needsOverContractApproval || needsCreditHoldApproval || needsContractNotExecutedApproval)
        {
            rOrder.Approval_Status__c = 'Submitted';

            List<Group> groupList = [SELECT Id FROM Group WHERE Name = 'Finance Queue'];
            if(groupList.size() > 0)
                rOrder.OwnerId = groupList[0].Id;
        }     
        
        if(orderRequest.selectedAlternateIdsString != null && orderRequest.selectedAlternateIdsString != '')
            rOrder.Selected_Alternates__c = orderRequest.selectedAlternateIdsString;

        insert rOrder;

        if((orderRequest.buildingOwnerId != null && orderRequest.buildingOwnerId != '') || (orderRequest.buildingOwnerParentId != null && orderRequest.buildingOwnerParentId != ''))
        {
            Opportunity o = new Opportunity();
            o.Id = orderRequest.opportunityId;            
            if(orderRequest.buildingOwnerId != null && orderRequest.buildingOwnerId != '')
                o.Building_Owner__c = orderRequest.buildingOwnerId;
            if(orderRequest.buildingOwnerParentId != null && orderRequest.buildingOwnerParentId != '')
                o.Building_Owner_Parent__c = orderRequest.buildingOwnerParentId;
            update o;
        }

        if(needsOverContractApproval || needsCreditHoldApproval || needsContractNotExecutedApproval)
        {
            if(orderRequest.collectorEmail == null)
                orderRequest.collectorEmail = '';
            String submitterEmail = '';
            String UserQuery = 'SELECT Id, Email FROM User WHERE Id = :userId LIMIT 1';
            List<User> users = Database.query(UserQuery);
            if(users != null && users.size() > 0)
            { 
                User u = users[0];
                submitterEmail = u.Email;
                string Body = 'The order request you have created has been submitted for the following approval(s): ';
                if(needsOverContractApproval)
                    Body += 'Over Contract, ';
                if(needsCreditHoldApproval)
                    Body += 'Credit Hold, ';
                if(needsContractNotExecutedApproval)
                    Body += 'Contract Not Executed, ';
                Body = Body.substring(0, Body.length() - 2);
                Body += '. The following individuals can be contacted if you have any questions: <br/><br/>';
                Body += 'Over Contract/Contract Not Executed: Nicole Tabat, Rachel Price, Erin Habermehl, or Kelly Poulson <br/>';
                Body += 'Credit Hold: ' + orderRequest.collectorEmail + ' <br/><br/>';
                Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rOrder.Id + '\">Order Request</a>';
                EmailSendHelper.sendEmail(submitterEmail, '', 'Order Request Submitted For Approval', Body);
            }

            List<String> financeApprovers = new List<String>();
            //financeApprovers.add('eleptich@inprocorp.com');

            string Body = submitterEmail + ' has submitted the following Order Request for the following approval(s): ';
            string collectorEmail = '';
            if(needsOverContractApproval)
            {
                financeApprovers.add('ntabat@inprocorp.com');
                financeApprovers.add('rprice@inprocorp.com');
                financeApprovers.add('ehabermehl@inprocorp.com');
                financeApprovers.add('kpoulson@inprocorp.com');
                Body += 'Over Contract, ';
            }
            if(needsCreditHoldApproval)
            {
                if(orderRequest.collectorEmail != '')
                    financeApprovers.add(orderRequest.collectorEmail);
                Body += 'Credit Hold, ';

            }
            if(needsContractNotExecutedApproval)
            {
                financeApprovers.add('ntabat@inprocorp.com');
                financeApprovers.add('rprice@inprocorp.com');
                financeApprovers.add('ehabermehl@inprocorp.com');
                financeApprovers.add('kpoulson@inprocorp.com');
                Body += 'Contract Not Executed, ';
            }
            Body = Body.substring(0, Body.length() - 2);
            Body += '.<br/><br/>';
            Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rOrder.Id + '\">Order Request</a><br/><br/>';
            Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '\">Quote</a><br/><br/>';
            if(orderRequest.ContractId != null && orderRequest.ContractId != '')
                Body += '<a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + orderRequest.ContractId + '\">Contract</a><br/><br/>';
            Body += 'Notes to Approver:<br/>';
            Body += notesToApprover;
            EmailSendHelper.sendEmailMultipleRecipients(financeApprovers, '', 'Order Request Submitted For Approval', Body);
                        
            CustomNotificationFromApex cn = new CustomNotificationFromApex();
            Set<String> financeApproverSet = new Set<String>();

            String financeUserQuery = '';
            if(needsOverContractApproval || needsContractNotExecutedApproval)
                financeUserQuery = 'SELECT Id FROM User WHERE Email = \'ntabat@inprocorp.com\' OR Email = \'rprice@inprocorp.com\' OR Email = \'ehabermehl@inprocorp.com\' OR Email = \'kpoulson@inprocorp.com\'';
            else if (!needsOverContractApproval && !needsContractNotExecutedApproval && needsCreditHoldApproval && collectorEmail != '')
                financeUserQuery = 'SELECT Id FROM User WHERE Email :collectorEmail';
            else {
                financeUserQuery = 'SELECT Id FROM User WHERE Email = \'ntabat@inprocorp.com\' OR Email = \'rprice@inprocorp.com\' OR Email = \'ehabermehl@inprocorp.com\' OR Email = \'kpoulson@inprocorp.com\'';
            }
            List<User> financeUsers = Database.query(financeUserQuery);
            if(financeUsers != null && financeUsers.size() > 0)
            {
                for(User usr : financeUsers)
                {
                    financeApproverSet.add(usr.Id);
                }
                cn.notifyUsers(financeApproverSet, rOrder.Id, 'Order Request Submitted For Over Contract Approval', submitterEmail + ' has submitted the following Order Request for over contract approval.');
            }
        }

        if(selectedBulkPackageAction != null && selectedBulkPackageAction != '' && orderRequest.oppOwner != null)
        {
            //create the task
            Bulk_Packaging_Task__c bpTask = new Bulk_Packaging_Task__c();
            bpTask.OwnerId = userId;
            bpTask.Order_Request__c = rOrder.Id;
            bpTask.Sales_Manager__c = orderRequest.oppOwnerManager;
            String dayOfWeek = (Datetime.now()).format('EEEE');
            if(dayOfWeek != null && dayOfWeek == 'Friday')
                bpTask.Reminder_Date__c = (Datetime.now()).addDays(3);
            else {
                bpTask.Reminder_Date__c = (Datetime.now()).addDays(1);
            }

            if(selectedBulkPackageAction == 'Yes')
            {
                bpTask.Processed_By__c = userId;
                bpTask.Processed_On__c = Datetime.now();
                bpTask.Status__c = 'Bulk Packaging Accepted';

            }
            else if (selectedBulkPackageAction == 'No')
            {
                bpTask.Processed_By__c = userId;
                bpTask.Processed_On__c = Datetime.now();
                bpTask.Status__c = 'Bulk Packaging Declined';
            }
            else if(selectedBulkPackageAction == 'Review Later')
            {
                bpTask.Status__c = 'Open';
            }
            insert bpTask;

            if(selectedBulkPackageAction == 'Review Later')
            {
                String oppOwnerId = orderRequest.oppOwner;
                String quoteOwnerId = orderRequest.quoteOwner;
                //email logic
                List<String> bulkPackagingRecipients = new List<String>();
                //bulkPackagingRecipients.add('eleptich@inprocorp.com');
                
                //Opp Owner
                String oppOwnerQuery = 'SELECT Id, Email, DelegatedApproverId FROM User WHERE Id = :oppOwnerId LIMIT 1';
                List<User> oppOwners = Database.query(oppOwnerQuery);
                if(oppOwners != null && oppOwners.size() > 0)
                { 
                    if(oppOwners[0].Email != null)
                    {
                        bulkPackagingRecipients.add(oppOwners[0].Email);
                    }

                    if(oppOwners[0].DelegatedApproverId != null)
                    {
                        String delegatedApproverId = oppOwners[0].DelegatedApproverId;
                        String delegatedApproverQuery = 'SELECT Id, Email FROM User WHERE Id = :delegatedApproverId LIMIT 1';
                        List<User> delegatedApprovers = Database.query(delegatedApproverQuery);
                        if(delegatedApprovers != null && delegatedApprovers.size() > 0)
                        { 
                            if(delegatedApprovers[0].Email != null)
                                bulkPackagingRecipients.add(delegatedApprovers[0].Email);
                        }
                    }
                }

                //Quote Owner
                String quoteOwnerQuery = 'SELECT Id, Email, DelegatedApproverId FROM User WHERE Id = :quoteOwnerId LIMIT 1';
                List<User> quoteOwners = Database.query(quoteOwnerQuery);
                if(quoteOwners != null && quoteOwners.size() > 0)
                { 
                    if(quoteOwners[0].Email != null)
                    {
                        bulkPackagingRecipients.add(quoteOwners[0].Email);
                    }

                    if(quoteOwners[0].DelegatedApproverId != null)
                    {
                        String delegatedApproverId = quoteOwners[0].DelegatedApproverId;
                        String delegatedApproverQuery = 'SELECT Id, Email FROM User WHERE Id = :delegatedApproverId LIMIT 1';
                        List<User> delegatedApprovers = Database.query(delegatedApproverQuery);
                        if(delegatedApprovers != null && delegatedApprovers.size() > 0)
                        { 
                            if(delegatedApprovers[0].Email != null)
                                bulkPackagingRecipients.add(delegatedApprovers[0].Email);
                        }
                    }
                }


                string bpBody = 'Bulk Packaging Processing Request: A bulk processing task has been created for an order request where you are the associated project owner. ';
                bpBody += 'Please respond to whether the bulk packaging should take place for the order. In 24 hours (factoring in weekends), a link to the task will be forwarded ';
                bpBody += 'to your manager for processing if it hasn\'t yet been processed. A link to the order request and bulk processing task can be seen below.'; 
                bpBody += '<br/><br/><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + rOrder.Id + '\">Order Request</a>';
                bpBody += '<br/><br/><a style=\"font-size:20px\" href=\"' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + bpTask.Id + '\">Bulk Processing Task</a>';
                EmailSendHelper.sendEmailMultipleRecipients(bulkPackagingRecipients, '', 'Bulk Packaging Processing Request', bpBody);
            }
        }

        return rOrder.Id;
    }

    @AuraEnabled
    public static List<Quote_Bidder__c> getBidders(String recordId)
    {
        String Query =  'SELECT AccountId__c, Bidder_Name__c, Bidder__c, ' + 
            'Id, Name, Bidder_Name__r.Bidder__r.Customer_Number__c, ' + 
            'Bidder_Name__r.Bidder__r.Inactive__c, Bidder_Name__r.Bidder__r.Status__c, ' + 
            'Bidder_Name__r.Bidder__r.Name, Contact_Name__c, Bidder_Name__r.Contact__c FROM Quote_Bidder__c ' +           
            'where Quote__c = :recordId';

        List<Quote_Bidder__c> Bidders = Database.query(Query);
        return Bidders;    
    }

    @AuraEnabled
    public static List<RCA_Reason__c> getRCAReasons(String categoryId)
    {
        String Query = 'SELECT Name, Applicable_Reason_Codes__c ' +
        'FROM RCA_Category__c WHERE Inactive__c != true AND Id =:categoryId ' +
        'ORDER BY Name ASC';

        List<RCA_Category__c> RCACategories = Database.query(Query);
        
        String applicableReasonCodes = '';
        if(RCACategories != null && RCACategories.size() > 0)
        {
            if(RCACategories[0].Applicable_Reason_Codes__c != null)
                applicableReasonCodes = RCACategories[0].Applicable_Reason_Codes__c;

            String Query2 = '';
            
            if(applicableReasonCodes != null && applicableReasonCodes == 'ALL')
            {
                Query2 = 'SELECT Name, Id ' +
                'FROM RCA_Reason__c ' +
                ' ORDER BY Name ASC';
            }
            else {
                Query2 = 'SELECT Name, Id ' +
                'FROM RCA_Reason__c WHERE Reason_Code__c IN ' + applicableReasonCodes +
                ' ORDER BY Name ASC';
            }
            List<RCA_Reason__c> RCAReasons = Database.query(Query2);
            return RCAReasons;
        }
        else
            return new List<RCA_Reason__c>();    
    }

    @AuraEnabled
    public static Account getAccount(String accountId)
    {
        List<Account> accounts = [SELECT Payment_Terms__c, Id, Available_Credit__c, Customer_Number__c, Collector__r.Email, BillingCountry
                             FROM Account WHERE Id = :accountId LIMIT 1];
        
        if(accounts != null && accounts.size() > 0)
            return accounts[0];     
        else {
            return null;
        }
    }

    @AuraEnabled
    public static List<RCA_Category__c> getRCACategories()
    {
        String Query =  'SELECT Name, Id ' +
        'FROM RCA_Category__c WHERE Inactive__c != true ' +
        'ORDER BY Name ASC';

        List<RCA_Category__c> RCACategories = Database.query(Query);
        return RCACategories;    
    }

    @AuraEnabled
    public static String getOrderNumber(String invoiceNumber)
    {
        List<Invoice__c> Invoices =  [SELECT Order__r.NetSuite_TranId__c
                         FROM Invoice__c WHERE Name = :invoiceNumber LIMIT 1];

        if(Invoices != null && Invoices.size() > 0)
            return Invoices[0].Order__r.NetSuite_TranId__c;
        else
            return '';    
    }

    @AuraEnabled
    public static List<RetrievedContract> getContract(String quoteId, String accountId)
    {
        String Query = 'SELECT Inpro_Contract__c, Inpro_Contract__r.Name, Inpro_Contract__r.Account__r.Customer_Number__c, Inpro_Contract__r.Original_PO_Contract_No__c, Inpro_Contract__r.Status__c, Inpro_Contract__r.Payment_Terms__c ' +
                       'FROM Contract_Version__c ' +
                       'WHERE Quote__c = :quoteId AND Inpro_Contract__r.Account__c = :accountId';

        String Query2 = 'SELECT Inpro_Contract__c, Inpro_Contract__r.Name, Inpro_Contract__r.Account__r.Customer_Number__c, Inpro_Contract__r.Original_PO_Contract_No__c, Inpro_Contract__r.Status__c, Inpro_Contract__r.Payment_Terms__c ' +
                        'FROM Quote ' +
                        'WHERE Id = :quoteId';

        List<Contract_Version__c> contractVersions = Database.query(Query);
        List<RetrievedContract> contracts = new List<RetrievedContract>();
        List<String> contractIds = new List<String>();
        if(contractVersions.size() > 0)
        {
            for(Contract_Version__c cv : contractVersions)
            {
                if(!contractIds.contains(cv.Inpro_Contract__c))
                {
                    contractIds.add(cv.Inpro_Contract__c);
                    RetrievedContract c = new RetrievedContract();
                    c.PONumber = cv.Inpro_Contract__r.Original_PO_Contract_No__c;
                    if(cv.Inpro_Contract__r.Payment_Terms__c != null)
                        c.paymentTerms = cv.Inpro_Contract__r.Payment_Terms__c;
                    c.Id = cv.Inpro_Contract__c;
                    c.Name = cv.Inpro_Contract__r.Name;
                    c.CustomerNumber = cv.Inpro_Contract__r.Account__r.Customer_Number__c;
                    if(cv.Inpro_Contract__r != null && cv.Inpro_Contract__r.Status__c != null && cv.Inpro_Contract__r.Status__c != 'Activated')
                        c.isExecuted = false;
                    else {
                        c.isExecuted = true;
                    }
                    contracts.add(c);
                }
            }
        }
        else 
        {
            List<Quote> quotes = Database.query(Query2);            
            Quote q  = quotes[0];            
            if(q.Inpro_Contract__c != null)
            {
                RetrievedContract c = new RetrievedContract();
                c.PONumber = q.Inpro_Contract__r.Original_PO_Contract_No__c;
                if(q.Inpro_Contract__r.Payment_Terms__c != null)
                    c.paymentTerms = q.Inpro_Contract__r.Payment_Terms__c;
                c.Id = q.Inpro_Contract__c;
                c.Name = q.Inpro_Contract__r.Name;
                c.CustomerNumber = q.Inpro_Contract__r.Account__r.Customer_Number__c;
                if(q.Inpro_Contract__r != null && q.Inpro_Contract__r.Status__c != null && q.Inpro_Contract__r.Status__c != 'Activated')
                        c.isExecuted = false;
                else {
                    c.isExecuted = true;
                }
                contracts.add(c);            
            }
        }
        return contracts;    
    }
    
    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> contractSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = searchTerm + '%';        
        String accountId = secondarySearchTerm;

        string Query =  'SELECT Id, Name, Account__r.Customer_Number__c FROM Contract__c WHERE Name LIKE :key and Account__c = :accountId  LIMIT 50';       

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String contractIcon = 'standard:account';

        List<Contract__c> contracts = Database.query(Query);
        if(contracts.size() > 0)
        {
            for(Contract__c c : contracts)
            {
                String contractName = c.Name;            
                String contractId = c.Id;
                String subtitle = c.Account__r.Customer_Number__c;
                results.add(new LookupSearchResult(contractId, 'Contract__c', contractIcon, contractName, subtitle));
            }
        }
        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> contactSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';        
        String accountId = secondarySearchTerm;

        string Query =  'SELECT Account_Name__c, Id, Name FROM contact WHERE (Account_Name__c like :key or Name LIKE :key) AND Id IN (SELECT ContactId FROM AccountContactRelation WHERE AccountId = :accountId AND IsActive = true)  LIMIT 50';       

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String contactIcon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String contactName = (String)so.get('Name');            
            String contactId = (String)so.get('Id');
            String subtitle = (String)so.get('Account_Name__c');
            results.add(new LookupSearchResult(contactId, 'contact', contactIcon, contactName, ' - ' + subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List<QuoteLineItem> validateCustomProducts(string quoteId)
    {
       List<QuoteLineItem> quoteLines =  [SELECT Item_Number__c, Id FROM QuoteLineItem
                                            WHERE QuoteId = :quoteId
                                            AND Custom_Part_Number__c = null 
                                            AND (Item_Number__c LIKE '%CUSTOM%')];
       return quoteLines;     
    }

    @AuraEnabled
    public static string willOrderExceedContractedAmount(decimal orderAmount, string customerNumber, string poNumber, string contractId, string division) 
    {  
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        return service.WillOrderExceedContractedAmount(orderAmount,customerNumber,poNumber,contractId,division,'dsj8U73_3nv3Dhba');  
    }

    @AuraEnabled
    public static Boolean isAccountOnCreditHOld(string customerNumber) 
    {        
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        return service.IsAccountOnCreditHold(customerNumber, 'dsj8U73_3nv3Dhba');  
    }

    @AuraEnabled
    public static string updateBulkPackagingTask(String recordId, String userId, String status, String comments)
    {
        //check to see if the order exists in NetSuite
        string result = '';
        string orderRequestId = '';
        String Query =  'SELECT Id, Order_Request__c ' +
        'FROM Bulk_Packaging_Task__c WHERE Id =:recordId ';

        List<Bulk_Packaging_Task__c> bulkPackagingTasks = Database.query(Query);
        if(bulkPackagingTasks != null && bulkPackagingTasks.size() > 0)
        {
            Bulk_Packaging_Task__c task = (Bulk_Packaging_Task__c)bulkPackagingTasks[0];
            if(task.Order_Request__c != null)
                orderRequestId = task.Order_Request__c;
        }

        if(orderRequestId == '')
            return 'Error: The bulk packaging task has a blank order request.';

        if(status != null && status == 'Bulk Packaging Accepted')
        {
            sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
            service.timeout_x = 120000;
            result = service.RunBulkPackagingNetSuiteLogic(orderRequestId, 'dsj8U73_3nv3Dhba');
        }

        if(!result.contains('Error:'))
        {
            Bulk_Packaging_Task__c bpTask = new Bulk_Packaging_Task__c();
            bpTask.Id = recordId;
            bpTask.Processed_By__c = userId;
            bpTask.Processed_On__c = Datetime.now();
            bpTask.Processing_Comments__c = comments;
            bpTask.Status__c = status;
            update bpTask;
        }       

        return result;    
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> buildingOwnerSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';        

        string Query =  'SELECT Id, Name, Customer_Number__c FROM Account WHERE RecordType.Name = \'Building Owner\' and (Name LIKE :key OR Customer_Number__c LIKE :key) LIMIT 50';       

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String accountIcon = 'standard:account';
        for (sObject so: Database.Query(Query)) {

            String accountName = (String)so.get('Name');            
            String accountId = (String)so.get('Id');
            String subtitle = (String)so.get('Customer_Number__c');
            results.add(new LookupSearchResult(accountId, 'account', accountIcon, accountName, ' - ' + subtitle));
        }

        // sort all results on name
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable = true)
    public static List <LookupSearchResult> buildingOwnerParentSearch(String searchTerm, String secondarySearchTerm, List <String> selectedIds) {
        // Prepare query paramters
        String key = '%' + searchTerm + '%';        

        string Query =  'SELECT ParentId, Parent.Name parentName, Parent.Customer_Number__c customerNumber FROM Account WHERE RecordType.Name = \'Building Owner\' and ';
               Query += 'ParentId != null and (Parent.Name LIKE :key OR Parent.Customer_Number__c LIKE :key) ';
               Query += 'GROUP BY ParentId, Parent.Name, Parent.Customer_Number__c LIMIT 50';       

        // Prepare results
        List<LookupSearchResult> results = new List < LookupSearchResult > ();

        String accountIcon = 'standard:account';

        List<AggregateResult> accounts = Database.query(Query);
        if(accounts.size() > 0)
        {
            for(AggregateResult a : accounts)
            {
                String accountName = string.valueOf(a.get('parentName'));         
                String accountId = string.valueOf(a.get('ParentId')); 
                String subtitle = string.valueOf(a.get('customerNumber')); 
                results.add(new LookupSearchResult(accountId, 'account', accountIcon, accountName, ' - ' + subtitle));
            }
        }

        // sort all results on name
        results.sort();

        return results;
    }

    public class RequestOrder {
        @AuraEnabled
        public Boolean CreditApproval {get;set;}
        @AuraEnabled
        public Boolean SameDayOrder {get;set;}
        @AuraEnabled
        public Boolean NoChargeOrder {get;set;}
        @AuraEnabled
        public Boolean InvoiceDetail {get;set;}
        @AuraEnabled
        public string PO {get;set;}
        @AuraEnabled
        public string RepNumber {get;set;}
        @AuraEnabled
        public string NationalAccount {get;set;}
        @AuraEnabled
        public string ShippingInstructions {get;set;}
        @AuraEnabled
        public string InstallerEmail {get;set;}        
        @AuraEnabled
        public string OriginalOrderNumber {get;set;}
        @AuraEnabled
        public string OriginalInvoiceNumber {get;set;}
        @AuraEnabled
        public string ReasonCategory {get;set;}
        @AuraEnabled
        public string ReasonCode {get;set;}
        @AuraEnabled
        public string Explanation {get;set;}
        @AuraEnabled
        public Decimal OrderAmount {get;set;}
        @AuraEnabled 
        public string Bidder {get;set;}
        @AuraEnabled 
        public string ContractId {get;set;}
        @AuraEnabled 
        public string OrderInformation {get;set;}
        @AuraEnabled 
        public string ContactId {get;set;}
        @AuraEnabled 
        public string shipToName {get;set;}
        @AuraEnabled 
        public string endUserParentCustomerNumber {get;set;}
        @AuraEnabled
        public Boolean RequiresCustomParts {get;set;}
        @AuraEnabled
        public string shipToAddress1 {get;set;}
        @AuraEnabled
        public string shipToAddress2 {get;set;}
        @AuraEnabled
        public string shipToCity {get;set;}
        @AuraEnabled
        public string shipToContactName {get;set;}
        @AuraEnabled
        public string shipToContactPhoneNumber {get;set;}
        @AuraEnabled
        public string shipToCountry {get;set;}
        @AuraEnabled
        public string shipToState {get;set;}
        @AuraEnabled
        public string shipToZip {get;set;}
        @AuraEnabled
        public string oppOwnerManager {get;set;}
        @AuraEnabled
        public string oppOwner {get;set;}
        @AuraEnabled
        public string quoteOwner {get;set;}
        @AuraEnabled
        public string collectorEmail {get;set;}
        @AuraEnabled
        public string selectedAlternateIdsString {get;set;}
        @AuraEnabled
        public string buildingOwnerId {get;set;}
        @AuraEnabled
        public string buildingOwnerParentId {get;set;}
        @AuraEnabled
        public string opportunityId {get;set;}
        @AuraEnabled
        public Boolean bypassBuildingOwner {get;set;}
    }

    public class RetrievedContract
    {
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string Name {get;set;}
        @AuraEnabled
        public string CustomerNumber {get;set;}
        @AuraEnabled
        public string PONumber {get;set;}
        @AuraEnabled
        public Boolean isExecuted {get;set;}
        @AuraEnabled
        public string paymentTerms {get;set;}
    }

    public class AlternateDetail
    {
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string name {get;set;}
        @AuraEnabled
        public decimal sequenceNumber {get;set;}
        @AuraEnabled
        public decimal totalMaterial {get;set;}
        @AuraEnabled
        public decimal freightAmount {get;set;}
        @AuraEnabled
        public decimal totalTax {get;set;}
        @AuraEnabled
        public decimal totalInclFreightTax {get;set;}
        @AuraEnabled
        public decimal totalInclFreightNoTax {get;set;}
        @AuraEnabled
        public Boolean bulkPackagable {get;set;}
        @AuraEnabled       
        public string bulkPackageItems {get; set;}
    }

    public class BulkPackageDetail
    {
        @AuraEnabled
        public string bulkPackageGroup {get;set;}
        @AuraEnabled
        public decimal bulkPackageGroupQty {get;set;}
        @AuraEnabled
        public decimal qtyOnAlternate {get;set;}
        @AuraEnabled
        public string alternateId {get;set;}
        @AuraEnabled
        public string itemNumbers {get;set;}
    }
}