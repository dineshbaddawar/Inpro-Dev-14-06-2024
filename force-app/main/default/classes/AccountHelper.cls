public with sharing class AccountHelper {
    @future (callout = true)
    public static void upsertSyncDivPriceLevelToChildAccounts(string accountId, string priceLevel, string division, string discount) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        service.UpsertSyncDivPriceLevelToChildAccounts('dsj8U73_3nv3Dhba', accountId, priceLevel, division, discount);
    }
    
    @future (callout = true)
    public static void deleteSyncDivPriceLevelToChildAccounts(String accountId, string division) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        service.DeleteSyncDivPriceLevelToChildAccounts('dsj8U73_3nv3Dhba', accountId, division);
    }   

    @future (callout = true)
    public static void syncPriceLevelToChildren(string accountId, string priceLevel) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        service.SyncPriceLevelToChildAccounts('dsj8U73_3nv3Dhba', accountId, priceLevel);
    } 

    @future (callout = true)
    public static void syncAllPricingToChildren(string parentAccountId, string priceLevel) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        service.FullPricingSyncToChildAccounts('dsj8U73_3nv3Dhba', parentAccountId, priceLevel);
    }

    @future (callout = true)
    public static void createAccountChangeRequestObjects(string changeRequestDetails, string changeRequest) {
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;        
        service.FullPricingSyncToChildAccounts(changeRequestDetails, changeRequest, 'dsj8U73_3nv3Dhba');
    }


    public static string executeAccountChangeRequestLogic(Account newAccount, Account oldAccount, string profileName) {
        try 
        {   
            List<Change_Request__c> changeRequestsToCreate = new List<Change_Request__c>();
            List<Change_Request_Detail__c> changeRequestDetailsToCreate = new List<Change_Request_Detail__c>();       
            if(newAccount.Status__c == 'Approved' && profileName != 'System Administrator' && profileName != 'Inpro - Finance')
            {
                Boolean needsAccountChangeRequest = false;               
                for (String str : newAccount.getPopulatedFieldsAsMap().keySet())
                {
                    if (newAccount.get(str) != oldAccount.get(str))
                    {
                        if(str != 'Name' && str != 'AKA_Former_Name__c' && str != 'Dodge_Company_ID__c' && str != 'Price_Level__c' && str != 'CIA__c'  
                        && str != 'RecordTypeId' && str != 'Market_Segment__c' && str != 'Sub_Segment__c' && str != 'ARC_FAC__c' && str != 'Category__c' 
                        && str != 'Phone' && str != 'Website' && str != 'Description' && str != 'ShippingAddress' && str != 'BillingAddress' 
                        && str != 'V_A_T_Number__c' && str != 'Point_of_Contact__c' && str != 'Year_Founded__c' && str != 'AD_Status__c' 
                        && str != 'CZC_Status__c' && str != 'CZW_Status__c' && str != 'EN_Status__c' && str != 'IPC_Status__c' 
                        && str != 'JM_Status__c' && str != 'SS_Status__c')
                        {
                            needsAccountChangeRequest = true;
                            break;
                        }
                    }
                }
                if(needsAccountChangeRequest)
                {
                    Map<String, Schema.SObjectField> fieldMap;
                    fieldMap = Schema.SObjectType.Account.fields.getMap();
                    //Create Account Change Request
                    Change_Request__c changeRequest = new Change_Request__c();
                    changeRequest.Record_Type__c = 'Account';
                    changeRequest.Record_ID__c = newAccount.Id;
                    changeRequestsToCreate.add(changeRequest);
                    //insert changeRequest;

                    //Create Field Change Logs
                    for (String str : newAccount.getPopulatedFieldsAsMap().keySet())
                    {
                        if (newAccount.get(str) != oldAccount.get(str))
                        {
                            Change_Request_Detail__c changeRequestDetail = new Change_Request_Detail__c();
                            changeRequestDetail.Change_Request__c = changeRequest.Id;
                            changeRequestDetail.Field_Schema_Name__c = str;
                            if(newAccount.get(str) != null)
                            {
                                Schema.SObjectField field = fieldMap.get(str);                           
                                changeRequestDetail.Field_Data_Type__c = String.valueOf(field.getDescribe().getType());
                                changeRequestDetail.New_Field_Value__c = String.valueOf(newAccount.get(str));
                            }
                            else {
                                changeRequestDetail.New_Field_Value__c = '';   
                            }
                            if(oldAccount.get(str) != null)
                                changeRequestDetail.Old_Field_Value__c = String.valueOf(oldAccount.get(str));
                            else {
                                changeRequestDetail.Old_Field_Value__c = '';   
                            }
                            changeRequestDetailsToCreate.add(changeRequestDetail);
                            //insert changeRequestDetail;
                        }
                    } 
                    if(changeRequestsToCreate.size() > 0)
                        Database.SaveResult[] crtc = Database.insert(changeRequestsToCreate); 
                    if(changeRequestDetailsToCreate.size() > 0)
                        Database.SaveResult[] crdtc = Database.insert(changeRequestDetailsToCreate); 
                    //Send Email To Finance
                    return 'Error: You have made changes to this account that need to be approved by Finance. A change request has been submitted for them to review.';
                }
            }
            else if (newAccount.Status__c == 'Customer' && profileName != 'System Administrator')
            {
                Boolean needsAccountChangeRequest = false;
                for (String str : newAccount.getPopulatedFieldsAsMap().keySet())
                {
                    if (newAccount.get(str) != oldAccount.get(str))
                    {
                        if(str != 'Dodge_Company_ID__c' && str != 'Price_Level__c' && str != 'CIA__c' && str != 'Price_Level__c' 
                        && str != 'ARC_FAC__c' && str != 'Category__c' && str != 'Phone' && str != 'Website' && str != 'Description' 
                        && str != 'V_A_T_Number__c' && str != 'Point_of_Contact__c' && str != 'Year_Founded__c' && str != 'AD_Status__c' 
                        && str != 'CZC_Status__c' && str != 'CZW_Status__c' && str != 'EN_Status__c' && str != 'IPC_Status__c' 
                        && str != 'JM_Status__c' && str != 'SS_Status__c')
                        {
                            needsAccountChangeRequest = true;
                            break;
                        }
                    }
                } 
                if(needsAccountChangeRequest)
                {
                    Map<String, Schema.SObjectField> fieldMap;
                    fieldMap = Schema.SObjectType.Account.fields.getMap();
                    //Create Account Change Request
                    Change_Request__c changeRequest = new Change_Request__c();
                    changeRequest.Record_Type__c = 'Account';
                    changeRequest.Record_ID__c = newAccount.Id;
                    changeRequestsToCreate.add(changeRequest);
                    //insert changeRequest;

                    //Create Field Change Logs
                    for (String str : newAccount.getPopulatedFieldsAsMap().keySet())
                    {
                        if (newAccount.get(str) != oldAccount.get(str))
                        {
                            Change_Request_Detail__c changeRequestDetail = new Change_Request_Detail__c();
                            changeRequestDetail.Change_Request__c = changeRequest.Id;
                            changeRequestDetail.Field_Schema_Name__c = str;
                            if(newAccount.get(str) != null)
                            {                            
                                Schema.SObjectField field = fieldMap.get(str);                           
                                changeRequestDetail.Field_Data_Type__c = String.valueOf(field.getDescribe().getType());
                                changeRequestDetail.New_Field_Value__c = String.valueOf(newAccount.get(str));
                            }
                            else {
                                changeRequestDetail.New_Field_Value__c = '';   
                            }
                            if(oldAccount.get(str) != null)
                                changeRequestDetail.Old_Field_Value__c = String.valueOf(oldAccount.get(str));
                            else {
                                changeRequestDetail.Old_Field_Value__c = '';   
                            }
                            changeRequestDetailsToCreate.add(changeRequestDetail);
                            //insert changeRequestDetail;
                        }
                    }
                    if(changeRequestsToCreate.size() > 0)
                        Database.SaveResult[] crtc = Database.insert(changeRequestsToCreate); 
                    if(changeRequestDetailsToCreate.size() > 0)
                        Database.SaveResult[] crdtc = Database.insert(changeRequestDetailsToCreate); 
                    //Send Email To Finance
                    return 'Error: You have made changes to this account that need to be approved by Finance. A change request has been submitted for them to review.';
                }
            }
            return 'Success!';      
        } catch (Exception ex) {
            return 'Error: There was an error determining if the account changes need to be approved.';
        }
    }

    @AuraEnabled
    public static List<Account> getAccount(String recordId){
        String Query = 'SELECT Id, Customer_Number__c FROM Account where Id = :recordId';
        List<Account> accounts = Database.query(Query);
        return accounts;    
    }
}