import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getQuote from '@salesforce/apex/RequestOrderHelper.getQuote';
import getAlternates from '@salesforce/apex/RequestOrderHelper.getAlternates';
import createOrderRequest from '@salesforce/apex/RequestOrderHelper.createOrderRequest';
import getBidders from '@salesforce/apex/RequestOrderHelper.getBidders';
import contractSearch from '@salesforce/apex/RequestOrderHelper.contractSearch';
import contactSearch from '@salesforce/apex/RequestOrderHelper.contactSearch';
import buildingOwnerSearch from '@salesforce/apex/RequestOrderHelper.buildingOwnerSearch';
import buildingOwnerParentSearch from '@salesforce/apex/RequestOrderHelper.buildingOwnerParentSearch';
import getSalesRepNumbers from '@salesforce/apex/RequestOrderHelper.getSalesRepNumbers';
import validateCustomProducts from '@salesforce/apex/RequestOrderHelper.validateCustomProducts';
import getRCAReasons from '@salesforce/apex/RequestOrderHelper.getRCAReasons';
import getRCACategories from '@salesforce/apex/RequestOrderHelper.getRCACategories';
import isAccountOnCreditHOld from '@salesforce/apex/RequestOrderHelper.isAccountOnCreditHOld';
import GetContract from '@salesforce/apex/RequestOrderHelper.getContract';
import getContractById from '@salesforce/apex/RequestOrderHelper.getContractById';
import WillOrderExceedContractedAmount from '@salesforce/apex/RequestOrderHelper.willOrderExceedContractedAmount';
import userId from '@salesforce/user/Id';
//import CheckDeniedPartyStatus from '@salesforce/apex/DeniedPartyHelper.CheckDeniedPartyStatus';
import getAccount from '@salesforce/apex/RequestOrderHelper.getAccount';
import isBidderTaxExempt from '@salesforce/apex/RequestOrderHelper.isBidderTaxExempt';
import validateAddress from '@salesforce/apex/AddressValidationHelper.ValidateAddressOne';
import getOrderNumber from '@salesforce/apex/RequestOrderHelper.getOrderNumber';

export default class RequestOrder extends LightningElement {

    @track CreditHold = false;
    @api recordId;
    @track loadMessage = 'Loading...';
    @track loaded = false;
    @track showError = false;
    @track contractMessage = '';
    @track errorMessage = '';

    @track AccountName = '';
    @track QuoteName = '';
    @track MarketSegment = '';
    @track PaymentTerms = '';
    @track theRecord = {};
    @track orderRequested = false;
    @track NoChargeOrder = false;
    @track accountList = [];
    @track accountId = '';
    @track selectedContract = [];
    @track selectedContact = [];
    @track selectedBuildingOwner = [];
    @track selectedbuildingOwnerParent = [];
    @track contractId = '';
    @track contactId = '';
    @track subTotal;
    @track NetSuiteId = '';
    @track salesRepNumbers = [];
    @track shipToName = '';
    @track shipToContactName = '';
    @track shipToContactPhoneNumber = '';
    @track shipToAddress1 = '';
    @track shipToAddress2 = '';
    @track shipToCity = '';
    @track shipToState = '';
    @track shipToZip = '';
    @track shipToCountry = '';
    @track shipToAddress = '';
    @track endUserParentCustomerNumber = '';
    @track quoteLineList = [];
    @track hasCustomParts = false;
    @track rcaReasonList = [];
    @track rcaCategoryList = [];
    @track alternateList = [];
    @track selectedAlternates = [];
    @track contactObj = {};
    //@track contactSelection = [];
    @track originalOrderNumber = '';
    @track originialInvoiceNumber = '';
    @track noChargeReasonCode = '';
    @track noChargeCategoryCode = '';
    @track explanation = '';
    @track sameDayOrder = false;
    @track poNumber = '';
    @track shippingInstructions = '';
    @track rcaCategory = '';
    @track rcaReason = '';
    @track customerNumber = '';
    @track overContractAmount = 0;
    @track approvedForOverContractValue = 0;
    @track approvedForOverContract = false;
    @track showContractApprovalButton = false;
    @track oppOwnersManagerId = '';
    @track division = '';
    @track contractSubmittalNotes = '';
    @track FinanceNote = '';
    @track AccountInactive = false;
    @track alternateScreenActive = true;
    @track headerScreenActive = false;
    @track selectedTotal = 0;
    @track selectedTotalExcludingTax = 0;
    @track selectedTotalIncludingTax = 0;
    @track creditHoldScreenOpen = false;
    @track deniedPartyMessageSent = false;
    @track orderIsTaxable = true;
    @track shippingStateCode = '';
    @track additionalStateCode = '';
    @track needsContractNotExecutedApproval = false;
    @track addressValidationComplete = false;
    @track proposedAddress1 = '';
    @track proposedAddress2 = '';
    @track proposedCity = '';
    @track proposedState = '';
    @track proposedZip = '';
    @track enableProposed = false;
    @track runAgain = false;
    @track showAddressValidationPane = false;
    @track isRerunningAddressValidation = false;
    @track addressValidationDetail = '';
    @track contractNotExecutedNotes = '';
    @track needsCreditHoldApproval = false;
    @track availableCredit = '';
    @track manualOrderTotal;
    @track isLargeManualOrderTotal = false;
    @track isBulkPackageAlternateSelected = false;
    @track bulkPackageActions = [];
    @track selectedBulkPackageAction = '';
    @track selectedAlternateIdsString = '';
    @track buildingOwnerId = '';
    @track buildingOwnerParentId = '';
    @track buildingOwnerNeeded = false;
    @track buildingOwnerAndParentMissing = false;
    @track accountBillingCountry = '';
    @track accountBillingAddressINTL = false;
    @track bypassBuildingOwner = false;
    @track contractPaymentTerms = '';

    @track alternateColumns = [
        {label: 'Name', fieldName: 'name',  type: 'text', sortable: true },
        {label: 'Sequence #', fieldName: 'sequenceNumber',  type: 'text', sortable: true },
        {label: 'Material Total', fieldName: 'totalMaterial', sortable: true, type: 'currency', typeAttributes: { curencyCode: 'USD'} },
        {label: 'Freight Amount', fieldName: 'freightAmount' , sortable: true, type: 'currency', typeAttributes: { curencyCode: 'USD'}},
        {label: 'Tax', fieldName: 'totalTax' , sortable: true, type: 'currency', typeAttributes: { curencyCode: 'USD'}},
        {label: 'Total (incl Freight/ No Tax)', fieldName: 'totalInclFreightNoTax', type: 'currency' , sortable: true},
        {label: 'Total (Incl Freight/Tax)', fieldName: 'totalInclFreightTax', type: 'currency' , sortable: true},
        {label: 'Bulk Packagable', fieldName: 'bulkPackagable', sortable: true}
    ];

