import {
  LightningElement,
  api,
  track
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getSPOFileModels from '@salesforce/apex/SharePointDocumentManagementHelper.getSPOFileModels'
import getLegacyFileModels from '@salesforce/apex/SharePointDocumentManagementHelper.getLegacyFileModels'
import deleteFile from '@salesforce/apex/SharePointDocumentManagementHelper.deleteFile'
import downloadFile from '@salesforce/apex/SharePointDocumentManagementHelper.downloadFile'
import uploadFiles from '@salesforce/apex/SharePointDocumentManagementHelper.uploadFiles'
import getSubRecordId from '@salesforce/apex/SharePointDocumentManagementHelper.getSubRecordId'

export default class SharePointFileManager extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api spName;
  
  @track environment = window.location.host;
  @track data = [];
  @track legacyData = [];
  @track loadMessage = 'Loading...';
  @track loadMessage2 = 'Checking for Legacy Documents...';
  @track loaded = false;
  @track loaded2 = false;
  @track hasLegacyFiles = false;
  @track columns = [{
      label: 'Type',
      fieldName: 'DisplayType',
      type: 'icon',
      sortable: false,
      cellAttributes: { alignment: 'left' }
    },
    {
      label: 'Name',
      fieldName: 'ServerURL',
      type: 'url',
      sortable: true,
      cellAttributes: { alignment: 'left' },
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    },
    {
      label: 'Uploaded On',
      fieldName: 'UploadedOn',
      type: 'datetime',
      sortable: false,
      cellAttributes: { alignment: 'left' }
    },
    {
      label: 'Uploaded By',
      fieldName: 'UploadedBy',
      type: 'text',
      sortable: false,
      cellAttributes: { alignment: 'left' }
    },
    {
      label: '',
      fieldName: '',
      multiAction: 'Delete Selected',
      isMultiAction: true,
      variant: 'warning',
      type: 'action',
      sortable: false
    }
  ];
  
  @track title = '';
  @track legacyTitle = '';
  @track originalRecordId = '';
  @track isFirstLoad = true;

  @track currentStep = 1;
  @track currentWait = 1;
  @track stepMessage = 'Checking SP for Legacy Files.';

  updateStep() //simulate loading time
  {
    setTimeout(function(){
      this.currentWait++;
      if (this.currentStep < 100){
        this.currentStep++;
        this.updateStep();
      } 
      else if (!this.loaded2)
      {
        console.log('Server process is warming up...');
        this.stepMessage = 'Server process is warming up...'
        this.updateStep();
      }
    }.bind(this),20);
  }

  connectedCallback()
  {
    if (this.spName != undefined && this.spName != '')
    {
      getSubRecordId({EntityType: this.objectApiName, SalesForceId: this.recordId }).then(result => {
        this.recordId = result;
        this.objectApiName = this.spName;
        this.loadFiles();
        this.loadFriendlyName();
      });
    }
    else
    {
      this.loadFiles();
      this.loadFriendlyName();
    }
  }

  loadFiles(){
    getSPOFileModels({
      Environment: this.environment,
      EntityType: this.objectApiName,
      SalesForceId: this.recordId
    }).then(data => {
      this.buildResults(data).forEach(x => {
        this.data.push(x);
      });
      this.loaded = true;
    }).catch(error =>{
      console.log(error);
    });
    

    if (this.isFirstLoad)
    {
      this.updateStep();
      getLegacyFileModels({
        Environment: this.environment,
        EntityType: this.objectApiName,
        SalesForceId: this.recordId
      }).then(data => {
        this.currentStep = 100;
        this.buildResults(data).forEach(x => {
          this.legacyData.push(x);
        });
        if (this.legacyData.length > 0)
        {
          this.hasLegacyFiles = true;
        }
        this.loaded2 = true;
      }).catch(error => {
        this.loaded2 = true;
      });

      this.isFirstLoad = false;
      
    }
  }

  

  loadFriendlyName()
  {
    console.log(this.objectApiName + ', ' + this.spName);
    switch(this.objectApiName)
    {
      case 'Construction_Project__c':
        this.title = 'Construction Project';
        break;
      case 'Contract__c':
        this.title = 'Contract';
        break;
      case 'Contract_Version__c':
        this.title = 'Contract Version';
        this.actionsEnabled = false;
        break;
      case 'Critical_Note__c':
        this.title = 'Critical Note';
        break;
      case 'Finance__c':
        this.title = 'Finance';
        break;
      case 'Illustrator_Design_Request__c':
        this.title = 'IDR';
        break;
      case 'Order_Request__c':
        this.title = 'Order Request';
        break;
      case 'Tax_Exempt_Certificate__c':
        this.title = 'Tax Exempt Certificate';
        break;
      case 'Task':
        this.title = this.spName == 'Task' ? 'CRM 2011 Only Task' : 'Task';
        if (this.spName == 'Task') this.actionsEnabled = false;
        break;
      case 'Quote':
        if (this.spName == 'Opportunity') this.title = 'Opportunity';
        else this.title = 'Quote';
        break;
      default:
        this.title = this.objectApiName;
        break;
    }
    this.title += ' Attachments';
    this.legacyTitle = 'Legacy ' + this.title;
  }

  buildResults(data){
    var response = JSON.parse(data);
    let tempData = [];
    console.log(response);

    if (response.Status === true) {
      var files = response.SPOFileList;

      //Push to table with only relevant fields

      if (files.SPOFile !== null)
      {
        files.SPOFile.forEach(file => {
          console.log(this.recordId);
          file.RelativeURL = file.ServerURL;
          tempData.push({
            Id: file.Id,
            Type: file.DocumentType,
            DisplayType: this.mapFileDisplayType(file.DocumentType),
            Location: file.Location,
            UploadedOn: file.ModifiedOn,
            UploadedBy: file.ModifiedBy,
            Name: file.Name,
            RelativeURL: file.ServerURL,
            ServerURL: this.mapFileServerUrl(file.ServerURL),
            Selected: false,
            IsInternal: file.Location === "I" ? true : false,
            RecordId: this.recordId,
            ObjectApiName: this.objectApiName,
            Actions: [
              { 
                isButtonIcon: true,
                iconName: 'utility:download',
                style: 'margin-right:10px;background-color:rgb(1,118,211);padding-top:4px;padding-bottom:9px;border-radius:5px;',
                variant: 'border-inverse',
                onclick: (function(){
                  this.handleDownload(file);
                }).bind(this)
              },
              { 
                isButtonIcon: true,
                iconName: 'utility:open',
                style: 'margin-right:10px;background-color:rgb(' + 
                       (file.Location === "I" ?'255,183,93' : '255,255,255') + 
                       ');padding-top:4px;padding-bottom:9px;border-radius:5px;',
                variant: file.Location === "I" ? 'border-inverse' : 'border',
                onclick: (function(){
                  let url = this.mapFileServerUrl(file.ServerURL);
                  window.open(url, '_blank');
                }).bind(this)
              },
              { 
                isButtonIcon: true,
                iconName: 'utility:delete',
                style: 'background-color:rgb(194,57,52);padding-top:4px;padding-bottom:9px;border-radius:5px;',
                variant: 'border-inverse',
                onclick: (function(){
                  this.handleDeleteConfirm(file);
                }).bind(this)
              }
            ]
          });
        });
      }
    }

    return tempData;
  }

  handleDownload = function(file){
    const params = {
      Environment: this.environment,
      EntityType: this.objectApiName,
      EntityId: this.recordId,
      FileName: file.Name,
      RelativeUrl: file.ServerURL
    };

    console.log(params);

    downloadFile(params).then(data => {
      console.log(data);
      if (data.indexOf("IO Exception") != -1)
      {
        if (file.ServerURL.indexOf("crmdocs") !== -1)
          window.open(file.ServerURL);
        else
          window.open("https://inprocorp.sharepoint.com" + file.ServerURL);
      }
      else{
        try{
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
        } catch(error){
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!',
            message: 'An unexpected error occurred: ' + error,
            variant: 'error',
            mode: 'sticky'
          }));
        }
      }
      
      this.loaded = true;
    });
  }

  @track currentFile = null;
  @track currentFileName = null;
  @track isDeleteActive = false;
  @track isSelectActive = false;

  @track selectedFiles = [];
  handleSelectRow = (function(event){
    this.isSelectActive = true;
    console.log(event.target);
    console.log(this.isSelectActive);
    const value = event.target.value;
    const checked = event.target.checked;
    
    if (value == 'all')
    {
      this.data.forEach(x => { x.Selected = checked; });
    }
    else
    {
      let selected = this.data.filter(x => x.Id == value)[0];
      selected.Selected = checked;
    }

    this.selectedFiles = [];

    this.data.forEach(x => { 
      if (x.Selected) { 
        this.selectedFiles.push(x);
      }
    });
    this.isSelectActive = this.selectedFiles.length > 0;
  }).bind(this);

  handleDeleteClose = function(event){
    this.isDeleteActive = false;
    this.isDeleteMultiple = false;
    this.currentFileName = '';
    this.currentFile = null;
  }

  handleDeleteConfirm = function(file){
    this.currentFile = file;
    this.isDeleteActive = true;
    this.currentFileName = file.Name;
  }

  @track isDeleteMultiple = false;
  @track selectedData = [];
  handleDeleteMultiple = (function(records){
    this.selectedData = [];
    records.forEach(x => {
      let y = this.data.filter(z => z.Id == x.Id)[0];
      if (x.Selected)
      {
        this.selectedData.push(x);
      }
    });

    this.isDeleteMultiple = true;
    this.isDeleteActive = true;
    this.currentFileName = 'Multiple Files';
  }).bind(this);

  handleDeleteMultipleConfirm = function(){
    this.isDeleteMultiple = false;
    this.selectedData.forEach(x => {
      if (x.Selected == true)
      {
        this.handleDeleteApex(x);
      }
    });
  }

  @track apexCount = 0;
  handleDeleteApex = function(x)
  {
    if (this.apexCount == 7)
    {
      setTimeout(function(){
        this.handleDeleteApex(x);
      }.bind(this),500);
    }
    else
    {
      this.handleDelete(x);
    }
    
  }

  handleDelete = function(x){
    console.log('Multiple delete? ' + (x != undefined));
    const params = {
      Environment: this.environment,
      EntityType: this.objectApiName,
      EntityId: this.recordId,
      FileName: x.RelativeURL == undefined ? this.currentFile.Name : x.Name,
      RelativeUrl: x.RelativeURL == undefined ? this.currentFile.RelativeURL : x.RelativeURL
    };

    this.loaded = false;
    console.log(params);
    
    this.apexCount++;
    deleteFile(params).then(data => {
      var results = JSON.parse(data);
      this.apexCount--;
      
      if (results.Status === false)
      {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error!',
          message: results.Message,
          variant: 'warning'
        }));
        this.loaded = true;
        this.loadMessage = 'Loading...';
      }
      else{
        this.dispatchEvent(new ShowToastEvent({
          title: 'Success!',
          message: 'File was deleted.',
          variant: 'success'
        }));

        if (this.apexCount == 0)
        {
          this.data = [];
          this.loadFiles();
        }
      }
      this.currentFile = null;
      this.currentFileName = null;
      this.isDeleteActive = false;
    });
  }

  handleUploadFinished = (function(event){
    this.loaded = false;
    this.loadMessage = 'Uploading file...';
    this.uploadedFileIds = [];
    const uploadedFiles = event.detail.files;
    //console.log("No. of files uploaded : " + uploadedFiles.length);

    
    uploadedFiles.forEach(file => {
      this.data.forEach(existingFile =>{
        if (file.name == existingFile.Name)
        {
          console.log('Match');
          //Is this already a file that has been uploaded at least twice?
          file.name = this.sameFileNameCheck(existingFile.Name, file.Name);

          console.log(file.name);
        }
      });
      this.uploadedFileIds.push({ 
        Id: file.documentId,
        Name: file.name
      });
      console.log(file.documentId);
    });

    //console.log("Begin uploading files...");
    var helper = this; //allow promise to access class function

    uploadFiles({ 
      Environment: this.environment,
      EntityType: this.objectApiName,
      SalesForceId: this.recordId, 
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

        this.data = [];
        this.loadFiles();
      }
      else{
        this.dispatchEvent(new ShowToastEvent({
          title: 'Error!',
          message: results.Message,
          variant: 'warning'
        }));
        this.loadMessage = 'Loading...';
        this.loaded = true;
      }
    });
  }).bind(this);

  sameFileNameCheck(existingFileName,newFileName)
  {
    var firstCopy = true;
    if (existingFileName.indexOf('(') !== -1 && existingFileName.indexOf(')') !== -1 && 
              existingFileName.lastIndexOf(')') == (existingFileName.lastIndexOf('.')-1))
    {
      firstCopy = false;
      console.log('start');
      console.log(existingFileName.match(/\d+/g));
      
      var split = existingFileName.match(/\d+/g);
      if (split != null)
      {
        console.log('split length is ' + split.length);
        var num = parseInt(split[split.length-1]) + 1;
        console.log('new number is ' + num);
        newFileName= existingFileName.substring(0,existingFileName.lastIndexOf('(')-1) 
                  + ' (' + num + ')' + existingFileName.substring(existingFileName.lastIndexOf('.'));
        
        console.log('New name is ' + newFileName);

        //Make sure this is the latest number in series of same name files
        /*
          * For example, if new name is Text (1).doc and the file list already has this file name,
          * then run this logic again to get Text (2).doc. Then, if that file already exists too,
          * recursive calling of this method will get Text (n).doc where n is the last newest number
          * in the line of same name files.
          */
        this.data.forEach(existingFile =>{
          if (existingFile.Name == newFileName)
          {
            console.log('This new file name already exists!');
            return newFileName = this.sameFileNameCheck(existingFile.Name, newFileName);
          }
        });
      }
      else //File has text inbetween parens, just add (1) at end of file name
      {
        firstCopy = true;
      }
    }
    if (firstCopy)
    {
      newFileName = existingFileName.substring(0,existingFileName.lastIndexOf('.')) 
                + ' (1)' + existingFileName.substring(existingFileName.lastIndexOf('.'));
      console.log('New name is ' + newFileName);
      //Make sure this is the latest number in series of same name files
      this.data.forEach(existingFile =>{
        if (existingFile.Name == newFileName)
        {
          console.log('This new file name already exists!');
          return newFileName = this.sameFileNameCheck(existingFile.Name, newFileName);
        }
      });
    }
    return newFileName;
  }
  
  mapFileServerUrl(serverUrl)
  {
    if (serverUrl.indexOf("crmdocs") !== -1) return serverUrl.replaceAll('#','%23');
    else return "https://inprocorp.sharepoint.com" + serverUrl.replaceAll('#','%23');
  }

  mapFileDisplayType(type)
  {
    console.log(type);
    var text = "doctype:";
    if (type == undefined) text += "unknown";
    else if (type.indexOf("application/zip") !== -1) text += "zip";
    else if (type.indexOf("application/x-zip-compressed") !== -1 ) text += "zip";
    else if (type.indexOf("application/x-7z-compressed") !== -1 ) text += "zip";
    else if (type.indexOf("text/plain") !== -1) text += "txt";
    else if (type.indexOf("application/vnd.visio") !== -1) text += "visio";
    else if (type.indexOf("text/xml") !== -1) text += "xml";
    else if (type.indexOf("image") !== -1) text += "image";
    else if (type.indexOf("word") !== -1) text += "word";
    else if (type.indexOf("powerpoint") !== -1) text += "ppt";
    else if (type.indexOf("presentation") !== -1) text += "ppt";
    else if (type.indexOf("excel") !== -1) text += "excel";
    else if (type.indexOf("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") !== -1) text += "excel";
    else if (type.indexOf("pdf") !== -1) text += "pdf";
    else if (type.indexOf("text") !== -1) text += "gdoc";
    else if (type.indexOf("audio") !== -1) text += "audio";
    else if (type.indexOf("video") !== -1) text += "video";
    else text += "unknown";

    return text;
  }
  
}