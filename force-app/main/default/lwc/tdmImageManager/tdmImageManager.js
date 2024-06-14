import {
    LightningElement,
    api,
    track
} from 'lwc';

import updateDocumentImage from '@salesforce/apex/TDMHelper.updateDocumentImage';
import getDocumentImage from '@salesforce/apex/TDMHelper.getDocumentImage';

export default class TdmImageManager extends LightningElement {

    imageData = '';    
    @api recordId;
    @track loaded = false;

    connectedCallback()
    {
        getDocumentImage({
            documentId: this.recordId
        }).then(data => {
            this.loaded = true;            
            console.log(data);
            this.imageData = 'data:application/png;base64,' + data;    
            this.loaded = true;
        }).catch(error => {
            console.log(error);
        });        
    }

    openfileUpload(event) {
        try {

            console.log('file uploaded');
            const file = event.target.files[0]
            var reader = new FileReader()
            reader.readAsDataURL(file)
            //this.fileName = file.name;


            reader.onload = () => {
                try {
                    var base64 = reader.result.split(',')[1]
                    console.log(base64);

                    var doc = {
                        Id: this.recordId,
                        Image__c: base64,
                        Image_Name__c:file.name        
                    };

                    updateDocumentImage({
                        document: doc
                    }).then(data => {
                        window.location.reload();
                        console.log(data);
                    }).catch(error => {
                        console.log(error);
                    });

                    
                } catch (error) {
                    console.log(error);
                }
            }
        } catch (error) {
            console.log(error);
        }
    }

    
}