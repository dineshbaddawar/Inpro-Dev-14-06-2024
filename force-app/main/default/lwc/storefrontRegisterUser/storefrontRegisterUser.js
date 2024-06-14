import {
    LightningElement,
    api
} from 'lwc';
import registerStoreFrontUser from '@salesforce/apex/EcomRegisterUserHelper.registerStoreFrontUser';
import userId from '@salesforce/user/Id';
import contactSearch from '@salesforce/apex/EcomRegisterUserHelper.contactSearch';
import getStoreFrontAccounts from '@salesforce/apex/EcomRegisterUserHelper.getStoreFrontAccounts';
import getCustomerAccounts from '@salesforce/apex/EcomRegisterUserHelper.getCustomerAccounts';
import callWebsiteRegisterAPI from '@salesforce/apex/EcomRegisterUserHelper.callWebsiteRegisterAPI';

export default class StoreFrontRegisterUser extends LightningElement {

    @api recordId;
    loaded = true;
    Response = '';
    contactId;
    customerAccountId;
    storeFrontAccountId;
    selectedContact = {};
    accountList = [];
    customerAccountList = [];

    connectedCallback() {
        this.callGetStoreFrontAccounts();
    }

    callGetStoreFrontAccounts() {
        try {
            getStoreFrontAccounts().then(data => {
                    try {
                        if (data) {
                            console.log(data);
                            var dataArray = JSON.parse(data);
                            dataArray.forEach(storefront => {
                                var option = {
                                    label: storefront.Name + ' (' + storefront.Customer_Number__c + ')',
                                    value: storefront.Id
                                };
                                this.accountList = [...this.accountList, option];
                            });
                            this.loaded = true;
                            
                        }
                    } catch (error) {
                        var errorJSON = JSON.stringify(error);
                        console.log(errorJSON);
                    }
                })
                .catch(error => {
                    // TODO: handle error                
                    var errorJSON = JSON.stringify(error);
                    console.log("Error getting storefront accounts: " + errorJSON);
                });

        } catch (error) {
            var erJSON = JSON.stringify(error);
            console.log("Error getting storefront accounts: " + erJSON);
        }
    }

    callGetCustomerAccounts() {
        try {
            this.customerAccountList = [];
            getCustomerAccounts({
                    contactId: this.contactId
                }).then(data => {
                    try {

                        if (data) {
                            console.log(data);
                            data.forEach(storefront => {
                                var option = {
                                    label: storefront.Account.Name + ' (' + storefront.Account.Customer_Number__c + ')',
                                    value: storefront.AccountId
                                };
                                this.customerAccountList = [...this.customerAccountList, option];
                            });
                            this.loaded = true;
                        }
                    } catch (error) {
                        var errorJSON = JSON.stringify(error);
                        console.log(errorJSON);
                    }
                })
                .catch(error => {
                    // TODO: handle error                
                    var errorJSON = JSON.stringify(error);
                    console.log("Error getting customer accounts: " + errorJSON);
                });

        } catch (error) {
            var erJSON = JSON.stringify(error);
            console.log("Error getting customer accounts: " + erJSON);
        }

    }

    handleRegisterUserClick() {
        this.callRegisterUser();
    }

    callRegisterUser() {

        try {
            this.loaded = false;
            console.log("contactId: " + this.contactId);
            console.log("userId: " + userId);
            console.log("sf account: " + this.storeFrontAccountId);
            console.log("customeraccountid: " + this.customerAccountId);
            registerStoreFrontUser({
                storeFrontId: this.storeFrontAccountId,
                contactId: this.contactId,
                customerAccountId: this.customerAccountId,
                    userId: userId
                }).then(data => {
                    if (data) {

                        var sfId = data;
                        console.log(sfId);
                        callWebsiteRegisterAPI({
                                storeFrontId: sfId,                                                        
                                userId: userId
                            }).then(data => {
                                if (data) {            
                                    this.Response = data;            
                                    this.loaded = true;
                                }
                            })
                            .catch(error => {
                                // TODO: handle error                
                                var errorJSON = JSON.stringify(error);
                                console.log("Error registering api user: " + errorJSON);
                                this.loaded = true;
                            });

                        this.loaded = true;
                    }
                })
                .catch(error => {
                    // TODO: handle error                
                    var errorJSON = JSON.stringify(error);
                    console.log("Error registering user: " + errorJSON);
                    this.loaded = true;
                });

        } catch (error) {
            var erJSON = JSON.stringify(error);
            console.log("Error calling register user: " + erJSON);
        }
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
        }
        console.log(event.target.name);
        console.log(name);
        console.log(id);
        this.contactId = id;
        this.callGetCustomerAccounts();
    }

    handleContactSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        contactSearch(event.detail)
            .then(results => {
                console.log("Account results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
            });
    }

    handleInputUpdate(event) {
        
        if (event.target.name == "CustomerAccount") {
            this.customerAccountId = event.target.value;
            console.log("CustomerAccount:");
        }
        if (event.target.name == "StoreFrontAccount") {
            this.storeFrontAccountId = event.target.value;
            console.log("StoreFrontAccount:");
        }
        console.log(event.target.value);
    }
}