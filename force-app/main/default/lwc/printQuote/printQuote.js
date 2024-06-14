import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import userId from '@salesforce/user/Id';

import CheckSaveQuote from '@salesforce/apex/PrintQuoteHelper.CheckSaveQuote';
import GetPrintQuoteWrapper from '@salesforce/apex/PrintQuoteHelper.GetPrintQuoteWrapper';
import GetContactInfo from '@salesforce/apex/PrintQuoteHelper.GetContactInfo';
import GetGrandTotals from '@salesforce/apex/PrintQuoteHelper.GetGrandTotals';
import UpdateOpportunityAmountAndStage from '@salesforce/apex/PrintQuoteHelper.UpdateOpportunityAmountAndStage';
import GetQuoteBidders from '@salesforce/apex/PrintQuoteHelper.GetQuoteBidders';
import UpdateQuoteBiddersToSent from '@salesforce/apex/PrintQuoteHelper.UpdateQuoteBiddersToSent';
import GetDocumentNames from '@salesforce/apex/PrintQuoteHelper.GetDocumentNames';
import GetCountries from '@salesforce/apex/AccountNewOpportunityHelper.GetCountries';
import GetStates from '@salesforce/apex/AccountNewOpportunityHelper.GetStates';
import ContactSearch from '@salesforce/apex/AccountNewOpportunityHelper.ContactSearch';
import UserSearch from '@salesforce/apex/AccountNewOpportunityHelper.UserSearch';
import SendEmail from '@salesforce/apex/PrintQuoteHelper.SendEmail';
import UpdateQuoteTaxById from '@salesforce/apex/TaxHelper.UpdateQuoteTaxById';
import UpdateQuote from '@salesforce/apex/PrintQuoteHelper.UpdateQuote';
import GeneratePrintPDF from '@salesforce/apex/PrintQuoteHelper.GeneratePrintPDF';
import CreateAsyncProcess from '@salesforce/apex/PrintQuoteHelper.CreateAsyncProcess';
import SendCustomFormsEmail from '@salesforce/apex/PrintQuoteHelper.SendCustomFormsEmail';
import PricingAccountsChanged from '@salesforce/apex/PrintQuoteHelper.PricingAccountsChanged';
import updatePricingAccountsFlick from '@salesforce/apex/PrintQuoteHelper.updatePricingAccountsFlick';
import CreatePrintQuote from '@salesforce/apex/PrintQuoteHelper.CreatePrintQuote';
//import CheckDeniedPartyStatus from '@salesforce/apex/DeniedPartyHelper.CheckDeniedPartyStatus';

import GetUserEmailTemplates from '@salesforce/apex/PrintQuoteHelper.GetUserEmailTemplates';
import CreateNewQuoteEmailTemplate from '@salesforce/apex/PrintQuoteHelper.CreateNewQuoteEmailTemplate';


