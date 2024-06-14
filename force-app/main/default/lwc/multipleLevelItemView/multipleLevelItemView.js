import { LightningElement, track, api } from 'lwc';

import userId from '@salesforce/user/Id';
import GetMIVItemInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getMIVItemInformation';
import GetMIVItemDetailInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getMIVItemDetailInformation';
import GetIMItemCostInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getIMItemCostInformation';
import GetItemMasterInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getItemMasterInformation';
import GetFOItemInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getFOItemInformation';
import GetFOItemDetailInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getFOItemDetailInformation';
import GetBOMItemDetailInformation from '@salesforce/apex/MultipleLevelItemViewHelper.getBOMItemDetailInformation';
import GetUserPermissionSets from '@salesforce/apex/MultipleLevelItemViewHelper.GetUserPermissionSets';
import RetrieveFeatureCostInformation from '@salesforce/apex/MultipleLevelItemViewHelper.RetrieveFeatureCostInformation';

export default class MultipleLevelItemView extends LightningElement {
    
   
    loaded = true;
    Response = '';
    itemDetailScreen = false;
    foItemDetailScreen = false;
    mivItemNumber = '';
    mivDescription = '';

    @api recordId;
    
    @track foItemNumber = '';
    @track bomItemNumber = '';
    @track imItemNumber = '';
    @track mivItemSearchList = [];
    @track mivItemDetailSearchList = [];
    @track imCostSearchList = [];
    @track foItemSearchList = [];
    @track foItemDetailSearchList = [];
    @track bomItemDetailSearchList = [];
    @track featureCostItems = [];
    @track featureCostLocations = [];
    @track hasItemMasterPrivs = false;
    @track currentSort = { Column: "", Direction: "asc"};
    @track lastTarget = null;

    @track imDescription = '';
    @track imActiveObsolete = '';
    @track imControlled = '';
    @track imStocked = '';
    @track imItemWeight = '';
    @track imUnitOfMeasure = '';
    @track imPrimaryLocation = '';
    @track imPurchasedManufactured = '';
    @track imProductCategory = '';
    @track imMaterialCostType = '';
    @track imBuyerPlanner = '';
    @track imEndItemCode = '';
    @track imMfgMethod = '';
    @track imInspectionQtyPct = '';
    @track imStockLocation1 = '';
    @track imStockLocation2 = '';
    @track imDrawingNumber = '';
    @track imDrawingRev = '';

    @track fcItemNumber = '';
    @track fcLocation = '';
    @track fcQuantity = '';
    @track fcUnitCost = 0;
    @track fcExtCost = 0;
    @track fcError = '';
    @track displayFCError = false;
    @track count = 0;
    @track allQtyPerParInRange = true;
    @track isModal = false;

    connectedCallback() {
        // initialize component
        this.loaded = false;
       
        if (this.recordId != '' && this.recordId != undefined)
        {
            this.isModal = true;
        }
        this.populateFeatureCostLocations();
        this.getUserPermissionSets();
    }

    handleSort(event){
        let column = event.target.dataset.id;
        if (this.currentSort.Column == column && this.currentSort.Direction == "asc")
        { //descending sort
          this.fileList = this.mivItemSearchList.sort((x,y) => {
            return x[column] > y[column] ? -1 : x[column] < y[column] ? 1 : 0
          });
          this.currentSort.Column = column;
          this.currentSort.Direction = "desc";
          event.target.iconName = "utility:chevrondown";
          //Remove chevron from last column if column changed
          if (this.lastTarget != null && this.lastTarget.dataset.id != column) this.lastTarget.iconName = "";
          this.lastTarget = event.target;
        }
        else
        { //ascending sort
          this.fileList = this.mivItemSearchList.sort((x,y) => {
            return x[column] > y[column] ? 1 : x[column] < y[column] ? -1 : 0
          });
          this.currentSort.Column = column;
          this.currentSort.Direction = "asc";
          event.target.iconName = "utility:chevronup";
          //Remove chevron from last column if column changed
          if (this.lastTarget != null && this.lastTarget.dataset.id != column) this.lastTarget.iconName = "";
          this.lastTarget = event.target;
        }
        
      }
    
