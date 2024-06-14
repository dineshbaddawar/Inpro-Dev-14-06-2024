import {
  LightningElement,
  api,
  track,
  wire
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getFileModels from '@salesforce/apex/SharePointDocumentManagementHelper.getFileModels'
import getRelatedFileModels from '@salesforce/apex/SharePointDocumentManagementHelper.getRelatedFileModels'
import uploadFiles from '@salesforce/apex/SharePointDocumentManagementHelper.uploadFiles'
import deleteFile from '@salesforce/apex/SharePointDocumentManagementHelper.deleteFile'
import downloadFile from '@salesforce/apex/SharePointDocumentManagementHelper.downloadFile'

import { subscribe, MessageContext } from 'lightning/messageService';
import SHAREPOINT_CHANNEL from '@salesforce/messageChannel/SharePointSubType__c'

export default class SharePointFileManagerChild extends LightningElement {
    @api recordId;

    @track fileList = [];
    @track fileListEmpty = true;
    @track loaded = false;
    @track uploadedFileIds = [];
    @track attachmentLink = "";
    @track attachmentName = "";
    @track selectionIsActive = false;
    @track deleteIsActive = false;
    @track selectedFileId = '';
    @track deleteSingleIsActive = false;
    @track deleteManyIsActive = false;
    @track deleteText = '';
    @track currentSort = { Column: "", Direction: "asc"};
    @track lastTarget = null;
    @track actionsEnabled = true;
    @track friendlyObjectApiName = 'Loading...';
    @wire(MessageContext)
    messageContext;

    @track subObjectType = '';
    @track subRecordId = '';

    connectedCallback() {
      this.subscribeToMessageChannel();
    };

    loadFriendlyName()
    {
      switch(this.subObjectType)
      {
        case 'Construction_Project__c':
          this.friendlyObjectApiName = 'Construction Project';
          break;
        case 'Contract__c':
          this.friendlyObjectApiName = 'Contract Version';
          break;
        case 'Critical_Note__c':
          this.friendlyObjectApiName = 'Critical Note';
          break;
        case 'Finance__c':
          this.friendlyObjectApiName = 'Finance';
          break;
        case 'Illustrator_Design_Request__c':
          this.friendlyObjectApiName = 'IDR';
          break;
        case 'Inpro_Contract__c':
          this.friendlyObjectApiName = 'Contract';
          break;
        case 'Order_Request__c':
          this.friendlyObjectApiName = 'Order Request';
          break;
        case 'Tax_Exempt_Certificate__c':
          this.friendlyObjectApiName = 'Tax Exempt Certificate';
          break;
        default:
          this.friendlyObjectApiName = this.subObjectType;
          break;
      }
      this.friendlyObjectApiName += ' Attachments';

    }
    
    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        SHAREPOINT_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

    handleMessage(message) {
      console.log('Handling message: ' + message.objectType + ', ' + message.recordId);
      this.subObjectType = message.objectType;
      this.subRecordId = message.recordId;
      this.loadFriendlyName();
      this.loadFiles();
    }

    loadFiles(){
      //Get documents from service
      if (this.recordId == this.subRecordId)
      {
        this.actionsEnabled = false;
        
        getRelatedFileModels({
          Environment: window.location.host,
          EntityType: this.subObjectType,
          SalesForceId: this.subRecordId
        }).then(data => {
          this.buildResults(data);
        })
      }
      else{
        getFileModels({
          Environment: window.location.host,
          EntityType: this.subObjectType,
          SalesForceId: this.subRecordId
        }).then(data => {
          this.buildResults(data);
        });
      }
    };

    buildResults(data){
      var response = JSON.parse(data);
        console.log(response);

        if (response.Status === true) {
          var files = response.SPOFileList;

          //Push to table with only relevant fields

          if (files.SPOFile !== null)
          {
            files.SPOFile.forEach(file => {
              this.fileList.push({
                Id: file.Id,
                Type: file.DocumentType,
                DisplayType: this.mapFileDisplayType(file.DocumentType),
                Location: file.Location,
                CreatedBy: file.CreatedBy,
                CreatedOn: file.CreatedOn,
                ModifiedBy: file.ModifiedBy,
                ModifiedOn: file.ModifiedOn,
                Name: file.Name,
                ServerURL: file.ServerURL,
                Selected: false,
                IsInternal: file.Location === "I" ? true : false
              });
              //console.log(file);
            });

            let myNode = this.template.querySelector('[data-id="Name"]');
            console.log(this.template.querySelector('[data-id="Name"]'));
            myNode.click();
          }
        }
        else{
          console.log(response.Message);
          this.dispatchEvent(new ShowToastEvent({
            title: 'Server Error!',
            message: response.Message,
            variant: 'error'
          }));
        }

        //Update file list length flag
        if (this.fileList.length == 0) this.fileListEmpty = true;
        else this.fileListEmpty = false;
        this.loaded = true; //Show table once files are loaded
    }

    handleSort(event){
      let column = event.target.dataset.id;
      if (this.currentSort.Column == column && this.currentSort.Direction == "asc")
      { //descending sort
        console.log(event.target.label);
        if (event.target.label = 'Updated On')
        {
          this.fileList = this.fileList.sort((x,y) => {
            var aa = new Date(x[column]),
                bb = new Date(y[column]);
            return aa < bb ? -1 : (aa > bb ? 1 : 0);
          });
        }
        else
        {
          this.fileList = this.fileList.sort((x,y) => {
            return x[column] > y[column] ? -1 : x[column] < y[column] ? 1 : 0
          });
        }
        
        this.currentSort.Column = column;
        this.currentSort.Direction = "desc";
        event.target.iconName = "utility:chevrondown";
        //Remove chevron from last column if column changed
        if (this.lastTarget != null && this.lastTarget.dataset.id != column) this.lastTarget.iconName = "";
        this.lastTarget = event.target;
      }
      else
      { //ascending sort
        if (event.target.label = 'Updated On')
        {
          this.fileList = this.fileList.sort((x,y) => {
            var aa = new Date(x[column]),
                bb = new Date(y[column]);
            return aa > bb ? -1 : (aa < bb ? 1 : 0);
          });
        }
        else
        {
          this.fileList = this.fileList.sort((x,y) => {
            return x[column] > y[column] ? 1 : x[column] < y[column] ? -1 : 0
          });
        }
        
        this.currentSort.Column = column;
        this.currentSort.Direction = "asc";
        event.target.iconName = "utility:chevronup";
        //Remove chevron from last column if column changed
        if (this.lastTarget != null && this.lastTarget.dataset.id != column) this.lastTarget.iconName = "";
        this.lastTarget = event.target;
      }
      
    }

    mapFileDisplayType(type)
    {
      //console.log(type);
      var text = "doctype:";
      if (type == undefined)
      {
        text += "unknown";
      }
      else if (type.indexOf("application/zip") !== -1 || 
               type.indexOf("application/x-zip-compressed") !== -1 || 
               type.indexOf("application/x-7z-compressed") !== -1 )
      {
        text += "zip";
      }
      else if (type.indexOf("text/plain") !== -1)
      {
        text += "txt";
      }
      else if (type.indexOf("application/vnd.visio") !== -1)
      {
        text += "visio";
      }
      else if (type.indexOf("text/xml") !== -1)
      {
        text += "xml";
      }
      else if (type.indexOf("image") !== -1)
      {
        text += "image";
      }
      else if (type.indexOf("word") !== -1)
      {
        text += "word";
      }
      else if (type.indexOf("powerpoint") !== -1 ||
      type.indexOf("presentation") !== -1)
      {
        text += "ppt";
      }
      else if (type.indexOf("excel") !== -1)
      {
        text += "excel";
      }
      else if (type.indexOf("pdf") !== -1)
      {
        text += "pdf";
      }
      else if (type.indexOf("text") !== -1)
      {
        text += "gdoc";
      }
      else if (type.indexOf("audio") !== -1)
      {
        text += "audio";
      }
      else if (type.indexOf("video") !== -1)
      {
        text += "video";
      }
      else{
        text += "unknown";
      }

      return text;
    }

    handleOptionChecked(event)
    {
        var fileId = event.target.accessKey;
        //console.log(fileId);
        let selectedFile = this.fileList.filter(function (file) {
            return file.Id === fileId;
        })[0];

        selectedFile.Selected = event.target.checked;

        //console.log(this.fileList.filter(function (file){ return file.Selected == true; }));
        //console.log(this.fileList.filter(function (file){ return file.Selected == true; }).length);

        if (this.fileList.filter(function (file){ return file.Selected == true; }).length > 0)
        {
          this.selectionIsActive = true;
        }
        else{
          this.selectionIsActive = false;
        }
    };

    handleUploadFinished(event)
    {
      this.loaded = false;
      this.uploadedFileIds = [];
      const uploadedFiles = event.detail.files;
      //console.log("No. of files uploaded : " + uploadedFiles.length);

      uploadedFiles.forEach(file => {
        this.uploadedFileIds.push({ 
          Id: file.documentId,
          Name: file.name
        });
        console.log(file.documentId);
      });

      //console.log("Begin uploading files...");
      var helper = this; //allow promise to access class function

      uploadFiles({ 
        Environment: window.location.host,
        EntityType: this.subObjectType,
        SalesForceId: this.subRecordId, 
        FileIds: JSON.stringify(this.uploadedFileIds)
      }).then(data => {
        var results = JSON.parse(data);
        //console.log(results);

        if (results.Status === true)
        {
          this.dispatchEvent(new ShowToastEvent({
            title: 'Success!',
            message: uploadedFiles.length > 1 ? 'Files were uploaded' : 'File was uploaded.',
            variant: 'success'
          }));

          this.fileList = [];
          this.loadFiles();
        }
        else{
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!',
            message: results.Message,
            variant: 'warning'
          }));
          this.loaded = true;
        }
      });
    };
    
    handleDeleteSingle(event){
      var fileId = event.target.accessKey;
      
      let selectedFile = this.fileList.filter(function (file) {
        return file.Id === fileId;
      })[0];

      this.deleteIsActive = true;
      this.deleteSingleIsActive = true;
      this.deleteManyIsActive = false;
      console.log(event);
      console.log(fileId);
      console.log(selectedFile);
      this.deleteText = "Are you sure you want to delete '" + selectedFile.Name + "' ?";
      this.selectedFile = selectedFile;
    };

    handleDeleteMany(){
      console.log("handleDeleteMany");
      this.deleteIsActive = true;
      this.deleteSingleIsActive = false;
      this.deleteManyIsActive = true;
      this.deleteText = "Are you sure you want to delete the selected files?";
    };

    handleDeleteCancel(){
      this.deleteIsActive = false;
      this.deleteSingleIsActive = false;
      this.deleteManyIsActive = false;
    };

    handleDeleteFiles(){
      console.log("handleDeleteFiles");
      this.handleDeleteCancel(); //close out confirmation modal

      var newFileList = [];

      this.fileList.forEach(file =>{
        if (file.Selected)
        {
          this.loaded = false;
          deleteFile({
            Environment: window.location.host,
            EntityType: this.subObjectType,
            EntityId: this.subRecordId,
            FileName: file.Name,
            RelativeUrl: file.ServerURL
          }).then(data => {
            var results = JSON.parse(data);
            //console.log(results);

            //Only toast when file is not deleted
            if (results.Status === false)
            {
              this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: results.Message,
                variant: 'warning'
              }));
              this.loaded = true;
            }
            else{
              this.loaded = true;
            }
          });
        }
        else{
          newFileList.push(file);
        }
      });

      //Update file list and length flag
      this.fileList = newFileList;
      if (this.fileList.length == 0) this.fileListEmpty = true;
      else this.fileListEmpty = false;
      this.selectionIsActive = false;
    };

    
    handleDelete(){
      console.log("handleDelete " + this.selectedFile.Id);
      this.handleDeleteCancel(); //close out confirmation modal
      
      var newFileList = [];
      
      this.loaded = false;

      this.fileList.forEach(file =>{
        if (file.Id == this.selectedFile.Id)
        {
          console.log(file.Id);
          deleteFile({
            Environment: window.location.host,
            EntityType: this.subObjectType,
            EntityId: this.subRecordId,
            FileName: this.selectedFile.Name,
            RelativeUrl: this.selectedFile.ServerURL
          }).then(data => {
            var results = JSON.parse(data);
            //console.log(results);
            
            if (results.Status === false)
            {
              this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: results.Message,
                variant: 'warning'
              }));
              this.loaded = true;
            }
            else{
              this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'File was deleted.',
                variant: 'success'
              }));

              //Update file list length flag
              if (this.fileList.length == 0) this.fileListEmpty = true;
              else this.fileListEmpty = false;
              this.loaded = true;
            }
          });
        }
        else{
          newFileList.push(file);
        }
      });

      this.fileList = newFileList;
    };

    handleOpen = function(event){
      var fileId = event.target.accessKey;
      
      let selectedFile = this.fileList.filter(function (file) {
        return file.Id === fileId;
      })[0];

      if (selectedFile.ServerURL.indexOf("crmdocs") !== -1)
        window.open(selectedFile.ServerURL);
      else
        window.open("https://inprocorp.sharepoint.com" + selectedFile.ServerURL);
    };

    handleDownload = function(event){
      var fileId = event.target.accessKey;

      let selectedFile = this.fileList.filter(function (file) {
          return file.Id === fileId;
      })[0];

      this.loaded = false;

      downloadFile({
        Environment: window.location.host,
        EntityType: this.subObjectType,
        EntityId: this.subRecordId,
        FileName: selectedFile.Name,
        RelativeUrl: selectedFile.ServerURL
      }).then(data => {
        console.log(data);
        if (data == 'IO Exception: Exceeded max size limit of 6000000')
        {
          this.dispatchEvent(new ShowToastEvent({
            title: 'File Error',
            message: 'Files over 6MB cannot be directly downloaded. Please use the open action instead.',
            variant: 'warning'
          }));
        }
        else{
          var results = JSON.parse(data);
          //console.log(results);
  
          if (results != null)
          {
            //Build blob buffer
            var binaryString = window.atob(results.FileContents);
            var binaryLen = binaryString.length;
            var bytes = new Uint8Array(binaryLen);
            for (var i = 0; i < binaryLen; i++) {
              var ascii = binaryString.charCodeAt(i);
              bytes[i] = ascii;
            }
  
            //Create document download link and automatically click it
            var link = document.createElement('a');
            link.href = window.URL.createObjectURL(new Blob([bytes] , {type:"text/plain"}));
            var fileName = results.FileName;
            link.download = fileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
          }
        }
        
        this.loaded = true;
      });
    };
}