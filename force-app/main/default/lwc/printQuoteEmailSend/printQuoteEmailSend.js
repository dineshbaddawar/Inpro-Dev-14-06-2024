import { LightningElement, api } from 'lwc';
import getEmailTemplateBody from '@salesforce/apex/PrintQuoteEmailController.getEmailBody';
import getFilesList from '@salesforce/apex/PrintQuoteEmailController.getFilesList';
import getContactList from '@salesforce/apex/PrintQuoteEmailController.getContactList';
import sendEmail from '@salesforce/apex/PrintQuoteEmailController.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

export default class PrintQuoteEmailSend extends LightningElement {

    @api toEmail;
    @api ccEmail;
    @api bccEmail;
    @api subject = '';
    @api availableActions = [];

    @api bccSelectedContactsVal;
    @api ccSelectedContactsVal;
    @api toSelectedContactsVal;
    @api newSubjectVal;
    @api emailTemplateBodyVal;
    @api selectedFilesVal;
    @api recordId;


    toEmailContacts = [];
    ccEmailContacts = [];
    bccEmailContacts = [];

    showToEmail = false;
    showCCEmail = false;
    showBCCEmail = false

    selectedBCCContacts = [];
    selectedCCContacts = [];
    selectedToContacts = [];

    fromEmailVal = '';
    fromEmailList = [
        { label: 'Hunley Group <hunleygroup@test.com>', value: 'hunleygroup@test.com' },
        { label: 'Hunley Group1 <hunleygroup@test1.com>', value: 'hunleygroup@test1.com' }
    ];

    richTextVal = '';
    isInit = false;
    isShowSpinner = false;

    showModal = false;
    isTemplateSelect = false;
    selectedTemplate;

    isFileAttachment = false;
    fileList = [];
    _fileListTemp = [];
    _selectedFileIds = [];
    selectedFiles = [];

    panelRefresh = true;

    connectedCallback(){
        if(this.isInit){
            return;
        }
        this.isInit = true;
        let thisObj = this;
        this.loadEmailTemplate();
        setTimeout(function(){
            debugger;
            //const editor = thisObj.template.querySelector('lightning-input-rich-text');
            //editor.setRangeText('\n\n\n\n\n\n\n\n\n\n\n', 0, 0, "end");
        },1000);

        this.toEmail = this.toEmail + ',CurrentUser';
        if(this.toEmail != undefined && this.toEmail != ''){
            this.toEmail = this.toEmail.replace(/\s+/g, '');
            let toEmails = this.toEmail;        
            getContactList({ emailList: toEmails})
                .then(result => {
                    debugger;
                    console.log('Result..'+result);
                    let jsonRes = JSON.parse(result);
                    if(jsonRes.status){
                        let contactList = jsonRes.contactList;
                        contactList.push(jsonRes.userInfo);
                        this.toEmailContacts = contactList;
                    }
                    this.showToEmail = true;
                })
                .catch(result => {
                    console.log(result);
                });
        }else{
            this.showToEmail = true;
        }
        this.ccEmail = this.ccEmail + ', Opportunity Owner,'+this.recordId;
        if(this.ccEmail != undefined && this.ccEmail != ''){
            this.ccEmail = this.ccEmail.replace(/\s+/g, '');
            let ccEmails = this.ccEmail;        
            getContactList({ emailList: ccEmails})
                .then(result => {
                    debugger;
                    console.log('Result..'+result);
                    let jsonRes = JSON.parse(result);
                    if(jsonRes.status){
                        let contactList = [];
                        //contactList.push(jsonRes.TerritoryManager);
                        contactList.push(jsonRes.Opportunityowner);
                        //this.ccEmailContacts = jsonRes.contactList;
                        this.ccEmailContacts = contactList;
                    }
                    this.showCCEmail = true;
                })
                .catch(result => {
                    console.log(result);
                });
        }else{
            this.showCCEmail = true;
        }
        debugger;
        //this.bccEmail = 'scram2@test.com,brokertestemail@yopmail.com';
        if(this.bccEmail != undefined && this.bccEmail != ''){
            this.bccEmail = this.bccEmail.replace(/\s+/g, '');
        }
        this.bccEmail = this.bccEmail + ', Territory Manager,'+this.recordId;
        if(this.bccEmail != undefined && this.bccEmail != ''){
            let bccEmails = this.bccEmail;        
            getContactList({ emailList: bccEmails})
                .then(result => {
                    debugger;
                    console.log('Result..'+result);
                    let jsonRes = JSON.parse(result);
                    if(jsonRes.status){
                       // let contactList = jsonRes.contactList;
                        let contactList = [];
                        contactList.push(jsonRes.TerritoryManager);
                        //contactList.push(jsonRes.Opportunityowner);
                        this.bccEmailContacts = contactList;
                    }
                    this.showBCCEmail = true;
                })
                .catch(result => {
                    console.log(result);
                });
        }else{
            this.showBCCEmail = true;
        }
        this.setFlowAttributes();
    }

