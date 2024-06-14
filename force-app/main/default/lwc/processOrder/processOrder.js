import {
    LightningElement,
    api,
    track
} from 'lwc';

import getLocations from '@salesforce/apex/ProcessOrderHelper.getLocations';
import getOpportunity from '@salesforce/apex/ProcessOrderHelper.getOpportunity';
import getQuoteProducts from '@salesforce/apex/ProcessOrderHelper.getQuoteProducts';
import processOrder from '@salesforce/apex/ProcessOrderHelper.processOrder';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import getOrderRequest from '@salesforce/apex/ProcessOrderHelper.getOrderRequest';
import isAccountOnCreditHOld from '@salesforce/apex/RequestOrderHelper.isAccountOnCreditHOld';
//import CheckDeniedPartyStatus from '@salesforce/apex/DeniedPartyHelper.CheckDeniedPartyStatus';

export default class ProcessOrder extends LightningElement {

    @api recordId;
    @track loaded = false;
    @track showError = false;
    @track showErrorButton = true;
    @track errorMessage = '';
    @track locationList = [];
    @track location = '';
    @track alternateList = [];
    @track orderProcessed = false
    @track metricDescriptions = false;
    @track orderNumber = '';
    @track orderLink = '';
    @track allowQuoteProductSelection = true;
    @track customerNumber = '';
    @track CreditHold = false;
    @track accountId = '';
    @track AccountIsDeniedParty = false;
    @track submitButtonEnabled = true;
    @track selectedAlternates = '';

    connectedCallback() {
        getOpportunity({recordId: this.recordId}).then(opp => {
            if (opp != null && opp.Market_Segment__c != null)
            {
                this.loadOrderRequest();
                this.loadLocations();                 
            }
            else if (opp != null && opp.Market_Segment__c == null)
            {
                this.loaded = true;
                this.showError = true;
                this.showErrorButton = false;
                this.errorMessage = 'The Opportunity on this order request does not have a Market Segment. ' +
                                    'Please set the market segment before processing order.';
            }
            else if (opp == null)
            {
                this.loaded = true;
                this.showError = true;
                this.showErrorButton = false;
                this.errorMessage = 'There is no Opportunity associated with the Order Request!';
            }
        });
               
    }

