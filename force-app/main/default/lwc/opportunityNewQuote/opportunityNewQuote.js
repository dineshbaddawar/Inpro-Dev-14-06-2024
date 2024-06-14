import {
    LightningElement,
    track,
    api
} from 'lwc';

import createQuote from '@salesforce/apex/OpportunityNewQuoteHelper.createQuote';
import getOpportunity from '@salesforce/apex/OpportunityNewQuoteHelper.getOpportunity';
import getAccountAddress from '@salesforce/apex/OpportunityNewQuoteHelper.getAccountAddress';
import getOpportunityBidders from '@salesforce/apex/OpportunityNewQuoteHelper.getOpportunityBidders';
import getContacts from '@salesforce/apex/OpportunityNewQuoteHelper.getContacts';
import getContracts from '@salesforce/apex/OpportunityNewQuoteHelper.getContracts';
import isUserEstimator from '@salesforce/apex/OpportunityNewQuoteHelper.isUserEstimator';
import userId from '@salesforce/user/Id';

import {
    NavigationMixin
} from 'lightning/navigation';
import getConstructionProject from '@salesforce/apex/OpportunityNewQuoteHelper.getConstructionProject';

export default class OpportunityNewQuote extends NavigationMixin(LightningElement) {
    
    loaded = true;
    Response = '';
    @api recordId;
    @track showContractOptions = false;
    @track quoteRecipient = '';
    @track contact = '';
    @track quoteType = '';
    @track contract = '';
    @track shippingAddressLocation = 'Project Address';
    @track quotePriority = 'Standard';
    @track createQuoteButtonVisible = true;

    @track quoteRecipientOptions = [];
    @track contactOptions = [];
    @track quoteTypeOptions = [];
    @track addressLocationOptions = [];
    @track priorityOptions = [];
    @track contractOptions = [];
    @track expirationDate;
    @track theRecord = {};
    @track contractOptionRequired = false;

    @track additionalCity = '';
    @track additionalCountry = '';
    @track additionalPostalCode = '';
    @track additionalState = '';
    @track additionalStreet = '';
    @track buildingOwnerId = '';
    @track divisionLookupId = '';
    @track oppOwnersManager = '';
    @track projectNumber = '';
    @track quoteOwner = '';
    @track primaryBidderId = '';
    @track shippingCity = '';
    @track shippingCountryCode = '';
    @track countryCode = '';
    @track shippingPostalCode = '';
    @track shippingStateCode = '';
    @track stateCode = '';
    @track shippingStreet = '';
    @track territoryLookup = '';
    @track territory = '';
    @track buildingOwnerParentId = '';
    @track constructionProjectId = '';
    @track oppAccountId = '';
    @track quoteOwnerId = '';
    @track isEstimator = false;
        
