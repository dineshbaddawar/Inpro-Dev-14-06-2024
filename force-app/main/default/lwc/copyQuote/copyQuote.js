import {
    LightningElement,
    api,
    track
} from 'lwc';

import copyQuote from '@salesforce/apex/CopyQuoteHelper.copyQuote';
import getBidders from '@salesforce/apex/CopyQuoteHelper.getBidders';
import hasBreakoutPermission from '@salesforce/apex/CopyQuoteHelper.hasBreakoutPermission';
import getAlternates from '@salesforce/apex/CopyQuoteHelper.getAlternates';
import getQuote from '@salesforce/apex/CopyQuoteHelper.getQuote';
import getContacts from '@salesforce/apex/CopyQuoteHelper.getContacts';
import accountSearch from '@salesforce/apex/CopyQuoteHelper.accountSearch';
import getExistingProductList from '@salesforce/apex/QuickConfigHelper.getExistingProductList';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';



import {
    NavigationMixin
} from 'lightning/navigation';

export default class CopyQuote extends NavigationMixin(LightningElement) {

    @api recordId;
    @track loaded = false;
    @track Response = '';
    @track QuoteId = '';
    @track ValidId = false;
    @track existingAlternates = false;
    @track alternateList = [];
    @track missingAlternateList = [];
    @track bidderList = [];
    @track accountList = [];
    @track contactList = [];
    @track typeList = [];
    @track accountId = '';
    @track contactId = '';
    @track theRecord = {};
    @track revision = 0;
    @track type = 'Bid';
    @track versionDescription = '';
    @track newQuoteNumber = false;
    @track selectedAccount = {};
    @track asyncSave = false;
    @track resetPricingBool = true;
    @track keepUnitPriceBool = false;
    @track decreaseUnitPriceBool = false;
    @track increaseUnitPriceBool = false;
    @track OverrideAccount = true;
    @track existingProductList = [];
    @track breakOut = false;
    @track alternateName = '';
    @track canBreakOut = false;
    @track overrideAccountId = '';
    @track missingAltMessage = '';

