import { LightningElement,
    api,
    wire,
    track } from 'lwc';

    import userId from '@salesforce/user/Id';
    import GetOrderInformation from '@salesforce/apex/OrderConfirmationSendHelper.GetOrderInformation';
    import GetUserEmailTemplates from '@salesforce/apex/PrintQuoteHelper.GetUserEmailTemplates';
    import ContactSearch from '@salesforce/apex/AccountNewOpportunityHelper.ContactSearch';
    import UserSearch from '@salesforce/apex/AccountNewOpportunityHelper.UserSearch';
    import SendEmail from '@salesforce/apex/PrintQuoteHelper.SendEmail';
    import GeneratePrintPDF from '@salesforce/apex/OrderConfirmationSendHelper.GeneratePrintPDF';
    import UpdateOrderConfirmationSentFlag from '@salesforce/apex/OrderConfirmationSendHelper.UpdateOrderConfirmationSentFlag';
    import RetrieveShippingNotificationEmail from '@salesforce/apex/OrderConfirmationSendHelper.RetrieveShippingNotificationEmail';
    import RetrieveOrderEditLink from '@salesforce/apex/OrderConfirmationSendHelper.RetrieveOrderEditLink';

    import {
        ShowToastEvent
    } from 'lightning/platformShowToastEvent';

