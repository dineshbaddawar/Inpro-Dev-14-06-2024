import {
    LightningElement,
    api,
    track,
    wire,
} from 'lwc';

import getEDIDetails from '@salesforce/apex/EDIActionPanelHelper.getEDIDetails';
import getOrderRequest from '@salesforce/apex/EDIActionPanelHelper.getOrderRequest';
import updateDetails from '@salesforce/apex/EDIActionPanelHelper.updateDetails';

export default class EdiActionPanel extends LightningElement {

    @api recordId;
    @track itemList = [];
    @track orderRequestIdUrl = '';
    @track orderRequestName = '';
    @track quoteIdUrl = '';
    @track quoteName = '';
    @track opportunityIdUrl = '';
    @track opportunityName = '';
    @track loaded = false;

    connectedCallback() {
        // initialize component
        this.refresh();
    };

    refresh() {
        this.loaded = false;
        this.loadRecords();
        this.loadOrderRequest();
    }

    loadRecords() {
        try {


            getEDIDetails({
                    recordId: this.recordId
                }).then(data => {
                    if (data) {
                        console.log(data);
                        data.forEach(x => {
                            if (x.Line_Change_Code__c != null && x.Line_Change_Code__c != '')
                                x.AdjustedPrice = Number(x.Line_Change_Code__c)
                            else
                                x.AdjustedPrice = 0;
                            try {


                                if (x.Inpro_Unit_Price__c != null)
                                    x.Inpro_Unit_Price__c = (Math.round(x.Inpro_Unit_Price__c * 100) / 100).toFixed(2);

                            } catch (error) {
                                console.log(JSON.stringify(error));
                            }

                        });
                        this.itemList = data;
                        this.sortedBy = "Sequence_Number__c";
                    } else if (error) {
                        this.error = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    console.log("Error loading EDI Line Items: " + JSON.stringify(error));
                });
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }

    round(value, decimals) {
        return Number(Math.round(value + 'e' + decimals) + 'e-' + decimals);
    }

    loadOrderRequest() {
        try {
            getOrderRequest({
                    recordId: this.recordId
                }).then(data => {
                    if (data) {
                        console.log(data);
                        this.orderRequestIdUrl = window.location.origin + '/' + data.Id;
                        this.orderRequestName = data.Name;
                        this.quoteIdUrl = window.location.origin + '/' + data.QuoteId__c;
                        this.quoteName = data.QuoteId__r.Name;
                        this.opportunityIdUrl = window.location.origin + '/' + data.Opportunity__c;
                        this.opportunityName = data.Opportunity__r.Name;
                    } else if (error) {
                        console.log(error);
                    }
                })
                .catch(error => {
                    // TODO: handle error
                    var jsonError = JSON.stringify(error);
                    console.log("Error loading order request: " + jsonError);
                });
        } catch (error) {
            var jsonError = JSON.stringify(error);
            console.log("Error loading order request1: " + jsonError);
        }
    }

    applyPricing() {
        this.itemList.forEach(x => {
            x.AdjustedPrice = x.Inpro_Unit_Price__c;
        });

        this.itemList = [...this.itemList];
    }

    handleItemUpdate(event) {
        try {
            let value = event.target.value;
            let selectedItem = this.itemList.filter(function (item) {
                return item.Id === event.target.accessKey;
            })[0];
            console.log("selected value changing: " + value + " " + selectedItem.Id + " key: " + event.target.accessKey);
            selectedItem[event.target.name] = value;
            console.log(selectedItem[event.target.name]);
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }

    saveChanges(event) {
        this.loaded = false;
        var list = [];
        this.itemList.forEach(x => {
            var item = {
                Id: x.Id,
                Line_Number__c: x.Line_Number__c,
                Name: x.Name,
                Notes__c: x.Notes__c,
                Unit_Price__c: x.Unit_Price__c,
                Quantity__c: x.Quantity__c,
                Inpro_Unit_Price__c: x.AdjustedPrice,
                Response__c: x.Response__c

            };
            list.push(item);
        });

        console.log(list);

        updateDetails({
                details: list
            }).then(data => {
                if (data) {
                    console.log(data);
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error saving line items: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }
}