    handleFromEmailChange(event){

    }

    handleSelectedRecords(event){
        debugger;
        this.selectedToContacts = event.detail.selRecords;
        this.setFlowAttributes();
    }

    handleSelectedCCRecords(event){
        debugger;
        this.selectedCCContacts = event.detail.selRecords;
        this.setFlowAttributes();
    }

    handleSelectedBCCRecords(event){
        debugger;
        this.selectedBCCContacts = event.detail.selRecords;
        this.setFlowAttributes();
    }

    closeModal(){
        this.showModal = false;
    }

    handleTemplateSelectClick(){
        this.isTemplateSelect = true;
        this.isFileAttachment = false;
        this.showModal = true;
        this.isShowSpinner = false;
    }

    handleSelectedTemplateRecords(event){
        debugger;
        this.selectedTemplate = event.detail.selRecords;

        if(event.detail.selRecords){
            this.isShowSpinner = true;
            getEmailTemplateBody({ emailTemplateId : event.detail.selRecords[0].recId})
            .then(result => {
                debugger;
                console.log('Result..'+result);
                let jsonRes = JSON.parse(result);
                if(jsonRes.status){
                   this.richTextVal = jsonRes.emailWrp.bodyStr;
                   this.setFlowAttributes()
                   this.closeModal();
                }
                this.isShowSpinner = false;
               // this.isShowSpinner = false;
            })
            .catch(result => {
                console.log(result);
                this.isShowSpinner = false;
            });
        }
    }

    handleFileUploaded(event){
        // Get the list of uploaded files
        let uploadedFiles = event.detail.files;
        this.getFilesListJs();
    }

    handleFileUploadClick(){
        this.isTemplateSelect = false;
        this.isFileAttachment = true;
        this.showModal = true;
        this.getFilesListJs();
    }

