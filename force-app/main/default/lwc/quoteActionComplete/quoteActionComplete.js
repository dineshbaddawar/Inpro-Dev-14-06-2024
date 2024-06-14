import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getQuoteAction from '@salesforce/apex/QuoteActionRequestHelper.getQuoteAction';
import completeQuoteAction from '@salesforce/apex/QuoteActionRequestHelper.completeQuoteAction';
import rejectQuoteAction from '@salesforce/apex/QuoteActionRequestHelper.rejectQuoteAction';
import updateQuoteActionPending from '@salesforce/apex/QuoteActionRequestHelper.updateQuoteActionPending';
import sendSSManufacturingEmail from '@salesforce/apex/QuoteActionRequestHelper.sendSSManufacturingEmail';
import notifyUsers from '@salesforce/apex/CustomNotificationFromApex.notifyUsersStatic';
import Id from '@salesforce/user/Id';

export default class QuoteActionComplete extends LightningElement {
    @track inputText = '';
    @track buttonText = 'Confirm';
    @track buttonVariant = 'success';
    @track titleText = 'Quote Action';

    @track isApprover = false;
    @track isNotifyingApprover = false;
    @track isNotifyingSSManufacturing = false;
    @track isSignScheduleChangeRequest = false;
    @track isIllustrationChangeRequest = false;
    @track isCustomPartNumberRequest = false;
    @track notes = '';

    @track loaded = false;
    @track userId = Id;
    @track quoteAction;
    @api recordId;
    @api customAction;

    connectedCallback(){
        getQuoteAction({
            TaskId: this.recordId
        }).then(data =>{
            this.quoteAction = JSON.parse(data);
            console.log(this.quoteAction);
            if (this.quoteAction.Status__c == 'Complete') //Close lwc - this is already complete
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: 'This task is already marked Complete. No further action required.',
                    variant: 'warning'
                }));

