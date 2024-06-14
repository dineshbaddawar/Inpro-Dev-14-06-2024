import {
    LightningElement,
    api
} from 'lwc';
import reloadConfiguration from '@salesforce/apex/ReloadExperlogixConfigHelper.reloadConfiguration';

export default class ReloadExperlogixConfig extends LightningElement {

    @api recordId;
    loaded = true;
    requestSent = false;
    Response = '';

    handleReloadConfigClick() {
        this.requestSent = true;
        this.callReloadConfiguration();
    }

    validateId(id) {

        if (id.length == 15 || id.length == 18) {
            return true;
        } else
            return false;
    }

    callReloadConfiguration() {

        try {

            this.loaded = false;
            console.log("quoteId: " + this.recordId);            
            reloadConfiguration({
                    recordId: this.recordId
                }).then(data => {
                    if (data) {

                        if(this.validateId(data))
                           this.Response = "Success, please open experlogix and validate the configuration has returned.";
                        else
                           this.Response = data;
                        this.loaded = true;
                    }
                })
                .catch(error => {
                    // TODO: handle error                
                    var errorJSON = JSON.stringify(error);
                    console.log("Error reloading config: " + errorJSON);
                    this.loaded = true;
                });

        } catch (error) {
            var erJSON = JSON.stringify(error);
            console.log("Error calling reload config: " + erJSON);
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}