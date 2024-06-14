import {
    LightningElement,
    api
} from 'lwc';
import doRecordsExist from '@salesforce/apex/RelatedRecordNotificationHelper.doRecordsExist';

export default class RelatedRecordNotification extends LightningElement {
    @api ChildSchemaName;
    @api Message;
    @api recordId;
    showMessage = false;

    connectedCallback() {
        // initialize component   
        doRecordsExist({
                Id: this.recordId,
                ObjectName: this.ChildSchemaName                
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        this.showMessage = data;
                    } 
                    catch (error) {
                        var errorJSON = JSON.stringify(error);                        
                        console.log("Error Checking If Related Records Exist: " + errorJSON);
                    }
                }                
            })
            .catch(error => {                
                var errorJSON = JSON.stringify(error);
                console.log("Error Checking If Related Records Exist1: " + errorJSON);                
            });
    }

}