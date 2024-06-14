import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import GetCountries from '@salesforce/apex/AccountNewOpportunityHelper.GetCountries';
import GetStates from '@salesforce/apex/AccountNewOpportunityHelper.GetStates';
import GetAccountAddress from '@salesforce/apex/AccountUpdateAddressHelper.GetAccountAddress';
import GetContacts from '@salesforce/apex/AccountUpdateAddressHelper.GetContacts';
import UpdateShippingAddress from '@salesforce/apex/AccountUpdateAddressHelper.UpdateShippingAddress';
import UpdateContacts from '@salesforce/apex/AccountUpdateAddressHelper.UpdateContacts';

export default class AccountUpdateAddress extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track shippingStreet;
    @track shippingCity;
    @track shippingState;
    @track shippingZip;
    @track shippingCountry;
    @track shippingStateList = [];
    @track countryList = [];
    @track contactList = [];
    @track syncAddressList = [];
    @track syncPhoneList = [];
    @track syncAddressToAll = false;
    @track syncPhoneToAll = false;

    connectedCallback(){
        GetContacts({accountId: this.recordId}).then(data =>{
            console.log(data);
            this.contactList = data;
        }).catch(error => {
            this.handleError(error);
        });

        GetCountries().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.split('|')[0],
                    label: x.split('|')[0]
                });
            });
            this.countryList = tempArray;
            this.addressCountry = 'United States';
            GetAccountAddress({recordId: this.recordId}).then(account =>{
                this.accountPhone = account.Phone;
                GetStates({
                    country: (account.ShippingCountry != undefined && account.ShippingCountry != null ? account.ShippingCountry : 'United States')
                }).then(results => {
                    var tempArray = [];
                    results.forEach(x => {
                        tempArray.push({
                            value: x.split('|')[0],
                            label: x.split('|')[0]
                        });
                    });
                    this.shippingStateList = tempArray;
                    this.shippingStreet = account.ShippingStreet;
                    this.shippingCity = account.ShippingCity;
                    this.shippingState = account.ShippingState;
                    this.shippingZip = account.ShippingPostalCode;
                    this.shippingCountry = account.ShippingCountry;
                    this.loaded = true;
                }).catch(error => {
                    this.handleError(error);
                });
            });
        }).catch(error => {
            this.handleError(error);
        });

    }

    handleInput(event){
        const name = event.target.name;
        const value = event.target.value;

        if (name == 'shippingStreet')
        {
            this.shippingStreet = value;
        } 
        else if (name == 'shippingCity')
        {
            this.shippingCity = value;
        }
        else if (name == 'shippingState')
        {
            this.shippingState = value;
        } 
        else if (name == 'shippingZip')
        {
            this.shippingZip = value;
        }
        else if (name == 'shippingCountry')
        {
            this.shippingCountry = value;
            GetStates({
                country: value
            }).then(results => {
                console.log(results);
                var tempArray = [];
                results.forEach(x => {
                    tempArray.push({
                        value: x.split('|')[0],
                        label: x.split('|')[0]
                    });
                });
                this.shippingStateList = tempArray;
            }).catch(error => {
                this.handleError(error);
            });
        } 
        else if (name == 'accountPhone')
        {
            this.accountPhone = value;
        }
    }

    handleOptionChecked(event) {
        try {
            console.log(event.target.name);
            const name = event.target.name;
            var isChecked = event.target.checked;

            if (name == 'syncAddressToAll')
            {
                this.syncAddressToAll = isChecked;
                this.syncAddressList = [];
                var tempList = this.contactList;
                this.contactList = [];
                for(var i = 0; i < tempList.length; i++)
                {
                    if (isChecked) 
                    {
                        this.syncAddressList.push(tempList[i].Id);
                    }
                    tempList[i].SyncAddress = isChecked;
                }
                console.log(tempList);
                this.contactList = tempList;
            }
            else if (name == 'syncPhoneToAll')
            {
                this.syncPhoneToAll = isChecked;
                this.syncPhoneList = [];
                var tempList = this.contactList;
                this.contactList = [];
                for(var i = 0; i < tempList.length; i++)
                {
                    if (isChecked) 
                    {
                        this.syncPhoneList.push(tempList[i].Id);
                    }
                    tempList[i].SyncPhone = isChecked;
                }
                this.contactList = tempList;
            }
            else
            {
                var selectedContact = event.target.accessKey;
            
                for(var i = 0; i < this.contactList.length; i++)
                {
                    const value = this.contactList[i].Id;
                    if(this.contactList[i].Id == selectedContact)
                    {
                        if (name == 'SyncAddress')
                        {
                            if (isChecked)
                            {
                                if (this.syncAddressList.indexOf(value) == -1)
                                {
                                    this.syncAddressList.push(value);
                                    console.log('push to address ' + value);
                                }
                            }
                            else
                            {
                                if (this.syncAddressList.indexOf(value) != -1)
                                {
                                    this.syncAddressList.splice(this.syncAddressList.indexOf(value),1);
                                }
                            }
                        }
                        else if (name == 'SyncPhone')
                        {
                            if (isChecked)
                            {
                                if (this.syncPhoneList.indexOf(value) == -1)
                                {
                                    this.syncPhoneList.push(value);
                                    console.log('push to phone ' + value);
                                }
                            }
                            else
                            {
                                if (this.syncPhoneList.indexOf(value) != -1)
                                {
                                    this.syncPhoneList.splice(this.syncPhoneList.indexOf(value),1);
                                }
                            }
                        }
                        else if (name == 'Inactive')
                        {
                            this.contactList[i].Inactive_Contact__c = isChecked;
                        }
                    }
                }
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleDataTableInput(event){
        const selectedRows = event.detail.selectedRows;
        if (event.target.name == 'contactList')
        {
            var tempArray = [];
            for (let i = 0; i < selectedRows.length; i++) {
                tempArray.push(selectedRows[i].Id);
            }
            this.selectedContacts = tempArray;
        }
    }

    handleDataTableSave(event){
        const selectedRows = event.detail.selectedRows;
        if (event.target.name == 'contactList')
        {
            var tempArray = [];
            for (let i = 0; i < selectedRows.length; i++) {
                for (let j = 0; j < this.contactList.length; j++)
                {
                    if (this.contactList[j].Id == selectedRows[i].Id)
                    {
                        this.contactList[j] = selectedRows[i];
                    }
                }
                tempArray.push(selectedRows[i].Id);
            }
            this.selectedContacts = tempArray;
        }
    }

    handleSave()
    {
        const params1 = {
            accountId: this.recordId,
            shippingStreet: this.shippingStreet,
            shippingCity: this.shippingCity,
            shippingState: this.shippingState,
            shippingZip: this.shippingZip,
            shippingCountry: this.shippingCountry,
            phone: this.accountPhone
        };
        console.log(params1);

        const params2 = {
            mailingStreet: this.shippingStreet,
            mailingCity: this.shippingCity,
            mailingState: this.shippingState,
            mailingZip: this.shippingZip,
            mailingCountry: this.shippingCountry,
            contactIds: this.syncAddressList
        };
        console.log(params2);

        const params3 = {
            phone: this.accountPhone,
            contactIds: this.syncPhoneList
        };
        console.log(params3);

        this.loaded = false;
        UpdateShippingAddress(params1).then(data0 =>{
            console.log(data0);
            if (data0 != 'Success')
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error!',
                    message: data,
                    variant: 'warning'
                }));
                this.loaded = true;
            }
            else{
                for(var i = 0; i < this.contactList.length; i++)
                {
                    for (var j = 0; j < this.syncAddressList.length; j++)
                    {
                        if (this.contactList[i].Id == this.syncAddressList[j])
                        {
                            this.contactList[i].MailingStreet = this.shippingStreet;
                            this.contactList[i].MailingCity = this.shippingCity;
                            this.contactList[i].MailingState = this.shippingState;
                            this.contactList[i].MailingPostalCode = this.shippingZip;
                            this.contactList[i].MailingCountry = this.shippingCountry;
                        }
                        
                    }
                    for (var j = 0; j < this.syncAddressList.length; j++)
                    {
                        if (this.contactList[i].Id == this.syncPhoneList[j])
                        {
                            this.contactList[i].Phone = this.accountPhone;
                        }
                    }
                }
                UpdateContacts({contacts: this.contactList}).then(data =>{
                    if (data != 'Success')
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Server Error!',
                            message: data,
                            variant: 'warning'
                        }));
                        this.loaded = true;
                    }
                    else
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: 'Address has been updated and information has been synced.',
                            variant: 'success'
                        }));
                        this.loaded = true;
                        this.closeQuickAction();
                    }
                }).catch(error => {
                    this.handleError(error);
                });
            }
        }).catch(error => {
            this.handleError(error);
        });
    }

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}