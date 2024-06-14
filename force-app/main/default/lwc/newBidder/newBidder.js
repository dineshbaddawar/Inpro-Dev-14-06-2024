import {
    LightningElement,
    api,
    track
} from 'lwc';

import GetCurrentUser from '@salesforce/apex/NewBidderHelper.GetCurrentUser';
import GetAccountsOnConstructionProject from '@salesforce/apex/NewBidderHelper.GetAccountsOnConstructionProject';
import GetContactsFromAccounts from '@salesforce/apex/NewSampleRequestHelper.GetContactsFromAccounts';
import GetDivisionPicklist from '@salesforce/apex/NewBidderHelper.GetDivisionPicklist';
import GetDivSectionPicklist from '@salesforce/apex/NewBidderHelper.GetDivSectionPicklist';
import GetPricingGroupPicklist from '@salesforce/apex/NewBidderHelper.GetPricingGroupPicklist';
import GetSourcePicklist from '@salesforce/apex/NewBidderHelper.GetSourcePicklist';
import GetInstallationTypePicklist from '@salesforce/apex/NewBidderHelper.GetInstallationTypePicklist';
import GetQuoteStatusPicklist from '@salesforce/apex/NewBidderHelper.GetQuoteStatusPicklist';
import CreateBidder from '@salesforce/apex/NewBidderHelper.CreateBidder';
import AccountSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountSearch';
import ContactSearch from '@salesforce/apex/AccountNewOpportunityHelper.ContactSearch';
import GetAccountSearch from '@salesforce/apex/NewBidderHelper.GetAccountSearch';
import CreateContact from '@salesforce/apex/NewBidderHelper.CreateContact';
import userId from '@salesforce/user/Id';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';


export default class NewBidder extends LightningElement {
    @api recordId;
    @track isMain = true;
    @track loaded = false;
    
    @track accountList = [];
    @track selectedAccount;
    @track isSearchValue = false;
    @track accountSelection = {};
    @track selectedContact;
    @track divisionTable;
    @track selectedDivisionTable = [];
    @track divSectionList;
    @track selectedDivSection;
    @track selectedPricingGroup;
    @track selectedQuoteStatus;
    @track selectedSource;
    @track selectedInstallationType;
    @track quoteBidRequestDate = new Date().toISOString();
    @track quoteBidDueDate;
    @track isClickezeSelected;
    @track contactList;
    @track pricingGroupList;
    @track quoteStatusList;
    @track sourceList;
    @track installationTypeList;
    @track divisionColumns= [
        {label: 'Division',fieldName: 'Name'},
    ];

    @track isSearch = false;
    @track searchTitle = '';
    @track searchTable = [];
    @track searchColumns = [];
    @track searchSelectedRows = [];

    @track isNewContactActive = false;
    @track isNewContact = false;
    @track contactFirstName;
    @track contactLastName;
    @track contactEmail;
    @track contactOwner;
    @track contactAccountName;

