import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRelatedFiles from '@salesforce/apex/TDMHelper.getRelatedFiles';
import isUserAdmin from '@salesforce/apex/TDMHelper.isUserAdmin';

export default class TDMFileList extends LightningElement{
    @api label;
    @api formats = '.png,.pdf,.txt,.xls,.xlsx,.doc,.docx,.jpg,.zip,.dwg,.rfa';
    @api recordId;
    @api adminUser = false;

    connectedCallback()
    {
        isUserAdmin().then(data => {
            this.adminUser = data;
            console.log(data);
        }).catch(error => {
            console.log(error);
        });
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