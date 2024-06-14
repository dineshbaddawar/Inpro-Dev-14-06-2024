public with sharing class SampleCommercialInvoiceController 
{
    public Boolean dataFound {get;set;}
    public String exceptionMessage {get;set;}
    public String exceptionStackTrace {get;set;}
    public SampleWrapper data {get;set;}

    public SampleCommercialInvoiceController() {
        try{
            data = new SampleWrapper();
            String sampleRequestId = Apexpages.currentPage().getParameters().get('sampleRequestId');
            data.Sample = 
                    [SELECT Account__c, Address_Validated__c, City__c, Contact_Email__c, Contact__c, Country__c, 
                            CreatedById, CreatedDate, Created_Date__c, CurrencyIsoCode, Current_Approver__c, 
                            Customer_Billing_Phone_Number__c, Customer_Billing_Zip__c, Customer_Number__c, 
                            Customer_Shipping_Account_Number__c, Desired_Shipping_Method__c, Div_Abbreviation__c, 
                            Div_Count__c, Div_Section__c, Division_LU__c, Division__c, Has_Inactive_Product__c, 
                            ISR_Creator__c, ISR_Running_User__c, ISR__c, Id, Inside_Rep__c, IsDeleted, LastActivityDate, 
                            LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Lead__c, MSCRM_ID__c, 
                            Manual_Tracking_Number__c, Name, Notes__c, Notes_field_Used__c, Opportunity__c, OwnerId, 
                            Postal_Code__c, Print_Date__c, Project__c, Qty_Exceeded_Promo_Rollup__c, 
                            Qty_Exceeded_Rollup__c, Quantities_Requested_Exceed_Stock_Levels__c, 
                            Quantity_of_Requested_Items__c, Reference_Field__c, Request_is_from_Known_Competitor__c, 
                            Ship_To__c, Ship_to_Company__c, Ship_to_Email__c, Ship_to_Name__c, Ship_to_Phone__c, 
                            Ship_using_Customer_Account__c, Side_Mark__c, State__c, Status__c, Street_Address__c, 
                            SystemModstamp, Territory_Manager__c, Total_Cost_of_Sample_Request__c, Track__c, 
                            Tracking_Code__c, Type__c
                     FROM Sample_Request__c
                     WHERE Id = :sampleRequestId
                     LIMIT 1];
            data.SampleItems = 
                    [SELECT Account_Name__c, Account__c, Available_Inventory__c, Campaign_ID__c, Contact__c, CreatedById, 
                        CreatedDate, CurrencyIsoCode, Div_Abbreviation__c, Fulfillment_Status__c, Id, IsDeleted, Item_Cost__c, 
                        Item_Status__c, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Lead_Time__c, 
                        MSCRM_ID__c, Name, Package__c, Product_Image__c, Product_Is_Active__c, Qty_Exceeded_Promo__c, 
                        Qty_Exceeded__c, Quantity__c, Request_Date__c, Request_Threshold__c, Requested_Amount_Exceeds_Stock_Level__c, 
                        Sample_Product__c, Sample_Request__c, SystemModstamp, Total_Cost__c, Sample_Product__r.Name, Sample_Product__r.Item_Number__c
                    FROM Sample_Request_Item__c
                    WHERE Sample_Request__c = :sampleRequestId];
            dataFound = true;
        }catch(Exception ex)
        {
            exceptionMessage = ex.getMessage();
            exceptionStackTrace = ex.getStackTraceString();
        }
        
    }

    public class SampleWrapper
    {
        public Sample_Request__c Sample {get;set;}
        public List<Sample_Request_Item__c> SampleItems {get;set;}
    }
}