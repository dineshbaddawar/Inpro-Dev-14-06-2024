import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import GetSampleRequest from '@salesforce/apex/NewSampleItemHelper.GetSampleRequest';
import GetSampleRequestItems from '@salesforce/apex/NewSampleItemHelper.GetSampleRequestItems';
import CreateSampleRequestItem from '@salesforce/apex/NewSampleItemHelper.CreateSampleRequestItem';
import CreateSampleRequestItems from '@salesforce/apex/NewSampleItemHelper.CreateSampleRequestItems';
import DeleteSampleRequestItems from '@salesforce/apex/NewSampleItemHelper.DeleteSampleRequestItems';
import AdvancedProductSearch from '@salesforce/apex/NewSampleItemHelper.AdvancedProductSearch';
import AdvancedProductSearchGetPageCount from '@salesforce/apex/NewSampleItemHelper.AdvancedProductSearchGetPageCount';
import GetProductFamilyPicklist from '@salesforce/apex/NewSampleItemHelper.GetProductFamilyPicklist';
import GetDivisionPicklist from '@salesforce/apex/NewSampleItemHelper.GetDivisionPicklist';
import GetProducts from '@salesforce/apex/NewSampleItemHelper.GetProducts';

export default class NewSampleItem extends LightningElement {
    @api recordId;
    @track isMain = false;
    @track isSearch = true;
    @track isDeleteActive = false;
    @track loaded = false;
    @track sampleRequestName;
    @track selectedDivision;
    @track selectedProduct;
    @track productTarget;
    @track selectedQuantity;
    @track sampleItemList = [];
    @track selectedItems = [];
    @track itemColumns = [
        {
            label: 'Name', 
            fieldName: 'SRLink', 
            type: 'url', 
            initialWidth: 100, 
            sortable: true, 
            typeAttributes: 
            {
                label: 
                { 
                    fieldName: 'Name' 
                },
                target: '_blank'
            }
        },
        {label: 'Product Name', initialWidth: 100, fieldName: 'Product_Name'},
        {label: 'Quantity', initialWidth: 100, fieldName: 'Quantity__c'},
        {label: 'Available Inventory',initialWidth: 110, fieldName: 'Available_Inventory__c'},
        {label: 'Division', initialWidth: 100, fieldName: 'Div_Abbreviation__c'},
        {label: 'Is Active', initialWidth: 100, fieldName: 'Product_Is_Active__c'},
    ];

    @track searchDivision = '';
    @track searchProductFamily = '';
    @track searchName = '';
    @track searchPage = '1';
    @track maxPage = '1';
    @track pageLibrary = [];
    @track divisionList = [];
    @track productFamilyList = [];
    @track searchColumns = [
        {label: 'Name',fieldName: 'Name'},
        {label: 'Description',fieldName: 'Description'},
        {label: 'Division',fieldName: 'Division__c'},
        {label: 'Family',fieldName: 'Family'},
        {label: 'Quantity',fieldName: 'Quantity', editable: true},
    ];
    @track selectedSearchItems = [];
    @track searchList;
    @track saveButtonText = 'Review';
    @track loadMessage = 'Loading products...';

