import {
    LightningElement,
    api,
    track
} from 'lwc';

import removePublishSet from '@salesforce/apex/TDMHelper.removePublishSet';

export default class TdmRemovePublishSet extends LightningElement {

    @api recordId;
    @track loaded = false;
    errorMessage = '';
    showError = false;

    connectedCallback() {
        console.log('remove start');
        try {
            removePublishSet({
                recordId: this.recordId
            }).then(data => {
                
                console.log(data);
                console.log(data.includes('error'));
                if (data.includes('error')) 
                {
                    console.log('error');
                    this.loaded = true;
                    this.showError = true;
                    this.errorMessage = JSON.stringify(data);
                }
                else
                {                    
                    window.location.reload();
                }
            }).catch(error => {
                console.log(JSON.stringify(error));
            });
        } catch (error) {
            console.log(JSON.stringify(error));
        }
    }
}