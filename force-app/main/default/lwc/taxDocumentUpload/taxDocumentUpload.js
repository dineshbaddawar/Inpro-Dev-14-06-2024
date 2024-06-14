import {
    LightningElement,
    api,
    track
  } from 'lwc';
  
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class TaxDocumentUpload extends LightningElement {
    @api recordId;
    @api objectApiName;

    get acceptedFormats() {
      return ['.pdf'];
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
}