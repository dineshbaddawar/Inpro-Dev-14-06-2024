import { LightningElement, 
         api, 
         track 
       } 
from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import processChangeRequest from '@salesforce/apex/ChangeRequestProcessHelper.FinishProcessingChangeRequest';
import RetrieveCurrentUserInfo from '@salesforce/apex/ChangeRequestProcessHelper.RetrieveCurrentUserInfo';
import RetrievePendingApprovals from '@salesforce/apex/ChangeRequestProcessHelper.RetrievePendingApprovals';

import userId from '@salesforce/user/Id';

export default class ChangeRequestProcess extends LightningElement {
    
    @api recordId;
    loaded = true;
    Response = '';
    @track notes = '';
    @track action = '';
    @track isNationalAccountApprover = false;
    @track isFinanceApprover = false;
    @track approvalStepData = [];
    @track approvalStepColumns= [
        {label: 'Name', fieldName: 'approvalStepName'},
        {label: 'Approval Type', fieldName: 'approvalType'},
        {label: 'Processed On', fieldName: 'processedOn'},
        {label: 'Processed By', fieldName: 'processedBy'},
        {label: 'Status', fieldName: 'status'},
        {label: 'Processing Notes', fieldName: 'processingNotes'}
    ];
    @track approvalStepSelectedRows = [];
    @track approvalStepSelectedTypes = [];

    connectedCallback()
    {
        this.retrieveCurrentUserInfo();
    }

    retrieveCurrentUserInfo()
    {
        RetrieveCurrentUserInfo({
            userId: userId
        }).then(data => {
            if (data) {
                try {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    if (!data.message.toLowerCase().includes("error"))
                    {
                        this.isNationalAccountApprover = data.isNationalAccountApprover;
                        this.isFinanceApprover = data.isFinanceApprover;
                        this.retrieveApprovalSteps();
                    }
                    else
                        this.handleError(data);
                } catch (error) {
                    this.handleError(error);
                }
            } else if (error) {
                this.handleError(error);
            }           
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    retrieveApprovalSteps()
    {
        RetrievePendingApprovals({
            changeRequestId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    var tempApprovalStepArr = [];
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(aStep => {                          
                        var currentStep = {};
                        
                        if(aStep.Id != null)
                        {
                            currentStep.Id = aStep.Id;
                            if(aStep.Name != null)
                                currentStep.approvalStepName = aStep.Name;
                            if(aStep.Approval_Type__c != null)
                                currentStep.approvalType = aStep.Approval_Type__c;
                            if(aStep.Processed_On__c != null)
                                currentStep.processedOn = aStep.Processed_On__c;
                            if(aStep.Processed_By__c != null)
                                currentStep.processedBy = aStep.Processed_By__c;
                            if(aStep.Status__c != null)
                                currentStep.status = aStep.Status__c;
                            if(aStep.Processing_Notes__c != null)
                                currentStep.processingNotes = aStep.Processing_Notes__c;
                            tempApprovalStepArr.push(currentStep);
                        }                                                                                        
                    });  
                    this.approvalStepData = tempApprovalStepArr;               
                } catch (error) {
                    console.log("Error Loading Approval Steps: " + error);
                }

            } else if (error) {
                this.error = error;
                console.log(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error retrieving the bidders: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    handleNotesOnChange(event){
        this.notes = event.target.value;
    }

    handleApproveClick()
    {
        if(this.approvalStepSelectedRows.length > 0)
        {
            console.log('TEST');
            this.loaded = false;
            this.action = 'Approve';
            this.finishProcessingChangeRequest();
        }
        else
            this.handleError('Error: At least one approval step must be selected before committing the approved changes.');
    }

    handleRejectClick()
    {
        if(this.approvalStepSelectedRows.length > 0)
        {
            console.log('TEST');
            this.loaded = false;
            this.action = 'Reject';
            this.finishProcessingChangeRequest();
        }
        else
            this.handleError('Error: At least one approval step must be selected before processing a rejection.');
    }

    finishProcessingChangeRequest()
    {
        processChangeRequest({
            changeRequestId: this.recordId,
            action: this.action,
            notes: this.notes,
            selectedApprovalStepIds: this.approvalStepSelectedRows,
            selectedApprovalStepTypes: this.approvalStepSelectedTypes,
            userId: userId
        }).then(data => {
            if (data) {
                try {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    if (!data.toLowerCase().includes("error"))
                        document.location = "https://" + location.hostname + "/lightning/r/Change_Request__c/" + this.recordId + "/view";
                    else
                    {
                        this.handleError(data);
                    }

                } catch (error) {
                    this.handleError(error);
                }

            } else if (error) {
                this.handleError(error);
            }
            
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    handleDataSelection(event)
    {
        this.approvalStepsSelected = [];
        const selectedRows = event.detail.selectedRows;
        var tempSelectedRows = [];
        this.template.querySelector("[data-id='approvalStepTable']").selectedRows = [];
        this.approvalStepSelectedTypes = [];

        for(var i = 0; i < selectedRows.length; i++)
        {
            if(selectedRows[i].approvalType == 'Finance' && !this.isFinanceApprover)
                this.handleError("Error: You don't have the necessary permissions to process Finance approval steps.");   
            else if(selectedRows[i].approvalType == 'National Account' && !this.isNationalAccountApprover)
                this.handleError("Error: You don't have the necessary permissions to process National Account approval steps.");       
            else
            {
                tempSelectedRows.push(selectedRows[i].Id); 
                this.approvalStepSelectedTypes.push(selectedRows[i].approvalType);
            }               
        }
            this.approvalStepSelectedRows = tempSelectedRows;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Attention! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Attention!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Attention!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }
}