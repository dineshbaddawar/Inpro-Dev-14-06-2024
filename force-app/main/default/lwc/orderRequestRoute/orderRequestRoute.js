import { LightningElement,
    api, 
    track 
} from 'lwc';

import userId from '@salesforce/user/Id';
import RouteOrderRequest from '@salesforce/apex/OrderRequestRouteHelper.RouteOrderRequest';
import RetrieveUserInfo from '@salesforce/apex/OrderRequestRouteHelper.RetrieveUserInfo';
import RetrieveRecordInfo from '@salesforce/apex/OrderRequestRouteHelper.RetrieveRecordInfo';

export default class OrderRequestRoute extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';
    @track notes = '';
    @track userName = '';
    @track orderRequestNotes = '';
    @track hasFinancePermissions = false;
    @track requiresOverContractApproval = false;
    @track createdById = '';

    connectedCallback() {
        // initialize component
        this.loaded = false;
        this.getUserInfo();
        this.getRecordInfo();
    }

    getUserInfo()
    {
        try {
            RetrieveUserInfo({
                    userId: userId
                }).then(data => {
                    data.forEach(user => {
                        if(user.Profile.Name == 'Inpro - Finance' || user.Profile.Name == 'System Administrator')
                            this.hasFinancePermissions = true;
                        if(user.Name != null)
                            this.userName = user.Name;
                    });
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error Retrieving User Info: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error retrieving user info: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    getRecordInfo()
    {
        try {
            RetrieveRecordInfo({
                    recordId: this.recordId
                }).then(data => {
                    data.forEach(record => {
                        if(record.Order_Request_Comments__c != null)
                            this.orderRequestNotes = record.Order_Request_Comments__c;
                        if(record.Requires_Over_Contract_Approval__c != null)
                            this.requiresOverContractApproval = record.Requires_Over_Contract_Approval__c;
                        if(record.CreatedById != null)
                            this.createdById = record.CreatedById;
                        this.loaded = true;
                    });
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error Retrieving Record Info: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error retrieving record info: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    routeOrderRequest(event)
    {
        this.loaded = false;
        try {
            RouteOrderRequest({
                recordId: this.recordId, 
                action: event.target.label, 
                userName: this.userName, 
                userId: userId,
                orderRequestComments: this.orderRequestNotes,
                userComments: this.notes,
                requiresOverContractApproval: this.requiresOverContractApproval,
                createdById: this.createdById
                }).then(data => {
                    this.Response = data;
                    console.log(data);
                    if(!data.toLowerCase().includes("error"))
                        document.location = location.href;
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error Routing Order Request: " + errorJson);
                    this.Response = errorJson;
                    this.loaded = true;
                });

        } catch (error) {
            var errorJson = JSON.stringify(error);
            console.log("Error routing the order request: " + errorJson);
            this.Response = errorJson;
            this.loaded = true;
        }
    }

    handleNotesOnChange(event){
        this.notes = event.target.value;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}