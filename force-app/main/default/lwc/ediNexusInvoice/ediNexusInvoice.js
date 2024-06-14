import {
    LightningElement,
    api
} from 'lwc';
import resendNexusInvoice from '@salesforce/apex/EDIActionPanelHelper.resendNexusInvoice';

import userId from '@salesforce/user/Id';

export default class EdiNexusInvoice extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';

    handleSendInvoiceClick() {
        this.callSendInvoice();
    }

    callSendInvoice() {

        try {

            this.loaded = false;
            console.log("contactId: " + this.recordId);
            console.log("userId: " + userId);
            resendNexusInvoice({
                    recordId: this.recordId
                }).then(data => {
                    if (data) {

                        this.Response = data;
                        this.loaded = true;
                    }
                })
                .catch(error => {
                    // TODO: handle error                
                    var errorJSON = JSON.stringify(error);
                    console.log("Error resending invoice: " + errorJSON);
                    this.loaded = true;
                });

        } catch (error) {
            var erJSON = JSON.stringify(error);
            console.log("Error calling resend invoice: " + erJSON);
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}