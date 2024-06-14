public with sharing class CustomFormHelper 
{
    
    public static Quote GetQuoteData(string quoteId) 
        
    {
        List<Quote> quote = [SELECT 
                             Id, OwnerId, IsDeleted, Name, CurrencyIsoCode,Contact.Name,
                             Contact.LastName,Contact.Phone,Contact.Email,Contact.fax,
                             Account.Customer_Number__c,
                             Primary_Bidder__r.ParentId,
                             RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                             SystemModstamp, LastViewedDate, LastReferencedDate, OpportunityId, Pricebook2Id,
                             ContactId, QuoteNumber, IsSyncing, ShippingHandling, Tax,
                             Status, ExpirationDate, Description, Subtotal, TotalPrice,
                             LineItemCount, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                             BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude,
                             BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState,
                             ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude,
                             ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, QuoteToStreet, QuoteToCity,
                             QuoteToState, QuoteToPostalCode, QuoteToCountry, QuoteToStateCode, QuoteToCountryCode,
                             QuoteToLatitude, QuoteToLongitude, QuoteToGeocodeAccuracy, QuoteToAddress, AdditionalStreet,
                             AdditionalCity, AdditionalState, AdditionalPostalCode, AdditionalCountry, AdditionalStateCode,
                             AdditionalCountryCode, AdditionalLatitude, AdditionalLongitude, AdditionalGeocodeAccuracy, AdditionalAddress,
                             BillingName, ShippingName, QuoteToName, AdditionalName, Email,
                             Phone, Fax, ContractId, AccountId, Discount,
                             GrandTotal, CanCreateQuoteLineItems, BidQuote__c, Bidder_Record_Type__c, Biggest_Alternate_Discount__c,
                             Copied_From_Quote__c, Copied_Price_Level__c, Division_Lookup__c, Division__c, Ending__c,
                             ISR_Task_Trigger__c, Inpro_Document_Number__c, Inpro_Interiors__c, Inside_Rep__c, Introduction__c,
                             Job_Location_City__c, Job_Location_Country__c, Job_Location_Postal_Code__c, Job_Location_State__c, Job_Location_Street__c,
                             Last_Activity_Date__c, Locked__c, Lowest_Alternate_CM__c, MPC_Interactive__c, PO_Number__c,
                             Payment_Terms_Code__c, Primary_Bidder__c, Print_Total_Setting__c, Priority__c, Qualifications__c,
                             Requested_Ship_Date__c, Revision_Number__c, SourceOLD__c, Taxable__c, Territory_Manager__c,
                             Non_configurable__c, Type__c, Automation_Date_Time__c, Update_Alternate_Header__c, Version_Description__c,
                             ARC_FAC__c, Category__c, Market_Segment__c, Sub_Segment__c, Account_Name_Formula__c,
                             Alternate_Total_Cost__c, Alternate_Total_Material__c, ContactEmail__c, ContactFax__c, ContactPhone__c,
                             Created_Date__c, Date_Sent_to_Customer__c, Div_Section__c, Inpro_Contract__c, Is_Dirty__c,
                             MSCRM_ID__c, Manager_Bypass__c, Market_Segment_New__c, Next_Activity__c, Non_Commissionable__c,
                             OR_Count__c, Opportunity_Owner__c, Order_Count__c, PrintNumber__c, Product_Removed__c,
                             Project__c, Requires_Follow_Up__c, Ship_To_Contact__c, Source_Details__c, Source__c,
                             Tax_Updated__c, Territory_Lookup__c, Total_CM__c, Account_GPO_Associations__c, Grand_Total__c,
                             Includes_Aspex__c, Install_Quote_Total__c, Is_Most_Recent_Quote__c, SAS__c, Total_Tax__c,
                             Ultimate_Parent_Account__c, Yield__c, Freight_Tax__c, Freight__c, Product_Tax__c,
                             Total_Base_Price__c, Is_Automation_Bypassed__c, Is_Ordered__c, Install_Task_Complete__c, Opportunity_Name__c,
                             Opp_Owner_s_Manager__c, Parent_Account__c, Quote_Estimating_Notes__c, Requires_Discount_Manager_Approval__c, Pricing_Account_Numbers__c,
                             Qualifications_Flick__c, Original_Source_Details__c, Original_Source__c, Estimating_Status__c, Pricing_Account_Numbers_Flick__c,
                             Clickeze_Location__c, Fireline_Location_Code__c, Estimating_Audit__c, Territory__c 
                             FROM Quote 
                             WHERE Id = :quoteId];
        if (quote.size() < 1)
        {
            return new Quote();
        }
        return quote[0];
    }
    
    
    public static List<QuoteLineItem> GetQuoteLineData(string quoteId) 
    {
        
        List<QuoteLineItem> lineItems = [SELECT Id, IsDeleted, LineNumber, CurrencyIsoCode, CreatedDate,
                                         CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate,
                                         LastReferencedDate, QuoteId, PricebookEntryId, OpportunityLineItemId, Quantity,
                                         UnitPrice, Discount, Description, ServiceDate, Product2Id,Product2.Name,
                                         Product2.ProductCode,SortOrder, ListPrice, Subtotal, TotalPrice, Above_Floor_Finish__c,
                                         Accessory__c, Additional_Liner__c, Allocation_Length__c, Allocation_Width__c, Alloy_Type__c,
                                         Alternate_Name__c, Alternate_Number__c, Alternate__c, Back_Plate_Substrate__c, Backsplash_Height__c,
                                         Backsplash_Length__c, Base_Price__c, Baston_Length__c, Brackets_2__c, Brackets__c,
                                         Braille__c, Bulk_Pack_Group__c, Ceiling_Height__c, Ceiling_to_Curtain__c, Chain_Guide__c,
                                         Color_2__c, Color_3__c, Color_4__c, Color_5__c, Color_6__c,
                                         Color_7__c, Color_Class__c, Color__c, Cord_Length__c, Cord_Position__c,
                                         Custom_Angle__c, Custom_Pricing_Requested__c, Customer_Priced_On__c, Cut_List__c, Description_2__c,
                                         Digital_Print__c, Do_Not_Print__c, Document_Name__c, Double_Sided__c, Draw_Type__c,
                                         EDI_Inpro_Item__c, EDI_Line_Number__c, EDI_Vendor_Item__c, Edge_Banding_Width__c, Edge_Height__c,
                                         Edge_Left_Length__c, Edge_Length__c, Edge_Right_Length__c, Edge__c, Fabric_Horizontal_Repeat__c,
                                         Fabric_Tape__c, Fabric_Vertical_Repeat_2__c, Fabric_Vertical_Repeat__c, Fabric_Width_2__c, Fabric_Width__c,
                                         Flat_Panel_Pins__c, Flip__c, Font_Size_2__c, Font_Size__c, Font_Type__c,
                                         Freight_Code__c, Front_Apron_Height__c, Front_Apron_Length__c, Fullness__c, Grommet_Color__c,
                                         Height_2__c, Height_3__c, Height__c, Hem_Bar__c, Horizontal_Alignment__c,
                                         Include_Edge_Banding__c, Installation__c, Is_Custom_Product__c, Is_Hardware__c, Is_Parent__c,
                                         Item_Allocation_2__c, Item_Allocation__c, Item_Number__c, Item_Type__c, Labor__c,
                                         Length__c, Lift_2__c, Lift__c, LineNumber__c, Line_Number__c,
                                         Lining__c, Listello_Pattern__c, Master_Carrier__c, Mesh_Height__c, Mesh__c,
                                         Metric_Description_1__c, Metric_Description_2__c, Mounting_Type__c, NestedLineNumber__c, Note__c,
                                         Obsolete__c, Operator_Location__c, Operator__c, Order_Item_Breakout__c, Originating_Alternate_Header_Id__c,
                                         P_Note__c, Panels__c, Pattern_2__c, Pattern__c, Pick_Sequence__c,
                                         Pin_Setting__c, Price_Level__c, Price_Per_Unit_Base__c, Price_Per_Unit__c, Pricing_Updated_On__c,
                                         Privacy_Slat__c, Product_Description__c, Product_Number__c, Production_Type__c, Qualifications__c,
                                         Quote_Note__c, Radius__c, Railroad__c, Recalculate_Allocation__c, RecordId__c,
                                         Rendering_Part_Number__c, Rendering_Required__c, Return__c, Ripple_Fold_Fullness__c, Ripple_Fold_Tape_Clear__c,
                                         Rod_Color__c, Rod_Diameter__c, Rod_Part_Number__c, Rod_Style__c, Room_Location__c,
                                         Sequence_Number__c, Sewing_Type_2__c, Sewing_Type__c, Sheet_Size__c, Side_Apron_Left_Height__c,
                                         Side_Apron_Left_Length__c, Side_Apron_Right_Height__c, Side_Apron_Right_Length__c, Side_Splash_Left_Height__c, Side_Splash_Left_Length__c,
                                         Side_Splash_Right_Height__c, Side_Splash_Right_Length__c, Size_2__c, Size__c, Stiffener__c,
                                         Style__c, Substrate__c, Surface_Paint__c, T_Note_2__c, T_Note_3__c,
                                         T_Note__c, Taxable__c, Thickness__c, Tilt_2__c, Tilt__c,
                                         Total_Base_Price__c, Total_Cost__c, Total_Weight__c, Total_Yards__c, Type__c,
                                         Unit_Cost__c, Unit_Weight__c, Unit_of_Measure__c, Valance_2__c, Valance__c,
                                         Vendor_2__c, Vendor__c, Vertical_Alignment__c, W_Note__c, Weights__c,
                                         Width__c, Window_Depth__c, Windows__c, Yards_Per_Line__c, IDR_Line_Notes__c,
                                         Product__c, Quote_Line_Long_Description__c, SignScheduleId__c, Contains_Aspex__c, Custom_Part_Number__c,
                                         ParentId__c, Custom_Pricing__c, Yield__c, Material_Allocation_Note__c, Discount__c,
                                         Discount_Type__c, Contract_Price__c, Item_Allocation_Grouping__c, Total_Item_Allocation__c, Roll_Type__c,
                                         OriginatingQuoteLineItemId__c, Fabric_Part_Number__c, SeriesID__c
                                         FROM QuoteLineItem 
                                         WHERE Product2.Name != 'output' AND is_Parent__c = true 
                                         AND QuoteId =:Id.valueOf(quoteId) 
                                         ORDER BY Alternate__r.Sequence_Number__c ASC, Sequence_Number__c ASC, Pick_Sequence__c ASC];
        if (lineItems == null)
        {
            return new List<QuoteLineItem>();
        }
        return lineItems;
    }
}