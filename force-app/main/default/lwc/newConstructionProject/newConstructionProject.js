import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import userId from '@salesforce/user/Id';
import GetPicklistValues from '@salesforce/apex/NewConstructionProjectHelper.GetPicklistValues';
import GetDependentPicklistValues from '@salesforce/apex/NewConstructionProjectHelper.GetDependentPicklistValues';
import GetCountries from '@salesforce/apex/AccountNewOpportunityHelper.GetCountries';
import GetStates from '@salesforce/apex/AccountNewOpportunityHelper.GetStates';
import GetAccountDetails from '@salesforce/apex/AccountNewOpportunityHelper.GetAccountDetails';
import GetRecordTypeWrapper from '@salesforce/apex/AccountNewOpportunityHelper.GetRecordTypeWrapper';
import AccountSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountSearch';
import AccountBuildingOwnerSearch from '@salesforce/apex/AccountNewOpportunityHelper.AccountBuildingOwnerSearch';
import TerritorySearch from '@salesforce/apex/NewConstructionProjectHelper.TerritorySearch';
import CreateConstructionProject from '@salesforce/apex/NewConstructionProjectHelper.CreateConstructionProject';
import ContactFilterSearch from '@salesforce/apex/NewConstructionProjectHelper.ContactFilterSearch';
import GetStateCountryFromZip from '@salesforce/apex/AddressValidationHelper.ZipCodeLookup';
//import CheckDeniedPartyStatus from '@salesforce/apex/DeniedPartyHelper.CheckDeniedPartyStatus';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import ContactSearch from '@salesforce/apex/AccountNewOpportunityHelper.ContactSearch';


export default class NewConstructionProject extends LightningElement {
    @api recordId; //Account
    @track stack;

    @track recordName = '';

    @track record = {
        Name: undefined,
        Market_Segment__c: undefined,
        Construction_Stage__c: 'Concept',
        Sub_Segment__c: undefined,
        A_E_Project_Number__c: undefined,
        Project_Source__c: 'Sales',
        ARC_FAC__c: 'ARC',
        Total_Constructed_Value__c: undefined,
        Category__c: undefined,
        General_Contractor__c: undefined,
        Large_Project__c: undefined,
        Construction_Project__c: 'Yes',
        Territory__c: undefined, //is this field still being used?
        Building_Owner__c: undefined,
        Expected_Completion_Date__c: undefined,
        Architect_Firm__c: undefined,
        Start_Date__c: undefined,
        Country__c: undefined,
        Street_Address__c: undefined,
        State__c: undefined,
        City__c: undefined,
        ZIP__c: undefined,
        Primary_Contact__c: undefined,
        Architect_Contact__c: undefined,
        Primary_Contact__c: undefined,
        General_Contractor__c: undefined,
        GC_Contact__c: undefined
    };

    @track list = {
        Market_Segment__c: [],
        Construction_Stage__c: [],
        Sub_Segment__c: [],
        Project_Source__c: [],
        ARC_FAC__c: [],
        Category__c: [],
        Country__c: [],
        State__c: []
    };

    @track selection = {
        Territory__c: new Array(0),
        Building_Owner__c: new Array(0),
        Architect_Firm__c: new Array(0),
        General_Contractor__c: new Array(0),
        Primary_Contact__c: new Array(0),
        Architect_Contact__c: new Array(0),
        Primary_Contact__c: new Array(0),
        GC_Contact__c: new Array(0)
    };

    @track selectedAddressType = 'newAddress';
    @track addressType = [
        {
            value: 'buildingOwnerAddress',
            label: 'Use Building Owner Address'
        },
        {
            value: 'accountAddress',
            label: 'Use Account Address'
        },
        {
            value: 'newAddress',
            label: 'Use New Address'
        }
    ];

    @track isContractor = false;
    @track isBuildingOwner = false;
    @track isArchitect = false;

    @track buildingOwnerAddress = {
        Country__c: undefined,
        Street_Address__c: undefined,
        State__c: undefined,
        City__c: undefined,
        ZIP__c: undefined
    };

    @track accountAddress = {
        Country__c: undefined,
        Street_Address__c: undefined,
        State__c: undefined,
        City__c: undefined,
        ZIP__c: undefined
    };

    @track newAddress = {
        Country__c: undefined,
        Street_Address__c: undefined,
        State__c: undefined,
        City__c: undefined,
        ZIP__c: undefined
    };

    @track loaded = false;
    _loadCount = 0;

