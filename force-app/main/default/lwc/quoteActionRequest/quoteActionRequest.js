import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteName from '@salesforce/apex/QuoteActionRequestHelper.getQuoteName';
import getQuoteStatus from '@salesforce/apex/QuoteActionRequestHelper.getQuoteStatus';
import getUsers from '@salesforce/apex/QuoteActionRequestHelper.getUsers';
import createQuoteAction from '@salesforce/apex/QuoteActionRequestHelper.createQuoteAction';
import createSignScheduleChangeRequest from '@salesforce/apex/QuoteActionRequestHelper.createSignScheduleChangeRequest';
import getQuoteLineItemsWithSignSchedules from '@salesforce/apex/QuoteActionRequestHelper.getQuoteLineItemsWithSignSchedules';
import createIllustrationChangeRequest from '@salesforce/apex/QuoteActionRequestHelper.createIllustrationChangeRequest';
import userSearch from '@salesforce/apex/QuoteActionRequestHelper.userSearch';
import notifyUsers from '@salesforce/apex/CustomNotificationFromApex.notifyUsersStatic'



export default class QuoteActionRequest extends LightningElement {
    @track actionTypes = 
        [
            { label: 'Custom Part Number Request', value: 'Custom Part Number Request'},
            { label: 'Sign Schedule Change Request', value: 'Sign Schedule Change Request'},
            { label: 'Illustration Change Request', value: 'Illustration Change Request'}
        ];
    @track isDefaultAction = true;
    @track isCustomPartNumberRequest = false;
    @track isSignScheduleChangeRequest = false;
    @track isIllustrationChangeRequest = false;
    
    @track routeTypes = [{ value: 'ccs', label: 'CCS Queue'}, { value: 'manager', label: 'Manager'}];
    @track loaded = false;
    @track quoteName = '';
    @track managerUsers = [];
    @track normalUsers = [];
    @track selectedAction = '';
    @track selectedRoute = '';
    @track selectedNormalUser = '';
    @track selectedManagerUser = '';
    @track comments = '';
    @track orderNumber = '';
    @track secondarySearchTerm = '';
    @track data = [];
    @track columns = [
        {label: 'Item Number', fieldName: 'Item_Number__c'},
        {label: 'Description', fieldName: 'Description'},
        {label: 'Description 2', fieldName: 'Description_2__c'},
        {label: 'Quantity', fieldName: 'Quantity'},
    ];
    
    
    @api recordId;

    handleRowAction(event){
        console.log(event);
    }
    
    connectedCallback(){
        
        getQuoteStatus({QuoteId: this.recordId}).then(data =>{
            if (data == 'Draft'){
                this.actionTypes = 
                [
                    { label: 'Custom Part Number Request', value: 'Custom Part Number Request'},
                ];   
            }
            else
            {
                this.actionTypes = 
                [
                    { label: 'Custom Part Number Request', value: 'Custom Part Number Request'},
                    { label: 'Sign Schedule Change Request', value: 'Sign Schedule Change Request'},
                    { label: 'Illustration Change Request', value: 'Illustration Change Request'}
                ];
            }
            getQuoteName({QuoteId: this.recordId}).then(data =>{
                this.quoteName = data;
            }).catch(error => {            
                var json = JSON.stringify(error);
                console.log("Error getting quote data: " + json);
            });
            getQuoteLineItemsWithSignSchedules({QuoteId: this.recordId}).then(data=>{
                this.data = JSON.parse(data);
                console.log(JSON.parse(data));
            }).catch(error =>{
                console.log(error);
            });
            getUsers().then(data =>{
                var results = JSON.parse(data);
                var userArray = [];
                results.forEach(user => {
                    //console.log(user);
                    userArray.push(
                        { 
                            value: String(user.Id), 
                            label: String(user.FirstName + ' ' + user.LastName)
                        });
                });
                this.normalUsers = userArray;
                this.managerUsers = userArray;
                this.loaded = true;
            }).catch(error => {
                
                var json = JSON.stringify(error);            
                console.log("Error getting user data: " + json);
            });
        });
    };

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleUserSearch(event) {
        console.log('handleUserSearch start');
        const target = event.target;
        console.log(event.detail);
        userSearch(event.detail)
            .then(results => {
                console.log("User results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting users: " + error);
            });
    }