export default class OrderConfirmationSend extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track sendThroughOutlook = false;
    @track sendThroughSalesforce = true;
    @track screenOneOpen = true;
    @track screenTwoOpen = false;
    @track netSuiteOrderId = '';
    @track emailSignatureName = '';
    @track emailSignatureHtmlValue = '';
    @track emailTemplateList = [];
    @track netSuiteInternalId = '';
    @track selectedToContact = Array(0);
    @track selectedToUser = Array(0);
    @track selectedCCContact = Array(0);
    @track selectedCCUser = Array(0);
    @track selectedBCCContact = Array(0);
    @track selectedBCCUser = Array(0);
    @track toAddress = '';
    @track ccAddress = '';
    @track bccAddress = '';
    @track emailSubject = '';
    @track emailBody = '';
    @track allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
        'background',
    ];
    @track pdfName = '';
    @track accountId = '';
    @track orderNumber = '';
    @track shippingNotificationEmail = '';
    @track projectName = '';
    @track quoteName = '';
    @track selectedEmailTemplate; 
    @track quoteId = '';
    @track additionalFileIds = [];
    @track additionalFileNames = '';
    @track orderEditLink = '';

    get acceptedFormats() {
        return ['.xls', '.xlsx', '.csv', '.png', '.jpg', '.pdf'];
    }

    connectedCallback() 
    {
        this.loaded = false;
        this.retrieveOrderInformation();
    }

    retrieveOrderInformation()
    {
        try {
            GetOrderInformation({
                recordId: this.recordId
            }).then(data => {
                console.log(data);               
                if(data)
                {
                    if(data.NetSuite_Id__c != null)
                        this.netSuiteInternalId = data.NetSuite_Id__c;
                    if(data.AccountId != null)
                        this.accountId = data.AccountId;
                    if(data.NetSuite_TranId__c != null)
                    {
                        this.orderNumber = data.NetSuite_TranId__c;
                        this.pdfName = 'Inpro Order Confirmation: Order#' + this.orderNumber;
                    }
                    if(data.Quote != null)
                    {
                        this.quoteName = data.Quote.Name;
                        this.quoteId = data.QuoteId;
                    }
                    if(data.Opportunity != null)
                    {
                        this.projectName = data.Opportunity.Name;
                        if(data.Opportunity.Territory_Manager__r != null)
                            this.bccAddress = data.Opportunity.Territory_Manager__r.Email;
                    }
                    if(data.Processed_By__r != null)
                        this.ccAddress = data.Processed_By__r.Email + ',';
                        if(data.Opportunity_Owner__r != null)
                        this.ccAddress += data.Opportunity_Owner__r.Email;
                    this.emailSubject = 'Inpro Order Confirmation (' + this.orderNumber + ') || ' + this.quoteName + ' || ' + this.projectName;
                    this.retrieveShippingConfirmationEmail();
                    this.retrieveOrderEditLink(); 
                }
                else
                    this.handleError('Error: There was an error retrieving the order.');           
            });
        } catch (error) {
            console.log(error);
            this.loaded = true;
        }
    }

    retrieveOrderEditLink()
    {
        try {
            RetrieveOrderEditLink({
                orderInternalId: this.netSuiteInternalId
            }).then(data => {
                console.log(data);               
                if(data)
                {
                    if(!data.toLowerCase().includes("error"))
                    {
                        this.orderEditLink = data; 
                    }
                    else
                        this.handleError(data);
                }
                else
                    this.handleError('Error: The shipping notification email could not be retrieved. Please specify a \'To\' email on the next screen if you\'re sending the confirmation to the customer.');  
                this.handleRefreshSignatures();          
            });
        } catch (error) {
            this.handleError('Error: The shipping notification email could not be retrieved. Please specify a \'To\' email on the next screen if you\'re sending the confirmation to the customer.');  
            this.handleRefreshSignatures();
        }
    }

    printOrderEdit()
    {
        //document.location = this.orderEditLink;
        window.open(this.orderEditLink,"_blank");                                
    }

    retrieveShippingConfirmationEmail()
    {
        try {
            RetrieveShippingNotificationEmail({
                orderInternalId: this.netSuiteInternalId
            }).then(data => {
                console.log(data);               
                if(data)
                {
                    if(!data.toLowerCase().includes("error"))
                    {
                        this.toAddress = data.replace(';',','); 
                        if(this.toAddress.charAt(this.toAddress.length - 1) == ',')
                            this.toAddress = this.toAddress.substring(0,this.toAddress.length-1); 
                    }
                    else
                        this.handleError(data);
                }
                else
                    this.handleError('Error: The shipping notification email could not be retrieved. Please specify a \'To\' email on the next screen if you\'re sending the confirmation to the customer.');  
                this.handleRefreshSignatures();          
            });
        } catch (error) {
            this.handleError('Error: The shipping notification email could not be retrieved. Please specify a \'To\' email on the next screen if you\'re sending the confirmation to the customer.');  
            this.handleRefreshSignatures();
        }
    }

    handleCancel()
    {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleManageSignatures(){
        window.open(window.location.origin + '/lightning/o/EmailTemplate/home?queryScope=mine', '_blank');  
    }

    handleRefreshSignatures(){
        this.loaded = false;
        GetUserEmailTemplates({userId: userId}).then(templates =>{
            this.emailTemplates = templates;
            this.emailTemplateList = [];
            templates.forEach(x => {
                this.emailTemplateList.push({
                    label: x.Name,
                    value: x.Id
                });
            });
            console.log(templates);
            this.loaded = true;
        });
    }

    openOrderConfirmation()
    {
        window.open("/apex/OrderConfirmation?internalId=" + this.netSuiteInternalId,"_blank");      
        this.loaded = true;                          
    }

    moveToScreenOne()
    {
        this.screenOneOpen = true;
        this.screenTwoOpen = false;
    }

    moveToScreenTwo()
    {
        if(this.sendThroughOutlook)
        {
            this.loaded = false;
            UpdateOrderConfirmationSentFlag({orderId: this.recordId}).then(results => {
                console.log(results);
                if (results == '')
                {
                    this.openOrderConfirmation();
                }
                else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: results,
                        variant: 'warning'
                    }));
                }
            }).catch(error => {
                this.handleError(error);
            });     
        }
        else
        {
            this.screenOneOpen = false;
            this.screenTwoOpen = true;
        }
    }

    handleFinish(){
        this.loaded = false;     
        GeneratePrintPDF({QuoteId: this.quoteId, FileName: this.pdfName, netSuiteInternalId: this.netSuiteInternalId, orderId: this.recordId}).then(attachmentId =>{
            attachmentId = '\'' + attachmentId + '\',';
            if(this.additionalFileIds.length > 0)
            {
                for(var i = 0; i < this.additionalFileIds.length; i++)
                {
                    attachmentId += '\'' + this.additionalFileIds[i] + '\',';
                }
            }
            attachmentId = attachmentId.substring(0,attachmentId.length - 1);
            console.log(attachmentId);
            var params = {
                QuoteId: this.quoteId,
                ToAddress: this.toAddress,
                CcAddress: this.ccAddress,
                BccAddress: this.bccAddress,
                Subject: this.emailSubject,
                BodyHtml: this.emailBody,
                AttachmentIds: attachmentId
            };          
            SendEmail(params).then(results => {
                console.log(results);
                if (results == '')
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Email Sent and Quote updated. Please visit the quote to see the tracked email.',
                        mode: 'sticky',
                        variant: 'success'
                    }));
                    this.closeQuickAction();
                }
                else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: results,
                        variant: 'warning'
                    }));
                }
                this.loaded = true;
            }).catch(error => {
                this.handleError(error);
            });           
        });
    }

    handleInput(event)
    {
        const name = event.target.name;
        if(name == 'li_sendThroughSalesforce')
        {
            if(event.target.checked)
            {
                this.sendThroughOutlook = false;
                this.sendThroughSalesforce = true;
            }
        }
        else if (name == 'li_sendThroughOutlook')
        {
            if(event.target.checked)
            {
                this.sendThroughOutlook = true;
                this.sendThroughSalesforce = false;
            }
        }
        else if (name == 'selectedEmailTemplate')
        {
            this.selectedEmailTemplate = event.target.value;
            var htmlValue = this.emailTemplates.filter(x => { return x.Id == event.target.value; })[0].HtmlValue;
            this.emailBody = this.emailBody + '<br>' + htmlValue;
        }
        else if (name == 'emailBody')
        {
            this.emailBody = event.detail.value;
        }
        else if (name == 'toAddress')
        {
            this.toAddress = event.detail.value;
        }
        else if (name == 'ccAddress')
        {
            this.ccAddress = event.detail.value;
        }
        else if (name == 'bccAddress')
        {
            this.bccAddress = event.detail.value;
        }
    }

    handleUserSearch(event)
    {
        const target = event.target;
        console.log(event.detail);
        UserSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting accounts: " + error);
            });
    }

    handleLookupSelectionChange(event)
    {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        const target = event.target;
        console.log(target);
        var name = '';

        if (selection.length > 0) {
            this.tempInt = 1;
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);
            
            if (event.target.name == "toContact" || event.target.name == "toUser") {
                if (subTitle !== undefined && subTitle !== '')
                {
                    this.toAddress += this.toAddress.length != 0 ? ',' + subTitle : subTitle;
                }
            } else if (event.target.name == "ccContact" || event.target.name == "ccUser") {
                if (subTitle !== undefined && subTitle !== '')
                    this.ccAddress += this.ccAddress.length != 0 ? ',' + subTitle : subTitle;
            } else if (event.target.name == "bccContact" || event.target.name == "bccUser") {
                if (subTitle !== undefined && subTitle !== '')
                    this.bccAddress += this.bccAddress.length != 0 ? ',' + subTitle : subTitle;
            }
            target.clearSelection();
        }
    }    

    handleContactSearch(event) {
        const target = event.target;
        console.log(event.detail);
        ContactSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting accounts: " + error);
            });
    }

    closeQuickAction() {
        console.log('TEST END');
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleError(error) {
        //console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }

    handleUploadFinished(event)
    {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        for(var i = 0; i < uploadedFiles.length; i++)
        {
            this.additionalFileIds.push(uploadedFiles[i].documentId);
            this.additionalFileNames += (uploadedFiles[i].name + ', ');
        }
        this.additionalFileNames = (this.additionalFileNames).substring(0,this.additionalFileNames.length - 2);
    }
}