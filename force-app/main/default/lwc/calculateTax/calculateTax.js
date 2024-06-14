import {
    LightningElement,
    api
} from 'lwc';
import getQuoteTaxFromButton from '@salesforce/apex/TaxHelper.getQuoteTaxFromButton';
import updateAlternateTax from '@salesforce/apex/TaxHelper.updateAlternateTax';

export default class calculateTax extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';

    handleCalculateTaxClick() {
        this.loaded = false;
        this.callcalculateTax();
    }

    callcalculateTax() {
        try {
            console.log(this.recordId);
            getQuoteTaxFromButton({
                    quoteId: this.recordId
                }).then(data => {
                        try {
                            console.log(this.recordId);
                            updateAlternateTax({
                                    alternatesToUpdate: data, 
                                    quoteId: this.recordId
                                }).then(data => {

                                    this.Response = data;
                                    console.log(data);
                                    this.loaded = true;
                                })
                                .catch(error => {
                                    // TODO: handle error
                                    var errorJson = JSON.stringify(error);
                                    console.log("Error calculating tax: " + errorJson);
                                    this.Response = errorJson;
                                    this.loaded = true;
                                });
                
                        } catch (error) {
                            var errorJson = JSON.stringify(error);
                            console.log("Error calculating tax: " + errorJson);
                            this.Response = errorJson;
                            this.loaded = true;
                        }                                  
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error calculating tax: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error calculating tax: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}