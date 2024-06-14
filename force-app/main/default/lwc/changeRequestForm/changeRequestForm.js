import { LightningElement, 
    api, 
    track } from 'lwc';

import userId from '@salesforce/user/Id';
import GetAccount from '@salesforce/apex/ChangeRequestFormHelper.GetAccount';
import GetAccountPicklistValues from '@salesforce/apex/ChangeRequestFormHelper.GetAccountPicklistValues';
import GetStates from '@salesforce/apex/AccountNewOpportunityHelper.GetStates';
import GetSubSegmentValues from '@salesforce/apex/AccountNewOpportunityHelper.GetSubSegmentValues';
import GetMarketSegmentValues from '@salesforce/apex/ChangeRequestFormHelper.GetMarketSegmentValues';
import GetCountries from '@salesforce/apex/AccountNewOpportunityHelper.GetCountries';
import AccountSearch from '@salesforce/apex/ChangeRequestFormHelper.AccountSearch';
import ContactSearch from '@salesforce/apex/ChangeRequestFormHelper.ContactSearch';
import UserSearch from '@salesforce/apex/ChangeRequestFormHelper.UserSearch';
import TerritorySearch from '@salesforce/apex/ChangeRequestFormHelper.TerritorySearch';
import GetPermissions from '@salesforce/apex/ChangeRequestFormHelper.GetCurrentUser';
import ProcessAccountChanges from '@salesforce/apex/ChangeRequestFormHelper.ProcessAccountChanges';
import GetContacts from '@salesforce/apex/ChangeRequestFormHelper.GetContacts';
import GetRecordTypes from '@salesforce/apex/ChangeRequestFormHelper.GetRecordTypes';
import GetDependentPicklistValues from '@salesforce/apex/NewConstructionProjectHelper.GetDependentPicklistValues';
import GetStateCityFromZip from '@salesforce/apex/AddressValidationHelper.ZipCodeLookup';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class ChangeRequestForm extends LightningElement {
    @api objectApiName;
    @api recordId;
    loaded = true;
    Response = '';
    @track isAccount = true;
    
    @track territoryId;
    @track territoryName;
    @track accountName;
    @track formerName;
    @track parentId;
    @track parentName;
    @track marketSegment;
    @track subSegment;
    @track customerNumber;
    @track collectorId;
    @track collectorName;
    @track pointOfContactId;
    @track pointOfContactName;
    @track arcFac;
    @track dodgeCompanyID;
    @track category;
    @track inactive  = false;
    @track level;
    @track cia = false;
    @track nationalTerritory;
    @track syncGPOPricing;
    @track territory;
    @track syncPriceLevel  = false;
    @track priceLevel;
    @track phoneNumber;
    @track website;
    @track balance;
    @track creditHold  = false;
    @track creditApplicationReceived;
    @track creditLimit;
    @track availableCredit;
    @track paymentTerms;
    @track numberOfOpenOrders;
    @track hardCopyPORequired;
    @track openOrderValue;
    @track netsuiteAddDate;
    @track lastCallDate;
    @track lastCallOrVisitDate;
    @track lastVisitDate;
    @track lastSampleRequestDate;
    @track description;
    @track collector;
    @track salesforceMapsOverridden;
    @track invoiceEmail;
    @track vatNumber;
    @track shippingStreetAddress;  
    @track shippingCity; 
    @track shippingState; 
    @track shippingZipCode; 
    @track shippingCountry; 
    @track billingStreetAddress;  
    @track billingCity; 
    @track billingState; 
    @track billingZipCode; 
    @track billingCountry; 
    @track status; 
    @track recordType; 
    @track recordTypeName; 
    @track territorySelection = {};
    @track pointOfContactSelection = {};
    @track collectorSelection = {};
    @track parentAccountSelection = {};
    @track theRecord = {};
    @track priceLevelList = [];
    @track marketSegmentList = [];
    @track subSegmentList = [];
    @track arcFacList = [];
    @track categoryList = [];
    @track levelList = [];
    @track nationalTerritoryList = [];
    @track recordTypeList = [];
    @track paymentTermsList = [];
    @track shippingStateList = [];
    @track shippingCountryList = [];
    @track billingStateList = [];
    @track billingCountryList = [];
    @track contactList = [];
    @track profileName = '';
    @track userRole = '';
    @track isContactPaneOpen = false;
    @track syncContactPhone = false;
    @track syncContactAddress = false;
    @track leavingContactPane = false;
    @track hasNationalAccountPrivileges = false;
    @track hasParentAccountPrivileges = false;
    @track classList = {};
    @track formerNameClass = '';
    @track requiredFieldsMissingData = '';
    @track isPriceLevelAdmin = false;
    @track lockPriceLevel = false;

    connectedCallback() {
        this.getDropdownListValues();     
    }

    renderedCallback()
    {
        if(this.leavingContactPane)
        {
            this.setFieldPermissionAttributes();
        }
    }

    loadPermissions() {
        GetPermissions({
            userId: userId
        }).then(data => {
            if (data) {                 
                var myJSON = JSON.stringify(data);
                //console.log(myJSON);

                if(data.retrievedUser != null && data.retrievedUser.Profile.Name != null)
                {
                    this.profileName = data.retrievedUser.Profile.Name;
                    this.userRole = '';
                    if(data.retrievedUser != null && data.retrievedUser.UserRole != null && data.retrievedUser.UserRole.Name != null)
                        this.userRole = data.retrievedUser.UserRole.Name;
                
                    if(data.permissionSets != null && data.permissionSets.length > 0)
                    {
                        for(var i = 0; i < data.permissionSets.length; i++)
                        {
                            if(data.permissionSets[i].PermissionSet != null && data.permissionSets[i].PermissionSet.Name != null)
                            {
                                if(data.permissionSets[i].PermissionSet.Name == 'National_Account_Updates')
                                    this.hasNationalAccountPrivileges = true;
                                if(data.permissionSets[i].PermissionSet.Name == 'Edit_Parent_Account')
                                    this.hasParentAccountPrivileges = true;
                                if(data.permissionSets[i].PermissionSet.Name == 'Price_Level_Admin')
                                    this.isPriceLevelAdmin = true;
                            }
                        }
                    }
                
                    this.setFieldPermissionAttributes();                       
                }
                else
                    alert("Error: There was an error retrieving the user permissions.");                                            
            }})
            .catch(error => {
                this.handleError(error);
            });
        
    }

    setFieldPermissionAttributes()
    {
        this.isContactPaneOpen = false;
        if(this.status == "Approved" && this.profileName != "Inpro - Finance" && this.profileName != "System Administrator")
        {
            this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#fcdfbd';                            
            this.template.querySelector("[data-id='acc_syncPriceLevel']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_inactive']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_level']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_nationalTerritory']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_collector']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_hardCopyPORequired']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_creditHold']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_salesforceMapsOverridden']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_balance']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_creditApplicationReceived']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_availableCredit']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_numberOfOpenOrders']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_openOrderValue']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_creditLimit']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_paymentTerms']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_netsuiteAddDate']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_lastCallDate']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_lastVisitDate']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_lastSampleRequestDate']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_territory']").style.backgroundColor = '#fcdfbd';                            
        }
        else if (this.status == "Customer" && this.profileName != "Inpro - Finance" && this.profileName != "System Administrator")
        {           
            this.template.querySelector("[data-id='acc_recordType']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_AccountName']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_inactive']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_marketSegment']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_subSegment']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_shippingStreetAddress']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_shippingCity']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_shippingZipCode']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_shippingState']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_shippingCountry']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_billingStreetAddress']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_billingCity']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_billingZipCode']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_billingState']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_billingCountry']").style.backgroundColor = '#fcdfbd';
            this.template.querySelector("[data-id='acc_arcFac']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_arcFac']").disabled = true;
        }
        if(this.profileName != "Inpro - Finance" && this.profileName != "System Administrator")
        {
            this.template.querySelector("[data-id='acc_CustomerNumber']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_CustomerNumber']").disabled = true;
            this.template.querySelector("[data-id='acc_syncPriceLevel']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_syncPriceLevel']").disabled = true;                        
            this.template.querySelector("[data-id='acc_territory']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_territory']").disabled = true;
            if(this.hasNationalAccountPrivileges && this.status == 'Approved')
            {
                this.template.querySelector("[data-id='acc_level']").disabled = false;
                this.template.querySelector("[data-id='acc_nationalTerritory']").disabled = false;
                this.template.querySelector("[data-id='acc_syncGPOPricing']").disabled = false;
            }
            else if (this.hasNationalAccountPrivileges)
            {
                this.template.querySelector("[data-id='acc_level']").style.backgroundColor = '#fcdfbd';
                this.template.querySelector("[data-id='acc_level']").disabled = false;
                this.template.querySelector("[data-id='acc_nationalTerritory']").style.backgroundColor = '#fcdfbd';
                this.template.querySelector("[data-id='acc_nationalTerritory']").disabled = false;
                this.template.querySelector("[data-id='acc_syncGPOPricing']").style.backgroundColor = '#fcdfbd';
                this.template.querySelector("[data-id='acc_syncGPOPricing']").disabled = false;
            }           
            else
            {
                this.template.querySelector("[data-id='acc_level']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_level']").disabled = true;
                this.template.querySelector("[data-id='acc_nationalTerritory']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_nationalTerritory']").disabled = true;
                this.template.querySelector("[data-id='acc_syncGPOPricing']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_syncGPOPricing']").disabled = true;
            }
            
            this.template.querySelector("[data-id='acc_balance']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_balance']").disabled = true;
            this.template.querySelector("[data-id='acc_creditHold']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_creditHold']").disabled = true;
            this.template.querySelector("[data-id='acc_creditApplicationReceived']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_creditApplicationReceived']").disabled = true;
            this.template.querySelector("[data-id='acc_creditLimit']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_creditLimit']").disabled = true;
            this.template.querySelector("[data-id='acc_availableCredit']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_availableCredit']").disabled = true;
            this.template.querySelector("[data-id='acc_paymentTerms']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_paymentTerms']").disabled = true;
            this.template.querySelector("[data-id='acc_numberOfOpenOrders']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_numberOfOpenOrders']").disabled = true;
            this.template.querySelector("[data-id='acc_hardCopyPORequired']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_hardCopyPORequired']").disabled = true;
            this.template.querySelector("[data-id='acc_openOrderValue']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_openOrderValue']").disabled = true;
            this.template.querySelector("[data-id='acc_netsuiteAddDate']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_netsuiteAddDate']").disabled = true;
            this.template.querySelector("[data-id='acc_lastCallDate']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_lastCallDate']").disabled = true;
            this.template.querySelector("[data-id='acc_lastCallOrVisitDate']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_lastCallOrVisitDate']").disabled = true;
            this.template.querySelector("[data-id='acc_lastVisitDate']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_lastVisitDate']").disabled = true;
            this.template.querySelector("[data-id='acc_lastSampleRequestDate']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_lastSampleRequestDate']").disabled = true;
            this.template.querySelector("[data-id='acc_salesforceMapsOverridden']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_salesforceMapsOverridden']").disabled = true;
            this.template.querySelector("[data-id='acc_collector']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_collector']").disabled = true;           
            this.template.querySelector("[data-id='acc_category']").style.backgroundColor = '#d9d9d9';
            this.template.querySelector("[data-id='acc_category']").disabled = true;
            if((this.userRole != null && this.userRole.indexOf("Exec") != -1) || this.hasParentAccountPrivileges || this.status == "Customer" || this.isPriceLevelAdmin)
            {
                this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_parentAccount']").disabled = true;
                this.template.querySelector("[data-id='acc_cia']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_cia']").disabled = true;
                this.template.querySelector("[data-id='acc_priceLevel']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_priceLevel']").disabled = true;
                this.template.querySelector("[data-id='acc_lockPriceLevel']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_lockPriceLevel']").disabled = true;

                if((this.userRole != null && this.userRole.indexOf("Exec") != -1))
                {
                    this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#FFFFFF';
                    this.template.querySelector("[data-id='acc_parentAccount']").disabled = false;
                    this.template.querySelector("[data-id='acc_cia']").style.backgroundColor = '#FFFFFF';
                    this.template.querySelector("[data-id='acc_cia']").disabled = false;
                    this.template.querySelector("[data-id='acc_priceLevel']").style.backgroundColor = '#FFFFFF';
                    this.template.querySelector("[data-id='acc_priceLevel']").disabled = false;
                }
                if (this.hasParentAccountPrivileges)
                {
                    this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#FFFFFF';
                    this.template.querySelector("[data-id='acc_parentAccount']").disabled = false;
                }
                if (this.status == "Customer")
                {
                    this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#fcdfbd';
                    this.template.querySelector("[data-id='acc_parentAccount']").disabled = false;
                }
                if(this.isPriceLevelAdmin)
                {
                    this.template.querySelector("[data-id='acc_priceLevel']").style.backgroundColor = '#FFFFFF';
                    this.template.querySelector("[data-id='acc_priceLevel']").disabled = false;
                    //this field should only be checked/unchecked through automation
                    //this.template.querySelector("[data-id='acc_lockPriceLevel']").style.backgroundColor = '#FFFFFF';
                    //this.template.querySelector("[data-id='acc_lockPriceLevel']").disabled = false;
                }
            }
            else
            {
                this.template.querySelector("[data-id='acc_parentAccount']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_parentAccount']").disabled = true;
                this.template.querySelector("[data-id='acc_cia']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_cia']").disabled = true;
                this.template.querySelector("[data-id='acc_priceLevel']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_priceLevel']").disabled = true;
                this.template.querySelector("[data-id='acc_lockPriceLevel']").style.backgroundColor = '#d9d9d9';
                this.template.querySelector("[data-id='acc_lockPriceLevel']").disabled = true;
            }                                  
        }
        if(!this.leavingContactPane)
            this.getContacts(); 
        else
        {
            this.leavingContactPane = false;
        }           
    }  

    getContacts() {
        this.contactList = [];
        GetContacts({
                accountId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        //console.log(myJSON);
                        data.forEach(Contact => {
                            var newItem = {
                                Id: Contact.Id,
                                MailingStreet: Contact.MailingStreet,
                                MailingCity: Contact.MailingCity,
                                MailingState: Contact.MailingState,
                                MailingPostalCode: Contact.MailingPostalCode,
                                MailingCountry: Contact.MailingCountry,
                                Phone: Contact.Phone,
                                Name: Contact.Name                              
                            };
                            this.contactList = [...this.contactList, newItem];
                        });
                        this.loaded = true;

                    } catch (error) {
                        //console.log("Error Loading Contacts: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    //console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                //console.log("Error getting Contacts: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    getDropdownListValues(){
        GetAccountPicklistValues({
        }).then(data => {
                if (data) {                 
                    var myJSON = JSON.stringify(data);
                    //console.log(myJSON);

                    var pleaseSelectOption = {
                        label: 'Please Select',
                        value: 'Please Select'
                    };
                    this.arcFacList = [...this.arcFacList, pleaseSelectOption];
                    this.priceLevelList = [...this.priceLevelList, pleaseSelectOption];
                    //this.marketSegmentList = [...this.marketSegmentList, pleaseSelectOption];
                    //this.subSegmentList = [...this.subSegmentList, pleaseSelectOption];
                    this.categoryList = [...this.categoryList, pleaseSelectOption];
                    this.levelList = [...this.levelList, pleaseSelectOption];
                    this.paymentTermsList = [...this.paymentTermsList, pleaseSelectOption];
                    this.shippingStateList = [...this.shippingStateList, pleaseSelectOption];
                    this.shippingCountryList = [...this.shippingCountryList, pleaseSelectOption];
                    this.billingStateList = [...this.billingStateList, pleaseSelectOption];
                    this.billingCountryList = [...this.billingCountryList, pleaseSelectOption];

                    for(var i = 0; i < data.arcFacOptions.length; i++)
                    {
                        var option = {
                            label: data.arcFacOptions[i],
                            value: data.arcFacOptions[i]
                        };
                        this.arcFacList = [...this.arcFacList, option];
                    }

                    for(var i = 0; i < data.levelOptions.length; i++)
                    {
                        var option = {
                            label: data.levelOptions[i],
                            value: data.levelOptions[i]
                        };
                        this.levelList = [...this.levelList, option];
                    }

                    for(var i = 0; i < data.priceLevelOptions.length; i++)
                    {
                        var option = {
                            label: data.priceLevelOptions[i],
                            value: data.priceLevelOptions[i]
                        };
                        this.priceLevelList = [...this.priceLevelList, option];
                    }

                    // for(var i = 0; i < data.marketSegmentOptions.length; i++)
                    // {
                    //     var option = {
                    //         label: data.marketSegmentOptions[i],
                    //         value: data.marketSegmentOptions[i]
                    //     };
                    //     this.marketSegmentList = [...this.marketSegmentList, option];
                    // }

                    // for(var i = 0; i < data.subSegmentOptions.length; i++)
                    // {
                    //     var option = {
                    //         label: data.subSegmentOptions[i],
                    //         value: data.subSegmentOptions[i]
                    //     };
                    //     this.subSegmentList = [...this.subSegmentList, option];
                    // }

                    for(var i = 0; i < data.categoryOptions.length; i++)
                    {
                        var option = {
                            label: data.categoryOptions[i],
                            value: data.categoryOptions[i]
                        };
                        this.categoryList = [...this.categoryList, option];
                    }

                    for(var i = 0; i < data.paymentTermsOptions.length; i++)
                    {
                        var option = {
                            label: data.paymentTermsOptions[i],
                            value: data.paymentTermsOptions[i]
                        };
                        this.paymentTermsList = [...this.paymentTermsList, option];
                    }  
                    
                    GetCountries().then(results => {
                        var tempArray = [];
                        results.forEach(x => {
                            tempArray.push({
                                value: x.split('|')[0],
                                label: x.split('|')[0]
                            });
                        });
                        this.billingCountryList = tempArray;
                        this.shippingCountryList = tempArray;
                    }).catch(error => {
                        this.handleError(error);
                    });

                    this.getRecordTypes('Account');    

                } else if (error) {
                    this.handleError(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    getRecordTypes(sObjectType){
        this.recordTypeList = [];
        GetRecordTypes({
            sObjectType: sObjectType
        }).then(data => {
            if (data) {
                try {
                    var myJSON = JSON.stringify(data);
                    //console.log(myJSON);
                    data.forEach(recordType => {
                        var option = {
                            label: recordType.Name,
                            value: recordType.Id
                        };
                        this.recordTypeList = [...this.recordTypeList, option];
                    });
                    this.getAccount();     

                } catch (error) {
                    //console.log("Error Loading Record Types: " + error);
                }

            } else if (error) {
                this.error = error;
                //console.log(error);
            }
        })
        .catch(error => {
            // TODO: handle error
            //console.log("Error getting Record Type: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    getAccount(){
        GetAccount({
            recordId: this.recordId
        }).then(data => {
                if (data) {                 
                    var myJSON = JSON.stringify(data);
                    //console.log('GetAccount');
                    //console.log(myJSON);

                    if(data.Name != null)
                        this.accountName = data.Name;
                    if(data.AKA_Former_Name__c != null)
                        this.formerName = data.AKA_Former_Name__c;
                    if(data.ParentId != null)
                    {
                        this.parentId = data.ParentId;
                        this.parentAccountSelection = {
                            id: data.ParentId,
                            sObjectType: 'account',
                            icon: 'standard:account',
                            title: data.Parent.Name,
                            subtitle: ''
                        };  
                    }
                    if(data.RecordTypeId != null)
                    {
                        this.recordType = data.RecordTypeId;
                        //this.marketSegment = data.Market_Segment__c;
                        GetMarketSegmentValues({recordTypeId: this.recordType}).then(marketSegmentData =>{
                            var tempArray = [];
            
                            marketSegmentData.forEach(x =>{
                                if(data.Market_Segment__c == String(x))
                                    this.marketSegment = data.Market_Segment__c;
                                tempArray.push({value: String(x), label: String(x)});
                            });
                            this.marketSegmentList = tempArray;   
                            
                            if(data.Market_Segment__c != null && this.marketSegment != '' && this.marketSegment != null)
                            {
                                GetSubSegmentValues({marketSegment: data.Market_Segment__c}).then(subSegmentData =>{
                                    var tempArray = [];
                    
                                    subSegmentData.forEach(x =>{
                                        tempArray.push({value: String(x), label: String(x)});
                                    });
                                    this.subSegmentList = tempArray;  
                                    if(data.Sub_Segment__c != null && this.marketSegment != '' && this.marketSegment != null)          
                                        this.subSegment = data.Sub_Segment__c;
                                }); 
                                this.marketSegment = data.Market_Segment__c;

                                this.getNationalTerritoryList();
                            }
                        }); 
                        
                    }
                    if(data.Customer_Number__c != null)
                        this.customerNumber = data.Customer_Number__c;
                    if(data.Dodge_Company_ID__c != null)
                        this.dodgeCompanyID = data.Dodge_Company_ID__c;
                    if(data.Inactive__c != null)
                        this.inactive = data.Inactive__c;
                    if(data.CIA__c != null)
                        this.cia = data.CIA__c;
                    if(data.Sync_GPO_Pricing__c != null)
                        this.syncGPOPricing = data.Sync_GPO_Pricing__c;
                    if(data.Sync_Price_Level__c != null)
                        this.syncPriceLevel = data.Sync_Price_Level__c;
                    
                    if(data.ARC_FAC__c != null)
                        this.arcFac = data.ARC_FAC__c;
                    if(data.Category__c != null)
                        this.category = data.Category__c;
                    if(data.Level__c != null)
                        this.level = data.Level__c;
                    if(data.National_Territory__c != null)
                        this.nationalTerritory = data.National_Territory__c;
                    if(data.Lock_Price_Level__c != null)
                        this.lockPriceLevel = data.Lock_Price_Level__c;
                    
                        
                    if(data.Territory_Lookup__c != null)
                    {
                        this.territorySelection = {
                            id: data.Territory_Lookup__c,
                            sObjectType: 'Territory__c',
                            icon: 'standard:account',
                            title: data.Territory_Lookup__r.Name,
                            subtitle: ''
                        }; 
                        this.territoryId = data.Territory_Lookup__c;
                    }
                    if(data.Price_Level__c != null)
                        this.priceLevel = data.Price_Level__c;
                    if(data.Phone != null)
                        this.phoneNumber = data.Phone;
                    if(data.Website != null)
                        this.website = data.Website;
                    if(data.Balance__c != null)
                        this.balance = data.Balance__c;
                    if(data.Credit_Application_Received__c != null)
                        this.creditApplicationReceived = data.Credit_Application_Received__c;
                    if(data.Available_Credit__c != null)
                        this.availableCredit = data.Available_Credit__c;
                    if(data.of_Open_Orders__c != null)
                        this.numberOfOpenOrders = data.of_Open_Orders__c;
                    if(data.Open_Order_Value__c != null)
                        this.openOrderValue = data.Open_Order_Value__c;
                    if(data.Credit_Hold__c != null)
                        this.creditHold = data.Credit_Hold__c;
                    if(data.Credit_Limit__c != null)
                        this.creditLimit = data.Credit_Limit__c;
                    if(data.Payment_Terms__c != null)
                        this.paymentTerms = data.Payment_Terms__c;
                    if(data.Hard_Copy_PO_Required__c != null)
                        this.hardCopyPORequired = data.Hard_Copy_PO_Required__c;
                    if(data.NetSuite_Add_Date__c != null)
                        this.netsuiteAddDate = data.NetSuite_Add_Date__c;
                    if(data.Last_Call_Date__c != null)
                        this.lastCallDate = data.Last_Call_Date__c;
                    if(data.Last_Call_or_Visit_Date__c != null)
                        this.lastCallOrVisitDate = data.Last_Call_or_Visit_Date__c;
                    if(data.Last_Visit_Date__c != null)
                        this.lastVisitDate = data.Last_Visit_Date__c;
                    if(data.Last_Sample_Date__c != null)
                        this.lastSampleRequestDate = data.Last_Sample_Date__c;
                    if(data.Description != null)
                        this.description = data.Description;
                    if(data.Collector__c != null)
                    {
                        this.collectorSelection = {
                            id: data.Collector__c,
                            sObjectType: 'User',
                            icon: 'standard:account',
                            title: data.Collector__r.Name,
                            subtitle: ''
                        }; 
                        this.collectorId = data.Collector__c;
                    }
                    if(data.Invoice_Email__c != null)
                        this.invoiceEmail = data.Invoice_Email__c;
                    if(data.Salesforce_Maps_Overridden_Finance__c != null)
                        this.salesforceMapsOverridden = data.Salesforce_Maps_Overridden_Finance__c;
                    if(data.V_A_T_Number__c != null)
                        this.vatNumber = data.V_A_T_Number__c;
                    if(data.Point_of_Contact__c != null)
                    {
                        this.pointOfContactSelection = {
                            id: data.Point_of_Contact__c,
                            sObjectType: 'Contact',
                            icon: 'standard:account',
                            title: data.Point_of_Contact__r.Name,
                            subtitle: ''
                        };
                        this.pointOfContactId = data.Point_of_Contact__c;
                    }
                    if(data.ShippingCity != null)
                        this.shippingCity = data.ShippingCity;                   
                    if(data.ShippingPostalCode != null)
                        this.shippingZipCode = data.ShippingPostalCode;
                    if(data.ShippingCountry != null)
                    {
                        this.shippingCountry = data.ShippingCountry;
                        GetStates({
                            country: this.shippingCountry
                        }).then(results => {
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
                    if(data.ShippingState != null)
                        this.shippingState = data.ShippingState; 
                    if(data.ShippingStreet != null)
                        this.shippingStreetAddress = data.ShippingStreet;
                    if(data.BillingCity != null)
                        this.billingCity = data.BillingCity;                     
                    if(data.BillingPostalCode != null)
                        this.billingZipCode = data.BillingPostalCode;
                    if(data.BillingCountry != null)
                    {
                        this.billingCountry = data.BillingCountry;
                        GetStates({
                            country: this.billingCountry
                        }).then(results => {
                            var tempArray = [];
                            results.forEach(x => {
                                tempArray.push({
                                    value: x.split('|')[0],
                                    label: x.split('|')[0]
                                });
                            });
                            this.billingStateList = tempArray;
                        }).catch(error => {
                            this.handleError(error);
                        }); 
                    }   
                    if(data.BillingState != null)
                        this.billingState = data.BillingState;                     
                    if(data.BillingStreet != null)
                        this.billingStreetAddress = data.BillingStreet; 
                    if(data.Status__c != null)
                        this.status = data.Status__c;
                    this.loadPermissions();
                } else if (error) {
                    this.handleError(error);
                }               
            })
            .catch(error => {
                this.handleError(error);
            });
    }
    
    confirmContactSelection(event){
        this.isContactPaneOpen = false;
        this.leavingContactPane = true;
        //this.setFieldPermissionAttributes();
    }

    getNationalTerritoryList(){
        let params = {
            objectName: 'Account',
            fieldName: 'National_Territory__c',
            value: this.marketSegment
        };
        console.log(params);

        GetDependentPicklistValues(params).then(data =>{
            this.nationalTerritoryList = [];
            console.log(data);
            if (data != null)
            {
                for(var i = 0; i < data.length; i++)
                {
                    var option = {
                        label: data[i],
                        value: data[i]
                    };
                    this.nationalTerritoryList = [...this.nationalTerritoryList, option];
                }
            }
            else
            {
                this.nationalTerritory = undefined;
            }
        });
    }

    handleSave(){ 

        this.requiredFieldsMissingData = '';
        if(this.marketSegment == null || this.marketSegment == '')
            this.requiredFieldsMissingData += 'Market Segment, ';
        if(this.subSegment == null || this.subSegment == '')
            this.requiredFieldsMissingData += 'Sub Segment, ';    
        if(this.accountName == null || this.accountName == '')
            this.requiredFieldsMissingData += 'Account Name, '; 
        
        if(this.requiredFieldsMissingData == '')
        {
            this.loaded = false;       
            var changeProperties = {
                profileName: this.profileName,
                recordId: this.recordId,
                name: this.accountName,
                formerName: this.formerName,
                parentId: this.parentId,
                parentName: this.parentName,
                customerNumber: this.customerNumber,
                dodgeCompanyId: this.dodgeCompanyID,
                inactive: this.inactive,
                cia: this.cia,
                syncGPOPricing: this.syncGPOPricing,
                syncPriceLevel: this.syncPriceLevel,
                marketSegment: this.marketSegment,
                subSegment: this.subSegment,
                arcFac: this.arcFac,
                category: this.category,
                level: this.level,
                nationalTerritory: this.nationalTerritory,
                territoryId: this.territoryId,
                territoryName: this.territoryName,
                priceLevel: this.priceLevel,
                phoneNumber: this.phoneNumber,
                website: this.website,
                balance: this.balance,
                creditApplicationReceived: this.creditApplicationReceived,
                availableCredit: this.availableCredit,
                numberOfOpenOrders: this.numberOfOpenOrders,
                openOrderValue: this.openOrderValue,
                creditHold: this.creditHold,
                creditLimit: this.creditLimit,
                paymentTerms: this.paymentTerms,
                hardCopyPORequired: this.hardCopyPORequired,
                netsuiteAddDate: this.netsuiteAddDate,
                lastCallDate: this.lastCallDate,
                lastVisitDate: this.lastVisitDate,
                lastCallOrVisitDate: this.lastCallOrVisitDate,
                lastSampleRequestDate: this.lastSampleRequestDate,
                description: this.description,
                collectorId: this.collectorId,
                collectorName: this.collectorName,
                invoiceEmail: this.invoiceEmail,
                salesforceMapsOverridden: this.salesforceMapsOverridden,
                shippingStreetAddress: this.shippingStreetAddress, 
                shippingCity: this.shippingCity,
                shippingZipCode: this.shippingZipCode,
                shippingState: this.shippingState,
                shippingCountry: this.shippingCountry,
                billingStreetAddress: this.billingStreetAddress,
                billingCity: this.billingCity,
                billingZipCode: this.billingZipCode,
                billingState: this.billingState,
                billingCountry: this.billingCountry,
                vatNumber: this.vatNumber,
                pointOfContactId: this.pointOfContactId,
                pointOfContactName: this.pointOfContactName,
                recordTypeId: this.recordType,
                recordTypeName: this.recordTypeName,
                lockPriceLevel: this.lockPriceLevel
            };        

            ProcessAccountChanges({
                changeProperties: changeProperties,
                selectedContacts: this.contactList,
                syncContactPhone: this.syncContactPhone,
                syncContactAddress: this.syncContactAddress,
                userId: userId            
            }).then(dataResult => {
                if (dataResult) {
                    try {
                        if(!dataResult.toLowerCase().includes("error"))
                        {
                            if(dataResult.toLowerCase().includes("success! change request submitted."))
                            {
                                alert("Some of the changes specified require finance approval. You can see the current status of the approval by going to the 'Approval History' tab on this account.");
                                this.loaded = true;
                                document.location = location.href;
                            }
                            else
                            {
                                this.loaded = true;
                                document.location = location.href; 
                            }                       
                        }
                        else
                        {
                            this.handleError(dataResult);
                        }                   
                    } catch (error) {
                        this.handleError(error);
                    }

                } else if (error) {
                    this.handleError(error);
                }
            })
            .catch(error => {
                this.handleError(error);
            });
        }
        else
        {
            this.requiredFieldsMissingData = this.requiredFieldsMissingData.substring(0,this.requiredFieldsMissingData.length - 2);
            this.handleError('Error: Missing Required Field Values: ' + this.requiredFieldsMissingData + '.');
            this.loaded = true;
        }
    }

    handleLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
                
            if(selection[0].subtitle == "Point of Contact")
            {
                this.pointOfContactId = selection[0].id;
                this.pointOfContactName = selection[0].title;
            }
            else if (selection[0].subtitle == "Collector")
            {
                this.collectorId = selection[0].id;
                this.collectorName = selection[0].title;
            }
            else if (selection[0].subtitle == "Parent Account")
            {
                this.parentId = selection[0].id;
                this.parentName = selection[0].title;
            }
            else if (selection[0].subtitle == "Territory")
            {
                this.territoryId = selection[0].id;
                this.territoryName = selection[0].title;
            }
        }
        else
        {
            if(event.target.name == "acc_pointOfContact")
            {
                this.pointOfContactId = '';
                this.pointOfContactName = '';
            }
            else if (event.target.name == "acc_collector")
            {
                this.collectorId = '';
                this.collectorName = '';
            }
            else if (event.target.name == "acc_parentAccount")
            {
                this.parentId = '';
                this.parentName = '';
            }
            else if (event.target.name == "acc_territory")
            {
                this.territoryId = '';
                this.territoryName = '';
            }
        }
    }

    handleInputChange(event){
        if(event.target.name == "acc_AccountName")
            this.accountName = event.target.value;
        else if (event.target.name == "acc_formerName")
            this.formerName = event.target.value;
        else if (event.target.name == "acc_marketSegment")
        {
            this.marketSegment = event.target.value;
            GetSubSegmentValues({marketSegment: event.target.value}).then(subSegmentData =>{
                var tempArray = [];

                subSegmentData.forEach(x =>{
                    tempArray.push({value: String(x), label: String(x)});
                });
                this.subSegmentList = tempArray; 
                this.subSegment = '';           
            }); 
            
            this.getNationalTerritoryList();
        }
        else if (event.target.name == "acc_subSegment")
            this.subSegment = event.target.value;
        else if (event.target.name == "acc_CustomerNumber")
            this.customerNumber = event.target.value;
        else if (event.target.name == "acc_arcFac")
            this.arcFac = event.target.value;
        else if (event.target.name == "acc_dodgeCompanyId")
            this.dodgeCompanyID = event.target.value;
        else if (event.target.name == "acc_category")
            this.category = event.target.value;
        else if (event.target.name == "acc_inactive")
            this.inactive = event.target.checked;
        else if (event.target.name == "acc_level")
            this.level = event.target.value;
        else if (event.target.name == "acc_cia")
            this.cia = event.target.checked;
        else if (event.target.name == "acc_nationalTerritory")
            this.nationalTerritory = event.target.value;
        else if (event.target.name == "acc_recordType")
        {
            this.recordType = event.target.value;
            this.recordTypeName = event.target.options.find(opt => opt.value === event.detail.value).label;
            
            var tempArray = [];
            this.subSegmentList = tempArray; 
            this.subSegment = '';  
            this.marketSegment = '';
            this.marketSegmentList = tempArray;

            GetMarketSegmentValues({recordTypeId: this.recordType}).then(marketSegment =>{
                var tempArray2 = [];

                marketSegment.forEach(x =>{
                    tempArray2.push({value: String(x), label: String(x)});
                });
                this.marketSegmentList = tempArray2;
            });
           
        }
        else if (event.target.name == "acc_syncGPOPricing")
            this.syncGPOPricing = event.target.checked;
        else if (event.target.name == "acc_syncPriceLevel")
            this.syncPriceLevel = event.target.checked;
        else if (event.target.name == "acc_priceLevel")
            this.priceLevel = event.target.value;
        else if (event.target.name == "acc_phoneNumber")
            this.phoneNumber = event.target.value;
        else if (event.target.name == "acc_website")
            this.website = event.target.value;
        else if (event.target.name == "acc_balance")
            this.balance = event.target.value;
        else if (event.target.name == "acc_creditHold")
            this.creditHold = event.target.checked;
        else if (event.target.name == "acc_creditApplicationReceived")
            this.creditApplicationReceived = event.target.value;
        else if (event.target.name == "acc_creditLimit")
            this.creditLimit = event.target.value;
        else if (event.target.name == "acc_availableCredit")
            this.availableCredit = event.target.value;
        else if (event.target.name == "acc_paymentTerms")
            this.paymentTerms = event.target.value;
        else if (event.target.name == "acc_numberOfOpenOrders")
            this.numberOfOpenOrders = event.target.value;
        else if (event.target.name == "acc_hardCopyPORequired")
            this.hardCopyPORequired = event.target.checked;
        else if (event.target.name == "acc_openOrderValue")
            this.openOrderValue = event.target.value;
        else if (event.target.name == "acc_netsuiteAddDate")
            this.netsuiteAddDate = event.target.value;
        else if (event.target.name == "acc_lastCallDate")
            this.lastCallDate = event.target.value;
        else if (event.target.name == "acc_lastCallOrVisitDate")
            this.lastCallOrVisitDate = event.target.value;
        else if (event.target.name == "acc_lastVisitDate")
            this.lastVisitDate = event.target.value;
        else if (event.target.name == "acc_lastSampleRequestDate")
            this.lastSampleRequestDate = event.target.value;
        else if (event.target.name == "acc_description")
            this.description = event.target.value;
        else if (event.target.name == "acc_salesforceMapsOverridden")
            this.salesforceMapsOverridden = event.target.checked;
        else if (event.target.name == "acc_invoiceEmail")
            this.invoiceEmail = event.target.value;
        else if (event.target.name == "acc_shippingStreetAddress")
            this.shippingStreetAddress = event.target.value;
        else if (event.target.name == "acc_shippingCity")
            this.shippingCity = event.target.value;
        else if (event.target.name == "acc_shippingState")
            this.shippingState = event.target.value;
        else if (event.target.name == "acc_shippingZipCode")
        {
            this.shippingZipCode = event.target.value;           
        }           
        else if (event.target.name == "acc_shippingCountry")
            this.shippingCountry = event.target.value;
        else if (event.target.name == "acc_billingStreetAddress")
            this.billingStreetAddress = event.target.value;
        else if (event.target.name == "acc_billingCity")
            this.billingCity = event.target.value;
        else if (event.target.name == "acc_billingState")
            this.billingState = event.target.value;
        else if (event.target.name == "acc_billingZipCode")
        {
            this.billingZipCode = event.target.value;
        }           
        else if (event.target.name == "acc_billingCountry")
            this.billingCountry = event.target.value;
        else if (event.target.name == "acc_vatNumber")
            this.vatNumber = event.target.value;        
        else if (event.target.name == "chk_syncContactAddress")
            this.syncContactAddress = event.target.checked;
        else if (event.target.name == "chk_syncContactPhone")
            this.syncContactPhone = event.target.checked;
        else if (event.target.name == "acc_lockPriceLevel")
            this.lockPriceLevel = event.target.checked;
    }

    lookupZipCode(event)
    {
        if (event.target.name == "acc_billingZipCode")
        {
            this.billingZipCode = event.target.value;
            if(this.billingZipCode != null && this.billingZipCode != '')
            {
                this.isLoaded = false;
                GetStateCityFromZip({ zipCode: this.billingZipCode }).then(results =>{
                    var data = JSON.parse(results);
                    if(data.Status)
                    {
                        if(data.City != null)
                            this.billingCity = data.City;
                        if(data.State != null)
                            this.billingState = data.State;
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
        else if (event.target.name == "acc_shippingZipCode")
        {   
            this.shippingZipCode = event.target.value;
            if(this.shippingZipCode != null && this.shippingZipCode != '')
            {
                this.isLoaded = false;
                GetStateCityFromZip({ zipCode: this.shippingZipCode }).then(results =>{
                    var data = JSON.parse(results);
                    if(data.Status)
                    {
                        if(data.City != null)
                            this.shippingCity = data.City;
                        if(data.State != null)
                            this.shippingState = data.State;
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

    handleParentAccountSearch(event){
        const target = event.target;
        //console.log(event.target.value);
        AccountSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleTerritorySearch(event){
        const target = event.target;
        //console.log(event.target.value);
        TerritorySearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.contactList.filter(contact => {
            return contact.Id == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
    }

    handleCheckAllChecked(event) {
        if (this.contactList.length > 0) {          
            this.contactList.forEach(option => {
                option.Selected = event.target.checked;
            });
        }
    }

    handleCollectorSearch(event){
        const target = event.target;
        //console.log(event.target.value);
        UserSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    openContactWindow(event)
    {
        this.isContactPaneOpen = true;
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
        //this.template.querySelector("[data-id='acc_fieldDiv']").style.height = '1px'; 
    }

    closeContactWindow(event)
    {
        this.leavingContactPane = true;
        this.syncContactPhone = false;
        this.syncContactAddress = false;
        if (this.contactList.length > 0) {          
            this.contactList.forEach(option => {
                option.Selected = false;
            });
        }
        this.isContactPaneOpen = false;
        //this.setFieldPermissionAttributes();
    }

    handlePointOfContactSearch(event){
        const target = event.target;
        //console.log(event.target.value);
        ContactSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
            });
    }

    handleError(error) {
        //console.log(error);
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
}