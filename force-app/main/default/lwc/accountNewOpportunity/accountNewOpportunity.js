import {
    LightningElement,
    api,
    track
} from 'lwc';

import GetDivisions from '@salesforce/apex/AccountNewOpportunityHelper.GetDivisions';
import AccountSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountSearch';
import AccountBuildingOwnerSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountBuildingOwnerSearch';
import AccountBuildingOwnerParentSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountBuildingOwnerParentSearch';
import ConstructionProjectSearch from '@salesforce/apex/AccountNewOpportunityHelper.ConstructionProjectSearch';
import GetMarketSegments from '@salesforce/apex/AccountNewOpportunityHelper.GetMarketSegments';
import GetSubSegmentValues from '@salesforce/apex/AccountNewOpportunityHelper.GetSubSegmentValues';
import GetDivSections from '@salesforce/apex/AccountNewOpportunityHelper.GetDivSections';
import CreateOpportunity from '@salesforce/apex/AccountNewOpportunityHelper.CreateOpportunity';
import GetContactsFromAccounts from '@salesforce/apex/AccountNewOpportunityHelper.GetContactsFromAccounts';
import GetAccountDetails from '@salesforce/apex/AccountNewOpportunityHelper.GetAccountDetails';
import GetRecordTypeWrapper from '@salesforce/apex/AccountNewOpportunityHelper.GetRecordTypeWrapper';
import GetCategories from '@salesforce/apex/AccountNewOpportunityHelper.GetCategories';
import GetLeadSources from '@salesforce/apex/AccountNewOpportunityHelper.GetLeadSources';
import GetCountries from '@salesforce/apex/AccountNewOpportunityHelper.GetCountries';
import GetStates from '@salesforce/apex/AccountNewOpportunityHelper.GetStates';
import GetParentAccountDetails from '@salesforce/apex/AccountNewOpportunityHelper.GetParentAccountDetails';
import GetConstructionProjectAccountId from '@salesforce/apex/AccountNewOpportunityHelper.GetConstructionProjectAccountId';
import GetConstructionProject from '@salesforce/apex/AccountNewOpportunityHelper.GetConstructionProject';
import GetStateCityFromZip from '@salesforce/apex/AddressValidationHelper.ZipCodeLookup';
import userId from '@salesforce/user/Id';
//import CheckDeniedPartyStatus from '@salesforce/apex/DeniedPartyHelper.CheckDeniedPartyStatus';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class AccountNewOpportunity extends LightningElement {
    @api objectApiName;
    @api recordId;

    @track loaded = false;
    @track accountId = '';
    @track categorySelectionVisible = false;
    @track marketSegmentSubSegmentVisible = false;
    @track buildingOwner;
    @track buildingOwnerSelection = {};
    @track buildingOwnerParent;
    @track buildingOwnerParentSelection = {};
    @track originalAccount;
    @track originalAccountSelection = {};
    @track constructionProject;
    @track bidderContact;
    @track bidderContactList = [];
    @track division = '';
    @track category;
    @track categoryList = [];
    @track divisionList = [];
    @track opportunityName = '';
    @track divSection = '';
    @track divSectionList = [];
    @track marketSegment = '';
    @track marketSegmentList = [];
    @track lockSegments = false;
    @track estCloseDate;
    @track subSegment = '';
    @track subSegmentList = [];
    @track oppDate = new Date().toISOString();
    @track leadSource = 'Sales';
    @track leadSourceList = [];
    @track estimateRequired = false;
    @track leadSourceDetails = '';
    @track largeProject = false;
    @track largeProjectDefinition =
        'Jobs that should be flagged as LARGE:\r\n' +
        '1. All airport, stadium, & casino projects (unless there is less than 75,000 SQFT or 50 architectural drawing pages)\r\n' +
        '2. Healthcare projects over 60,000 SQFT\r\n' +
        '3. Any type of project over 175,000 SQFT\r\n' +
        '4. More than 1 building\r\n' +
        '5. More than 100 architectural drawing pages\r\n' +
        '6. Healthcare projects (hospital or assisted living) with more than 2 floors\r\n' +
        '7. Educational projects with more than 3 floors\r\n' +
        '8. Hotel, apartment, or senior living community projects with more than 6 floors\r\n' +
        '9. Hotel, apartment, or senior living community projects with more than 150 guestrooms/units\r\n' +
        '10. Hospital projects that contain REPLACEMENT or TOWER in the name\r\n' +
        '11. Hospital projects that sound like they’re for an entire building (they don’t list a specific department)';
    @track isrComments = '';
    @track isOpportunity = 'Yes';
    @track isOpportunityList = [{
        value: 'Yes',
        label: 'Yes'
    }, {
        value: 'eCommerce',
        label: 'eCommerce'
    }];

    @track arFacList = [{
            value: '',
            label: ''
        },
        {
            value: 'FAC',
            label: 'FAC'
        }, {
            value: 'ARC',
            label: 'ARC'
        }
    ];

    @track hasCZSelected = false;
    @track clickezeId = '';
    @track hasIPCSelected = false;
    @track IPCId = '';
    @track showArcFac = false;
    @track arcFac = '';

    @track defaultBuildingOwner = false;
    @track defaultoriginalAccount = true;

    @track isBuildingOwner = false;
    @track addressText = '';
    @track addressStreet = '';
    @track addressCity = '';
    @track addressState = '';
    @track addressZip = '';
    @track addressCountry = '';
    @track arcfac = '';

    @track countryList = '';
    @track stateList = '';
    @track addressList = [{
            label: 'Use Building Owner Address',
            value: 'BOA'
        },
        {
            label: 'Use Account Address',
            value: 'OBA'
        },
        {
            label: 'Use New Address',
            value: 'NEW'
        }
    ];
    @track selectedAddressList = 'NEW';

    @track boaAddress  = {
        addressStreet: '',
        addressCity: '',
        addressState: '',
        addressZip: '',
        addressCountry: ''
    };
    @track accAddress = {
        addressStreet: '',
        addressCity: '',
        addressState: '',
        addressZip: '',
        addressCountry: ''
    };
    @track proAddress = {
        addressStreet: '',
        addressCity: '',
        addressState: '',
        addressZip: '',
        addressCountry: ''
    };
    @track newAddress = {
        addressStreet: '',
        addressCity: '',
        addressState: '',
        addressZip: '',
        addressCountry: ''
    };
    @track buildingOwnerIsReadyOnly = false;
    @track buildingOwnerParentFound = false;
    @track cpHasBuildingOwner = false;
    @track cpData;

    @track buildingOwnerContactRequired = false;
    @track buildingOwnerContact;
    @track buildingOwnerContactList = [];
    @track bidDateEntryPossible = true;

    @track isAccount = false;
    @track isConstructionProject = false;
    @api currentRecordId;
    @api divisionInput;
    @api divSectionInput;

    connectedCallback() {
        this.loaded = false;
        
        //origin is the review all divisions process
        if(this.currentRecordId != null && this.currentRecordId != 'undefined' && this.currentRecordId != '')
        {
            this.recordId = this.currentRecordId;
            this.objectApiName = 'Construction_Project__c';
            this.estimateRequired = true;            
        }

        console.log(this.recordId);
        console.log('Object api is ' + this.objectApiName);
        GetRecordTypeWrapper().then(recordWrapper =>{
            const recordTypes = JSON.parse(recordWrapper);
            console.log(this.recordId);
            if (this.objectApiName == 'Construction_Project__c' || this.recordId.indexOf('a03') == 0)
            {
                this.isConstructionProject = true;
                this.addressList = [
                    {
                        label: 'Use Building Owner Address',
                        value: 'BOA'
                    },
                    {
                        label: 'Use Account Address',
                        value: 'OBA'
                    },
                    {
                        label: 'Use Project Address',
                        value: 'PRO'
                    },
                    {
                        label: 'Use New Address',
                        value: 'NEW'
                    }
                ];
                this.constructionProject = this.recordId;
                this.selectedAddressList = 'PRO';
                GetConstructionProject({recordId: this.recordId}).then(cpData => {
                    this.proAddress = {
                        addressStreet: cpData.Street_Address__c,
                        addressCity: cpData.City__c,
                        addressState: cpData.State__c,
                        addressZip: cpData.ZIP__c,
                        addressCountry: cpData.Country__c
                    }
                    console.log('construction project');
                    console.log(cpData);
                    this.marketSegment = cpData.Market_Segment__c;
                    let subSegmentTemp = cpData.Sub_Segment__c;
                    GetSubSegmentValues({marketSegment: this.marketSegment}).then(subSegmentData =>{
                        var tempArray = [];
        
                        subSegmentData.forEach(x =>{
                            tempArray.push({value: String(x), label: String(x)});
                        });
                        this.subSegmentList = tempArray;
        
                        this.subSegment = subSegmentTemp;
                        this.lockSegments = true;
                    });      
                    
                    this.addressStreet = this.proAddress.addressStreet;
                    this.addressCity = this.proAddress.addressCity;
                    this.addressZip = this.proAddress.addressZip;
                    this.addressCountry = this.proAddress.addressCountry;
                    this.populateStateAfterChange(this.proAddress.addressState);

                    GetConstructionProjectAccountId({recordId: this.recordId}).then(data =>{
                        console.log('Account Id returned was [' + data + ']');
                        if (data == '')
                        {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Error!',
                                message: 'No accounts are set on the construction project! Cannot create an opportunity.',
                                variant: 'warning'
                            }));
                            this.closeQuickAction();
                        }
                        else{
                            this.cpData = cpData;
                            if(cpData.Bid_Date_GC_to_Owner__c != null)
                                this.oppDate = cpData.Bid_Date_GC_to_Owner__c;
                            //this.bidDateEntryPossible = false; //decided not to use this visibility toggle
                            if (cpData.Building_Owner__c != null)
                            {
                                this.cpHasBuildingOwner = true;
                            }
                            this.buildAccountInfo(data,recordTypes);
                            
                        }
    
                        
                    }).catch(error => {
                        this.handleError(error);
                    });
                }).catch(error => {
                    this.handleError(error);
                });

                this.opportunityName = 'Auto Generated...';
                this.template.querySelector("[data-id='opportunityName']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='opportunityName']").disabled = true;
                
            }
            else{
                this.isAccount = true;
                this.buildAccountInfo(this.recordId,recordTypes);              
            }
        }).catch(error => {
            this.handleError(error);
        });;

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
        }).catch(error => {
            this.handleError(error);
        });

        GetLeadSources().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: String(x),
                    label: String(x)
                });
            });
            this.leadSourceList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetCategories().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: String(x),
                    label: String(x)
                });
            });
            this.categoryList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });

        GetDivisions().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: String(x.Id),
                    label: String(x.Name)
                });
                if (x.Name == 'Clickeze') this.clickezeId = x.Id;
                else if (x.Name == 'IPC') this.IPCId = x.Id;
            });
            this.divisionList = tempArray;
            if(this.divisionInput != null && this.divisionInput != 'undefined' && this.divisionInput != '')
            {
                this.division = this.divisionInput;
                if(this.divisionInput == 'a274V000000kKmPQAU')
                    this.hasCZSelected = true;
            }
        }).catch(error => {
            this.handleError(error);
        });

        GetDivSections().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: String(x),
                    label: String(x)
                });
            });
            this.divSectionList = tempArray;
            if(this.divSectionInput != null && this.divSectionInput != 'undefined' && this.divSectionInput != '')
                this.divSection = this.divSectionInput;
        }).catch(error => {
            this.handleError(error);
        });

        
        
    }

    checkAccountDeniedParty()
    {
        CheckDeniedPartyStatus({
            accountId: this.accountId
        }).then(data => {
                if (data) {                 
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    if(data.isAccountBlocked || data.hasRetrievalErrorOccurred)
                    {
                        this.handleError(data.message);
                        this.loaded = false;
                    }
                    else
                        this.loaded = true;           
                } else if (error) {
                    this.handleError(error);
                    this.loaded = false;
                }
            })
            .catch(error => {
                this.handleError("Error checking denied party status: " + errorJSON);
                this.loaded = false;
            });
    }

    buildAccountInfo(accountId,recordTypes)
    {
        this.accountId = accountId;
        GetAccountDetails({
            accountId: accountId
        }).then(data => {
            //Build contacts list
            GetContactsFromAccounts({
                buildingOwner: accountId,
                originalAccount: this.originalAccount
            }).then(results => {
                var tempArray = [];
                results.forEach(x => {
                    tempArray.push({
                        value: String(x.Id),
                        label: String(x.Name)
                    });
                });
                this.bidderContactList = tempArray;
            }).catch(error => {
                this.handleError(error);
            });
            //Build Market segment info
            GetMarketSegments({
                accountId: accountId
            }).then(results => {
                var tempArray = [];
                results.forEach(x => {
                    tempArray.push({
                        value: x.trim(),
                        label: x.trim()
                    });
                });
                this.marketSegmentList = tempArray;
            }).catch(error => {
                this.handleError(error);
            });
    
            //determine read-only property for Building Owner and Building Owner Parent fields
            if (data.RecordTypeId == recordTypes.BuildingOwnerId)
            {
                this.buildingOwnerIsReadyOnly = true;
            }
            
            this.defaultBuildingOwner = data.RecordTypeId == recordTypes.BuildingOwnerId;
            this.defaultoriginalAccount = data.Id;
            this.isBuildingOwner = data.RecordTypeId == recordTypes.BuildingOwnerId;
            this.selectedAddressList = this.selectedAddressList != 'PRO' ? 'NEW' : 'PRO';
            const dateObj = new Date();
            const month = String(dateObj.getMonth() + 1);
            const day = String(dateObj.getDate()).padStart(2, '0');
            const year = dateObj.getFullYear();
            const output = month + '/' + day + '/' + year;

            if(this.objectApiName != 'Construction_Project__c' && this.recordId.indexOf('a03') != 0)
                this.opportunityName = '';//data.Name + '-' + output;

            var selectedItem = {
                id: accountId,
                sObjectType: 'Account',
                icon: 'standard:account',
                title: data.Name,
                subtitle: data.AccountNumber
            };

            this.accAddress = {
                addressStreet: data.ShippingStreet,
                addressCity: data.ShippingCity,
                addressState: data.ShippingState,
                addressZip: data.ShippingPostalCode,
                addressCountry: data.ShippingCountry
            };
            /*if (this.selectedAddressList != 'PRO')
            {
                this.addressCity = data.ShippingCity;
                this.addressCountry = data.ShippingCountry;
                this.addressState = data.ShippingState;
                this.addressZip = data.ShippingPostalCode;
                this.addressStreet = data.ShippingStreet;
            }*/
            
            var cValue = data.ShippingCountry != undefined && data.ShippingCountry != '' ? data.ShippingCountry : 'United States';
            GetStates({
                country: cValue
            }).then(results => {
                var tempArray = [];
                results.forEach(x => {
                    tempArray.push({
                        value: x.split('|')[0],
                        label: x.split('|')[0]
                    });
                });
                this.stateList = tempArray;
                if (this.selectedAddressList == 'PRO' && this.addressState == '') this.addressState = data.ShippingState;
            }).catch(error => {
                this.handleError(error);
            });

            if(this.isBuildingOwner)
            {
                this.arcfac = 'FAC';
                if(data.Market_Segment__c != null && data.Sub_Segment__c != null && data.Market_Segment__c != '' && data.Sub_Segment__c != '')
                {
                    this.marketSegment = data.Market_Segment__c;
                    var subSegmentTemp = data.Sub_Segment__c;
                    GetSubSegmentValues({marketSegment: this.marketSegment}).then(subSegmentData =>{
                        var tempArray = [];
        
                        subSegmentData.forEach(x =>{
                            tempArray.push({value: String(x), label: String(x)});
                        });
                        this.subSegmentList = tempArray;
        
                        this.subSegment = subSegmentTemp;
                    });                                
                }
                else
                    this.marketSegmentSubSegmentVisible = true;
                if(data.Category__c != null && data.Category__c != '')
                    this.category = data.Category__c;
                else
                    this.categorySelectionVisible = true;
            }
            else
            {
                this.arcfac = 'ARC';
                this.marketSegmentSubSegmentVisible = true;
            }
            
            this.defaultoriginalAccount = accountId;
            this.originalAccountSelection = selectedItem;
            this.originalAccount = accountId;

            if (this.cpHasBuildingOwner) //Get CP Building Owner if objectApiName is Construction_Project__c
            {
                this.defaultBuildingOwner = true;
                this.buildingOwner = this.cpData.Building_Owner__c;
                GetAccountDetails({
                    accountId: this.buildingOwner
                }).then(cpAcc => {
                    this.boaAddress = {
                        addressStreet: cpAcc.ShippingStreet,
                        addressCity: cpAcc.ShippingCity,
                        addressState: cpAcc.ShippingState,
                        addressZip: cpAcc.ShippingPostalCode,
                        addressCountry: cpAcc.ShippingCountry
                    };

                    var selectedItem2 = {
                        id: cpAcc.Id,
                        sObjectType: 'Account',
                        icon: 'standard:account',
                        title: cpAcc.Name,
                        subtitle: cpAcc.AccountNumber
                    };
                    console.log('CP Building Owner is ' + cpAcc.Name);
                    this.buildingOwnerSelection = selectedItem2;
                    if (this.cpData.ParentId !== null)
                    {
                        GetParentAccountDetails({accountId: this.buildingOwner}).then(parentData => {
                            if (parentData !== null)
                            {
                                this.buildingOwnerParentFound = true;
                                //Auto select BO parent if found
                                this.buildingOwnerParent = parentData.Id;
                                var selectedParentItem = {
                                    id: parentData.Id,
                                    sObjectType: 'Account',
                                    icon: 'standard:account',
                                    title: parentData.Name,
                                    subtitle: parentData.AccountNumber
                                };
                                console.log('Parent is ' + parentData.Name);
                                this.buildingOwnerParentSelection = selectedParentItem;
                            }
                        });
                    }
                });
            }
            else if (this.defaultBuildingOwner) {

                this.buildingOwner = accountId;
                this.buildingOwnerSelection = selectedItem;
                this.boaAddress = {
                    addressStreet: data.ShippingStreet,
                    addressCity: data.ShippingCity,
                    addressState: data.ShippingState,
                    addressZip: data.ShippingPostalCode,
                    addressCountry: data.ShippingCountry
                };
                console.log(this.boaAddress);
                this.selectedAddressList = 'BOA';
                this.addressCity = data.ShippingCity;
                this.addressCountry = data.ShippingCountry;
                this.addressState = data.ShippingState;
                this.addressZip = data.ShippingPostalCode;
                this.addressStreet = data.ShippingStreet;

                console.log('set boaAddress');
                //Check for BO parent
                console.log(data.ParentId);
                if (data.ParentId !== null)
                {
                    GetParentAccountDetails({accountId: accountId}).then(parentData => {
                        if (parentData !== null)
                        {
                            this.buildingOwnerParentFound = true;
                            //Auto select BO parent if found
                            this.buildingOwnerParent = parentData.Id;
                            var selectedParentItem = {
                                id: parentData.Id,
                                sObjectType: 'Account',
                                icon: 'standard:account',
                                title: parentData.Name,
                                subtitle: parentData.AccountNumber
                            };
                            console.log('Parent is ' + parentData.Name);
                            this.buildingOwnerParentSelection = selectedParentItem;
                        }
                    });
                }
            }
            this.loaded = true;
            //this.checkAccountDeniedParty();
        }).catch(error => {
            this.handleError(error);
        });
    }
    handleCancel(event) {
        console.log("close");
        this.closeQuickAction();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleSave(event) {
        this.loaded = false;
        var needsTerritoryReview = this.newAddress != undefined && this.boaAddress != undefined &&
            this.newAddress.addressZip != '' && this.newAddress.addressZip != this.boaAddress.addressZip;

        var hasError = false;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            console.log('lightning-input:' + element.reportValidity());
            if (!element.reportValidity()) {
                hasError = true;
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            console.log('lightning-combobox:' + element.reportValidity());
            if (!element.reportValidity()) {
                hasError = true;
            }
        });
        if (!hasError)
        {
            if(this.isBuildingOwner)
                this.originalAccount = this.buildingOwner;

            var params = {
                buildingOwner: this.buildingOwner,
                buildingOwnerParent: this.buildingOwnerParent,
                originalAccount: this.originalAccount,
                constructionProject: this.constructionProject,
                bidderContact: this.bidderContact,
                buildingOwnerContactRequired: this.buildingOwnerContactRequired,
                buildingOwnerContact: this.buildingOwnerContact,
                division: this.division,
                opportunityName: this.opportunityName,
                divSection: this.divSection,
                marketSegment: this.marketSegment,
                estCloseDate: this.estCloseDate,
                subSegment: this.subSegment,
                oppDate: this.oppDate,
                leadSource: this.leadSource,
                estimateRequired: this.estimateRequired,
                leadSourceDetails: this.leadSourceDetails,
                largeProject: this.largeProject,
                isrComments: this.isrComments,
                isOpportunity: this.isOpportunity,
                category: this.category,
                isBuildingOwner: this.isBuildingOwner,
                addressStreet: this.addressStreet,
                addressCity: this.addressCity,
                addressState: this.addressState,
                addressZip: this.addressZip,
                addressCountry: this.addressCountry,
                userId: userId,
                arcFac: this.arcfac,
                needsTerritoryReview: needsTerritoryReview
            };
            
            console.log(params);

            CreateOpportunity(params).then(results => {
                if (results.indexOf('Error') == -1) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Opportunity was created! {1}.',
                        variant: 'success',
                        mode: 'sticky',
                        "messageData": [
                            'Salesforce',
                            {
                                url: window.location.protocol + '//' + window.location.host + '/lightning/r/Opportunity/' + results + '/view',
                                label: 'Click here to navigate to new opportunity'
                            }
                        ]
                    }));
                    this.loaded = true;
                    this.closeQuickAction();
                } else {
                    console.log(results);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: results,
                        variant: 'warning'
                    }));
                    this.loaded = true;
                }
            }).catch(error => {
                this.handleError(error);
            });
        } else {
            this.loaded = true;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'Please fill in the required fields.',
                variant: 'warning'
            }));
        }
    }

    handleInput(event) {
        if (event.target.name == 'division') {
            this.division = event.target.value;
            console.log(event.target);
            if (this.division == this.clickezeId) {
                this.hasCZSelected = true;
                //this.showArcFac = true;
            } else {
                this.hasCZSelected = false;
            }

            if (this.division == this.IPCId) {
                this.hasIPCSelected = true;
                //this.showArcFac = true;
            } else {
                this.hasIPCSelected = false;
            }

            //if (this.division != this.IPCId && this.division != this.clickezeId)
                //this.showArcFac = false;

        } else if (event.target.name == 'opportunityName') {
            this.opportunityName = event.target.value;
        } else if (event.target.name == 'arcFac') {
            this.arcFac = event.target.value;
        } else if (event.target.name == 'bidderContact') {
            this.bidderContact = event.target.value;
        } else if (event.target.name == 'buildingOwnerContact') {
            this.buildingOwnerContact = event.target.value;
        } else if (event.target.name == 'divSection') {
            this.divSection = event.target.value;
        } else if (event.target.name == 'marketSegment') {
            this.marketSegment = event.target.value;
            this.subSegmentList = [];
            GetSubSegmentValues({
                marketSegment: this.marketSegment
            }).then(data => {
                var tempArray = [];

                data.forEach(x => {
                    tempArray.push({
                        value: String(x),
                        label: String(x)
                    });
                });
                this.subSegmentList = tempArray;

                this.subSegment = '';
            });
            if(!this.isBuildingOwner)
            {
                if(this.marketSegment == 'Healthcare')
                    this.category = 'Healthcare';
                else
                    this.category = 'Spaces';
            }

        }
        else if (event.target.name == 'estCloseDate')
        {
            this.estCloseDate = event.target.value;
        } else if (event.target.name == 'subSegment') {
            this.subSegment = event.target.value;
        } else if (event.target.name == 'date') {
            this.oppDate = event.target.value;
        } else if (event.target.name == 'leadSource') {
            this.leadSource = event.target.value;
        } else if (event.target.name == 'estimateRequired') {
            console.log(event.target.checked);
            this.estimateRequired = event.target.checked;
            if (event.target.checked && this.objectApiName != 'Construction_Project__c')
            {
                this.oppDate = null;
                const inputFields = this.template.querySelectorAll('lightning-input-field');
                if (inputFields){
                    inputFields.forEach(field => {
                        if (field.name == 'date')
                        {
                            field.reset();
                        }
                    })
                }
            }
        } else if (event.target.name == 'leadSourceDetails') {
            this.leadSourceDetails = event.target.value;
        } else if (event.target.name == 'largeProject') {
            this.largeProject = event.target.checked;
        } else if (event.target.name == 'isrComments') {
            this.isrComments = event.target.value;
        } else if (event.target.name == 'isOpportunity') {
            this.isOpportunity = event.target.value;
        } else if (event.target.name == 'addressStreet') {
            this.addressStreet = event.target.value;
            this.selectedAddressList = 'NEW';
            this.newAddress = {
                addressStreet: this.addressStreet,
                addressCity: this.addressCity,
                addressState: this.addressState,
                addressZip: this.addressZip,
                addressCountry: this.addressCountry
            };
        } else if (event.target.name == 'addressCity') {
            this.addressCity = event.target.value;
            this.selectedAddressList = 'NEW';
            this.newAddress = {
                addressStreet: this.addressStreet,
                addressCity: this.addressCity,
                addressState: this.addressState,
                addressZip: this.addressZip,
                addressCountry: this.addressCountry
            };
        } else if (event.target.name == 'addressState') {
            this.addressState = event.target.value;
            this.selectedAddressList = 'NEW';
            this.newAddress = {
                addressStreet: this.addressStreet,
                addressCity: this.addressCity,
                addressState: this.addressState,
                addressZip: this.addressZip,
                addressCountry: this.addressCountry
            };
        } else if (event.target.name == 'addressZip') {
            this.addressZip = event.target.value;
            this.selectedAddressList = 'NEW';
            this.newAddress = {
                addressStreet: this.addressStreet,
                addressCity: this.addressCity,
                addressState: this.addressState,
                addressZip: this.addressZip,
                addressCountry: this.addressCountry
            };
        } else if (event.target.name == 'addressCountry') { //only trigger state update if country changes
            if (this.addressCountry != event.target.value) {
                this.addressCountry = event.target.value;
                this.addressState = '';
                this.selectedAddressList = 'NEW';
                this.newAddress = {
                    addressStreet: this.addressStreet,
                    addressCity: this.addressCity,
                    addressState: this.addressState,
                    addressZip: this.addressZip,
                    addressCountry: this.addressCountry
                };
                this.stateList = [];
                GetStates({
                    country: event.target.value
                }).then(results => {
                    var tempArray = [];
                    results.forEach(x => {
                        tempArray.push({
                            value: x.split('|')[0],
                            label: x.split('|')[0]
                        });
                    });
                    this.stateList = tempArray;
                }).catch(error => {
                    this.handleError(error);
                });
            }
        }
    };

    handleBuildingOwnerParentSearch(event){
        const target = event.target;
        console.log(event.detail);
        AccountBuildingOwnerParentSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
            });
    };

    handleBuildingOwnerSearch(event){
        const target = event.target;
        console.log(event.detail);
        AccountBuildingOwnerSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
            });
    };

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

    handleConstructionProjectSearch(event) {
        const target = event.target;
        console.log(event.detail);
        ConstructionProjectSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting construction projects: " + error);
            });
    }

    handleLookupSelectionChange(event) {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length == 0 && event.target.name == "buildingOwner") {
            this.updateBuildingOwner(null);
        } else if (selection.length == 0 && event.target.name == "originalAccount") {
            this.updateoriginalAccount(null);
        }
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);

            if (event.target.name == "buildingOwner") {
                this.updateBuildingOwner(id)
            } else if (event.target.name == "originalAccount") {
                this.updateoriginalAccount(id);
            } else if (event.target.name == "constructionProject") {
                this.constructionProject = id;
            } else if (event.target.name == "buildingOwnerParent") {
                this.buildingOwnerParent = id;
            }
        }
    }

    updateoriginalAccount(id) {
        this.originalAccount = id;
        if (id != null) {
            GetAccountDetails({
                accountId: id
            }).then(account => {
                this.accAddress = {
                    addressStreet: account.ShippingStreet,
                    addressCity: account.ShippingCity,
                    addressState: account.ShippingState,
                    addressZip: account.ShippingPostalCode,
                    addressCountry: account.ShippingCountry
                };
                console.log('setting boa address to ' + this.accAddress);
            });
        }

        this.handleContactListUpdate();
    }

    updateBuildingOwner(id) {
        this.buildingOwner = id;
        if (id != null) {
            GetAccountDetails({
                accountId: id
            }).then(account => {
                GetContactsFromAccounts({
                    buildingOwner: '',
                    originalAccount: id
                }).then(results => {
                    var tempArray = [];
                    results.forEach(x => {
                        tempArray.push({
                            value: String(x.Id),
                            label: String(x.Name)
                        });
                    });
                    this.buildingOwnerContactList = tempArray;
                }).catch(error => {
                    this.handleError(error);
                });
                this.buildingOwnerContactRequired = true;

                this.boaAddress = {
                    addressStreet: account.ShippingStreet,
                    addressCity: account.ShippingCity,
                    addressState: account.ShippingState,
                    addressZip: account.ShippingPostalCode,
                    addressCountry: account.ShippingCountry
                };

                if(account.Market_Segment__c != null && account.Sub_Segment__c != null && account.Market_Segment__c != '' && account.Sub_Segment__c != '')
                {
                    this.marketSegment = account.Market_Segment__c;
                    var subSegmentTemp = account.Sub_Segment__c;
                    GetSubSegmentValues({marketSegment: this.marketSegment}).then(subSegmentData =>{
                        var tempArray = [];
        
                        subSegmentData.forEach(x =>{
                            tempArray.push({value: String(x), label: String(x)});
                        });
                        this.subSegmentList = tempArray;
        
                        this.subSegment = subSegmentTemp;
                    });                                
                }
                else
                    this.marketSegmentSubSegmentVisible = true;
                
                if (account.ParentId !== null)
                {
                    console.log(account.Id);
                    GetParentAccountDetails({accountId: account.Id}).then(parentData => {
                        console.log('parentData is ' + parentData);
                        if (parentData !== null)
                        {
                            this.buildingOwnerParentFound = true;
                            console.log('parentData.Name is ' + parentData.Name);
                            //Auto select BO parent if found
                            this.buildingOwnerParent = parentData.Id;
                            var selectedParentItem = {
                                id: parentData.Id,
                                sObjectType: 'Account',
                                icon: 'standard:account',
                                title: parentData.Name,
                                subtitle: parentData.AccountNumber
                            };
                            this.buildingOwnerParentSelection = selectedParentItem;
                        }
                    });
                }
                else{
                    this.buildingOwnerParentFound = false;
                }
                console.log('setting boa address to ' + this.boaAddress.addressStreet + ', ' + this.boaAddress.addressCity + ', ' + this.boaAddress.addressState + ', ' + this.boaAddress.addressZip + ', ' + this.boaAddress.addressCountry);
            });
        }
        else
        {
            this.buildingOwnerContactRequired = false;
        }

        this.handleContactListUpdate();
    }


    populateStateAfterChange(state) {
        GetStates({
            country: this.addressCountry
        }).then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.split('|')[0], //[1] if value truly needed
                    label: x.split('|')[0] //[0] is full text
                });
            });
            this.stateList = tempArray;
            this.addressState = state;
        }).catch(error => {
            this.handleError(error);
        });
    }

    handleAddressListOnChange(event) {
        //Currently on New Address
        if (this.selectedAddressList == 'NEW') {
            //Update it before change
            this.newAddress = {
                addressStreet: this.addressStreet,
                addressCity: this.addressCity,
                addressState: this.addressState,
                addressZip: this.addressZip,
                addressCountry: this.addressCountry
            };
        }

        //If selecting new address manually
        if (event.target.value == 'NEW') {
            this.addressStreet = '';
            this.addressCity = '';
            this.addressState = '';
            this.addressZip = '';
            //assume new address in same country as account before
            //this.addressCountry = '';
        }
        if (event.target.value == 'BOA' && this.boaAddress != null) {
            this.addressStreet = this.boaAddress.addressStreet;
            this.addressCity = this.boaAddress.addressCity;
            this.addressZip = this.boaAddress.addressZip;
            this.addressCountry = this.boaAddress.addressCountry;
            this.populateStateAfterChange(this.boaAddress.addressState);
        } else if (event.target.value == 'OBA' && this.accAddress != null) {
            this.addressStreet = this.accAddress.addressStreet;
            this.addressCity = this.accAddress.addressCity;
            this.addressZip = this.accAddress.addressZip;
            this.addressCountry = this.accAddress.addressCountry;
            this.populateStateAfterChange(this.accAddress.addressState);
        }
        //If selecting new address but it was already given some data, then repopulate
        else if (event.target.value == 'NEW' && this.newAddress != null) {
            this.addressStreet = this.newAddress.addressStreet;
            this.addressCity = this.newAddress.addressCity;
            this.addressZip = this.newAddress.addressZip;
            this.addressCountry = this.newAddress.addressCountry;
            this.populateStateAfterChange(this.newAddress.addressState);
        }
        else if (event.target.value == 'PRO' && this.proAddress != null) {
            this.addressStreet = this.proAddress.addressStreet;
            this.addressCity = this.proAddress.addressCity;
            this.addressZip = this.proAddress.addressZip;
            this.addressCountry = this.proAddress.addressCountry;
            this.populateStateAfterChange(this.proAddress.addressState);
        }

        this.selectedAddressList = event.target.value;
    }
    //If selected account address is removed, reflect current selection on text helper list
    handleAddressListOnAccountUpdate() {
        this.addressList = [];
        var tempSelection = this.selectedAddressList;

        if (this.buildingOwner != null) {
            this.addressList.push({
                label: 'Use Building Owner Address',
                value: 'BOA'
            });
        }
        if (this.originalAccount != null) {
            this.addressList.push({
                label: 'Use Account Address',
                value: 'OBA'
            });
        }
        this.addressList.push({
            label: 'Use New Address',
            value: 'NEW'
        });

        if (tempSelection == 'BOA' && this.buildingOwner == null && this.originalAccount != null) this.selectedAddressList = 'OBA';
        else if (tempSelection == 'OBA' && this.originalAccount == null && this.buildingOwner != null) this.selectedAddressList = 'BOA';
        else if (this.buildingOwner == null && this.originalAccount == null) this.selectedAddressList = 'NEW';
    }

    handleContactListUpdate() {
        GetContactsFromAccounts({
            buildingOwner: this.buildingOwner,
            originalAccount: this.originalAccount
        }).then(results => {
            var tempArray = [];
            this.bidderContactList = [];
            results.forEach(x => {
                tempArray.push({
                    value: String(x.Id),
                    label: String(x.Name)
                });
            });
            this.bidderContactList = tempArray;

        }).catch(error => {
            this.handleError(error);
        });
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

    zipCodeLookup()
    {
        if(this.addressZip != null && this.addressZip != '')
        {
            this.isLoaded = false;
            GetStateCityFromZip({ zipCode: this.addressZip }).then(results =>{
                var data = JSON.parse(results);
                if(data.Status)
                {
                    if(data.City != null)
                        this.addressCity = data.City;
                    if(data.State != null)
                    {
                        this.addressCountry = 'United States'
                        this.populateStateAfterChange(data.State);
                    }
                        
                    this.isLoaded = true;
                }
                else
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'There was a problem looking up the zip code: ' + data.Message,
                        variant: 'warning'
                    }));
                    this.isLoaded = true;
                }            
            }); 
        }
    }
}