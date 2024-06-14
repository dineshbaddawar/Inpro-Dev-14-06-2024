import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import userId from '@salesforce/user/Id';
import getQuotes from '@salesforce/apex/QuoteComparisonHelper.getQuotes';
import getPreComparedMap from '@salesforce/apex/QuoteComparisonHelper.getPreComparedMap';
import createComparison from '@salesforce/apex/QuoteComparisonHelper.createComparison2';
import createComparisonMatch from '@salesforce/apex/QuoteComparisonHelper.createComparisonMatch';
import createAddDeductPreview from '@salesforce/apex/QuoteComparisonHelper.createAddDeductPreview';
import createAddDeductQuote from '@salesforce/apex/QuoteComparisonHelper.createAddDeductQuote';
import GetExcelFile from '@salesforce/apex/QuoteComparisonHelper.GetExcelFile';
import OpportunitySearch from '@salesforce/apex/QuoteComparisonHelper.OpportunitySearch';
import GetOpportunity from '@salesforce/apex/QuoteComparisonHelper.GetOpportunity';
import CreateExportReferenceFile from '@salesforce/apex/QuoteComparisonHelper.CreateExportReferenceFile';

import getBidders from '@salesforce/apex/QuoteComparisonHelper.getBidders';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class QuoteComparisonTool extends LightningElement {

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
    }

    @track recordId = undefined;
    @track loaded = false;
    @track loadMessage = 'Loading...';
    @track quoteList = [];
    @track quoteIsActive = false;
    @track quoteText = '';
    @track quoteNum = '1';
    @track firstQuote = { Id: '', Name: ''};
    @track secondQuote = {Id: '', Name: ''};
    @track comparison = { matchedAlts: [], noMatchOneAlts: [], noMatchTwoAlts: [], manualAlts: []};
    @track emptyQLI = {
        Item_Number__c: '',
        Color__c: '',
        UnitPrice: '',
        Quantity: '',
        Description: '',
        Description_2__c: '',
        Note__c: '',
    };
    @track emptyStyleQLI = {
        Item_Number__c: 'table-row-text change-empty',
        Color__c: 'table-row-text2 change-empty',
        UnitPrice: 'table-row-number change-empty',
        Quantity: 'table-row-number change-empty',
        Description: 'table-row-text change-empty',
        Description_2__c: 'table-row-text change-empty',
        Note__c: 'table-row-text change-empty',
    };
    @track removedStylQLI = {
        Item_Number__c: 'table-row-text change-red',
        Color__c: 'table-row-text2 change-red',
        UnitPrice: 'table-row-number change-red',
        Quantity: 'table-row-number change-red',
        Description: 'table-row-text change-red',
        Description_2__c: 'table-row-text change-red',
        Note__c: 'table-row-text change-red',
    };
    @track addedStyleQLI = {
        Item_Number__c: 'table-row-text change-green',
        Color__c: 'table-row-text2 change-green',
        UnitPrice: 'table-row-number change-green',
        Quantity: 'table-row-number change-green',
        Description: 'table-row-text change-green',
        Description_2__c: 'table-row-text change-green',
        Note__c: 'table-row-text change-green',
    };
    @track totalColumns = 9;
    @track halfColumns = 3;

    @track options = [
        { value: false, label: 'All', icon: 'utility:check'},
        { value: false, label: 'Only Changes', icon: 'utility:change_record_type'},
        { value: false, label: 'Exclude Hidden', icon: 'utility:hide'},
        { value: true, label: 'Alt Total', icon: 'utility:money'},
        { value: true, label: 'Show Color', icon: 'utility:color_swatch'},
        { value: true, label: 'Show Unit Price', icon: 'utility:price_book_entries'},
        { value: false, label: 'Show Desc. One', icon: 'utility:description'},
        { value: false, label: 'Show Desc. Two', icon: 'utility:description'},
        { value: false, label: 'Show Notes', icon: 'utility:description'},
        { value: false, label: 'Show Math', icon: 'utility:add'},
    ];
    @track actions = [
        { value: this.index++, label: 'Compare', onclick: this.compareRevisions},
        { value: this.index++, label: 'Match', onclick: this.handleMatchOpen, disabled: 'disabled' },
        { value: this.index++, label: 'Reset', onclick: this.handleReset, disabled: 'disabled' },
        //{ value: this.index++, label: 'Print', onclick: this.compareRevisions, disabled: 'disabled' },
        { value: this.index++, label: 'Update Products', onclick: this.handleHideToggle, disabled: 'disabled' },
        { value: this.index++, label: 'Export', onclick: this.handleExportOpen, disabled: 'disabled' },
        { value: this.index++, label: 'Add/Deduct', onclick: this.handleAddDeduct, disabled: 'disabled' }
    ];

    @track showAltTotal = true;
    @track showColor = true;
    @track showUnitPrice = true;
    @track showDescOne = false;
    @track showDescTwo = false;
    @track showNotes = false;
    @track showOnlyChanges = false;
    @track excludeHidden = false;
    @track isHideActive = false;
    @track showMath = false;
    @track formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      });
    @track index = 0;
    @track ajaxCount = 0;
    @track size = 0;
    @track matchIsActive = false;
    @track matchSelection = { one: undefined, two: undefined};
    @track isCreatingAddDeduct = false;
    @track addConfigs = [];
    @track deductConfigs = [];
    @track isAddDeductActive = false;
    @track bidderList = [];
    @track selectedBidder = '';


    @track switch_A_On = false;
    @track switch_B_On = false;
    @track switch_Alt_On = false;
    @track switch_Alt_Key = '';
    @track switch_A_Key = '';
    @track switch_B_Key = '';

    handleSwitch = function(event){
        const key = event.target.accessKey;
        const altKey = key.substring(0,key.lastIndexOf(','));
        console.log(key);
        console.log(altKey);
        let alt = this.comparison.matchedAlts.filter(y => { return y.key == altKey;})[0];
        let selected = alt.value.filter(z => { return z.key == key;})[0];
        console.log(alt);
        console.log(selected);
        this.comparisonLoaded = false;
        //Handle Alt selection and Alt Changing
        if (!this.switch_Alt_On)
        {
            this.switch_Alt_On = true;
            this.switch_Alt_Key = alt.key;
        }
        else if (this.switch_Alt_Key != alt.key)
        {
            if (this.switch_A_Key != '')
            {
                let alt_A = this.comparison.matchedAlts.filter(y => { return y.key == this.switch_Alt_Key;})[0];
                let selected_A = alt_A.value.filter(z => { return z.key == this.switch_A_Key;})[0];
                selected_A.switchTrigger = false;
            }

            this.switch_Alt_Key = alt.key;
            this.switch_A_Key = '';
            this.switch_A_On = false;
        }

        if (!this.switch_A_On) //make first selection
        {
            this.switch_A_On = true;
            this.switch_A_Key = selected.key;
            selected.switchTrigger = true;
        }
        else if (this.switch_A_On && this.switch_A_Key == selected.key) //undo selection
        {
            this.switch_A_On = false;
            selected.switchTrigger = false;
        }
        else if (!this.switch_B_On) //perform swap on second selection
        {
            this.switch_B_On = true;
            this.switch_B_Key = selected.key;

            let selected_A = alt.value.filter(z => { return z.key == this.switch_A_Key;})[0];
            let selected_B = alt.value.filter(z => { return z.key == this.switch_B_Key;})[0];
            selected_A.switchTrigger = false;
            selected_A.switchTrigger = false;
            let temp = selected_A.second;
            selected_A.second = selected_B.second;
            selected_B.second = temp;
            
            this.switch_B_On = false;
            this.switch_A_On = false;
            this.switch_Alt_On = false;
            this.switch_Alt_Key = '';
            this.switch_A_Key = '';
            this.switch_B_Key = '';

            this.buildAlternates(true, altKey);
        }
        
        this.comparisonLoaded = true;
    }

    getDefaultStyle = function(){
        return {
            Item_Number__c: 'table-row-text ',
            Color__c: 'table-row-text2 ',
            UnitPrice: 'table-row-number ',
            Quantity: 'table-row-number ',
            Description: 'table-row-text ',
            Description_2__c: 'table-row-text ',
            Note__c: 'table-row-text ',
        }
    };

    handleProcessRow = function(x)
    {
        if (this.ajaxCount == 5)
        {
            setTimeout(function(){
                this.handleProcessRow(x);
            }.bind(this),50);
        }
        else
        {
            let params2 = {
                preComparedMapJson: JSON.stringify(x[1])
            };

            console.log(params2);
            this.ajaxCount++;
            
            createComparison(params2).then(data2 => {
                this.handleComparison(x[0], data2);
            })
        }
    }

    @track exportIsActive = false;
    handleExportOpen(event)
    {
        this.exportOptions.fileName = 
            'Compare ' + 
            this.firstQuote.DisplayName.substring(0, this.firstQuote.DisplayName.indexOf(',')) + ' vs ' +
            this.secondQuote.DisplayName.substring(0, this.firstQuote.DisplayName.indexOf(','));

        this.comparison.matchedAlts.forEach(alt => {
            alt.isSelected = true;
        });
        this.comparison.noMatchOneAlts.forEach(alt => {
            alt.isSelected = true;
        });
        this.comparison.noMatchTwoAlts.forEach(alt => {
            alt.isSelected = true;
        });
        
        this.exportIsActive = true;
    }

    handleExportClose = function(event)
    {
        this.exportIsActive = false;
    }

    handleComparison = function(altName, data2)
    {
        this.index++;
        console.log('Processing Alternate ' + (this.index) + '/' + this.size + '...');
        this.loadMessage = 'Processing Alternate ' + (this.index)  + '/' + this.size + '...';
        this.ajaxCount--;
        let results2 = JSON.parse(data2);
        console.log(results2);

        this.comparison.matchedAlts.push({
            key: altName,
            value: results2
        });

        if (this.ajaxCount == 0 && this.index == this.size)
        {
            this.actions.filter(x => {return x.label == 'Add/Deduct';})[0].disabled = '';
            this.actions.filter(x => {return x.label == 'Update Products';})[0].disabled = '';
            this.actions.filter(x => {return x.label == 'Export';})[0].disabled = '';
            this.buildAlternates(false);

            let a = this.comparison.matchedAlts.filter(x => { return x.order == 1});
            let b = this.comparison.matchedAlts.filter(x => { return x.order == 2});
            let c = this.comparison.matchedAlts.filter(x => { return x.order == 3});
            let orderArray = [];
            
            this.comparison.matchedAlts = orderArray.concat(a,b,c);
            let tempOne = this.comparison.noMatchOneAlts.sort((x,y) => {
                return x.Name > y.Name ? 1 :
                    x.Name < y.Name ? -1 : 0
            });
            this.comparison.noMatchOneAlts = tempOne;
            let tempTwo = this.comparison.noMatchTwoAlts.sort((x,y) => {
                return x.Name > y.Name ? 1 :
                    x.Name < y.Name ? -1 : 0
            });
            this.comparison.noMatchTwoAlts = tempTwo;
            try
            {
                this.comparison.matchedAlts.forEach(alt => {
                    alt.value = alt.value.sort((x,y) => {
                        if (x != undefined && x.second != undefined && x.second.item != undefined && y != undefined && y.second != undefined && y.second.item != undefined)
                        {
                            let itemX = x.second.item;
                            let itemY = y.second.item;
                            return itemX.Item_Number__c < itemY.Item_Number__c ? -1 :
                                   itemX.Item_Number__c < itemY.Item_Number__c ? 1 : 0;
                        }
                        else if (x == undefined || x.second == undefined || x.second.item == undefined)
                        {
                            return 1;
                        }
                        else
                        {
                            return -1;
                        }
                    });
                });
            }
            catch(ex)
            {
                console.log(ex);
            }
            
            this.handleShowOnlyChanges();
            this.comparisonLoaded = true;
            this.loaded = true;
        }
    };

    buildAlternates = function(isSwitching, key)
    {
        if (isSwitching)
        {
            this.compareRows(this.comparison.matchedAlts.filter(y => {return y.key == key;})[0]);
            return;
        }
        
        this.comparison.matchedAlts.filter(y => {return y.isProcessed == undefined;}).forEach(y => {
            y.visible = true;
            y.isSelected = false;
            y.isProcessed = true;
            if (y.value.filter(z => {return z.second != null && z.second.item != null; }).length == 0)
            {
                y.order = 2;
                const first = y.value.filter(x => {return x.first != null && x.first.item != null;})[0].first.item;
                this.actions.filter(x => {return x.label == 'Match';})[0].disabled = '';
                this.comparison.noMatchOneAlts.push(y);
                y.AlternateId = first.Alternate__c;
                y.noMatchOne = true;
                y.freightOne = this.safeFormat(first.Alternate__r.Freight_Amount__c);
                if (y.freightOne != undefined && first.Alternate__r.Freight_Carrier__r != undefined)
                {
                    y.freightOneName = first.Alternate__r.Freight_Carrier__r.Name;
                    y.freightClass = "change-red";
                    y.freightChange = "[-" +  this.safeFormat(first.Alternate__r.Freight_Amount__c) + "]";
                }
                y.totalOne = this.safeFormat(first.Alternate__r.Total_Cost__c);
                y.totalClass =  "change-red";
                y.totalChange = "[-" + this.safeFormat(first.Alternate__r.Total_Cost__c) + "]";
                
            }
            else if (y.value.filter(z => {return z.first != null && z.first.item != null; }).length == 0)
            {
                y.order = 3;
                const second = y.value.filter(x => {return x.second != null && x.second.item != null;})[0].second.item;
                y.AlternateId =second.Alternate__c;
                this.actions.filter(x => {return x.label == 'Match';})[0].disabled = '';
                this.comparison.noMatchTwoAlts.push(y);

                y.noMatchTwo = true;
                y.freightTwo = this.safeFormat(second.Alternate__r.Freight_Amount__c);
                if (y.freightTwo != undefined && second.Alternate__r.Freight_Carrier__r != undefined)
                {
                    y.freightTwoName =second.Alternate__r.Freight_Carrier__r.Name;
                    y.freightClass = "change-green";
                    y.freightChange = "(+" + this.safeFormat(second.Alternate__r.Freight_Amount__c) + ")";
                }
                y.totalTwo = this.safeFormat(second.Alternate__r.Total_Cost__c);
                y.totalClass =  "change-green";
                y.totalChange = "(+" + this.safeFormat(second.Alternate__r.Total_Cost__c) + ")";
            }
            else if (y.value.filter(z => {return z.second != null && z.second.item != null; }).length > 0 && 
                y.value.filter(z => {return z.first != null && z.first.item != null; }).length > 0)
            {
                y.order = 1;
                const first = y.value.filter(x => {return x.first != null && x.first.item != null;})[0].first.item;
                const second = y.value.filter(x => {return x.second != null && x.second.item != null;})[0].second.item;
                y.AlternateId = first.Alternate__c;
                y.freightOne = this.safeFormat(first.Alternate__r.Freight_Amount__c);
                y.freightTwo = this.safeFormat(second.Alternate__r.Freight_Amount__c);
                if (y.freightOne != undefined && y.freightTwo != undefined)
                {
                    if (y.freightOne < y.freightTwo)
                    {
                        y.freightClass = "change-green";
                        y.freightChange = "(+" +  this.safeFormat(second.Alternate__r.Freight_Amount__c - first.Alternate__r.Freight_Amount__c) + ")";
                    }
                    else if (y.freightOne > y.freightTwo)
                    {
                        y.freightClass = "change-red";
                        y.freightChange = "[-" +  this.safeFormat(first.Alternate__r.Freight_Amount__c- second.Alternate__r.Freight_Amount__c) + "]";
                    }
                }
                if (y.freightOne != undefined && first.Alternate__r.Freight_Carrier__r != undefined)
                {
                    y.freightOneName = first.Alternate__r.Freight_Carrier__r.Name;
                }
                if (y.freightTwo != undefined && second.Alternate__r.Freight_Carrier__r != undefined)
                {
                    y.freightTwoName = second.Alternate__r.Freight_Carrier__r.Name;
                }

                y.totalOne = this.safeFormat(first.Alternate__r.Total_Cost__c);
                y.totalTwo = this.safeFormat(second.Alternate__r.Total_Cost__c);
                if (first.Alternate__r.Total_Cost__c < second.Alternate__r.Total_Cost__c)
                {
                    y.totalClass =  "change-green";
                    y.totalChange = "(+" + this.safeFormat(second.Alternate__r.Total_Cost__c - first.Alternate__r.Total_Cost__c) + ")";
                }
                else if (first.Alternate__r.Total_Cost__c > second.Alternate__r.Total_Cost__c)
                {
                    y.totalClass =  "change-red";
                    y.totalChange = "[-" + this.safeFormat(first.Alternate__r.Total_Cost__c - second.Alternate__r.Total_Cost__c) + "]";
                }
            }

            this.compareRows(y);
        });
        
        this.updateAltTotals();
    }

    compareRows = function(y){
        let rowIndex = 1;
        y.value.forEach(z => {
            z.changes = false;
            z.key = y.key + ',' + rowIndex++;
            z.RowId = rowIndex;
            z.switchTrigger = false;
            if (z.first == null || z.first.item == null || z.first.item.Item_Number__c == '' ) {
                z.first = {};
                z.first.item = this.emptyQLI;
                z.second.Id = z.second.item.Id;
                z.changes = true;
                z.first.cssClass = this.emptyStyleQLI;
                z.second.cssClass = this.getDefaultStyle();
                z.second.change = {};
                z.second.math = { UnitPrice: '', Quantity: ''};
                z.second.UnitPriceFormat = this.safeFormat(z.second.item.UnitPrice);
                if (!y.noMatchTwo) z.second.cssClass = this.addedStyleQLI;
            }
            else if (z.second == null || z.second.item == null || z.second.item.Item_Number__c == ''){
                z.changes = true;
                z.first.cssClass = this.getDefaultStyle();
                z.first.UnitPriceFormat = this.safeFormat(z.first.item.UnitPrice);
                z.second = {};
                z.second.item = {
                    Item_Number__c: z.first.item.Item_Number__c,
                    Color__c: z.first.item.Color__c,
                    UnitPrice: z.first.item.UnitPrice,
                    Quantity: z.first.item.Quantity,
                    Description: z.first.item.Description,
                    Description_2__c: z.first.item.Description_2__c,
                    Note__c: z.first.item.Note__c,
                };
                z.first.Id = z.first.item.Id;
                z.second.cssClass = y.noMatchOne ? this.emptyStyleQLI : this.removedStylQLI;
                z.second.item.Quantity = 0;
                z.second.item.UnitPrice = 0;
                z.second.change = {};
                z.second.math = { UnitPrice: '', Quantity: ''};
                this.compareNumber(z, "UnitPrice", z.first.item.UnitPrice, z.second.item.UnitPrice, true);
                this.compareNumber(z, "Quantity", z.first.item.Quantity, z.second.item.Quantity, false);
            } 
            else
            {
                z.first.Id = z.first.item.Id;
                z.second.Id = z.second.item.Id;
                z.first.cssClass = this.getDefaultStyle();
                z.second.cssClass = this.getDefaultStyle();
                z.second.change = {};
                z.second.math = { UnitPrice: '', Quantity: ''};
                z.first.UnitPriceFormat = this.safeFormat(z.first.item.UnitPrice);
                z.second.UnitPriceFormat = this.safeFormat(z.second.item.UnitPrice);
                this.compareText(z, "Item_Number__c", z.first.item.Item_Number__c, z.second.item.Item_Number__c);
                this.compareText(z, "Color__c", z.first.item.Color__c, z.second.item.Color__c);
                this.compareNumber(z, "UnitPrice", z.first.item.UnitPrice, z.second.item.UnitPrice, true);
                this.compareNumber(z, "Quantity", z.first.item.Quantity, z.second.item.Quantity, false);
                this.compareText(z, "Description", z.first.item.Description, z.second.item.Description);
                this.compareText(z,"Description_2__c", z.first.item.Description_2__c, z.second.item.Description_2__c);
                this.compareText(z,"Note__c", z.first.item.Note__c, z.second.item.Note__c);

                z.visible = (this.showOnlyChanges && z.changes) || !this.showOnlyChanges;
            }
        });
    }
    safeFormat = function(x)
    {
        if (x != undefined && x != null && !Number.isNaN(x))
        {
            return this.formatter.format(x);
        }
        else return "";
    }

    updateAltTotals = function()
    {
        this.comparison.matchedAlts.forEach(alt => {
            let totalOne = 0.0;
            let totalTwo = 0.0;
            alt.value.forEach(row => {
                //test
                if (row.isHidden == false || row.isHidden == null || row.isHidden == undefined)
                {
                    if (row.first != undefined && row.first.item != undefined && 
                        row.first.item.Price_Per_Unit__c != undefined && row.first.item.Price_Per_Unit__c != "")
                    {
                        if (this.showOnlyChanges == false || (this.showOnlyChanges == true  && row.changes == true ))
                            totalOne += row.first.item.Price_Per_Unit__c * row.first.item.Quantity;
                    }
                    if (row.second != undefined && row.second.item != undefined && 
                        row.second.item.Price_Per_Unit__c != undefined && row.second.item.Price_Per_Unit__c != "")
                    {
                        if (this.showOnlyChanges == false || (this.showOnlyChanges == true  && row.changes == true ))
                            totalTwo += row.second.item.Price_Per_Unit__c * row.second.item.Quantity;
                    }
                }
            })
            alt.totalOne = this.safeFormat(totalOne);
            alt.totalTwo = this.safeFormat(totalTwo);

            if (totalOne == 0.0)
            {
                alt.totalClass = "change-green";
                alt.totalChange = "(+" + this.safeFormat(totalTwo) + ")";
            }
            else if (totalTwo == 0.0)
            {
                alt.totalClass = "change-red";
                alt.totalChange = "[-" + this.safeFormat(totalOne) + "]";
            }
            else if (totalOne < totalTwo)
            {
                alt.totalClass = "change-green";
                alt.totalChange = "(+" + this.safeFormat(totalTwo - totalOne) + ")";
            }
            else if (totalTwo < totalOne)
            {
                alt.totalClass = "change-red";
                alt.totalChange = "[-" + this.safeFormat(totalOne - totalTwo) + "]";
            }
        });
    }
    compareText = function(z, field, a, b)
    {
        if (a != b)
        {
            z.second.cssClass[field] += "change-yellow";
            z.changes = true;
        }
    }

    compareNumber = function(z, field, a,b, isFormatting)
    {
        //test
        if (a != undefined && b == undefined)
        {
            z.second.math[field] += "change-red";
            z.second.cssClass[field] += "change-red";
            z.second.change[field] = "[-" + (isFormatting ? this.safeFormat(a) : a) + "]";
            z.changes = true;
        }
        else if (a == undefined && b != undefined)
        {
            z.second.math[field] += "change-green";
            z.second.cssClass[field] += "change-green";
            z.second.change[field] = "(+" + (isFormatting ? this.safeFormat(b) : b) + ")";
            z.changes = true;
        }
        else if (a > b)
        {
            z.second.math[field] += "change-red";
            z.second.cssClass[field] += "change-red";
            z.second.change[field] = "[-" + (isFormatting ? this.safeFormat(a - b) : (a-b)) + "]";
            z.changes = true;
        }
        else if (a < b)
        {
            z.second.math[field] += "change-green";
            z.second.cssClass[field] += "change-green";
            z.second.change[field] = "(+" + (isFormatting ? this.safeFormat(b - a) : (b-a)) + ")";
            z.changes = true;
        }
    }

    compareRevisions(event){
        let params = {
            firstQuoteId : this.firstQuote.Id, 
            secondQuoteId : this.secondQuote.Id
        };

        console.log(params);
        this.loaded = false;
        this.comparisonLoaded = false;

        this.comparison = {
            matchedAlts: [],
            noMatchOneAlts: [],
            noMatchTwoAlts: [],
            manualAlts: []
        };
        
        getPreComparedMap(params).then(data =>{
            let results = JSON.parse(data);
            console.log(results);
            this.index = 0;
            this.size = Object.entries(results.matchedAlts).length;
            if (this.size == 0)
            {
                this.loaded = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'There are no alternates to compare.',
                    variant: 'success',
                }));
            }
            Object.entries(results.matchedAlts).forEach(x => {
                this.handleProcessRow(x);
            });
        }).catch(error => this.handleError(error));
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    @track emptyStart = false;
    connectedCallback(){
        console.log(this.recordId);

        if (this.recordId == '' || this.recordId == undefined) this.emptyStart = true;

        let params = { opportunityId: this.recordId };

        GetOpportunity({recordId: this.recordId}).then(data => {
            var selectedItem = {
                id: data.Id,
                sObjectType: 'Opportunity',
                icon: 'standard:opportunity',
                title: data.Name,
                subtitle: ''
            };

            this.opportunitySelection = selectedItem;
        });

       
        getQuotes(params).then(data => {
            console.log(data);
            data.forEach(x => {
                x.DisplayName = (x.MSCRM_ID__c != undefined ? '(CRM 2011) ' : '') + 
                                 x.QuoteNumber + ', Rev #' + x.Revision_Number__c + ': ' + x.Version_Description__c;
                x.CreatedDate = new Date(x.CreatedDate).toLocaleString("en-US");
                x.Link = window.location.protocol + '//' + window.location.host + '/lightning/r/' + x.Id + '/view'
            });
            this.quoteList = data;
            this.loaded = true;
        }).catch(error => this.handleError(error));
        
    }

    @track versionDescription = '';
    @track revisionNumber = 0;
    @track selectedQuoteType = 'Quote';
    @track quoteTypeList = [
        { value: 'Quote', label: 'Quote'},
        { value: 'Bid', label: 'Bid'},
        { value: 'Estimate Detail', label: 'Estimate Detail'},
        { value: 'Estimate Summary', label: 'Estimate Summary'},
    ];

    @track exportColumns = [
        { Id: 'Show Item Name', label: 'Show Item Name', one: true, two: true, delta: true, all: true},
        { Id: 'Show Color', label: 'Show Color', one: true, two: true, delta: true, all: true},
        { Id: 'Show Price', label: 'Show Price', one: true, two: true, delta: true, all: true},
        { Id: 'Show Qty', label: 'Show Qty', one: true, two: true, delta: true, all: true},
        { Id: 'Show Description One', label: 'Show Description One', one: true, two: true, delta: true, all: true},
        { Id: 'Show Description Two', label: 'Show Description Two', one: true, two: true, delta: true, all: true},
        { Id: 'Show Notes', label: 'Show Notes', one: true, two: true, delta: true, all: true},
    ]
    @track exportOptions = {
        exportAltOne: true,
        exportAltTwo: true,
        exportSaveSF: true,
        exportDownloadSF: true,
        showOnlyChanges: true,
        fileName: 'Compare',
    }
    handleExportInput(event)
    {
        const name = event.target.name;
        const value = event.target.value;
        const checked = event.target.checked;
        const key = event.target.accessKey;

        let selected = this.exportColumns.filter(x => { return x.Id == key})[0];

        if (name == 'Alt Total (1)')
        {
            this.exportOptions.exportAltOne = checked;
        }
        else if (name == 'Alt Total (2)')
        {
            this.exportOptions.exportAltTwo = checked;
        }
        else if (name == 'Save to Salesforce')
        {
            this.exportOptions.exportSaveSF = checked;
        }
        else if (name == 'Show Only Changes')
        {
            this.exportOptions.showOnlyChanges = checked;
        }
        else if (name == 'Download File')
        {
            this.exportOptions.exportDownloadSF = checked;
        }
        else if (name == 'File Name')
        {
            this.exportOptions.fileName = value;
        }
        else if (name =='one')
        {
            selected.one = checked;
        }
        else if (name =='two')
        {
            selected.two = checked;
        }
        else if (name =='delta')
        {
            selected.delta = checked;
        }
        else if (name =='all')
        {
            selected.all = checked;
            selected.one = checked;
            selected.two = checked;
            selected.delta = checked;
        }
    }
    
    handleExport(event)
    {
        let params = {
            recordId: this.recordId,
            exportOptions: JSON.stringify(this.exportOptions),
            exportColumns: JSON.stringify(this.exportColumns),
            comparedJson: JSON.stringify(this.comparison),
            quoteOneName: JSON.stringify(this.firstQuote.DisplayName),
            quoteTwoName: JSON.stringify(this.secondQuote.DisplayName)
        };

        console.log(params);
        this.loaded = false;
        this.loadMessage = 'Generating export file...';
        this.exportIsActive = false;

        CreateExportReferenceFile(params).then(attachmentId => {
            console.log(attachmentId);
            let params2 = {
                recordId: this.recordId,
                attachmentId: attachmentId
            };
            GetExcelFile(params2).then(url => {
                this.loaded = true;
                ///test
                window.open(url , '_blank');
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Export file has been saved to the opportunity.',
                    variant: 'success',
                    mode: 'sticky'
                }));
            }).catch(error => this.handleError(error));
            //window.open('/apex/QuoteComparisonExport?attachmentId=' + attachmentId, '_blank');
            /*
            */
            
            //window.open('/apex/QuoteComparisonExport?attachmentId=' + attachmentId, '_blank');
        }).catch(error => this.handleError(error));
    }

    handleExportAltInput(event)
    {
        const name = event.target.name;
        const value = event.target.value;
        const checked = event.target.checked;
        const key = event.target.accessKey;

        if (name == "matchedAlts")
        {
            let alt = this.comparison.matchedAlts.filter(item => {
                return item.key == key;
            })[0];

            alt.isSelected = checked;
        }
        else if (name == "noMatchOneAlts")
        {
            let alt = this.comparison.noMatchOneAlts.filter(item => {
                return item.key == key;
            })[0];

            alt.isSelected = checked;
        }
        else if (name == "noMatchTwoAlts")
        {
            let alt = this.comparison.noMatchTwoAlts.filter(item => {
                return item.key == key;
            })[0];

            alt.isSelected = checked;
        }
    }

    handleInput(event){
        const name = event.target.name;
        const value = event.target.value;
        const checked = event.target.checked;
        const key = event.target.accessKey;

        console.log(name + ': ' + checked);
        if (name == 'Name Deduct')
        {
            let selected =  this.deductConfigs.filter(x => { return x.RowId == key})[0];
            selected.Name = value;
        }
        else if (name == 'Name Add')
        {
            let selected =  this.addConfigs.filter(x => { return x.RowId == key})[0];
            selected.Name = value;
        }
        else if (name == 'Checked Add')
        {
            let selected =  this.addConfigs.filter(x => { return x.RowId == key})[0];
            selected.checked = checked;
        }
        else if (name == 'Checked Deduct')
        {
            let selected =  this.deductConfigs.filter(x => { return x.RowId == key})[0];
            selected.checked = checked;
        }
        else if (name == 'Version Description')
        {
            this.versionDescription = value;
        }
        else if (name == 'Rev #')
        {
            this.revisionNumber = value;
        }
        else if (name == 'Quote Type')
        {
            this.selectedQuoteType = value;
        }
        else if (name == 'Primary Bidder')
        {
            this.selectedBidder = value;
        }
        else if (name == 'All')
        {
            this.options.forEach(x => {
                x.value = checked;
            });
            this.showColor = checked; 
            this.showNotes = checked;
            this.showUnitPrice = checked;
            this.showDescOne = checked;
            this.showDescTwo = checked;
            this.showMath = checked;
            this.totalColumns = checked ? 17 : 5;
            this.halfColumns = checked ? 6 : 1;
            this.showOnlyChanges = checked;
            this.showAltTotal = checked;
            this.excludeHidden = checked;
            this.handleShowOnlyChanges();
        }
        else 
        {
            let selected = this.options.filter(x => { return x.label == name; })[0];

            selected.value = checked;
            if (name == 'Show Color')
            {
                this.showColor = checked;
                this.totalColumns += selected.value ? 2 : -2;
                this.halfColumns +=selected.value ? 1 : -1;
            }
            else if (name == 'Show Unit Price')
            {
                this.showUnitPrice = checked;
                this.totalColumns += selected.value ? 2 : -2;
                this.halfColumns +=selected.value ? 1 : -1;
            }
            else if (name == 'Show Desc. One')
            {
                this.showDescOne = checked;
                this.totalColumns += selected.value ? 2 : -2;
                this.halfColumns +=selected.value ? 1 : -1;
            }
            else if (name == 'Show Desc. Two')
            {
                this.showDescTwo = checked;
                this.totalColumns += selected.value ? 2 : -2;
                this.halfColumns +=selected.value ? 1 : -1;
            }
            else if (name == 'Show Notes')
            {
                this.showNotes = checked;
                this.totalColumns += selected.value ? 2 : -2;
                this.halfColumns +=selected.value ? 1 : -1;
            }
            else if (name == 'Only Changes')
            {
                this.showOnlyChanges = checked;
                this.handleShowOnlyChanges();
            }
            else if (name == 'Show Math')
            {
                this.showMath = checked;
            }
            else if (name == 'Alt Total')
            {
                this.showAltTotal = checked;
            }
            else if (name == 'Exclude Hidden')
            {
                this.excludeHidden = checked;
                this.handleShowOnlyChanges();
            }
        }
    }

    handleShowOnlyChanges = function(){
        if (this.excludeHidden)
        {
            this.comparison.matchedAlts.forEach(y => {
                y.value.forEach(z => {
                    z.visible = !z.isHidden;
                });
                if (y.value.filter(z => { return z.visible;}).length == 0)
                {
                    y.visible = false;
                }
                else
                {
                    y.visible = true;
                }
            });
        }
        if (this.showOnlyChanges)
        {
            this.comparison.matchedAlts.forEach(y => {
                y.value.forEach(z => {
                    z.visible = this.excludeHidden && z.isHidden ? false : z.changes;
                });
            });
            this.comparison.matchedAlts.forEach(y => {
                if (y.value.filter(z => { return z.visible;}).length == 0)
                {
                    y.visible = false;
                }
                else
                {
                    y.visible = true;
                }
            });
        }
        else if (!this.showOnlyChanges)
        {
            this.comparison.matchedAlts.forEach(y => {
                y.value.forEach(z => {
                    z.visible =  this.excludeHidden && z.isHidden ? false : true;
                });
            });
            this.comparison.matchedAlts.forEach(y => {
                if (y.value.filter(z => { return z.visible;}).length == 0)
                {
                    y.visible = false;
                }
                else
                {
                    y.visible = true;
                }
            });
        }
    }

    handleQuoteOpen(event){
        const name = event.target.name;
        this.quoteIsActive = true;
        if (name == 'Quote 1')
        {
            this.quoteText = 'Quote (1) Selection';
            this.quoteNum = '1';
        }
        else
        {
            this.quoteText = 'Quote (2) Selection';
            this.quoteNum = '2';
        }
    }

    handleQuoteCancel()
    {
        this.quoteIsActive = false;
    }

    handleQuoteSelect(event)
    {
        let Id = event.target.accessKey;
        var selectedQuote = this.quoteList.filter(item => {
            return item.Id == Id;
        })[0];
        
        console.log(selectedQuote);
        if (this.quoteNum == '1') this.firstQuote = selectedQuote;
        else {
            this.secondQuote = selectedQuote;
            this.versionDescription = 'Add/Deduct - ' + selectedQuote.Version_Description__c;
            this.revisionNumber = selectedQuote.Revision_Number__c;
            this.selectedQuoteType = selectedQuote.BidQuote__c;
        }

        this.actions.filter(x => {return x.label != 'Compare';}).forEach(x => { x.disabled = 'disabled';});
        this.comparison = { matchedAlts: [], noMatchOneAlts: [], noMatchTwoAlts: [], manualAlts: []};
        this.addConfigs = [];
        this.deductConfigs = [];
        this.quoteIsActive = false;
    }

    handleHideToggle(event){
        this.isHideActive = !this.isHideActive;
    }

    handleAddDeductConfirm(event){
        this.isCreatingAddDeduct = true;
        this.isAddDeductActive = false;
        this.handleAddDeduct(event);
    }

    handleAddDeductCancel(event){
        this.isCreatingAddDeduct = false;
        this.isAddDeductActive = false;
    }

    handleAddDeduct(event){
        this.loaded = false;
        if (this.isCreatingAddDeduct)
        {
            this.loadMessage = 'Creating Quote...';
        }
        else
        {
            this.loadMessage = 'Preparing Add/Deduct Breakouts...';
        }

        if (this.isCreatingAddDeduct)
        {
            let params = {
                isCreatingAddDeduct: this.isCreatingAddDeduct,
                quote1Id: this.firstQuote.Id,
                quote2Id: this.secondQuote.Id,
                accountId: this.selectedBidder,
                description: this.versionDescription,
                quoteType: this.selectedQuoteType,
                revision: this.revisionNumber,
                addConfigsJson: JSON.stringify(this.addConfigs.filter(x => {return x.checked;})),
                deductConfigsJson: JSON.stringify(this.deductConfigs.filter(x => {return x.checked;}))
            };
            console.log('Param Param');
            console.log(params);

            createAddDeductQuote(params).then(data => {
                this.isCreatingAddDeduct = false;
                if (data.indexOf('Error') != -1)
                {
                    this.isAddDeductActive = true;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: data,
                        variant: 'warning',
                        mode: 'sticky'
                    }));
                }
                else
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'You will receive a bell notification when the add/deduct is done saving.',
                        variant: 'success',
                        mode: 'sticky'
                    }));

                    console.log('Data id is '+ data);

                    /*GetValidationFileLink({quoteId: data}).then(x => {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'File Link',
                            message: 'Link to json file: {1}.',
                            variant: 'success',
                            mode: 'sticky',
                            "messageData": [
                                'Salesforce',
                                {
                                    url: x + '/view',
                                    label: 'Click here to navigate'
                                }
                            ]
                        }));
                    })*/
                }
                this.loaded = true;
            })
        }
        else
        {
            let params = {
                quote1Id: this.firstQuote.Id,
                quote2Id: this.secondQuote.Id,
                description: this.versionDescription,
                quoteType: this.selectedQuoteType,
                revision: this.revisionNumber,
                matchedAlts: JSON.stringify(this.comparison.matchedAlts),
                noMatchOneAlts: JSON.stringify(this.comparison.noMatchOneAlts),
                noMatchTwoAlts: JSON.stringify(this.comparison.noMatchTwoAlts),
                manualMatchAlts: JSON.stringify(this.comparison.manualAlts)
            };
            console.log('Param Param');
            console.log(params);

            createAddDeductPreview(params).then(data =>{
                getBidders({quote1Id: this.firstQuote.Id, quote2Id: this.secondQuote.Id}).then(data2 =>{
                    this.bidderList = [];
                    
                    let tempList = [];
                    console.log(data2);
                    data2.forEach(z => {
                        tempList.push({ value: z.Id, label: z.Name});
                    });
                    this.bidderList = tempList;
                    if (this.bidderList.length > 0)
                        this.selectedBidder = this.bidderList[0].value;

                    console.log(data);
                    let results = JSON.parse(data);
                    console.log(results);
                    let index = 0;
                    this.deductConfigs = [];
                    this.addConfigs = [];
                    results.forEach(x => {
                        x.RowId = index++;
                        x.checked = true;
                        if (x.Name.indexOf('DEDUCT -') === 0 && this.deductConfigs.filter(y => { return y.Name == x.Name}).length == 0 )
                        {
                            this.deductConfigs.push(x);
                        }
                        else if (x.Name.indexOf('ADD -') === 0 && this.addConfigs.filter(y => { return y.Name == x.Name}).length == 0)
                        {
                            this.addConfigs.push(x);
                        }
                    });
        
                    this.addConfigs = this.addConfigs.sort((x,y) => {
                        return x.Name > y.Name ? 1 :
                            x.Name < y.Name ? -1 : 0
                    });
        
                    this.deductConfigs = this.deductConfigs.sort((x,y) => {
                        return x.Name > y.Name ? 1 :
                            x.Name < y.Name ? -1 : 0
                    });
        
                    this.isAddDeductActive = true;
                    this.loaded = true;
                });
            }).catch(error => this.handleError(error));
        }
    }

    handleAddDeductCancel = function(event){
        this.isAddDeductActive = false;
    }

    handleHide(event){
        const altId = event.target.accessKey.split(',')[0];
        const rowId = event.target.accessKey.split(',')[1];

        let selectedAlt = this.comparison.matchedAlts.filter(item => {
            return item.key == altId;
        })[0];

        let selectedRow = selectedAlt.value.filter(item => {
            return item.key.split(',')[1] == rowId;
        })[0];

        selectedRow.isHidden = !selectedRow.isHidden;

        this.updateAltTotals();

        this.actions.filter(x => {return x.label == 'Reset';})[0].disabled = '';
        this.handleShowOnlyChanges();
    }

    handleMatchOpen(event){
        this.matchIsActive = true;
    }

    handleMatchClose(event){
        this.matchIsActive = false;
    }

    
    handleMatchUnselect(event)
    {
        let Id = event.target.accessKey;
        const name = event.target.name;
        let selectedAlt = {};
        if (name == 'One')
        {
            selectedAlt = this.comparison.noMatchOneAlts.filter(item => {
                return item.key == Id;
            })[0];
            selectedAlt.cssClass = "";
            selectedAlt.isSelected = false;
            this.matchSelection.one = undefined;
        }
        else if (name == 'Two')
        {
            selectedAlt = this.comparison.noMatchTwoAlts.filter(item => {
                return item.key == Id;
            })[0];
            selectedAlt.cssClass = "";
            selectedAlt.isSelected = false;
            this.matchSelection.two = undefined;
        }
        else
        {
            this.comparison.noMatchOneAlts.push(this.comparison.manualAlts.filter(item => {
                return item.one.key == Id
            })[0].one);

            this.comparison.noMatchTwoAlts.push(this.comparison.manualAlts.filter(item => {
                return item.one.key == Id
            })[0].two);

            this.comparison.manualAlts = this.comparison.manualAlts.filter(item => {
                return item.one.key != Id;
            });
        }
    }

    handleMatchSelect(event)
    {
        let Id = event.target.accessKey;
        let name = event.target.name;
        let selectedAlt = {};
        if (name == 'One')
        {
            selectedAlt = this.comparison.noMatchOneAlts.filter(item => {
                return item.key == Id;
            })[0];
            selectedAlt.isSelected = true;
            selectedAlt.cssClass = "change-green";
            this.matchSelection.one = selectedAlt;
        }
        else
        {
            selectedAlt = this.comparison.noMatchTwoAlts.filter(item => {
                return item.key == Id;
            })[0];
            selectedAlt.isSelected = true;
            selectedAlt.cssClass = "change-green";
            this.matchSelection.two = selectedAlt;
        }

        if (this.matchSelection.one != undefined && this.matchSelection.two != undefined)
        {
            selectedAlt = this.comparison.noMatchOneAlts.filter(item => {
                return item.key == this.matchSelection.one.key;
            })[0];
            selectedAlt._isSelected = false;
            selectedAlt.cssClass = "";

            selectedAlt = this.comparison.noMatchTwoAlts.filter(item => {
                return item.key == this.matchSelection.two.key;
            })[0];
            selectedAlt._isSelected = false;
            selectedAlt.cssClass = "";

            this.comparison.noMatchOneAlts = this.comparison.noMatchOneAlts.filter(x => { return x.key != this.matchSelection.one.key});
            this.comparison.noMatchTwoAlts = this.comparison.noMatchTwoAlts.filter(x => { return x.key != this.matchSelection.two.key});
            this.comparison.manualAlts.push(this.matchSelection);
            this.matchSelection = { one: undefined, two: undefined};
        }
    }

    handleMatchProcess = function(){
        this.handleMatchClose();
        this.loaded = false;
        this.comparisonLoaded = false;
        this.index = 0;
        this.size = this.comparison.manualAlts.length;
        this.comparison.manualAlts.forEach(y => {
            console.log(y.one);
            console.log(y.two);

            if (y.one.AlternateId == undefined)
                y.one.AlternateId = 
                    y.one.value.filter(qli => { return qli.first != undefined && qli.first.item != undefined;})[0].first.item.Alternate__r.Description__c;
            
            if (y.two.AlternateId == undefined)
                y.two.AlternateId = 
                    y.two.value.filter(qli => { return qli.second != undefined && qli.second.item != undefined;})[0].second.item.Alternate__r.Description__c;
            
            let params = {
                altOneId: y.one.AlternateId,
                altTwoId: y.two.AlternateId,
                quoteOneId: this.firstQuote.Id,
                quoteTwoId: this.secondQuote.Id
            };
            let altName = y.one.key + ' vs. ' + y.two.key;
            console.log(params);
            this.ajaxCount++;
            this.comparison.matchedAlts = this.comparison.matchedAlts.filter(x => {return x.AlternateId != params.altOneId && x.AlternateId != params.altTwoId;});
            createComparisonMatch(params).then(data => {
                this.handleMatchClose();
                this.handleComparison(altName,data);
                if (this.ajaxCount == 0 && this.index == this.size)
                {
                    this.comparison.manualAlts = [];
                    this.actions.filter(x => {return x.label == 'Reset';})[0].disabled = '';
                }
            });
        })
    }

    handleReset(event){
        console.log('reset');
        this.actions.filter(x => {return x.label != 'Compare';}).forEach(x => { x.disabled = 'disabled';});
        this.compareRevisions();
    };

    handleError = function(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning',
                mode: 'sticky'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'warning',
                mode: 'sticky'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'warning',
                mode: 'sticky'
            }));
        }
        this.loadMessage = 'Loading...';
        this.loaded = true;
    };

    handleOpportunitySearch(event) {
        const target = event.target;
        console.log(event.detail);
        OpportunitySearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting opportunities: " + error);
            });
    }


    @track opportunitySelection = {};

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

            this.recordId = id;

            let params = { opportunityId: this.recordId };

            getQuotes(params).then(data => {
                console.log(data);
                data.forEach(x => {
                    x.DisplayName = (x.MSCRM_ID__c != undefined ? '(CRM 2011) ' : '') + 
                                    x.QuoteNumber + ', Rev #' + x.Revision_Number__c + ': ' + x.Version_Description__c;
                    x.CreatedDate = new Date(x.CreatedDate).toLocaleString("en-US");
                    x.Link = window.location.protocol + '//' + window.location.host + '/lightning/r/' + x.Id + '/view'
                });
                this.quoteList = data;
                this.loaded = true;
            }).catch(error => this.handleError(error));
        }
    }
}