    connectedCallback() {
        this.theRecord['CreditApproval'] = false;
        this.theRecord['SameDayOrder'] = false;
        this.theRecord['NoChargeOrder'] = false;
        this.theRecord['InvoiceDetail'] = true;
        this.theRecord['RequiresCustomParts'] = false;

        var yesOption = {
            label: 'Yes',
            value: 'Yes'
        };

        var noOption = {
            label: 'No',
            value: 'No'
        };

        var reviewLaterOption = {
            label: 'Review Later',
            value: 'Review Later'
        };
        
        this.bulkPackageActions = [...this.bulkPackageActions, yesOption];
        this.bulkPackageActions = [...this.bulkPackageActions, noOption];
        this.bulkPackageActions = [...this.bulkPackageActions, reviewLaterOption];

        this.loaded = false;
        this.loadQuoteInfo();
        //this.getContract();
    }

    renderedCallback()
    {
        const existing = this.salesRepNumbers.find(x => x.value == this.NetSuiteId);
        if (existing) {
            const startSelect = this.template.querySelector('.sales-rep-combo');
            console.log(startSelect);
            if (startSelect) {
                startSelect.value = existing.value;

            }
        }
    }

    checkCreditHold() {
        isAccountOnCreditHOld({
                customerNumber: this.customerNumber
            }).then(data => {
                //if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        this.CreditHold = data;
                        if(this.CreditHold != null && this.CreditHold)
                            this.creditHoldScreenOpen = true;
                        this.getContract();
                        this.checkTaxExemptStatus();
                        this.loaded = true;

                    } catch (error) {
                        console.log("Error Checking CreditHold: " + error);
                    }
                //}
                //else
                //{
                    //this.retrieveAlternates();
                    //this.loadBidders();
                    //this.getCustomPartNumbers();
                    //this.loadRCACategories();
                    //this.CreditHold = data;
                //}              
            })
            .catch(error => {
                console.log("Error Checking CreditHold: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
            });
    }

    handleDataTableInput(event)
    {
        let selectedRows = event.detail.selectedRows;
        var tempTotal = 0;
        var tempTotalWithoutTax = 0;
        var bulkPackageAltSelected = false;
        console.log('alternate string is [');
        if (event.target.name == 'alternates')
        {            
            var tempArray = [];
            for (let i = 0; i < selectedRows.length; i++) {
                
                tempArray.push(selectedRows[i].Id);
             
                var id = selectedRows[i].Id;
                let selectedItem = this.alternateList.filter(function (a) {
                    return a.Id === id;
                })[0];

                if(selectedItem != null)
                {
                    if(selectedItem.totalInclFreightTax != null)
                        tempTotal += parseFloat(selectedItem.totalInclFreightTax);
                    if(selectedItem.totalInclFreightNoTax != null)
                        tempTotalWithoutTax += parseFloat(selectedItem.totalInclFreightNoTax);
                    if(selectedItem.bulkPackagable != null && selectedItem.bulkPackagable == true)
                        bulkPackageAltSelected = true;
                }
            }

            this.isBulkPackageAlternateSelected = bulkPackageAltSelected;
            if(!this.isBulkPackageAlternateSelected)
                this.selectedBulkPackageAction = '';
            this.selectedTotalExcludingTax = tempTotalWithoutTax;
            this.selectedTotalIncludingTax = tempTotal;
            
            if(this.orderIsTaxable && (this.shipToCountry == 'United States'))
            {
                if(this.NoChargeOrder)
                {
                    this.theRecord["OrderAmount"] = 0;
                    this.selectedTotal = 0;
                }
                else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
                {
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                }
                else
                {
                    this.theRecord["OrderAmount"] = this.selectedTotalIncludingTax;
                    this.selectedTotal = this.selectedTotalIncludingTax;
                }
            }
            else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
            {
                this.selectedTotal = this.manualOrderTotal;
                this.theRecord["OrderAmount"] = this.manualOrderTotal;
            }
            else
            {
                if(this.NoChargeOrder)
                {
                    this.theRecord["OrderAmount"] = 0;
                    this.selectedTotal = 0;
                }
                else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
                {
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                }
                else
                {
                    this.theRecord["OrderAmount"] = this.selectedTotalExcludingTax;
                    this.selectedTotal = this.selectedTotalExcludingTax;
                }
            }
            this.selectedAlternates = tempArray;
        }       
    }

    closeCreditHoldPopUp() {
        this.needsCreditHoldApproval = true;
        this.CreditHold = false;
        this.creditHoldScreenOpen = false;
    }

    loadBidders() {
        getBidders({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        var bidderCounter = 1;
                        var hasActiveApprovedAccounts = false;
                        var firstAccountId = '';
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        var firstContact = {};
                        
                        data.forEach(bidder => {

                            if (bidder.Bidder_Name__r != null && bidder.Bidder_Name__r.Bidder__r != null) {
                                if (bidder.Bidder_Name__r.Bidder__r.Inactive__c == false && (bidder.Bidder_Name__r.Bidder__r.Status__c == 'Approved' || bidder.Bidder_Name__r.Bidder__r.Status__c == 'Customer')) {
                                    this.hasActiveApprovedAccounts = true;
                                    var option = {
                                        label: bidder.Bidder_Name__r.Bidder__r.Name + ' (' + bidder.Bidder_Name__r.Bidder__r.Customer_Number__c + ')',
                                        value: bidder.AccountId__c
                                    };

                                    this.accountList = [...this.accountList, option];
                                    if(bidderCounter == 1)
                                    {
                                        firstAccountId = bidder.AccountId__c;
                                        if(bidder.Bidder_Name__r != null && bidder.Bidder_Name__r.Contact__c != null)
                                        {
                                            firstContact.id = bidder.Bidder_Name__r.Contact__c;
                                            firstContact.sObjectType = 'Contact';
                                            firstContact.icon = 'standard:account';
                                            firstContact.title = bidder.Contact_Name__c;
                                            firstContact.subtitle = bidder.Contact_Name__c;
                                        }
                                    }
                                    bidderCounter++;
                                }
                            }
                        });
                        if (data.length == 0)
                        {
                            this.handleError('Error: There are no Quote Bidders associated with this Quote.');
                        }
                        else if (!this.hasActiveApprovedAccounts)
                            this.handleError('Error: All bidders on this quote are either inactive or not approved. Please contact Finance to review the associated account.');

                        if (this.accountList.length === 1) {
                            console.log(this.accountList[0].value);
                            this.theRecord["Bidder"] = this.accountList[0].value;
                            this.accountId = firstAccountId;
                            this.retrieveAccountInformation();
                            
                            this.selectedContact = firstContact;
                            this.theRecord["ContactId"] = firstContact.id;
                            this.contactId = firstContact.id;
                        }
                        this.loaded = true;

                    } catch (error) {
                        this.handleError(error);
                        console.log("Error Loading Bidders: " + error);
                    }

                } else if (error) {
                    console.log(error);
                    this.handleError(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting Bidders: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
            });
    }

