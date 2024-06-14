import {
    LightningElement,
    api,
    track
} from 'lwc';

import getPOHeaders from '@salesforce/apex/EDIPODetailsHelper.getPOHeaders';

export default class EDIPODetails extends LightningElement {
    @api recordId;
    loaded = false;
    @track POList = [];
    @track showError = false;
    @track errorMessage = false;

    connectedCallback() {
        // initialize component        
        this.loadPOLinks();
    }

    loadPOLinks() {

        getPOHeaders({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        console.log(data);
                        var obj = JSON.parse(data);
                        if (obj != null) {
                            obj.forEach(po => {
                                this.POList.push(po);
                            });
                        }
                        this.loaded = true;
                    } catch (error) {
                        console.log("Error Loading PO: " + error);
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                console.log("Error Loading PO: " + errorJSON);
            });
    }


}