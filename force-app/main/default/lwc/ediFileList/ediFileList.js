import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRelatedFiles from '@salesforce/apex/EDIActionPanelHelper.getRelatedFiles';
export default class EdiFileList extends LightningElement {
    @api label;
    @api formats = '.txt,.json,.xml';
    @api recordId;
    @api adminUser = false;

    connectedCallback()
    {
        this.adminUser = true;
        // isUserAdmin().then(data => {
        //     this.adminUser = data;
        //     console.log(data);
        // }).catch(error => {
        //     console.log(error);
        // });
    }

    get acceptedFormats() {
        return this.formats.split(',');
    }

    @wire(getRelatedFiles, { recordId: '$recordId' })
    files;

    handleActionFinished(event) {
        //refresh the list of files
        refreshApex(this.files);
    }
}