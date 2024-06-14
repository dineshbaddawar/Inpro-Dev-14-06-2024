import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import getExistingProductList from '@salesforce/apex/QuickConfigHelper.getExistingProductList';
import colorSearch from '@salesforce/apex/QuickConfigHelper.colorsearch';
import productSearch from '@salesforce/apex/QuickConfigHelper.productsearch';
import productSignSearch from '@salesforce/apex/QuickConfigHelper.productSignSearch';
import saveConfiguration from '@salesforce/apex/QuickConfigHelper.saveConfiguration';
import getDivision from '@salesforce/apex/QuickConfigHelper.getDivision';

//Signscape Methods
import getMountingTypes from '@salesforce/apex/QuickConfigHelper.getMountingTypes';
import getFontSizes from '@salesforce/apex/QuickConfigHelper.getFontSizes';
import getFontTypes from '@salesforce/apex/QuickConfigHelper.getFontTypes';
import getHorizontalJustifications from '@salesforce/apex/QuickConfigHelper.getHorizontalJustifications';
import getVerticalJustifications from '@salesforce/apex/QuickConfigHelper.getVerticalJustifications';
import getCollections from '@salesforce/apex/QuickConfigHelper.getCollections';
import getProductionTypes from '@salesforce/apex/QuickConfigHelper.getProductionTypes';
import createAsyncProcess from '@salesforce/apex/QuickConfigHelper.createAsyncProcess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import userId from '@salesforce/user/Id';

export default class quickConfig extends LightningElement {
    @api recordId;
    loaded = false;
    keyIndex = 0;
    @track secondarySearchTerm = '';
    @track theRecord = {};
    @track error;
    //per alternate list
    @track existingProductList = [];
    //current config list
    @track filteredProductList = [];
    @track removedProductList = [];
    @track alternateList = [];
    @track selectedItem;
    @track cacheCounter = 0
    division = 'DW';
    isSignScape = false;
    showError = false;
    errorMessage = '';
    toastMessage = 'Save Complete';

    @track mountingTypes = [];
    @track fontSizes = [];
    @track fontTypes = [];
    @track horizontalJustifications = [];
    @track verticalJustifications = [];
    @track collections = [];
    @track productionTypes = [];
     @track selectedProduct = [];
     @track selectedQty = '';
     @track selectedColor = [];
     @track selectedNotes = '';
     @track closeWindow = false;


    connectedCallback() {
        // initialize component
        this.loadExistingProducts();
        this.loadDivision();

    }