    loadPermissions() {
        hasBreakoutPermission().then(data => {
                if (data) {
                    try {

                        console.log(data);
                        if (data == true)
                            this.canBreakOut = true;
                        console.log(this.canBreakOut);
                    } catch (error) {
                        console.log("Error checking permissions: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error checking permissions1: " + errorJson);
            });


    }

    handleCheckAllChecked(event) {
        this.existingProductList.forEach(option => {
            option.Selected = event.target.checked;
        });
    }

    handleUncheckAll() {
        this.existingProductList.forEach(option => {
            option.Selected = false;
        });
    }

    handleApplyToSelectedOnClick(event) {

        var toUpdate = this.existingProductList.filter(function (product) {
            return product.Selected == true
        });

        toUpdate.forEach(x => {
            x.AlternateName = this.alternateName;
        });

    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.existingProductList.filter(product => {
            return product.Id == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
    }


    handleBreakOutClickBack() {
        this.breakOut = false;
    }

    handleBreakOutClick() {
        //this.loaded = false;
        this.breakOut = true;
        // this.loadExistingProducts();
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    connectedCallback() {

        var oBid = {
            label: 'Bid',
            value: 'Bid'
        };
        var oEstDetail = {
            label: 'Estimate Detail',
            value: 'Estimate Detail'
        };
        var oEstSum = {
            label: 'Estimate Summary',
            value: 'Estimate Summary'
        };
        var oEstSupSum = {
            label: 'Estimate Super Summary',
            value: 'Estimate Super Summary'
        };
        var oQuote = {
            label: 'Quote',
            value: 'Quote'
        };

        this.typeList = [...this.typeList, oBid];
        this.typeList = [...this.typeList, oEstDetail];
        this.typeList = [...this.typeList, oEstSum];
        this.typeList = [...this.typeList, oEstSupSum];
        this.typeList = [...this.typeList, oQuote];

        this.theRecord["newQuoteNumber"] = false;
        if (this.theRecord["pricingRadio"] == null || this.theRecord["pricingRadio"] == "")
            this.theRecord["pricingRadio"] = 1;
        this.theRecord["type"] = "Bid";
        this.loadAlternates();
        this.loadPermissions();
        this.loadBidders();
        this.loadAccount();
    }

    loadExistingProducts() {
        var date = Date().toLocaleString();
        console.log(date);
        console.log(this.recordId);
        this.existingProductList = [];
        getExistingProductList({
                recordId: this.recordId,
                cache: date
            }).then(data => {
                if (data) {
                    try {
                        console.log("Product List:");
                        console.log(data);
                        data.forEach(item => {

                            var newItem = {
                                Id: item.Id,
                                rId: item.rId,
                                Name: item.Name,
                                Color: item.Color,
                                Quantity: item.Quantity,
                                Description: item.Description,
                                AlternateName: item.AlternateName,
                                AlternateId: item.AlternateId,
                                rAlternateId: item.rAlternateId,
                                ColorPalette: item.ColorPalette,
                                PickSequence: item.PickSequence,
                                IsRemoved: false,
                                Selected: false,
                                Checked: false,
                                bpColorCode: item.bpColorCode,
                                bpColorPallette: item.bpColorPallette,
                                txColorCode: item.txColorCode,
                                txColorPallette: item.txColorPallette,
                                acColorCode: item.acColorCode,
                                acColorPallette: item.acColorPallette,
                                fpColorCode: item.fpColorCode,
                                fpColorPallette: item.fpColorPallette,
                                AccentColor: item.AccentColor,
                                MountingType: item.MountingType,
                                FontType: item.FontType,
                                FontSize: item.FontSize,
                                HorizontalAlign: item.HorizontalAlign,
                                VerticalAlign: item.VerticalAlign
                            };

                            this.existingProductList.push(newItem);
                        });

                        if (this.existingProductList.length > 0)
                            this.alternateList.forEach(alt => {

                                var checkAlternateExists = this.existingProductList.filter(x => {
                                    return alt.Name.trim() == x.AlternateName.trim();
                                })[0];

                                if (checkAlternateExists == null) {

                                    console.log("Alternate Does Not Exist In Experlogix: " + alt.Name);
                                    var alternate = {
                                        Name: alt.Name,
                                        Number: alt.Number,
                                        AlternateId: alt.AlternateId,
                                        Selected: false,
                                        GroupName: ''
                                    };

                                    this.missingAlternateList.push(alternate);

                                } else {
                                    console.log("Alternate Exists In Experlogix: " + alt.Name);
                                }

                            });

                        // this.missingAlternateList.forEach(m => {
                        //     this.alternateList = this.alternateList.filter(a => {
                        //         return a.Name != m.Name;
                        //     });
                        // });


                        console.log("end wire");

                    } catch (error) {
                        console.log("Error Binding Existing Products: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }

                var missingAltTxt = '';
                var counter = 0;
                this.missingAlternateList.forEach(x => {
                    if (counter == 0)
                        missingAltTxt += x.Name;
                    else
                        missingAltTxt += ", " + x.Name;
                    counter++;
                });

                if (missingAltTxt != '')
                    this.missingAltMessage = 'ATTENTION: The following alternates on the quote in Salesforce, do not exist in Experlogix, and will not be available to be copied: ' + missingAltTxt;
                this.loaded = true;

            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting products: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
            });
    }

    handleGridInputChange(event) {
        if (this.existingProductList.length > 0) {
            let value = event.target.value;
            let selectedItem = this.existingProductList.filter(function (product) {
                return product.Id === event.target.accessKey;
            })[0];

            console.log("selected value changing: " + value + " " + selectedItem.Id + " key: " + event.target.accessKey);
            if (event.target.name == "Color") {
                selectedItem.Color = value;
            } else if (event.target.name == "Quantity") {
                selectedItem.Quantity = value;
            } else if (event.target.name == "Description") {
                selectedItem.Description = value;
            } else {
                selectedItem[event.target.name] = value;
                console.log(selectedItem[event.target.name]);
            }
        }
    }

    handleCopyQuoteClick() {
        this.loaded = false;
        this.callCopyQuote();
    }

    callCopyQuote() {

        try {


            //get selected configs
            this.Response = "";
            var configList = [];
            let selectedAlts = this.alternateList.filter(function (alt) {
                return alt.Selected == true;
            });
            selectedAlts.forEach(alt => {
                configList.push(alt.Number);
            });
            var configListJSON = JSON.stringify(configList);

            //get selected bidders
            var biddersList = [];
            let selectedBidders = this.bidderList.filter(function (bid) {
                return bid.Selected == true;
            });
            selectedBidders.forEach(bid => {
                biddersList.push(bid.Id);
            });
            var biddersListJSON = JSON.stringify(biddersList);

            //get reprice percent
            var repricePercent = 0;
            if (this.theRecord["pricingRadio"] == "3") {
                repricePercent = this.theRecord["decreasePercent"];
            } else if (this.theRecord["pricingRadio"] == "4") {
                repricePercent = this.theRecord["increasePercent"];
            }

            console.log("recordId: " + this.recordId);
            console.log("accountid: " + this.accountId);
            console.log("configList: " + configListJSON);
            console.log("repriceOption: " + this.theRecord["pricingRadio"]);
            console.log("repricePercent: " + repricePercent);
            console.log("newQuoteNumber: " + this.theRecord["newQuoteNumber"]);
            console.log("quoteName: " + this.theRecord["quoteName"]);
            console.log("versionName: " + this.theRecord["VersionName"]);
            console.log("type: " + this.theRecord["type"]);
            console.log("contactId: " + this.contactId);
            console.log("bidders: " + biddersListJSON);
            console.log("userId: " + userId);
            console.log("revisionNumber: " + this.theRecord["RevisionNumber"]);
            var prodListJson = JSON.stringify(this.existingProductList);
            console.log(prodListJson);
            var productsToBreakout = [];
            if (this.breakOut)
                productsToBreakout = this.existingProductList;

            //if(configList.length > 2)
            //{
            this.asyncSave = true;
            //}
            if (configList.length == 0 && this.alternateList.length > 0 && this.breakOut == false) {
                this.Response = "Error: You must select at least one alternate before copying the quote.";
                this.loaded = true;
                return;
            }

            // string recordId, string accountId, List<Integer> configs, Integer repriceOption, Decimal repricePercent,
            // Boolean newQuoteNumber, string orderEditRequestId, string quoteName, string type, string contactId, List<string> bidders
            try {
                if (this.OverrideAccount)
                    this.accountId = this.overrideAccountId;
                copyQuote({
                        recordId: this.recordId,
                        accountId: this.accountId,
                        configs: configList,
                        repriceOption: parseInt(this.theRecord["pricingRadio"]),
                        repricePercent: repricePercent,
                        newQuoteNumber: this.newQuoteNumber,
                        orderEditRequestId: "",
                        quoteName: this.theRecord["quoteName"],
                        versionName: this.theRecord["VersionName"],
                        typex: this.theRecord["type"],
                        contactId: this.contactId,
                        bidders: biddersList,
                        userId: userId,
                        revisionNumber: this.theRecord["RevisionNumber"],
                        parentAccountId: '',
                        ultimateParentAccountId: '',
                        products: productsToBreakout
                    }).then(data => {
                        try {
                            if (data) {
                                this.Response = data;
                                console.log(data);
                                this.loaded = true;
                                this.QuoteId = data;
                                this.validateId(data);
                            }
                        } catch (error) {
                            console.log("error copying quote response: " + error);
                        }
                    })
                    .catch(error => {
                        // TODO: handle error
                        var errorJSON = JSON.stringify(error);
                        console.log(errorJSON);

                        if (errorJSON.includes("Encountered HTML Content when looking for"))
                            errorJSON = "Operation timeout, please try again. If the copy doesn't go through after three attempts, please contact IT Support.";


                        this.Response = "Error copying quote: " + errorJSON;
                        this.loaded = true;
                    });

            } catch (error) {
                var errorJSON = JSON.stringify(error);
                console.log("Error Copying Quote: " + errorJSON);
            }
        } catch (error) {
            var errorJSON = JSON.stringify(error);
            console.log("Error Copying Quote: " + errorJSON);
        }
    }

    viewRecord(event) {
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.QuoteId,
                "objectApiName": "Quote",
                "actionName": "view"
            },
        });
    }

    validateId(id) {

        if (id.length == 15 || id.length == 18) {
            this.ValidId = true;

            // Generate a URL to a User record page
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": this.QuoteId,
                    "objectApiName": "Quote",
                    "actionName": "view",
                },
            }).then(url => {
                console.log(window.location.origin + url);
                const event = new ShowToastEvent({
                    "title": "Success!",
                    "message": "Quote created! See it {1}",
                    "messageData": [
                        'Salesforce',
                        {
                            url: url,
                            label: 'here'
                        }
                    ],
                    variant: 'success',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            }).finally(x => {
                console.log("finally close");
                this.closeQuickAction();
            });
        } else {
            this.ValidId = false;
        }
    }

    loadAlternates() {
        getAlternates({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {

                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);

                        data.forEach(alt => {
                            var alternate = {
                                Name: alt.Name__c,
                                Number: alt.Number__c,
                                AlternateId: alt.Id,
                                Selected: false,
                                GroupName: ''
                            };
                            this.alternateList.push(alternate);
                        });

                    } catch (error) {
                        console.log("Error Loading Alternates: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loadExistingProducts();
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting alternates: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    loadBidders() {
        getBidders({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {

                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(bidder => {

                            // String bQuery =  'SELECT AccountId__c, Bidder_Name__c, Bidder__c, Pricing_Group__c, Primary__c, Quote__c, ' + 
                            // 'Status__c, MSCRM_ID__c, Id, Name, Inpro_Interiors__c, Bidder_Name__r.Bidder__r.Customer_Number__c, ' + 
                            // 'Bidder_Name__r.Bidder__r.Name, Bidder_Name__r.Bidder__r.Type FROM Quote_Bidder__c ' +
                            // 'where Quote__c = \'' + recordId + '\'';


                            var bid = {
                                PriceGroup: bidder.Pricing_Group__c,
                                Status: bidder.Quote_Status__c,
                                Selected: false,
                                Id: bidder.Id
                            };

                            if (bidder.Quote_Type__c != null)
                                bid.QuoteType = bidder.Quote_Type__c;

                            if (bidder.Installation_Type__c != null) {
                                if (bidder.Installation_Type__c == 'Inpro Interiors')
                                    bid.Interiors = true;
                                else
                                    bid.Interiors = false;
                            } else
                                bid.Interiors = false;

                            if (bidder.Bidder__r != null) {
                                if (bidder.Bidder__r.Customer_Number__c != null)
                                    bid.AccountNumber = bidder.Bidder__r.Customer_Number__c;
                                bid.Account = bidder.Bidder__r.Name;
                                if (bidder.Bidder__r.Type != null)
                                    bid.BidType = bidder.Bidder__r.Type;
                            }

                            if (bidder.Contact__r != null && bidder.Contact__r.Name != null)
                                bid.Contact = bidder.Contact__r.Name;

                            var option = {
                                label: bidder.Bidder__r.Name + ' (' + bidder.Bidder__r.Customer_Number__c + ')',
                                value: bidder.Bidder__r.Id
                            };
                            var accountIsInList = false;
                            for (var i = 0; i < this.accountList.length; i++) {
                                if (this.accountList[i].value == bidder.Bidder__r.Id)
                                    accountIsInList = true;
                            }
                            if (!accountIsInList)
                                this.accountList = [...this.accountList, option];
                            this.bidderList.push(bid);
                        });

                    } catch (error) {
                        console.log("Error Loading Bidders: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting Bidders: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    loadAccount() {
        getQuote({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {

                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(Quote => {
                            var accountIsInList = false;
                            if (Quote.Account.Inactive__c == false) {
                                var option = {
                                    label: Quote.Account.Name + ' (' + Quote.Account.Customer_Number__c + ')',
                                    value: Quote.AccountId
                                };
                                for (var i = 0; i < this.accountList.length; i++) {
                                    if (this.accountList[i].value == Quote.AccountId)
                                        accountIsInList = true;
                                }
                                if (!accountIsInList)
                                    this.accountList = [...this.accountList, option];
                                //this.accountList.push(option);
                            }
                            if (Quote.BidQuote__c != null && Quote.BidQuote__c == "Estimate Detail") {
                                this.type = "Bid";
                                this.theRecord["type"] = "Bid";
                            } else {
                                this.type = Quote.BidQuote__c;
                                this.theRecord["type"] = Quote.BidQuote__c;
                            }
                        });

                        //if(data[0].BidQuote__c != null)

                        this.accountId = data[0].Primary_Bidder__c;
                        this.revision = data[0].Revision_Number__c + 1;
                        this.theRecord["RevisionNumber"] = this.revision;
                        this.versionDescription = data[0].Version_Description__c;
                        this.theRecord["VersionName"] = data[0].Version_Description__c;
                        var newLookup = {
                            id: this.accountId,
                            sObjectType: 'account',
                            icon: 'standard:account',
                            title: data[0].Account.Name,
                            subtitle: data[0].Account.Customer_Number__c
                        };
                        this.selectedAccount = newLookup;
                        this.overrideAccountId = this.accountId;

                        this.contactId = data[0].ContactId;
                        this.loadContacts();

                    } catch (error) {
                        console.log("Error Loading Bidders: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting Bidders: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    loadContacts() {
        this.contactList = [];
        getContacts({
                accountId: this.accountId
            }).then(data => {
                if (data) {
                    try {

                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        data.forEach(Contact => {

                            var option = {
                                label: Contact.Name,
                                value: Contact.Id
                            };

                            this.contactList = [...this.contactList, option];

                        });

                    } catch (error) {
                        console.log("Error Loading Bidders: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting Bidders: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    handleInputUpdate(event) {
        console.log("check");
        if (event.target.name == "pricingRadio") {
            if (event.target.accessKey == 1) {
                this.resetPricingBool = true;
                this.keepUnitPriceBool = false;
                this.decreaseUnitPriceBool = false;
                this.increaseUnitPriceBool = false;
            } else if (event.target.accessKey == 2) {
                this.resetPricingBool = false;
                this.keepUnitPriceBool = true;
                this.decreaseUnitPriceBool = false;
                this.increaseUnitPriceBool = false;
            } else if (event.target.accessKey == 3) {
                this.resetPricingBool = false;
                this.keepUnitPriceBool = false;
                this.decreaseUnitPriceBool = true;
                this.increaseUnitPriceBool = false;
            } else if (event.target.accessKey == 4) {
                this.resetPricingBool = false;
                this.keepUnitPriceBool = false;
                this.decreaseUnitPriceBool = false;
                this.increaseUnitPriceBool = true;
            }

            this.theRecord[event.target.name] = event.target.accessKey;
        } else if (event.target.name == "newQuoteNumber") {
            this.theRecord["newQuoteNumber"] = event.target.checked;
            this.newQuoteNumber = event.target.checked;
            if (this.newQuoteNumber == false) {
                this.accountId = this.theRecord["CopyToAccount"];
                this.overrideAccountId = this.theRecord["CopyToAccount"];
            }
        } else if (event.target.name == "Contact") {
            this.contactId = event.target.value;
            console.log(this.contactId);
        } else if (event.target.name == "type") {
            this.type = event.target.value;
            this.theRecord[event.target.name] = event.target.value;
            console.log(this.type);
        } else if (event.target.name == "CopyToAccount") {
            if (this.newQuoteNumber == false) {
                this.accountId = event.target.value;
                this.overrideAccountId = event.target.value;
                console.log(this.accountId);
            }
            var newLookup = {
                id: this.accountId,
                sObjectType: 'account',
                icon: 'standard:account',
                title: event.target.options.find(opt => opt.value === event.detail.value).label
            };
            this.selectedAccount = newLookup;
            this.theRecord[event.target.name] = event.target.value;
            this.loadContacts();
        } else if (event.target.name == "overrideAccount") {
            this.OverrideAccount = event.target.checked;
        } else {
            this.theRecord[event.target.name] = event.target.value;
        }
    }

    handleAltChecked(event) {
        let selectedItem = this.alternateList.filter(function (alt) {
            return alt.AlternateId === event.target.accessKey;
        })[0];

        selectedItem.Selected = event.target.checked;

    }

    handleCheckAllAltChecked(event) {
        this.alternateList.forEach(alt => {
            alt.Selected = event.target.checked;
        });
    }

    handleCheckAllBiddersChecked(event) {
        this.bidderList.forEach(bidder => {
            bidder.Selected = event.target.checked;
        });
    }

    handleBidderChecked(event) {
        let selectedItem = this.bidderList.filter(function (bid) {
            return bid.Id === event.target.accessKey;
        })[0];

        selectedItem.Selected = event.target.checked;

    }

    handleAccountSearch(event) {
        const target = event.target;
        console.log(event.target.value);
        accountSearch(event.detail)
            .then(results => {
                console.log("Account results count: " + results.length);
                target.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting accounts: " + error);
            });
    }

    handleAltNameUpdate(event) {
        this.alternateName = event.target.value;
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
        this.theRecord[event.target.name] = id;
        if (event.target.name == 'primaryBidderLookup') {
            this.accountId = id;
            this.overrideAccountId = id;
        } else {
            this.accountId = id;
            this.overrideAccountId = id;
        }
    }

}