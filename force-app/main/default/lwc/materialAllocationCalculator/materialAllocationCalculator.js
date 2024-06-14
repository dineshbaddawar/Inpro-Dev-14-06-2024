import {
    LightningElement,
    api,
    track
} from 'lwc';

import calcAllocations from '@salesforce/apex/MaterialAllocationCalculatorHelper.calcAllocations';
import createAsyncProcess from '@salesforce/apex/QuickConfigHelper.createAsyncProcess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import userId from '@salesforce/user/Id';

export default class MaterialAllocationCalculator extends LightningElement {

    @api recordId;
    loaded = false;
    @track showError = false;
    @track errorMessage = false;
    @track loadMessage = 'Loading...';
    @track products = [];
    @track imageData = ''; //'data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
    @track selectedItem = {};

    connectedCallback() {
        // initialize component        
        this.createAsyncTask();
    }

    createAsyncTask() {              
        console.log(this.recordId);
        console.log(userId);
        console.log("create async task");
        this.loadMessage = 'Saving quote...';
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
                        this.loadMessage = 'Loading...';
                    }
                    else
                    {
                        this.loadMessage = 'Calculating Allocations...';
                        this.runCalcAllocations();
                    }
                        
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
                this.loadMessage = 'Loading...';
            });
    }

    runCalcAllocations() {
        calcAllocations({
                quoteId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        console.log(data);
                        if (data == null)
                        {
                            this.loaded = true;
                            this.loadMessage = 'Loading...';
                            this.showError = true;
                            this.errorMessage = "No quote products applicable for this process.";
                        }
                        else
                        {
                            var obj = JSON.parse(data);
                            obj.forEach(prod => {
                                this.products.push(prod);
                            });
                            this.loaded = true;
                            this.loadMessage = 'Loading...';
                        }
                    } catch (error) {
                        console.log("Error running calculations: " + error);
                        this.showError = true;
                        this.errorMessage = error;
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
                this.loadMessage = 'Loading...';
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                this.errorMessage = errorJSON;
                this.showError = true;
                console.log("Error running calculations: " + errorJSON);
            });
    }

    handleSelected(event) {
        try {
            var selected = this.products.filter(x => {
                return x.Id == event.detail.name
            })[0];
            console.log('Getting selected:');
            console.log(selected);

            if (selected.AllocationMaps == null)
            {
                this.loaded = false;
                this.loadMessage = 'Fetching image...';
                console.log('Fetching map');
                calcAllocations({
                    quoteId: this.recordId,
                    quoteProductId: event.detail.name
                }).then(data => {
                    if (data) {        
                        //console.log(dataJson);      
                        var obj = JSON.parse(data);

                        //replace item in array so that we don't query for this image again against the server
                        var indexOfSelected = this.products.findIndex(x => { return x.Id == event.detail.name; });
                        this.products[indexOfSelected] = obj[0];

                        //show image
                        this.imageData = 'data:application/png;base64,' + obj[0].AllocationMaps.AllocationMap[0].Image;
                        this.loaded = true;
                        this.loadMessage = 'Loading...';
                    }
                });
            }
            else
            {
                this.imageData = 'data:application/png;base64,' + selected.AllocationMaps.AllocationMap[0].Image;
            }
            
        } catch (error) {
            var errorJSON = JSON.stringify(error);
            console.log(errorJSON);
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}