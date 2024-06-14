import {
    LightningElement,
    api
} from 'lwc';
import AddAccountToNetSuite from '@salesforce/apex/accountToNSHelper.AddAccountToNetSuite';

export default class AccountToNS extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';

    handlePushAccountUserClick() {
        this.loaded = false;
        this.callAddAccountToNetSuite();
    }

    callAddAccountToNetSuite() {
        try {
            console.log(this.recordId);
            AddAccountToNetSuite({
                    accountId: this.recordId
                }).then(data => {
                    this.Response = data;
                    console.log(data);
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error pushing acount to NetSuite: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error pushing acount to NetSuite: " + errorJson);
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