    handleLookupSelectionChange(event) {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);

            if (event.target.name == "managerUsers") {
                this.selectedManagerUser = id;
            }
            else if (event.target.name == "normalUsers") {
                this.selectedNormalUser = id;
            }
        }
    }

    handleUpdateInput(event){
        //console.log(event.target.name);
        //console.log(event.target.value);
        if (event.target.name == "action")
        {
            this.selectedAction = event.target.value;
            //Reset values
            this.isDefaultAction = false;
            this.isCustomPartNumberRequest = false;
            this.isSignScheduleChangeRequest = false;
            this.isIllustrationChangeRequest = false;

            
            if (event.target.value == 'Custom Part Number Request')
            {
                this.isCustomPartNumberRequest = true;
            }
            else if (event.target.value == 'Sign Schedule Change Request')
            {
                this.isSignScheduleChangeRequest = true;
            }
            else if (event.target.value == 'Illustration Change Request')
            {
                this.isIllustrationChangeRequest = true;
            }
            else{
                this.isDefaultAction = true;
            }
        }
        else if (event.target.name == "orderNumber")
        {
            this.orderNumber = event.target.value;
        }
        else if (event.target.name == "comments")
        {
            this.comments = event.target.value;
        }
        else if (event.target.name == "route")
        {
            this.selectedRoute = event.target.value;
        }
    };
    
    handleSubmit(event){
        this.loaded = false;
        console.log('Submit begin');

        if (this.isCustomPartNumberRequest)
        {
            createQuoteAction({
                QuoteId: this.recordId,
                Type: this.selectedAction,
                OrderNumber: this.orderNumber,
                Comments: this.comments,
                ApprovingManagerId: this.selectedManagerUser,
                RouteType: this.selectedRoute,
                AssignUserId: this.selectedNormalUser
            }).then(data => {
                var task = JSON.parse(data);
                console.log(data);
                //Notify assigned user
                notifyUsers({
                    recipientsIds: [this.selectedNormalUser], 
                    targetId: task.Id, 
                    title: task.Subject, 
                    body: 'A new quote action task has been assigned to you.'
                });
    
                //Notify assigned manager
                notifyUsers({
                    recipientsIds: [this.selectedManagerUser], 
                    targetId: task.Id, 
                    title: task.Subject, 
                    body: 'A new quote action task has been assigned to another user. You\'ve been assigned as the manager.'
                });
                
                //Toast success
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Quote Action Request was submitted.',
                    variant: 'success'
                  }));
                  this.closeQuickAction();
                this.loaded = true;
            }).catch(data => {
                console.log(data);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data.body.message,
                    variant: 'warning'
                })); 
            }).finally(data => {
                this.loaded = true;
            });
        }
        else if (this.isSignScheduleChangeRequest)
        {
            createSignScheduleChangeRequest({ 
                QuoteId: this.recordId,
                OrderNumber: this.orderNumber,
                Comments: this.comments
            }).then(data =>{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: data,
                    variant: 'success'
                  }));
                  this.closeQuickAction();
            }).catch(data => {
                console.log(data);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data.body.message,
                    variant: 'warning'
                })); 
            }).finally(data => {
                this.loaded = true;
            });
        }
        else if (this.isIllustrationChangeRequest)
        {
            var el = this.template.querySelector('lightning-datatable');
            var selected = el.getSelectedRows();

            //Create quotelineitemids__c value here
            var selectedStr = '';
            for(var i = 0; i < selected.length; i++)
            {
                if (selectedStr == '') selectedStr = selected[i]["Id"];
                else selectedStr += ',' + selected[i]["Id"];
            }

            createIllustrationChangeRequest({
                QuoteId: this.recordId,
                OrderNumber: this.orderNumber,
                Comments: this.comments,
                Selected: selectedStr
            }).then(data =>{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: data,
                    variant: 'success'
                  }));
                  this.closeQuickAction();
            }).catch(data => {
                console.log(data);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: data.body.message,
                    variant: 'warning'
                })); 
            }).finally(data => {
                this.loaded = true;
            });
        }
    };
}