    createAsyncTask() {              
        console.log(this.recordId);
        console.log(userId);
        console.log("create async task");
        createAsyncProcess({
                recordId: this.recordId,
                UserId: userId
            }).then(data => {
                if (data) {        
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);              
                    
                    if (data.includes("Save in progress")) {
                        this.showError = true;
                        this.errorMessage = data;
                        this.loaded = true;
                    }
                    else
                        this.finishSave();
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }                
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error creating async process: " + errorJson);
                this.loaded = true;
            });
    }

    loadExistingProducts() {
        var date = Date().toLocaleString();
        console.log(date);
        console.log(this.recordId);
        getExistingProductList({
                recordId: this.recordId,
                cache: date
            }).then(data => {
                if (data) {
                    //this.existingProductList = data;
                    //change data to writeable
                    try {
                        console.log("start wire");
                        data.forEach(item => {

                            var newItem = {
                                Id: item.Id,
                                rId: item.rId,
                                Name: item.Name,
                                Color: item.Color,
                                Quantity: item.Quantity,
                                Description: item.Description,
                                AlternateName: item.AlternateName,
                                AlternateId: item.AlternateId,
                                rAlternateId: item.rAlternateId,
                                ColorPalette: item.ColorPalette,
                                PickSequence: item.PickSequence,
                                IsRemoved: false,
                                Selected: false,
                                Checked: false,
                                bpColorCode: item.bpColorCode,
                                bpColorPallette: item.bpColorPallette,
                                txColorCode: item.txColorCode,
                                txColorPallette: item.txColorPallette,
                                acColorCode: item.acColorCode,
                                acColorPallette: item.acColorPallette,
                                fpColorCode: item.fpColorCode,
                                fpColorPallette: item.fpColorPallette,
                                AccentColor: item.AccentColor,
                                MountingType: item.MountingType,
                                FontType: item.FontType,
                                FontSize: item.FontSize,
                                HorizontalAlign: item.HorizontalAlign,
                                VerticalAlign: item.VerticalAlign
                            };
                            console.log("adding: " + item.Name);

                            var newLookup = {
                                id: '1',
                                sObjectType: 'item_color__c',
                                icon: 'standard:account',
                                title: newItem.Color,
                                subtitle: newItem.Color
                            };
                            //if (newItem.Color !== '')
                            newItem.ColorLookup = newLookup;

                            var newBPColorCodeLookup = {
                                id: '1',
                                sObjectType: 'item_color__c',
                                icon: 'standard:account',
                                title: newItem.bpColorCode,
                                subtitle: newItem.bpColorCode
                            };
                            //  if (newItem.bpColorCode !== '')
                            newItem.bpColorCodeLookup = newBPColorCodeLookup;


                            var newtxColorCodeLookup = {
                                id: '1',
                                sObjectType: 'item_color__c',
                                icon: 'standard:account',
                                title: newItem.txColorCode,
                                subtitle: newItem.txColorCode
                            };
                            // if (newItem.txColorCode !== '')
                            newItem.txColorCodeLookup = newtxColorCodeLookup;

                            var newacColorCodeLookup = {
                                id: '1',
                                sObjectType: 'item_color__c',
                                icon: 'standard:account',
                                title: newItem.acColorCode,
                                subtitle: newItem.acColorCode
                            };
                            //   if (newItem.acColorCode !== '')
                            newItem.acColorCodeLookup = newacColorCodeLookup;

                            var newfpColorCodeLookup = {
                                id: '1',
                                sObjectType: 'item_color__c',
                                icon: 'standard:account',
                                title: newItem.fpColorCode,
                                subtitle: newItem.fpColorCode
                            };
                            //  if (newItem.fpColorCode !== '')
                            newItem.fpColorCodeLookup = newfpColorCodeLookup;


                            var newAccentColorLookup = {
                                id: '1',
                                sObjectType: 'item_color__c',
                                icon: 'standard:account',
                                title: newItem.AccentColor,
                                subtitle: newItem.AccentColor
                            };
                            //   if (newItem.AccentColor !== '')
                            newItem.AccentColorLookup = newAccentColorLookup;


                            this.existingProductList.push(newItem);

                            var newAlternate = {
                                AlternateName: newItem.AlternateName,
                                AlternateId: newItem.AlternateId,
                                rAlternateId: newItem.rAlternateId
                            }

                            var duplicate = false;
                            if (this.alternateList.length > 0) {

                                this.alternateList.forEach(element => {
                                    if (element.AlternateId == newAlternate.AlternateId)
                                        duplicate = true;
                                });
                            }

                            if (!duplicate) {
                                this.alternateList.push(newAlternate);
                                console.log("adding new alternate: " + newAlternate.AlternateName + " " + newAlternate.AlternateId);
                            }
                        });

                        this.filteredProductList = this.existingProductList;

                        if (this.alternateList.length < 1) {
                            var startingAlternate = {
                                AlternateName: 'Base',
                                AlternateId: 0,
                                rAlternateId: -1
                            }
                            this.alternateList.push(startingAlternate);
                        }

                        this.selectedItem = this.alternateList[0].AlternateId;
                        this.filterListByAlternate();
                        console.log("end wire");
                    } catch (error) {
                        console.log("Error Binding Existing Products: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;

            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting products: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
            });
    }

    loadDivision() {
        getDivision({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {

                        console.log(data);
                        if (data != null && data != 'IPC' && data != 'JointMaster' && data != 'Ascend') {
                            this.division = 'SS';
                            this.isSignScape = true;
                            //this.loadMountingTypes();
                        }
                    } catch (error) {
                        console.log("Error Loading Division: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting division: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    @wire(getMountingTypes) wiredMountingTypes({
        error,
        data
    }) {
        if (data) {
            //this.existingProductList = data;
            //change data to writeable
            try {
                console.log("start wire");
                data.forEach(x => {
                    var option = {
                        label: x,
                        value: x
                    };
                    // this.mountingTypes.push(option);
                    this.mountingTypes = [...this.mountingTypes, option];
                });

            } catch (error) {
                console.log("Error Binding Mounting Types: " + error);
            }
        }
    }

    @wire(getFontSizes) wiredFontSizes({
        error,
        data
    }) {
        if (data) {
            //this.existingProductList = data;
            //change data to writeable
            try {
                console.log("start wire");
                data.forEach(x => {
                    var option = {
                        label: x,
                        value: x
                    };
                    // this.mountingTypes.push(option);
                    this.fontSizes = [...this.fontSizes, option];
                });

            } catch (error) {
                console.log("Error Binding Font Sizes: " + error);
            }
        }
    }

    @wire(getFontTypes) wiredFontTypes({
        error,
        data
    }) {
        if (data) {
            //this.existingProductList = data;
            //change data to writeable
            try {
                console.log("start wire");
                data.forEach(x => {
                    var option = {
                        label: x,
                        value: x
                    };
                    // this.mountingTypes.push(option);
                    this.fontTypes = [...this.fontTypes, option];
                });

            } catch (error) {
                console.log("Error Binding Font Types: " + error);
            }
        }
    }

    @wire(getHorizontalJustifications) wiredHorizontalJustifications({
        error,
        data
    }) {
        if (data) {
            //this.existingProductList = data;
            //change data to writeable
            try {
                console.log("start wire");
                data.forEach(x => {
                    var option = {
                        label: x,
                        value: x
                    };
                    // this.mountingTypes.push(option);
                    this.horizontalJustifications = [...this.horizontalJustifications, option];
                });

            } catch (error) {
                console.log("Error Binding Horizontal Justifications: " + error);
            }
        }
    }

    @wire(getVerticalJustifications) wiredVerticalJustifications({
        error,
        data
    }) {
        if (data) {
            //this.existingProductList = data;
            //change data to writeable
            try {
                console.log("start wire");
                data.forEach(x => {
                    var option = {
                        label: x,
                        value: x
                    };
                    // this.mountingTypes.push(option);
                    this.verticalJustifications = [...this.verticalJustifications, option];
                });

            } catch (error) {
                console.log("Error Binding Horizontal Justifications: " + error);
            }
        }
    }

    handleSelected(event) {
        try {
            //console.log(event.detail.name);
            if (event.detail.name || event.detail.name === 0) {
                this.selectedItem = event.detail.name;
                console.log(event.detail.name);
                //TODO: Filter this by alternate
                this.filterListByAlternate();
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;

            if (event.target.name == "Name") {
                //this is the color palette on a product
                this.secondarySearchTerm = subTitle;
                this.theRecord["ColorPalette"] = subTitle;
            }


        }
        // In 1 line, assign the value to the property
        this.theRecord[event.target.name] = name;

    }

    handleFormInputChange(event) {
        // In 1 line, assign the value to the property
        this.theRecord[event.target.name] = event.target.value;
        //console.log(event.target.name + ' now is set to ' + event.target.value);
    }

    handleGridInputChange(event) {
        if (this.filteredProductList.length > 0) {
            let value = event.target.value;
            let selectedItem = this.filteredProductList.filter(function (product) {
                return product.Id === event.target.accessKey;
            })[0];

            console.log("selected value changing: " + value + " " + selectedItem.Id + " key: " + event.target.accessKey);
            if (event.target.name == "Color") {
                selectedItem.Color = value;
            } else if (event.target.name == "Quantity") {
                selectedItem.Quantity = value;
            } else if (event.target.name == "Description") {
                selectedItem.Description = value;
            }
            else
            {
                selectedItem[event.target.name] = value;
                console.log(selectedItem[event.target.name]);
            }
        }
    }

    handleGridLookupSelectionChange(event) {
        let selectedItem = this.filteredProductList.filter(function (product) {
            return product.Id === event.target.accessKey;
        })[0];
        var inputName = event.target.name;

        const selection = event.target.getSelection();
        var name = '';

        if (selection.length > 0) {
            name = selection[0].title;
            //var id = selection[0].id;
            //var subTitle = selection[0].subtitle;            
            var newLookup = {
                id: '1',
                sObjectType: 'item_color__c',
                icon: 'standard:account',
                title: name,
                subtitle: name
            };

            if (inputName == 'bpColorCode') {
                selectedItem.bpColorCodeLookup = newLookup;
                selectedItem.bpColorCode = name;
            } else if (inputName == 'Color') {
                selectedItem.ColorLookup = newLookup;
                selectedItem.Color = name;
            } else if (inputName == 'txColorCode') {
                selectedItem.txColorCodeLookup = newLookup;
                selectedItem.txColorCode = name;
            } else if (inputName == 'fpColorCode') {
                selectedItem.fpColorCodeLookup = newLookup;
                selectedItem.fpColorCode = name;
            } else if (inputName == 'AccentColor') {
                selectedItem.AccentColorLookup = newLookup;
                selectedItem.AccentColor = name;
            }
        } else {
            if (inputName == 'bpColorCode') {
                selectedItem.bpColorCodeLookup = [];
            } else if (inputName == 'Color') {
                selectedItem.ColorLookup = [];
            } else if (inputName == 'txColorCode') {
                selectedItem.txColorCodeLookup = [];
            } else if (inputName == 'fpColorCode') {
                selectedItem.fpColorCodeLookup = [];
            } else if (inputName == 'AccentColor') {
                selectedItem.AccentColorLookup = [];
            }
        }

    }

    addNewRow() {

        if(this.theRecord.Name != '' && this.theRecord.Name != null)
        {
        var id = this.keyIndex + 1;
        this.keyIndex++;
        let altNum = parseInt(this.selectedItem);
        console.log(altNum);
        let selectedAlternate = this.alternateList.filter(function (alt) {
            return parseInt(alt.AlternateId) === altNum;
        })[0];

        console.log("selected alternate: " + selectedAlternate.AlternateId);

        var newItem = [{
            Id: id.toString(),
            rId: "00000000-0000-0000-0000-000000000000",
            Name: this.theRecord.Name,
            Color: this.theRecord.Color,
            Quantity: this.theRecord.Quantity,
            Description: this.theRecord.Description,
            AlternateName: selectedAlternate.AlternateName,
            AlternateId: selectedAlternate.AlternateId,
            rAlternateId: selectedAlternate.rAlternateId,
            ColorPalette: this.theRecord.ColorPalette,
            IsRemoved: false,
            Selected: false,
            Checked: false,
            bpColorCode: this.theRecord.bpColorCode,
            bpColorPallette: this.theRecord.bpColorPallette,
            txColorCode: this.theRecord.txColorCode,
            txColorPallette: this.theRecord.txColorPallette,
            acColorCode: this.theRecord.acColorCode,
            acColorPallette: this.theRecord.acColorPallette,
            fpColorCode: this.theRecord.fpColorCode,
            fpColorPallette: this.theRecord.fpColorPallette,
            AccentColor: this.theRecord.AccentColor,
            MountingType: this.theRecord.MountingType,
            FontType: this.theRecord.FontType,
            FontSize: this.theRecord.FontSize,
            HorizontalAlign: this.theRecord.HorizontalAlign,
            VerticalAlign: this.theRecord.VerticalAlign
        }];


        var newLookup = {
            id: '1',
            sObjectType: 'item_color__c',
            icon: 'standard:account',
            title: this.theRecord.Color,
            subtitle: this.theRecord.Color
        };
        newItem[0].ColorLookup = newLookup;

        var newbpLookup = {
            id: '1',
            sObjectType: 'item_color__c',
            icon: 'standard:account',
            title: this.theRecord.bpColorCode,
            subtitle: this.theRecord.bpColorCode
        };
        newItem[0].bpColorCodeLookup = newbpLookup;

        var newtxLookup = {
            id: '1',
            sObjectType: 'item_color__c',
            icon: 'standard:account',
            title: this.theRecord.txColorCode,
            subtitle: this.theRecord.txColorCode
        };
        newItem[0].txColorCodeLookup = newtxLookup;

        var newfpLookup = {
            id: '1',
            sObjectType: 'item_color__c',
            icon: 'standard:account',
            title: this.theRecord.fpColorCode,
            subtitle: this.theRecord.fpColorCode
        };
        newItem[0].fpColorCodeLookup = newfpLookup;

        var newaccLookup = {
            id: '1',
            sObjectType: 'item_color__c',
            icon: 'standard:account',
            title: this.theRecord.acColorCode,
            subtitle: this.theRecord.acColorCode
        };
        newItem[0].AccentColorLookup = newaccLookup;

         this.theRecord.Name = '';
         this.theRecord.Color = '';
         this.theRecord.Quantity = '';
         this.theRecord.Description = '';

         this.selectedProduct = [];
         this.selectedQty = '';
         this.selectedColor = [];
         this.selectedNotes = '';         

         this.template.querySelectorAll('lightning-input[data-id="reset"]').forEach(element => {
            element.value = '';
          });

        this.filteredProductList = this.filteredProductList.concat(newItem);
        this.filterListByAlternate();
        }
        else
            alert('Please select a product, even if you type in a SKU, you must click or tab to a product.');
    }

    copyRow(event) {
        this.keyIndex = this.filteredProductList.length + 1;
        this.keyIndex++;
        var existing = this.filteredProductList.filter(function (product) {
            return product.Id === event.target.accessKey;
        })[0];
        var newItem = [{
            Id: this.keyIndex.toString(),
            rId: "00000000-0000-0000-0000-000000000000",
            Name: existing.Name,
            Color: existing.Color,
            Quantity: existing.Quantity,
            Description: existing.Description,
            AlternateName: existing.AlternateName,
            AlternateId: existing.AlternateId,
            rAlternateId: existing.rAlternateId,
            ColorPalette: existing.ColorPalette,
            ColorLookup: existing.ColorLookup,
            IsRemoved: false,
            Selected: false,
            Checked: false,
            bpColorCode: existing.bpColorCode,
            bpColorPallette: existing.bpColorPallette,
            txColorCode: existing.txColorCode,
            txColorPallette: existing.txColorPallette,
            acColorCode: existing.acColorCode,
            acColorPallette: existing.acColorPallette,
            fpColorCode: existing.fpColorCode,
            fpColorPallette: existing.fpColorPallette,
            AccentColor: existing.AccentColor,
            MountingType: existing.MountingType,
            FontType: existing.FontType,
            FontSize: existing.FontSize,
            HorizontalAlign: existing.HorizontalAlign,
            VerticalAlign: existing.VerticalAlign,
            fpColorCodeLookup: existing.fpColorCodeLookup,
            acColorCodeLookup: existing.acColorCodeLookup,
            bpColorCodeLookup: existing.fpColorCodeLookup,
            txColorCodeLookup: existing.fpColorCodeLookup,
            AccentColorLookup: existing.fpColorCodeLookup
        }];

        this.filteredProductList = this.filteredProductList.concat(newItem);
        this.filterListByAlternate();
    }

    removeRow(event) {
        // alert(event.target.accessKey);        
        // if (this.existingProductList.length >= 2) {
        console.log("remove: " + event.target.accessKey);
        var id = event.target.accessKey;
        console.log("count before delete: " + this.filteredProductList.length);

        //track removed products, so we can tell experlogix to delete them
        var existing = this.filteredProductList.filter(function (product) {
            return product.Id === event.target.accessKey;
        })[0];
        var newItem = [{
            Id: existing.Id,
            rId: existing.rId,
            Name: existing.Name,
            Color: existing.Color,
            Quantity: existing.Quantity,
            Description: existing.Description,
            AlternateName: existing.AlternateName,
            AlternateId: existing.AlternateId,
            rAlternateId: existing.rAlternateId,
            ColorPalette: existing.ColorPalette,
            ColorLookup: existing.ColorLookup,
            IsRemoved: true,
            Selected: false,
            Checked: false
        }];
        this.removedProductList = this.removedProductList.concat(newItem);

        this.filteredProductList = this.filteredProductList.filter(function (product) {
            return product.Id !== id;
        });
        console.log("count after delete: " + this.filteredProductList.length);
        this.filterListByAlternate();
    }

    filterListByAlternate() {

        try {


            let num = parseInt(this.selectedItem);
            //console.log(num);
            //console.log(this.existingProductList.length);
            if (this.filteredProductList.length > 0) {
                this.existingProductList = this.filteredProductList.filter(function (product) {
                    //console.log(product.Id);            
                    return parseInt(product.AlternateId) === parseInt(num);
                });//.sort((a, b) => (a.PickSequence > b.PickSequence) ? 1 : -1);
                // console.log(this.existingProductList.length);
                // console.log("filtered: " + this.filteredProductList.length);

            } else {
                this.existingProductList = [];
            }
            // console.log(this.existingProductList.length);
        } catch (error) {
            console.log(error);
        }
    }

    addNewAlternate() {
        var altName = prompt("New Alternate Name", "New Alernate");
        if (altName == "null" || altName == null || altName == "") {
            console.log("invalid alt name");
            return; //break out of the function early            
        }
        var newAltId = 1
        if (this.alternateList.length > 0)
            newAltId = this.alternateList[this.alternateList.length - 1].AlternateId + 1;
        console.log("new alt id: " + newAltId);
        var newItem = [{
            AlternateName: altName,
            AlternateId: newAltId,
            rAlternateId: -1
        }];

        this.alternateList = this.alternateList.concat(newItem);
        this.selectedItem = newItem[0].AlternateId;
    }

    copyAlternate() {
        var altName = prompt("New Alternate Name", "Duplicate Alernate");
        if (altName == "null" || altName == null || altName == "") {
            console.log("alt name null or empty");
            return; //break out of the function early
        }
        console.log("finding new alt id");

        var newAltId = 1
        if (this.alternateList.length > 0)
            newAltId = this.alternateList[this.alternateList.length - 1].AlternateId + 1

        console.log(newAltId);

        this.existingProductList.forEach(item => {
            var index = this.keyIndex + 1;
            var newItem = [{
                Id: index.toString(),
                rId: "00000000-0000-0000-0000-000000000000",
                Name: item.Name,
                Color: item.Color,
                Quantity: item.Quantity,
                Description: item.Description,
                AlternateName: altName,
                AlternateId: newAltId,
                rAlternateId: -1,
                ColorPalette: item.ColorPalette,
                ColorLookup: item.ColorLookup,
                IsRemoved: false,
                Selected: false,
                Checked: false,
                bpColorCode: item.bpColorCode,
                bpColorPallette: item.bpColorPallette,
                txColorCode: item.txColorCode,
                txColorPallette: item.txColorPallette,
                acColorCode: item.acColorCode,
                acColorPallette: item.acColorPallette,
                fpColorCode: item.fpColorCode,
                fpColorPallette: item.fpColorPallette,
                AccentColor: item.AccentColor,
                MountingType: item.MountingType,
                FontType: item.FontType,
                FontSize: item.FontSize,
                HorizontalAlign: item.HorizontalAlign,
                VerticalAlign: item.VerticalAlign,
                fpColorCodeLookup: item.fpColorCodeLookup,
                acColorCodeLookup: item.acColorCodeLookup,
                bpColorCodeLookup: item.fpColorCodeLookup,
                txColorCodeLookup: item.fpColorCodeLookup,
                AccentColorLookup: item.fpColorCodeLookup
            }];
            console.log("Adding new item: " + item.Name + " " + this.keyIndex.toString());
            this.filteredProductList = this.filteredProductList.concat(newItem);
            this.keyIndex++;
        });

        var newItem = [{
            AlternateName: altName,
            AlternateId: newAltId,
            rAlternateId: -1
        }];

        console.log("Adding new alternate: " + altName);
        this.alternateList = this.alternateList.concat(newItem);

        this.filterListByAlternate();
    }

    renameAlternate() {
        var selectedAlternate = this.selectedItem;

        //get Existing alternate
        var alternate = this.alternateList.filter(function (alt) {
            return parseInt(alt.AlternateId) === parseInt(selectedAlternate);
        });

        if (alternate.length > 0) {
            var altName = prompt("Rename Alternate", alternate[0].AlternateName);
            if (altName == "null" || altName == null || altName == "") {
                return; //break out of the function early
            }
            //TODO: Validate altName
            if (altName != "") {
                //rename all product's alternate name
                this.existingProductList.forEach(prod => {
                    prod.AlternateName = altName;
                });

                alternate[0].AlternateName = altName;
            }
        } else
            console.log("No alternate selected");
    }

    //initialized = false;
    renderedCallback() {

        //old datalist html5 auto complete method
        // if (this.initialized) {
        //     return;
        // }

        //var listIds = this.template.querySelectorAll('datalist');
        //console.log(listIds[0].id);
        //console.log(listIds[1].id);
        //Set the auto completes up, we need to grab the datalists to use the HTML 5 auto complete
        //Sales Force appends some stuff to the Id, so we need to select by Name
        // var inp = this.template.querySelectorAll("input");
        // inp.forEach(function (element) {
        //     if (element.name == "Name") {
        //         element.setAttribute('list', listIds[0].id); //Product Datalist
        //         // console.log("bind name data");
        //     } else if (element.name == "Color") {
        //         element.setAttribute('list', listIds[1].id); //Color Datalist
        //         //  console.log("bind color data");
        //     }
        // });
        // this.initialized = true; //Only do this once
    }

    saveConfigClose()
    {
        this.closeWindow = true;
        this.saveConfig();
    }


    saveConfig() {
        this.loaded = false;
        if(this.alternateList.length > 2)
        {
            this.createAsyncTask();
            this.toastMessage = 'Save in progress, you will be notified when it finishes (Bell icon in the upper right corner).';
        }
        else
            this.finishSave();
        }

    finishSave()
    {      
        var list = this.filteredProductList.concat(this.removedProductList);
        var myJSON = JSON.stringify(list);
        console.log(this.recordId + " " + myJSON);
        saveConfiguration({
                recordId: this.recordId,
                products: list
            }).then(results => {
                console.log("save results: " + results);
                if (results.includes("error")) {
                    this.showError = true;
                    this.errorMessage = results;
                    this.loaded = true;
                }
                else if(results.includes("Unable to save"))
                {
                    this.showError = true;
                    this.errorMessage = "It looks like the configuration was unable to save back to Salesforce, please open Experlogix and review any misconfigurations.";
                    this.loaded = true;
                }
                else
                {

                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: this.toastMessage,
                        variant: 'success',
                        mode: 'sticky'
                    }));

                    if (this.closeWindow) {
                        this.closeQuickAction();
                    }
                
                }

                this.filteredProductList = [];
                this.existingProductList = [];
                this.removedProductList = [];
                //this.cacheCounter++;
                this.loadExistingProducts();
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log(errorJSON);
                this.showError = true;
                this.loaded = true;
                if(errorJSON.includes("Encountered HTML Content when looking for"))
                    errorJSON = "Operation timeout, please try again.";
               
                this.errorMessage = "Error saving: " + errorJSON;
            });
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleColorSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        colorSearch(event.detail)
            .then(results => {
                console.log("color results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting colors: " + error);
            });
    }

    handleProductSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        if (this.isSignScape == true && 1 === 9) {
            productSignSearch(event.detail)
                .then(results => {
                    console.log("product results count: " + results.length);
                    target.setSearchResults(results);
                })
                .catch(error => {
                    // TODO: handle error
                    var myJSON = JSON.stringify(error);
                    console.log("Error getting products: " + myJSON);
                });
        } else {
            productSearch(event.detail)
                .then(results => {
                    console.log("product results count: " + results.length);
                    target.setSearchResults(results);
                })
                .catch(error => {
                    // TODO: handle error
                    console.log("Error getting products: " + error);
                });
        }
    }

    handleProductRowClick(event) {
        try {

            if (event.target.accessKey != null && event.target.accessKey != '') {
                console.log(event.target.accessKey)

                var existing = this.filteredProductList.filter(function (product) {
                    return product.Id === event.target.accessKey;
                })[0];

                if (existing != null) {
                    existing.Checked = true;

                    var otherSelectedItems = this.filteredProductList.filter(function (product) {
                        return product.Checked === true && product.Id !== event.target.accessKey;
                    });

                    if (otherSelectedItems != null && otherSelectedItems.length > 0) {
                        otherSelectedItems.forEach(x => {
                            x.Checked = false;
                        });
                    }
                }
            }

        } catch (error) {
            //  console.log(error);
        }
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.filteredProductList.filter(product => {
            return product.Id == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
    }

    handleCheckAllChecked(event) {
        let num = parseInt(this.selectedItem);
        if (this.filteredProductList.length > 0) {
            var toUpdateSelected = this.filteredProductList.filter(function (product) {
                return parseInt(product.AlternateId) === parseInt(num);
            });

            toUpdateSelected.forEach(option => {
                option.Selected = event.target.checked;
            });
        }
    }

    handleDeleteSelectedClick(event) {
        let num = parseInt(this.selectedItem);
        if (this.filteredProductList.length > 0) {
            var toUpdateSelected = this.filteredProductList.filter(function (product) {
                return parseInt(product.AlternateId) === parseInt(num) && product.Selected == true;
            });

            toUpdateSelected.forEach(existing => {
                var newItem = [{
                    Id: existing.Id,
                    rId: existing.rId,
                    Name: existing.Name,
                    Color: existing.Color,
                    Quantity: existing.Quantity,
                    Description: existing.Description,
                    AlternateName: existing.AlternateName,
                    AlternateId: existing.AlternateId,
                    rAlternateId: existing.rAlternateId,
                    ColorPalette: existing.ColorPalette,
                    ColorLookup: existing.ColorLookup,
                    IsRemoved: true,
                    Selected: false,
                    Checked: false
                }];
                this.removedProductList = this.removedProductList.concat(newItem);

                this.filteredProductList = this.filteredProductList.filter(function (product) {
                    return product.Id !== existing.Id;
                });
                console.log("count after delete: " + this.filteredProductList.length);
            });

            this.filterListByAlternate();
        }
    }

    handleClearDefaultsClick(event) {
        console.log("reset defaults");
        this.MountingTypeSelection = null;
        this.fpColorSelection = null;
    }

    handleBulkEditClick(event) {
        let num = parseInt(this.selectedItem);
        if (this.filteredProductList.length > 0) {
            var toUpdateSelected = this.filteredProductList.filter(function (product) {
                return parseInt(product.AlternateId) === parseInt(num) && product.Selected == true;
            });

            toUpdateSelected.forEach(existing => {


                existing.bpColorCode = this.theRecord.bpColorCode;
                existing.bpColorPallette = this.theRecord.bpColorPallette;
                existing.txColorCode = this.theRecord.txColorCode;
                existing.txColorPallette = this.theRecord.txColorPallette;
                existing.acColorCode = this.theRecord.acColorCode;
                existing.acColorPallette = this.theRecord.acColorPallette;
                existing.fpColorCode = this.theRecord.fpColorCode;
                existing.fpColorPallette = this.theRecord.fpColorPallette;
                existing.AccentColor = this.theRecord.AccentColor;
                existing.MountingType = this.theRecord.MountingType;
                existing.FontType = this.theRecord.FontType;
                existing.FontSize = this.theRecord.FontSize;
                existing.HorizontalAlign = this.theRecord.HorizontalAlign;
                existing.VerticalAlign = this.theRecord.VerticalAlign;

                var newLookup = {
                    id: '1',
                    sObjectType: 'item_color__c',
                    icon: 'standard:account',
                    title: this.theRecord.Color,
                    subtitle: this.theRecord.Color
                };
                existing.ColorLookup = newLookup;

                var newbpLookup = {
                    id: '1',
                    sObjectType: 'item_color__c',
                    icon: 'standard:account',
                    title: this.theRecord.bpColorCode,
                    subtitle: this.theRecord.bpColorCode
                };
                existing.bpColorCodeLookup = newbpLookup;

                var newtxLookup = {
                    id: '1',
                    sObjectType: 'item_color__c',
                    icon: 'standard:account',
                    title: this.theRecord.txColorCode,
                    subtitle: this.theRecord.txColorCode
                };
                existing.txColorCodeLookup = newtxLookup;

                var newfpLookup = {
                    id: '1',
                    sObjectType: 'item_color__c',
                    icon: 'standard:account',
                    title: this.theRecord.fpColorCode,
                    subtitle: this.theRecord.fpColorCode
                };
                existing.fpColorCodeLookup = newfpLookup;

                var newaccLookup = {
                    id: '1',
                    sObjectType: 'item_color__c',
                    icon: 'standard:account',
                    title: this.theRecord.acColorCode,
                    subtitle: this.theRecord.acColorCode
                };
                existing.AccentColorLookup = newaccLookup;

            });
        }
    }

}