    connectedCallback(){
        AdvancedProductSearch({name: '', searchPage: this.searchPage}).then(data =>{
            AdvancedProductSearchGetPageCount({name: ''}).then(data2 =>{
                console.log('Pages found: ' + data2);
                console.log('Data:');
                console.log(data);
                this.searchList = data;
                this.maxPage = data2;
                this.pageLibrary = [];
                for(var i = 1; i <= data2; i++)
                {
                    this.pageLibrary.push({label: i, value: i});
                }
                this.populateImages();
            });
        }).catch(error => {
            this.handleError(error);
        });
        GetSampleRequest({recordId: this.recordId}).then(sr => {
            this.selectedDivision = sr.Division__c;
            this.sampleRequestName = sr.Name;
            this.buildTable();
        }).catch(error => {
            this.handleError(error);
        });

        GetProductFamilyPicklist().then(data =>{
            var tempArray = [];
            tempArray.push({
                value: '',
                label: '--None--'
            });
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.productFamilyList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetDivisionPicklist().then(data =>{
            var tempArray = [];
            tempArray.push({
                value: '',
                label: '--None--'
            });
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.divisionList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });
    }

    handleDelete(){
        this.loaded = false;
        DeleteSampleRequestItems({itemList: this.selectedItems}).then(data =>{
            if (data == 'Success')
            {
                this.buildTable();
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error!',
                    message: data,
                    variant: 'warning'
                }));
                this.loaded = true;
            }
        }).catch(error => {
            this.handleError(error);
        });
    }

    handleAdd(){
        this.loaded = false;
        console.log('Create Sample Request');
        var params = {
            sampleRequestId: this.recordId,
            productId: this.selectedProduct,
            quantity: this.selectedQuantity
        };
        console.log(params);
        CreateSampleRequestItem(params).then(data =>{
            if (data == 'Success')
            {
                this.productTarget.clearSelection();
                this.selectedQuantity = '';
                this.buildTable();
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error!',
                    message: data,
                    variant: 'warning'
                }));
                this.loaded = true;
            }
        }).catch(error => {
            this.handleError(error);
        });
    }

    buildTable(){
        GetSampleRequestItems({recordId: this.recordId}).then(data =>{
            this.sampleItemList = [];
            data.forEach(x =>{
                x.Product_Name = x.Sample_Product__r.Name;
                x.SRLink =  window.location.origin + '/' + x.Id;
            });
            this.sampleItemList = data;
            this.loaded = true;
        }).catch(error => {
            this.handleError(error);
        });
    }
    
    handleStartSearch(){
        this.isMain = false;
        this.isSearch = true;
        this.selectedSearchItems = [];
        this.saveButtonText = 'Review';
        this.loaded = false;
        console.log('Search');

        var params = {
            name: this.searchName, 
            division: this.searchDivision, 
            productFamily: this.searchProductFamily,
            searchPage: this.searchPage
        };

        var params2 = {
            name: this.searchName, 
            division: this.searchDivision, 
            productFamily: this.searchProductFamily
        };

        AdvancedProductSearch(params).then(data =>{
            
            AdvancedProductSearchGetPageCount(params2).then(data2 =>{
                console.log('Pages found: ' + data2);
                console.log('Data:');
                console.log(data);
                this.searchList = data;
                
                this.maxPage = data2;
                this.pageLibrary = [];
                for(var i = 1; i <= data2; i++)
                {
                    this.pageLibrary.push({label: i, value: i});
                }
                this.populateImages();
            });
        }).catch(error => {
            this.handleError(error);
        });
    }

    populateImages(){
        this.loaded = false;
        this.loadMessage = 'Loading images...';
        var names = '';
        this.searchList.forEach(x => {
            names += '\'' + x.ProductCode + '\',';
        });
        names = names.substring(0, names.length-1);

        GetProducts({names: names}).then(data =>{
            data.forEach(x => {
                this.searchList.forEach(y => {
                    if (x.ProductCode == y.ProductCode)
                    {
                        console.log('Image found for ' + x.ProductCode);
                        var url = x.DisplayUrl;
                        var img = document.createElement('img');
                        img.src=url;
                        img.onload = function(e){
                            y.ImageUrl = url;
                            y.ShowImage = true;
                        };
                    }
                });
            });
            this.loaded = true;
            this.loadMessage = 'Loading products...';
        });
    }

    @track isDelayed = null;

    handlePageBack(event)
    {
        var lastPage = parseInt(this.searchPage) - 1;
        if (lastPage >= 1)
        {
            this.searchPage = lastPage.toString();
            this.handleDelayInput(event);
        }
    }

    handlePageForward(event)
    {
        var nextPage = parseInt(this.searchPage) + 1;
        if (nextPage <= parseInt(this.maxPage))
        {
            this.searchPage = nextPage.toString();
            this.handleDelayInput(event);
        }
    }
    handleDelayInput(event)
    {
        const value = event.target.value;
        const name = event.target.name;
        if (name == 'searchDivision')
        {
            this.searchDivision = value;
            this.searchPage = '1';
        }
        else if (name == 'searchProductFamily')
        {
            this.searchProductFamily = value;
            this.searchPage = '1';
        }
        else if (name == 'searchName')
        {
            this.searchName = value;
            this.searchPage = '1';
        }
        else if (name == 'searchPage')
        {
            this.searchPage = value;
        }

        this.searchInput = value;
        const ev = () => {
            console.log('Search input is ' + this.searchInput);
            this.loaded = false;

            var params = {
                name: this.searchName, 
                division: this.searchDivision, 
                productFamily: this.searchProductFamily,
                searchPage: this.searchPage
            };
            
            var params2 = {
                name: this.searchName, 
                division: this.searchDivision, 
                productFamily: this.searchProductFamily
            };

            console.log(params);
            AdvancedProductSearch(params).then(data =>{
                AdvancedProductSearchGetPageCount(params2).then(data2 =>{
                    console.log('Pages found: ' + data2);
                    this.searchList = data;
                    
                    this.searchList.forEach(x => {
                        this.selectedSearchItems.forEach(y => {
                            if (y.Id == x.Id)
                            {
                                x.Selected = true;
                                x.Quantity = y.Quantity;
                            }
                        })
                    });
                    
                    this.maxPage = data2;
                    this.pageLibrary = [];
                    for(var i = 1; i <= data2; i++)
                    {
                        this.pageLibrary.push({label: i, value: i});
                    }
                    this.populateImages();
                });
            }).catch(error => {
                this.handleError(error);
            });
        };
        if (this.isDelayed){
            console.log('clear timeout');
            clearTimeout(this.isDelayed);
        }

        this.isDelayed = setTimeout(function(){
            console.log('Begin search')
            ev();
            isDelayed = null;
        }, 500);
    }

    handleSaveSearch(){
        console.log(this.selectedSearchItems);

        if (this.selectedSearchItems.length > 0)
        {
            this.loaded = false;
            var a = this.recordId;
            var b = [];
            var c = [];
            this.selectedSearchItems.forEach(x =>{
                b.push(x.Id);
                c.push(x.Quantity);
            });
            var params = {
                sampleRequestId: a,
                productIds: b,
                quantities: c
            };
            console.log(params);
            CreateSampleRequestItems(params).then(data =>{
                if (data == 'Success')
                {
                    this.isSearch = false;
                    this.isMain = true;
                    this.buildTable();
                }
                else
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Server Error!',
                        message: data,
                        variant: 'warning'
                    }));
                    this.loaded = true;
                }
            }).catch(error => {
                this.handleError(error);
            });
        }
        else{
            this.isSearch = false;
            this.isMain = true;
        }
        
    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.searchList.filter(product => {
            return product.Id == Id;
        })[0];
        selectedItem.Selected = event.target.checked;

        const existingSelection = this.selectedSearchItems.find(x => x.Id == selectedItem.Id);
        if (existingSelection != undefined)
        {
            this.selectedSearchItems.splice(this.selectedSearchItems.indexOf(existingSelection),1);
        }

        if (selectedItem.Selected)
        {
            if (selectedItem.Quantity == undefined || selectedItem.Quantity == '')
            {
                selectedItem.Quantity = '1';
            }

            this.selectedSearchItems.push(selectedItem);
        }
        else
        {
            selectedItem.Quantity = '';
        }

        console.log(this.selectedSearchItems.length);
        if (this.selectedSearchItems.length > 0)
        {
            this.saveButtonText = 'Add (' + this.selectedSearchItems.length + ') and Review';
        }
        else
        {
            this.saveButtonText = 'Review';
        }
    }

    handleInput(event){
        const name = event.target.name;
        const value = event.target.value;

        if (name == 'itemQuantity')
        {
            let Id = event.target.accessKey;
            var selectedItem = this.searchList.filter(item => {
                return item.Id == Id;
            })[0];
            selectedItem.Quantity = value;
            selectedItem.Selected = true;
        }
        if (name == 'selectedQuantity')
        {
            this.selectedQuantity = value;
        } 
        else if (name == 'sampleItemList')
        {
            const selectedRows = event.detail.selectedRows;
            var tempArray = [];
            selectedRows.forEach(x => {
                tempArray.push(x.Id);
            });
            this.selectedItems = tempArray;
            this.isDeleteActive = this.selectedItems.length > 0;
        }
        else if (name == 'selectedSearchItems')
        {
            const selectedRows = event.detail.selectedRows;
            var tempArray = [];
            selectedRows.forEach(x => {
                tempArray.push(x.Id);
            });
            this.selectedSearchItems = tempArray;
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
            console.log(name);
            console.log(id);
            console.log(subTitle);

            if (event.target.name == "selectedItem") {
                this.selectedProduct = id;
            }
        }
    }

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else if (error.body !== undefined && error.body.fieldErrors !== undefined && error.body.fieldErrors.Sample_Product__c !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error.body.fieldErrors.Sample_Product__c[0].message,
                variant: 'warning'
            }));
        }
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }

    handleClose(){
        window.location.reload();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}