    connectedCallback()
    {
        console.log('TEST');
        this.populateDependentListValues('Market_Segment__c','Yes');
        this.populateListValues('Construction_Stage__c');
        this.populateListValues('Project_Source__c');
        this.populateListValues('ARC_FAC__c');
        this.populateListValues('Category__c');
        this.populateAddressValues('Country__c');
        GetRecordTypeWrapper().then(recordWrapper =>{
            const recordTypes = JSON.parse(recordWrapper);
            GetAccountDetails({
                accountId: this.recordId
            }).then(results =>{
                this.recordName = results.Name;

                const addressResults = {
                    Country__c: results.ShippingCountry,
                    Street_Address__c: results.ShippingStreet,
                    State__c: results.ShippingState,
                    City__c: results.ShippingCity,
                    ZIP__c: results.ShippingPostalCode
                };
                console.log(results.RecordTypeId);
                console.log(recordTypes);
                this.accountAddress = addressResults;
                if (results.RecordTypeId == recordTypes.BuildingOwnerId)
                {
                    this.isBuildingOwner = true;
                    this.selectedAddressType = 'buildingOwnerAddress';
                    this.record.Building_Owner__c = this.recordId;
                    this.buildingOwnerAddress = addressResults;
                    this.handleAddressInput({ target: { name:'addressType', value:'buildingOwnerAddress' } });
                }
                else if (results.RecordTypeId == recordTypes.ArchitectId)
                {
                    this.isArchitect = true;
                    this.record.Architect_Firm__c = this.recordId;
                    this.isArchitectFirmSelected = true;
                }
                else 
                {
                    this.isContractor = true;
                    this.record.General_Contractor__c = this.recordId;
                }
                //this.checkAccountDeniedParty();
            }).catch(error => {
                this.handleError(error);
            });
        });
        
    }