    loadQuoteInfo() {
        getQuote({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        this.AccountName = data.Account.Name;
                        this.QuoteName = data.Name;
                        this.MarketSegment = data.Opportunity.Market_Segment__c;
                        //this.PaymentTerms = data.Account.Payment_Terms__c;
                        this.accountId = data.AccountId__c;
                        this.subTotal = data.Subtotal;
                        //this.theRecord["OrderAmount"] = data.Subtotal;
                        this.NetSuiteId = data.Opportunity.Owner.NetSuite_Id__c;
                        this.loadSalesRepNumbers();
                        this.theRecord["RepNumber"] = data.Opportunity.Owner.NetSuite_Id__c;
                        if (data.ShippingName != null && data.ShippingName != '')
                            this.theRecord["shipToName"] = data.ShippingName;
                        this.shipToName = data.ShippingName;
                        this.shipToAddress = data.ShippingStreet + ' ' + data.ShippingCity + ', ' + data.ShippingState + ' ' + data.ShippingPostalCode + ' ' + data.ShippingCountry;

                        this.shipToContactName = '';
                        this.shipToContactPhoneNumber = '';
                        this.shipToAddress1 = data.ShippingStreet;
                        this.shipToAddress2 = '';
                        this.shipToCity = data.ShippingCity;
                        this.shipToState = data.ShippingState;
                        this.shipToZip = data.ShippingPostalCode;
                        this.shipToCountry = data.ShippingCountry;
                        //this.customerNumber = data.Account.Customer_Number__c;
                        if (data.ShippingStreet != null && data.ShippingStreet != '')
                            this.theRecord["shipToAddress1"] = data.ShippingStreet;
                        if (data.ShippingCity != null && data.ShippingCity != '')
                            this.theRecord["shipToCity"] = data.ShippingCity;
                        if (data.ShippingState != null && data.ShippingState != '')
                            this.theRecord["shipToState"] = data.ShippingState;
                        if (data.ShippingPostalCode != null && data.ShippingPostalCode != '')
                            this.theRecord["shipToZip"] = data.ShippingPostalCode;
                        if (data.ShippingCountry != null && data.ShippingCountry != '')
                        {
                            this.theRecord["shipToCountry"] = data.ShippingCountry;
                            if(this.shipToCountry != 'United States')
                                this.orderIsTaxable = false;
                        }
                        if (data.Division__c != null)
                            this.division = data.Division__c;
                        if (data.Primary_Bidder__r != null && data.Primary_Bidder__r.Point_of_Contact__c != null && data.Primary_Bidder__r.Point_of_Contact__c != '') {
                            this.theRecord["ContactId"] = data.Primary_Bidder__r.Point_of_Contact__c;
                            this.contactId = data.Primary_Bidder__r.Point_of_Contact__c;
                        }
                        if (data.AdditionalStateCode != null)
                            this.additionalStateCode = data.AdditionalStateCode;
                        if (data.ShippingStateCode != null)
                            this.shippingStateCode = data.ShippingStateCode;
                        if(data.OwnerId != null)
                            this.theRecord['quoteOwner'] = data.OwnerId;
                        //this.contactSelection.push({icon: 'standard:account', id: data.Primary_Bidder__r.Point_of_Contact__c, sObjectType: 'contact', title: 'contactName', titleFormatted: 'contactName'});
                        //this.contactSelection = new LookupSearchResult(, 'contact', 'standard:account', 'contactName', ' - ' + data.Account.Name);

                        // if (data.AccountId != null) {
                        //     var option = {
                        //         label: data.Account.Name + ' (' + data.Account.Customer_Number__c + ')',
                        //         value: data.AccountId
                        //     };

                        //     this.accountList = [...this.accountList, option];
                        //     this.accountId = data.AccountId;
                        // }

                        if (data.Primary_Bidder__r != null && data.Primary_Bidder__r.Id != null) {
                            // var option = {
                            //     label: data.Primary_Bidder__r.Name + ' (' + data.Primary_Bidder__r.Customer_Number__c + ')',
                            //     value: data.Primary_Bidder__r.Id
                            // };

                            // this.accountList = [...this.accountList, option];

                            if (this.accountId = '')
                                this.accountId = data.Primary_Bidder__r.Id
                        }
                        if (data.Opportunity != null && data.Opportunity.Building_Owner_Parent__r != null && data.Opportunity.Building_Owner_Parent__r.Customer_Number__c != null && data.Opportunity.Building_Owner_Parent__r.Level__c != null && data.Opportunity.Building_Owner_Parent__r.Level__c == 'National') {
                            if (data.Opportunity.Building_Owner_Parent__r.Customer_Number__c == '669396')
                                this.endUserParentCustomerNumber = '470379-0006';
                            else if (data.Opportunity.Building_Owner_Parent__r.Job_Number_Excluded__c == null || data.Opportunity.Building_Owner_Parent__r.Job_Number_Excluded__c == false)
                                this.endUserParentCustomerNumber = data.Opportunity.Building_Owner_Parent__r.Customer_Number__c;
                        }
                        if(data.Opportunity != null && data.Opportunity.Building_Owner_Parent__c == null && data.Opportunity.Building_Owner__c == null)
                            this.buildingOwnerAndParentMissing = true;
                        // if (data.Over_Contract_Amount__c != null)
                        // {
                        //     this.overContractAmount = data.Over_Contract_Amount__c;
                        //     this.approvedForOverContractValue = data.Over_Contract_Amount__c;
                        // }
                        // if (data.Approved_For_Over_Contract__c != null)
                        //     this.approvedForOverContract = data.Approved_For_Over_Contract__c;
                        if (data.Opp_Owner_s_Manager__c != null)
                        {
                            this.oppOwnersManagerId = data.Opp_Owner_s_Manager__c;
                            this.theRecord['oppOwnerManager'] = data.Opp_Owner_s_Manager__c;
                        }
                        if(data.OpportunityId != null)
                            this.theRecord['opportunityId'] = data.OpportunityId;

                        if (data.Opportunity != null && data.Opportunity.OwnerId != null)
                            this.theRecord['oppOwner'] = data.Opportunity.OwnerId;

                         if (data.Primary_Bidder__r != null && data.Primary_Bidder__r.Inactive__c != null)
                             this.AccountInactive = data.Primary_Bidder__r.Inactive__c;

                        console.log(this.AccountName);
                        console.log(this.QuoteName);
                        console.log(this.MarketSegment);
                        console.log(this.PaymentTerms);
                        console.log(this.CreditHold);
                    } catch (error) {
                        console.log("Error Loading Quote Info: " + error);
                    }

                } else if (error) {
                    console.log(error);
                    this.handleError(error);
                }

                this.retrieveAlternates();
                this.loadBidders();
                this.getCustomPartNumbers();
                this.loadRCACategories();               

            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting quote: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    retrieveAlternates()
    {
        getAlternates({
            quoteId: this.recordId
        }).then(result => {
            if (result) {
                try {
                    this.alternateList = result;
                    var tempArray = [];
                    var tempTotal = 0;
                    var tempTotalWithoutTax = 0;
                    for (let i = 0; i < result.length; i++) {
                        tempArray.push(result[i].Id);
                        if(result[i].totalInclFreightTax != null)
                            tempTotal += parseFloat(result[i].totalInclFreightTax);
                        if(result[i].totalInclFreightNoTax != null)
                            tempTotalWithoutTax += parseFloat(result[i].totalInclFreightNoTax);
                        if(result[i].bulkPackagable != null && result[i].bulkPackagable == true)
                            this.isBulkPackageAlternateSelected = true;
                    }
                    this.selectedTotalIncludingTax = tempTotal;
                    this.selectedTotalExcludingTax = tempTotalWithoutTax;
                    if(this.NoChargeOrder)
                    {
                        this.theRecord["OrderAmount"] = 0;
                        this.selectedTotal = 0;
                    }
                    else
                    {
                        this.theRecord["OrderAmount"] = tempTotal;
                        this.selectedTotal = tempTotal;
                    }
                    this.selectedAlternates = tempArray;
                    
                } catch (error) {
                    console.log("Error Loading Alternate Info: " + error);
                }

            } else if (error) {
                console.log(error);
                this.handleError(error);
            }
        })
        .catch(error => {
            // TODO: handle error
            console.log("Error getting alternates: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    nextClick()
    {        
        if(this.selectedBulkPackageAction == '' && this.isBulkPackageAlternateSelected)
        {
            this.handleError('Error: You must first select a bulk package option before continuing.');
        }
        else if(this.buildingOwnerNeeded && this.buildingOwnerId == '' && this.buildingOwnerParentId == '')
        {
            this.handleError('Error: Please specify a building owner or building owner parent before continuing.');
        }
        else
        {
            this.headerScreenActive = true;
            this.alternateScreenActive = false; 
        }     
    }

    previousClick()
    {
        if(this.showAddressValidationPane)
        {
            this.showAddressValidationPane = false;
            this.headerScreenActive = true;
            this.alternateScreenActive = false;
        }
        else
        {
            this.headerScreenActive = false;
            this.alternateScreenActive = true;
        }
    }

    checkAccountDeniedParty() {
        if(!this.deniedPartyMessageSent)
        {
            CheckDeniedPartyStatus({
                accountId: this.accountId
            }).then(data => {
                if (data) {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    if (data.isAccountBlocked || data.hasRetrievalErrorOccurred) {
                        this.handleError(data.message);
                        this.loaded = true;
                        this.deniedPartyMessageSent = true;
                    } else {
                        this.finishRequestingOrder();
                    }
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
        else
            this.finishRequestingOrder();
    }


    getContract() {
        console.log("load contract start");
        GetContract({
                quoteId: this.recordId,
                accountId: this.accountId
            }).then(data => {
                if (data) {
                    try {
                        var contractCount = 0;
                        this.contractMessage = 'Multiple contracts are associated with this quote/account combination. Please select one of the following: ';
                        console.log(data);
                        data.forEach(contract => {
                            this.contractMessage += contract.Name + ', ';
                            contractCount++;
                        });
                        this.contractMessage = this.contractMessage.substring(0, this.contractMessage.length - 2);
                        this.contractMessage += '.';

                        if (contractCount == 1) {
                            this.contractMessage = '';
                            this.contractId = data[0].Id;
                            this.theRecord['ContractId'] = data[0].Id;
                            this.contractCustomerNumber = data[0].CustomerNumber;
                            this.poNumber = data[0].PONumber;
                            this.theRecord['PO'] = data[0].PONumber;
                            this.selectedContract = {
                                id: data[0].Id,
                                sObjectType: 'Contract__c',
                                icon: 'standard:account',
                                title: data[0].Name,
                                subtitle: data[0].CustomerNumber
                            };
                            if(data[0].isExecuted != null && !data[0].isExecuted)
                                this.needsContractNotExecutedApproval = true;
                            else
                                this.needsContractNotExecutedApproval = false;
                            if (data[0].paymentTerms != null)
                                this.contractPaymentTerms = data[0].paymentTerms;
                        } else if (contractCount == 0) {
                            this.contractMessage = 'No Contract is associated with this Quote. If a Contract needs to be linked to this Order, please search in this field to add it.';
                        }

                    } catch (error) {
                        console.log("Error Checking Contracts: " + error);
                    }
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error Retrieving Contracts: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    loadRCAReasons() {
        this.rcaReasonList = [];
        var tempArray = [];
        getRCAReasons({categoryId: this.rcaCategory}).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(reason => {
                            var option = {
                                label: reason.Name,
                                value: reason.Id
                            };

                            tempArray = [...tempArray, option];
                        });
                        this.rcaReasonList = tempArray;

                    } catch (error) {
                        console.log("Error Loading RCA Reasons: " + error);
                    }
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting RCA Reasons: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    loadRCACategories() {
        getRCACategories({}).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(category => {
                            var option = {
                                label: category.Name,
                                value: category.Id
                            };

                            this.rcaCategoryList = [...this.rcaCategoryList, option];
                        });

                    } catch (error) {
                        console.log("Error Loading RCA Category List: " + error);
                    }
                }
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting RCA Categories: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    loadSalesRepNumbers() {
        try {
            getSalesRepNumbers().then(data => {
                    try {
                        var results = JSON.parse(data);
                        this.salesRepNumbers = [];
                        this.salesRepNumbers.push({
                            label: "No Commission",
                            value: 90140
                        });
                        this.salesRepNumbers.push({
                            label: "In House",
                            value: 90139
                        });
                        results.forEach(salesrep => {
                            //console.log(salesrep);
                            this.salesRepNumbers.push({
                                label: salesrep.Name,
                                value: salesrep.NetSuite_Id__c
                            });
                        });

                        if (this.NetSuiteId != '') //load in name if netsuite Id is set
                        {
                            const existing = this.salesRepNumbers.find(x => x.value == this.NetSuiteId);
                            if (existing) {
                                const startSelect = this.template.querySelector('.sales-rep-combo');
                                console.log(startSelect);
                                if (startSelect) {
                                    startSelect.value = existing.value;

                                }
                            }
                        }
                        //this.loaded = true;
                    } catch (error) {
                        console.log("Error Loading Reps1: " + JSON.stringify(error));
                    }
                })
                .catch(ex => {
                    console.log("Error Loading Reps2: " + JSON.stringify(ex));
                });
        } catch (error) {
            console.log("Error Loading Reps3: " + JSON.stringify(error));
        }
    }

    checkTaxExemptStatus()
    {
        isBidderTaxExempt({
            accountId: this.accountId,
            additionalStateCode: this.additionalStateCode,
            shippingStateCode: this.shippingStateCode
        }).then(data => {
            //true means not taxable
            if (data) 
            {
                this.orderIsTaxable = false;
                if(this.NoChargeOrder)
                {
                    this.selectedTotal = 0;
                    this.theRecord["OrderAmount"] = 0;
                }
                else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
                {
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                }
                else
                {
                    this.selectedTotal = this.selectedTotalExcludingTax;
                    this.theRecord["OrderAmount"] = this.selectedTotalExcludingTax;
                }
            }        
            else
            {
                if(this.NoChargeOrder)
                {
                    this.selectedTotal = 0;
                    this.theRecord["OrderAmount"] = 0;
                    if(this.shipToCountry == 'United States')
                        this.orderIsTaxable = true;
                    else
                        this.orderIsTaxable = false;
                }
                else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
                {
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                    if(this.shipToCountry == 'United States')
                        this.orderIsTaxable = true;
                    else
                        this.orderIsTaxable = false;
                }
                else if (this.shipToCountry == 'United States')
                {
                    this.selectedTotal = this.selectedTotalIncludingTax;
                    this.theRecord["OrderAmount"] = this.selectedTotalIncludingTax;
                    this.orderIsTaxable = true;
                }
                else
                { 
                    this.selectedTotal = this.selectedTotalExcludingTax;
                    this.theRecord["OrderAmount"] = this.selectedTotalExcludingTax;
                    this.orderIsTaxable = false;
                }
            }
        })
        .catch(error => {
            // TODO: handle error
            this.handleError(error);
            console.log("Error getting account: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
        });
    }

    retrieveAccountInformation() {
        this.loaded = false;
        getAccount({
                accountId: this.accountId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        if (data.Payment_Terms__c != null)
                            this.PaymentTerms = data.Payment_Terms__c;
                        if (data.Available_Credit__c != null)
                            this.availableCredit = data.Available_Credit__c;
                        if (data.Customer_Number__c != null)
                            this.customerNumber = data.Customer_Number__c;
                        if (data.BillingCountry != null)
                        {
                            this.accountBillingCountry = data.BillingCountry;
                            if(this.accountBillingCountry != 'United States' && this.accountBillingCountry != 'US')
                                this.accountBillingAddressINTL = true;
                        }
                        else
                        {
                            this.accountBillingCountry = '';
                            this.accountBillingAddressINTL = false;
                        }
                        if (data.Collector__r != null && data.Collector__r.Email != null)
                            this.theRecord['collectorEmail'] = data.Collector__r.Email;
                        else
                            this.theRecord['collectorEmail'] = '';
                        
                        //Get Credit Hold Status
                        this.checkCreditHold();

                    } catch (error) {
                        console.log("Error Loading Account Info: " + error);
                    }

                } else if (error) {
                    console.log(error);
                    this.handleError(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting account: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
    }

    handleOnFocusOut(event)
    {
        if (event.target.name == 'OriginalInvoiceNumber')
        {
            this.originialInvoiceNumber = event.target.value;
            getOrderNumber({invoiceNumber: this.originialInvoiceNumber}).then(data => {
                    try {
                        this.originalOrderNumber = data;
                        this.theRecord['OriginalOrderNumber'] = this.originalOrderNumber;
                    } catch (error) {
                        console.log("Error Loading Order Number: " + error);
                    }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting order number: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });
        }
    }

    handleInputUpdate(event) {
        console.log(event.target.name);
        console.log(event.target.value);
        console.log(event.target.checked);

        if (event.target.name == "Bidder") {
            this.accountId = event.target.value;
            console.log("AccountID: " + this.accountId);
            this.retrieveAccountInformation();            
        }
        else if (event.target.name == "BypassBuildingOwnerLogic") {
            this.bypassBuildingOwner = event.target.checked;
            this.theRecord["bypassBuildingOwner"] = event.target.checked;
        }
        else if(event.target.name == "Taxable")
        {
            if(this.shipToCountry != 'United States')
            {
                alert("Error: The taxable flag cannot be set. The shipping country code is not US and therefore will be marked 'Not Taxable'.");
                this.orderIsTaxable = false;
                event.target.checked = false;
            }
            else
            {
                this.orderIsTaxable = event.target.checked;
                if(this.NoChargeOrder)
                {
                    this.selectedTotal = 0;
                    this.theRecord["OrderAmount"] = 0;
                }
                else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
                {
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                }
                else
                {
                    if(event.target.checked && (this.shipToCountry == 'United States'))
                    {
                        this.selectedTotal = this.selectedTotalIncludingTax;
                        this.theRecord["OrderAmount"] = this.selectedTotalIncludingTax;
                    }
                    else
                    {
                        this.selectedTotal = this.selectedTotalExcludingTax;
                        this.theRecord["OrderAmount"] = this.selectedTotalExcludingTax;
                    }
                }
            }
        }
        else if (event.target.name == 'CreditApproval' || event.target.name == 'SameDayOrder' || event.target.name == 'NoChargeOrder' ||
            event.target.name == 'InvoiceDetail') {
            this.theRecord[event.target.name] = event.target.checked;
            if (event.target.name == "NoChargeOrder") {
                this.NoChargeOrder = event.target.checked;
                if(this.NoChargeOrder)
                {
                    this.selectedTotal = 0;
                    this.theRecord["OrderAmount"] = 0;
                    console.log(this.NoChargeOrder);
                }
                else if(this.manualOrderTotal != null && this.manualOrderTotal != '')
                {
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                }
                else
                {
                    if(this.orderIsTaxable && (this.shipToCountry == 'United States'))
                    {
                        this.selectedTotal = this.selectedTotalIncludingTax;
                        this.theRecord["OrderAmount"] = this.selectedTotalIncludingTax;
                    }
                    else
                    {
                        this.selectedTotal = this.selectedTotalExcludingTax;
                        this.theRecord["OrderAmount"] = this.selectedTotalExcludingTax;
                    }
                }
            }
            if (event.target.name == "SameDayOrder")
                this.sameDayOrder = event.target.checked;
        } else if (event.target.name == 'SalesRepSelect') {
            this.NetSuiteId = event.target.value;
            this.theRecord["RepNumber"] = event.target.value;
        } else if (event.target.name == 'RepNumber') {
            this.NetSuiteId = event.target.value;
            const existing = this.salesRepNumbers.find(x => x.value == event.target.value);
            const startSelect = this.template.querySelector('.sales-rep-combo');
            if (startSelect) {
                if (existing) {
                    this.theRecord["RepNumber"] = existing.value;
                    startSelect.value = existing.value;
                } else {
                    startSelect.value = ''; //clear selection if current value is not a match
                }
            }
        } else {
            if (event.target.name == 'PO')
                this.poNumber = event.target.value;
            if(event.target.name == 'ManualOrderTotal')
            {
                this.manualOrderTotal = event.target.value;
                var manualTotal = parseFloat(this.manualOrderTotal);
                if(manualTotal > 2500)
                    this.isLargeManualOrderTotal = true;
                else
                this.isLargeManualOrderTotal = false;
                if(this.NoChargeOrder)
                {
                    this.selectedTotal = 0;
                    this.theRecord["OrderAmount"] = 0;
                    console.log(this.NoChargeOrder);
                }
                else if(event.target.value != '')
                {
                    this.manualOrderTotal = event.target.value;
                    this.selectedTotal = this.manualOrderTotal;
                    this.theRecord["OrderAmount"] = this.manualOrderTotal;
                }
                else
                {
                    if(this.orderIsTaxable && (this.shipToCountry == 'United States'))
                    {
                        this.selectedTotal = this.selectedTotalIncludingTax;
                        this.theRecord["OrderAmount"] = this.selectedTotalIncludingTax;
                    }
                    else
                    {
                        this.selectedTotal = this.selectedTotalExcludingTax;
                        this.theRecord["OrderAmount"] = this.selectedTotalExcludingTax;
                    }
                }
            }
            else if (event.target.name == 'OriginalOrderNumber')
                this.originalOrderNumber = event.target.value;
            else if (event.target.name == 'OriginalInvoiceNumber')
                this.originialInvoiceNumber = event.target.value;               
            else if (event.target.name == 'Explanation')
                this.explanation = event.target.value;
            else if (event.target.name == 'NationalAccount')
                this.endUserParentCustomerNumber = event.target.value;
            else if (event.target.name == 'InstallerEmail')
                this.installerEmail = event.target.value;
            else if (event.target.name == 'OrderInformation')
                this.orderInformation = event.target.value;
            else if (event.target.name == 'shipToName')
                this.shipToName = event.target.value;
            else if (event.target.name == 'shipToContactName')
                this.shipToContactName = event.target.value;
            else if (event.target.name == 'shipToContactPhoneNumber')
                this.shipToContactPhoneNumber = event.target.value;
            else if (event.target.name == 'shipToAddress1')
                this.shipToAddress1 = event.target.value;
            else if (event.target.name == 'shipToAddress2')
                this.shipToAddress2 = event.target.value;
            else if (event.target.name == 'shipToCity')
                this.shipToCity = event.target.value;
            else if (event.target.name == 'shipToState')
                this.shipToState = event.target.value;
            else if (event.target.name == 'shipToZip')
                this.shipToZip = event.target.value;
            else if (event.target.name == 'shipToCountry')
                this.shipToCountry = event.target.value;
            else if (event.target.name == 'ShippingInstructions')
                this.shippingInstructions = event.target.value;
            else if (event.target.name == 'OrderAmount')
                this.selectedTotal = event.target.value;
            else if (event.target.name == 'ReasonCategory')
            {
                this.rcaCategory = event.target.value;
                this.rcaReason = '';
                this.loadRCAReasons();               
            }               
            else if (event.target.name == 'ReasonCode')
                this.rcaReason = event.target.value;
            else if (event.target.name == 'ta_contractSubmittalNotes')
                this.contractSubmittalNotes = event.target.value;
            else if (event.target.name == 'NotesToFinance')
                this.FinanceNote = event.target.value;
            else if (event.target.name == "aLine1")
            {
                this.shipToAddress1 = event.target.value;
                this.theRecord['shipToAddress1'] = event.target.value;
            }
            else if (event.target.name == "aLine2")
            {
                this.shipToAddress2 = event.target.value;
                this.theRecord['shipToAddress2'] = event.target.value;
            }
            else if (event.target.name == "aCity")
            {
                this.shipToCity = event.target.value;
                this.theRecord['shipToCity'] = event.target.value;
            }
            else if (event.target.name == "aState")
            {
                this.shipToState = event.target.value;
                this.theRecord['shipToState'] = event.target.value;
            }
            else if (event.target.name == "aZip")
            {
                this.shipToZip = event.target.value;  
                this.theRecord['shipToZip'] = event.target.value;
            }
            else if (event.target.name == "contractNotExecutedNotes")
                this.contractNotExecutedNotes = event.target.value;
            else if (event.target.name == "BulkPackageOption")
                this.selectedBulkPackageAction = event.target.value;
        }
        if(event.target.name != 'CreditApproval' && event.target.name != 'SameDayOrder' && event.target.name != 'NoChargeOrder' && event.target.name != 'InvoiceDetail')
            this.theRecord[event.target.name] = event.target.value;
    }

    handleRerun()
    {
        this.isRerunningAddressValidation = true;
        this.validateAddress();
    }

    handleProposed()
    {
        this.shipToAddress1 = this.proposedAddress1;
        this.theRecord['shipToAddress1'] = this.proposedAddress1;
        this.shipToAddress2 = this.proposedAddress2;
        this.theRecord['shipToAddress2'] = this.proposedAddress2;
        this.shipToCity = this.proposedCity;
        this.theRecord['shipToCity'] = this.proposedCity;
        this.shipToState = this.proposedState;
        this.theRecord['shipToState'] = this.proposedState;
        this.shipToZip = this.proposedZip;
        this.theRecord['shipToZip'] = this.proposedZip;
        this.addressValidationComplete = true;
        this.finishRequestingOrder();
    }

    handleOriginal()
    {
        this.addressValidationComplete = true;
        this.finishRequestingOrder();
    }

    requestOrder(event) {
        //this.checkAccountDeniedParty();
        this.finishRequestingOrder();
    }

    closeQuickAction()
    {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    finishRequestingOrder() {
        this.loaded = false;
        var myJSON = JSON.stringify(this.theRecord);
        console.log(myJSON);

        if (this.theRecord.PO == '' || this.theRecord.PO == null ||
            this.theRecord.Bidder == '' || this.theRecord.Bidder == null ||
            this.theRecord.OrderAmount == null || this.theRecord.RepNumber == null ||
            this.theRecord.ContactId == '' || this.theRecord.ContactId == null ||
            this.theRecord.shipToName == '' || this.theRecord.shipToName == null) {
            this.showError = true;
            this.errorMessage = 'Please fill out all the required fields. (Contact, PO Number, Bidder, Order Amount, Rep Number, and Ship To Name)'.split('\r\n');;
            this.loaded = true;

        }
        else if(this.NoChargeOrder && (this.rcaCategory == '' || this.rcaReason == '')){
            this.showError = true;
            this.errorMessage = 'Error: This order is marked as a no charge. A Reason Category and Reason Code must be specified to continue.';
            this.loaded = true;
        } else {
            if(this.buildingOwnerAndParentMissing && (this.buildingOwnerId == null || this.buildingOwnerId == '') && (this.buildingOwnerParentId == null || this.buildingOwnerParentId == '') && this.division != 'JointMaster' && this.division != 'Ascend' && this.selectedTotal >= 1000 && !this.bypassBuildingOwner)
            {
                this.buildingOwnerNeeded = true;
                this.headerScreenActive = false;
                this.loaded = true;
            } 
            else if(!this.addressValidationComplete && (this.shipToCountry == 'United States' || this.shipToCountry == 'US'))
                this.validateAddress();
            else if (this.contractId == null || this.contractId == '') {
                if(this.FinanceNote != null && this.FinanceNote != '')
                    this.FinanceNote = "Credit Hold Request Notes: " + this.FinanceNote + "<br/>";
                if(this.contractNotExecutedNotes != '')
                    this.FinanceNote = this.FinanceNote + "Contract Not Executed Notes: " + this.contractNotExecutedNotes;
                
                this.theRecord['selectedAlternateIdsString'] = '';
                for(var i = 0; i < this.selectedAlternates.length; i++)
                {
                    this.theRecord['selectedAlternateIdsString'] += (this.selectedAlternates[i] + ',');
                }
                if(this.theRecord['selectedAlternateIdsString'] != null && this.theRecord['selectedAlternateIdsString'] != '')
                    this.theRecord['selectedAlternateIdsString'] = (this.theRecord['selectedAlternateIdsString']).substring(0,this.theRecord['selectedAlternateIdsString'].length - 1);            
                
                    createOrderRequest({
                        recordId: this.recordId,
                        orderRequest: this.theRecord,
                        needsOverContractApproval: false,
                        notesToApprover: this.FinanceNote,
                        userId: userId,
                        needsContractNotExecutedApproval: this.needsContractNotExecutedApproval,
                        needsCreditHoldApproval: this.needsCreditHoldApproval,
                        selectedBulkPackageAction: this.selectedBulkPackageAction
                    }).then(data => {
                        if (data) {
                            try {
                                var myJSON = JSON.stringify(data);
                                console.log(myJSON);
                                this.orderRequested = true;
                                if (!data.toLowerCase().includes("error"))
                                    document.location = "https://" + location.hostname + "/lightning/r/Order_Request__c/" + data + "/view";
                                else {
                                    console.log(data);
                                    this.handleError(data);
                                }
                                this.loaded = true;
                            } catch (error) {
                                var errorJSON = JSON.stringify(error);
                                this.handleError(errorJSON);
                                console.log("Error Requesting Order: " + errorJSON);
                            }
                        }
                        else
                            this.handleError('Error: There was an error creating the order request.');
                    })
                    .catch(error => {
                        // TODO: handle error
                        var errorJSON = JSON.stringify(error);
                        console.log("Error Requesting Order: " + errorJSON);
                        this.handleError(errorJSON);
                    });
            }
            else {
                WillOrderExceedContractedAmount({
                        orderAmount: this.selectedTotal,
                        customerNumber: this.contractCustomerNumber,
                        poNumber: this.poNumber,
                        contractId: this.contractId,
                        division: this.division
                    }).then(data => {
                        try {
                            //data = JSON.parse(data);
                            if ((JSON.parse(data)).Status || ((JSON.parse(data)).overContractAmount <= this.approvedForOverContractValue && this.approvedForOverContract)) {
                                    if(this.FinanceNote != null && this.FinanceNote != '')
                                        this.FinanceNote = "Credit Hold Request Notes: " + this.FinanceNote + "<br/>";
                                    if(this.contractNotExecutedNotes != '')
                                        this.FinanceNote = this.FinanceNote + "Contract Not Executed Notes: " + this.contractNotExecutedNotes;
                                    createOrderRequest({
                                        recordId: this.recordId,
                                        orderRequest: this.theRecord,
                                        needsOverContractApproval: false,
                                        notesToApprover: this.FinanceNote,
                                        userId: userId,
                                        needsContractNotExecutedApproval: this.needsContractNotExecutedApproval,
                                        needsCreditHoldApproval: this.needsCreditHoldApproval,
                                        selectedBulkPackageAction: this.selectedBulkPackageAction
                                    }).then(data => {
                                        if (data) {
                                            try {
                                                var myJSON = JSON.stringify(data);
                                                console.log(myJSON);
                                                this.orderRequested = true;
                                                if (!data.toLowerCase().includes("error"))
                                                    document.location = "https://" + location.hostname + "/lightning/r/Order_Request__c/" + data + "/view";
                                                else {
                                                    console.log(data);
                                                    this.handleError(data);
                                                }
                                                this.loaded = true;
                                            } catch (error) {
                                                var errorJSON = JSON.stringify(error)
                                                console.log("Error Requesting Order: " + errorJSON);
                                            }
                                        } else if (error) {
                                            console.log(error);
                                            this.handleError(error);
                                        }
                                        else
                                            this.handleError('Error: There was an error creating the order request.');
                                        
                                    })
                                    .catch(error => {
                                        // TODO: handle error
                                        var errorJSON = JSON.stringify(error)
                                        console.log("Error Requesting Order: " + errorJSON);
                                        this.handleError(errorJSON);
                                    });
                            } else {
                                this.showAddressValidationPane = false;
                                this.showContractApprovalButton = true;
                                this.overContractAmount = data.overContractAmount;
                                console.log((JSON.parse(data)).Message);
                                this.handleError((JSON.parse(data)).Message);
                                // if(this.approvedForOverContract)
                                // {
                                //     this.errorMessage += " You've only been approved for an order that would bring us over contract by $" + this.approvedForOverContractValue + ".";
                                // }
                                this.loaded = true;
                            }
                        } catch (error) {
                            var errorJSON = JSON.stringify(error);
                            console.log(errorJSON);
                            this.handleError(errorJSON);
                            this.loaded = true;
                        }
                    })
                    .catch(error => {
                        var errorJSON = JSON.stringify(error);
                        this.handleError(errorJSON);
                        this.loaded = true;
                    });
            }
        }
    }

    validateAddress()
    {
        this.loaded = false;
        validateAddress({
            recordId: '',
            objectName: '',
            updateAddress: true,
            Line1: this.shipToAddress1,
            Line2: this.shipToAddress2,
            City: this.shipToCity,
            State: this.shipToState,
            Zip: this.shipToZip
        }).then(data => {
            if (data) {
                try {
                    data = JSON.parse(data);
                    console.log(data);
                    this.proposedAddress1 = data.Street1;
                    this.proposedAddress2 = data.Street2;
                    this.proposedCity = data.City;
                    this.proposedState = data.State;
                    this.proposedZip = data.ZipCode;
                    this.addressValidationDetail = data.ResultDescription;

                    if (data.ZipCode == '' || data.ZipCode == null)
                        this.enableProposed = false;
                    else
                        this.enableProposed = true;

                    if (data.ResultCode == 0 && !this.isRerunningAddressValidation) //valid
                    {
                        this.addressValidationComplete = true;
                        this.finishRequestingOrder();
                    }   
                    else
                    {
                        this.showAddressValidationPane = true;
                        this.headerScreenActive = false;
                        this.loaded = true;  
                    } 
                    this.isRerunningAddressValidation = false;                          

                } catch (error) {
                    var errorJSON = JSON.stringify(error);
                    console.log(errorJSON);
                    this.handleError(errorJSON);
                    console.log("Error validating custom products: " + errorJSON);
                }
            }
        })
        .catch(error => {
            // TODO: handle error
            var errorJSON = JSON.stringify(error);
            console.log("Error validating custom product: " + errorJSON);
            this.handleError(errorJSON);
            this.loaded = true;
        });
    }

    getCustomPartNumbers(event) {
        validateCustomProducts({
                quoteId: this.recordId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log("Custom Part Numbers: " + myJSON);
                        if (data != null && data.length > 0) {
                            this.quoteLineList = data;
                            this.hasCustomParts = true;
                        }
                    } catch (error) {
                        var errorJSON = JSON.stringify(error);
                        console.log(errorJSON);
                        this.handleError(errorJSON);
                        console.log("Error validating custom products: " + errorJSON);
                    }
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error validating custom product: " + errorJSON);
                this.handleError(errorJSON);
                this.loaded = true;
            });
    }

    initiateContractApprovalProcess(event) {
        this.loaded = false;

        if (this.theRecord.PO == '' || this.theRecord.PO == null ||
            this.theRecord.Bidder == '' || this.theRecord.Bidder == null ||
            this.theRecord.OrderAmount == null || this.theRecord.RepNumber == null ||
            this.theRecord.ContactId == '' || this.theRecord.ContactId == null ||
            this.theRecord.shipToName == '' || this.theRecord.shipToName == null) {
            this.showError = true;
            this.errorMessage = 'Please fill out all the required fields. (Contact, PO Number, Bidder, Order Amount, Rep Number, and Ship To Name)';
            this.loaded = true;

        } else {
            if(this.FinanceNote != null && this.FinanceNote != '')
                this.FinanceNote = "Credit Hold Request Notes: " + this.FinanceNote + "<br/>";
            if(this.contractNotExecutedNotes != '')
                this.FinanceNote = this.FinanceNote + "Contract Not Executed Notes: " + this.contractNotExecutedNotes + "<br/>";
            if(this.contractSubmittalNotes != '')
                this.FinanceNote = this.FinanceNote + "Over Contract Notes: " + this.contractSubmittalNotes;
            createOrderRequest({
                recordId: this.recordId,
                orderRequest: this.theRecord,
                needsOverContractApproval: true,
                notesToApprover: this.FinanceNote,
                userId: userId,
                needsContractNotExecutedApproval: this.needsContractNotExecutedApproval,
                needsCreditHoldApproval: this.needsCreditHoldApproval,
                selectedBulkPackageAction: this.selectedBulkPackageAction
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        this.orderRequested = true;
                        this.loaded = true;
                        if (!data.toLowerCase().includes("error"))
                            document.location = "https://" + location.hostname + "/lightning/r/Order_Request__c/" + data + "/view";
                        else
                        {
                            this.errorMessage = data;
                            this.showError = true;
                        }
                    } catch (error) {
                        var errorJSON = JSON.stringify(error)
                        console.log("Error Requesting Order: " + errorJSON);
                    }

                } else if (error) {
                    this.errorMessage = error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error)
                console.log("Error Requesting Order: " + errorJSON);
                this.showError = true;
                this.errorMessage = errorJSON;
                this.loaded = true;
            });
        }
    }

    handleError(error) {
        try {
            if(error.indexOf(':500') != -1 || error.indexOf('status: 500') != -1)
                this.errorMessage = error.replace('\r','').replace('\n','');
            else
                this.errorMessage = error.split('\r\n');
        } catch (ex) {
            let tempArray = [];
            tempArray.push(error);
            this.errorMessage = tempArray;
        }
        this.showError = true;
        this.loaded = true;
    }

    handleContinueAnyway(event) {
        this.hasCustomParts = false;
    }

    handleCloseClick(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        var id = '';
        var subTitle = '';
        if (selection.length > 0) {
            name = selection[0].title;
            id = selection[0].id;
            subTitle = selection[0].subtitle;
            this.selectedContract = selection[0];
        }


        // console.log(event.target.name);
        // console.log(name);
        // console.log(id);
        this.theRecord["ContractId"] = id;
        this.contractId = id;
        this.contractCustomerNumber = subTitle;
        if(id != null && id != '')
        {
            getContractById({
                contractId: id
            }).then(data => {
                if (data.Id != null) {             
                    if (data.PONumber != null && data.PONumber != '') {
                        this.poNumber = data.PONumber;
                        this.theRecord['PO'] = data.PONumber;   
                    }
                    if(data.isExecuted != null && !data.isExecuted)
                        this.needsContractNotExecutedApproval = true;
                    else
                        this.needsContractNotExecutedApproval = false;
                    if (data.paymentTerms != null)
                        this.contractPaymentTerms = data.paymentTerms;
                } else {
                    this.handleError('Error: The contract could not be found.');
                    //this.loaded = false;
                }
            })
            .catch(error => {
                this.handleError("Error retrieving contract information: " + error);
                //this.loaded = false;
            });
        }
        else
        {
            this.contractPaymentTerms = '';
            this.poNumber = '';
            this.theRecord['PO'] = '';
            this.needsContractNotExecutedApproval = false;
        }
    }

    handleContactLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            this.selectedContact = selection[0];
        }

        // console.log(event.target.name);
        // console.log(name);
        // console.log(id);
        this.theRecord["ContactId"] = id;
        this.contactId = id;
    }

    handleContractSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        contractSearch(event.detail)
            .then(results => {
                console.log("contract results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting contracts: " + errorJSON);
            });
    }

    handleContactSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        contactSearch(event.detail, this.accountId)
            .then(results => {
                console.log("contact results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting contracts: " + errorJSON);
            });
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    handleBuildingOwnerSearch(event)
    {
        const target = event.target;
        console.log(event.target.value);
        buildingOwnerSearch(event.detail)
            .then(results => {
                console.log("contact results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting ding owners: " + errorJSON);
            });
    }

    handleBuildingOwnerLookupSelectionChange(event)
    {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            this.selectedbuildingOwner = selection[0];
        }

        this.theRecord["buildingOwnerId"] = id;
        this.buildingOwnerId = id;
    }

    handlebuildingOwnerParentSearch(event)
    {
        const target = event.target;
        console.log(event.target.value);
        buildingOwnerParentSearch(event.detail)
            .then(results => {
                console.log("contact results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting building owner parents: " + errorJSON);
            });
    }

    handlebuildingOwnerParentLookupSelectionChange(event)
    {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            this.selectedbuildingOwnerParent = selection[0];
        }

        this.theRecord["buildingOwnerParentId"] = id;
        this.selectedbuildingOwnerParentId = id;
    }

    moveToHeaderScreen()
    {
        this.buildingOwnerNeeded = false;
        this.headerScreenActive = true;
    }

    finishBuildingOwnerScreen()
    {
        if((this.buildingOwnerId == null || this.buildingOwnerId == '') && (this.buildingOwnerParentId == null || this.buildingOwnerParentId == '') && !this.bypassBuildingOwner)
        {
            alert("Error: You have to specify a building owner or building owner parent before creating the order.");
        }
        else
        {
            this.buildingOwnerNeeded = false;
            this.finishRequestingOrder();
        }
    }
}