import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import approveEstimateQuote from '@salesforce/apex/QuoteActionRequestHelper.approveEstimateQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityEstimatingStatus from '@salesforce/apex/QuoteActionRequestHelper.getOpportunityEstimatingStatus';

export default class QuoteEstimateApprove extends LightningElement {
    @api recordId;
    @track loaded = false;
    connectedCallback(){
        approveEstimateQuote({QuoteId: this.recordId}).then(results => {
            if (results == 'Success')
            {
                this.closeQuickAction();
                window.location.reload();
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: results,
                    variant: 'warning'
                  })); 
            }
            
        }).catch(error =>{
            if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined)
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                    message: error.body.pageErrors[0].message,
                    variant: 'warning'
                  })); 
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error!',
                    message: error,
                    variant: 'warning'
                  })); 
            }
        });
        /*
        getOpportunityEstimatingStatus({QuoteId: this.recordId}).then(results => {
            if (results != 'Estimate Complete')
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: 'Opportunity Estimating status is not "Estimate Complete". Cannot activate quote.',
                    variant: 'warning'
                  })); 
                  this.closeQuickAction();
            }
            else{
                
            }
        });*/
    };

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    };
}