    checkAccountDeniedParty()
    {
        CheckDeniedPartyStatus({
            accountId: this.recordId
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

    populateDependentListValues(fieldName,value)
    {
        this.loaded = false;
        this.list[fieldName] = [];
        this._loadCount++;
        GetDependentPicklistValues({
            objectName: 'Construction_Project__c',
            fieldName: fieldName,
            value: value
        }).then(data => {
            var tempArray = [];
            data.forEach(x => {
                tempArray.push({
                    value: String(x),
                    label: String(x)
                });
            });
            this.list[fieldName] = tempArray;
            this.record[fieldName] = '';
            if (--this._loadCount == 0) this.loaded = true;
        }).catch(error => {
            this.handleError(error);
        });
    }
    populateListValues(fieldName)
    {
        this.loaded = false;
        this._loadCount++;
        GetPicklistValues({
            objectName: 'Construction_Project__c', 
            fieldName: fieldName
        }).then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.split('|')[0],
                    label: x.split('|')[0]
                });
            });
            this.list[fieldName] = tempArray;
            if (--this._loadCount == 0) this.loaded = true;
        }).catch(error => {
            this.handleError(error);
        });
    }

    populateAddressValues(fieldName)
    {
        this.loaded = false;
        this._loadCount++;
        if (fieldName == 'State__c'){
            GetStates({
                country: this.record.Country__c
            }).then(results => {
                var tempArray = [];
                results.forEach(x => {
                    tempArray.push({
                        value: x.split('|')[0],
                        label: x.split('|')[0]
                    });
                });
                this.list.State__c = tempArray;
                if (--this._loadCount == 0) this.loaded = true;
            }).catch(error => {
                this.handleError(error);
            });
        }
        else if (fieldName == 'Country__c'){
            GetCountries().then(results =>{
                var tempArray = [];
                results.forEach(x => {
                    tempArray.push({
                        value: x.split('|')[0],
                        label: x.split('|')[0]
                    });
                });
                this.list.Country__c = tempArray;
                this.record.Country__c = 'United States';
                this.populateAddressValues('State__c');
                if (--this._loadCount == 0) this.loaded = true;
            }).catch(error => {
                this.handleError(error);
            });
        }
    }

    closeQuickAction() 
    {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleSearch(event)
    {
        const target = event.target;
        const detail = event.detail;
        const name = event.target.name;

        if (name == 'Territory__c')
        {
            this.handleSearchComplete(TerritorySearch, target, detail, name);
        }
        else if (name == 'Architect_Firm__c' || name == 'General_Contractor__c')
        {
            this.handleSearchComplete(AccountSearch, target, detail, name);
        }
        else if (name == 'Building_Owner__c')
        {
            this.handleSearchComplete(AccountBuildingOwnerSearch, target, detail, name);
        }
        else if (name == 'Primary_Contact__c')
        {
            this.handleSearchComplete(ContactSearch, target, detail, name);
        }
        else if (name == 'Architect_Contact__c' || name == 'GC_Contact__c')
        {
            event.detail.accountId = name == 'Architect_Contact__c' ? 
                this.record.Architect_Firm__c : this.record.General_Contractor__c;
            const filterDetail = event.detail;

            console.log('Account id is...');
            console.log(event.detail.accountId);
            this.handleSearchComplete(ContactFilterSearch, target, filterDetail, name);
        }
    }

    handleSearchComplete(promise, target, detail, name)
    {
        promise(detail).then(results => {
            target.setSearchResults(results);
        })
        .catch(error => {
            this.handleError(error);
            console.log("Error getting " + name + " : " + error);
        });
    }

    handleLookupSelectionChange(event) {
        const selection = event.target.getSelection();
        const name = event.target.name;

        if (selection.length > 0)
        {
            this.selection[name] = selection[0];
            this.record[name] = selection[0].id;
            console.log(this.record);
        }
        else if (selection.length == 0)
        {
            this.record[name] = '';
        }

        if (name == 'Architect_Firm__c')
        {
            this.isArchitectFirmSelected = selection.length > 0;
        }
        else if (name == 'General_Contractor__c')
        {
            this.isContractorSelected = selection.length > 0;
        }
        else if (name == 'Building_Owner__c')
        {
            if (selection.length > 0)
            {
                this.loaded = false;
                this.record.Building_Owner__c = selection[0].id;
                GetAccountDetails({
                    accountId: this.record.Building_Owner__c
                }).then(results =>{
                    const addressResults = {
                        Country__c: results.ShippingCountry,
                        Street_Address__c: results.ShippingStreet,
                        State__c: results.ShippingState,
                        City__c: results.ShippingCity,
                        ZIP__c: results.ShippingPostalCode
                    };
                    this.buildingOwnerAddress = addressResults;
                    this.loaded = true;
                }).catch(error => {
                    this.handleError(error);
                });
            }
            else
            {
                this.record.Building_Owner__c = undefined;
                this.buildingOwnerAddress = {
                    Country__c: undefined,
                    Street_Address__c: undefined,
                    State__c: undefined,
                    City__c: undefined,
                    ZIP__c: undefined
                };
            }
            
            
            
        }
    }

    handleAddressInput(event)
    {
        const name = event.target.name;
        const value = event.target.value;

        if (name == 'addressType')
        {
            this.selectedAddressType = value;
            this.record.Street_Address__c = this[value].Street_Address__c;
            this.record.City__c = this[value].City__c;
            this.record.State__c = this[value].State__c;
            this.record.ZIP__c = this[value].ZIP__c;
            this.record.Country__c = this[value].Country__c;
            return;
        }
        else if (name == 'Country__c')
        {
            this.record.State__c = '';
            this.populateAddressValues('State__c');
        }

        this.record[name] = value;
        this[this.selectedAddressType][name] = value;
    }

    handleInput(event)
    {
        const name = event.target.name;
        const value = event.target.value;
        const checked = event.target.checked;
        
        console.log(name);
        console.log(value);
        console.log(checked);

        this.record[name] = name == 'Large_Project__c' ? checked : value;
        
        if (name == 'Market_Segment__c')
        {
            this.populateDependentListValues('Sub_Segment__c',value);
        }
    }

    handleSave(event)
    {
        if (this.handleValidation(event))
        {
            console.log('Start save...');
            this.loaded = false;
            const jsonFields = JSON.stringify(this.record);
            console.log(jsonFields);
            CreateConstructionProject({
                jsonFields: jsonFields,
                accountId: this.recordId
            }).then(newRecordId =>{
                console.log(newRecordId);
                if (newRecordId.indexOf('a03') != -1 )
                {
                    window.location = window.location.protocol + '//' + window.location.host + '/lightning/r/Construction_Project__c/' + newRecordId + '/view';
                    this.loaded = true;
                }
                else
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!',
                        message: newRecordId,
                        variant: 'error'
                    }));
                }
                
            }).catch(error => {
                this.handleError(error);
            });
        }
    }

    handleValidation(event)
    {
        let valid = true;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.reportValidity();
            valid = valid && element.checkValidity();
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            element.reportValidity();
            valid = valid && element.checkValidity();
        });

        if (!valid)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error!',
                message: 'Please fill in the required fields.',
                variant: 'error'
            }));
        }
        return valid;
    }

    handleError(error) 
    {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'error'
            }));
        } 
        else if (error.body !== undefined && error.body.fieldErrors !== undefined)
        {
            for(var property in error.body.fieldErrors)
            {
                let innerError = error.body.fieldErrors[property][0];
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: innerError.statusCode + ': ' + innerError.message,
                    variant: 'error'
                }));
            }
        }
        else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'error'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'error'
            }));
        }
        this.loaded = true;
    }

    zipCodeLookup()
    {
        if(this.record.ZIP__c != null && this.record.ZIP__c != '')
        {
            this.isLoaded = false;
            GetStateCountryFromZip({ zipCode: this.record.ZIP__c }).then(results =>{
                var data = JSON.parse(results);
                if(data.Status)
                {
                    if(data.City != null)
                        this.record.City__c = data.City;
                    if(data.State != null)
                    {
                        this.populateAddressValues('Country__c');
                        this.record.Country__c = 'United States';
                        this.record.State__c = data.State;
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