                this.closeQuickAction();
            }
            if (this.customAction == 'Approve')
            {
                if (this.quoteAction.Type__c == 'Custom Part Number Request')
                {
                    this.titleText = 'Custom Part Number Request - Action';
                    //If there is an approver and current user is not the approver
                    if (this.quoteAction.ApproverId__c != null && this.quoteAction.ApproverId__c != this.userId)
                    {
                        this.handleAutoClose();
                    }
                    else if ((this.quoteAction.ApproverId__c != null && this.quoteAction.ApproverId__c == this.userId)) //Is approver
                    {
                        this.isApprover = true;
                        this.inputText = 'Approving will mark this task complete.';
                        this.buttonText = 'Approve';
                    }
                    else{ //No approver required
                        this.handleAutoClose();
                    }
                }
                else{
                    this.handleAutoClose();
                }
            }
            else if (this.customAction == 'Reject')
            {
                this.buttonVariant = 'destructive';

                if (this.quoteAction.Type__c == 'Custom Part Number Request')
                {
                    this.titleText = 'Custom Part Number Request - Action';
                    //If there is an approver and current user is not the approver
                    if (this.quoteAction.ApproverId__c != null && this.quoteAction.ApproverId__c != this.userId)
                    {
                        this.handleAutoClose();
                    }
                    else if ((this.quoteAction.ApproverId__c != null && this.quoteAction.ApproverId__c == this.userId)) //Is approver
                    {
                        this.isApprover = true;
                        this.inputText = 'Rejecting will notify the task owner. This does not complete the task.';
                        this.buttonText = 'Reject';
                    }
                    else{ //No approver required
                        this.handleAutoClose();
                    }
                }
                else{
                    this.handleAutoClose();
                }
            }
            else if (this.customAction == 'Notify')
            {
                if (this.quoteAction.Type__c == 'Custom Part Number Request')
                {
                    this.titleText = 'Custom Part Number Request - Action';
                    //If there is an approver and current user is not the approver
                    if (this.quoteAction.ApproverId__c != null && this.quoteAction.ApproverId__c != this.userId)
                    {
                        this.isNotifyingApprover = true;
                        this.inputText = 'Would you like to send the approver a notification to complete this task?';
                        this.buttonText = 'Send Approver Notification';
                    }
                    else{
                        this.handleAutoClose();
                    }
                }
                else if (this.quoteAction.Type__c == 'Sign Schedule Change Request' || this.quoteAction.Type__c == 'Illustration Change Request')
                {
                    if (this.quoteAction.Type__c == 'Sign Schedule Change Request')
                    {
                        this.isSignScheduleChangeRequest = true;
                    }
                    else if (this.quoteAction.Type__c == 'Illustration Change Request')
                    {
                        this.isIllustrationChangeRequest = true;
                    }
    
                    this.isNotifyingSSManufacturing = true;
                    this.titleText = 'Sign Schedule Change Request - Action';
                    this.inputText = 'This quote action can only be completed by SS Manufacturing. If needed, you can resend the original Change Request email here.'
                    this.buttonText = 'Resend Request Email';
                }
                else{
                    this.handleAutoClose();
                }
            }
            else{
                this.handleAutoClose();
            }
        }).finally(data =>{
            this.loaded = true;
        })
    };

    handleInput(event){
        //console.log(event.target.name);
        //console.log(event.target.value);
        if (event.target.name == "notes")
        {
            this.notes = event.target.value;
        }
    }

    handleAutoClose()
    {
        this.dispatchEvent(new ShowToastEvent({
            title: '',
            message: 'This function is not applicable to this task.',
            variant: 'warning'
        }));
        this.closeQuickAction();
    }

    handleReject(event){
        if (this.notes == '' || this.notes == undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                message: 'Please provide notes.',
                variant: 'warning'
            }));
        }
        else{
            this.loaded = false;
            rejectQuoteAction({
                TaskId: this.recordId,
                Notes: this.notes
            }).then(data =>{
                notifyUsers({
                    recipientsIds: [this.quoteAction.OwnerId], 
                    targetId: this.Id, 
                    title: 'Custom Part Number Request - Rejected: Action Required', 
                    body: 'The assigned approver has rejected your custom part number request. Please check the comments for further information.'
                }).then(data => {
                    //Toast success
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Notes have been saved and owner has been notified.',
                        variant: 'success'
                    }));
    
                    this.closeQuickAction();
                })
            }).finally(data =>{
                this.loaded = true;
            });
        }
    };
    
    handleApprove(event)
    {
        console.log(this.recordId);
        completeQuoteAction({TaskId: this.recordId, Notes: this.notes}).then(data => {
            if (this.isApprover)
            {
                //Notify assigned user
                notifyUsers({
                    recipientsIds: [this.quoteAction.OwnerId], 
                    targetId: this.Id, 
                    title: 'Custom Part Number Request - Approved', 
                    body: 'A Custom Part Number Request has been approved.'
                });
            }
            //Toast success
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Quote Action has been marked complete.',
                variant: 'success'
            }));

            this.closeQuickAction();
        }).catch(jqXHR,textStatus,errorThrown => {
            console.log(errorThrown);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: textStatus,
                variant: 'warning'
            })); 
        }).finally(data => { //only needed on failure
            this.loaded = true;
        });
    }

    handleSubmit(event){
        this.loaded = false;

        if (this.customAction == "Approve" && this.isApprover)
        {
            this.handleApprove(event);
        }
        if (this.customAction == "Reject" && this.isApprover)
        {
            this.handleReject(event);
        }
        else if (this.isNotifyingApprover == true) //Notify approver
        { 
            updateQuoteActionPending({TaskId: this.recordId}).then(data =>{
                notifyUsers({
                    recipientsIds: [this.quoteAction.ApproverId__c], 
                    targetId: this.Id, 
                    title: 'Custom Part Number Request - Approval Needed', 
                    body: 'A Custom Part Number Request needs your approval. Please verify information and Mark Complete.'
                }).then(data => {
                    //Toast success
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Approver has been notified.',
                        variant: 'success'
                    }));
    
                    this.closeQuickAction();
                })
            }).catch(data =>{
                console.log(data);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data,
                    variant: 'warning'
                })); 
            }).finally(data => { //only needed on failure
                this.loaded = true;
            });
        }
        else if (this.isNotifyingSSManufacturing)
        {
            var requestTypeInt = 0;
            if (this.isSignScheduleChangeRequest) requestTypeInt = 1;
            else if (this.isIllustrationChangeRequest) requestTypeInt = 2;
            sendSSManufacturingEmail({TaskId: this.recordId, requestType: requestTypeInt}).then(data => {
                //Toast success
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Manufacturing has been sent another email about this request.',
                    variant: 'success'
                }));

                this.closeQuickAction();
            }).catch(data =>{
                console.log(data);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data.body.message,
                    variant: 'warning'
                })); 
            }).finally(data => { //only needed on failure
                this.loaded = true;
            });
        }
    };

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}