    connectedCallback() {
        //set shipping address option set values
        var projectAddressOption = {
            label: 'Project Address',
            value: 'Project Address'
        };
        var buildingOwnerOption = {
            label: 'Building Owner',
            value: 'Building Owner'
        };
        var primaryBidderOption = {
            label: 'Primary Bidder',
            value: 'Primary Bidder'
        };       

        this.addressLocationOptions = [...this.addressLocationOptions, projectAddressOption];
        this.addressLocationOptions = [...this.addressLocationOptions, buildingOwnerOption];
        this.addressLocationOptions = [...this.addressLocationOptions, primaryBidderOption];

        this.theRecord["lcb_CopyShippingAddressFrom"] = 'Project Address';

        //set priority option set values
        var standardPriorityOption = {
            label: 'Standard',
            value: 'Standard'
        };
        var rushPriorityOption = {
            label: 'Rush',
            value: 'Rush'
        };      
        
        //Set default values
        this.theRecord["lcb_Priority"] = 'Standard';

        this.priorityOptions = [...this.priorityOptions, standardPriorityOption];
        this.priorityOptions = [...this.priorityOptions, rushPriorityOption];

        //set default Expiration Date
        var date = new Date();
        date.setDate(date.getDate() + 90);
        this.expirationDate = date.toISOString();
        this.theRecord["dt_quoteExpirationDate"] = date.toISOString();

        //determine quote type options
        isUserEstimator({
            userId: userId
        }).then(data => {
                try {
                    if(data != null && data == true)
                    {
                        var estimateDetailOption = {
                            label: 'Estimate Detail',
                            value: 'Estimate Detail'
                        };
                        var estimateSummaryOption = {
                            label: 'Estimate Summary',
                            value: 'Estimate Summary'
                        };
                        var estimateSuperSummaryOption = {
                            label: 'Estimate Super Summary',
                            value: 'Estimate Super Summary'
                        };       
                
                        this.isEstimator = true;
                        this.quoteTypeOptions = [...this.quoteTypeOptions, estimateDetailOption];
                        this.quoteTypeOptions = [...this.quoteTypeOptions, estimateSummaryOption];
                        this.quoteTypeOptions = [...this.quoteTypeOptions, estimateSuperSummaryOption];
                        this.quoteType = 'Estimate Detail';
                        this.theRecord["lcb_QuoteType"] = 'Estimate Detail';
                    }
                    else
                    {
                        var bidOption = {
                            label: 'Bid',
                            value: 'Bid'
                        };
                        var quoteOption = {
                            label: 'Quote',
                            value: 'Quote'
                        };    
                
                        this.quoteTypeOptions = [...this.quoteTypeOptions, bidOption];
                        this.quoteTypeOptions = [...this.quoteTypeOptions, quoteOption];
                        this.quoteType = 'Bid';
                        this.theRecord["lcb_QuoteType"] = 'Bid';
                    }
                                      
                } catch (error) {
                    console.log("Error retrieving user profile: " + error);
                }           
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error retrieving the user profile: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });

        //default the revision
        this.theRecord["li_revision"] = "0";

        //add defaults for remaining dropdowns
        var pleaseSelectOption = {
            label: 'Please Select',
            value: 'Please Select'
        };
        this.quoteRecipientOptions = [...this.quoteRecipientOptions, pleaseSelectOption];
        this.contactOptions = [...this.contactOptions, pleaseSelectOption];
        this.contractOptions = [...this.contractOptions, pleaseSelectOption];

        this.quoteRecipient = 'Please Select';
        this.contact = 'Please Select';
        this.contract = 'Please Select';

        this.loadOpportunity();
        this.loadOpportunityBidders();           
        this.loaded = true;
    }

