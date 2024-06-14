import {
    LightningElement,
    api,
    track
} from 'lwc';
  
import getLockedStatus from '@salesforce/apex/CustomPartNumberConfigHelper.getLockedStatus'
import getDivision from '@salesforce/apex/CustomPartNumberConfigHelper.getDivision'
import getCustomPartNumbers from '@salesforce/apex/CustomPartNumberConfigHelper.getCustomPartNumbers'
import updateCustomPartNumbers from '@salesforce/apex/CustomPartNumberConfigHelper.updateCustomPartNumbers'
import getExistingImage from '@salesforce/apex/UploadCustomImageHelper.getExistingImage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


export default class CustomPartNumberConfig extends LightningElement {
    @track productList = [];
    @track loaded = false;
    @track isLocked = false;
    @api recordId;
    
    @track isSignScape = false;
    
    connectedCallback(){
        console.log(this.recordId);
        getLockedStatus({TaskId: this.recordId}).then(status =>{
            console.log(status);
            if (status == 'Locked')
            {
                this.isLocked = true;
            }
        });

        getDivision({TaskId: this.recordId}).then(data =>{
            console.log(data);
            if (data == 'SignScape')
            {
                this.isSignScape = true;
            }
        });

        getCustomPartNumbers({TaskId: this.recordId}).then(data =>{
            console.log(data);
            var response = JSON.parse(data);
            this.productList = response;
            this.loaded = true;
        });
    }

    handleCustomInput(event)
    {
        var productId = event.target.accessKey;

        let product = this.productList.filter(function (product) {
            return product.Id === productId;
        })[0];

        product.Custom_Part_Number__c = event.target.value;
    }

    handleSelect(event){
        var productId = event.target.accessKey;
        this.productList.forEach(function (product){
            product.isLoaded = false;
        });

        let product = this.productList.filter(function (product) {
            return product.Id === productId;
        })[0];

        product.isLoaded = true;

        //Only call once
        if (product.imageLoaded == false || product.imageLoaded == undefined || product.imageLoaded == null)
        {
            getExistingImage({
                quoteDetailId: productId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
    
                        if (data != 'No Image Found') {
                            product.imageData = 'data:image/png;base64,' + data;
                            product.imageLoaded = true;
                        }
                        else{
                            product.imageData = '';
                            product.imageLoaded = false;
                        }
                    } catch (error) {
                        var myJSON = JSON.stringify(error);
                        console.log(myJSON);
                        console.log("Error finding image: " + myJSON);
                        this.loaded = true;
                        this.errorMessage = "Error finding image: " + myJSON;
                        this.showError = true;
                    }
    
                    this.loaded = true;
    
                } else if (error) {
                    this.error = error;
                    console.log(error);
                    this.loaded = true;
                    this.errorMessage = "Error finding image: " + error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error finding image: " + errorJson);
                this.loaded = true;
                this.errorMessage = "Error finding image: " + errorJson;
                this.showError = true;
            });
        }
    }

    handleSave()
    {
        this.loaded = false;
        console.log(this.productList);
        updateCustomPartNumbers({QuoteProducts: JSON.stringify(this.productList)}).then(data =>{
            if (data == 'success')
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Quote products were successfully updated.',
                    variant: 'success'
                  }));
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data,
                    variant: 'error'
                  }));
            }
            this.loaded = true;
        });
    }
    
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}