    connectedCallback(){
        GetCurrentUser({userId: userId}).then(results=>{
            this.contactOwner = results.Name;
        }).catch(error => {
            this.handleError(error);
        });

        GetAccountsOnConstructionProject({recordId: this.recordId}).then(data =>{
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: x.Id,
                    label: x.Name
                });
            });
            this.accountList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetDivisionPicklist().then(data =>{
            this.divisionTable = data;
        }).catch(error => {
            this.handleError(error);
        });

        GetDivSectionPicklist().then(data =>{
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.divSectionList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetPricingGroupPicklist().then(data =>{
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.pricingGroupList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetSourcePicklist().then(data =>{
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.sourceList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetInstallationTypePicklist().then(data =>{
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.installationTypeList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetQuoteStatusPicklist().then(data =>{
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: x,
                    label: x
                });
            });
            this.quoteStatusList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        this.loaded = true;
    }

    @track isDelayed = null;
    handleDelayInput(event)
    {
        const value = event.target.value;
        this.searchInput = value;
        const ev = () => {
            console.log('Search input is ' + this.searchInput);
            if (this.searchInput !== undefined && this.searchInput !== '')
            {
                this.loaded = false;
                GetAccountSearch({input: value})
                    .then(results => {
                        var tempArray = [];
                        results.forEach(x => {
                            x.Territory_Lookup_Name = x.Territory_Lookup__r != undefined && x.Territory_Lookup__r != null ? x.Territory_Lookup__r.Name : '';
                            x.RecordType_Name = x.RecordType != undefined&& x.RecordType != null  ? x.RecordType.Name : '';
                            x.AccountLink = window.location.origin + '/' + x.Id;
                            tempArray.push(x);
                        });
                        this.searchTable = tempArray;
                        this.selectedSearchRows = [];
                        this.loaded = true;
                    })
                    .catch(error => {
                        // TODO: handle error
                        console.log("Error getting accounts: " + error);
                        console.log(error);
                    });
            }
        };
        if (this.isDelayed){
            console.log('clear timeout');
            clearTimeout(this.isDelayed);
        }

        this.isDelayed = setTimeout(function(){
            console.log('Begin search')
            ev();
            isDelayed = null;
        }, 500);
    }

    handleSearchInput(event){
        const name = event.target.name;
        if (name == 'searchTable')
        {
            const selectedRows = event.detail.selectedRows;
            this.isMain = true;
            this.isSearch = false;
            console.log(selectedRows[0]);
            this.selectedAccount = selectedRows[0].Id;
            this.isNewContactActive = true;
            this.isSearchValue = true;
            this.accountSelection = {
                id: selectedRows[0].Id,
                sObjectType: 'Account',
                icon: 'standard:account',
                title:  selectedRows[0].Name,
                subtitle:  selectedRows[0].Customer_Number__c
            };
            console.log('Did the thing...');
            this.handleContactListUpdate();
        }
        else if (name == 'searchInput')
        {
            if (this.searchInput !== undefined && this.searchInput !== '')
            {
                this.loaded = false;
                GetAccountSearch({input: this.searchInput})
                .then(results => {
                    var tempArray = [];
                    results.forEach(x => {
                        x.Territory_Lookup_Name = x.Territory_Lookup__r != undefined ? x.Territory_Lookup__r.Name : '';
                        x.RecordType_Name = x.RecordType != undefined ? x.RecordType.Name : '';
                        x.AccountLink = window.location.origin + '/' + x.Id;
                        tempArray.push(x);
                    });
                    this.searchTable = tempArray;
                    this.selectedSearchRows = [];
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    console.log("Error getting accounts: " + error);
                    console.log(error);
                });
            }
        }
    }
    
    handleContactSave()
    {
        this.loaded = false;
        CreateContact({
            firstName: this.contactFirstName,
            lastName: this.contactLastName,
            email: this.contactEmail,
            ownerId: userId,
            accountId: this.selectedAccount
        }).then(results =>{
            if (results.indexOf('Error!') == -1)
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'Contact created.',
                    variant: 'success'
                }));
                this.contactList.push({
                    label: '(NEW) ' + this.contactFirstName + ' ' + this.contactLastName,
                    value: results
                });
                this.selectedContact = results;
                this.isNewContact = false;
                this.isMain = true;
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error on contact creation!',
                    message: results,
                    variant: 'warning'
                }));
            }
            this.loaded = true;
        })
    }

    handleSave(){
        if (this.selectedDivisionTable.length == 0)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Please select a division.',
                variant: 'warning'
            }));
        }
        else
        {
            this.loaded = false;
            var params = {
                constructionProjectId: this.recordId,
                accountId: this.selectedAccount,
                contactId: this.selectedContact,
                pricingGroup: this.selectedPricingGroup,
                quoteStatus: this.selectedQuoteStatus,
                source: this.selectedSource,
                installationType: this.selectedInstallationType,
                quoteBidRequestDate: this.quoteBidRequestDate,
                quoteBidDueDate: this.quoteBidDueDate,
                divisions: this.selectedDivisionTable,
                divSection: this.selectedDivSection
            };
            console.log(params)
            
            CreateBidder(params).then(results =>{
                if (results[0] == 'Failure')
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error on bidder creation!',
                        message: results[1] + '\r\n' + results[2],
                        variant: 'warning'
                    }));
                }
                else{
                    if (results.length > 1)
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: 'Bidder was created for multiple divisions.',
                            variant: 'success'
                        }));
                    }
                    else
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success!',
                            message: 'Bidder was created! {1}.',
                            variant: 'success',
                            "messageData": [
                                'Salesforce',
                                {
                                    url: window.location.protocol + '//' + window.location.host + '/lightning/r/Bidder__c/' + results[0] + '/view',
                                    label: 'Click here to navigate to new bidder'
                                }
                            ]
                        }));
                    }
                    this.closeQuickAction();
                }
                this.loaded = true;
            }).catch(error => {
                this.handleError(error);
            });
        }
    }

    handleContactStart(){
        this.isMain = false;
        this.isNewContact = true;
        this.contactAccountName = this.accountSelection != undefined && this.accountSelection.title != undefined ? this.accountSelection.title : '';
    }

    @track currentSearchValue = '';

    handleAccountSearch(event) {
        const target = event.target;
        console.log('event details:');
        console.log(event.detail.searchTerm);
        this.searchInput = event.detail.searchTerm;
        AccountSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
                console.log(error);
            });
    };

    handleContactSearch(event) {
        const target = event.target;
        console.log(event.detail);
        ContactSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
                console.log(error);
            });
    };

    handleInput(event){
        const name = event.target.name;
        const value = event.target.value;

        if (name == 'selectedContact')
        {
            this.selectedContact = value;
        }
        else if (name == 'selectedDivSection')
        {
            this.selectedDivSection = value;
        }
        else if (name == 'selectedPricingGroup')
        {
            this.selectedPricingGroup = value;
        }
        else if (name == 'selectedQuoteStatus')
        {
            this.selectedQuoteStatus = value;
        }
        else if (name == 'selectedSource')
        {
            this.selectedSource = value;
        }
        else if (name == 'selectedInstallationType')
        {
            this.selectedInstallationType = value;
        }
        else if (name == 'selectedDivSection')
        {
            this.selectedDivSection = value;
        }
        else if (name == 'quoteBidRequestDate')
        {
            this.quoteBidRequestDate = value;
        }
        else if (name == 'quoteBidDueDate')
        {
            this.quoteBidDueDate = value;
        }
        else if (name == 'contactFirstName')
        {
            this.contactFirstName = value;
        }
        else if (name == 'contactLastName')
        {
            this.contactLastName = value;
        }
        else if (name == 'contactEmail')
        {
            this.contactEmail = value;
        }
    }

    handleLookupSelectionChange(event){

        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);

            if (event.target.name == "selectedAccount") 
            {
                this.selectedAccount = id;
                this.isNewContactActive = true;
                this.isSearchValue = true;
                this.accountSelection = {
                    id: id,
                    sObjectType: 'Account',
                    icon: 'standard:account',
                    title:  name,
                    subtitle:  subTitle
                };
                this.handleContactListUpdate();
            }
        }
    }

    handleSearchCancel(){
        this.isMain = true;
        this.isSearch = false;
        this.isNewContact = false;
    }

    handleSearchKeyDown(event){
        if (event.keyCode == 13 && event.target.name == 'selectedAccount'){
            //open bidder advanced search
            this.handleStartSearch();
        }
    }

    handleStartSearch()
    {
        console.log('Value for advanced search: ' + this.searchInput);
        
        this.searchColumns = [
            {
                label: 'Account Name', 
                fieldName: 'AccountLink', 
                type: 'url', 
                initialWidth: 200, 
                sortable: true, 
                typeAttributes: 
                {
                    label: 
                    { 
                        fieldName: 'Name' 
                    },
                    target: '_blank'
                }
            },
            {label: 'Inactive',fieldName: 'Inactive__c'},
            {label: 'Customer Number',fieldName: 'Customer_Number__c'},
            {label: 'Territory',fieldName: 'Territory_Lookup_Name'},
            {label: 'Phone',fieldName: 'Phone'},
            {label: 'Type',fieldName: 'RecordType_Name',initialWidth: 150, },
            {label: 'Street',fieldName: 'ShippingStreet'},
            {label: 'City',fieldName: 'ShippingCity'},
            {label: 'State',fieldName: 'ShippingState'},
            {label: 'Zip',fieldName: 'ShippingPostalCode'}
        ];
        this.selectedSearchRows = [];
                
        if (this.searchInput !== undefined && this.searchInput !== '')
        {
            this.loaded = false;
            GetAccountSearch({input: this.searchInput})
            .then(results => {
                results.forEach(x => {
                    x.Territory_Lookup_Name = x.Territory_Lookup__r != undefined ? x.Territory_Lookup__r.Name : '';
                    x.RecordType_Name = x.RecordType != undefined ? x.RecordType.Name : '';
                    x.AccountLink = window.location.origin + '/' + x.Id;
                });
                this.searchTable = results;
                console.log(results);
                
                this.searchTitle = 'Bidder Search';
                this.isMain = false;
                this.isSearch = true;
                this.loaded = true;
            }).catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
                console.log(error);
            });
        }
        else
        {
            this.searchTitle = 'Bidder Search';
            this.isMain = false;
            this.isSearch = true;
        }
    }

    handleContactListUpdate(){
        var params = {
            accountId: this.selectedAccount,
            opportunityId: ''
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
                    label: String(x.Name)
                });
                if (x.Id == tempSelectedContact) this.selectedContact = tempSelectedContact;
            });

            this.contactList = tempArray;

        }).catch(error => {
            this.handleError(error);
        });
    }

    handleDataTableInput(event){
        const selectedRows = event.detail.selectedRows;
        this.isClickezeSelected = false;
        if (event.target.name == 'divisionTable')
        {
            var tempArray = [];
            for (let i = 0; i < selectedRows.length; i++) {
                tempArray.push(selectedRows[i].Id);
                if (selectedRows[i].Name == 'Clickeze')
                {
                    this.isClickezeSelected = true;
                }
            }
            this.selectedDivisionTable = tempArray;
        }
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