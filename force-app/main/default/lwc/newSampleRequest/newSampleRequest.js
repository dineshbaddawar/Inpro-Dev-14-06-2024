import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import AccountSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountSearch';
import OpportunitySearch from '@salesforce/apex/NewSampleRequestHelper.OpportunitySearch';
import GetDesiredShippingMethodPicklist from '@salesforce/apex/NewSampleRequestHelper.GetDesiredShippingMethodPicklist';
import GetShipToPicklist from '@salesforce/apex/NewSampleRequestHelper.GetShipToPicklist';
import GetTypePicklist from '@salesforce/apex/NewSampleRequestHelper.GetTypePicklist';
import GetAccountName from '@salesforce/apex/NewSampleRequestHelper.GetAccountName';
import GetOpportunity from '@salesforce/apex/NewSampleRequestHelper.GetOpportunity';
import CreateSampleRequest from '@salesforce/apex/NewSampleRequestHelper.CreateSampleRequest';
import GetContactsFromAccounts from '@salesforce/apex/NewSampleRequestHelper.GetContactsFromAccounts';
import GetAddress from '@salesforce/apex/NewSampleRequestHelper.GetAddress';
import GetContactDetails from '@salesforce/apex/NewSampleRequestHelper.GetContactDetails';
import GetLeadDetails from '@salesforce/apex/NewSampleRequestHelper.GetLeadDetails';
//import CheckDeniedPartyStatus from '@salesforce/apex/DeniedPartyHelper.CheckDeniedPartyStatus';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';


export default class NewSampleRequest extends LightningElement
{
    @api recordId;
    @api objectApiName;

    @track loaded = false;
    @track IsAccountSearchable = false;
    @track IsContact = false;
    @track IsContactRequired = true;
    @track IsOpportunity = false;
    @track IsLead = false;
    @track accountIsDeniedParty = false;

    @track selectedAccount = '';
    @track selectedContact = '';
    @track selectedOpportunity = '';
    @track selectedLead = '';

    @track AccountName = '';
    @track ContactName = '';
    @track OpportunityName = '';
    @track LeadName = '';

    @track desiredShippingMethodList = [];
    @track selectedDesiredShippingMethod;
    @track shipToList = [];
    @track selectedShipTo;
    @track typeList = [];
    @track selectedType;
    @track contactList = [];
    
    @track IsManualAddress = false;
    @track addressStreet = '';
    @track addressCity = '';
    @track addressState = '';
    @track addressZip = '';
    @track addressCountry = '';
    
