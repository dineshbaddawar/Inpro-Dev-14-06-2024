import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getTaskStatus from '@salesforce/apex/EstimatingNoTakeoffHelper.getTaskStatus';
import updateOpportunityAndTask from '@salesforce/apex/EstimatingNoTakeoffHelper.updateOpportunityAndTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CANCEL_FIELD from '@salesforce/schema/Task.Task_Cancellation_Reason__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class EstimatingNoTakeoff extends LightningElement {
    @api recordId;
    @track comments = '';
    @track cancelReason = '';
    @track loaded = false;
    @track estimatingHours = '0';
    @track taskCancelReasons = [
        {label : "No Divisional Product Required", value : "No Divisional Product Required"},
        {label : "Small/Limited Qtys", value : "Small/Limited Qtys"},
        {label : "Not Enough Information", value : "Not Enough Information"},
        {label : "Can’t Accommodate in Estimating’s Schedule", value : "Can’t Accommodate in Estimating’s Schedule"},
        {label : "Can’t Match Specified Products", value : "Can’t Match Specified Products"},
        {label : "Plans are Unusable", value : "Plans are Unusable"},
        {label : "Duplicate Project", value : "Duplicate Project"},
        {label : "Qtys Provided in Spec", value : "Qtys Provided in Spec"},
        {label : "Job Entered After Cutoff Time", value : "Job Entered After Cutoff Time"},
        {label : "Miscellaneous", value : "Miscellaneous"},
    ];

    connectedCallback(){
        getTaskStatus({
            recordId: this.recordId
        }).then(data =>{
            if (data == 'Completed')
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: 'This task is already marked complete.',
                    variant: 'warning'
                  })); 
                this.closeQuickAction();
            }
            this.loaded = true;
        }).catch(data => {
            this.loaded = true;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: data.body.message,
                variant: 'warning'
              })); 
        })
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleInput(event){
        if (event.target.name == "reason")
        {
            this.comments = event.target.value;
        }
        else if (event.target.name == "cancelReason")
        {
            this.cancelReason = event.target.value;
        }
        else if (event.target.name == "hours")
        {
            this.estimatingHours = event.target.value;
        }
    }

    handleSubmit(){
        if (this.cancelReason == null || this.cancelReason == '' || this.comments == null || this.comments == '')
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Please fill in a value for Cancel Reason and Notes.',
                variant: 'warning'
            })); 
            return;
        }
        this.loaded = false;

        updateOpportunityAndTask({
            recordId: this.recordId, 
            cancelReason: this.cancelReason, 
            comments: this.comments, 
            estimatingHours: this.estimatingHours
        }).then(data =>{
            if (data != '')
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data,
                    variant: 'warning'
                })); 

                this.loaded = true;
            }
            else
            {
                window.location.reload();
                this.closeQuickAction();
            }
        }).catch(data => {
            this.loaded = true;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: data.body.message,
                variant: 'warning'
              })); 
        })
    }
}