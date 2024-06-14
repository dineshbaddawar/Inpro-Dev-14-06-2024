import { LightningElement, api, track } from 'lwc';

import InitiateApproval from '@salesforce/apex/QuoteApprovalHelper.initiateApprovalProcess';
import userId from '@salesforce/user/Id';

export default class QuoteSubmitForApproval extends LightningElement {
    
    @api recordId;
    loaded = true;
    Response = '';
    @track notes = '';
    @track error = '';

    handleSubmitForApprovalClick()
    {
        this.loaded = false;
        this.initiateQuoteApprovalProcess();
    }

    initiateQuoteApprovalProcess()
    {
        InitiateApproval({
            quoteId: this.recordId,
            userId: userId,
            comments: this.notes
        }).then(data => {
            if (data) {
                try {
                    if(data.toLowerCase().includes("success"))
                        document.location = location.href;
                    else
                    {
                        if(data.toLowerCase().includes("entity_is_locked"))
                            this.error = "Error: Either this quote is currently pending approval or the opportunity is currently going through an audit approval. Before the quote can be submitted for approval, the opportunity's audit must first be approved. Please check the quote/opportunity's 'Approval History' tab for more information.";
                        else
                            this.error = data;
                        
                            console.log(data);
                        this.loaded = true;
                    }                
                    

                } catch (error) {
                    console.log("There was an error submitting this quote for approval: " + error);
                }

            } else if (error) {
                this.error = error;
                console.log(error);
            }
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error submitting this quote for approval: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }
    
    handleNotesOnChange(event){
        console.log(event.target.value);
        this.notes = event.target.value;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}