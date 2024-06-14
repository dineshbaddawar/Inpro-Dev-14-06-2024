import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import uploadCustomImage from '@salesforce/apex/UploadCustomImageHelper.uploadCustomImage';
import getQuoteInfo from '@salesforce/apex/UploadCustomImageHelper.getQuoteInfo';
import getQuoteDetailNotes from '@salesforce/apex/UploadCustomImageHelper.getQuoteDetailNotes';
import getExistingImage from '@salesforce/apex/UploadCustomImageHelper.getExistingImage';

export default class UploadCustomImage extends LightningElement {

    @api recordId;
    @track loaded = false;
    @track uploaded = false;
    @track fileUploaded = false;
    @track theFileId;
    @track FileName = '';
    @track showError = false;
    @track errorMessage = '';
    @track notes = '';
    @track QuoteId = '';
    @track QuoteDetailId = '';
    @track IDRId = '';
    @track imageData = '';
    @track imageLoaded = false;

    get acceptedFormats() {
        return ['.png'];
    }

    connectedCallback() {
        // initialize component
        this.loadQuote();
    };

    getNotes()
    {
        console.log('Get Notes...');
        getQuoteDetailNotes({
            quoteDetailId: this.QuoteDetailId
        }).then(data =>{
            console.log('Notes: ' + data);
            this.notes = data;
        });
    }
    
    loadQuote() {
        getQuoteInfo({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);

                        this.IDRId = data[0].IDR__c;
                        this.QuoteId = data[0].Quote__c;
                        this.QuoteDetailId = data[0].Quote_Line_Item__c;

                        console.log(this.IDRId);
                        console.log(this.QuoteId);
                        console.log(this.QuoteDetailId);

                        this.getNotes();
                        this.checkImageExists();

                    } catch (error) {

                        var myJSON = JSON.stringify(error);
                        console.log(myJSON);
                        console.log("Error loading quote: " + myJSON);
                        this.errorMessage = "Error loading quote: " + myJSON;
                        this.showError = true;
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);

                    this.errorMessage = "Error loading quote: " + error;
                    this.showError = true;
                }

            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error loading quote: " + errorJson);
                this.loaded = true;
                this.errorMessage = "Error loading quote: " + errorJson;
                this.showError = true;
            });
    }

    handleInput(event)
    {
        this.notes = event.target.value;
    }

    checkImageExists() {
        this.loaded = false;
        //String quoteDetailId, string illustratorDrawingRequestID
        getExistingImage({
                quoteDetailId: this.QuoteDetailId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);

                        if (data != 'No Image Found') {
                            this.imageData = 'data:image/png;base64,' + data;
                            this.imageLoaded = true;
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

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " + uploadedFiles.length);
        console.log(uploadedFiles[0].documentId + " " + uploadedFiles[0].name);
        this.theFileId = uploadedFiles[0].documentId;
        this.FileName = uploadedFiles[0].name;
        this.fileUploaded = true;
    }

    uploadImage(event) {
        this.loaded = false;
        if (this.fileId != '' && this.QuoteId != '' && this.QuoteDetailId != '' && this.recordId != '') {
            uploadCustomImage({
                    fileId: this.theFileId,
                    quoteId: this.QuoteId,
                    quoteDetailId: this.QuoteDetailId,
                    illustratorDrawingRequestID: this.recordId,
                    notes: this.notes
                }).then(data => {
                    if (data) {
                        try {
                            var myJSON = JSON.stringify(data);
                            console.log(myJSON);
                            this.loaded = true;
                            this.checkImageExists();
                        } catch (error) {

                            var myJSON = JSON.stringify(error);
                            console.log(myJSON);
                            console.log("Error uploading image1: " + myJSON);
                            this.loaded = true;
                            this.errorMessage = "Error uploading image2: " + myJSON;
                            this.showError = true;
                        }

                    } else if (error) {
                        this.error = error;
                        console.log(error);
                        this.loaded = true;
                        this.errorMessage = "Error uploading image3: " + error;
                        this.showError = true;
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error uploading image4: " + errorJson);
                    this.loaded = true;
                    this.errorMessage = "Error uploading image5: " + errorJson;
                    this.showError = true;
                });
        } else {
            console.log("missing information.");
        }

    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}