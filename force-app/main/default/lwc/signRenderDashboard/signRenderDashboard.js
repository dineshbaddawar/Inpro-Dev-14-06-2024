import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import getAlternates from '@salesforce/apex/SignScheduleManagementHelper.getAlternates';
import getProducts from '@salesforce/apex/SignScheduleManagementHelper.getProducts';
import getSignScheduleItems from '@salesforce/apex/SignScheduleManagementHelper.getSignScheduleItems';
import renderSign from '@salesforce/apex/SignScheduleManagementHelper.renderSign';
import getQuoteLineItems from '@salesforce/apex/SignRenderDashboardHelper.getQuoteLineItems';
import getAllSignScheduleItems from '@salesforce/apex/SignRenderDashboardHelper.getAllSignScheduleItems';
import saveToCRM from '@salesforce/apex/SignRenderDashboardHelper.saveToCRM';
import getContacts from '@salesforce/apex/SignRenderDashboardHelper.getContacts';
import emailSign from '@salesforce/apex/SignRenderDashboardHelper.emailSign';
import userId from '@salesforce/user/Id';

export default class SignRenderDashboard extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track showError = false;
    @track errorMessage = '';
    @track currentSignSchedule = [];
    @track imageData = ''; //'data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==';
    @track selectedItem = {};
    

    @track alternateList = [];
    @track alternateOptionList = [];
    @track productList = [];
    @track productOptionList = [];
    @track selectedProductId = '';
    @track cacheDate = Date().toLocaleString();
    @track saveSigns = false;
    @track renderedSign = false;
    @track AllSignSchedules = [];
    @track emailSigns = false;
    @track contactList = [];
    @track contactsSelected = [];
    @track alternatesSelected = [];
    @track attachSignSchedule = false;

    connectedCallback() {
        this.loadExistingAlternates();
        this.loadExistingProducts();
        this.loaded = true;
    }

    handleSaveImage(event) {
        this.loaded = false;
        var SignScheduleIds = [];
        this.AllSignSchedules = [];
        console.log('start handle save.');
        console.log(this.recordId);
        try {

            getAllSignScheduleItems({
                    quoteId: this.recordId
                }).then(data => {
                    if (data) {
                        var myJSON = JSON.stringify(data);
                        console.log("All SignSchedule Items: ")
                        console.log(myJSON);

                        data.forEach(ss => {

                            var signSchedule = {
                                Id: ss.Id,
                                Name: '',
                                Selected: false,
                                Line1: ss.Line1__c,
                                Line2: ss.Line2__c,
                                Line3: ss.Line3__c,
                                Line4: ss.Line4__c,
                                Line5: ss.Line5__c,
                                Line6: ss.Line6__c,
                                Line7: ss.Line7__c,
                                Line8: ss.Line8__c,
                                Line9: ss.Line9__c,
                                Line10: ss.Line10__c,
                                Line11: ss.Line11__c,
                                Line12: ss.Line12__c,
                                Line13: ss.Line13__c,
                                Line14: ss.Line14__c,
                                Line15: ss.Line15__c,
                                Line16: ss.Line16__c,
                                Line17: ss.Line17__c,
                                Line18: ss.Line18__c,
                                Line19: ss.Line19__c,
                                Line20: ss.Line20__c,
                                MadeChanges: false,
                                Index: ss.Index__c,
                                SignScheduleId__c: ss.SignScheduleId__c,
                                Line1Font: ss.Line1Font__c,
                                Line2Font: ss.Line2Font__c,
                                Line3Font: ss.Line3Font__c,
                                Line4Font: ss.Line4Font__c,
                                Line5Font: ss.Line5Font__c,
                                Line6Font: ss.Line6Font__c,
                                Line7Font: ss.Line7Font__c,
                                Line8Font: ss.Line8Font__c,
                                Line9Font: ss.Line9Font__c,
                                Line10Font: ss.Line10Font__c,
                                Line11Font: ss.Line11Font__c,
                                Line12Font: ss.Line12Font__c,
                                Line13Font: ss.Line13Font__c,
                                Line14Font: ss.Line14Font__c,
                                Line15Font: ss.Line15Font__c,
                                Line16Font: ss.Line16Font__c,
                                Line17Font: ss.Line17Font__c,
                                Line18Font: ss.Line18Font__c,
                                Line19Font: ss.Line19Font__c,
                                Line20Font: ss.Line20Font__c,
                                Text_Too_Tall__c: ss.Text_Too_Tall__c,
                                Text_Too_Wide__c: ss.Text_Too_Wide__c,
                                SavedToCRM__c: ss.SavedToCRM__c,
                                Missing_Configuration_Info__c: ss.Missing_Configuration_Info__c
                            };

                            this.AllSignSchedules.push(signSchedule);
                        });

                        if (this.AllSignSchedules.length == 0)
                        {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Warning',
                                message: 'No sign schedules were detected for this quote.',
                                variant: 'warning'
                            }));
                        }

                        this.AllSignSchedules.forEach(p => {
                            if (SignScheduleIds.includes(p.SignScheduleId__c) == false)
                                SignScheduleIds.push(p.SignScheduleId__c);
                        });
                        console.log("SignSchedule Groups:");
                        console.log(SignScheduleIds);

                        console.log("start get quote line items");
                        getQuoteLineItems({
                                SignScheduleIds: SignScheduleIds
                            }).then(data => {
                                if (data) {
                                    var qlmJSON = JSON.stringify(data);
                                    console.log("quote line items:")
                                   // console.log(qlmJSON);                                    
                                    //SignScheduleId__c, Item_Number__c, Alternate__r.Name__c, Alternate__r.Number__c
                                    //Id, Quote.QuoteNumber
                                    this.AllSignSchedules.forEach(line => {
                                        var filteredLine = data.filter(x => {
                                            return x.SignScheduleId__c == line.SignScheduleId__c
                                        })[0];
                                        line.Alternate = filteredLine.Alternate__r.Name__c;
                                        line.ItemNumber = filteredLine.Item_Number__c;
                                        line.QuoteNumber = filteredLine.Quote.QuoteNumber;
                                        line.QuoteDetailId = filteredLine.Id;
                                    });

                                    this.saveSigns = true;
                                } else if (error) {
                                    var errorJSON = JSON.stringify(error);
                                    this.errorMessage = errorJSON;
                                    console.log(errorJSON);
                                    this.showError = true;
                                }
                                this.loaded = true;
                            })
                            .catch(error => {
                                // TODO: handle error
                                var errorJSON = JSON.stringify(error);
                                console.log("Error getting quoteLineItems: " + errorJSON);
                                this.errorMessage = errorJSON;
                                this.showError = true;
                                this.loaded = true;
                            });


                    } else if (error) {
                        this.errorMessage = error;
                        this.showError = true;
                        this.loaded = true;
                        console.log(error);
                    }
                    
                })
                .catch(error => {
                    // TODO: handle error
                    console.log("Error getting all signschedule items: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                    this.loaded = true;
                });


        } catch (error) {
            var myJSON = JSON.stringify(error);
            console.log("Error getting images to save to CRM: " + myJSON);
        }

    }

    handleSelected(event) {
        try {
            console.log(event.detail.name);
            console.log(event.detail.Key);
            console.log(this.selectedProductId);

            if (event.detail.name && this.selectedProductId != '' && event.detail.name != null) {
                this.loaded = false;

                var signScheduleItemId = event.detail.name;
                renderSign({
                        quoteDetailId: this.selectedProductId,
                        signScheduleItemId: signScheduleItemId,
                        cache: this.cacheDate
                    }).then(data => {
                        if (data) {
                            try {
                                if (data.toLowerCase().includes("error")) {
                                    this.errorMessage = "Error rendering schedule: " + data;
                                    this.showError = true;
                                } else {

                                    var myJSON = JSON.stringify(data);
                                    console.log(myJSON);
                                    this.imageData = 'data:application/png;base64,' + data;
                                    this.loaded = true;
                                    this.renderedSign = true;
                                }

                            } catch (error) {
                                console.log("Error rendering image: " + error);
                                this.loaded = true;
                                this.errorMessage = "Error rendering image1: " + error;
                                this.showError = true;
                            }

                        } else if (error) {
                            console.log(error);
                            this.loaded = true;
                            this.errorMessage = "Error rendering image2: " + error;
                            this.showError = true;
                        }
                        this.loaded = true;
                    })
                    .catch(error => {
                        // TODO: handle error
                        var myJSON = JSON.stringify(error);
                        console.log("Error  rendering image: " + myJSON);
                        this.loaded = true;
                        this.errorMessage = "Error rendering image3: " + myJSON;
                        this.showError = true;
                    });
            }


        } catch (error) {
            this.loaded = true;
            console.log(error);
        }

    }

    loadExistingAlternates() {
        console.log(this.recordId);
        getAlternates({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    console.log(data);

                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);

                    data.forEach(alt => {

                        var alternate = {
                            Id: alt.Id,
                            Name: alt.Name__c,
                            Selected: false,
                            Number: alt.Number__c
                        };

                        var altOption = {
                            value: alt.Id,
                            label: alt.Name__c
                        };

                        this.alternateOptionList = [...this.alternateOptionList, altOption];
                        //this.alternateOptionList.push(altOption);
                        this.alternateList.push(alternate);
                    });

                } else if (error) {
                    this.errorMessage = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(data);
                console.log("Error getting alternates: " + errorJSON);
                this.loaded = true;
            });
    }

    loadExistingProducts() {
        console.log(this.recordId);
        getProducts({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    console.log(data);

                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);

                    data.forEach(product => {
                        //Id, QuoteId, Alternate__c, Item_Number__c
                        var prod = {
                            Id: product.Id,
                            AlternateId: product.Alternate__c,
                            ItemNumber: product.Item_Number__c,
                            Quantity: product.Quantity,
                            SignScheduleId: product.SignScheduleId__c,
                            Selected: false
                        }
                        this.productList.push(prod);
                    });

                } else if (error) {
                    this.errorMessage = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting alternates: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
            });
    }

    handleAlternateComboBoxOnchange(event) {
        var AltId = event.target.value;
        this.alternateId = AltId;
        let products = this.productList.filter(function (product) {
            return product.AlternateId === AltId;
        });
        this.productOptionList = [];
        var myJSON = JSON.stringify(products);
        console.log(myJSON);

        if (products != null) {
            products.forEach(product => {

                var productOption = {
                    value: product.Id,
                    label: product.ItemNumber
                };
                this.productOptionList = [...this.productOptionList, productOption];
                // this.productOptionList = [...this.optionList, {label: this.newLabel+'', value: this.newValue+''}];
                //  this.productOptionList.push(productOption);
            });

        }

        var myProductJSON = JSON.stringify(this.productOptionList);
        console.log(myProductJSON);
    }

    handleProductComboBoxOnchange(event) {
        try {


            var quoteProductId = event.target.value;
            console.log(quoteProductId);
            let product = this.productList.filter(function (product) {
                return product.Id === quoteProductId;
            })[0];
            let SignScheduleId = product.SignScheduleId;
            console.log(SignScheduleId);
            this.selectedProductId = quoteProductId;
            getSignScheduleItems({
                    signScheduleId: SignScheduleId
                }).then(data => {
                    if (data) {

                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        this.currentSignSchedule = [];
                        data.forEach(ss => {

                            // Id, Line1__c, Index__c, Line10__c, Line11__c, Line12__c, Line13__c, 
                            // Line14__c, Line15__c, Line16__c, Line17__c, Line18__c, Line19__c, Line2__c, Line20__c, Line3__c, Line4__c, 
                            // Line5__c, Line6__c, Line7__c, Line8__c, Line9__c 

                            var signSchedule = {
                                Id: ss.Id,
                                Name: '',
                                Selected: false,
                                Line1: ss.Line1__c,
                                Line2: ss.Line2__c,
                                Line3: ss.Line3__c,
                                Line4: ss.Line4__c,
                                Line5: ss.Line5__c,
                                Line6: ss.Line6__c,
                                Line7: ss.Line7__c,
                                Line8: ss.Line8__c,
                                Line9: ss.Line9__c,
                                Line10: ss.Line10__c,
                                Line11: ss.Line11__c,
                                Line12: ss.Line12__c,
                                Line13: ss.Line13__c,
                                Line14: ss.Line14__c,
                                Line15: ss.Line15__c,
                                Line16: ss.Line16__c,
                                Line17: ss.Line17__c,
                                Line18: ss.Line18__c,
                                Line19: ss.Line19__c,
                                Line20: ss.Line20__c,
                                MadeChanges: false,
                                Index: ss.Index__c,
                                SignScheduleId__c: ss.SignScheduleId__c,
                                Line1Font: ss.Line1Font__c,
                                Line2Font: ss.Line2Font__c,
                                Line3Font: ss.Line3Font__c,
                                Line4Font: ss.Line4Font__c,
                                Line5Font: ss.Line5Font__c,
                                Line6Font: ss.Line6Font__c,
                                Line7Font: ss.Line7Font__c,
                                Line8Font: ss.Line8Font__c,
                                Line9Font: ss.Line9Font__c,
                                Line10Font: ss.Line10Font__c,
                                Line11Font: ss.Line11Font__c,
                                Line12Font: ss.Line12Font__c,
                                Line13Font: ss.Line13Font__c,
                                Line14Font: ss.Line14Font__c,
                                Line15Font: ss.Line15Font__c,
                                Line16Font: ss.Line16Font__c,
                                Line17Font: ss.Line17Font__c,
                                Line18Font: ss.Line18Font__c,
                                Line19Font: ss.Line19Font__c,
                                Line20Font: ss.Line20Font__c,
                                Text_Too_Tall__c: ss.Text_Too_Tall__c,
                                Text_Too_Wide__c: ss.Text_Too_Wide__c,
                                SavedToCRM__c: ss.SavedToCRM__c,
                                Missing_Configuration_Info__c: ss.Missing_Configuration_Info__c
                            };

                            if (signSchedule.Line1 != '' && signSchedule.Line1 != null)
                                signSchedule.Name += 'Line 1: ' + signSchedule.Line1 + ' ';
                            if (signSchedule.Line2 != '' && signSchedule.Line2 != null)
                                signSchedule.Name += 'Line 2: ' + signSchedule.Line2 + ' ';
                            if (signSchedule.Line3 != '' && signSchedule.Line3 != null)
                                signSchedule.Name += 'Line 3: ' + signSchedule.Line3 + ' ';
                            if (signSchedule.Line4 != '' && signSchedule.Line4 != null)
                                signSchedule.Name += 'Line 4: ' + signSchedule.Line4 + ' ';
                            if (signSchedule.Line5 != '' && signSchedule.Line5 != null)
                                signSchedule.Name += 'Line 5: ' + signSchedule.Line5 + ' ';
                            if (signSchedule.Line6 != '' && signSchedule.Line6 != null)
                                signSchedule.Name += 'Line 6: ' + signSchedule.Line6 + ' ';
                            if (signSchedule.Line7 != '' && signSchedule.Line7 != null)
                                signSchedule.Name += 'Line 7: ' + signSchedule.Line7 + ' ';
                            if (signSchedule.Line8 != '' && signSchedule.Line8 != null)
                                signSchedule.Name += 'Line 8: ' + signSchedule.Line8 + ' ';
                            if (signSchedule.Line9 != '' && signSchedule.Line9 != null)
                                signSchedule.Name += 'Line 9: ' + signSchedule.Line9 + ' ';
                            if (signSchedule.Line10 != '' && signSchedule.Line10 != null)
                                signSchedule.Name += 'Line 10: ' + signSchedule.Line10 + ' ';
                            if (signSchedule.Line11 != '' && signSchedule.Line11 != null)
                                signSchedule.Name += 'Line 11: ' + signSchedule.Line11 + ' ';
                            if (signSchedule.Line12 != '' && signSchedule.Line12 != null)
                                signSchedule.Name += 'Line 12: ' + signSchedule.Line12 + ' ';
                            if (signSchedule.Line13 != '' && signSchedule.Line13 != null)
                                signSchedule.Name += 'Line 13: ' + signSchedule.Line13 + ' ';
                            if (signSchedule.Line14 != '' && signSchedule.Line14 != null)
                                signSchedule.Name += 'Line 14: ' + signSchedule.Line14 + ' ';
                            if (signSchedule.Line15 != '' && signSchedule.Line15 != null)
                                signSchedule.Name += 'Line 15: ' + signSchedule.Line15 + ' ';
                            if (signSchedule.Line16 != '' && signSchedule.Line16 != null)
                                signSchedule.Name += 'Line 16: ' + signSchedule.Line16 + ' ';
                            if (signSchedule.Line17 != '' && signSchedule.Line17 != null)
                                signSchedule.Name += 'Line 17: ' + signSchedule.Line17 + ' ';
                            if (signSchedule.Line18 != '' && signSchedule.Line18 != null)
                                signSchedule.Name += 'Line 18: ' + signSchedule.Line18 + ' ';
                            if (signSchedule.Line19 != '' && signSchedule.Line19 != null)
                                signSchedule.Name += 'Line 19: ' + signSchedule.Line19 + ' ';
                            if (signSchedule.Line20 != '' && signSchedule.Line20 != null)
                                signSchedule.Name += 'Line 20: ' + signSchedule.Line20;

                           console.log("signschedule Name: " + signSchedule.Name);
                                
                            if(signSchedule.Name == ' ')
                            {
                                signSchedule.Name = '(Empty)';
                            }

                            console.log("signschedule Name: " + signSchedule.Name);


                            this.currentSignSchedule.push(signSchedule);
                        });


                    } else if (error) {
                        this.errorMessage = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    console.log("Error getting alternates: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                    this.loaded = true;
                });
            //TODO: get the signschedule.
        } catch (error) {
            console.log(error);
        }
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    handleCheckAllChecked(event) {
        this.AllSignSchedules.forEach(ss => {
            ss.Selected = event.target.checked;
            console.log(ss.Selected);
        });
    }

    handleOptionChecked(event) {
        var prodId = event.target.accessKey;
        let selectedProd = this.AllSignSchedules.filter(function (prod) {
            return prod.Id === prodId;
        })[0];

        selectedProd.Selected = event.target.checked;
        console.log(selectedProd.Selected);
    }

    handleUploadSigns(event) {
        this.loaded = false;
        try {
            var signsToSave = [];
            this.AllSignSchedules.filter(x => {
                return x.Selected == true
            }).forEach(ss => {
                var sign = {
                    QuoteId: this.recordId,
                    QuoteDetailId: ss.QuoteDetailId,
                    SignScheduleId: ss.SignScheduleId__c,
                    SignScheduleItemId: ss.Id,
                    QuoteNumber: ss.QuoteNumber
                };
                signsToSave.push(sign);
            });
            var jsonSigns = JSON.stringify(signsToSave);
            console.log(jsonSigns);
            saveToCRM({
                jsonSigns: jsonSigns
            }).then(data => {
                console.log('Save TO CRM done');
                if (data == 'Success!') {
                    console.log(data);
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!',
                        message: 'Successfully saved images to CRM.',
                        variant: 'success'
                    }));
                } else {
                    this.errorMessage = "Error saving signs to CRM: " + data;
                    this.showError = true;
                    console.log(data);
                }
                this.saveSigns = false;
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error saving signs to CRM: " + errorJSON);
                this.errorMessage = "Error saving signs to CRM: " + errorJSON;
                this.showError = true;
                this.loaded = true;
                this.saveSigns = false;
            });
        } catch (error) {
            var errorJSON = JSON.stringify(error);
            this.errorMessage = "Error saving signs to CRM: " + errorJSON;
            this.showError = true;
            this.loaded = true;
        }
    }

    handleSaveSignsBack(event) {
        this.saveSigns = false;
        this.emailSigns = false;
    }

    handleEmail(event) {
        this.emailSigns = true;
        this.saveSigns = true;
        this.loaded = false;
        this.contactList = [];
        getContacts({
                quoteId: this.recordId
            }).then(data => {
                if (data) {
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);

                    data.forEach(contact => {

                        var oContact = {
                            label: contact.FirstName + " " + contact.LastName,
                            value: contact.Id
                        };

                        this.contactList = [...this.contactList, oContact];
                    });

                } else if (error) {
                    this.errorMessage = error;
                    this.showError = true;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error getting contacts: " + errorJSON);
                this.loaded = true;
            });

        this.handleSaveImage(event);

    }

    handleContactsChange(event) {
        this.contactsSelected = event.detail.value;
        console.log(this.contactsSelected);
    }

    handleAlternatesChange(event) {
        this.alternatesSelected = event.detail.value;
        console.log(this.alternatesSelected);
    }

    handleEmailSigns(event) {

        //string quoteId, String userId, String jsonContactList, String jsonAlternateList, String jsonSigns
        this.loaded = false;
        var signsToSave = [];

        this.AllSignSchedules.filter(x => {
            return x.Selected == true
        }).forEach(ss => {
            var sign = {
                QuoteId: this.recordId,
                QuoteDetailId: ss.QuoteDetailId,
                SignScheduleId: ss.SignScheduleId__c,
                SignScheduleItemId: ss.Id,
                QuoteNumber: ss.QuoteNumber
            };
            signsToSave.push(sign);
        });
        var jsonSigns = JSON.stringify(signsToSave);
        console.log(jsonSigns);


        //@track contactsSelected = [];
        //@track alternatesSelected = [];

        var jsonContactList = JSON.stringify(this.contactsSelected);
        console.log(jsonContactList);
        var jsonAlternateList = JSON.stringify(this.alternatesSelected);
        console.log(jsonAlternateList);

        emailSign({
                quoteId: this.recordId,
                userId: this.userId,
                jsonContactList: jsonContactList,
                jsonAlternateList: jsonAlternateList,
                jsonSigns: jsonSigns
            }).then(data => {
                if (data) {
                    console.log(data);
                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                } else if (error) {
                    this.errorMessage = error;
                    this.showError = true;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error emailing signs from salesforce: " + errorJSON);
                this.loaded = true;
            });
        this.saveSigns = false;
        this.emailSigns = false;
    }

    handleAttachChecked(event) {
        this.attachSignSchedule = event.target.checked;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}