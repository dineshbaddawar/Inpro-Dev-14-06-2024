import {
    LightningElement,
    api,
    track
} from 'lwc';

import SubmitRCARequest from '@salesforce/apex/RCAHelper.SubmitRCARequest';

export default class RcaSubmit extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';

    handleSubmitRCAClick() {
        this.loaded = false;
        this.callSubmitRCA();
    }

    callSubmitRCA() {
        try {
            console.log(this.recordId);
            SubmitRCARequest({
                    rcaId: this.recordId
                }).then(data => {
                    this.Response = data;
                    console.log(data);
                    if(!data.toLowerCase().includes("error"))
                        document.location = location.href;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error submitting RCA: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error submitting RCA: " + errorJson);
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