    populateFeatureCostLocations()
    {
        var apolloOption = {
            label: 'APOLLO',
            value: 'APOLLO'
        };
        var az2Option = {
            label: 'AZ2',
            value: 'AZ2'
        };
        var czAZOption = {
            label: 'ClickEze - AZ',
            value: 'ClickEze - AZ'
        };
        var czNCOption = {
            label: 'ClickEze - NC',
            value: 'ClickEze - NC'
        };
        var countyDraperieOption = {
            label: 'County Draperie',
            value: 'County Draperie'
        };
        var decoSurfOption = {
            label: 'Deco Surf',
            value: 'Deco Surf'
        };
        var dsOption = {
            label: 'Drop Ship',
            value: 'Drop Ship'
        };
        var firelineAZOption = {
            label: 'FIRELINE AZ',
            value: 'FIRELINE AZ'
        };
        var firelineNYOption = {
            label: 'FIRELINE NY',
            value: 'FIRELINE NY'
        };
        var inTransitOption = {
            label: 'IN TRANSIT',
            value: 'IN TRANSIT'
        };
        var inproDubaiOption = {
            label: 'Inpro Dubai',
            value: 'Inpro Dubai'
        };
        var ipcNCarolinaOption = {
            label: 'IPC N. Carolina',
            value: 'IPC N. Carolina'
        };
        var italypgWHOption = {
            label: 'ITALY PG WAREHS',
            value: 'ITALY PG WAREHS'
        };
        var juneTailorOption = {
            label: 'June Tailor',
            value: 'June Tailor'
        };
        var mrrHoldOption = {
            label: 'MRR Hold Area',
            value: 'MRR Hold Area'
        };
        var outsideInventorySuppliersOption = {
            label: 'OUTSIDE INVENTORY SUPPLIERS',
            value: 'OUTSIDE INVENTORY SUPPLIERS'
        };
        var primeWoodOption = {
            label: 'Primewood',
            value: 'Primewood'
        };
        var riOption = {
            label: 'RECEIVE INSPECT',
            value: 'RECEIVE INSPECT'
        };
        var unusableProductOption = {
            label: 'UNUSABLE PRODUCT',
            value: 'UNUSABLE PRODUCT'
        };
        this.featureCostLocations = [...this.featureCostLocations, apolloOption];
        this.featureCostLocations = [...this.featureCostLocations, az2Option];
        this.featureCostLocations = [...this.featureCostLocations, czAZOption];
        this.featureCostLocations = [...this.featureCostLocations, czNCOption];
        this.featureCostLocations = [...this.featureCostLocations, countyDraperieOption];
        this.featureCostLocations = [...this.featureCostLocations, decoSurfOption];
        this.featureCostLocations = [...this.featureCostLocations, dsOption];
        this.featureCostLocations = [...this.featureCostLocations, firelineAZOption];
        this.featureCostLocations = [...this.featureCostLocations, firelineNYOption];
        this.featureCostLocations = [...this.featureCostLocations, inTransitOption];
        this.featureCostLocations = [...this.featureCostLocations, inproDubaiOption];
        this.featureCostLocations = [...this.featureCostLocations, ipcNCarolinaOption];
        this.featureCostLocations = [...this.featureCostLocations, italypgWHOption];
        this.featureCostLocations = [...this.featureCostLocations, juneTailorOption];
        this.featureCostLocations = [...this.featureCostLocations, mrrHoldOption];
        this.featureCostLocations = [...this.featureCostLocations, outsideInventorySuppliersOption];
        this.featureCostLocations = [...this.featureCostLocations, primeWoodOption];
        this.featureCostLocations = [...this.featureCostLocations, riOption];
        this.featureCostLocations = [...this.featureCostLocations, unusableProductOption];
    }

