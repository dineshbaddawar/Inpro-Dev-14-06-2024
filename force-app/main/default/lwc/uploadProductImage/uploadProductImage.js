import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import getProductCode from '@salesforce/apex/UploadProductImageHelper.getProductCode';
import getProductImageId from '@salesforce/apex/UploadProductImageHelper.getProductImageId';
import getProductImage from '@salesforce/apex/UploadProductImageHelper.getProductImage';
import getNewProductImage from '@salesforce/apex/UploadProductImageHelper.getNewProductImage';
import saveProductImage from '@salesforce/apex/UploadProductImageHelper.saveProductImage';
import deleteImage from '@salesforce/apex/UploadProductImageHelper.deleteImage';

export default class UploadProductImage extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track imageLoaded = false;
    @track imageDOM;
    @track imageData = '';
    @track largeImageSize = 0;
    @track contentVersionId = '';
    @track productCode = '';

    get acceptedFormats() {
        return ['.jpg', '.png'];
    }

    handleClose()
    {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleFilesChange(event){
        this.loaded = false;
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        getNewProductImage({contentVersionId: uploadedFiles[0].contentVersionId}).then(data =>{
            console.log(data);
            this.contentVersionId = uploadedFiles[0].contentVersionId;
            this.imageData = 'data:image/jpeg;base64,' + data;
            this.loaded = true;
        });
    }

    connectedCallback(){
        getProductCode({productId: this.recordId}).then(pc => {
            this.productCode = pc;
            console.log(this.recordId);
            getProductImageId({productId: this.recordId}).then(cvId =>{
                this.contentVersionId = cvId;
                console.log(cvId);
                getProductImage({contentVersionId: this.contentVersionId}).then(data => {
                    this.imageData = 'data:image/jpeg;base64,' + data;
                    this.loaded = true;
                });
            });
        });
    }

    handleSave(){
        this.handleCompress();
        this.loaded = false;
        const params = {contentVersionId: this.contentVersionId, productCode: this.productCode, imageData: this.imageData.substring(this.imageData.indexOf(',')+1)};
        console.log(params);
        saveProductImage(params).then(data => {
            if (data.indexOf('Error') != -1)
            {
                console.log(data);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data,
                    variant: 'warning'
                }));
            }
            else
            {
                this.contentVersionId = data;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Image uploaded. Product record will update within the minute.',
                    variant: 'success'
                }));
            }
            this.loaded = true;
        });
    }

    handleDelete(){
        const params = {contentVersionId: this.contentVersionId, productId: this.recordId }
        console.log(params);
        deleteImage(params).then(data =>{
            console.log(data);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Image has been deleted. Product record will update within the minute.',
                variant: 'success'
            }));
            this.imageData = '';
        })
    }
    
    handleBrowse(){
        console.log('browse 2');
        var test = this.getElementsByClassName('fileupload')[0];
        console.log(test);
        test.click();
    }

    handleCompress(){
        try {
            var image = new Image();
            image.src = this.imageData;

            var canvas = document.createElement("canvas");

            canvas.width = 250;
            canvas.height = 250;
            var ctx = canvas.getContext("2d");

            ctx.drawImage(image, 0, 0, 250, 250);

            this.imageData = ctx.canvas.toDataURL();
        } catch (er) {
            console.log(er);
        }
    }

    handleRotateRight(){
        try {
            var image = new Image();
            image.src = this.imageData;

            var canvas = document.createElement("canvas");

            canvas.width = 250;
            canvas.height = 250;
            var ctx = canvas.getContext("2d");

            ctx.rotate(90 * Math.PI / 180);
            ctx.translate(0, -canvas.width);
            ctx.drawImage(image, 0, 0, 250, 250);

            this.imageData = ctx.canvas.toDataURL();
            
        } catch (er) {
            console.log(er);
        }
    }

    handleRotateLeft(){
        try {
            //c/accountNewOpportunityvar canvas = this.getElementsByClassName("image-preview")[0];
            var image = new Image();
            image.src = this.imageData;

            var canvas = document.createElement("canvas");

            canvas.width = 250;
            canvas.height = 250;
            var ctx = canvas.getContext("2d");

            ctx.rotate(90 * Math.PI / 180);
            ctx.translate(0, -canvas.width);
            ctx.drawImage(image, 0, 0, 250, 250);
            ctx.rotate(90 * Math.PI / 180);
            ctx.translate(0, -canvas.width);
            ctx.drawImage(image, 0, 0, 250, 250);
            ctx.rotate(90 * Math.PI / 180);
            ctx.translate(0, -canvas.width);
            ctx.drawImage(image, 0, 0, 250, 250);

            console.log(ctx);
            this.imageData = ctx.canvas.toDataURL();
        } catch (er) {
            console.log(er);
        }
    }
}