public without sharing class SubstitutionRequestController {
    public User loggedinUser { get; set; }
    public string errormsg { get; set; } // Holds the error message.
    //public Opportunity objopportunity{get;set;} //Reference of opportunity to display in the vf page
    public Construction_Project__c objConstruction { get; set; } //Reference of Construction_Project__c to display in the vf page
    public list<WrapDoc> lstDocTodownload;
    public Attachment objCoversheetDoc; // To add the Substitution Request a Attachment to Coreesponding Construction_Project__c.
    public Document objCoversheetDocument; // To add the Sustitution Request to the User specified folder under documents.
    public List<SubstitutionRequestWrapClass> subRequestWrapList { get; set; }
    public List<SubstitutionRequestWrapClass> selectedSubLineWrappers { get; set; }
    public boolean showSubstitutionReq { get; set; }
    public boolean noSubstitutionReq { get; set; }
    public boolean hideButtons { get; set; }
    transient list<ContentVersion> contentVersionList;
    Set<Id> contDocIDs = new Set<Id>();
    public integer totSubReqCount { get; set; }
    public string url { get; set; }
    public integer lastindexofSubReq { get; set; }
    public boolean isViewDocuments { get; set; }
    public string DownloadText { get; set; }
    //public string downloadFileId{get;set;}
    public Map<String, ContentDistribution> publicLinks { get; set; }
    public map<String, WrapProductFiles> prodBrandDocMap = new Map<String, WrapProductFiles>();
    
    public string supportingDocumentsLink { get; set; }  
    
    //This method is used to Download  the  Documents to user System.
    public PageReference InsertCoverDoc() {
        Id objdocid;
        // System.debug('contDocIDs@@'+contDocIDs);
        objdocid = RedirectId();
        // System.debug('objdocid'+objdocid);
        PageReference page11 = new PageReference('/servlet/servlet.FileDownload?file=' + objdocid);
        page11.setRedirect(true);
        system.debug('page11'+page11);
        isViewDocuments = true;
        return null;
    }
    
    public PageReference downloadSupportingDocuments(){
        PageReference page11 = new PageReference(supportingDocumentsLink);
        system.debug('page11'+page11);
        return page11;
    }
    
    public string CompPhone { get; set; }
    public string CompAddress { get; set; }
    public string CompName { get; set; }
    public string CompCityStateZip { get; set; }
    
    // Constructor
    public SubstitutionRequestController() {
        // load in our metadata strings for company info
        CompName = HunleyUtils.GetMetadataValue(HunleyUtils.COMPANY_NAME);
        CompAddress = HunleyUtils.GetMetadataValue(HunleyUtils.COMPANY_ADDRESS);
        CompPhone = HunleyUtils.GetMetadataValue(HunleyUtils.COMPANY_PHONE);
        CompCityStateZip = HunleyUtils.GetMetadataValue(HunleyUtils.COMPANY_CITYSTATEZIP);
        
        isViewDocuments = false;
        loggedinUser = [
            SELECT
            Id,
            ContactId,
            LastName,
            FirstName,
            CompanyName,
            Title,
            Street,
            State,
            City,
            PostalCode,
            Country,
            Email,
            Phone
            FROM User
            WHERE Id = :Userinfo.getUserId()
            LIMIT 1
        ];
        string ConstructionId = ApexPages.currentPage().getParameters().get('id'); //getting the opportunity from query parameter.
        
        if (ApexPages.currentPage().getParameters().containsKey('hide')) {
            hideButtons = true;
        } else {
            hideButtons = false;
        }
        
        subRequestWrapList = new List<SubstitutionRequestWrapClass>();
        showSubstitutionReq = false;
        noSubstitutionReq = false;
        String selectedIds = ApexPages.currentPage().getParameters().get('selectedids');
        List<String> selectedIdsSet = new List<String>();
        if (selectedIds != '' && selectedIds != null) {
            if (selectedIds.contains(',')) {
                selectedIdsSet = selectedIds.split(',');
            } else {
                selectedIdsSet.add(selectedIds);
            }
        }
        
        if (ConstructionId != null) {
            this.getConstructionProjectRecord(ConstructionId);
            List<Substitution_Line_Item__c> subReqSpecLineList = new List<Substitution_Line_Item__c>();
            if (
                loggedinUser.ContactId == null ||
                (loggedinUser.ContactId != null &&
                 selectedIdsSet.size() == 0)
            ) {
                subReqSpecLineList = [
                    SELECT
                    Name,
                    Product_FamilyG__c,
                    Project_Specification_Article_Paragraph__c,
                    Specification_Status__c,
                    Competing_Product_Basis_of_Design__c,
                    Project_Specification_Page_Number__c,
                    Project_Specification_Title__c,
                    Project_Specification_Description__c,
                    Status__c,
                    Substitution_Status__c,
                    ANSI_Category__c,
                    Competors_Product_to_be_Substituted__c,
                    Competitors_Listed_All__c,
                    Substitute_Product_1__c,
                    Substitute_Product_1__r.Name,
                    Substitute_Product_2__c,
                    Substitute_Product_2__r.Name,
                    Project_Specification_Section_Number__c,
                    Sales_Rep__c,
                    Sales_Team__c
                    FROM Substitution_Line_Item__c
                    WHERE
                    ConstructionProject__c = :ConstructionId
                    AND (Specification_Status__c LIKE '%not Included%'
                         OR Specification_Status__c LIKE '%Performance Specification, Manufacturer Not Identified%')
                ];
                lastindexofSubReq = subReqSpecLineList.size() - 1;
            } else {
                subReqSpecLineList = [
                    SELECT
                    Name,
                    Product_FamilyG__c,
                    Project_Specification_Article_Paragraph__c,
                    Competing_Product_Basis_of_Design__c,
                    Specification_Status__c,
                    Project_Specification_Page_Number__c,
                    Project_Specification_Title__c,
                    Project_Specification_Description__c,
                    Substitution_Status__c,
                    Status__c,
                    ANSI_Category__c,
                    Competors_Product_to_be_Substituted__c,
                    Competitors_Listed_All__c,
                    Substitute_Product_1__c,
                    Substitute_Product_1__r.Name,
                    Substitute_Product_2__c,
                    Substitute_Product_2__r.Name,
                    Project_Specification_Section_Number__c,
                    Sales_Rep__c,
                    Sales_Team__c
                    FROM Substitution_Line_Item__c
                    WHERE
                    ConstructionProject__c = :ConstructionId
                    AND ID IN :selectedIdsSet
                    AND (Specification_Status__c LIKE '%not Included%'
                         OR Specification_Status__c LIKE '%Performance Specification, Manufacturer Not Identified%')
                ];
                lastindexofSubReq = subReqSpecLineList.size() - 1;
            }
            for (Substitution_Line_Item__c subItem : subReqSpecLineList) {
                SubstitutionRequestWrapClass subLineWrapper = new SubstitutionRequestWrapClass();
                subLineWrapper.subRequestRec = subItem;
                subLineWrapper.isSelected = true;
                subLineWrapper.signer = this.getSubLineSigner(subItem);
                subRequestWrapList.add(subLineWrapper);
            }
            
            //Check Validations and Preparing the required Error Messages.
            if (
                objConstruction.Architect_Contact__c == null ||
                objConstruction.Architect_Contact__r.email == null
            ) {
                errormsg = 'The Architect PM must be filled in and that contact must have a valid email address before the substitution request can be completed.';
            } else if (objConstruction.Architect_Contact__r.email == null) {
                errormsg = 'The Architect PM must be filled in and that contact must have a valid email address before the substitution request can be completed.';
            }
        }
        totSubReqCount = subRequestWrapList.size();
        if (subRequestWrapList.size() == 0)
            ApexPages.AddMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Please add at least one Substitution Request line item to this Project first.'
                )
            );
        
        if (loggedinUser.ContactId != null && selectedIdsSet.size() > 0) {
            if (subRequestWrapList != null && subRequestWrapList.size() > 0) {
                showSubstitutionReq = true;
                showSubstitutionPage();
            } else {
                showSubstitutionReq = false;
            }
        }
    }
    //end of Constructor
    
    private void getConstructionProjectRecord(String cpId) {
        system.debug('cpId'+cpId);
        objConstruction = [
            SELECT
            Id,
            OwnerId,
            Name,
            Architect_Firm__c,
            Owner.Email,
            Architect_Contact__c,
            Architect_Contact__r.email,
            Architect_Contact__r.LastName,
            Architect_Contact__r.FirstName,
            City__c,
            State__c,
            ZIP_or_Postal_Code__c,
            Country__c,
            Project_Owner_Company__c,
            Internal_Status__c,
            Architect_Contact__r.Account.name,
            Public_Links__c,
            Architect_Contact__r.phone,
            Owner.Name,
            Owner.Phone,
            Owner_City__c,
            OwnerCompanyName__c,
            OwnerPostalCode__c,
            OwnerState__c,
            OwnerStreet__c,
            Project_Owner_Company__r.Name,
            A_E_Project_Number__c,Substitution_Message_To_Arch__c
            FROM Construction_Project__c
            WHERE id = :cpId
        ];
    }
    
    private User getSubLineSigner(Substitution_Line_Item__c subLine) {
        User signer;
        User manRep = this.getUserRecord(objConstruction.OwnerId);
        if (manRep.FirstName != 'Mark' && manRep.LastName != 'Rounds') {
            signer = manRep;
        } else {
            User salesRep = this.getRepForSpecLine(subLine);
            if (salesrep != null) {
                signer = salesRep;
            } else {
                signer = loggedinUser;
            }
        }
        return signer;
    }
    
    private User getRepForSpecLine(Substitution_Line_Item__c subLine) {
        User salesRep;
        String salesTeam = subLine.Sales_Team__c;
        Sales_Team_Field_Automation_Mapping__c fieldMap = this.getSalesTeamFieldMap(salesTeam);
        if (fieldMap != null) {
            String repFieldName = fieldMap.Construction_Project_Rep_Field__c;
            Id repId = (Id) objConstruction.get(repFieldName);
            if (repId != null) {
                salesRep = this.getUserRecord(repId);
            }
        }
        return salesRep;
    }
    
    private Sales_Team_Field_Automation_Mapping__c getSalesTeamFieldMap(String salesTeam) {
        Sales_Team_Field_Automation_Mapping__c fieldMap = [
            SELECT
            Id,
            Sales_Team__c,
            Construction_Project_Rep_Field__c,
            Construction_Project_Team_Field__c
            FROM Sales_Team_Field_Automation_Mapping__c
            WHERE Sales_Team__c = :salesTeam
            LIMIT 1
        ];
        return fieldMap;
    }
    
    // Gets the Download link and Saves the Sustitution Request as Attachment and Document.
    public Id RedirectId() {
        isViewDocuments = true;
        hideButtons = true;
        try {
            DownloadText = 'Documents to Download';
            
            if (objCoversheetDoc == null) {
                PageReference pdf;
                if (loggedinUser.ContactId == null) {
                    pdf = Page.SubstitutionRequest;
                    pdf.getParameters().put('id', objConstruction.id);
                    pdf.getParameters().put('hide', '1');
                } else {
                    String selectedIdstoPage = '';
                    for (SubstitutionRequestWrapClass sReqSelPage : selectedSubLineWrappers) {
                        selectedIdstoPage = selectedIdstoPage + sReqSelPage.subRequestRec.ID + ',';
                    }
                    if (selectedIdstoPage != null) {
                        selectedIdstoPage = selectedIdstoPage.removeEnd(',');
                    }
                    pdf = new PageReference(
                        '/Agents/apex/SubstitutionRequest?hide=1&id=' +
                        objConstruction.id +
                        '&selectedids=' +
                        selectedIdstoPage
                    );
                }
                
                pdf.setRedirect(true);
                Blob b;
                if (!test.isRunningTest()) {
                    b = pdf.getContentASPdf();
                } else {
                    b = blob.valueof('Test Body');
                }
                
                SaveDocument(b, objConstruction);
                if (selectedSubLineWrappers != null && selectedSubLineWrappers.size() > 0) {
                    for (SubstitutionRequestWrapClass sReq : selectedSubLineWrappers) {
                        if (sReq.wrapDocList == null) {
                            sReq.wrapDocList = new List<WrapDoc>();
                        }
                        WrapDoc wDoc = new WrapDoc();
                        wDoc.Docname = objCoversheetDoc.Name.remove('.pdf');
                        wDoc.Docid = objCoversheetDoc.Id;
                        wDoc.DocUniqName = objCoversheetDoc.Name;
                        sReq.wrapDocList.add(wDoc);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception is :: ' + e);
            System.debug('Exception is :: ' + e.getLineNumber());
        }
        url = '/servlet/servlet.FileDownload?file=' + objCoversheetDoc.Id;
        return objCoversheetDoc.Id;
    }
    
    public pagereference SendEmailToArchitect() {
        pagereference ref;
        
        publicLinks = new Map<String, ContentDistribution>();
        Map<String, ContentDistribution> existingLinks = new Map<String, ContentDistribution>();
        Set<Id> subReqIDs = new Set<Id>();
        Set<Id> contentVersionIds = new Set<Id>();
        contentVersionList = new List<ContentVersion>();
        string sendTo = Apexpages.currentPage().getParameters().get('emailTo');
        system.debug('sendTo'+sendTo);
        try {
            Messaging.EmailFileAttachment attach; //= new Messaging.EmailFileAttachment();
            list<Messaging.EmailFileAttachment> lstAttach = new List<Messaging.EmailFileAttachment>();
            
            Blob b;
            
            // build our filename, honoring 100 character limit:
            // set our filename and make sure it remains 100 chars or less....
            string fname = 'Substitution Request - ' + objConstruction.name;
            if (fname.length() > 96) {
                fname = fname.substring(0, 96);
            }
            fname = fname + '.pdf';
            
            if (objCoversheetDoc != null) {
                attach = new Messaging.EmailFileAttachment();
                
                attach.setFileName(fname);
                attach.setBody(objCoversheetDoc.body);
                lstAttach.add(attach); //adding coversheet
            } else {
                PageReference pdf;
                if (loggedinUser.ContactId == null) {
                    pdf = Page.SubstitutionRequest;
                    pdf.getParameters().put('id', objConstruction.id);
                } else {
                    String selectedIdstoPage = '';
                    for (SubstitutionRequestWrapClass sReqSelPage : selectedSubLineWrappers) {
                        selectedIdstoPage = selectedIdstoPage + sReqSelPage.subRequestRec.ID + ',';
                    }
                    if (selectedIdstoPage != null)
                        selectedIdstoPage = selectedIdstoPage.removeEnd(',');
                    pdf = new PageReference(
                        '/Agents/apex/SubstitutionRequest?id=' +
                        objConstruction.id +
                        '&selectedids=' +
                        selectedIdstoPage
                    );
                }
                pdf.setRedirect(true);
                //Take the PDF content
                if (!test.IsRunningTest()) {
                    b = pdf.getContentAspdf();
                } else {
                    b = blob.valueof('test body');
                }
                //Create coversheet pdf as the email attachment
                attach = new Messaging.EmailFileAttachment();
                attach.setFileName(fname);
                attach.setBody(b);
                lstAttach.add(attach); //adding coversheet to email
                
                for (String mapKey : existingLinks.keySet()) {
                    System.debug('key: ' + mapKey);
                    System.debug('link: ' + existingLinks.get(mapKey));
                }
            }
            ContentVersion coverSheetVersion = new ContentVersion();
            coverSheetVersion.Title = fname;
            coverSheetVersion.VersionData = attach.body;
            coverSheetVersion.pathOnClient = fname;
            insert coverSheetVersion;
            
            ContentVersion coverSheetVersionObj = [
                SELECT Id, Title, ContentDocumentId, ContentUrl, ContentBodyId, FileType, VersionData
                FROM ContentVersion
                WHERE Id = :coverSheetVersion.id
            ];
            
            ContentDistribution cdu1 = new ContentDistribution(
                ContentVersionId = coverSheetVersionObj.Id,
                PreferencesNotifyOnVisit = false,
                RelatedRecordId = ApexPages.currentPage().getParameters().get('id'),
                Name = coverSheetVersionObj.Title
            );
            insert cdu1;
            cdu1 = [
                SELECT DistributionPublicUrl, Name
                FROM ContentDistribution
                WHERE Id = :cdu1.Id
                LIMIT 1
            ];
            system.debug('cdu1.DistributionPublicUrl' + cdu1.DistributionPublicUrl);
            for (ContentVersion contVer : [
                SELECT id, VersionData, FileType, ContentSize, ContentDocumentId, ContentDocument.title
                FROM ContentVersion
                WHERE IsLatest = true AND ContentDocumentId IN :contDocIDs
            ]) {
                contentVersionList.add(contVer);
                contentVersionIds.add(contVer.Id);
                system.debug('prodBrandDocMap' + prodBrandDocMap);
            }
            system.debug('prodBrandDocMap' + prodBrandDocMap);
            for (SubstitutionRequestWrapClass wrapListItem : selectedSubLineWrappers) {
                subReqIDs.add(wrapListItem.subRequestRec.Id);
            }
            
            for (ContentDistribution existingCDU : [
                SELECT Id, RelatedRecordId, ContentVersionId, Name, DistributionPublicURL
                FROM ContentDistribution
                WHERE ContentVersionId IN :contentVersionIds AND RelatedRecordId IN :subReqIDs
            ]) {
                //existingLinks.put(String.valueOf(existingCDU.ContentVersionId) + String.valueOf(existingCDU.RelatedRecordId), existingCDU);
                existingLinks.put(String.valueOf(existingCDU.ContentVersionId), existingCDU);
            }
            
            system.debug('contentVersionList' + contentVersionList);
            system.debug('existingLinks' + existingLinks);
            for (SubstitutionRequestWrapClass sReq : selectedSubLineWrappers) {
                for (WrapDoc wDoc : sReq.wrapDocList) {
                    for (ContentVersion cVer : contentVersionList) {
                        //String existingKey = String.valueOf(wDoc.DocVersionId) + String.valueOf(sReq.subRequestRec.Id);
                        String existingKey = String.valueOf(wDoc.DocVersionId);
                        System.debug('check existing key: ' + existingKey);
                        if (!existingLinks.containsKey(existingKey)) {
                            ContentDistribution cdu = new ContentDistribution(
                                ContentVersionId = wDoc.DocVersionId,
                                PreferencesNotifyOnVisit = false,
                                RelatedRecordId = sReq.subRequestRec.Id,
                                Name = wDoc.DocUniqName
                            );
                            publicLinks.put(existingKey, cdu);
                        } else {
                            publicLinks.put(existingKey, existingLinks.get(existingKey));
                        }
                    }
                }
            }
            
            System.debug('create links');
            
            for (ContentDistribution cduLink : publicLinks.values()) {
                System.debug('link value: ' + cduLink);
            }
            
            upsert publicLinks.values();
            
            String links = '';
            
            for (ContentDistribution publicLink : [
                SELECT Id, Name, ContentVersionId, ContentDocumentId, DistributionPublicURL
                FROM ContentDistribution
                WHERE Id IN :publicLinks.values()
            ]) {
                for (string name : prodBrandDocMap.keySet()) {
                    WrapProductFiles wpf = prodBrandDocMap.get(name);
                    for (AttachmentProductFiles attchProdFiles : wpf.attchFiles) {
                        if (attchProdFiles.DocumentId == publicLink.ContentDocumentId) {
                            attchProdFiles.Links =
                                '<li><a href="' +
                                publicLink.DistributionPublicURL +
                                '">' +
                                publicLink.Name +
                                '</a></li>';
                        }
                    }
                }
            }
            
            for (string name : prodBrandDocMap.keySet()) {
                links += '<p><b>Suggested Substitute: ' + name + '</b></p>';
                links += '<p>Supporting Documentation:</p>';
                links += '<ul>';
                WrapProductFiles wpf = prodBrandDocMap.get(name);
                for (AttachmentProductFiles attchProdFiles : wpf.attchFiles) {
                    links += attchProdFiles.Links;
                }
                for (Document_Link__c extProdFiles : wpf.extFiles) {
                    links += '<li><a href="' +
                        extProdFiles.Document_URL__c +
                        '">' +
                        extProdFiles.Name +
                        '</a></li>';
                }
                links += '</ul>';
            }
            
            if (!String.isBlank(links)) {
                links += '</ul>';
            }
            system.debug('cdu1' + cdu1);
            string coverUrl =
                '<p style="font-size:1.2em;"><b>Substitution Request Summary:</b> <a href="' +
                cdu1.DistributionPublicURL +
                '">' +
                cdu1.Name +
                '</a></p>';
            system.debug('coverUrl' + coverUrl);
            system.debug('links' + links);
            objConstruction.Cover_Doc_Link__c = coverUrl;
            objConstruction.Public_Links__c = links;
            update objConstruction;
            system.debug('prodBrandDocMap' + prodBrandDocMap);
            //Cannot create ContentVersion from Test Class
            if (Test.isRunningTest()) {
            }
            

            
            //preparing mail
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            //getting the current user information to send cc mail
            // User objUser = [SELECT id, Name, email FROM User WHERE id = :Userinfo.getUserid()];
            
            String cpName = this.getParagraphHTML(objConstruction.Name);
            String cpCoverDocLink = this.getParagraphHTML(objConstruction.Cover_Doc_Link__c);
            String cpPublicLinks = this.getParagraphHTML(objConstruction.Public_Links__c);
            String cpMessageToArchs = this.getParagraphHTML(
                objConstruction.Substitution_Message_To_Arch__c
            );
            
          
            User emailSender = this.getEmailSender();
            String signature = this.buildEmailSignature(emailSender);
            String subject = this.getEmailSubject(objConstruction.Name);
            
            List<String> ccAddresses = this.getEmailCCAddresses(objConstruction);
            
            EmailTemplate SubReqTemplate = this.getEmailTemplate(
                'Substitution_Request_to_Architects_Custom'
            );
            String mailBody = SubReqTemplate.HtmlValue;
            mailBody = mailBody.replace('###CPNAME###', cpName);
            mailBody = mailBody.replace('###CPCOVERDOCLINK###', cpCoverDocLink);
            mailBody = mailBody.replace('###CPPUBLICLINKS###', cpPublicLinks);
            mailBody = mailBody.replace('###CPMESSAGETOARCHITECTS###', cpMessageToArchs);
            mailBody = mailBody.replace('###SIGNATURE###', signature);
            mail.setHtmlBody(mailBody);
            mail.setPlainTextBody(mailBody);
            mail.setSubject(subject);
            if(sendTo == 'Architect'){
                mail.setSaveAsActivity(true);
                mail.setTargetobjectid(objConstruction.Architect_Contact__c);
            }
            else
            {
                mail.setSaveAsActivity(false);
                mail.setTargetobjectid(UserInfo.getUserId());
            }
                
            mail.setWhatId(objConstruction.id);
            mail.setBccSender(false);
            
            //mail.setCcAddresses(ccAddresses);
            mail.setReplyTo(emailSender.Email);
            mail.setSenderDisplayName(emailSender.FirstName + ' ' + emailSender.LastName);
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail }); //sending the mail
            
            //updating opportunity stage with the metadata value defined
            objConstruction.Internal_Status__c = HunleyUtils.GetMetadataValue(
                HunleyUtils.CONPROJ_STATUS_TRANSITION
            );
            
            update objConstruction;
            List<Substitution_Line_Item__c> updateSubReqList = new List<Substitution_Line_Item__c>();
            for (SubstitutionRequestWrapClass sReq : selectedSubLineWrappers) {
                Substitution_Line_Item__c subReqRec = sReq.subRequestRec;
                subReqRec.Substitution_Status__c = 'Submitted';
                subReqRec.Status__c = 'Substitution Submitted, Pending';
                updateSubReqList.add(subReqRec);
            }
            if (!updateSubReqList.isEmpty()) {
                update updateSubReqList;
            }
            
            //deleting the document
            if (objCoversheetDoc != null) {
                delete objCoversheetDoc;
            }
            //return to opportunity from where we started
            ref = new pagereference('/' + objConstruction.id);
            
            return ref;
        } catch (Exception e) {
            //try
            if (e.getmessage().contains('Bounced')) {
                ApexPages.AddMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Send Email Failed due to Email Address Bounced. So please check the Email address on' +
                        objConstruction.Architect_Contact__r.LastName +
                        'With Id ' +
                        objConstruction.Architect_Contact__c
                    )
                );
                system.debug('e.getmessage()' + e.getmessage());
            } else {
                String msg = e.getMessage() + '. Line: ' + e.getLineNumber();
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
                system.debug('e.getmessage()' + e.getmessage());
                system.debug('e.getLineNumber()' + e.getLineNumber());
            }
            return ref;
        } //catch
    }
    
    private EmailTemplate getEmailTemplate(String devName) {
        EmailTemplate et = [
            SELECT Id, DeveloperName, HtmlValue, Subject
            FROM EmailTemplate
            WHERE DeveloperName = :devName
            LIMIT 1
        ];
        return et;
    }
    
    private User getEmailSender() {
        User sender;
        if (selectedSubLineWrappers.size() > 0) {
            sender = selectedSubLineWrappers[0].signer;
        } else {
            sender = loggedinUser;
        }
        return sender;
    }
    
    private String buildEmailSignature(User userRec) {
        String signature = '<p>';
        List<String> nameLine = new List<String>{ userRec.FirstName + ' ' + userRec.LastName };
            signature = this.appendEmailSignature(signature, nameLine);
        
        List<String> companyLine = new List<String>{ userRec.CompanyName };
            signature = this.appendEmailSignature(signature, companyLine);
        
        List<String> addressLine = new List<String>{
            userRec.Street,
                userRec.City,
                userRec.State,
                userRec.PostalCode
                };
                    signature = this.appendEmailSignature(signature, addressLine);
        
        List<String> contactInfoLine = new List<String>{ userRec.Phone, userRec.Email };
            signature = this.appendEmailSignature(signature, contactInfoLine);
        
        signature += '</p>';
        return signature;
    }
    
    private String appendEmailSignature(String signature, List<String> inputs) {
        List<String> lineVals = new List<String>();
        String newLine = this.buildSignatureLine(inputs);
        if (this.stringNotEmpty(newLine)) {
            signature += newLine + '</br>';
        }
        return signature;
    }
    
    private String buildSignatureLine(List<String> inputs) {
        String result = '';
        Integer inputCount = inputs.size();
        for (Integer i = 0; i < inputCount; i++) {
            String val = inputs[i];
            if (this.stringNotEmpty(val)) {
                result += val;
                if (i != inputCount - 1) {
                    result += ' | ';
                }
            }
        }
        return result;
    }
    
    private String getEmailSubject(String cpName) {
        String subject = 'Substitution Request for products for ' + cpName;
        if (subject.length() > 80) {
            subject = subject.substring(0, 79);
        }
        return subject;
    }
    
    public String getParagraphHTML(String input) {
        String result = '';
        if (stringNotEmpty(input)) {
            result = '<p>' + input + '</p>';
        }
        return result;
    }
    
    public Boolean stringNotEmpty(String input) {
        Boolean notEmpty = true;
        if (input == null || input == '') {
            notEmpty = false;
        }
        return notEmpty;
    }
    
    public List<String> getEmailCCAddresses(Construction_Project__c objConstruction) {
        List<String> ccAddresses = new List<String>();
        
        // CC Riely on every sub req email
        ccAddresses.add('rjucius@thehunleygroup.com');
        
        // CC project owner on every sub req email
        if (objConstruction.Owner.Email != null) {
            ccAddresses.add(objConstruction.Owner.Email);
        }
        
        // CC all reps related to selected spec line items
        for (SubstitutionRequestWrapClass wrap : selectedSubLineWrappers) {
            User rep = wrap.signer;
            if (rep.Email != null && 
                !ccAddresses.contains(rep.Email)
               ) {
                   ccAddresses.add(rep.Email);
               }
        }
        return ccAddresses;
    }
    
    //This is to cancel sending Substitution request to Architect and navigate to opportunity detail page.
    public pagereference Cancel() {
        //deleting the document
        if (!test.isRunningTest() && objCoversheetDoc != null) {
            delete objCoversheetDoc;
        }
        return new Pagereference('/' + objConstruction.id);
    }
    
    public void showSubstitutionPage() {
        selectedSubLineWrappers = new List<SubstitutionRequestWrapClass>();
        Set<Id> prodBrandIds = new Set<Id>();
        for (SubstitutionRequestWrapClass sReq : subRequestWrapList) {
            if (sReq.isSelected) {
                selectedSubLineWrappers.add(sReq);
                if (sReq.subRequestRec.Substitute_Product_1__c != null) {
                    prodBrandIds.add(sReq.subRequestRec.Substitute_Product_1__c);
                }
                if (sReq.subRequestRec.Substitute_Product_2__c != null) {
                    prodBrandIds.add(sReq.subRequestRec.Substitute_Product_2__c);
                }
                showSubstitutionReq = true;
            }
        }
        if (showSubstitutionReq) {
            map<ID, set<ID>> mapObjectRelatedDocs = new Map<ID, set<ID>>();
            list<AttachedContentDocument> attContentDocList = new List<AttachedContentDocument>();
            //  String[] filters = new String[]{'%TDS','%MSDS'};
            list<Product_Brand__c> prodBrandList = [
                SELECT ID, Name, (SELECT Id, ContentDocumentId, Title FROM AttachedContentDocuments),
                (select Id,Name,Document_URL__c from Document_Links__r)
                FROM Product_Brand__c
                WHERE id IN :prodBrandIds
            ]; // where Title Like :filters
            System.debug('prodBrandList---->' + prodBrandList);
            for (Product_Brand__c P : prodBrandList) {
                WrapProductFiles wrapProductFileObj = new WrapProductFiles();
                List<AttachmentProductFiles> AttachmentProductFilesList = new List<AttachmentProductFiles>();
                attContentDocList = new List<AttachedContentDocument>();
                Set<Id> tempContDocIDs = new Set<Id>();
                attContentDocList.addAll(P.AttachedContentDocuments);
                
                List<Document_Link__c> ExternalProductFilesList = new List<Document_Link__c>();
                
                for (AttachedContentDocument conDoc : attContentDocList) {
                    contDocIDs.add(conDoc.ContentDocumentId);
                    tempContDocIDs.add(conDoc.ContentDocumentId);
                    AttachmentProductFiles attchProductFilesObj = new AttachmentProductFiles();
                    //map<Id,Id> testmap =new map<Id,Id>();
                    //testmap.put(conDoc.ContentDocumentId,null);
                    attchProductFilesObj.DocumentId = (conDoc.ContentDocumentId);
                    AttachmentProductFilesList.add(attchProductFilesObj);
                    system.debug('AttachmentProductFilesList' + AttachmentProductFilesList);
                }
                
                for (Document_Link__c extDoc : p.Document_Links__r) {
                    ExternalProductFilesList.add(extDoc);
                    system.debug('ExternalProductFilesList' + ExternalProductFilesList);
                }
                wrapProductFileObj.extFiles=ExternalProductFilesList;
                wrapProductFileObj.attchFiles=AttachmentProductFilesList;
                prodBrandDocMap.put(P.Name, wrapProductFileObj);
                mapObjectRelatedDocs.put(P.ID, tempContDocIDs);
            }
            map<Product_Brand__c, list<ContentVersion>> mapProductBrandContent = new Map<Product_Brand__c, list<ContentVersion>>();
            contentVersionList = [
                SELECT id, VersionData, FileType, ContentSize, ContentDocumentId, ContentDocument.title
                FROM ContentVersion
                WHERE IsLatest = true AND ContentDocumentId IN :contDocIDs
            ];
            
            
            supportingDocumentsLink='';
            for(ContentVersion cv:contentVersionList){
                supportingDocumentsLink=supportingDocumentsLink+'/'+cv.Id;
            }  
            supportingDocumentsLink='/sfc/servlet.shepherd/version/download'+supportingDocumentsLink+'?';
            
            system.debug('contentVersionList' + contentVersionList);
            for (SubstitutionRequestWrapClass wClass : selectedSubLineWrappers) {
                wClass.wrapDocList = new List<WrapDoc>();
                for (Product_Brand__c prodBrand : prodBrandList) {
                    if (
                        wClass.subRequestRec.Substitute_Product_1__c == prodBrand.Id ||
                        wClass.subRequestRec.Substitute_Product_2__c == prodBrand.Id
                    ) {
                        if (mapObjectRelatedDocs.get(prodBrand.Id) != null) {
                            for (ContentVersion cVer : contentVersionList) {
                                if (mapObjectRelatedDocs.get(prodBrand.Id).contains(cVer.ContentDocumentId)) {
                                    WrapDoc wDoc = new WrapDoc();
                                    wDoc.Docname = cVer.ContentDocument.title;
                                    wDoc.Docid = cVer.ContentDocumentId;
                                    wDoc.DocUniqName = cVer.ContentDocument.title;
                                    wDoc.DocVersionId = cVer.Id;
                                    wClass.wrapDocList.add(wDoc);
                                }
                            }
                        }
                    }
                }
            }
        } else {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.WARNING,
                    ' Please select atleast one substitution request record'
                )
            );
        }
    }
    
    private User getUserRecord(Id userID) {
        User userRec = [
            SELECT Id, FirstName, LastName, CompanyName, Street, City, State, PostalCode, Phone, Email
            FROM User
            WHERE Id = :userId
        ];
        return userRec;
    }
    // To Save the Document to the User Folder and attachment.
    public void SaveDocument(Blob pagecontent, Construction_Project__c Construction) {
        // build our filename, honoring 100 character limit:
        // set our filename and make sure it remains 100 chars or less....
        string fname = 'Substitution Request - ' + Construction.name;
        if (fname.length() > 96) {
            fname = fname.substring(0, 96) + '.pdf';
        }
        
        // To store the Substitution Request to the Specified Folder.
        Folder folderobj = [
            SELECT id, name
            FROM folder
            WHERE name = 'Substitution Supporting Documentation'
            LIMIT 1
        ];
        objCoversheetDocument = new Document();
        //  objCoversheetDocument .name = 'Substitution Request'+' '+ objopportunity.Substitution_Request_Number__c +'- Bostik '+ objopportunity .Substitution_Pdt_for_Submittal__c+'-'+objopportunity.name+'.pdf';
        
        objCoversheetDocument.name = fname;
        objCoversheetDocument.body = pagecontent;
        objCoversheetDocument.folderid = folderobj.id;
        insert objCoversheetDocument;
        system.debug('objCoversheetDocument.body' + objCoversheetDocument.body);
        
        // To store the Attachment to Opportunity Attachment.
        objCoversheetDoc = new Attachment();
        objCoversheetDoc.parentID = Construction.id;
        String subReqNumber = '';
        //if(objopportunity.Substitution_Request_Number__c != null)
        //subReqNumber = objopportunity.Substitution_Request_Number__c;
        objCoversheetDoc.Name = fname + '.pdf';
        objCoversheetDoc.body = pagecontent;
        insert objCoversheetDoc;
    }
    
    public class SubstitutionRequestWrapClass {
        public boolean isSelected { get; set; }
        public Substitution_Line_Item__c subRequestRec { get; set; }
        public List<WrapDoc> wrapDocList { get; set; }
        public User signer { get; set; }
    }
    
    //Wraper class
    public class WrapDoc {
        public string Docname { get; set; }
        public string Docid { get; set; }
        public string DocUniqName { get; set; }
        public string DocVersionId { get; set; }
    }
    
    public class AttachmentProductFiles {
        public Id DocumentId { get; set; }
        public String Links { get; set; }
    }
    
    public class WrapProductFiles {
        public List<Document_Link__c> extFiles { get; set; }
        public List<AttachmentProductFiles> attchFiles { get; set; }
    }
}