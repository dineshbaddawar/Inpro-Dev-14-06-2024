import {
    LightningElement,
    api,
    track
} from 'lwc';

import getCustomPricingLineItems from '@salesforce/apex/CustomPricingHelper.getCustomPricingLineItems';
import updateQuoteProducts from '@salesforce/apex/CustomPricingHelper.updateQuoteProducts';
import createAsyncProcess from '@salesforce/apex/QuickConfigHelper.createAsyncProcess';
import cancelAsyncSave from '@salesforce/apex/CustomPricingHelper.cancelAsyncSave';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class CustomPricingQuoteProducts extends LightningElement {

    @api recordId;
    loaded = false;
    @track QuoteProductList = [];
    @track showError = false;
    @track errorMessage = false;
    @track quoteId = '';
    @track saveAttempted = false;

    connectedCallback() {
        // initialize component
        this.loaded = false;
        this.loadQuoteProducts();
    }

    loadQuoteProducts() {
        getCustomPricingLineItems({
                customPricingId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        console.log(data);
                        data.forEach(product => {
                            this.quoteId = product.Quote.Id;
                            this.QuoteProductList.push(product);
                        });

                        this.loaded = true;
                    } catch (error) {
                        console.log("Error Loading Quote Products: " + error);
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                console.log("Error getting quote products: " + errorJSON);
                this.showError = true;
                this.error = errorJSON;
            });
    }

    cancelSave()
    {
        console.log(this.quoteId);
        this.loaded = false;
        cancelAsyncSave({
            quoteId: this.quoteId            
        }).then(data => {
            if (data) {
                var dataJson = JSON.stringify(data);
                console.log(dataJson);
            } else if (error) {
                this.error = error;
                console.log(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            var errorJson = JSON.stringify(error);
            console.log("Error canceling async process: " + errorJson);
            this.loaded = true;
        });

    }

    createAsyncTask() {
        this.loaded = false;
        console.log(this.quoteId);
        console.log(userId);
        console.log("create async task");
        createAsyncProcess({
                recordId: this.quoteId,
                UserId: userId
            }).then(data => {
                if (data) {
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);

                    if (data.includes("Save in progress")) {
                        this.showError = true;
                        this.errorMessage = data;
                        this.loaded = true;
                        this.saveAttempted = true;
                    } else
                        this.submitProducts();
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

    submitProducts(event) {
        try {
            console.log("submit products");
            var quoteProducts = [];
            this.QuoteProductList.forEach(p => {
                // var pJson = JSON.stringify(p);
                // console.log(pJson);
                var qp = {
                    UserId: userId,
                    QuoteId: p.Quote.Id,
                    RequestorId: p.Custom_Pricing__r.CreatedBy.Id,
                    CustomPricingRequestId: p.Custom_Pricing__c,
                    ParentID: p.ParentId__c,
                    AlternateName: p.LineNumber__c,
                    ExpRecordId: p.RecordId__c,
                    DocumentName: p.Document_Name__c,
                    TNote: p.T_Note__c,
                    AdditionalLiner: p.Additional_Liner__c,
                    Labor: p.Labor__c,
                    Id: p.Id,
                    ItemNumber: p.Item_Number__c
                };
                quoteProducts.push(qp);
            });

            var qpJson = JSON.stringify(quoteProducts);
            console.log(qpJson);

            updateQuoteProducts({
                    userId: userId,
                    quoteProducts: qpJson
                }).then(data => {
                    if (data) {
                        try {
                            console.log(data);
                            this.loaded = true;
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Success!',
                                message: 'Products updated successfully, feel free to mark the task complete (Doing this will notify the requestor).',
                                variant: 'success',
                                mode: 'sticky'
                            }));
                        } catch (error) {
                            console.log("Error processing request: " + error);
                            this.error = "Error processing request: " + error;
                            this.showError = true;
                            this.loaded = true;
                        }
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                        this.showError = true;
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    var errorJSON = JSON.stringify(error);
                    console.log("Error processingrequest : " + errorJSON);
                    this.error = errorJSON;
                    this.showError = true;
                    this.loaded = true;
                });
        } catch (error) {
            var errorJSON = JSON.stringify(error);
            console.log("Error submitting request : " + errorJSON);
            this.error = errorJSON;
            this.showError = true;
            this.loaded = true;
        }
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    handleGridInputChange(event) {
        if (this.QuoteProductList.length > 0) {
            let value = event.target.value;
            let selectedItem = this.QuoteProductList.filter(function (product) {
                return product.Id === event.target.accessKey;
            })[0];

            console.log("selected value changing: " + value + " " + selectedItem.Id + " key: " + event.target.accessKey);
            selectedItem[event.target.name] = value;
            console.log(selectedItem[event.target.name]);

        }
    }

}