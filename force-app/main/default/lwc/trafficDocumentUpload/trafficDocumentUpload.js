import {
    LightningElement,
    api,
    track
  } from 'lwc';
  
import getFileModelsPrefix from '@salesforce/apex/SharePointDocumentManagementHelper.getFileModelsPrefix'
import uploadFiles from '@salesforce/apex/SharePointDocumentManagementHelper.uploadFiles'
import deleteFile from '@salesforce/apex/SharePointDocumentManagementHelper.deleteFile'
import downloadFile from '@salesforce/apex/SharePointDocumentManagementHelper.downloadFile'
import getAccountContacts from '@salesforce/apex/TrafficDocumentHelper.getAccountContacts'
import sendContactEmail from '@salesforce/apex/TrafficDocumentHelper.sendContactEmail'
import createTrafficDocument from '@salesforce/apex/TrafficDocumentHelper.createTrafficDocument'
import deleteTrafficDocument from '@salesforce/apex/TrafficDocumentHelper.deleteTrafficDocument'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class TrafficDocumentUpload extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track loaded = false;
    @track modalLoaded = false;
    @track uploadIsActive = false;
    @track uploadNextIsActive = false;
    @track hasCommercialInvoiceFile = false;
    @track hasProductFile = false;
    @track hasCertificateFile = false;
    @track hasTransportFile = false;
    @track uploadedFileIds = [];
    @track fileListEmpty = true;
    @track fileList = [];
    @track deleteText = "";
    @track deleteIsActive = false;
    @track deleteSingleIsActive = false;
    @track hasMisc = false;
    @track miscNumber = 0;

    @track contactList = [];
    @track contactSelectionText = 'Please choose contact(s) to send email to.';

    get acceptedFormats() {
      return ['.pdf'];
    }

    connectedCallback() {
      // initialize component
      this.loadTrafficCheck();
      this.loadTable();
    };

    loadTable(){
      this.loaded = false;
      this.fileList = [];
      getFileModelsPrefix({
        Environment: window.location.host,
        EntityType: this.objectApiName,
        SalesForceId: this.recordId,
        Prefix: "External"
      }).then(data => {
        var response = JSON.parse(data);
        console.log(response);

        if (response.Status === true) {
          var files = response.SPOFileList;

          //Push to table with only relevant fields

          if (files.SPOFile !== null)
          {
            this.fileListEmpty = true;
            //Update table
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
              this.fileListEmpty = false;
            });
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
        this.loaded = true;
      });
    };
    
    handleAllContactChecked(event){
      this.contactList.forEach(function(contact){
        contact.Selected = event.target.checked;
      });
      this.allContactsSelected = event.target.checked;

      this.updateContactText();
    };

    handleContactChecked(event){
      var fileId = event.target.accessKey;
        //console.log(fileId);
        let selectedFile = this.contactList.filter(function (file) {
            return file.Id === fileId;
        })[0];

        selectedFile.Selected = event.target.checked;
        if (!selectedFile.Selected) 
        {
          this.allContactsSelected = false;
        }

        this.updateContactText();
    };

    updateContactText(){
      var selectedCount = this.contactList.filter(function (contact){
        return contact.Selected === true; 
      }).length;

      if (selectedCount > 0 )
      {
        this.contactSelectionText = selectedCount + " contact" + (selectedCount > 1 ? "s are " : " is ") + "selected.";
      }
      else{
        this.contactSelectionText = 'Please choose contact(s) to send email to.';
      }
    };

    loadAccountContacts(){
      this.modalLoaded = false;
      this.contactList = [];
      getAccountContacts({
        OrderId: this.recordId
      }).then(data => {
        var response = JSON.parse(data);
        console.log("Contacts:");
        console.log(response);
        response.forEach(contact => {
          this.contactList.push({
            Id: contact.Id,
            FirstName: contact.FirstName,
            LastName: contact.LastName,
            Title: contact.Title,
            Email: contact.Email,
            Selected: false
          });
        })
        this.modalLoaded = true;
      });
    };

    loadTrafficCheck(){
      this.modalLoaded = false;
      //Get documents from service
      getFileModelsPrefix({
        Environment: window.location.host,
        EntityType: this.objectApiName,
        SalesForceId: this.recordId,
        Prefix: "External"
      }).then(data => {
        var response = JSON.parse(data);

        if (response.Status === true) {
          var files = response.SPOFileList;

          if (files.SPOFile !== null)
          {
            //Reset values
            this.hasCommercialInvoiceFile = false; this.hasProductFile = false;
            this.hasCertificateFile = false; this.hasTransportFile = false;
            this.hasMisc = false; 
            this.miscText = "";
            this.miscNumber = 0;
            //Update upload info
            files.SPOFile.forEach(file => {
              if (file.Name.indexOf("Commercial Invoice") !== -1)
              {
                this.hasCommercialInvoiceFile = true;
              }
              else if (file.Name.indexOf("Where to find your Product") !== -1)
              {
                this.hasProductFile = true;
              }
              else if (file.Name.indexOf("Certificate of Origin") !== -1)
              {
                this.hasCertificateFile = true;
              }
              else if (file.Name.indexOf("Transport Document") !== -1)
              {
                this.hasTransportFile = true;
              }
              else
              {
                this.miscNumber++;
                this.hasMisc = true;
                this.miscText = "No. of Misc Files: " + this.miscNumber;
              }
            });
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
        
        this.modalLoaded = true; //Show modal once files have been checked
      });
    };
    
    handleUploadCommercialInvoice(event)
    {
      console.log("upload commercial invoice");
      this.handleUploadFinished(event, "Commercial Invoice.pdf", 1);
    };

    handleUploadProduct(event)
    {
      this.handleUploadFinished(event, "Where to find your Product.pdf", 2);
    };

    handleUploadCertificateOfOrigin(event)
    {
      this.handleUploadFinished(event, "Certificate of Origin.pdf", 3);
    };

    handleUploadTransportDocument(event)
    {
      this.handleUploadFinished(event, "Transport Document.pdf", 4);
    };

    handleUploadMisc(event)
    {
      console.log(event.detail.files);
      
      this.handleUploadFinished(event, event.detail.files[0].name, 5);
    };

    handleUploadFinished(event, fileName, variable)
    {
      this.modalLoaded = false;
      this.uploadedFileIds = [];
      const uploadedFiles = event.detail.files;
      console.log("No. of files uploaded : " + uploadedFiles.length);
      console.log(uploadedFiles);
      uploadedFiles.forEach(file => {
        this.uploadedFileIds.push({ 
          Id: file.documentId,
          Name: fileName
        });
        console.log(file.fileName);
      });

      console.log("Upload file...");

      uploadFiles({ 
        Environment: window.location.host,
        EntityType: this.objectApiName,
        SalesForceId: "External" + this.recordId, 
        FileIds: JSON.stringify(this.uploadedFileIds)
      }).then(data => {
        var results = JSON.parse(data);

        if (results.Status === true)
        {
          var type = "";
          this.toastSuccess("File was uploaded.");
          if (variable == 1){
            this.hasCommercialInvoiceFile = true;
            type = "Commercial Invoice";
          } 
          else if (variable == 2){
            this.hasProductFile = true;
            type = "WTFYP";
          } 
          else if (variable == 3){
            this.hasCertificateFile = true;
            type = "Certificate of Origin";
          } 
          else if (variable == 4){
            this.hasTransportFile = true;
            type = "Transport Document";
          } 
          else if (variable == 5) {
            this.miscNumber++; 
            this.hasMisc = true; 
            type = "Miscellaneous";
            this.miscText = "No. of Misc Files: " + this.miscNumber;
          }

          createTrafficDocument({
            OrderId: this.recordId,
            Type: type,
            Name: fileName
          }).then(data =>{
            if (data === 'true')
            {
              console.log("successfully created traffic document.");
            }
            else console.log(data);
          });
        }
        else{
          this.toastError(results.Message);
        }
        this.uploadedFileIds = [];
        this.modalLoaded = true;
        this.loadTable();
      });
    };
    
    handleUploadStart(event){
      this.uploadIsActive = true;
    };

    handleUploadCancel(event){
      this.uploadIsActive = false;
    };

    handleUploadNext(event){
      this.uploadIsActive = false;
      this.uploadNextIsActive = true;
      this.loadAccountContacts();
    };

    handleUploadPrevious(event){
      this.uploadIsActive = true;
      this.uploadNextIsActive = false;
    };

    handleUploadFinish(event){
      var selectedContacts = this.contactList.filter(function (contact){
        return contact.Selected === true;
      });
      if (selectedContacts.length === 0)
      {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Business Error!',
          message: 'You need to select at least one contact before emailing.',
          variant: 'error'
        }));
      }
      else{
        var emailStr = [];
        selectedContacts.forEach(x => {
          emailStr.push(x.Email);
        });
        console.log(emailStr);
        sendContactEmail({
          OrderId: this.recordId,
          EmailTo: emailStr
        }).then(data =>{
          console.log(data);
          if (data.indexOf('success') !== -1)
          {
            console.log(data);
            this.dispatchEvent(new ShowToastEvent({
              title: 'Success!',
              message:  data,
              variant: 'success'
            }));
          }
          else{
            console.log(data);
            this.dispatchEvent(new ShowToastEvent({
              title: 'Error!',
              message: data,
              variant: 'error'
            }));
          }
        });
      }
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

    handleDownload(event){
      var fileId = event.target.accessKey;

      let selectedFile = this.fileList.filter(function (file) {
          return file.Id === fileId;
      })[0];

      this.loaded = false;

      downloadFile({
        Environment: window.location.host,
        EntityType: this.objectApiName,
        EntityId: this.recordId,
        FileName: selectedFile.Name,
        RelativeUrl: selectedFile.ServerURL
      }).then(data => {
        var results = JSON.parse(data);
        console.log(results);

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
        this.loaded = true;
      });
    };

    handleDeleteSingle(event){
      var fileId = event.target.accessKey;
      
      let selectedFile = this.fileList.filter(function (file) {
        return file.Id === fileId;
      })[0];

      this.deleteIsActive = true;
      this.deleteSingleIsActive = true;
      console.log(event);
      console.log(fileId);
      console.log(selectedFile);
      this.deleteText = "Are you sure you want to delete '" + selectedFile.Name + "' ?";
      this.selectedFile = selectedFile;
    };

    handleDeleteCancel(){
      this.deleteIsActive = false;
      this.deleteSingleIsActive = false;
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
            EntityType: this.objectApiName,
            EntityId: this.recordId,
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
              console.log(this.selectedFile);
              deleteTrafficDocument({
                OrderId: this.recordId,
                Name: this.selectedFile.Name,
                Type: this.selectedFile.Type
              }).then(data =>{
                if (data === 'true')
                {
                  this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'File was deleted.',
                    variant: 'success'
                  }));
                }
                else{
                  this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: 'File was deleted, but the Traffic Document record was not.',
                    variant: 'warning'
                  }));
                }
                //Update file list length flag
                if (this.fileList.length == 0) this.fileListEmpty = true;
                else this.fileListEmpty = false;
                this.loaded = true;
              })
              
            }
            this.loadTrafficCheck();
          });
        }
        else{
          newFileList.push(file);
        }
      });

      this.fileList = newFileList;
    };

    toastSuccess(message)
    {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Success!',
        message: message,
        variant: 'success'
      }));
    };

    toastError(message){
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error!',
        message: message,
        variant: 'warning'
      }));
    };

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
    };
}