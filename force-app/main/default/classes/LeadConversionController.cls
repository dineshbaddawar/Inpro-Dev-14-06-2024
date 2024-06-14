public without sharing  class LeadConversionController {
    
    @AuraEnabled
    public static FilterWrapper getFilterWrapper() {
        FilterWrapper filt = new FilterWrapper();
        
        // select our objectdata settings
        List<Lead_Mapping_Configuration__mdt> configs = 
            [select id, label, uses_filters__c, Filter_Interface__c, filter_label__c
             from Lead_Mapping_Configuration__mdt];
        
        // if we don't use filter, set to false and return
        if (!configs.get(0).Uses_Filters__c) { 
            filt.useFilter = false;
        } else {  // else, setup filters
            
            filt.useFilter = true;
            
            // dynamically instantiate our LeadConversionFilter interface            
            ILeadConversionFilter lcf = 
                (ILeadConversionFilter) Type.forName(configs.get(0).Filter_Interface__c).newInstance();
            // set our filters up:
            filt.filterValues = lcf.getFilterValues();
            filt.defaultFilter = lcf.getDefaultFilter();
            if (String.IsBlank(filt.defaultFilter)) {
                if (filt.filterValues != null && filt.filterValues.size() > 0) {
                    filt.defaultFilter = filt.filterValues.get(0);  // default to first in list if not set
                } else {
                    filt.defaultFilter = '';
                }
            }
            filt.filterLabel = configs.get(0).filter_label__c;
        }
        system.debug('filt'+filt);
        return filt;
    }
    
    private static string leadQueryCache = '';
    
    /// Since lead mapping contains dynamically chosen fields, we must dynamically generate our Lead query:
    private static string generateLeadQuery() {
        if (String.isBlank(leadQueryCache)) {
            Set<String> fields = new Set<String>();
            fields.add('Id');
            fields.add('Name');
            fields.add('FirstName');
            fields.add('LastName');
            fields.add('Company');
            fields.add('Description');
            fields.add('Email');
            fields.add('Phone');
            fields.add('Title');
            
            fields.add('Street');
            fields.add('City');
            fields.add('State');
            fields.add('PostalCode');
            fields.add('Country');
            fields.add('Fax');
            fields.add('Website');
            fields.add('Account_Record_Type_To_Create__c');
            fields.add('Market_Segment__c');
            fields.add('Sub_Segment__c');
            fields.add('AD_Status__c');
            fields.add('CZC_Status__c');
            fields.add('CZW_Status__c');
            fields.add('EN_Status__c');
            fields.add('IPC_Status__c');
            fields.add('JM_Status__c');
            fields.add('SS_Status__c');
            fields.add('Facility__c');
            fields.add('Ultimate_Parent_Account__c');
            fields.add('National_Territory__c');
            
            
            
            
            
            List<Lead_Mapping_Field__mdt> customFields = [select Label,Source_Field__c,Required__c,Destination_Field__c,Filter_Settings__c
                                                          from Lead_Mapping_Field__mdt];
            for(Lead_Mapping_Field__mdt f : customFields) {
                if (String.isNotBlank(f.Source_Field__c) && !f.Source_Field__c.startsWith('<')) {   // if we have a value and it is not special mapping
                    fields.add(f.Source_Field__c);
                }
            }
            leadQueryCache = 'Select ' + String.join(new List<String>(fields), ', ') + ' from Lead where Id = :leadId';
        }
        return leadQueryCache;
    }
    
    @AuraEnabled
    public static List<customObjectWrapper> getCustomObjectsFromMetadata(string leadId,string selFilter,boolean useFilter){
        system.debug('selFilter'+selFilter);
        system.debug('useFilter'+useFilter);
        Lead leadObj = ( (List<Lead>) Database.query(generateLeadQuery())).get(0);
        
        // NOTE:  we CANNOT do an 'ORDER BY Order__c' in our subquery.....it simply did not work.....we will manually sort the sub list later:
        List<Lead_Mapping_Object__mdt> customObjects= [SELECT Id, QualifiedApiName, Target_Object_API_Name__c, DeveloperName,Default_Behaviour__c, Label, Display_Order__c,
                                                       (select Label,Source_Field__c,Required__c,Destination_Field__c, DeveloperName, Order__c
                                                        from Lead_Mapping_Fields__r)
                                                       FROM Lead_Mapping_Object__mdt ORDER BY Display_Order__c];
        
        List<Lead_Mapping_Filter_Assignment__mdt> filters = new List<Lead_Mapping_Filter_Assignment__mdt>();
        // if using filter, we must load in any filter settings:
        if (useFilter && String.isNotBlank(selFilter)) {
            filters = [Select Label, Lead_Mapping_Field__r.DeveloperName,
                       Lead_Mapping_Filter__r.DeveloperName, Lead_Mapping_Filter__r.Label, Lead_Mapping_Object__r.DeveloperName from
                       Lead_Mapping_Filter_Assignment__mdt];
            
        }
        
        
        List<customObjectWrapper> coWrapList= new List<customObjectWrapper>();
        for(Lead_Mapping_Object__mdt lmo:customObjects){
            if(true || useFilter == false ){
                
                // test if this object has specific filters
                boolean objectFound = false;
                boolean objectPassed = false;
                system.debug('in object: ' + lmo.Label + ':' + lmo.Target_Object_API_Name__c + ':' + lmo.DeveloperName);
                for(Lead_Mapping_Filter_Assignment__mdt filt : filters) {
                    system.debug('in object filt: ' + filt.Label + ':' + filt.Lead_Mapping_Filter__r.DeveloperName + ':' + filt.Lead_Mapping_Field__r.DeveloperName + ':' + filt.Lead_Mapping_Object__r.DeveloperName);
                    system.debug('comparing: ' + filt.Lead_Mapping_Object__r.DeveloperName + ':' + lmo.DeveloperName);
                    system.debug('comparing selFilter: ' + filt.Lead_Mapping_Filter__r.Label + ':' + selFilter);
                    if (filt.Lead_Mapping_Object__r.DeveloperName == lmo.DeveloperName) {
                        objectFound = true;
                        if (filt.Lead_Mapping_Filter__r.Label == selFilter) {
                            objectPassed = true;
                            break;
                        }
                    }
                }
                
                if (!objectFound) {  // if we DID NOT find the object, it defaults to ALL
                    objectPassed = true;
                }
                
                // bail if we don't even use this object for this filter:
                if (!objectPassed) {
                    continue;
                }
                
                customObjectWrapper coWrap= new customObjectWrapper();
                coWrap.Label=lmo.Label;
                coWrap.ObjectAPIName=lmo.Target_Object_API_Name__c;
                
                if(coWrap.Label =='Construction_Project' && leadObj.Facility__c == null ){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                }
                else if(leadObj.CZC_Status__c !='Could Buy' && coWrap.Label =='CZC Opportunity' ){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                }
                else If(leadObj.AD_Status__c !='Could Buy' && coWrap.Label =='AD Opportunity'){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                    
                }else if(leadObj.CZW_Status__c !='Could Buy' && coWrap.Label == 'CZW Opportunity'){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                    
                }else if(leadObj.EN_Status__c !='Could Buy'&& coWrap.Label ==   'EN Opportunity' ){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                    
                }else if(leadObj.IPC_Status__c !='Could Buy' && coWrap.Label == 'IPC Opportunity'){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                    
                }else if(leadObj.JM_Status__c !='Could Buy' &&  coWrap.Label == 'JM Opportunity'){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                    
                }else if(leadObj.SS_Status__c !='Could Buy' && coWrap.Label ==  'SS Opportunity'){
                    coWrap.DefaultBehaviour ='Do Not Create';
                    coWrap.isCreate         =false;
                    
                    
                }else {
                    coWrap.isCreate = true;
                    
                }
                
                
                List<customFieldWrapper> cfWrapList= new List<customFieldWrapper>();
                List<String> fList=new List<String>();
                
                SObjectType objectType = Schema.getGlobalDescribe().get(coWrap.ObjectAPIName);
                SObject duplicateRec = objectType.newsObject();
                
                
                // manually do a sort on our subfields:
                List<FieldWrapper> fields = new List<FieldWrapper>();
                for(Lead_Mapping_Field__mdt lmf:lmo.Lead_Mapping_Fields__r) {
                    fields.add(new FieldWrapper(lmf));
                }
                fields.sort();
                
                for(FieldWrapper wrapper : fields){
                    Lead_Mapping_Field__mdt lmf = wrapper.lfield;
                    if(true || useFilter == false ){
                        
                        // test if this field has specific filters
                        boolean fieldFound = false;
                        boolean  fieldPassed = false;
                        system.debug('in field: ' + lmf.Label + ':' + lmf.Destination_Field__c + ':' + lmf.DeveloperName);
                        for(Lead_Mapping_Filter_Assignment__mdt filt : filters) {
                            
                            system.debug('in field filt: ' + filt.Label + ':' + filt.Lead_Mapping_Filter__r.DeveloperName + ':' + filt.Lead_Mapping_Field__r.DeveloperName);
                            system.debug('comparing: ' + filt.Lead_Mapping_Field__r.DeveloperName + ':' + lmf.DeveloperName);
                            system.debug('comparing selFilter: ' + filt.Lead_Mapping_Filter__r.Label + ':' + selFilter);
                            if (filt.Lead_Mapping_Field__r.DeveloperName == lmf.DeveloperName) {
                                fieldFound = true;
                                if (filt.Lead_Mapping_Filter__r.Label == selFilter) {
                                    fieldPassed = true;
                                    system.debug('field passed because filter found for our BU: ' + selFilter);
                                    break;
                                }
                            }
                        }
                        if (!fieldFound) {  // if we DID NOT find the field, it defaults to ALL
                            fieldPassed = true;
                            system.debug('field passed because NO filters found');
                        }
                        
                        // bail if we don't even use this field:
                        if (!fieldPassed) {
                            system.debug('field failed -- BU: ' + selFilter);
                            continue;
                        }
                        
                        customFieldWrapper cfWrap= new customFieldWrapper();
                        cfWrap.sourceField=lmf.Source_Field__c;
                        cfWrap.destField=lmf.Destination_Field__c;
                        cfWrap.isRequired=lmf.Required__c;
                        cfWrap.label=lmf.Label;
                        if(lmf.Source_Field__c != null){
                            if(!lmf.Source_Field__c.startsWith('<')){
                                duplicateRec.put(cfWrap.destField, leadObj.get(cfWrap.sourceField));
                                
                                cfWrap.sourceFieldValue=string.valueOf(leadObj.get(lmf.Source_Field__c)) ;
                                // Datetime format for ISO 8601
                                if(lmf.Source_Field__c == 'Bid_Due_Date__c' && leadObj.get(lmf.Source_Field__c) != null  ){
                                    cfWrap.sourceFieldValue=string.valueOf((datetime.valueOf(leadObj.get(lmf.Source_Field__c))).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')) ;
                                    
                                }
                                
                                //////////////////////////
                            } else {  // start with angle brackets means we have a dependency:
                                cfWrap.hasDependency = true;
                                cfWrap.sourceField = cfWrap.sourceField.remove('<').remove('>');
                            }
                        }
                        
                        fList.add(lmf.Destination_Field__c);
                        cfWrapList.add(cfWrap);
                    }
                }
                
                List<SObject> dupResults = new List<SObject>();
                List<sObject> recordList = new List<sObject>();
                recordList.add(duplicateRec);
                
                Datacloud.FindDuplicatesResult[] results = new Datacloud.FindDuplicatesResult[0];
                
                try {
                    results = Datacloud.FindDuplicates.findDuplicates(recordList);
                } catch(Exception ex) {
                    // nothing
                    system.debug(ex.getMessage());
                }
                
                for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                    for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                        for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                            for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                                System.debug('Duplicate Record: ' + matchRecord.getRecord());
                                dupResults.add(matchRecord.getRecord());
                            }
                        }
                    }
                }
                
                
                coWrap.dupeResults=dupResults;
                coWrap.customFields=cfWrapList;
                coWrap.fieldsList=fList;
                system.debug('Adding to list: ' + coWrap.Label);
                coWrapList.add(coWrap);
                
                
            }
            
        }
        system.debug('customWrapperList: ' + JSON.serialize(coWrapList));
        return coWrapList;
    }
    
    
    
    @AuraEnabled
    public static ResultWrapper getUser(){
        User u = [SELECT Id, Name FROM User where id=:UserInfo.getUserId()];
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        ResultWrapper obj = new ResultWrapper();
        obj.objName = 'User';
        obj.text = String.valueOf(u.Name);
        obj.val = String.valueOf(u.Id);
        lstRet.add(obj);
        //return JSON.serialize(lstRet) ; 
        return obj;
    }
    
    @AuraEnabled
    public static DuplicateListWrapper allowDuplicates(string leadId){
        
        Lead leadObj = ( (List<Lead>) Database.query(generateLeadQuery())).get(0);
        List<SObject> AccountdupResults = new List<SObject>();
        List<SObject> ContactdupResults = new List<SObject>();
        Boolean allowAccDupe=true;
        Boolean allowConDupe=true;
        Account acct = new Account(name=leadObj.Company,
                                   BillingCity          =   leadObj.City,
                                   BillingStreet        =   leadObj.Street,
                                   BillingState         =   leadObj.State,
                                   BillingPostalCode    =   leadObj.PostalCode,
                                   BillingCountry       =   leadObj.Country,
                                   ShippingCity         =   leadObj.City,
                                   ShippingStreet       =   leadObj.Street,
                                   ShippingState        =   leadObj.State,
                                   ShippingPostalCode   =   leadObj.PostalCode,
                                   ShippingCountry      =   leadObj.Country,
                                   Phone                =   leadObj.phone,
                                   Fax                  =   leadObj.Fax,
                                   Website              =   leadObj.Website                                
                                  );
        List<Account> acctList = new List<Account>();
        acctList.add(acct);
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(acctList);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    allowAccDupe=dupeResult.isAllowSave();
                    system.debug('dupeResult.isAllowSave()'+dupeResult.isAllowSave());
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        System.debug('Duplicate Record: ' + matchRecord.getRecord());
                        AccountdupResults.add(matchRecord.getRecord());
                    }
                }
            }
        }
        
        
        
        Contact con = new Contact(FirstName     =   leadObj.FirstName,
                                  LastName      =   leadObj.LastName,
                                  Email         =   leadObj.Email,
                                  Phone         =   leadObj.Phone,
                                  MailingCity       =   leadObj.City,
                                  MailingStreet     =   leadObj.Street,
                                  MailingState      =   leadObj.State,
                                  MailingPostalCode =   leadObj.PostalCode,
                                  MailingCountry    =   leadObj.Country,
                                  Title             =   leadObj.Title
                                 );
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        Datacloud.FindDuplicatesResult[] resultsCon = Datacloud.FindDuplicates.findDuplicates(conList);
        for (Datacloud.FindDuplicatesResult findDupeResult : resultsCon) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    allowConDupe=dupeResult.isAllowSave();
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        System.debug('Duplicate Record: ' + matchRecord.getRecord());
                        ContactdupResults.add(matchRecord.getRecord());
                    }
                }
            }
        }
        
        DuplicateListWrapper wrapper= new DuplicateListWrapper();
        if(AccountdupResults.size()>0){
            List<Account>AccListDup = new List<Account>();
            // System.debug('@@AccountdupResults'+AccountdupResults);
            AccListDup = [Select Id,Name,Website,Phone,BillingStreet,AccountNumber from Account where Id IN:AccountdupResults ];
            AccountdupResults = new List<Account>();
            AccountdupResults = AccListDup;
        }
        if(ContactdupResults.size()>0){
            List<Contact>ConListDup = new List<Contact>();
            // System.debug('@@AccountdupResults'+AccountdupResults);
            ConListDup = [Select Id,Name,Email from Contact where Id IN:ContactdupResults ];
            ContactdupResults = new List<Contact>();
            ContactdupResults = ConListDup;
        }
        wrapper.accountDupList=AccountdupResults;
        wrapper.contactDupList=ContactdupResults;
        wrapper.allowAccDupe=allowAccDupe;
        wrapper.allowAccDupe=allowConDupe;
        
        return wrapper;
    }
    
    
    @AuraEnabled
    public static RecordTypeWrapper getRecordTypes(string leadId){
        
        Lead leadRecord=[Select Id,Name,Account_Record_Type_To_Create__c from Lead where Id=:leadId];
        List<String> recTypeIds = new List<String>();
        Map<string,List<RecordTypeWrapper>> recordtypeMap = new Map<string,List<RecordTypeWrapper>>();
        
        
        List<String> accRecType=new List<String>();
        List<String> conRecType=new List<String>();
        String defAccType='';
        String defConType='';
        for(RecordTypeInfo info: Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                recTypeIds.add(info.getRecordTypeId());
                accRecType.add(info.getName());
                if(info.isDefaultRecordTypeMapping())
                    defAccType=info.getName();
            }
        }
        for(RecordTypeInfo info: Contact.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                recTypeIds.add(info.getRecordTypeId());
                conRecType.add(info.getName());
                if(info.isDefaultRecordTypeMapping())
                    defConType=info.getName();
            }
        }
        
        // defAccType = leadRecord.Account_Record_Type__c;
        // defAccType = leadRecord.Account_Record_Type_To_Create__c;
        
        RecordTypeWrapper wrapperObj = new RecordTypeWrapper();
        wrapperObj.AccountRecTypes=accRecType;
        wrapperObj.ContactRecTypes=conRecType;
        wrapperObj.defAccRecType=defAccType;
        wrapperObj.defConRecType=defConType;
        
        RETURN wrapperObj;
        
    }
    
    
    
    @AuraEnabled
    public static Map<string,string> getStageValues(){
        Map<string,string> leadStages = new Map<string,string>();
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            leadStages.put(pickListVal.getLabel(),pickListVal.getLabel()); 
        }  
        return leadstages;
    }
    
    
    @AuraEnabled
    public static inputFieldWrapper getLeadDetails(string leadId){
        Lead leadObj = ( (List<Lead>) Database.query(generateLeadQuery())).get(0);
        inputFieldWrapper wrapObj= new inputFieldWrapper();
        wrapObj.accountName=leadObj.Company;
        
        wrapObj.accountBillingStreet        = leadObj.Street;
        wrapObj.accountBillingCity          = leadObj.City;
        wrapObj.accountBillingState         = leadObj.State;
        wrapObj.accountBillingPostalCode    = leadObj.PostalCode;
        wrapObj.accountBillingCountry       = leadObj.Country;
        wrapObj.accountPhone                = leadObj.Phone;
        wrapObj.accountFax                  = leadObj.Fax;
        wrapObj.accountWebsite              = leadObj.Website ;
        wrapObj.contactName                 =   leadObj.Name;
        wrapObj.contactFirstName            =   leadObj.FirstName;
        wrapObj.contactLastName             =   leadObj.LastName;
        wrapObj.contactEmail                =   leadObj.Email;
        wrapObj.contactTitle                =   leadObj.Title;
        wrapObj.contactPhone                =   leadObj.Phone;
        wrapObj.marketSegment               =   leadObj.Market_Segment__c;
        wrapObj.subSegment                  =   leadObj.Sub_Segment__c;
        wrapObj.accountRecordType           =   leadObj.Account_Record_Type_To_Create__c;
        wrapObj.ultimateParentAccount       =   leadObj.Ultimate_Parent_Account__c;
        wrapObj.nationalTerritory           =   leadObj.National_Territory__c;
        
        
        return wrapObj;
    }
    
    @AuraEnabled
    public static convertedCObjectWrapper updateLookupForCustomObjects(Id recordId,Id accId, Id conId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjName);
        Map<String,String> fieldValueToUpdate= new Map<String,String>();
        List<Lead_Mapping_Object__mdt> customObjects= [SELECT Id, QualifiedApiName, Target_Object_API_Name__c, Label,
                                                       (select Label,Source_Field__c,Destination_Field__c from Lead_Mapping_Fields__r) 
                                                       FROM Lead_Mapping_Object__mdt];
        for(Lead_Mapping_Object__mdt lmo:customObjects){
            if(lmo.Target_Object_API_Name__c == sObjName){
                for(Lead_Mapping_Field__mdt lmf:lmo.Lead_Mapping_Fields__r){
                    if(lmf.Source_Field__c == '<ACCOUNT>' ){
                        fieldValueToUpdate.put(lmf.Destination_Field__c, accId);
                    }
                    if(lmf.Source_Field__c == '<CONTACT>' ){
                        fieldValueToUpdate.put(lmf.Destination_Field__c, conId);
                    }
                    
                }
            }
        }
        
        SObject recToUpdate = objectType.newsObject();
        recToUpdate.put('Id', recordId);
        for(string s:fieldValueToUpdate.keySet()){
            recToUpdate.put(s, fieldValueToUpdate.get(s));
        }
        update recToUpdate;
        
        convertedCObjectWrapper wrap = new convertedCObjectWrapper();
        wrap.name=string.valueOf( recToUpdate.get('Name'));
        wrap.objectname=sObjName;
        
        return wrap;
        
    }
    
    
    @AuraEnabled
    public static convertedLeadWrapper convertLeadrecord(string convStatus,string leadId,string accName,
            string accRecordType,string confName,string conlName,
            string conEmail,string conPhone,string conTitle,
            string conRecordType,string existAccid,string existConId,
            boolean createAcc,boolean createCon, string accBillingStreet,
            string accBillingCity,string accBillingState,string accBillingPostalCode,
            string accBillingCountry, string accPhone,string accFax,string accWebsite,string userId )
        {
                                                         
        system.debug('createAcc'+createAcc);
        system.debug('createCon'+createCon);
        Database.LeadConvert lc = new Database.LeadConvert();
        Lead leadRecord = new lead();
        system.debug('leadId'+leadId);
        lc.setLeadId(leadId);
        lc.setConvertedStatus(convStatus);
        Account acc = new Account();
        Contact con= new Contact();
        leadRecord = [SELECT Email, Id,Account_Record_Type_To_Create__c,Website,Category__c,Market_Segment__c,Sub_Segment__c,
                             LeadSource,Lead_Source_Details__c,AIA_Member_Number__c,Is_AIA_Member__c,Products_Interested_in__c,
                             Ultimate_Parent_Account__c,National_Territory__c,Is_Account_Request__c, Email_Opt_In__c, Facility__c,
                             pi__conversion_date__c, pi__conversion_object_name__c, 
                             pi__conversion_object_type__c, pi__campaign__c, pi__comments__c, pi__grade__c, pi__pardot_hard_bounced__c, 
                             pi__created_date__c, pi__score__c, pi__notes__c, pi__url__c, pi__last_activity__c, pi__Pardot_Last_Scored_At__c, 
                             pi__first_touch_url__c, pi__first_search_term__c, pi__first_search_type__c
                      FROM Lead 
                      WHERE Id = :leadId];

        if (createAcc == true)
        {
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                                    .get(leadRecord.Account_Record_Type_To_Create__c).getRecordTypeId();

            system.debug('devRecordTypeId'+devRecordTypeId);
            acc.Name = accName;
            acc.Lead__c = leadRecord.Id;
            acc.Lead_Id__c = leadRecord.Id;
            acc.BillingCity = accBillingCity;
            acc.BillingStreet = accBillingStreet;
            acc.BillingState = accBillingState;
            acc.BillingPostalCode = accBillingPostalCode;
            acc.BillingCountry = accBillingCountry;
            acc.ShippingCity = accBillingCity;
            acc.ShippingStreet = accBillingStreet;
            acc.ShippingState = accBillingState;
            acc.ShippingPostalCode = accBillingPostalCode;
            acc.ShippingCountry = accBillingCountry;
            acc.RecordTypeId = devRecordTypeId;
            acc.Category__c = leadRecord.Category__c;
            acc.Phone = accPhone;
            acc.Website = leadRecord.Website;
            acc.Market_Segment__c = leadRecord.Market_Segment__c;
            acc.Sub_Segment__c = leadRecord.Sub_Segment__c;
            acc.AccountSource = leadRecord.LeadSource;
            acc.Account_Source_Details__c = leadRecord.Lead_Source_Details__c;
            acc.Ultimate_Parent_Account__c = leadRecord.Ultimate_Parent_Account__c;
            acc.National_Territory__c = leadRecord.National_Territory__c;    

            if(userId !=null)
            {
                acc.OwnerId = Id.valueOf(userId);
            }

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            Database.insert(acc,dml);
        }
        else
        {
            acc.Id=existAccid;
        }
        
        if(createCon == true)
        {
            con.Lead__c = leadRecord.Id;
            con.Lead_Id__c = leadRecord.Id;
            con.FirstName = confName;
            con.LastName = conlName;
            con.Phone = conPhone;
            con.AIA_Member_Number__c = leadRecord.AIA_Member_Number__c;
            con.Is_AIA_Member__c = leadRecord.Is_AIA_Member__c;
            con.Lead_Source_Details__c = leadRecord.Lead_Source_Details__c;
            con.LeadSource = leadRecord.LeadSource;  
            con.Products_Interested_In__c = leadRecord.Products_Interested_in__c;
            con.AccountId = acc.Id;
            con.Is_Lead_Account_Request__c = leadRecord.Is_Account_Request__c;
            con.Email = leadRecord.Email;
            con.Email_Opt_In__c = leadRecord.Email_Opt_In__c;
            con.Facility__c = leadRecord.Facility__c;                                                                 
            con.pi__conversion_date__c = leadRecord.pi__conversion_date__c;
            con.pi__conversion_object_name__c = leadRecord.pi__conversion_object_name__c;
            con.pi__conversion_object_type__c= leadRecord.pi__conversion_object_type__c;
            con.pi__campaign__c = leadRecord.pi__campaign__c;
            con.pi__comments__c = leadRecord.pi__comments__c;
            con.pi__grade__c = leadRecord.pi__grade__c;
            con.pi__pardot_hard_bounced__c = leadRecord.pi__pardot_hard_bounced__c;
            con.pi__created_date__c = leadRecord.pi__created_date__c;
            con.pi__score__c = leadRecord.pi__score__c;
            con.pi__notes__c = leadRecord.pi__notes__c;
            con.pi__url__c = leadRecord.pi__url__c;
            con.pi__last_activity__c = leadRecord.pi__last_activity__c;
            con.pi__Pardot_Last_Scored_At__c = leadRecord.pi__Pardot_Last_Scored_At__c;
            con.pi__first_touch_url__c = leadRecord.pi__first_touch_url__c;
            con.pi__first_search_term__c = leadRecord.pi__first_search_term__c;
            con.pi__first_search_type__c= leadRecord.pi__first_search_type__c;

            if (userId !=null)
            {
                con.OwnerId = Id.valueOf(userId); 
            }

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            Database.insert(con,dml);
        }
        else
        {
            con.Id=existConId;                        
        }

        if (createAcc && createCon && leadRecord.LeadSource == 'Website')
        {
            acc.Point_of_Contact__c = con.Id;
            update acc;
        }

        system.debug('acc.Id'+acc.Id);
        system.debug('con.Id'+con.Id);
        lc.setAccountId(acc.Id);
        lc.setContactId(con.Id);
        lc.setDoNotCreateOpportunity(true);

        if (userId != null)
        {
            lc.setOwnerId(Id.valueOf(userId));
        }                                                    
        
        Account acc1 = new Account();
        Contact con1 = new Contact();
        con1.Id = con.Id;
        acc1.Id = acc.Id;
        acc1.Lead__c = leadRecord.Id;
        acc1.Lead_Id__c = leadRecord.Id;

        con1.Lead__c= leadRecord.Id;
        con1.Lead_Id__c = leadRecord.Id;
        con1.Is_Lead_Account_Request__c = leadRecord.Is_Account_Request__c;
        if(confName != null && confName != '')
            con1.FirstName = confName;
        if(conlName != null && conlName != '')        
            con1.LastName = conlName;
        if(conPhone != null && conPhone != '')                
            con1.Phone = conPhone;
        if(conEmail != null && conEmail != '')                        
            con1.Email = conEmail;
        if(conTitle != null && conTitle != '')                                
            con1.Title = conTitle;    

        if(leadRecord.Is_Account_Request__c != null && leadRecord.Is_Account_Request__c)
        {
            Contact c = [select FirstName, LastName, Phone, Email, Title from Contact where Id = :con1.Id limit 1];
            if(c.FirstName != confName || 
               c.LastName != conlName ||
               c.Phone != conPhone ||
               c.Email != conEmail ||
               c.Title != conTitle)
               {
                  //TODO: get Email Template for customer facing email
                  //  EmailSendHelper.sendEmail('dsieraski@inprocorp.com', [Select email from user where id = :userId].email, 'Contact Info Updates', 'Contact info updated');
               }

               if(conEmail != null && conEmail != '')
                WebserviceTriggerProxy.ApproveEcomRegistration(conEmail);
               
        }

        update con1;
        update acc1;

        Lead l = new Lead();
        l.Id = leadRecord.Id;
        l.Status = 'Converted';                                                                
        update l;
            
        // load our wrapper objects (either new, or existing):
        String accIdFinal = acc.Id; //(createAcc) ? lcr.accountid : existAccid;
        String conIdFinal = con.Id; //(createCon) ? lcr.contactId : existConid;
        
        Account convAcc=[SELECT Id, Name FROM Account WHERE Id = :accIdFinal];
        Contact convCon=[SELECT Id, Name FROM Contact WHERE Id = :conIdFinal];
        
        convertedLeadWrapper wrapObj = new convertedLeadWrapper();
        wrapObj.convAccount = convAcc;
        wrapObj.convContact = convCon;
        
        return wrapObj; 
    }

    @AuraEnabled
    public static void insertBidderRecords(string objArray,string newObj,string leadId){
        
        List<CreatedRecords>rcdsList    = new list<CreatedRecords>();
        CreatedRecords OppRecord        = new CreatedRecords();
        id masterAccountId, masterContactId,constructionProjId;
        lead leadRecord = new lead();
        List<Construction_Project__c>ConstructionProjList =new List<Construction_Project__c>();
        OppRecord =(CreatedRecords) JSON.deserialize(newObj,CreatedRecords.class);
        rcdsList =(List<CreatedRecords>) JSON.deserialize(objArray,List<CreatedRecords>.class);
        for(CreatedRecords newRecords:rcdsList){
            if(newRecords.Name =='Account' ){
                masterAccountId =newRecords.Id;
            }
            else if(newRecords.Name =='Contact'){
                masterContactId =newRecords.Id;
            }
            else if(newRecords.Name =='Construction_Project'){
                constructionProjId =newRecords.Id;
            }
        }
        //  string recordTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(masterAccountId).getDeveloperName();

        if(constructionProjId != null){
            ConstructionProjList    =[Select Id,project_Role__c,Bid_Date_GC_to_Owner__c,Converted_Lead__c,Converted_Lead__r.Name,
                                      Converted_Lead__r.LeadSource,Converted_Lead__r.Lead_Source_Details__c,
                                      Converted_Lead__r.Installation_Type__c,Converted_Lead__r.Bid_Due_Date__c,
                                      Converted_Lead__r.CreatedDate,Converted_Lead__r.Is_Estimate_Required__c,
                                      Market_Segment__c,Sub_Segment__c
                                      from Construction_Project__c 
                                      where Id=:constructionProjId ];
            Construction_Project__c cp = new Construction_Project__c();
            cp = ConstructionProjList[0];
            
            if(cp.project_Role__c =='Bidding Contractor'){
                Opportunity opp = new Opportunity();
                opp = [select id,Division__c,Is_Estimate_Required__c,Div_Section__c,Building_Owner__c,AccountId from Opportunity where Id=:OppRecord.Id];
                
                Bidder__c bid = new Bidder__c();
                bid.Construction_Project__c =   cp.Id;
                bid.Opportunity__c          =   OppRecord.Id;
                if(cp.Bid_Date_GC_to_Owner__c != null ){
                    bid.ITB_Due_Date__c         =   (cp.Bid_Date_GC_to_Owner__c).date();
                }
                bid.Source__c               =   cp.Converted_Lead__r.LeadSource;
                bid.Installation_Type__c    =   cp.Converted_Lead__r.Installation_Type__c;
                bid.Division__c             =   opp.Division__c;
                bid.Div_Section__c          =   opp.Div_Section__c;
                bid.Quote_Status__c         =   'Quote Requested';
                bid.Converted_Lead__c       =   cp.Converted_Lead__c;
                bid.ITB_Request_Date__c     =   Date.valueOf(CP.Converted_Lead__r.CreatedDate);
                //ITB_Request_Date__c
                bid.Bidder__c               =   masterAccountId;
                bid.Contact__c              =   masterContactId; 
                List<bidder__c> bidderDel = new list<bidder__c>();
                for(bidder__c bidder:[select Id,Converted_Lead__c,Opportunity__c from bidder__c  where Construction_Project__c =: constructionProjId  AND Converted_Lead__c =: cp.Converted_Lead__c AND Opportunity__c =:null Limit 1]){
                    //  if((bidder.Opportunity__c == oppRecord.Id ||bidder.Opportunity__c == null )&& bidder.Converted_Lead__c == cp.Converted_Lead__c ){
                    bidderDel.add(bidder);
                    //   }                                   
                }
                //    
                if(bidderDel.size()>0)  {
                    
                    try {
                        delete bidderDel;
                    } catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
                    
                }                    
                insert bid; 
                System.debug('@@bid'+bid);                          
                if(cp.Converted_Lead__r.Is_Estimate_Required__c){
                    opp.Is_Estimate_Required__c = cp.Converted_Lead__r.Is_Estimate_Required__c;
                    // update opp;
                    System.debug('@@opp'+opp);
                }
            } 
            
        }
        else{
            Opportunity opp1 = new Opportunity();
            opp1 = [select id,Converted_Lead__c,Division__c,Converted_Lead__r.Project_Role__c,Converted_Lead__r.CreatedDate,Is_Estimate_Required__c,Div_Section__c,
                    Converted_Lead__r.Bid_Due_Date__c,Converted_Lead__r.LeadSource,Converted_Lead__r.Installation_Type__c,Building_Owner__c,AccountId
                    from Opportunity where Id=:OppRecord.Id];
            
            if(opp1.Converted_Lead__r.Project_Role__c =='Bidding Contractor'){
                Bidder__c bid = new Bidder__c();
                // bid.Construction_Project__c =    cp.Id;
                bid.Opportunity__c          =   OppRecord.Id;
                if(opp1.Converted_Lead__r.Bid_Due_Date__c != null ){
                    bid.ITB_Due_Date__c         =   (opp1.Converted_Lead__r.Bid_Due_Date__c).date();
                }
                bid.Source__c               =   opp1.Converted_Lead__r.LeadSource;
                bid.Installation_Type__c    =   opp1.Converted_Lead__r.Installation_Type__c;
                bid.Division__c             =   opp1.Division__c;
                bid.Div_Section__c          =   opp1.Div_Section__c;
                bid.Quote_Status__c         =   'Quote Requested';
                bid.Converted_Lead__c       =   opp1.Converted_Lead__c;
                bid.ITB_Request_Date__c     =   Date.valueOf(opp1.Converted_Lead__r.CreatedDate);
                //ITB_Request_Date__c
                bid.Bidder__c               =   masterAccountId;
                bid.Contact__c              =   masterContactId;
                insert bid; 
                
            }
            
            
        }
        Id idRecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Building_Owner').getRecordTypeId();
        Account masterAccount   =   new Account();
        masterAccount           =   [Select ID,RecordTypeId from Account where Id=: masterAccountId ];
        Opportunity oppt = new Opportunity();
        oppt = [select id,Building_Owner__c,AccountId from Opportunity where Id=:OppRecord.Id];
        if(masterAccount.RecordTypeId == idRecordId){
            oppt.Building_Owner__c  = masterAccount.Id;
        }
        else{
            oppt.AccountId = masterAccount.Id;
        }
        if(constructionProjId != null){
            oppt.Market_Segment__c  =   ConstructionProjList[0].Market_Segment__c;
            oppt.Sub_Segment__c     =   ConstructionProjList[0].Sub_Segment__c;
        }
            
        update oppt;
        
    }
    // custom wrapper class to allow us to sort our subfields list:
    public class FieldWrapper implements Comparable {
        
        public Lead_Mapping_Field__mdt lfield {get; set;}
        
        public FieldWrapper(Lead_Mapping_Field__mdt f) {
            this.lfield = f;
        }
        
        public Integer compareTo(Object compare) {
            // Cast argument to OpportunityWrapper
            FieldWrapper compareTo = (FieldWrapper) compare;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (lfield.Order__c > compareTo.lfield.Order__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (lfield.Order__c < compareTo.lfield.Order__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;
        }
    }
    
    
    public class FilterWrapper {
        @AuraEnabled
        public String defaultFilter {get; set;}
        
        @AuraEnabled
        public boolean useFilter { get; set; }
        
        @AuraEnabled
        public List<String> filterValues {get; set;}
        
        @AuraEnabled
        public String filterLabel {get; set;}
    }
    
    public class ResultWrapper{
        @AuraEnabled
        public String objName {get;set;}
        @AuraEnabled
        public String text{get;set;}
        @AuraEnabled
        public String val{get;set;}
    }
    
    public class RecordTypeWrapper{
        @AuraEnabled
        public List<String> AccountRecTypes {get;set;}
        @AuraEnabled
        public List<String> ContactRecTypes {get;set;}
        @AuraEnabled
        public String defAccRecType {get;set;}
        @AuraEnabled
        public String defConRecType{get;set;}
    }
    
    public class inputFieldWrapper{
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public String accountBillingStreet {get;set;}
        @AuraEnabled
        public String accountBillingCity {get;set;}
        @AuraEnabled
        public String accountBillingState {get;set;}
        @AuraEnabled
        public String accountBillingPostalCode {get;set;}
        @AuraEnabled
        public String accountBillingCountry {get;set;}
        @AuraEnabled
        public String accountPhone {get;set;}
        @AuraEnabled
        public String accountFax {get;set;}
        @AuraEnabled
        public String accountWebsite  {get;set;}
        
        @AuraEnabled
        public String contactName {get;set;}
        @AuraEnabled
        public String contactFirstName {get;set;}
        @AuraEnabled
        public String contactLastName{get;set;}
        @AuraEnabled
        public String contactEmail{get;set;}
        @AuraEnabled
        public String contactPhone{get;set;}
        @AuraEnabled
        public String contactTitle{get;set;}
        @AuraEnabled
        public String marketSegment{get;set;}
        @AuraEnabled
        public String subSegment{get;set;}
        @AuraEnabled
        public String accountRecordType{get;set;}
        @AuraEnabled
        public String ultimateParentAccount{get;set;}
        @AuraEnabled
        public String nationalTerritory{get;set;}
    }
    
    public class DuplicateListWrapper{
        @AuraEnabled
        public List<SObject> accountDupList {get;set;}
        @AuraEnabled
        public List<SObject> contactDupList {get;set;}
        @AuraEnabled
        public boolean allowAccDupe {get;set;}
        @AuraEnabled
        public boolean allowConDupe {get;set;}
    }
    
    public class customObjectWrapper{
        @AuraEnabled
        public String Label {get;set;}
        @AuraEnabled
        public String DefaultBehaviour {get;set;}
        @AuraEnabled
        public boolean isCreate {get;set;}
        
        @AuraEnabled
        public String ObjectAPIName {get;set;}
        @AuraEnabled
        public List<customFieldWrapper> customFields {get;set;}
        @AuraEnabled
        public List<String> fieldsList {get;set;}
        @AuraEnabled
        public List<SObject> dupeResults {get;set;}
    }
    public class customFieldWrapper{
        @AuraEnabled
        public String sourceField {get;set;}
        @AuraEnabled
        public String destField {get;set;}
        @AuraEnabled
        public Boolean isRequired {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String sourceFieldValue {get;set;}
        @AuraEnabled
        public boolean hasDependency {get; set;}
    }
    public class convertedLeadWrapper{
        @AuraEnabled
        public Account convAccount {get;set;}
        @AuraEnabled
        public Contact convContact {get;set;}
    }
    
    public class convertedCObjectWrapper{
        @AuraEnabled
        public string objectname {get;set;}
        @AuraEnabled
        public string name {get;set;}
    }
    public class CreatedRecords{
        public String Id;   
        public String objName;  
        public String Name; 
    }
}