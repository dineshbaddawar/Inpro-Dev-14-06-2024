import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import refreshQualifications from '@salesforce/apex/QualificationHelper.refreshQualifications';

export default class QualificationLoader extends LightningElement {

    @api recordId;

    connectedCallback(){
        this.populateRecordList();
    }

    populateRecordList()
    {        
        refreshQualifications({quoteId: this.recordId}).then(data =>{ console.log(data); });        
    }
}