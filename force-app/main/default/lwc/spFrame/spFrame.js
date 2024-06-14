import {
    LightningElement,
    api,
    track,
    wire,
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getOnlineLibraryUrl from '@salesforce/apex/SharePointDocumentManagementHelper.getOnlineLibraryUrl'
import getSubRecordId from '@salesforce/apex/SharePointDocumentManagementHelper.getSubRecordId'

export default class SpFrame extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track loaded = false;
    @track projectId = '';
    @track link = '';
    @track projectNumberPresent = false;

    connectedCallback(){
        getSubRecordId({
            EntityType: this.objectApiName,
            SalesForceId: this.recordId
          }).then(data => {
            this.projectId = data;
            console.log(this.projectId);
            console.log(window.location.host);
            console.log(this.objectApiName == 'Construction_Project__c');
            if (this.projectId != '')
            {
                this.projectNumberPresent = true;
                getOnlineLibraryUrl({
                    EntityId: this.recordId,
                    ProjectId: this.projectId,
                    IsConstructionProject: this.objectApiName == 'Construction_Project__c'
                }).then(data2 =>{
                    this.link = data2;
                    this.loaded = true;
                }).catch(error =>{
                    console.log(error);
                });
            }
            else{
                this.loaded = true;
            }
          });
    }

    handleNavigate()
    {
        console.log(this.link);
        window.open(this.link);
    }
}