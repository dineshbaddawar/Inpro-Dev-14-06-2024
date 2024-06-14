public with sharing class MultipleLevelItemViewHelper {
    @AuraEnabled
    public static List <item> getMIVItemInformation(string itemNumber, string description) {
        List <item> mivItemList = new List <item> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfSearchItem results = service.RetrieveSearchItems('dsj8U73_3nv3Dhba', itemNumber, description);
        if(results != null && results.SearchItem != null)
            for (sfdata.SearchItem retrievedItem: results.SearchItem) {
                item itm = new item();
                itm.ItemNumber = retrievedItem.ItemNumber;
                itm.Location = retrievedItem.Location;
                itm.ItemDesc1 = retrievedItem.ItemDesc1;
                itm.QtyAvailable = retrievedItem.QtyAvailable;
                itm.QtyOnHand = retrievedItem.QtyOnHand;
                itm.QtyAllocated = retrievedItem.QtyAllocated;
                itm.OnOrderQty = retrievedItem.OnOrderQty;
                itm.QtyInTransit = retrievedItem.QtyInTransit;
                itm.SoldPTD = retrievedItem.SoldPTD;                
                itm.SoldYTD = retrievedItem.SoldYTD;
                itm.SoldPY = retrievedItem.SoldPY;                
                itm.UsagePTD = retrievedItem.UsagePTD;
                itm.UsageYTD = retrievedItem.UsageYTD;
                itm.UsagePY = retrievedItem.UsagePY;                   
                mivItemList.Add(itm);
            }           
        return mivItemList;
    } 

    @AuraEnabled
    public static List <itemDetail> getMIVItemDetailInformation(string itemNumber, string location) {
        List <itemDetail> mivItemDetailList = new List <itemDetail> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfSearchItemDetail results = service.RetrieveSearchItemDetail('dsj8U73_3nv3Dhba', itemNumber, location);
        if(results != null && results.SearchItemDetail != null)
            for (sfdata.SearchItemDetail retrievedItem: results.SearchItemDetail) {
                itemDetail itm = new itemDetail();
                itm.DueDate = retrievedItem.DueDate;
                itm.ShipDate = retrievedItem.ShipDate;
                itm.OrderNumber = retrievedItem.OrderNumber;
                itm.LineItem = retrievedItem.LineItem;
                itm.Desc1 = retrievedItem.Desc1;
                itm.Desc2 = retrievedItem.Desc2;
                itm.QtyPurchased = retrievedItem.QtyPurchased;
                itm.QtyAllocated = retrievedItem.QtyAllocated;
                itm.RunningTotal = retrievedItem.RunningTotal;                
                itm.QtyOnHand = retrievedItem.QtyOnHand;
                itm.BackgroundColor = retrievedItem.BackgroundColor;                
                itm.WOStartColor = retrievedItem.WOStartColor;                  
                mivItemDetailList.Add(itm);
            }           
        return mivItemDetailList;
    }
    
    @AuraEnabled
    public static List <itemCost> getIMItemCostInformation(string itemNumber) {
        List <itemCost> imItemCostList = new List <itemCost> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfItemMasterCost results = service.RetrieveItemMasterCosts('dsj8U73_3nv3Dhba', itemNumber);
        if(results != null && results.ItemMasterCost != null)
            for (sfdata.ItemMasterCost retrievedItem: results.ItemMasterCost) {
                itemCost itmCost = new itemCost();
                itmCost.Location = retrievedItem.Location;
                itmCost.ItemCost = retrievedItem.ItemCost;
                itmCost.StockLocation1 = retrievedItem.StockLocation1;
                itmCost.StockLocation2 = retrievedItem.StockLocation2;               
                imItemCostList.Add(itmCost);
            }           
        return imItemCostList;
    }

    @AuraEnabled
    public static List <itemMaster> getItemMasterInformation(string itemNumber) {
        List <itemMaster> imItemMasterList = new List <itemMaster> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfItemMasterRecord results = service.RetrieveItemMaster('dsj8U73_3nv3Dhba', itemNumber);
        if(results != null && results.ItemMasterRecord != null)
            for (sfdata.ItemMasterRecord retrievedItem: results.ItemMasterRecord) {
                itemMaster iMaster = new itemMaster();
                iMaster.Description = retrievedItem.Description;
                iMaster.ActiveObsolete = retrievedItem.ActiveObsolete;
                iMaster.Stocked = retrievedItem.Stocked;
                iMaster.Controlled = retrievedItem.Controlled;
                iMaster.UnitOfMeasure = retrievedItem.UnitOfMeasure;
                iMaster.ItemWeight = retrievedItem.ItemWeight;
                iMaster.PurchasedMfg = retrievedItem.PurchasedMfg;
                iMaster.PrimaryLocation = retrievedItem.PrimaryLocation;
                iMaster.MaterialCostType = retrievedItem.MaterialCostType;
                iMaster.ProductCategory = retrievedItem.ProductCategory;
                iMaster.EndItemCode = retrievedItem.EndItemCode;
                iMaster.InspectionCode = retrievedItem.InspectionCode;
                iMaster.QtyPct = retrievedItem.QtyPct;               
                iMaster.MfgMethod = retrievedItem.MfgMethod;
                iMaster.BuyerPlanner = retrievedItem.BuyerPlanner;
                iMaster.DrawingNumber = retrievedItem.DrawingNumber;
                iMaster.DrawingRev = retrievedItem.DrawingRev;
                imItemMasterList.Add(iMaster);
            }           
        return imItemMasterList;
    }

    @AuraEnabled
    public static List <feature> getFOItemInformation(string itemNumber) {
        List <feature> foItemList = new List <feature> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfFeature results = service.RetrieveFeatures('dsj8U73_3nv3Dhba', itemNumber);
        if(results != null && results.Feature != null)
            for (sfdata.Feature retrievedFeature: results.Feature) {
                feature ftr = new feature();
                ftr.FeatureInternalID = retrievedFeature.FeatureInternalID;
                ftr.ItemNumber = retrievedFeature.ItemNumber;
                ftr.ItemDescription = retrievedFeature.ItemDescription;
                ftr.FeatureDescription = retrievedFeature.FeatureDescription;
                ftr.FeatureNumber = retrievedFeature.FeatureNumber;
                ftr.FeatureMinimum = retrievedFeature.FeatureMinimum;
                                   
                foItemList.Add(ftr);
            }           
        return foItemList;
    }
    
    @AuraEnabled
    public static List <featureOption> getFOItemDetailInformation(string featureInternalID) {
        List <featureOption> foItemDetailList = new List <featureOption> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfFeatureOption results = service.RetrieveFeatureOptions('dsj8U73_3nv3Dhba', featureInternalID);
        if(results != null && results.FeatureOption != null)
            for (sfdata.FeatureOption retrievedFeature: results.FeatureOption) {
                featureOption ftr = new featureOption();
                ftr.ParentItemNumber = retrievedFeature.ParentItemNumber;
                ftr.ItemNumber = retrievedFeature.ItemNumber;
                ftr.ComponentDescription = retrievedFeature.ComponentDescription;
                ftr.FeatureDescription = retrievedFeature.FeatureDescription;
                ftr.FeatureNumber = retrievedFeature.FeatureNumber;
                ftr.QtyPerPar = retrievedFeature.QtyPerPar;
                                   
                foItemDetailList.Add(ftr);
            }           
        return foItemDetailList;
    }
    
    @AuraEnabled
    public static List <billOfMaterial> getBOMItemDetailInformation(string itemNumber) {
        List <billOfMaterial> bomItemList = new List <billOfMaterial> ();       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        sfdata.ArrayOfBillOfMaterial results = service.RetrieveBOMProducts('dsj8U73_3nv3Dhba', itemNumber);
        if(results != null && results.BillOfMaterial != null)
            for (sfdata.BillOfMaterial retrievedBillOfMaterial: results.BillOfMaterial) {
                billOfMaterial bom = new billOfMaterial();
                bom.ItemNumber = retrievedBillOfMaterial.ItemNumber;
                bom.CompItemNumber = retrievedBillOfMaterial.CompItemNumber;
                bom.QtyPerPart = retrievedBillOfMaterial.QtyPerPart;
                bom.Desc1 = retrievedBillOfMaterial.Desc1;
                bom.Desc2 = retrievedBillOfMaterial.Desc2;
                bom.GroupByText = retrievedBillOfMaterial.GroupByText;
                bom.HasSubLevelItems = retrievedBillOfMaterial.HasSubLevelItems;
                bom.Location = retrievedBillOfMaterial.Location;
                bom.UOM = retrievedBillOfMaterial.UOM;            
                bomItemList.Add(bom);
            }           
        return bomItemList;
    }

    @AuraEnabled()
    public static List<PermissionSetAssignment> GetUserPermissionSets(String userId){         
        String qQuery = 'SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId';
        List<PermissionSetAssignment> permissions = Database.query(qQuery);
        return permissions;    
    }

    @AuraEnabled
    public static string RetrieveFeatureCostInformation(string itemNumber, string location) {                       
        sfdata.sfDataWebServiceSoap service = new sfdata.sfDataWebServiceSoap();
        service.timeout_x = 120000;
        string results = service.RetrieveFeatureCostInformation(itemNumber, location, '', 'dsj8U73_3nv3Dhba');       
        return results; 
    }  

    public class item {
        @AuraEnabled
        public string ItemNumber {get;set;}
        @AuraEnabled
        public string Location {get;set;}
        @AuraEnabled
        public string ItemDesc1 {get;set;}
        @AuraEnabled
        public decimal QtyAvailable {get;set;}
        @AuraEnabled
        public decimal QtyOnHand {get;set;}
        @AuraEnabled
        public decimal QtyAllocated {get;set;}
        @AuraEnabled
        public decimal OnOrderQty { get;set;}
        @AuraEnabled
        public decimal QtyInTransit { get;set;}
        @AuraEnabled
        public decimal SoldPTD { get;set;}
        @AuraEnabled
        public decimal SoldYTD { get;  set; }
        @AuraEnabled
        public decimal SoldPY { get; set; }       
        @AuraEnabled
        public decimal UsagePTD { get; set; }    
        @AuraEnabled
        public decimal UsageYTD { get; set; }
        @AuraEnabled
        public decimal UsagePY { get; set; }
        
    }

    public class itemDetail {
        @AuraEnabled
        public string DueDate {get;set;}
        @AuraEnabled
        public string ShipDate {get;set;}
        @AuraEnabled
        public string OrderNumber {get;set;}
        @AuraEnabled
        public string LineItem {get;set;}
        @AuraEnabled
        public string Desc1 {get;set;}
        @AuraEnabled
        public string Desc2 {get;set;}
        @AuraEnabled
        public string QtyPurchased { get;set;}
        @AuraEnabled
        public string QtyAllocated { get;set;}
        @AuraEnabled
        public string RunningTotal { get;set;}
        @AuraEnabled
        public string QtyOnHand { get;  set; }
        @AuraEnabled
        public string BackgroundColor { get; set; }       
        @AuraEnabled
        public string WOStartColor { get; set; }           
    }

    public class itemCost {
        @AuraEnabled
        public string Location {get;set;}
        @AuraEnabled
        public string ItemCost {get;set;}
        @AuraEnabled
        public string StockLocation1 {get;set;}
        @AuraEnabled
        public string StockLocation2 {get;set;}
    }

    public class feature {
        @AuraEnabled
        public string FeatureInternalID {get;set;}
        @AuraEnabled
        public string ItemNumber {get;set;}
        @AuraEnabled
        public string ItemDescription {get;set;}
        @AuraEnabled
        public string FeatureDescription {get;set;}
        @AuraEnabled
        public string FeatureNumber {get;set;}
        @AuraEnabled
        public string FeatureMinimum {get;set;}
    }

    public class featureOption {
        @AuraEnabled
        public string ParentItemNumber {get;set;}
        @AuraEnabled
        public string ItemNumber {get;set;}
        @AuraEnabled
        public string ComponentDescription {get;set;}
        @AuraEnabled
        public string FeatureNumber {get;set;}
        @AuraEnabled
        public string FeatureDescription {get;set;}
        @AuraEnabled
        public string QtyPerPar {get;set;}
    }

    public class billOfMaterial {
        @AuraEnabled
        public string ItemNumber {get;set;}
        @AuraEnabled
        public string CompItemNumber {get;set;}
        @AuraEnabled
        public string QtyPerPart {get;set;}
        @AuraEnabled
        public string Desc1 {get;set;}
        @AuraEnabled
        public string Desc2 {get;set;}
        @AuraEnabled
        public string GroupByText {get;set;}
        @AuraEnabled
        public Boolean HasSubLevelItems {get;set;}
        @AuraEnabled
        public string Location {get;set;}
        @AuraEnabled
        public string UOM {get;set;}
    }

    public class itemMaster {
        @AuraEnabled
        public string Description { get; set; }
        @AuraEnabled
        public string ActiveObsolete { get; set; }
        @AuraEnabled
        public string Stocked { get; set; }
        @AuraEnabled
        public string Controlled { get; set; }
        @AuraEnabled
        public string UnitOfMeasure { get; set; }
        @AuraEnabled
        public string ItemWeight { get; set; }
        @AuraEnabled
        public string PurchasedMfg { get; set; }
        @AuraEnabled
        public string PrimaryLocation { get; set; }
        @AuraEnabled
        public string MaterialCostType { get; set; }
        @AuraEnabled
        public string ProductCategory { get; set; }
        @AuraEnabled
        public string EndItemCode { get; set; }
        @AuraEnabled
        public string InspectionCode { get; set; }
        @AuraEnabled
        public string QtyPct { get; set; }
        @AuraEnabled
        public string MfgMethod { get; set; }
        @AuraEnabled
        public string BuyerPlanner { get; set; }
        @AuraEnabled
        public string DrawingNumber { get; set; }
        @AuraEnabled
        public string DrawingRev { get; set; }
        @AuraEnabled
        public string ItemCost { get; set; }
        @AuraEnabled
        public string StockLocation1 { get; set; }
        @AuraEnabled
        public string StockLocation2 { get; set; }
    }
}