import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getQuoteLineItems from '@salesforce/apex/CustomPricingHelper.getQuoteLineItems';
import createPricingRequests from '@salesforce/apex/CustomPricingHelper.createPricingRequests';
import userId from '@salesforce/user/Id';
import createAsyncProcess from '@salesforce/apex/QuickConfigHelper.createAsyncProcess';
import cancelAsyncProcess from '@salesforce/apex/QuickConfigHelper.cancelAsyncProcess';
import cancelPricingRequests from '@salesforce/apex/CustomPricingHelper.cancelPricingRequests';
import resetCustomPricing from '@salesforce/apex/CustomPricingHelper.resetCustomPricing';


export default class RequestCustomPricing extends LightningElement {
    @api recordId;
    loaded = false;
    @track QuoteProductList = [];
    @track showError = false;
    @track errorMessage = false;



    connectedCallback() {
        // initialize component
        this.loadQuoteProducts();
    }

    loadQuoteProducts() {
        this.QuoteProductList = [];
        getQuoteLineItems({
                quoteId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        var prodJSON = JSON.stringify(data);
                        console.log(prodJSON);
                        //var obj = JSON.parse(data);
                        data.forEach(prod => {
                            prod.Selected = false;
                            this.QuoteProductList.push(prod);
                        });
                        this.loaded = true;
                    } catch (error) {
                        console.log("Error Loading Products: " + error);
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                console.log("Error getting Products: " + errorJSON);
            });
    }

    resetCustomPricing()
    {
        this.loaded = false;
        resetCustomPricing({
            quoteId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    var prodJSON = JSON.stringify(data);
                    console.log(prodJSON);
                    //var obj = JSON.parse(data);   
                    this.loadQuoteProducts();
                    
                } catch (error) {
                    console.log("Error Resetting Requests: " + error);
                }
            } else if (error) {
                this.error = error;
                console.log(error);
            }            
        })
        .catch(error => {
            var errorJSON = JSON.stringify(error);
            console.log("Error Resetting Custom Pricing: " + errorJSON);
        });

    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.QuoteProductList.filter(prod => {
            return prod.Id == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
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
                    } else
                        this.createRequests();
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

    createRequests(event) {
        this.loaded = false;
        console.log(this.recordId);
        var quoteProducts = [];
        this.QuoteProductList.filter(x => {
            return x.Selected == true
        }).forEach(p => {
            quoteProducts.push(p.Id);
        });

        //String userId, List<string> quoteProducts

        createPricingRequests({
                userId: userId,
                quoteProducts: quoteProducts
            }).then(data => {
                if (data) {
                    try {
                        console.log(data);
                        if (data.includes('error') || data.includes('CustomPricingHelper')) {
                            var errJSON = JSON.stringify(data);
                            this.error = errJSON;
                            this.showError = true;
                            this.cancelRequest();
                        } else {
                            this.closeQuickAction();
                        }
                        this.loaded = true;
                    } catch (error) {
                        console.log("Error creating pricing requests: " + error);
                        this.cancelRequest();
                        this.loaded = true;
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                    this.cancelRequest();
                }
                this.loaded = true;
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                console.log("Error creating pricing requests: " + errorJSON);
                this.cancelRequest();
                this.loaded = true;
            });

    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }


    cancelRequest() {
        cancelAsyncProcess({
                recordId: this.recordId,
                UserId: userId
            }).then(data => {
                if (data) {
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);                 
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error canceling async process: " + errorJson);
                this.loaded = true;
            });

            var quoteProducts = [];
            this.QuoteProductList.filter(x => {
                return x.Selected == true
            }).forEach(p => {
                quoteProducts.push(p.Id);
            });
            

            cancelPricingRequests({
                userId: userId,
                quoteProducts: quoteProducts
            }).then(data => {
                if (data) {                    
                        console.log(data);                                                                  
                } else if (error) {
                    this.error = error;
                    console.log(error);                    
                }                
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                console.log("Error canceling pricing requests: " + errorJSON);                
            });

         }

}