    checkCreditHold() {
        isAccountOnCreditHOld({
                customerNumber: this.customerNumber
            }).then(data => {
                if (data) 
                    this.CreditHold = data;                           
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error Checking CreditHold: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    loadQuoteProducts() {
        console.log(this.recordId);
        getQuoteProducts({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    var selectedAlternateArr;
                    if(this.selectedAlternates != null && this.selectedAlternates != '')
                    {
                        selectedAlternateArr = this.selectedAlternates.split(',');
                    }

                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    //Alternate__r.Id, Id, Item_Number__c, Color__c, Description, Description_2__c, Price_Per_Unit__c, Quantity, Subtotal, Alternate__c
                    data.forEach(prod => {

                        var alternate = {
                            AlternateId: prod.Alternate__r.Id,
                            AlternateName: prod.Alternate__r.Name__c,
                            Selected: false,
                            QuoteProducts: []
                        };

                        var product = {
                            Id: prod.Id,
                            ItemNumber: prod.Item_Number__c,
                            Color: prod.Color__c,
                            Description1: prod.Description,
                            Description2: prod.Description_2__c,
                            Price: prod.Price_Per_Unit__c,
                            Total: prod.Subtotal,
                            Quantity: prod.Quantity,
                            Selected: false,
                            AlternateId: prod.Alternate__r.Id,
                            UnitPrice: prod.UnitPrice
                        };

                        if(selectedAlternateArr != null && selectedAlternateArr.includes(prod.Alternate__r.Id))
                        {
                            product.Selected = true;
                            alternate.Selected = true;
                        }

                        var existingAlternate = this.alternateList.filter(function (alt) {
                            return alt.AlternateId === alternate.AlternateId;
                        })[0];

                        if (existingAlternate != null) {
                            existingAlternate.QuoteProducts.push(product);                            
                        } else {
                            alternate.QuoteProducts.push(product);
                            this.alternateList.push(alternate);
                        }

                    });

                    

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting alternates: " + errorJSON);
                this.loaded = true;
            });
    }

    
    loadOrderRequest() {
        getOrderRequest({
            recordId: this.recordId
        }).then(data => {
                if (data) {                 
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);

                    if(data.Division__c == 'Endurant')
                        this.allowQuoteProductSelection = false;

                    if(data.Selected_Alternates__c != null && data.Selected_Alternates__c != '')
                        this.selectedAlternates = data.Selected_Alternates__c;

                    this.customerNumber = data.Account__r.Customer_Number__c;
                    if((data.Account__r.Status__c != 'Approved' && data.Account__r.Status__c != 'Customer') || data.Account__r.Inactive__c == true)
                    {
                        this.submitButtonEnabled = false;
                        alert('Error: The account associated to this order request is either inactive or not approved, therefore the order cannot be pushed to Staging.');
                    }
                    this.accountId = data.Account__c;
                 
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
                this.loadQuoteProducts();
                this.checkCreditHold();
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting locations: " + errorJSON);
                this.loaded = true;
            });
    }

    loadLocations() {
        getLocations()
            .then(data => {
                if (data) {
                    console.log(data);
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(loc => {
                        var locOption = {
                            value: loc,
                            label: loc
                        };
                        this.locationList = [...this.locationList, locOption];
                    });

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting locations: " + errorJSON);
                this.loaded = true;
            });
    }

    checkAccountDeniedParty()
    {
        CheckDeniedPartyStatus({
            accountId: this.accountId
        }).then(data => {
                if (data) {                 
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    if(data.isAccountBlocked || data.hasRetrievalErrorOccurred)
                    {
                        this.showError = true;
                        this.error = data.message;
                        console.log(data.message);
                        this.AccountIsDeniedParty = true;
                        this.loaded = true;
                    }
                    else
                        this.callProcessOrder();             
                } else if (error) {
                    this.showError = true;
                    this.error = error;
                    console.log(error);
                    this.loaded = true;
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                this.showError = true;
                this.error = "Error checking denied party status: " + errorJSON;
                console.log("Error checking denied party status: " + errorJSON);
                this.loaded = true;
            });
    }

    callProcessOrder() {

        console.log(this.recordId);
        console.log(this.metricDescriptions);
        console.log(this.location);

        if(this.location == '' || this.location == null)
        {
            this.showError = true;
            this.errorMessage = 'Error: You have to enter a location before processing this order.';
            this.loaded = true;
        }
        else
        {
            var selectedPrducts = [];
            this.alternateList.forEach(alt => {
                if (alt.QuoteProducts != null) {
                    alt.QuoteProducts.forEach(prod => {
                        if (prod.Selected == true) {
                            selectedPrducts.push(prod.Id);
                        }
                    });
                }
            });
            var quoteProducts = JSON.stringify(selectedPrducts);
            console.log(quoteProducts);

            processOrder({
                    recordId: this.recordId,
                    quoteProducts: quoteProducts,
                    isMetric: this.metricDescriptions,
                    location: this.location,
                    userId: USER_ID
                })
                .then(data => {
                    if (data) {
                        console.log(data);
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        var containsTBD = data.includes('TBD');
                        if (containsTBD == true) {
                            this.orderNumber = 'TBD' + data.split('TBD')[1];
                            this.orderLink = data;
                        } else {
                            this.errorMessage = data;
                            this.showError = true;
                        }

                    } else if (error) {
                        this.error = error;
                        console.log(error);
                        this.errorMessage = error;
                        this.showError = true;
                    }
                    this.orderProcessed = true;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJSON = JSON.stringify(error);
                    console.log("Error processing order: " + errorJSON);
                    this.loaded = true;
                    this.errorMessage = errorJSON;
                    this.showError = true;
                });
        }
    }

    handleLocationComboBoxOnchange(event) {
        this.location = event.target.value;
    }

    handleMetricDescriptionsCheckboxUpdate(event) {
        this.metricDescriptions = event.target.checked;
    }

    handleProcessOrderClick(event) {
        this.loaded = false;
        //this.checkAccountDeniedParty();
        this.callProcessOrder();
    }

    handleOptionSelected(event) {
        try {                    
            var optionId = event.target.accessKey;
            var alternateId = event.target.name;
            console.log(optionId);
            let existingAlternate = this.alternateList.filter(function (alt) {
                return alt.AlternateId === alternateId;
            })[0];
            console.log(existingAlternate.AlternateId);
            let selectedProduct = existingAlternate.QuoteProducts.filter(function (item) {
                return item.Id === optionId;
            })[0];
            console.log(selectedProduct.Selected);
            console.log(selectedProduct.Id);
            selectedProduct.Selected = event.target.checked;
            console.log(selectedProduct.Selected);
        } catch (error) {
            var errorJSON = JSON.stringify(error);
            console.log("Error selecting item order: " + errorJSON);
        }
    }

    handleAlternateSelected(event) {
        var alternateId = event.target.accessKey;
        console.log(alternateId);
        let existingAlternate = this.alternateList.filter(function (alt) {
            return alt.AlternateId === alternateId;
        })[0];

        existingAlternate.QuoteProducts.forEach(x => {
            x.Selected = event.target.checked;
        });
    }
    
    handleErrorMessageBack(event) {
        this.showError = false;
        this.AccountIsDeniedParty = false;
        this.errorMessage = '';
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}