import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class PrintQuote extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track isRecalculating = false;
    @track data;
    @track pdfName = '';
    @track showPrevious = false;
    @track screenOne = true;
    @track screenTwoStop = false;
    @track screenTwoContact = false;
    @track screenTwoBidder = false;
    @track screenThreePrint = false;
    @track screenFourEmail = false;
    @track screenFourSignature = false;
    @track screenFiveDone = false;
    @track lastScreenName = '';
    @track isLockingQuoteOnFinish = false;
    @track isFreightCalculated = false;
    @track isInternalQuoteStatus = false;
    @track isShowingContact = false;
    @track isShowingHideQtys = false;
    @track isShowingSubmittalVersion = false;
    @track isProForma = false;
    @track isProFormaOrLOC = false;
    @track isProFormaOrWT = false;
    @track isAnyProForma = false;
    @track isShowingPrintSummary = false;
    @track isPrintSummary = true;
    @track isPrintDetails = true;
    @track isBidFormat = true;
    @track isHideQtys = false;
    @track isSubmittalVersion = false;
    @track isShowingParagraphs = false;
    @track isShowingPrintGrandTotal = true;
    @track selectedDocumentType = 'Bid_Format';
    @track selectedRecipient = 'Internal';
    @track selectedContact = '';
    @track selectedMaterial = 'Material Only';
    @track addressCountry = '';
    @track addressZip = '';
    @track addressState = '';
    @track addressCity = '';
    @track addressStreet = '';
    @track poNumber = '';
    @track shipToName = '';
    @track selectedAlternates = [];
    @track previousSelectedRows = [];
    @track alternateList = [];
    @track selectedPricingAlternates = [];
    @track alternatePricingList = [];
    @track taxCertList = [];
    @track contactList = [];
    @track stateList = [];
    @track paymentList=[];
    @track bidderList=[];
    @track selectedBidders=[];
    @track originalIntroductionParagraph = '';
    @track originalEndingParagraph = '';
    @track introductionParagraph = '';
    @track endingParagraph = '';
    @track selectedPayment = '';
    @track proFormaFreight;
    @track jobReference = '';
    @track selectedCreditType = '';
    @track selectedShippingTerms = '';
    @track printGrandTotal = false;
    @track isTaxable = false;
    @track contactName = '';
    @track contactEmail = '';
    @track contactPhone = '';
    @track contactFax = '';
    @track shipToAddress = '';
    @track shippingTerms = '';
    @track jobReference = '';
    @track ourReference = '';
    @track creditType = '';
    @track opportunityAmount = 0.0;
    @track opportunityAmountForPricing = 0.0;
    @track quoteCreatedDate;
    @track documentTypeList = [{
        value: 'Bid_Format',
        label: 'Bid Format'
    }, {
        value: 'Quote_w_Pricing',
        label: 'Quote w/Pricing'
    },
    {
        value: 'Quote_w_Lump_Sum_Pricing',
        label: 'Quote w/Lump Sum Pricing'
    },
    {
        value: 'Pro_Forma',
        label: 'Pro Forma'
    },
    {
        value: 'Pro_Forma_Letter_of_Credit',
        label: 'Pro Forma Letter of Credit'
    },
    {
        value: 'Pro_Forma_Wire_Transfer',
        label: 'Pro Forma Wire Transfer'
    },
    {
        value: 'Add_Deduct',
        label: 'Add/Deduct Comparison'
    }];
    @track alternateColumns = [
        {label: 'Name',fieldName: 'Name__c',  type: 'text', sortable: true },
        {label: 'Sequence #',fieldName: 'Sequence_Number__c',  type: 'text', sortable: true },
        {label: 'Group Sequence #',fieldName: 'Group_Sequence_Number__c',  type: 'text', sortable: true },
        {label: 'Freight Group Name',fieldName: 'Freight_Group_Name__c' , sortable: true},
        {label: 'Freight Amount',fieldName: 'Freight_Amount__c' , sortable: true, type: 'currency', typeAttributes: { curencyCode: 'USD'}},
        {label: 'Show Unit Pricing',fieldName: 'Show_Unit_Pricing__c', type: 'boolean' , sortable: true},
    ];
    @track alternateColumnsNoTax= [
        {label: 'Name',fieldName: 'Name__c'},
        {label: 'Total (incl Freight)',fieldName: 'Total_incl_Freight_No_Tax__c', type: 'currency', typeAttributes: { curencyCode: 'USD'}},
    ];
    @track alternateColumnsTax = [
        {label: 'Name',fieldName: 'Name__c'},
        {label: 'Total (incl Freight/Tax)',fieldName: 'Total_incl_Freight_Tax__c', type: 'currency', typeAttributes: { curencyCode: 'USD'}},
    ];
    @track quoteBidderColumns = [
        {label: 'Bidder',fieldName: 'Url', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
        {label: 'Pricing Group',fieldName: 'Pricing_Group__c'},
        {label: 'Status',fieldName: 'Status__c'},
        {label: 'Bidder_Status__c',fieldName: 'Bidder_Status__c'},
        {label: 'Contact Name',fieldName: 'Contact_Name__c'}
    ];
    @track taxCertColumns = [
        {label: 'Account',fieldName: 'AccountName'},
        {label: 'Note Subject / Job Name',fieldName: 'NoteSubject'},
        {label: 'Cert. Type',fieldName: 'CertificateType'},
        {label: 'States where Valid',fieldName: 'StatesWhereValid'},
        {label: 'State of Issue',fieldName: 'StateOfIssue'},
        {label: 'Exp. Date',fieldName: 'ExpirationDate'},
        {label: 'Effective Date',fieldName: 'EffectiveDate'},
        {label: 'Tax Exempt #',fieldName: 'Name'}
    ];
    @track recipientOptions = [
        {value: 'Internal', label: 'Internal'},
        {value: 'For Customer', label: 'For Customer'}
    ];
    @track materialList=[
        {value: 'Material Only', label: 'Material Only'},
        {value: 'Material and Labor', label: 'Material and Labor'}
    ];
    
    @track creditTypeList =[
        {value: 'Advised', label: 'Advised'},
        {value: 'Confirmed', label: 'Confirmed'}
    ];
    @track shippingTermsList = [
        {value: 'Carriage and Insurance Paid To', label: 'Carriage and Insurance Paid To'},
        {value: 'Carriage Paid To', label: 'Carriage Paid To'},
        {value: 'Cost and Freight', label: 'Cost and Freight'},
        {value: 'Cost, Insurance and Freight', label: 'Cost, Insurance and Freight'},
        {value: 'Delivered Duty Paid', label: 'Delivered Duty Paid'},
        {value: 'Delivered at Place', label: 'Delivered at Place'},
        {value: 'Delivered at Terminal', label: 'Delivered at Terminal'},
        {value: 'Ex Works', label: 'Ex Works'},
        {value: 'Free Alongside Ship', label: 'Free Alongside Ship'},
        {value: 'Free Carrier', label: 'Free Carrier'},
        {value: 'Free on Board', label: 'Free on Board'}
    ];
    @track toAddress = '';
    @track ccAddress = '';
    @track bccAddress = '';
    @track bidderBccAddress = '';
    @track emailSubject = '';
    @track allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
        'background',
    ];
    @track territoryManagerEmail = '';
    @track alternateString = '';
    @track selectedToContact = Array(0);
    @track selectedToUser = Array(0);
    @track selectedCCContact = Array(0);
    @track selectedCCUser = Array(0);
    @track selectedBCCContact = Array(0);
    @track selectedBCCUser = Array(0);
    @track docNames = '';
    @track isShowingDocWarning = false;
    @track isForCustomer = false;
    //Punish the users
    @track hasPreviewPrintSelected = false;
    @track isPrintOnly = false;
    @track isPreviewOnly = false;
    //Email Template fields
    @track emailTemplates = [];
    @track emailTemplateList = [];
    @track selectedEmailTemplate;
    @track showPricingWarning = false;
    @track isCAD = false;
    @track isPotentialCAD = false;

    handleRefreshSignatures(){
        this.loaded = false;
        GetUserEmailTemplates({userId: userId}).then(templates =>{
            this.emailTemplates = templates;
            this.emailTemplateList = [];
            templates.forEach(x => {
                this.emailTemplateList.push({
                    label: x.Name,
                    value: x.Id
                });
            });
            console.log(templates);
            this.loaded = true;
        });
    }

    handlePricingUpdated()
    {
        this.updateAccountFlick();
        this.showPricingWarning = false;
    }

    updateAccountFlick()
    {
        updatePricingAccountsFlick({
            quoteId: this.recordId
        }).then(result=> {
            console.log(result);
        }).catch(error => {
            this.handleError(error);
        });
    }

    connectedCallback() {
        CheckSaveQuote({
            quoteId: this.recordId
        }).then(result => {

            console.log('Async Process? ' + result)
            if (result == 'true')
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Save in Progress!',
                    message: 'Please wait until Experlogix is done saving before using Print Quote.',
                    variant: 'warning'
                }));
                this.closeQuickAction();
            }
            else{
                PricingAccountsChanged({
                    quoteId: this.recordId
                }).then(result=> {
                    this.showPricingWarning = result;
                }).catch(error => {
                    this.handleError(error);
                });
        
                GetPrintQuoteWrapper({
                    Id: this.recordId
                }).then(result => {
                    try{
                        console.log(result);
                        console.log(JSON.parse(result));
                        this.data = JSON.parse(result);
                        //Set component visibility statuses
                        if (this.data.Quote.Freight__c > 0)
                        {
                            this.isFreightCalculated = true;
                        }

                        console.log("Is CAD? " + this.data.IsPotentialCAD);
                        this.isCAD = this.data.IsPotentialCAD == 'true';

                        if (this.data.Quote.Status == 'Draft' || this.data.Quote.Status == 'Rejected' || this.data.Quote.Status == 'Submitted for Approval')
                        {
                            this.isInternalQuoteStatus = true;
                        }
                        if (this.data.Opportunity.Owner !== undefined && this.data.Opportunity.Owner.Email !== undefined)
                        {
                            this.ccAddress += this.data.Opportunity.Owner.Email;
                        }
                        for(var i = 0; i < this.data.PaymentTerms.length; i++)
                        {
                            if (this.data.PaymentTerms[i].active == true)
                            {
                                this.paymentList.push({value: this.data.PaymentTerms[i].value, label: this.data.PaymentTerms[i].label});
                            }
                        }
                        if (this.data.Quote.Introduction__c !== undefined && this.data.Quote.Introduction__c !== null)
                        {
                            this.originalIntroductionParagraph = this.data.Quote.Introduction__c;
                            this.introductionParagraph = this.data.Quote.Introduction__c;
                        }
                        if (this.data.Quote.Ending__c !== undefined && this.data.Quote.Ending__c !== null)
                        {
                            this.originalEndingParagraph = this.data.Quote.Ending__c;
                            this.endingParagraph = this.data.Quote.Ending__c;
                        }
                        if (this.data.Quote.Opportunity !== undefined && this.data.Quote.Opportunity.Territory_Manager__r !== undefined && this.data.Quote.Opportunity.Territory_Manager__r.Email !== undefined)
                            this.territoryManagerEmail = this.data.Quote.Opportunity.Territory_Manager__r.Email;
                        this.shipToName = this.data.Quote.ShippingName != null ? this.data.Quote.ShippingName : '';
                        this.addressStreet = this.data.Quote.ShippingStreet != null ? this.data.Quote.ShippingStreet : '';
                        this.addressCity = this.data.Quote.ShippingCity != null ? this.data.Quote.ShippingCity : '';
                        
                        this.addressZip = this.data.Quote.ShippingPostalCode != null ? this.data.Quote.ShippingPostalCode : '';
                        this.addressCountry = this.data.Quote.ShippingCountry != null ? this.data.Quote.ShippingCountry : '';
                        GetStates({
                            country: this.addressCountry
                        }).then(results => {
                            var tempArray = [];
                            results.forEach(x => {
                                tempArray.push({
                                    value: x.split('|')[0],
                                    label: x.split('|')[0]
                                });
                            });
                            this.stateList = tempArray;
                            this.addressState = this.data.Quote.ShippingState != null ? this.data.Quote.ShippingState : '';
                        }).catch(error => {
                            this.handleError(error);
                        });
                        var tempArray = [];
                        var tempId = '';
                        for(var i = 0; i < this.data.Contacts.length; i++)
                        {
                            tempArray.push({value: this.data.Contacts[i].Id, label: (this.data.Contacts[i].Name + ' - ' + this.data.Contacts[i].Account_Name__c) });
                            if (this.data.Quote.ContactId !== null && this.data.Quote.ContactId !== undefined && this.data.Quote.ContactId == this.data.Contacts[i].Id)
                            {
                                tempId = this.data.Contacts[i].Id;
                            }
                        }
                        this.contactList = tempArray;
                        
                        if (tempId !== '')
                        {
                            this.selectedContact = tempId;
                        }
                        else if (this.contactList.length > 0)
                        {
                            this.selectedContact = this.contactList[0].value;
                        } 
            
                        this.opportunityAmount = this.data.Opportunity.Amount;
                        this.opportunityAmountForPricing = this.data.Opportunity.Amount;
                        
                        if (this.data.Quote.BidQuote__c == 'Bid')
                        {
                            this.emailSubject = 'Inpro Bid ';
                        }
                        else this.emailSubject = 'Inpro Quote ';
                        this.emailSubject += this.data.Quote.Name + ' - Rev:' + this.data.Quote.Revision_Number__c + ' - ' + this.data.Opportunity.Name;
            
                        if (this.data.ContactEmail !== null && this.data.ContactEmail !== undefined) this.toAddress = this.data.ContactEmail;
                        this.pdfName = this.data.Quote.Name + ' ' + this.data.Opportunity.Name;
                        //Account_Name__c
                        this.alternateList = this.data.Alternates;
                        this.previousSelectedRows = this.alternateList;
                        this.alternatePricingList = this.data.Alternates;
            
                        tempArray = [];
                        for (let i = 0; i < this.data.Alternates.length; i++) {
                            tempArray.push(this.data.Alternates[i].Id);
                        }
                        this.selectedAlternates = tempArray;
                        this.selectedPricingAlternates = tempArray;
                        this.taxCertList = this.data.TaxCertificates;
            
                        this.handleTriggers();
                        this.loaded = true;
                    }
                    catch(ex)
                    {
                        console.log(ex);
                        this.loaded = true;
                    }
                }).catch(error => {
                    this.handleError(error);
                });
        
                GetUserEmailTemplates({userId: userId}).then(templates =>{
                    this.emailTemplates = templates;
                    this.emailTemplateList = [];
                    templates.forEach(x => {
                        this.emailTemplateList.push({
                            label: x.Name,
                            value: x.Id
                        });
                    });
                    console.log(templates);
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
                }).catch(error => {
                    this.handleError(error);
                });
        
                GetStates({
                    country: this.addressCountry
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
        }).catch(error => {
            this.handleError(error);
        });
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
                        this.loaded = false;
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

    
    handleDataTableInput(event){
        let selectedRows = event.detail.selectedRows;

        if (event.target.name == 'alternates')
        {
            var tempArray = [];
            for (let i = 0; i < selectedRows.length; i++) {
                tempArray.push(selectedRows[i].Id);
            }
            this.selectedAlternates = tempArray;
            this.selectedPricingAlternates = tempArray;
            this.handleRecalculate()
            this.updateAlternateString();
            console.log('alternate string is [' + this.alternateString + ']');
        }/*
        if (event.target.name == 'alternates')
        {
            var rowChanged = this.previousSelectedRows.filter(o1 => !selectedRows.some(o2 => o1.Id == o2.Id))[0];
            
            var rowIsRemoved = rowChanged != undefined;

            if (rowChanged == undefined){
                rowChanged = selectedRows.filter(o1 => !this.previousSelectedRows.some(o2 => o1.Id == o2.Id))[0];
            } 

            if (rowIsRemoved) //remove same name alternates
            {
                selectedRows = selectedRows.filter(o1 => o1.Name__c != rowChanged.Name__c);
            }
            else //add same name alternates
            {
                var newSelectedRows = selectedRows;
                var sameNameAlts = this.alternateList.filter(o1 => o1.Name__c == rowChanged.Name__c);
                for (let j = 0; j < sameNameAlts.length; j++){
                    if (selectedRows.find(x => x.Id == sameNameAlts[j].Id) == undefined)
                    {
                        newSelectedRows.push(sameNameAlts[j]);
                    }
                }
                selectedRows = newSelectedRows;
            }
            var tempArray = [];
            for (let i = 0; i < selectedRows.length; i++) {
                tempArray.push(selectedRows[i].Id);
            }
            this.selectedAlternates = tempArray;
            this.selectedPricingAlternates = tempArray;
            this.previousSelectedRows = selectedRows;
            this.handleRecalculate()
            this.updateAlternateString();
            console.log('alternate string is [' + this.alternateString + ']');
        }*/
        else if (event.target.name == 'alternatePricingList')
        {
            var tempArray = [];
            selectedRows.forEach(x => {
                tempArray.push(x.Id);
            });
            this.selectedPricingAlternates = tempArray;
            if (this.screenThreePrint)
            {
                this.handleRecalculate();
            }
        }
        else if (event.target.name == 'bidders')
        {
            var tempArray = [];
            this.bidderBccAddress = '';
            for (let i = 0; i < selectedRows.length; i++) {
                tempArray.push(selectedRows[i].Id);
                console.log(selectedRows[i].Contact_Email__c);
                //Build BCC emails from selected bidders
                if (this.bidderBccAddress == '') this.bidderBccAddress = selectedRows[i].Contact_Email__c;
                else this.bidderBccAddress += ',' + selectedRows[i].Contact_Email__c;
            }
            this.selectedBidders = tempArray;
        }
    }

    handleInput(event){

        const name = event.target.name;
        const value = event.target.value;
        if (name == 'documentType')
        {
            //Update taxable on change of document type
            if (this.selectedDocumentType != value)
            {
                if (value == 'Bid_Format')
                {
                    this.isBidFormat = true;
                    this.isTaxable = false;
                } 
                else{
                    this.isBidFormat = false;
                    this.isTaxable = true;
                }
            }
            this.selectedDocumentType = value;
        }
        else if (name == 'isPrintSummary')
        {
            this.isPrintSummary = event.target.checked;
        }
        else if (name == 'isPrintDetails')
        {
            this.isPrintDetails = event.target.checked;
        }
        else if (name == 'selectedEmailTemplate')
        {
            this.selectedEmailTemplate = value;
            var htmlValue = this.emailTemplates.filter(x => { return x.Id == value; })[0].HtmlValue;
            this.emailBody = this.emailBody + '<br>' + htmlValue;
        }
        else if (name == 'isPreviewOnly')
        {
            this.isPreviewOnly = event.target.checked;
            this.isPrintOnly = false;
            this.hasPreviewPrintSelected = this.isPreviewOnly || this.isPrintOnly; //true as long as one is selected
        }
        else if (name == 'isPrintOnly')
        {
            this.isPrintOnly = event.target.checked;
            this.isPreviewOnly = false;
            this.hasPreviewPrintSelected =  this.isPreviewOnly || this.isPrintOnly; //true as long as one is selected
        }
        else if (name == 'isHideQtys')
        {
            this.isHideQtys = event.target.checked;
        }
        else if (name == 'isSubmittalVersion')
        {
            this.isSubmittalVersion = event.target.checked;
        }
        else if (name == 'printGrandTotal')
        {
            this.printGrandTotal = event.target.checked;
        }
        else if (name == 'isTaxable')
        {
            this.isTaxable = event.target.checked;
        }
        else if (name == 'material')
        {
            this.selectedMaterial = value;
        }
        else if (name == 'recipient')
        {
            this.selectedRecipient = value;
        }
        else if (name == 'contact')
        {
            this.selectedContact = value;
        }
        else if (name == 'poNumber')
        {
            this.poNumber = value;
        }
        else if (name == 'shipToName')
        {
            this.shipToName = value;
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
            this.populateStateAfterChange(''); //ensure state list is properly updated
        }
        else if (name == 'introductionParagraph')
        {
            this.introductionParagraph = value;
        }
        else if (name == 'endingParagraph')
        {
            this.endingParagraph = value;
        }
        else if (name == 'selectedPayment')
        {
            this.selectedPayment = value;
        }
        else if (name == 'jobReference')
        {
            this.jobReference = value;
        }
        else if (name == 'proFormaFreight')
        {
            this.proFormaFreight = value;
        }
        else if (name == 'selectedCreditType')
        {
            this.selectedCreditType = value;
        }
        else if (name == 'selectedShippingTerms')
        {
            this.selectedShippingTerms = value;
        }
        else if (name == 'toAddress')
        {
            this.toAddress = value;
        }
        else if (name == 'ccAddress')
        {
            this.ccAddress = value;
        }
        else if (name == 'bccAddress')
        {
            this.bccAddress = value;
        }
        else if (name == 'opportunityAmount')
        {
            this.opportunityAmount = value;
        }
        else if (name == 'emailSubject')
        {
            this.emailSubject = value;
        }
        else if (name == 'emailBody')
        {
            this.emailBody = event.detail.value;
        }
        else if (name == 'emailSignatureHtmlValue')
        {
            this.emailSignatureHtmlValue = event.detail.value;
        }
        else if (name == 'emailSignatureName')
        {
            this.emailSignatureName = value;
        }
        else if (name == 'contactName')
        {
            this.contactName = value;
        }
        else if (name == 'contactEmail')
        {
            if (this.contactEmail !== undefined && this.toAddress !== undefined && 
                this.toAddress.indexOf(this.contactEmail) != -1)
            {
                this.toAddress = this.toAddress.replace(this.contactEmail,'').replace(',,',',');
            }
            
            this.contactEmail = value;
        }
        else if (name == 'contactPhone')
        {
            this.contactPhone = value;
        }
        else if (name == 'contactFax')
        {
            this.contactFax = value;
        }
        else if (name == 'pdfName')
        {
            this.pdfName = value;
        }
        this.handleTriggers(); //fire visibility logic for fields
    }

    handleTriggers()
    {
        if (this.selectedDocumentType != 'Bid_Format') this.isShowingContact = true;
        else this.isShowingContact = false;

        if (this.selectedDocumentType  == 'Quote_w_Lump_Sum_Pricing'){
            this.isShowingHideQtys = true;
            this.isShowingSubmittalVersion = true;
        } 
        else{
            this.isShowingHideQtys = false;
            this.isShowingSubmittalVersion = false;
        }
        if (this.selectedDocumentType.indexOf('Add_Deduct') != -1) this.isShowingPrintSummary = true;
        else this.isShowingPrintSummary = false;

        if (this.selectedDocumentType.indexOf('Pro_Forma') != -1) this.isAnyProForma = true;
        else this.isAnyProForma = false;

        if (this.selectedDocumentType == 'Pro_Forma') this.isProForma = true;
        else this.isProForma = false;

        if (this.selectedDocumentType == 'Pro_Forma' || 
            this.selectedDocumentType == 'Pro_Forma_Letter_of_Credit') this.isProFormaOrLOC = true;
        else this.isProFormaOrLOC = false;
        
        if (this.selectedDocumentType == 'Pro_Forma' || 
            this.selectedDocumentType == 'Pro_Forma_Wire_Transfer') this.isProFormaOrWT = true;
        else this.isProFormaOrWT = false;

        if (this.selectedDocumentType == 'Bid_Format' || 
            this.selectedDocumentType == 'Quote_w_Pricing' || 
            this.selectedDocumentType == 'Quote_w_Lump_Sum_Pricing' ||
            this.selectedDocumentType == 'Add_Deduct') this.isShowingParagraphs = true;
        else this.isShowingParagraphs = false;

        if (this.selectedDocumentType == 'Bid_Format' || 
            this.selectedDocumentType == 'Quote_w_Pricing' || 
            this.selectedDocumentType == 'Quote_w_Lump_Sum_Pricing' ||
            this.selectedDocumentType == 'Pro_Forma' ||
            this.selectedDocumentType == 'Add_Deduct') this.isShowingPrintGrandTotal = true;
        else this.isShowingPrintGrandTotal = false;

        if(this.screenTwoStop || this.screenTwoBidder || this.screenTwoContact || this.screenThreePrint || this.screenFourEmail)
        {
            this.showPrevious = true;
        }
        else{
            this.showPrevious = false;
        }

        if (this.selectedRecipient == 'For Customer') this.isForCustomer = true;
        else this.isForCustomer = false;
    }

    handleRecalculate()
    {
        var tempGrandTotal = 0;
        var tempGrandTotalWithTax = 0;
                
        for(var i = 0; i < this.selectedPricingAlternates.length; i++)
        {
            for(var j = 0; j < this.alternatePricingList.length; j++)
            {
                if (this.alternatePricingList[j].Id == this.selectedPricingAlternates[i])
                {
                    tempGrandTotal += this.alternatePricingList[j].Total_incl_Freight_No_Tax__c;
                    tempGrandTotalWithTax += this.alternatePricingList[j].Total_incl_Freight_Tax__c;
                }
            }
        }
        this.opportunityAmountForPricing = this.isTaxable ? tempGrandTotalWithTax : tempGrandTotal;
    }
    
    updateAlternateString()
    {
        this.alternateString = '';
        for(var i = 0; i < this.selectedAlternates.length; i++)
        {
            if (this.alternateString == '') this.alternateString = '\'' + this.selectedAlternates[i] + '\'';
            else this.alternateString += ',\'' + this.selectedAlternates[i] + "'";
        }
        this.totalAlternateString = '';
        for(var i = 0; i < this.alternateList.length; i++){
            if (this.totalAlternateString == '') this.totalAlternateString = '\'' + this.alternateList[i].Id + '\'';
            else this.totalAlternateString += ',\'' + this.alternateList[i].Id + "'";
        }
    }

    handleNext()
    {
        this.loaded = false;
        if (this.screenOne)
        {
            this.updateAlternateString();
            UpdateQuoteTaxById({QuoteId: this.recordId}).then(taxUpdated =>{
                GetGrandTotals({quoteId: this.recordId, alternateString: this.alternateString, isTaxable: this.isTaxable}).then(totalStr => {
                    console.log('Totals: ' + totalStr);
                    const totals = totalStr.split('|');
                    this.grandTotal = totals[2];
                    this.grandTotalWithTax = totals[3];
                    this.opportunityAmount = this.isTaxable ? this.grandTotalWithTax : this.grandTotal;
                    this.opportunityAmountForPricing = this.isTaxable ? this.grandTotalWithTax : this.grandTotal;

                    this.screenOne = false;
    
                    //If estimating in audit, stop here
                    if (this.data.Opportunity.Estimating_Divisional_Status__c == 'In Audit' && 
                        this.selectedRecipient == 'For Customer' &&
                        (this.data.Quote.BidQuote__c == 'Estimate Detail' ||
                        this.data.Quote.BidQuote__c == 'Estimate Summary' ||
                        this.data.Quote.BidQuote__c == 'Estimate Super Summary'))
                    {
                        this.screenTwoStop = true;
                        this.handleTriggers();
                        this.loaded = true;
                    }
                    //If Bid/Quote
                    else{
                        //If Quote is type Bid and Bid_Format is selected
                        if (this.selectedDocumentType == 'Bid_Format' && this.selectedRecipient == 'For Customer' && this.data.Quote.BidQuote__c == 'Bid')
                        {
                            GetQuoteBidders({QuoteId: this.data.Quote.Id}).then(bidders =>
                            {
                                for(var i = 0; i < bidders.length; i++)
                                {
                                    bidders[i].Url = '/' + bidders[i].AccountId__c;
                                    bidders[i].Name = bidders[i].Bidder__c.substring(bidders[i].Bidder__c.indexOf(">")+1, bidders[i].Bidder__c.lastIndexOf("<"));
                                }
                                this.bidderList = bidders;
                                this.screenTwoBidder = true;
                                this.handleTriggers();
                                this.loaded = true;
                            });
                        }
                        //If Internal Bid_Format
                        else if (this.selectedDocumentType == 'Bid_Format' && this.selectedRecipient != 'For Customer')
                        {
                            this.screenThreePrint = true;
                            this.handleTriggers();
                            this.loaded = true;
                        }
                        //If any other document type
                        else
                        {
                            GetContactInfo({ContactId: this.selectedContact}).then(data =>{
                                this.contactName = data.Name;
                                this.contactEmail = data.Email;
                                this.contactPhone = data.Phone;
                                this.contactFax = data.Fax;
                                this.screenTwoContact = true;
                                this.loaded = true;
                                this.handleTriggers();
                            });
                        }
                    }
                    this.lastScreenName = 'Start';
                }).catch(error => {
                    this.handleError(error);
                });
            }).catch(error => {
                this.handleError(error);
            });
        }
        //Go to Print from Contact screen
        else if (this.screenTwoContact)
        {
            this.loaded = true;
            this.screenThreePrint = true;
            this.screenTwoContact = false;
            this.lastScreenName = 'Contact';
        }
        //Check that one bidder is selected before proceeding to Print
        else if (this.screenTwoBidder)
        {
            this.loaded = true;
            if (this.selectedBidders.length != 0)
            {
                if(this.territoryManagerEmail != null && this.territoryManagerEmail != '')
                {
                    this.bccAddress = this.territoryManagerEmail;
                    if(this.bidderBccAddress != null && this.bidderBccAddress != '')
                        this.bccAddress = this.bccAddress + ',' + this.bidderBccAddress;
                }
                else
                    this.bccAddress = this.bidderBccAddress; //override bccAddress with bidders selected (maybe handle this differently)
                this.screenThreePrint = true;
                this.screenTwoBidder = false;
                this.lastScreenName = 'Bidder';
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Form Error!',
                    message: 'Please select at least one bidder before proceeding.',
                    variant: 'warning'
                }));
            }
        }
        else if (this.screenThreePrint)
        {
            if(this.bidderBccAddress != null && this.bidderBccAddress != '')
                        this.bccAddress = this.territoryManagerEmail + ',' + this.bidderBccAddress;
            else
                this.bccAddress = this.territoryManagerEmail;
            //If for customer, prepare email screen
            if (this.selectedRecipient == 'For Customer' && this.isPreviewOnly)
            {
                console.log(this.alternateString);
                GetDocumentNames({alternateString: this.alternateString}).then(result => {
                    console.log('Doc Names returned: ' + result)
                    if (result != '')
                    {
                        this.isShowingDocWarning = true;
                        this.docNames = result;
                        var docNames = result.split(',');
                        docNames.forEach(x => {
                            var current = this.uploadedFiles.filter(y => { return y.Id == ('custom_'+x.trim());});
                            
                            if (current.length == 0){
                                
                                // this.uploadedFiles.push({
                                //     Id: 'custom_'+x.trim(),
                                //     Name: x.trim(),
                                //     RemoveName: x.trim() + ' [X]'
                                // });
                                
                            }
                        });
                        
                    }
                    if (this.toAddress.indexOf(this.contactEmail) == -1)
                    {
                        this.toAddress += (this.toAddress == '' ? this.contactEmail : ',' + this.contactEmail);
                    }
                    
                    this.toAddress = this.toAddress.replace(',,',',');
                    this.loaded = true;
                    this.screenFourEmail = true;
                    this.isLockingQuoteOnFinish = true;
                
                });
            }
            //Otherwise no changes will be saved, go to final screen.
            else{
                if (this.isPrintOnly)
                {
                    this.isLockingQuoteOnFinish = true;
                }
                else{
                    this.isLockingQuoteOnFinish = false;
                }
                this.loaded = true;
                this.screenFiveDone = true;
            }
            this.screenThreePrint = false;
            this.lastScreenName = 'Bidder';
        }
        //Go to final screen and warn user that changes/email will be saved/sent
        else if (this.screenFourEmail)
        {
            this.loaded = true;
            this.screenFourEmail = false;
            this.screenFiveDone = true;
            this.lastScreenName = 'Email';
        }
    }

    handlePrevious(){
        if (this.screenTwoStop)
        {
            this.screenOne = true;
            this.screenTwoStop = false;
            this.lastScreenName = 'Stop';
        }
        else if (this.screenTwoBidder)
        {
            this.screenOne = true;
            this.screenTwoBidder = false;
            this.lastScreenName = 'Bidder';
        }
        else if (this.screenTwoContact)
        {
            this.screenOne = true;
            this.screenTwoContact = false;
            this.lastScreenName = 'Contact';
        }
        else if (this.screenThreePrint)
        {
            this.screenThreePrint = false;
            if (this.selectedDocumentType == 'Bid_Format' && this.selectedRecipient == 'For Customer' && this.data.Quote.BidQuote__c == 'Bid')
            {
                this.screenTwoBidder = true;
            }
            else if (this.selectedDocumentType == 'Bid_Format' && this.selectedRecipient != 'For Customer')
            {
                this.screenOne = true; 
            }
            else{
                
                this.screenTwoContact = true;
            }
            this.lastScreenName = 'Print';
        }
        else if (this.screenFourEmail)
        {
            this.screenFourEmail = false;
            this.screenThreePrint = true;
            this.lastScreenName = 'Email';
        }
        else if (this.screenFiveDone)
        {
            this.screenFiveDone = false;
            if (this.lastScreenName == 'Email')
            {
                this.screenFourEmail = true;
            }
            else{
                this.screenThreePrint = true;
            }
            this.lastScreenName = 'Done';
        }
        this.handleTriggers();
    }

    //For testing purposes
    handleGeneratePDF(){
        this.loaded = false;
        this.generateUrlString(false).then(printQuoteId =>{
            console.log('Print Quote Id:' );
            console.log(printQuoteId);

            this.params = '';
            this.params +='quoteId='+this.data.Quote.Id;
            this.params +='&printquoteId='+printQuoteId
            this.params +='&alternates='+this.alternateString.replaceAll('\'','');
            this.urlstring = this.pageName + '?' + this.params;

            console.log(this.urlstring);
            GeneratePrintPDF({QuoteId: this.recordId, FileName: this.pdfName, PageName: this.pageName, Params: this.params}).then(attachmentId =>{
                console.log(attachmentId);
                this.loaded = true;
            }).catch(error => {
                this.handleError(error);
            });
        });
    }

    @track urlstring = '';
    @track pageName = '';
    @track params = '';


    @track printQuoteParams = [];
    generateUrlString(isPreview){
        this.urlstring = '';
        this.pageName = 'Quote_PDF_Global';
        
        if(this.selectedPayment != ''){
            this.selectedPayment = this.selectedPayment.replaceAll('%', '--p');
        }

        const format = (num, decimals) => num.toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
        });
        
        let printQuoteParams = {
            quoteId: this.data.Quote.Id,
            formType: this.selectedDocumentType,
            taxable: this.isTaxable,
            metric: false,
            print: this.printGrandTotal,
            totalwTax: parseFloat(this.grandTotalWithTax).toFixed(2),
            total: parseFloat(this.grandTotal).toFixed(2),
            alternates: this.alternateString,
            contactName: this.contactName,
            contactEmail: this.contactEmail,
            contactPhone: this.contactPhone,
            creditType: this.selectedCreditType,
            fax: this.contactFax,
            toAddress: this.toAddress,
            ccAddress: this.ccAddress,
            bccAddress: this.bccAddress,
            emailSubject: '',
            hideQtys: this.isHideQtys,
            shipToAddress: this.shipToAddress,
            paymentTerms: this.selectedPayment,
            shippingTerms: this.selectedShippingTerms,
            jobReference: this.jobReference,
            ourReference: this.data.Quote.Name,
            creditType: this.creditType,
            material: this.selectedMaterial,
            submittalVersion: this.isSubmittalVersion,
            internal:  (isPreview == true ? true : (this.selectedRecipient == 'Internal')),
            shipToName: this.shipToName.replaceAll('',''),
            shipToStreet: this.addressStreet.replaceAll('',''),
            shipToCity: this.addressCity,
            shipToState: this.addressState,
            shipToPostalCode: this.addressZip,
            shipToCountry: this.addressCountry,
            poNumber: this.poNumber,
            isCAD: this.isCAD,
            isPrintingGrandTotal: this.printGrandTotal,
            isPrintSummary: this.isPrintSummary,
            isPrintDetails: this.isPrintDetails
        };

        let stringify = JSON.stringify(printQuoteParams);
        console.log(stringify);
        this.loaded = false;
        return CreatePrintQuote({jsonParams: stringify});
    }
    

    handlePrint(){
        UpdateQuote({id: this.recordId, 
            introduction: this.introductionParagraph, 
            ending: this.endingParagraph, 
            updateNumber: this.isPrintOnly ? 'true' : 'false', 
            updateStatus: this.isPrintOnly ? 'true' : 'false'
        }).then(nothing => {
            this.generateUrlString(this.isPrintOnly ? false : true).then(printQuoteId =>{
                this.loaded = true;
                console.log('Print Quote Id:' );
                console.log(printQuoteId);
    
                this.params = '';
                this.params +='quoteId='+this.data.Quote.Id;
                this.params +='&printquoteId='+printQuoteId
                this.params +='&alternates='+this.alternateString.replaceAll('\'','');
                this.urlstring = this.pageName + '?' + this.params;
                
                var url = "/apex/"+this.urlstring; 
                console.log('urlString = ' + url);        
                window.open(url, '_blank');  
                if (this.isPrintOnly)
                {
                    this.handleFinish();
                }
            });
        });
    }

    @track uploadedFiles = [];
    @track filesToSend = [];
    
    handleUploadFinished(event){
        this.loaded = false;
        const uploadedFiles = event.detail.files;
        
        uploadedFiles.forEach(file => {
            this.uploadedFiles.push({ 
                Id: file.contentVersionId,
                Name: file.name,
                RemoveName: file.name + ' [X]'
            });
            console.log(file);
        });
        this.loaded = true;
    }

    handleRemoveFile(event){
        this.loaded = false;
        const fileId = event.target.accessKey;
        console.log(fileId);
        var tempArray = [];
        for(var i = 0; i < this.uploadedFiles.length; i++)
        {
            if (this.uploadedFiles[i].Id != fileId) 
                tempArray.push({
                    Id: this.uploadedFiles[i].Id, 
                    Name: this.uploadedFiles[i].Name, 
                    RemoveName: this.uploadedFiles[i].Name + ' [X]'
                });
        }
        this.uploadedFiles = tempArray;
        this.loaded = true;
    }

    @track emailBody = '';
    
    handleEmailSend(){
        console.log(this.emailBody);
        this.loaded = false;
        var test = this.uploadedFiles.map(x => x.Id);
        var temp = '';
        var temp2 = '';
        for(var i = 0; i < test.length; i++)
        {
            if (test[i].indexOf("custom_") == -1)
            {
                if (temp == '') temp = '\'' + test[i] + '\'';
                else temp += ',\'' + test[i] + '\'';
            }
        }
        
        this.generateUrlString(false).then(printQuoteId =>{
            console.log('Print Quote Id:' );
            console.log(printQuoteId);

            this.params = '';
            this.params +='quoteId='+this.data.Quote.Id;
            this.params +='&printquoteId='+printQuoteId
            this.params +='&alternates='+this.alternateString.replaceAll('\'','');
            this.urlstring = this.pageName + '?' + this.params;

            UpdateQuote({id: this.recordId, 
                introduction: this.introductionParagraph, 
                ending: this.endingParagraph, 
                updateNumber: 'true', 
                updateStatus: 'true'
            }).then(nothing => {
                GeneratePrintPDF({QuoteId: this.recordId, FileName: this.pdfName, PageName: this.pageName, Params: this.params}).then(attachmentId =>{
                    attachmentId = '\'' + attachmentId + '\'';
                    console.log(attachmentId);
                    var params = {
                        QuoteId: this.recordId,
                        ToAddress: this.toAddress,
                        CcAddress: this.ccAddress,
                        BccAddress: this.bccAddress,
                        Subject: this.emailSubject,
                        BodyHtml: this.emailBody,
                        AttachmentIds: temp == '' ? attachmentId : attachmentId + ',' + temp
                    };
                    console.log(params);
                    if (temp2 != '')
                    {
                        CreateAsyncProcess({QuoteId: this.recordId}).then(r1 =>{
                            var params3 = {
                                QuoteId: this.recordId,
                                AsyncProcessId: r1,
                                ToAddress: this.toAddress,
                                CcAddress: this.ccAddress,
                                BccAddress: this.bccAddress,
                                Subject: this.emailSubject,
                                BodyHtml: this.emailBody,
                                AttachmentIds: temp == '' ? attachmentId : attachmentId + ',' + temp,
                                CustomForms: temp2
                            };
                            SendCustomFormsEmail(params3).then(r2 => {
                                
                            });
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Success!',
                                message: 'The email has custom forms being generated, and it will be sent shortly. You will be notified when it is sent.',
                                mode: 'sticky',
                                variant: 'success'
                            }));
                            this.loaded = true;
                            this.closeQuickAction();
                        }).catch(error => {
                            this.handleError(error);
                        });
                    }
                    else{
                        SendEmail(params).then(results => {
                            console.log(results);
                            if (results == '')
                            {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Success!',
                                    message: 'Email Sent and Quote updated. Please refresh page.',
                                    mode: 'sticky',
                                    variant: 'success'
                                }));
                                this.closeQuickAction();
                            }
                            else{
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Error!',
                                    message: results,
                                    variant: 'warning'
                                }));
                            }
                            this.loaded = true;
                        }).catch(error => {
                            this.handleError(error);
                        });
                    }
                });
            });
        });
    }

    handleContactSearch(event) {
        const target = event.target;
        console.log(event.detail);
        ContactSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting accounts: " + error);
            });
    }

    handleUserSearch(event) {
        const target = event.target;
        console.log(event.detail);
        UserSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting accounts: " + error);
            });
    }

    handleLookupSelectionChange(event) {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        const target = event.target;
        console.log(target);
        var name = '';

        if (selection.length > 0) {
            this.tempInt = 1;
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);
            
            if (event.target.name == "toContact" || event.target.name == "toUser") {
                if (subTitle !== undefined && subTitle !== '')
                {
                    this.toAddress += this.toAddress.length != 0 ? ',' + subTitle : subTitle;
                }
            } else if (event.target.name == "ccContact" || event.target.name == "ccUser") {
                if (subTitle !== undefined && subTitle !== '')
                    this.ccAddress += this.ccAddress.length != 0 ? ',' + subTitle : subTitle;
            } else if (event.target.name == "bccContact" || event.target.name == "bccUser") {
                if (subTitle !== undefined && subTitle !== '')
                    this.bccAddress += this.bccAddress.length != 0 ? ',' + subTitle : subTitle;
            }
            target.clearSelection();
        }
    }

    handleFinish(){
        console.log('opportunity amount is [' + this.opportunityAmountForPricing + ']');

        if (this.isForCustomer)
        {
            this.loaded = false;
            if (this.selectedDocumentType == 'Bid_Format' && this.selectedRecipient == 'For Customer' && this.data.Quote.BidQuote__c == 'Bid')
            {
                var bidderStr = '';
                for(var i = 0; i < this.selectedBidders.length; i++)
                {
                    if (bidderStr == '') bidderStr = '\'' + this.selectedBidders[i] + '\'';
                    else bidderStr += '\'' + this.selectedBidders[i] + '\'';
                }
                console.log(bidderStr);
                UpdateQuoteBiddersToSent({bidderIds: bidderStr}).then(results => {
                    UpdateOpportunityAmountAndStage({Id: this.data.Opportunity.Id, NewAmount: this.opportunityAmountForPricing.toString(), quoteId: this.recordId}).then(results2 => {
                        if (!this.isPrintOnly) //Do not email if printing and emailing separately from this process
                        {
                            this.handleEmailSend();
                        }
                        else{
                            //Quote updated, refresh page to show status change
                            window.location.reload();
                        }
                    }).catch(error => {
                        this.handleError(error);
                    });
                }).catch(error => {
                    this.handleError(error);
                });
            }
            else{
                UpdateOpportunityAmountAndStage({Id: this.data.Opportunity.Id, NewAmount: this.opportunityAmountForPricing.toString(), quoteId: this.recordId}).then(results2 => {
                    if (!this.isPrintOnly) //Do not email if printing and emailing separately from this process
                    {
                        this.handleEmailSend();
                    }
                    else{
                        //Quote updated, refresh page to show status change
                        window.location.reload();
                    }
                }).catch(error => {
                    this.handleError(error);
                });
            }
        }
        else{
            window.location.reload();
        }
    }

    /** Address Logic **/
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


    handleManageSignatures(){
        window.open(window.location.origin + '/lightning/o/EmailTemplate/home?queryScope=mine', '_blank');  
    }

    handleCreateSignature(){
        this.screenFourEmail = false;
        this.screenFourSignature = true;
    }

    handleCancelSignature(){
        this.screenFourSignature = false;
        this.screenFourEmail = true;
    }

    @track emailSignatureName;
    @track emailSignatureHtmlValue;
    handleAddSignature(){
        this.loaded = false;
        CreateNewQuoteEmailTemplate({
            userId: userId,
            name: this.emailSignatureName,
            html: this.emailSignatureHtmlValue
        }).then(data =>{
            console.log(data);
            if (data == 'Success')
            {
                GetUserEmailTemplates({userId: userId}).then(templates =>{
                    this.emailTemplates = templates;
                    templates.forEach(x => {
                        this.emailTemplateList.push({
                            label: x.Subject,
                            value: x.Id
                        });
                    });
                    console.log(templates);
                    this.loaded = true;
                    this.emailSignatureName = '';
                    this.emailSignatureHtmlValue = '';
                    this.handleCancelSignature();
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'New Template added.',
                        variant: 'success'
                    }));
                }).catch(error => {
                    this.handleError(error);
                });
            }
            else{
                this.loaded = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error creating signature:',
                    message: data,
                    variant: 'warning'
                }));
            }
        })
    }

    handleCancel(){
        this.closeQuickAction();
    }
    
    closeQuickAction() {
        console.log('TEST END');
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}