    connectedCallback(){
        if (this.recordId.substring(0,3) == '001') //Account
        {
            this.IsAccountSearchable = false;
            this.selectedAccount = this.recordId;
            //this.checkAccountDeniedParty();
            GetAccountName({recordId: this.recordId}).then(name =>{
                this.AccountName = name;
            }).catch(error => {
                this.handleError(error);
            });
        }
        else if (this.recordId.substring(0,3) == '006') //Opportunity
        {
            this.IsOpportunity = true;
            this.IsAccountSearchable = false;
            this.selectedOpportunity = this.recordId;
            GetOpportunity({recordId: this.recordId}).then(opp =>{
                this.OpportunityName = opp.Name;
                if (opp.AccountId != null)
                {
                    this.selectedAccount = opp.AccountId;
                    this.AccountName = opp.Account.Name;
                    //this.checkAccountDeniedParty();
                }
                if (opp.Converted_Lead__c != null)
                {
                    this.selectedLead = opp.Converted_Lead__c;
                }
            }).catch(error => {
                this.handleError(error);
            });
        }
        else if (this.recordId.substring(0,3) == '003') //Contact
        {
            console.log('Is Contact');
            this.IsContact = true;
            this.IsAccountSearchable = false;
            this.selectedContact = this.recordId;
            this.selectedShipTo = 'Contact - Contact\'s Address';
            GetContactDetails({recordId: this.recordId}).then(con =>{
                this.AccountName = con.Account.Name;
                this.ContactName = con.Name;
                this.selectedAccount = con.AccountId;
                if (con.Lead__c != null)
                {
                    this.selectedLead = con.Lead__c;
                }
                this.updateAddress();
                //if(this.selectedAccount != null && this.selectedAccount != '')
                //   this.checkAccountDeniedParty();
            }).catch(error => {
                this.handleError(error);
            });
        }
        else if (this.recordId.substring(0,3) == '00Q') //Lead
        {
            console.log('Is Lead');
            this.IsAccountSearchable = true;
            this.IsLead = true;
            this.IsContactRequired = false;
            this.selectedLead = this.recordId;
            this.selectedShipTo = 'Lead - Mailing';
            GetLeadDetails({recordId: this.recordId}).then(lead =>{
                this.LeadName = lead.Name;
                this.updateAddress();
            }).catch(error => {
                this.handleError(error);
            });
        }

        this.handleContactListUpdate();
        
        GetDesiredShippingMethodPicklist().then(results => {
            var tempArray = [];
            console.log(results);
            results.forEach(x => {
                tempArray.push({
                    value: x.split('|')[0],
                    label: x.split('|')[1]
                });
            });
            this.desiredShippingMethodList = tempArray;
            this.selectedDesiredShippingMethod = 'UPS Ground';
        }).catch(error => {
            this.handleError(error);
        });

        GetShipToPicklist().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.split('|')[0],
                    label: x.split('|')[1]
                });
            });
            this.shipToList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetTypePicklist().then(results => {
            var tempArray = [];
            results.forEach(x => {
                if (x.indexOf('Web Request') === -1)
                {
                    tempArray.push({
                        value: x.split('|')[0],
                        label: x.split('|')[1]
                    });
                }
            });
            this.typeList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });
        
        if(this.accountIsDeniedParty == false)
            this.loaded = true;
    }

    checkAccountDeniedParty()
    {
        CheckDeniedPartyStatus({
            accountId: this.selectedAccount
        }).then(data => {
                if (data) {                 
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    if(data.isAccountBlocked || data.hasRetrievalErrorOccurred)
                    {
                        this.accountIsDeniedParty = true;
                        this.handleError(data.message);
                        //this.loaded = true; 
                        this.loaded = false; //needed for hard stop
                    }
                    else
                        this.loaded = true;            
                } else if (error) {
                    this.handleError(error);
                    this.loaded = true;
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                this.Response = "Error checking denied party status: " + errorJSON;
                console.log("Error checking denied party status: " + errorJSON);
                this.loaded = true;
            });
    }

    handleSave(){
        this.loaded = false;
        var params = {
            accountId: this.selectedAccount,
            opportunityId: this.selectedOpportunity,
            contactId: this.selectedContact,
            leadId: this.selectedLead,
            desiredShippingMethod: this.selectedDesiredShippingMethod,
            shipTo: this.selectedShipTo,
            sampleType: this.selectedType,
            addressStreet: this.addressStreet,
            addressCity: this.addressCity,
            addressState: this.addressState,
            addressZip: this.addressZip,
            addressCountry: this.addressCountry
        };
        console.log(params);

        CreateSampleRequest(params).then(results =>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Sample Request was created! {1}.',
                variant: 'success',
                mode: 'sticky',
                "messageData": [
                    'Salesforce',
                    {
                        url: window.location.protocol + '//' + window.location.host + '/lightning/r/Sample_Request__c/' + results + '/view',
                        label: 'Click here to navigate to new sample request'
                    }
                ]
            }));
            this.loaded = true;
            this.closeQuickAction();
        }).catch(error => {
            this.handleError(error);
        });
    }

    handleInput(event){
        let name = event.target.name;
        let value = event.target.value;
        if (name == 'selectedDesiredShippingMethod'){
            this.selectedDesiredShippingMethod = value;
        }
        else if (name == 'selectedShipTo'){
            this.selectedShipTo = value;
            
            if (this.selectedShipTo.indexOf('Other') != -1 || this.selectedShipTo.indexOf('Europe') != -1)
            {
                this.IsManualAddress = true;
            }
            else{
                this.IsManualAddress = false;
                this.updateAddress();
            }
        }
        else if (name == 'selectedContact'){
            this.selectedContact = value;
            if (this.selectedShipTo != undefined && this.selectedShipTo.indexOf('Contact') != -1)
            {
                this.updateAddress();
            }
        }
        else if (name == 'selectedType'){
            this.selectedType = value;
            
        }
        else if (name == 'addressStreet')
        {
            this.addressStreet = value;
        }
        else if (name == 'addressCity')
        {
            this.addressCity = value;
        }
        else if (name == 'addressState')
        {
            this.addressState = value;
        }
        else if (name == 'addressZip')
        {
            this.addressZip = value;
        }
        else if (name == 'addressCountry')
        {
            this.addressCountry = value;
        }
    }

    updateAddress(){
        var params = {
            shipTo: this.selectedShipTo,
            accountId: this.selectedAccount,
            contactId: this.selectedContact,
            leadId: this.selectedLead
        }
        console.log(params);
        GetAddress(params).then(results =>
        {
            console.log(results);
            if (results.length != 0)
            {
                this.addressStreet = results[0];
                this.addressCity = results[1];
                this.addressState = results[2];
                this.addressZip = results[3];
                this.addressCountry = results[4];
            }
        }).catch(error => {
            this.handleError(error);
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

            if (event.target.name == "selectedAccount") {
                this.selectedAccount = id;
                this.handleContactListUpdate();
            } else if (event.target.name == "selectedContact") {
                this.selectedContact = id;
            } else if (event.target.name == "selectedOpportunity") {
                this.selectedOpportunity = id;
                this.handleContactListUpdate();
            } 
        }
    }

    handleAccountSearch(event) {
        const target = event.target;
        console.log(event.detail);
        AccountSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
            });
    };

    handleContactListUpdate() {
        if (this.IsContact)
        {
            return;
        }

        var params = {
            accountId: this.selectedAccount,
            opportunityId: this.selectedOpportunity
        };
        console.log(params);

        GetContactsFromAccounts(params).then(results => {
            console.log(results);
            var tempArray = [];
            this.contactList = [];
            var tempSelectedContact = this.selectedContact;
            this.selectedContact = '';
            results.forEach(x => {
                tempArray.push({
                    value: String(x.Id),
                    label: String(x.Name) + ' (' + String(x.Account.Name) + ' #' + x.Account.Customer_Number__c + ')'
                });
                if (x.Id == tempSelectedContact) this.selectedContact = tempSelectedContact;
            });

            this.contactList = tempArray;

        }).catch(error => {
            this.handleError(error);
        });
    }

    handleOpportunitySearch(event) {
        const target = event.target;
        console.log(event.detail);
        OpportunitySearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting opportunities: " + error);
            });
    };

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } 
        else if (error.body !== undefined && error.body.fieldErrors !== undefined && Object.keys(error.body.fieldErrors).length > 0) {
            let keys = Object.keys(error.body.fieldErrors);
            let errorMessage = '';
            for(var i = 0; i < keys.length; i++)
            {
                errorMessage += error.body.fieldErrors[keys[i]][0].message + ' ';
            }

            this.dispatchEvent(new ShowToastEvent({
                title: 'Field Validation Error!',
                message: errorMessage,
                variant: 'warning'
            }));
        } 
        else if (error.body !== undefined && error.body.message !== undefined)
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