    loadOpportunity()
    {
        getOpportunity({
            recordId: this.recordId
        }).then(Opportunity => {
            if (Opportunity) {
                try {                     
                    if(Opportunity.Account != null)
                        this.oppAccountId = Opportunity.Account.Id;
                    if(Opportunity.Building_Owner_Parent__c != null)
                        this.buildingOwnerParentId = Opportunity.Building_Owner_Parent__c;
                    else
                        this.buildingOwnerParentId = Opportunity.Account.Id;
                    if(Opportunity.Construction_Project__c != null)
                        this.constructionProjectId = Opportunity.Construction_Project__c;
                    if(Opportunity.Building_Owner__c != null)
                        this.buildingOwnerId = Opportunity.Building_Owner__c;
                    if(Opportunity.Account != null)
                        this.primaryBidderId = Opportunity.Account.Id;
                    if(Opportunity.Project_Number__c != null)
                        this.projectNumber = Opportunity.Project_Number__c;
                    if(Opportunity.City__c != null)
                        this.additionalCity = Opportunity.City__c;
                    if(Opportunity.Country__c != null)
                        this.additionalCountry = Opportunity.Country__c;
                    if(Opportunity.Country_Code__c != null)
                        this.countryCode = Opportunity.Country_Code__c;
                    if(Opportunity.Zip__c != null)
                        this.additionalPostalCode = Opportunity.Zip__c;
                    if(Opportunity.State__c != null)
                        this.additionalState = Opportunity.State__c;
                    if(Opportunity.State_Code__c != null)
                        this.stateCode = Opportunity.State_Code__c;    
                    if(Opportunity.Street_Address__c != null)
                        this.additionalStreet = Opportunity.Street_Address__c;
                    if(Opportunity.Division_Lookup__r != null && Opportunity.Division_Lookup__r.Id != null)
                        this.divisionLookupId = Opportunity.Division_Lookup__r.Id;
                    if(Opportunity.Territory__r != null && Opportunity.Territory__r.Id != null)
                        this.territoryLookup = Opportunity.Territory__r.Id;
                    if(Opportunity.Territory__c != null)
                        this.territory = Opportunity.Territory__c;    
                    if(Opportunity.Owner.Manager != null && Opportunity.Owner.Manager.Id != null)
                        this.oppOwnersManager = Opportunity.Owner.Manager.Id;  
                    if(Opportunity.Construction_Project__c != null){
                        getConstructionProject({Id: Opportunity.Construction_Project__c }).then(cp =>{
                            if(cp.General_Contractor__r != null && cp.General_Contractor__r.Id != null)
                            {
                                this.constructionManagerId = cp.General_Contractor__r.Id; 
                            }
                            this.finishLoad(Opportunity);
                        });
                    }
                    else{
                        this.finishLoad(Opportunity);
                    }
                    //this.loadContacts();
                    this.loaded = true;                  
                } catch (error) {
                    console.log("Error Loading Opportunity: " + error);
                }
            } else if (error) {
                this.error = error;
                console.log(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error getting the Opportunity: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    finishLoad(Opportunity)
    {
        if(Opportunity.Account.Id != null)
            this.oppAccountId = Opportunity.Account.Id;
        if(Opportunity.Building_Owner__c != null)
            this.buildingOwnerId = Opportunity.Building_Owner__c;
        if(Opportunity.Account.Id != null)
            this.primaryBidderId = Opportunity.Account.Id;
        if(Opportunity.OwnerId != null && Opportunity.Owner.IsActive != null)
        {
            if(Opportunity.Owner.IsActive)
                this.quoteOwnerId = Opportunity.OwnerId
            else
                this.quoteOwnerId = userId
        }
        else
        {
            this.quoteOwnerId = userId
        }
        if(Opportunity.Account.Id != null && Opportunity.Account.Name != null && (Opportunity.Account.Status__c == 'Approved' || Opportunity.Account.Status__c == 'Customer'))
        {
            var addOption = true;
            for(var i = 0; i < this.quoteRecipientOptions.length; i++)
            {
                var currentOption = this.quoteRecipientOptions[i];
                if(currentOption.value != null && currentOption.value == Opportunity.Account.Id)
                {
                    addOption = false;
                    currentOption.label = currentOption.label.substring(0,currentOption.label.length - 1) + "/Opportunity Account)";  
                }
            }
            if(addOption)
            {
                var oppAccountOption = {
                    label: Opportunity.Account.Name + ' (Opportunity Account)',
                    value: Opportunity.Account.Id
                };
                this.quoteRecipientOptions = [...this.quoteRecipientOptions, oppAccountOption];
            }
        }
        if(Opportunity.Building_Owner__c != null && Opportunity.Building_Owner__r.Name != null && Opportunity.Building_Owner__c != Opportunity.Account.Id)
        {
            var addOption = true;
            for(var i = 0; i < this.quoteRecipientOptions.length; i++)
            {
                var currentOption = this.quoteRecipientOptions[i];
                if(currentOption.value != null && currentOption.value == Opportunity.Building_Owner__c)
                {
                    addOption = false;
                    currentOption.label = currentOption.label.substring(0,currentOption.label.length - 1) + "/Opportunity Building Owner)";  
                }
            }
            if(addOption)
            {
                var oppBuildingOwnerOption = {
                    label: Opportunity.Building_Owner__r.Name + ' (Opportunity Building Owner)',
                    value: Opportunity.Building_Owner__c
                };
                this.quoteRecipientOptions = [...this.quoteRecipientOptions, oppBuildingOwnerOption];
            }
        } 
        if(Opportunity.Is_Estimate_Required__c != null)
        {
            if(!Opportunity.Is_Estimate_Required__c && !this.isEstimator)
            {
                this.quoteType = 'Quote';
                this.theRecord["lcb_QuoteType"] = 'Quote';
            }
                

        }
        this.loadContracts();   
    }

    // loadContacts()
    // {
    //     getContacts({
    //         id: this.recordId,
    //         buildingOwnerId: this.buildingOwnerId,
    //         originalBidderId: this.originalBidderId
    //     }).then(data => {
    //         if (data) {
    //             try {
    //                 var myJSON = JSON.stringify(data);
    //                 console.log(myJSON);
    //                 data.forEach(Contact => {                          
    //                     if(Contact.Id != null && Contact.Name != null)
    //                     {
    //                         var contactOption = {
    //                             label: Contact.Name,
    //                             value: Contact.Id
    //                         };
    //                         this.contactOptions = [...this.contactOptions, contactOption];
    //                     }                                                                                        
    //                 });                   
    //             } catch (error) {
    //                 console.log("Error Loading Contacts: " + error);
    //             }

    //         } else if (error) {
    //             this.error = error;
    //             console.log(error);
    //         }
    //         this.loaded = true;
    //     })
    //     .catch(error => {
    //         // TODO: handle error
    //         console.log("Error retrieving the contacts: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
    //     });
    // }

    loadContracts()
    {
        getContracts({
            accountId: this.oppAccountId
        }).then(data => {
            if (data) {
                try {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(Contract__c => {                          
                        if(Contract__c.Id != null && Contract__c.Name != null)
                        {
                            var contractOption = {
                                label: Contract__c.Name + ' - ' + Contract__c.Account__r.Name + ' - ' + Contract__c.Contract_Name__c,
                                value: Contract__c.Id
                            };
                            this.contractOptions = [...this.contractOptions, contractOption];
                        }                                                                                        
                    });                   
                } catch (error) {
                    console.log("Error Loading Contracts: " + error);
                }

            } else if (error) {
                this.error = error;
                console.log(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error retrieving the contracts: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    loadOpportunityBidders()
    {
        getOpportunityBidders({
            opportunityId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    var bidderIds = [];
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    data.forEach(Bidder__c => {                          
                        if(Bidder__c.Bidder__r.Id != null && Bidder__c.Bidder__r.Name != null)
                        {
                            if(bidderIds.indexOf(Bidder__c.Bidder__r.Id) == -1)
                            {
                                var addOption = true;
                                for(var i = 0; i < this.quoteRecipientOptions.length; i++)
                                {
                                    var currentOption = this.quoteRecipientOptions[i];
                                    if(currentOption.value != null && currentOption.value == Bidder__c.Bidder__r.Id)
                                    {
                                        addOption = false;
                                        currentOption.label = currentOption.label.substring(0,currentOption.label.length - 1) + "/Bidder Account)";  
                                    }
                                }
                                if(addOption)
                                {
                                    var bidderAccountOption = {
                                        label: Bidder__c.Bidder__r.Name + ' (Bidder Account)',
                                        value: Bidder__c.Bidder__r.Id
                                    };
                                    this.quoteRecipientOptions = [...this.quoteRecipientOptions, bidderAccountOption];
                                }
                                bidderIds.push(Bidder__c.Bidder__r.Id);
                            }
                        }                                                                                        
                    });                   
                } catch (error) {
                    console.log("Error Loading Contracts: " + error);
                }

            } else if (error) {
                this.error = error;
                console.log(error);
            }
            this.loaded = true;
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error retrieving the contracts: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    handleInputOnChange(event) {
        console.log("check");
        if (event.target.name == "chk_relateToContract") {
            this.showContractOptions = event.target.checked;
            this.contractOptionRequired = event.target.value;
        }
        else if(event.target.name == "lcb_quoteRecipient")
        {
            this.theRecord[event.target.name] = event.target.value;
            this.contactOptions = [];
            var pleaseSelectContactOption = {
                label: 'Please Select',
                value: 'Please Select'
            };
            this.contactOptions = [...this.contactOptions, pleaseSelectContactOption];
            getContacts({
                accountId: event.target.value
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(Contact => {                          
                            if(Contact.Id != null && Contact.Name != null)
                            {
                                var contactOption = {
                                    label: Contact.Name,
                                    value: Contact.Id
                                };
                                this.contactOptions = [...this.contactOptions, contactOption];
                            }                                                                                        
                        });                   
                    } catch (error) {
                        console.log("Error Loading Contacts: " + error);
                    }
    
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error retrieving the contacts: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
           
        } 
        else {
            this.theRecord[event.target.name] = event.target.value;
        }
    }

    handleComboBoxOnChange(){

    }

    handleCreateQuoteClick(){
        console.log("TEST");
        this.Response = "";
        this.loaded = false;
        var missingInformationComponents = "";
        if(this.theRecord["li_versiondescription"] == null || this.theRecord["li_versiondescription"] == "")
            missingInformationComponents += "Version Description" + ", ";
        if(this.theRecord["li_revision"] == null || this.theRecord["li_revision"] == "")
            missingInformationComponents += "Revision" + ", ";
        if(this.theRecord["dt_quoteExpirationDate"] == null || this.theRecord["dt_quoteExpirationDate"] == "")
            missingInformationComponents += "Expiration Date" + ", ";
        if(this.theRecord["lcb_QuoteType"] != null && this.theRecord["lcb_QuoteType"] == "Quote" && !this.isEstimator)
        {
            if(this.theRecord["lcb_quoteRecipient"] == null || this.theRecord["lcb_quoteRecipient"] == "" || this.theRecord["lcb_quoteRecipient"] == "Please Select")
                missingInformationComponents += "Quote Recipient" + ", ";
            if(this.theRecord["lcb_Contact"] == null || this.theRecord["lcb_Contact"] == "" || this.theRecord["lcb_Contact"] == "Please Select")
                missingInformationComponents += "Contact" + ", ";
        }
        if(this.theRecord["lcb_QuoteType"] == null || this.theRecord["lcb_QuoteType"] == "" || this.theRecord["lcb_QuoteType"] == "Please Select")
            missingInformationComponents += "" + ", ";
        if(this.theRecord["lcb_CopyShippingAddressFrom"] == null || this.theRecord["lcb_CopyShippingAddressFrom"] == "" || this.theRecord["lcb_CopyShippingAddressFrom"] == "Please Select")
            missingInformationComponents += "Copy Shipping Address From" + ", ";
        if(this.theRecord["lcb_Priority"] == null || this.theRecord["lcb_Priority"] == "" || this.theRecord["lcb_Priority"] == "Please Select")
            missingInformationComponents += "Priority" + ", ";
        if(this.showContractOptions)
        {
            if(this.theRecord["lcb_attachToContract"] == null || this.theRecord["lcb_attachToContract"] == "" || this.theRecord["lcb_attachToContract"] == "Please Select")
                missingInformationComponents += "Attach to Contract" + ", ";
        }
        console.log(this.buildingOwnerId);
        if(this.theRecord["lcb_CopyShippingAddressFrom"] == "Building Owner" && this.buildingOwnerId == "")
        {
            this.Response = "Error: You've selected to use the building owner's shipping address, but the opportunity does not have a building owner specified.";
            this.loaded = true;
            return;
        }
        else if(this.theRecord["lcb_CopyShippingAddressFrom"] == "Primary Bidder" && this.primaryBidderId == "")
        {
            this.Response = "Error: You've selected to use the primary bidder's shipping address, but the opportunity does not have a primary bidder specified.";
            this.loaded = true;
            return;
        }

        if(missingInformationComponents != "")
        {
            missingInformationComponents = missingInformationComponents.substring(0,missingInformationComponents.length - 2);
            this.Response = "Error: There are fields that are missing information. Please enter values for the following fields: " + missingInformationComponents + ".";
            this.loaded = true;
            return;
        }           
        else
        {
            var shippingAddressAccountId = this.oppAccountId;
            if(this.theRecord["lcb_CopyShippingAddressFrom"] == "Project Address")
            {
                this.theRecord["ShippingCity"] = this.additionalCity;
                this.theRecord["ShippingStreet"] = this.additionalStreet; 
                this.theRecord["ShippingCountryCode"] = this.countryCode;
                this.theRecord["ShippingPostalCode"] = this.additionalPostalCode; 
                this.theRecord["ShippingStateCode"] = this.stateCode;
            }
            else if(this.theRecord["lcb_CopyShippingAddressFrom"] == "Building Owner")
                shippingAddressAccountId = this.buildingOwnerId;
            else if(this.theRecord["lcb_CopyShippingAddressFrom"] == "Primary Bidder")
                shippingAddressAccountId = this.primaryBidderId;

            if(this.theRecord["lcb_quoteRecipient"] == null || this.theRecord["lcb_quoteRecipient"] == "")
                this.theRecord["lcb_quoteRecipient"] = this.oppAccountId;
            
            getAccountAddress({
                accountId: shippingAddressAccountId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(Account => {                          
                            if(this.theRecord["lcb_CopyShippingAddressFrom"] != "Project Address")
                            {
                                if(Account.ShippingCity != null)
                                    this.theRecord["ShippingCity"] = Account.ShippingCity;
                                if(Account.ShippingStreet != null)
                                    this.theRecord["ShippingStreet"] = Account.ShippingStreet; 
                                if(Account.ShippingCountryCode != null)
                                    this.theRecord["ShippingCountryCode"] = Account.ShippingCountryCode; 
                                if(Account.ShippingPostalCode != null)
                                    this.theRecord["ShippingPostalCode"] = Account.ShippingPostalCode; 
                                if(Account.ShippingStateCode != null)
                                    this.theRecord["ShippingStateCode"] = Account.ShippingStateCode;  
                            }                                                       
                        });
                        
                        createQuote({
                            additionalCity: this.additionalCity,
                            additionalCountry: this.additionalCountry,
                            additionalPostalCode: this.additionalPostalCode,
                            additionalState: this.additionalState,
                            additionalStreet: this.additionalStreet,
                            bidQuote: this.theRecord["lcb_QuoteType"],
                            contactId: this.theRecord["lcb_Contact"],
                            divisionLookup: this.divisionLookupId,
                            expirationDate: this.theRecord["dt_quoteExpirationDate"],
                            inpro_Contract: this.theRecord["lcb_attachToContract"],
                            name: this.projectNumber,
                            oppownersManager: this.oppOwnersManager,
                            opportunityId: this.recordId,
                            ownerId: this.quoteOwnerId,
                            primaryBidder: this.primaryBidderId,
                            priority: this.theRecord["lcb_Priority"],
                            revisionNumber: this.theRecord["li_revision"],
                            shippingCity: this.theRecord["ShippingCity"],
                            shippingCountryCode: this.theRecord["ShippingCountryCode"],
                            shippingPostalCode: this.theRecord["ShippingPostalCode"],
                            shippingStateCode: this.theRecord["ShippingStateCode"],
                            shippingStreet: this.theRecord["ShippingStreet"],
                            territoryLookup: this.territoryLookup,
                            territory: this.territory,
                            versionDescription: this.theRecord["li_versiondescription"],
                            quoteRecipientId: this.theRecord["lcb_quoteRecipient"]
                        }).then(data => {
                            if (data) {
                                try {
                                    if(!data.toLowerCase().includes("error"))
                                    {
                                        this.createQuoteButtonVisible = false;
                                        this.Response = "Success!";
                                        document.location = "https://" + location.hostname + "/lightning/r/Quote/" + data + "/view";
                                        this.loaded = true;
                                    }
                                    else
                                    {
                                        this.Response = data;
                                        console.log(data);
                                        this.loaded = true;
                                    }
                                    
                                } catch (error) {
                                    console.log("Error Creating Quote: " + error);
                                }
                
                            } else if (error) {
                                this.error = error;
                                console.log(error);
                            }
                        })
                        .catch(error => {
                            // TODO: handle error
                            console.log("Error creating quote: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                        });
                    } catch (error) {
                        console.log("Error Loading Shipping Account: " + error);
                    }
    
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }                
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error retrieving the shipping account: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
        }        
    }
    
    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}