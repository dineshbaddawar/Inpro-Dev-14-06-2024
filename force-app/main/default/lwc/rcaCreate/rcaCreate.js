import {
    LightningElement,
    track
} from 'lwc';
import CreateRCARequest from '@salesforce/apex/RCAHelper.CreateRCARequest';

import userId from '@salesforce/user/Id';

export default class RcaCreate extends LightningElement {

    loaded = true;
    Response = '';
    @track orderNumber = '';
    @track rcaType = '';
    @track invoiceNumber = '';

    get options() {
        return [
            { label: '', value: '' },
            { label: 'RMA', value: 'RMA' },
            { label: 'Freight Adjustment', value: 'Freight Adjustment' },
            { label: 'Record Only', value: 'Record Only' },
            { label: 'Adjustment', value: 'Adjustment' },
            { label: 'Rework', value: 'Rework' }
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.rcaType = event.detail.value;
    }

    handleOrderNumberOnChange(event) {
        this.orderNumber = event.target.value;
    }

    handleInvoiceNumberOnChange(event) {
        this.invoiceNumber = event.target.value;
    }

    handleCreateRCAClick() {
        this.loaded = false;
        this.callCreateRCA();
    }

    callCreateRCA() {
        try {
            var currentDate = new Date(new Date().getTime());
            //var currentDate = new Date('July 31, 2021 03:24:00');
            var month = currentDate.getMonth();

            currentDate.setDate(currentDate.getDate() + 1);
            var isLastDayOfMonth = currentDate.getMonth() !== month;
            if(this.rcaType == "Record Only" && isLastDayOfMonth)
            {
                this.Response = "You cannot create a Record Only request on the last day of the month.";
                this.loaded = true;
            }
            else
            {
                console.log("RCA Type: " + this.rcaType);
                console.log("Order Number: " + this.orderNumber);
                console.log("Invoice Number: " + this.invoiceNumber);
                CreateRCARequest({
                    rcaType: this.rcaType,
                    orderNumber: this.orderNumber,
                    invoiceNumber: this.invoiceNumber,
                    createdById: userId
                }).then(data => {
                    this.Response = JSON.stringify(data);
                    console.log(data);
                    if(!data.toLowerCase().includes("error"))
                        document.location = "https://" + location.hostname + "/lightning/r/RCA__c/" + data + "/view";
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error creating RCA: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });
            }
        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error creating RCA: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

}