    getFilesListJs(){

        this.isShowSpinner = true;
        getFilesList({ reqStr: ''})
            .then(result => {
                debugger;
                console.log('Result..'+result);
                let jsonRes = JSON.parse(result);
                if(jsonRes.status){
                    let  fileList = jsonRes.contentVersionList;
                    let finalFileList = [];
                    for(let i=0; i<fileList.length; i++){
                        let fileObj = fileList[i];
                        fileObj.fileLink = '/'+fileObj.Id;
                        fileObj.imgURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId='+fileObj.Id +'&operationContext=CHATTER';
                        fileObj.sizeStr = this.bytesToSize(fileObj.ContentSize);
                        fileObj.date = new Date(fileObj.CreatedDate).toLocaleString('default', { month: 'short', year : 'numeric', day : '2-digit' })
                        finalFileList.push(fileObj);
                    }
                    this.fileList = finalFileList;
                    this._fileListTemp = finalFileList;
                }
                this.isShowSpinner = false;
            })
            .catch(result => {
                console.log(result);
                this.isShowSpinner = false;
            });
    }
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            debugger;
            let queryTerm = evt.target.value;
            let  fileList = this._fileListTemp;
            let finalFileList = [];
            for(let i=0; i<fileList.length; i++){
                let fileObj = fileList[i];
                if(fileObj.Title.indexOf(queryTerm) != -1){
                    finalFileList.push(fileObj);
                }
            }
            this.fileList = finalFileList;
        }
    }

    bytesToSize(bytes) {
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes == 0) return '0 Byte';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    }

    handleAttachSelectedFiles(event){
        let checkboxElements = this.template.querySelectorAll('.file-checkbox');
        let selectedFilesIds = [];
        let selectedFiles = [];
        for(let i=0;i<checkboxElements.length;i++){
            if(checkboxElements[i].checked){
                selectedFilesIds.push(checkboxElements[i].value);
                for(let j=0;j<this._fileListTemp.length;j++){
                    if(this._fileListTemp[j].Id == checkboxElements[i].value){
                        let fileObj = this._fileListTemp[j];
                        let pillItem = {
                            type: 'avatar',
                            label: fileObj.Title,
                            src: fileObj.imgURL,
                            fallbackIconName: 'standard:file',
                            variant: 'circle',
                            alternativeText: fileObj.Title
                        }
                        selectedFiles.push(pillItem);
                        break;
                    }
                }
            }
        }
        this._selectedFileIds = selectedFilesIds;
        this.selectedFiles = selectedFiles;
        this.showModal = false;
        this.isShowSpinner = false;
        this.setFlowAttributes();
    }

    // Flow
    //Go to Next screen of Flow
    handleNext(event){ 
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent); 
    } 

    handleSendEmail(){
        debugger;
        this.isShowSpinner = true;

        let bccSelectedContacts = [];
        for(let i=0;i< this.selectedBCCContacts.length;i++){
            bccSelectedContacts.push(this.selectedBCCContacts[i].recId);
        }
        let ccSelectedContacts = [];
        for(let i=0;i< this.selectedCCContacts.length;i++){
            ccSelectedContacts.push(this.selectedCCContacts[i].recId);
        }
        let toSelectedContacts = [];
        for(let i=0;i< this.selectedToContacts.length;i++){
            toSelectedContacts.push(this.selectedToContacts[i].recId);
        }
        const editor = this.template.querySelector('lightning-input-rich-text');
        let fromAddress = '';
        
        var reqObj = {
            bccContacts : bccSelectedContacts.join(','),
            ccContacts :  ccSelectedContacts.join(','),
            toContacts :  toSelectedContacts.join(','),
            subject : this.subject,
            emailTemplateBody : editor.value,
            selectedFiles :this._selectedFileIds.join(','),
            fromAddress : fromAddress
        }
        sendEmail({ reqStr: JSON.stringify(reqObj)})
            .then(result => {
                debugger;
                console.log('Result..'+result);
                let jsonRes = JSON.parse(result);
                if(jsonRes.status){
                    const evt = new ShowToastEvent({
                        title: 'Email sent successfully' ,
                        message: 'Email sent successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                }
                this.isShowSpinner = false;
            })
            .catch(result => {
                console.log(result);
                this.isShowSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Error Occured' ,
                    message: 'Error Occured ',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            });
    }

    handleSubjectChange(event){
        this.subject = event.currentTarget.value;
    }

    resetEmailModal(){
        this.panelRefresh = false;
        let thisObj = this;
        setTimeout(function(){
            thisObj.panelRefresh = true;
        },2000);
        this.bccSelectedContacts = [];
        this.ccSelectedContacts = [];
        this.toSelectedContacts = [];
        this._selectedFileIds = [];
    }

    loadEmailTemplate(){
        debugger;
        this.isShowSpinner = true;
        getEmailTemplateBody({ emailTemplateId : 'Send Quote'})
        .then(result => {
            debugger;
            console.log('Result..'+result);
            let jsonRes = JSON.parse(result);
            if(jsonRes.status){
                this.richTextVal = jsonRes.emailWrp.bodyStr;
            }
            this.isShowSpinner = false;
        })
        .catch(result => {
            console.log(result);
            this.isShowSpinner = false;
        });
    }

    setFlowAttributes(){

        let bccSelectedContacts = [];
        for(let i=0;i< this.selectedBCCContacts.length;i++){
            bccSelectedContacts.push(this.selectedBCCContacts[i].recId);
        }
        let ccSelectedContacts = [];
        for(let i=0;i< this.selectedCCContacts.length;i++){
            ccSelectedContacts.push(this.selectedCCContacts[i].recId);
        }
        let toSelectedContacts = [];
        for(let i=0;i< this.selectedToContacts.length;i++){
            toSelectedContacts.push(this.selectedToContacts[i].recId);
        }
        const editor = this.template.querySelector('lightning-input-rich-text');
        let fromAddress = '';
        
        /*
        var reqObj = {
            bccContacts : bccSelectedContacts.join(','),
            ccContacts :  ccSelectedContacts.join(','),
            toContacts :  toSelectedContacts.join(','),
            subject : this.subject,
            emailTemplateBody : editor.value,
            selectedFiles :this._selectedFileIds.join(','),
            fromAddress : fromAddress
        }
        */

        const bccSelectedContactsEvent = new FlowAttributeChangeEvent('bccSelectedContactsVal', bccSelectedContacts);
        this.dispatchEvent(bccSelectedContactsEvent);

        const ccSelectedContactsEvent = new FlowAttributeChangeEvent('ccSelectedContactsVal', ccSelectedContacts);
        this.dispatchEvent(ccSelectedContactsEvent);

        const toSelectedContactsEvent = new FlowAttributeChangeEvent('toSelectedContactsVal', toSelectedContacts);
        this.dispatchEvent(toSelectedContactsEvent);

        const subjectEvent = new FlowAttributeChangeEvent('newSubjectVal', this.subject);
        this.dispatchEvent(subjectEvent);
        if(editor !=null && editor.value !=undefined && editor.value !=null){
            const emailTemplateBodyEvent = new FlowAttributeChangeEvent('emailTemplateBodyVal', editor.value);
            this.dispatchEvent(emailTemplateBodyEvent);
            this.emailTemplateBodyVal = editor.value;
        }
        const selectedFilesEvent = new FlowAttributeChangeEvent('selectedFilesVal', this._selectedFileIds.join(','));
        this.dispatchEvent(selectedFilesEvent);

        this.bccSelectedContactsVal = bccSelectedContacts.join(',');
        this.ccSelectedContactsVal =  ccSelectedContacts.join(',');
        this.toSelectedContactsVal = toSelectedContacts.join(',');
        this.newSubjectVal = this.subject;
        this.selectedFilesVal =  this._selectedFileIds.join(',');
        console.log('------------bccSelectedContactsVal' + this.bccSelectedContactsVal);
        console.log('------------ccSelectedContactsVal' + this.ccSelectedContactsVal);
        console.log('------------toSelectedContactsVal' + this.toSelectedContactsVal);




        
    }
}