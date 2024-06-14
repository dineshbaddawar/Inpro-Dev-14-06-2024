import { 
    LightningElement,
    api,
    wire,
    track } from 'lwc';

    import userId from '@salesforce/user/Id';
    import GetCurrentExpedite from '@salesforce/apex/ExpediteProcessHelper.GetCurrentExpedite';
    import GetCurrentUser from '@salesforce/apex/ExpediteProcessHelper.GetCurrentUser';
    import GetCurrentApprovalStep from '@salesforce/apex/ExpediteProcessHelper.GetCurrentApprovalStep';
    import ExecuteExpediteAction from '@salesforce/apex/ExpediteProcessHelper.ExecuteExpediteAction';
    import IsValidApprover from '@salesforce/apex/ExpediteProcessHelper.IsValidApprover';
    import GetSupplierOptions from '@salesforce/apex/ExpediteProcessHelper.GetSupplierOptions';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExpediteProcess extends LightningElement {
    @api recordId;

    @track expediteRoutingOptions = []; 

    @track currentStep = '';
    @track division = '';
    @track location = '';
    @track expeditePartNumber = '';
    @track processingAction = '';
    @track currentStepId = '';
    @track currentStepNetSuiteID = '';
    @track currentUserEmail = '';
    @track nextApproverType = '';
    @track Response = '';
    @track notes = '';
    @track netSuiteExpediteInternalId = '';
    @track approvalStage = '';
    @track approverEmail = '';
    @track approvalStepStatus = '';
    @track expediteRequestId = '';
    @track expediteCreatedById = '';
    @track expediteManagerEmail = '';
    @track expediteId = '';
    @track processButtonPressed = false;

    @track isProcessingAction = false;
    @track loaded = false;
    @track hasRoutingOptions = false;
    @track supplierOptionSelected = false;
    @track expediteStatus = '';
    
    connectedCallback() {       
        this.RetrieveCurrentApprovalStep();
    }

    RetrieveCurrentApprovalStep()
    {
        GetCurrentApprovalStep({
            recordId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(Expedite_Approval_Step__c => { 
                        this.approvalStage = Expedite_Approval_Step__c.Approval_Stage__c;
                        this.approverEmail = Expedite_Approval_Step__c.Approver__c;
                        this.approvalStepStatus = Expedite_Approval_Step__c.Status__c;
                        this.expediteRequestId = Expedite_Approval_Step__c.Expedite_Request__c;          
                        this.netsuiteExpediteApprovalStepId = Expedite_Approval_Step__c.NetSuite_ID__c;
                        if(Expedite_Approval_Step__c.Expedite_Request__r != null)
                        {
                            this.netSuiteExpediteInternalId = Expedite_Approval_Step__c.Expedite_Request__r.NetSuite_ID__c; 
                            this.expediteCreatedById =  Expedite_Approval_Step__c.Expedite_Request__r.CreatedById;
                            if(Expedite_Approval_Step__c.Expedite_Request__r.Approving_Manager__r != null)
                                this.expediteManagerEmail = Expedite_Approval_Step__c.Expedite_Request__r.Approving_Manager__r.Email__c;
                            this.expediteId = Expedite_Approval_Step__c.Expedite_Request__c;
                            this.expediteStatus = Expedite_Approval_Step__c.Expedite_Request__r.Status__c;
                        }  
                    }); 

                    if(this.expediteStatus == 'Rejected')
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'This expedite has been rejected and cannot be processed.',
                            variant: 'warning'
                        }));
                        this.loaded = false;
                    }
                    else
                        this.RetrieveCurrentUser();

                } catch (error) {
                    this.Response = "Error Retrieving Expedite: " + error;
                    console.log("Error Retrieving Expedite: " + error);
                    this.loaded = true; 
                }

            } else if (error) {
                this.error = error;
                console.log(error);
                this.loaded = true; 
            }
        })
        .catch(error => {
            // TODO: handle error
            this.Response = "Error getting Expedite Approval Step: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
            console.log("Error getting Expedite Approval Step: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            this.loaded = true; 
        });
    }

    // RetrieveCurrentExpediteStep()
    // {
    //     this.currentStepId = '';
    //     this.currentStepNetSuiteID = '';
    //     GetCurrentApprovalStep({
    //         expediteId: this.recordId
    //     }).then(data => {
    //         if (data) {
    //             try {
    //                 var myJSON = JSON.stringify(data);
    //                 console.log(myJSON);
    //                 if(data[0] != null)
    //                 {
    //                     this.currentStepId = data[0].Id;
    //                     this.currentStepNetSuiteID = data[0].NetSuite_ID__c;  
    //                 }
                                      
    //                 if(this.currentStepId != '' && this.currentStepNetSuiteID != '')
    //                     this.RetrieveCurrentUser();
    //                 else
    //                 {
    //                     this.error = 'Error: There was an error retrieving the current approval step.';
    //                     console.log(this.error);
    //                 }                   
    //             } catch (error) {
    //                 console.log("Error Retrieving Expedite Current Approval Step: " + error);
    //             }

    //         } else if (error) {
    //             this.error = error;
    //             console.log(error);
    //         }
    //     })
    //     .catch(error => {
    //         // TODO: handle error
    //         console.log("Error getting Expedite Current Approval Step: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
    //     });
    // }

    RetrieveCurrentUser()
    {
        this.currentUserEmail = '';
        this.currentUserProfile = '';
        GetCurrentUser({
            userId: userId
        }).then(data => {
            if (data) {
                try {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(User => { 
                        this.currentUserEmail = User.Email;
                        this.currentUserProfile = User.Profile.Name;                 
                    }); 
                    if(this.currentUserEmail != '')
                        this.loaded = true;
                    else
                    {
                        this.Response = 'Error: There was an error retrieving the current user\'s email.'
                        console.log(this.error);
                        this.loaded = true; 
                    }                    
                } catch (error) {
                    this.Response = "Error Retrieving the Current User's Email: " + error;
                    console.log("Error Retrieving the Current User's Email: " + error);
                    this.loaded = true; 
                }

            } else if (error) {
                this.Response = error;
                console.log(error);
                this.loaded = true; 
            }
        })
        .catch(error => {
            // TODO: handle error
            this.Response = "Error getting the current user's email: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
            console.log("Error getting the current user's email: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            this.loaded = true; 
        });
    }

    ValidateCurrentUserApprovalLevel()
    {
        if(this.currentUserProfile != 'System Administrator')
        {
            
            IsValidApprover({
                currentUserId: userId,
                recordId: this.recordId,
                approvalStage: this.approvalStage,
                expediteCreatedById: this.expediteCreatedById,
                expediteManagerEmail: this.expediteManagerEmail
            }).then(data => {
                if (data) {
                    try {
                        if(data == true)
                            this.ExecuteProcessingAction();
                        else
                        {
                            this.Response = 'Error: You do not have the necessary permissions to process this expedite approval step.';
                            console.log(this.error);
                            this.loaded = true; 
                        }          
                    } catch (error) {
                        this.Response = "Error Validating User Approval Level: " + error;
                        console.log("Error Validating User Approval Level: " + error);
                        this.loaded = true; 
                    }

                } else if (error) {
                    this.Response = error;
                    console.log(error);
                    this.loaded = true; 
                }
            })
            .catch(error => {
                // TODO: handle error
                this.Response = "Error getting the current user's approval level: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
                console.log("Error getting the current user's approval level: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true; 
            });
        }
        else
            this.ExecuteProcessingAction(); 
    }

    ValidateSupplierOptions()
    {
        if(this.approvalStage == "Requestor")
        {
            GetSupplierOptions({
                expediteId: this.expediteRequestId
            }).then(data => {
                if (data) {
                    try {  
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        var hasSelectedOptions = false;
                        var hasSupplierOptions = false;
                        data.forEach(Expedite_Supplier_Option__c => { 
                            hasSupplierOptions = true;
                            if(Expedite_Supplier_Option__c.Selected_Option__c == true)
                                hasSelectedOptions = Expedite_Supplier_Option__c.Selected_Option__c;                        
                        }); 
                        if(hasSupplierOptions && !hasSelectedOptions)
                        {
                            this.loaded = true; 
                            this.Response = "Error: You have not selected a supplier option. Please select one before approving this record.";
                        }
                        else
                            this.ExecuteProcessingAction();                       
                    } catch (error) {
                        this.loaded = true; 
                        this.Response = "Error Validating Supplier Options: " + error;
                        console.log("Error Validating Supplier Options: " + error);
                    }

                } else if (error) {
                    this.loaded = true; 
                    this.Response = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                this.loaded = true; 
                this.Response = "Error validating supplier options: " + error.status + " " + error.body.message + " " + error.body.stackTrace;           
                console.log("Error validating supplier options: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
        }
        else
            this.ExecuteProcessingAction();
    }

    ExecuteProcessingAction()
    {
        if(this.processButtonPressed)
        {
            this.Response = 'Error: The request is currently being processed. Please wait for the action to complete.';
            this.loaded = true;
            console.log(error);
        }
        else if(this.processingAction == 'Approve' || this.processingAction == 'Reject' || this.processingAction == 'Acknowledge')
        {
           this.processButtonPressed = true;
            ExecuteExpediteAction({
                actionType: this.processingAction,
                expediteId: this.expediteId,
                notes: this.notes,
                currentUserEmail: this.currentUserEmail,
                currentStepNetSuiteID: this.netsuiteExpediteApprovalStepId,
                expediteNetSuiteID: this.netSuiteExpediteInternalId,
                currentStepId: this.recordId,
                currentStepApprovalStage: this.approvalStage
            }).then(data => {
                if (data) {
                    try {
                        this.Response = data;
                        console.log(data);
                        if(!data.toLowerCase().includes("error"))
                            document.location = location.href; 
                        else
                        {
                            this.Response = data;
                            this.loaded = true; 
                        }
                    } catch (error) {
                        this.Response = "Error Processing Expedite Action: " + error;
                        console.log("Error Processing Expedite Action: " + error);
                        this.loaded = true; 
                    } 
                } else if (error) {
                    this.Response = error;
                    this.error = error;
                    console.log(error);
                    this.loaded = true; 
                }
            })
            .catch(error => {
                // TODO: handle error
                this.Response = "Error processing the current exepdite action: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
                console.log("Error processing the current exepdite action: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true; 
            });
        }      
        else
        {
            this.Response = 'Error: The processing action type is currently blank. Please contact IT Support.';
            this.loaded = true; 
            console.log(error);
        }
    }

    handleApproveExpediteClick()
    {
        this.loaded = false;
        this.Response = 'The request is currently being processed. Please wait for the action to complete.';
        this.processingAction = 'Approve';
        this.isProcessingAction = true;
        this.ExecuteProcessingAction();
    }

    handleRejectExpediteClick()
    {
        this.loaded = false;
        this.processingAction = 'Reject';
        this.isProcessingAction = true;
        this.ExecuteProcessingAction();
    }

    handleAcknowledgeExpediteClick(){
        this.loaded = false;
        this.processingAction = 'Acknowledge';
        this.isProcessingAction = true;
        this.ExecuteProcessingAction();
    }
    
    handleRoutingOptionChange(event){
        if (event.target.name == 'lcb_routingOptions')
            this.nextApproverType = event.target.value;
        if (event.target.name == 'ta_notes')
            this.notes = event.target.value;
    }

    handleNotesOnChange(event)
    {
        this.notes = event.target.value;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}