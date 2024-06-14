import { 
    LightningElement,
    api,
    wire,
    track 
} from 'lwc';

import RetrieveRecordInfo from '@salesforce/apex/OrderRequestRouteHelper.RetrieveRecordInfo';
import UpdateOrderRequestStatusAndNotes from '@salesforce/apex/OrderRequestRouteHelper.UpdateOrderRequestStatusAndNotes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID from '@salesforce/user/Id';
import {
    getRecord
} from 'lightning/uiRecordApi';

export default class OrderRequestChangeStatus extends LightningElement 
{
    @api recordId;
    loaded = true;
    @track status = '';
    @track updateStatus = false;
    @track orderRequestIsApproved = false;
    @track orderRequestIsProcessed = false;
    @track newOrderRequestComments = '';
    @track orderRequestComments = '';
    @track finalOrderRequestComments = '';
    @track currentUserName = '';

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.currentUserName = data.fields.Name.value;
        }
    }

    connectedCallback()
    {
        try {
            console.log('entered');
            this.loaded = false;
            RetrieveRecordInfo({
                    recordId: this.recordId
                }).then(data => {
                    data.forEach(record => {
                        if(record.Approval_Status__c != null)
                        {
                            this.status = record.Approval_Status__c;
                            if(this.status == 'Approved')
                                this.orderRequestIsApproved = true;
                            if (this.status == 'Order Complete')
                                this.orderRequestIsProcessed = true;
                        }
                        else
                            this.handleError('Error: The order request status could not be retrieved.');
                        if (record.Order_Request_Comments__c != null)
                            this.orderRequestComments = record.Order_Request_Comments__c;
                        this.loaded = true;
                    });
                })
                .catch(error => {
                    var errorJson = JSON.stringify(error);
                    console.log("Error Retrieving Record Info: " + errorJson);
                    this.handleError("Error retrieving record info: " + errorJson);
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error retrieving record info: " + errorJson);
            this.handleError("Error retrieving record info: " + errorJson);
        }
    }

    updateOrderRequest()
    {
        try
        {
            this.finalOrderRequestComments = '';
            if(this.newOrderRequestComments != null && this.newOrderRequestComments != '')
            {
                var currentdate = new Date(); 
                var datetime = (currentdate.getMonth()+1) + "/"
                + currentdate.getDate()  + "/" 
                + currentdate.getFullYear() + " @ "  
                + currentdate.getHours() + ":"  
                + currentdate.getMinutes();
                this.finalOrderRequestComments = '(' + this.currentUserName + ' - ' + datetime + ') ' + this.newOrderRequestComments + '\n' + this.orderRequestComments;
            }

            UpdateOrderRequestStatusAndNotes({
            status: this.status, 
            recordId: this.recordId,
            orderRequestComments: this.finalOrderRequestComments,
            updateStatus: this.updateStatus
            }).then(data => {
                console.log(data);
                if(!data.toLowerCase().includes("error"))
                    document.location = location.href;
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error Updating Order Request: " + errorJson);
                this.handleError("Error Updating Order Request: " + errorJson);
            });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error Updating Order Request: " + errorJson);
            this.handleError("Error Updating Order Request: " + errorJson);
        }
    }
    
    markOrderRequestCompleted()
    {
        this.status = 'Order Complete';
        this.loaded = false;
        this.updateStatus = true;
        this.updateOrderRequest();
    }

    cancelOrderRequest()
    {
        this.status = 'Canceled';
        this.loaded = false;
        this.updateStatus = true;
        this.updateOrderRequest();
    }

    updateOnlyComments()
    {
        this.loaded = false;
        this.updateStatus = false;
        this.updateOrderRequest();
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleInputChange(event)
    {
        this.newOrderRequestComments = event.target.value;
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