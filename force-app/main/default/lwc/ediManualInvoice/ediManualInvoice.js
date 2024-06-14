import {
    LightningElement,
    api,
    track,
    wire,
} from 'lwc';

import getERPParts from '@salesforce/apex/EDIManualInvoiceHelper.getERPParts';
import getXMLLineItems from '@salesforce/apex/EDIManualInvoiceHelper.getXMLLineItems';
import updateXMLItems from '@salesforce/apex/EDIManualInvoiceHelper.updateXMLItems';

export default class EdiManualInvoice extends LightningElement {
    @api recordId;
    @track itemList = [];
    @track erpItemList = [];
    @track loaded = false;

    connectedCallback() {
        this.loadERPItems();
        this.loadXMLItems();
    }

    handleItemUpdate(event) {
        try {
            let value = event.target.value;
            let selectedItem = this.itemList.filter(function (item) {
                return item.LineNumber === event.target.accessKey;
            })[0];
            console.log("selected value changing: " + value + " " + selectedItem.LineNumber + " key: " + event.target.accessKey);
            selectedItem[event.target.name] = value;
            console.log(selectedItem[event.target.name]);
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }

    handleRemoveItem(event) {
        this.itemList = this.itemList.filter(function (item) {
            return item.LineNumber != event.target.accessKey;
        });
    }

    updateXML() {
        var itemListJson = JSON.stringify( this.itemList);
        console.log(itemListJson);
        updateXMLItems({
                statusId: this.recordId,
                lineItems: itemListJson
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
                console.log("Error updating XML Line Items: " + JSON.stringify(error));
            });
    }

    loadERPItems() {
        getERPParts({
                statusId: this.recordId
            }).then(data => {
                if (data) {
                    console.log(data);
                    var jsonList = JSON.parse(data);
                    this.erpItemList = jsonList.MacolaPartList;
                    //this.sortedBy = "Sequence_Number__c";
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error loading ERP EDI Line Items: " + JSON.stringify(error));
            });
    }

    loadXMLItems() {
        getXMLLineItems({
                statusId: this.recordId
            }).then(data => {
                if (data) {
                    console.log(data);
                    var jsonList = JSON.parse(data);
                    this.itemList = jsonList.EDIXmlLineItemList;
                    //this.sortedBy = "Sequence_Number__c";
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error loading ERP EDI Line Items: " + JSON.stringify(error));
            });
    }


    addLineItem(event) {

        try {

            var maxLineItem = 1;
            if (this.itemList != null)
                var maxLineItem = this.itemList.length + 1;
                else
                this.itemList = [];

            var item = {
                LineNumber: String(maxLineItem)
            }
            this.itemList.push(item);
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }

    handleSort(event) {

    }

    submit(event) {
        this.loaded = false;
        this.updateXML();
    }



}