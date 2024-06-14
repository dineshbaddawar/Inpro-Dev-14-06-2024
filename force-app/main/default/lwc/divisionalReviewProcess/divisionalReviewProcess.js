import { LightningElement,
    api, 
    track
 } from 'lwc';

 import { NavigationMixin } from 'lightning/navigation';
 import ProcessDivisionalReview from '@salesforce/apex/DivisionalReviewProcessHelper.processDivisionalReview';
 import RetrieveDivisionalReview from '@salesforce/apex/DivisionalReviewProcessHelper.retrieveDivisionalReview';
 import RetrieveDivisionId from '@salesforce/apex/DivisionalReviewProcessHelper.retrieveDivisionId';
 import userId from '@salesforce/user/Id';

 import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class DivisionalReviewProcess extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @track constructionProjectId = '';
    @track notes = '';
    @track division = '';
    @track divSection = '';
    @track divisionId = '';
    @track currentStatus = '';
    @track statusList = [{
        value: 'Please Select',
        label: 'Please Select'
    },
    {
        value: 'Approved',
        label: 'Approved'
    }, {
        value: 'Rejected',
        label: 'Rejected'
    }
    ];
    @track status = 'Please Select';

    connectedCallback()
    {
        console.log('TEST');
        RetrieveDivisionalReview({
            divisionalReviewId: this.recordId
        }).then(data => {
            if (data) {
                try {                        
                    if(data.Construction_Project__c != null)
                        this.constructionProjectId = data.Construction_Project__c;  
                    if(data.Status__c != null)
                        this.currentStatus = data.Status__c;
                    if(data.Division__c != null)
                    {
                        this.division = data.Division__c; 
                        RetrieveDivisionId({
                            divisionName: this.division
                        }).then(data => {
                            if (data) {
                                try {                        
                                    if(data != null)
                                        this.divisionId = data;  
                                                      
                                } catch (error) {
                                    this.handleError(error);
                                }
                            }
                        })
                        .catch(error => {
                            this.handleError(error);
                        });
                    }
                    if(data.Div_Section__c != null)
                        this.divSection = data.Div_Section__c;                   
                } catch (error) {
                    this.handleError(error);
                }
            }
        })
        .catch(error => {
            this.handleError(error);
        });
        this.loaded = true;
    }
    
    handleStatusChange(event)
    {
        this.status = event.target.value;
    }

    handleNotesOnChange(event)
    {
        this.notes = event.target.value;
    }
    
    processRequest()
    {
        if(this.currentStatus != 'Pending')
        {
            this.handleError('Error: Rejected and approved divisional reviews cannot be processed again.');
        }
        else if(this.status == 'Please Select')
        {
            this.handleError('Error: Please select a status for this review.');
        }
        else
        {       
            this.loaded = false;
            ProcessDivisionalReview({
                divisionalReviewId: this.recordId,
                notes: this.notes,
                status: this.status,
                currentUserId: userId
            }).then(data => {
                if (data) {
                    try 
                    {     
                        if(!data.toLowerCase().includes("error"))
                        {
                            if(this.status == 'Rejected')
                                document.location = location.href;
                            else
                            {
                                this[NavigationMixin.Navigate]({
                                    type: "standard__component",
                                    attributes: {
                                        componentName: "c__accountNewOpportunityButton"
                                    },
                                    state: {
                                        c__currentRecordId: this.constructionProjectId,
                                        c__division: this.divisionId,
                                        c__divisionSection: this.divSection
                                    }
                                });
                            }
                        }                            
                        else
                            this.handleError(data);                                      
                    } 
                    catch (error) 
                    {
                        this.handleError(error);
                    }
                }
                this.loaded = true;
            })
            .catch(error => {
                this.handleError(error);
            });
        }
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
                title: 'Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }
}