    getUserPermissionSets()
    {
        var itemMasterPermissionSetId = '0PS4V000000epVfWAI';

        console.log("CHECK!");
        GetUserPermissionSets({
            userId: userId
        }).then(data => {
                if (data) {
                    try {
                        data.forEach(permission => {
                            console.log(permission.PermissionSetId);
                            if(permission.PermissionSetId == itemMasterPermissionSetId)
                                this.hasItemMasterPrivs = true;
                        });
                        this.loaded = true;
                    } catch (error) {
                        console.log("Error Retrieving Permission Sets: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }

            })
            .catch(error => {
                // TODO: handle error
                console.log("Error Loading The Product Information: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    handleMIVSearchClick() {
        this.loaded = false;
        this.callMIVSearch();
    }

    callMIVSearch()
    {
        try {
            console.log("Item Number: " + this.mivItemNumber);
            GetMIVItemInformation({
                itemNumber: this.mivItemNumber,
                description: this.mivDescription
                }).then(data => {
                    if (data) {
                        try {
                            this.mivItemSearchList = [];
                            var count = 0; 
                            data.forEach(item => {                           
                                var newItem = {
                                    ItemDesc1: item.ItemDesc1,
                                    ItemNumber: item.ItemNumber,
                                    Location: item.Location,
                                    OnOrderQty: item.OnOrderQty,
                                    QtyAllocated: item.QtyAllocated,
                                    QtyAvailable: item.QtyAvailable,
                                    QtyInTransit: item.QtyInTransit,
                                    QtyOnHand: item.QtyOnHand,
                                    SoldPTD: item.SoldPTD,
                                    SoldPY: item.SoldPY,
                                    SoldYTD: item.SoldYTD,
                                    UsagePTD: item.UsagePTD,
                                    UsagePY: item.UsagePY,                                   
                                    UsageYTD: item.UsageYTD,
                                    ItemKey: count
                                };   
                                count++;
                                this.mivItemSearchList.push(newItem);
                            });
                        } catch (error) {
                            console.log("Error Retrieving Items: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
    
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for items: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for items: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleMIVDetailsClick(event) {
        try {           
            if (event.target.accessKey != null) {
                var filteredLine = this.mivItemSearchList.filter(x => {
                    return x.ItemKey == event.target.accessKey
                })[0];
                this.loaded = false;
                this.callMIVDetailSearch(filteredLine.ItemNumber, filteredLine.Location);
            }
            else
                console.log("Error retrieving details.");
        } catch (error) {
            console.log(error);
        }
    }

    callMIVDetailSearch(itemNumber, location)
    {
        try {
            GetMIVItemDetailInformation({
                itemNumber: itemNumber,
                location: location
                }).then(data => {
                    if (data) {
                        try {
                            console.log("TEST");
                            this.mivItemDetailSearchList = [];
                            data.forEach(itemDetail => {
                                var newItem = {
                                    ItemNumber: itemNumber,
                                    DueDate: itemDetail.DueDate,
                                    ShipDate: itemDetail.ShipDate,
                                    OrderNumber: itemDetail.OrderNumber,
                                    LineItem: itemDetail.LineItem,
                                    Desc1: itemDetail.Desc1,
                                    QtyPurchased: itemDetail.QtyPurchased,
                                    QtyAllocated: itemDetail.QtyAllocated,
                                    RunningTotal: itemDetail.RunningTotal,
                                    QtyOnHand: itemDetail.QtyOnHand,
                                    BackgroundColor: itemDetail.BackgroundColor,
                                    WOStartColor: itemDetail.WOStartColor
                                };   
                                this.mivItemDetailSearchList.push(newItem);
                            });
                        } catch (error) {
                            console.log("Error retrieving item details: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.itemDetailScreen = true;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for items: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for items: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleIMCostSearchClick(event)
    {
        this.loaded = false;
        this.callIMCostSearch();
    }

    callIMCostSearch()
    {
        try {
            GetIMItemCostInformation({
                itemNumber: this.imItemNumber
                }).then(data => {
                    if (data) {
                        try {
                            this.imCostSearchList = [];
                            data.forEach(itemCost => {
                                var newItem = {
                                    Location: itemCost.Location,
                                    ItemCost: itemCost.ItemCost,
                                    StockLocation1: itemCost.StockLocation1,
                                    StockLocation2: itemCost.StockLocation2
                                };   
                                this.imCostSearchList.push(newItem);
                            });
                            try {
                                GetItemMasterInformation({
                                    itemNumber: this.imItemNumber
                                    }).then(data => {
                                        if (data) {
                                            try {
                                                var imCount = 0;
                                                data.forEach(itemMaster => {
                                                    imCount = imCount + 1;
                                                    this.imDescription = itemMaster.Description;
                                                    this.imActiveObsolete = itemMaster.ActiveObsolete;
                                                    this.imControlled = itemMaster.Controlled;
                                                    this.imStocked = itemMaster.Stocked;
                                                    this.imItemWeight = itemMaster.ItemWeight;
                                                    this.imUnitOfMeasure = itemMaster.UnitOfMeasure;
                                                    this.imPrimaryLocation = itemMaster.PrimaryLocation;
                                                    this.imPurchasedManufactured = itemMaster.PurchasedMfg;
                                                    this.imProductCategory = itemMaster.ProductCategory;
                                                    this.imMaterialCostType = itemMaster.MaterialCostType;
                                                    this.imBuyerPlanner = itemMaster.BuyerPlanner;
                                                    this.imEndItemCode = itemMaster.EndItemCode;
                                                    this.imMfgMethod = itemMaster.MfgMethod;
                                                    this.imInspectionQtyPct = itemMaster.QtyPct;
                                                    this.imStockLocation1 = itemMaster.StockLocation1;
                                                    this.imStockLocation2 = itemMaster.StockLocation2;
                                                    this.imDrawingNumber = itemMaster.DrawingNumber;
                                                    this.imDrawingRev = itemMaster.DrawingRev;
                                                });
                                                if(imCount == 0)
                                                {
                                                    this.imDescription = '';
                                                    this.imActiveObsolete = '';
                                                    this.imControlled = '';
                                                    this.imStocked = '';
                                                    this.imItemWeight = '';
                                                    this.imUnitOfMeasure = '';
                                                    this.imPrimaryLocation = '';
                                                    this.imPurchasedManufactured = '';
                                                    this.imProductCategory = '';
                                                    this.imMaterialCostType = '';
                                                    this.imBuyerPlanner = '';
                                                    this.imEndItemCode = '';
                                                    this.imMfgMethod = '';
                                                    this.imInspectionQtyPct = '';
                                                    this.imStockLocation1 = '';
                                                    this.imStockLocation2 = '';
                                                    this.imDrawingNumber = '';
                                                    this.imDrawingRev = '';
                                                }
                                            } catch (error) {
                                                console.log("Error retrieving item master: " + error);
                                            }
                        
                                        } else if (error) {
                                            this.error = error;
                                            console.log(error);
                                        }
                                        this.loaded = true;
                                    })
                                    .catch(error => {
                                        // TODO: handle error
                                        var errorJson = JSON.stringify(error);
                                        console.log("Error searching for item master: " + errorJson);
                                        this.Response = errorJson;
                                        this.loaded = true;
                                    });
                    
                            } catch (error) {
                                var errorJson = JSON.stringify(error);
                                console.log("Error searching for item master: " + errorJson);
                                this.Response = errorJson;
                                this.loaded = true;
                            }
                        } catch (error) {
                            console.log("Error retrieving item costs: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for item costs: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for items: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleFOSearchClick(event)
    {
        console.log("asdasd");
        this.loaded = false;
        this.callFeatureSearch();
    }

    callFeatureSearch()
    {
        try {
            console.log("before");
            GetFOItemInformation({
                itemNumber: this.foItemNumber
                }).then(data => {
                    if (data) {
                        try {
                            console.log("after");
                            this.foItemSearchList = [];
                            data.forEach(feature => {
                                var newItem = {
                                    FeatureInternalID: feature.FeatureInternalID,
                                    ItemNumber: feature.ItemNumber,
                                    ItemDescription: feature.ItemDescription,
                                    FeatureDescription: feature.FeatureDescription,
                                    FeatureNumber: feature.FeatureNumber,
                                    FeatureMinimum: feature.FeatureMinimum
                                };   
                                this.foItemSearchList.push(newItem);
                            });
                        } catch (error) {
                            console.log("Error retrieving features: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for features: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for features: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleFeatureOptionsClick(event) {
        try {
            if (event.target.accessKey != null) {
                this.loaded = false;
                console.log(event.target.accessKey);
                this.callFeatureOptionsSearch(event.target.accessKey);               
            }
            else
                console.log("Error retrieving details.");
        } catch (error) {
            console.log(error);
        }
    }

    callFeatureOptionsSearch(featureInternalID)
    {
        try {
            GetFOItemDetailInformation({
                featureInternalID: featureInternalID
                }).then(data => {
                    if (data) {
                        try {
                            this.foItemDetailSearchList = [];
                            data.forEach(featureOption => {
                                var newItem = {
                                    ParentItemNumber: featureOption.ParentItemNumber,
                                    ItemNumber: featureOption.ItemNumber,
                                    ComponentDescription: featureOption.ComponentDescription,
                                    FeatureNumber: featureOption.FeatureNumber,
                                    FeatureDescription: featureOption.FeatureDescription,
                                    QtyPerPar: featureOption.QtyPerPar
                                };   
                                this.foItemDetailSearchList.push(newItem);
                            });
                        } catch (error) {
                            console.log("Error retrieving feature options: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.foItemDetailScreen = true;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for feature options: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for feature options: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleBOMSearchClick(event)
    {
        this.loaded = false;
        this.callBOMSearch();
    }

    callBOMSearch()
    {
        try {
            console.log(this.bomItemNumber);
            GetBOMItemDetailInformation({               
                itemNumber: this.bomItemNumber
                }).then(data => {
                    if (data) {
                        try {
                            this.bomItemDetailSearchList = [];
                            data.forEach(billOfMaterial => {
                                var newItem = {
                                    ItemNumber: billOfMaterial.ItemNumber,
                                    CompItemNumber: billOfMaterial.CompItemNumber,
                                    QtyPerPart: billOfMaterial.QtyPerPart,
                                    Desc1: billOfMaterial.Desc1,
                                    Desc2: billOfMaterial.Desc2,
                                    GroupByText: billOfMaterial.GroupByText,
                                    HasSubLevelItems: billOfMaterial.HasSubLevelItems,
                                    Location: billOfMaterial.Location,
                                    UOM: billOfMaterial.UOM
                                };   
                                this.bomItemDetailSearchList.push(newItem);
                            });
                        } catch (error) {
                            console.log("Error retrieving bill of material: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for bill of material: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for bill of material: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleBOMSearchFromGridClick(event)
    {
        try {
            if (event.target.accessKey != null) {
                this.loaded = false;
                this.callBOMFromGridSearch(event.target.accessKey);
            }
            else
                console.log("Error retrieving details.");
        } catch (error) {
            console.log(error);
        }
    }

    callBOMFromGridSearch(itemNumber)
    {
        try {
            GetBOMItemDetailInformation({
                itemNumber: itemNumber
                }).then(data => {
                    if (data) {
                        try {
                            this.bomItemDetailSearchList = [];
                            data.forEach(billOfMaterial => {
                                var newItem = {
                                    ItemNumber: billOfMaterial.ItemNumber,
                                    CompItemNumber: billOfMaterial.CompItemNumber,
                                    QtyPerPart: billOfMaterial.QtyPerPart,
                                    Desc1: billOfMaterial.Desc1,
                                    Desc2: billOfMaterial.Desc2,
                                    GroupByText: billOfMaterial.GroupByText,
                                    HasSubLevelItems: billOfMaterial.HasSubLevelItems,
                                    Location: billOfMaterial.Location,
                                    UOM: billOfMaterial.UOM
                                };   
                                this.bomItemDetailSearchList.push(newItem);
                            });
                        } catch (error) {
                            console.log("Error retrieving bill of material: " + error);
                        }
    
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error searching for bill of material: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error searching for bill of material: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    returnToSearch(event)
    {
        this.itemDetailScreen = false;
    }

    returnToFOSearch(event)
    {
        this.foItemDetailScreen = false;
    }

    handleFormMIVItemChange(event) {
        console.log("asdasd");
        this.mivItemNumber = event.target.value;
    }

    handleFormMIVDescriptionChange(event) {
        console.log("asdasd");
        this.mivDescription = event.target.value;
    }

    handleFormFOItemChange(event) {
        this.foItemNumber = event.target.value;
    }

    handleFormBOMItemChange(event) {
        this.bomItemNumber = event.target.value;
    }

    handleFormIMItemChange(event) {
        this.imItemNumber = event.target.value;
    }

    handleFeatureItemNumberChange(event){
        this.fcItemNumber = event.target.value;
    }

    handleFeatureLocationChange(event){
        this.fcLocation = event.target.value;
    }

    handleFeatureQuantityChange(event){
        this.fcQuantity = event.target.value;
    }

    handleFeatureItemChecked(event){
        console.log('Check Test');
        let Id = event.target.accessKey;
        var selectedItem = this.featureCostItems.filter(product => {
            return product.LineID == Id;
        })[0];

        //find how many items were selected for the current feature number
        var featureItemsSelected = this.featureCostItems.filter(product => {
            return selectedItem.FeatureNumber == product.FeatureNumber && product.Selected == true;
        });

        if((featureItemsSelected.length + 1 > 1) && event.target.checked)
        {
            //this.displayFCError = true;
            //this.fcError = "Error: A feature option has already been selected for the current feature.";
            alert("Error: A feature option has already been selected for the current feature.");
            event.target.checked = false;
            selectedItem.Selected = false;
        }
        else
        {
            this.displayFCError = false;
            selectedItem.Selected = event.target.checked;
        }
        
    }

    closeFCErrorMessage()
    {       
        this.displayFCError = false;
    }

    handleCalculateCost(){
        try
        {
            this.displayFCError = false;
            this.fcUnitCost = 0;
            this.fcExtCost = 0;
            this.allQtyPerParInRange = true;
            if(this.fcQuantity != null && this.fcQuantity != '')
            {
                //add required features to array
                var requiredFeatures = [];
                for(var i = 0; i < this.featureCostItems.length; i++)
                {
                    if(this.featureCostItems[i].FeatureRequired == "Y" && 
                      !requiredFeatures.includes(this.featureCostItems[i].FeatureNumber))
                        requiredFeatures.push(this.featureCostItems[i].FeatureNumber);

                    if(this.featureCostItems[i].FeatureMin > this.featureCostItems[i].QtyPerPar || this.featureCostItems[i].FeatureMax < this.featureCostItems[i].QtyPerPar)
                        this.allQtyPerParInRange = false;
                }

                //remove required features that are selected
                for(var i = 0; i < this.featureCostItems.length; i++)
                {
                    if(this.featureCostItems[i].FeatureRequired == "Y" && 
                       requiredFeatures.includes(this.featureCostItems[i].FeatureNumber) && this.featureCostItems[i].Selected)
                    {
                        var requiredFeatureIndex = requiredFeatures.indexOf(this.featureCostItems[i].FeatureNumber);
                        requiredFeatures.splice(requiredFeatureIndex,1);
                    }
                }

                if(requiredFeatures.length > 0)
                {
                    alert("Error: One or more required features have not been selected. Missing Required Features: " + requiredFeatures.toString());
                }
                else if (!this.allQtyPerParInRange)
                {
                    alert("Error: One or more selected options are out of the min/max Qty Per Par range.");
                }
                else
                {
                    var selectedItems = this.featureCostItems.filter(product => {
                        return product.Selected == true;
                    });
                    for(var i = 0; i < selectedItems.length; i++)
                    {
                        this.fcUnitCost += (selectedItems[i].QtyPerPar * selectedItems[i].StandardCost);
                    }
                    this.fcExtCost = this.fcUnitCost * this.fcQuantity;
                    
                    this.fcUnitCost = this.roundToTwo(this.fcUnitCost);
                    this.fcExtCost = this.roundToTwo(this.fcExtCost);
                }               
            }
            else
            {
                this.displayFCError = true;
                this.fcError = "Error: You must first specify a quantity to generate cost.";
                this.loaded = true;
            }
        }
        catch(ex)
        {
            this.displayFCError = true;
            this.fcError = ex;
            this.loaded = true;
        }
    }

    handlePopulateFeatureOptions() {
        this.displayFCError = false;
        console.log("Feature Cost Retrieval Start");
        this.loaded = false;
        this.fcUnitCost = 0;
        this.fcExtCost = 0;
        RetrieveFeatureCostInformation({
            itemNumber: this.fcItemNumber,
            location: this.fcLocation
        }).then(data => {
            if (data) {
                try {
                    data = JSON.parse(data);                                           
                    if(data.Status)
                    {
                        if(data.FeatureOptions != null)
                        {
                            this.count = 0;
                            this.featureCostItems = [];                           
                            for(var i = 0; i < data.FeatureOptions.length; i++)
                            {
                                var featureOption = {
                                    ParentItemNumber: data.FeatureOptions[i].ParentItemNumber,
                                    FeatureNumber: data.FeatureOptions[i].FeatureNumber,
                                    FeatureRequired: data.FeatureOptions[i].FeatureRequired,
                                    FeatureDescription: data.FeatureOptions[i].FeatureDescription,
                                    FeatureMax: data.FeatureOptions[i].FeatureMax,
                                    FeatureMin: data.FeatureOptions[i].FeatureMin,
                                    ItemNumber: data.FeatureOptions[i].ItemNumber,
                                    ComponentDescription: data.FeatureOptions[i].ComponentDescription,
                                    QtyPerPar: data.FeatureOptions[i].QtyPerPar,
                                    StandardCost: data.FeatureOptions[i].StandardCost,
                                    Selected: false,
                                    LineID: this.count,
                                    BackgroundColor: data.FeatureOptions[i].BackgroundColor
                                };
                                
                                this.count++;
                                this.featureCostItems = [...this.featureCostItems, featureOption];
                            }
                        }
                    }
                    else
                    {
                        this.displayFCError = true;
                        this.fcError = data.Message;
                        this.loaded = true;
                    }                                                                                                     
                } catch (error) {
                    this.displayFCError = true;
                    this.fcError = "Error retrieving the feature cost information: " + error;
                    this.loaded = true;
                }
            } else if (error) {
                this.displayFCError = true;
                this.fcError = "Error retrieving the feature cost information: " + error;
                this.loaded = true;

            }
            this.loaded = true;
        })
        .catch(error => {
            this.displayFCError = true;
            this.fcError = "Error retrieving the feature cost information: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
            this.loaded = true;
        });
    }

    handleGridInputChange(event){
        let selectedItem = this.featureCostItems.filter(function (product) {
            return product.LineID === event.target.accessKey;
        })[0];

        if (event.target.name == 'QtyPerPar') {
            selectedItem.QtyPerPar = event.target.value;
        }
    }

    roundToTwo(num) {
        return +(Math.round(num + "e+2") + "e-2");
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}