import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getAlternates from '@salesforce/apex/SignScheduleManagementHelper.getAlternates';
import getProducts from '@salesforce/apex/SignScheduleManagementHelper.getProducts';
import getProductsByAltId from '@salesforce/apex/SignScheduleManagementHelper.getProductsByAltId';
import getSignScheduleItems from '@salesforce/apex/SignScheduleManagementHelper.getSignScheduleItems';
import uploadSchedule from '@salesforce/apex/SignScheduleManagementHelper.UploadSchedule';
import downloadSchedule from '@salesforce/apex/SignScheduleManagementHelper.DownloadSchedule';
import saveScheduleItems from '@salesforce/apex/SignScheduleManagementHelper.saveScheduleItems';
import renderSign from '@salesforce/apex/SignScheduleManagementHelper.renderSign';
import validateSign from '@salesforce/apex/SignScheduleManagementHelper.validateSign';
import createSignSchedules from '@salesforce/apex/SignScheduleManagementHelper.createSignSchedules';
import downloadSignPro from '@salesforce/apex/SignScheduleManagementHelper.downloadSignPro';
import userId from '@salesforce/user/Id';

export default class SignScheduleManagement extends LightningElement {
    @api recordId;

    @track loaded = true;
    @track showError = false;
    @track errorMessage = '';

    @track startScreen = true;
    @track editSignSchedule = false;
    @track exportSignSchedule = false;
    @track importSignSchedule = false;
    @track exportSignPro = false;

    @track uploaded = false;
    @track fileUploaded = false;
    @track theFileId;

    @track alternateList = [];
    @track alternateOptionList = [];
    @track productList = [];
    @track productOptionList = [];

    @track alternateId = '';
    @track selectedProductId = '';
    @track currentSignSchedule = [];
    @track removedSignScheduleItems = [];
    @track downloadLink = 'data:application/pdf;base64,';

    @track fileDownloaded = false;
    @track Index = 0;

    @track fontObject = {};
    @track fontObjectContainer = [];
    @track assignFonts = false;
    @track assignOptions = false;
    @track assignedObject = {};
    @track optionsList = [];
    @track selectedOptionValue = '{BRAILLE}';
    @track renderImage = false;
    @track imageData = '';
    @track cacheDate = Date().toLocaleString();
    @track includesNotes = false;
    @track showSignProComplete = false;

    saveConfig(event) {
        try {
            this.loaded = false;
            var signScheduleItems = [];
            // Id, Line1__c, Index__c, Line10__c, Line11__c, Line12__c, Line13__c, 
            // Line14__c, Line15__c, Line16__c, Line17__c, Line18__c, Line19__c, Line2__c, Line20__c, Line3__c, Line4__c, 
            // Line5__c, Line6__c, Line7__c, Line8__c, Line9__c 
            this.removedSignScheduleItems.forEach(x => {
                var signSchedule = {
                    Id: x.Id,
                    Line20__c: 'delete'
                };
                signScheduleItems.push(signSchedule);
            });
            var index = 1;
            this.currentSignSchedule.forEach(x => {
                var signSchedule = {
                    Id: x.Id,
                    Line1__c: x.Line1,
                    Index__c: index,
                    Line10__c: x.Line10,
                    Line11__c: x.Line11,
                    Line12__c: x.Line12,
                    Line13__c: x.Line13,
                    Line14__c: x.Line14,
                    Line15__c: x.Line15,
                    Line16__c: x.Line16,
                    Line17__c: x.Line17,
                    Line18__c: x.Line18,
                    Line19__c: x.Line19,
                    Line2__c: x.Line2,
                    Line20__c: x.Line20,
                    Line3__c: x.Line3,
                    Line4__c: x.Line4,
                    Line5__c: x.Line5,
                    Line6__c: x.Line6,
                    Line7__c: x.Line7,
                    Line8__c: x.Line8,
                    Line9__c: x.Line9,
                    SignScheduleId__c: x.SignScheduleId__c,
                    Line1Font__c: x.Line1Font,
                    Line2Font__c: x.Line2Font,
                    Line3Font: x.Line3Font,
                    Line4Font__c: x.Line4Font,
                    Line5Font__c: x.Line5Font,
                    Line6Font__c: x.Line6Font,
                    Line7Font__c: x.Line7Font,
                    Line8Font__c: x.Line8Font,
                    Line9Font__c: x.Line9Font,
                    Line10Font__c: x.Line10Font,
                    Line11Font__c: x.Line11Font,
                    Line12Font__c: x.Line12Font,
                    Line13Font__c: x.Line13Font,
                    Line14Font__c: x.Line14Font,
                    Line15Font__c: x.Line15Font,
                    Line16Font__c: x.Line16Font,
                    Line17Font__c: x.Line17Font,
                    Line18Font__c: x.Line18Font,
                    Line19Font__c: x.Line19Font,
                    Line20Font__c: x.Line20Font

                }                
                signSchedule.Formatted_Sign_Schedule__c = '';
            if (x.Line1 != '' && x.Line1 != null)
                signSchedule.Formatted_Sign_Schedule__c += x.Line1;
            if (x.Line2 != '' && x.Line2 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line2;
            if (x.Line3 != '' && x.Line3 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line3;
            if (x.Line4 != '' && x.Line4 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line4;
            if (x.Line5 != '' && x.Line5 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line5;
            if (x.Line6 != '' && x.Line6 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line6;
            if (x.Line7 != '' && x.Line7 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line7;
            if (x.Line8 != '' && x.Line8 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line8;
            if (x.Line9 != '' && x.Line9 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line9;
            if (x.Line10 != '' && x.Line10 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line10;
            if (x.Line11 != '' && x.Line11 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line11;
            if (x.Line12 != '' && x.Line12 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line12;
            if (x.Line13 != '' && x.Line13 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line13;
            if (x.Line14 != '' && x.Line14 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line14;
            if (x.Line15 != '' && x.Line15 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line15;
            if (x.Line16 != '' && x.Line16 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line16;
            if (x.Line17 != '' && x.Line17 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line17;
            if (x.Line18 != '' && x.Line18 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line18;
            if (x.Line19 != '' && x.Line19 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line19;
            if (x.Line20 != '' && x.Line20 != null)
                signSchedule.Formatted_Sign_Schedule__c += '<br />' + x.Line20;

                console.log(signSchedule.Formatted_Sign_Schedule__c);
                
                signScheduleItems.push(signSchedule);
                index = index + 1
            });

            saveScheduleItems({
                    SSItems: signScheduleItems
                }).then(data => {
                    if (data) {
                        try {
                            var myJSON = JSON.stringify(data);
                            console.log(myJSON);
                            this.loaded = true;
                            if (data.toLowerCase().includes("error")) {
                                this.errorMessage = "Error saving schedule: " + data;
                                this.showError = true;
                            } else {
                                console.log("Success!");
                            }
                        } catch (error) {

                            var myJSON = JSON.stringify(error);
                            console.log(myJSON);
                            console.log("Error saving schedule: " + myJSON);
                            this.loaded = true;
                            this.errorMessage = "Error saving schedule: " + myJSON;
                            this.showError = true;
                        }

                    } else if (error) {
                        this.errorMessage = error;
                        console.log(error);
                        this.loaded = true;
                        this.errorMessage = "Error saving schedule: " + error;
                        this.showError = true;
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error saving schedule: " + errorJson);
                    this.loaded = true;
                    this.errorMessage = "Error saving schedule: " + errorJson;
                    this.showError = true;
                });

        } catch (error) {
            console.log(error);
        }
        this.cacheDate = Date().toLocaleString();
        //update existing signschedule items lines/fonts

        //create new signschedule items lines/fonts

        //delete removed signschedule items
    }

    handleImportSchedule(event) {
        this.startScreen = false;
        this.editSignSchedule = false;
        this.exportSignSchedule = false;
        this.exportSignPro = false;
        this.importSignSchedule = true;
    }

    handleExportSchedule(event) {
        this.startScreen = false;
        this.editSignSchedule = false;
        this.exportSignSchedule = true;
        this.importSignSchedule = false;
        this.exportSignPro = false;
    }

    handleExportSignPro(event)
    {
        this.startScreen = false;
        this.editSignSchedule = false;
        this.exportSignSchedule = false;
        this.importSignSchedule = false;
        this.exportSignPro = true;
    }

    handleEditSignSchedule(event) {
        this.startScreen = false;
        this.editSignSchedule = true;
        this.exportSignSchedule = false;
        this.importSignSchedule = false;
        this.exportSignPro = false;
    }

    handleCancel(event) {
        if (this.startScreen == true) {
            this.closeQuickAction();
        } else {
            this.startScreen = true;
            this.editSignSchedule = false;
            this.exportSignSchedule = false;
            this.importSignSchedule = false;
            this.exportSignPro = false;
        }
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " + uploadedFiles.length);
        console.log(uploadedFiles[0].documentId + " " + uploadedFiles[0].name);
        this.theFileId = uploadedFiles[0].documentId;
        this.FileName = uploadedFiles[0].name;
        this.fileUploaded = true;
    }

    connectedCallback() {
        // initialize component
        var oBraille = {
            label: 'Braille',
            value: '{BRAILLE}'
        };
        var oAccentLine = {
            label: 'Accent Line',
            value: '{ACCENT LINE}'
        };
        var oLogo = {
            label: 'Logo',
            value: '{LOGO}'
        };
        var oIllustration = {
            label: 'Text From Illustration',
            value: '{TEXT FROM ILLUSTRATION}'
        };
        var oSlider = {
            label: 'Slider',
            value: '{SLIDER}'
        };
        var oWindow = {
            label: 'Window',
            value: '{WINDOW}'
        };

        this.optionsList = [...this.optionsList, oBraille];
        this.optionsList = [...this.optionsList, oAccentLine];
        this.optionsList = [...this.optionsList, oLogo];
        this.optionsList = [...this.optionsList, oIllustration];
        this.optionsList = [...this.optionsList, oSlider];
        this.optionsList = [...this.optionsList, oWindow];

        this.BuildSignSchedules();
       
    }

    BuildSignSchedules()
    {
        createSignSchedules({
            quoteId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    if (data != 'Success!')
                    {
                        console.log("Error creating new schedules: " + data);
                        this.loaded = true;
                        this.errorMessage = "Error creating new schedules: " + data;
                        this.showError = true;
                    }
                    else{
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);     
    
                        this.loadExistingAlternates();
                        this.loadExistingProducts();
                    }
                } catch (error) {
                    var myJSON = JSON.stringify(error);
                    console.log(myJSON);                  
                }
            } else if (error) {
                this.errorMessage = error;
                console.log(error);
            }            
        })
        .catch(error => {
            // TODO: handle error
            var errorJson = JSON.stringify(error);
            console.log("Error creating new schedules: " + errorJson);
            this.loaded = true;
            this.errorMessage = "Error creating new schedules: " + errorJson;
            this.showError = true;
        });

    }

    loadExistingAlternates() {
        console.log(this.recordId);
        this.alternateList = [];
        this.alternateOptionList = [];

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
        this.productList = [];
        this.productOptionList = [];
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
                            Selected: false,
                            Description: product.Description
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
                var errorJSON = JSON.stringify(error);
                console.log("Error getting products: " + errorJSON);
                this.loaded = true;
            });
    }

    handleAlternateComboBoxOnchange(event) {
        var AltId = event.target.value;
        this.alternateId = AltId;
        this.productOptionList = [];
        let products = this.productList.filter(function (product) {
            return product.AlternateId === AltId;
        });

        var myJSON = JSON.stringify(products);
        console.log(myJSON);

        if (products != null) {
            products.forEach(product => {

                var productOption = {
                    value: product.Id,
                    label: product.ItemNumber + '-' + product.Description
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
                                Line1Class: '',
                                Line2Class: '',
                                Line3Class: '',
                                Line4Class: '',
                                Line5Class: '',
                                Line6Class: '',
                                Line7Class: '',
                                Line8Class: '',
                                Line9Class: '',
                                Line10Class: '',
                                Line11Class: '',
                                Line12Class: '',
                                Line13Class: '',
                                Line14Class: '',
                                Line15Class: '',
                                Line16Class: '',
                                Line17Class: '',
                                Line18Class: '',
                                Line19Class: '',
                                Line20Class: ''                          
                            };

                            this.currentSignSchedule.push(signSchedule);
                        });

                        this.fontObject = {
                            Line1Font: data[0].Line1Font__c,
                            Line2Font: data[0].Line2Font__c,
                            Line3Font: data[0].Line3Font__c,
                            Line4Font: data[0].Line4Font__c,
                            Line5Font: data[0].Line5Font__c,
                            Line6Font: data[0].Line6Font__c,
                            Line7Font: data[0].Line7Font__c,
                            Line8Font: data[0].Line8Font__c,
                            Line9Font: data[0].Line9Font__c,
                            Line10Font: data[0].Line10Font__c,
                            Line11Font: data[0].Line11Font__c,
                            Line12Font: data[0].Line12Font__c,
                            Line13Font: data[0].Line13Font__c,
                            Line14Font: data[0].Line14Font__c,
                            Line15Font: data[0].Line15Font__c,
                            Line16Font: data[0].Line16Font__c,
                            Line17Font: data[0].Line17Font__c,
                            Line18Font: data[0].Line18Font__c,
                            Line19Font: data[0].Line19Font__c,
                            Line20Font: data[0].Line20Font__c
                        }
                        this.fontObjectContainer.push(this.fontObject);



                    } else if (error) {
                        this.errorMessage = error;
                        console.log(error);
                    }
                    this.loaded = true;
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJSON = JSON.stringify(error);
                    console.log("Error getting products from dropdown: " + errorJSON);
                    this.loaded = true;
                });
            //TODO: get the signschedule.
        } catch (error) {
            console.log(error);
        }
    }

    handleGridInputChange(event) {
        try {
            if (this.currentSignSchedule.length > 0) {
                let value = event.target.value;

                let selectedItem = this.currentSignSchedule.filter(function (ss) {
                    return ss.Id === event.target.accessKey;
                })[0];

                console.log('Start Validate Sign');
                event.target.style.width = (value.length + 4) + "ch";
                console.log(event.target.name);
                var prop = event.target.name + "Class";
                console.log(value);
                console.log(this.selectedProductId);
                if (value.length > 0) {

                    //string quoteDetailId, string content
                    validateSign({
                            quoteDetailId: this.selectedProductId,
                            content: value
                        }).then(data => {
                            if (data) {
                                try {
                                    //console.log(data);
                                    var obj = JSON.parse(data);
                                    console.log("Valid: " +  obj.Valid);
                                    console.log("LineWidth: "  + obj.LineWidth)
                                    console.log("WorkableAreaWidth: "  + obj.WorkableAreaWidth)                                     
                                    
                                    if(obj.Valid == false)
                                    {                                        
                                        selectedItem[prop] = "red";                                            
                                    }
                                    else if(obj.LineWidth >= obj.WorkableAreaWidth - 25)
                                    {
                                        selectedItem[prop] = "yellow";                                        
                                    }
                                    else 
                                    {
                                        selectedItem[prop] = "green";                                        
                                    }
                                    console.log(prop +  ": " +  selectedItem[prop]);
                                } catch (error) {
                                    var errorJSON = JSON.stringify(error);
                                    console.log("Error validating sign1: " + errorJSON);  
                                }

                            } else if (error) {
                                var errorJSON = JSON.stringify(error);
                                console.log(errorJSON);
                            }
                        })
                        .catch(error => {
                            var errorJSON = JSON.stringify(error);
                            console.log("Error validating sign2: " + errorJSON);
                        });


                    //validateSign

                    //if this information is missing set the color to be:255, 192, 192, 192
                    // if (SelectedSignSchedule.AreaX != string.Empty && 
                    //     SelectedSignSchedule.AreaY != string.Empty && 
                    //     SelectedSignSchedule.FontFamily != string.Empty && 
                    //     SelectedSignSchedule.FontSize != string.Empty && 
                    //     !tb.Text.Contains("{"))

                    //if the result of the validation is true
                    // if (e.Result.Status)
                    // {
                    //     if (tb.Text.Length > 0)
                    //     {
                    //         if (!e.Result.Valid)
                    //         {
                    //             tb.Background = new SolidColorBrush(Color.FromArgb(255, 255, 132, 132));
                    //         }
                    //         else if (e.Result.LineWidth >= e.Result.WorkableAreaWidth - 25)
                    //         {
                    //             tb.Background = new SolidColorBrush(Color.FromArgb(255, 255, 255, 143));
                    //         }
                    //         else
                    //         {
                    //             tb.Background = new SolidColorBrush(Color.FromArgb(255, 116, 255, 116));
                    //         }
                    //     }
                    // }
                    // else if (e.Result.MissingTemplate || e.Result.MissingPictoGram)
                    //     tb.Background = new SolidColorBrush(Color.FromArgb(255, 192, 192, 192)); //--Missing the template
                    // else if (e.Result.MissingTemplate == false)
                    //     tb.Background = new SolidColorBrush(Color.FromArgb(255, 192, 192, 192)); //--Missing the template

                }

                console.log("selected value changing: " + value + " " + selectedItem.Id + " key: " + event.target.accessKey);
                selectedItem[event.target.name] = value;
                selectedItem.MadeChanges = true;

            }
        } catch (error) {
            var myJSON = JSON.stringify(error);
            console.log("error handling text change: " + myJSON);
        }
    }

    removeRow(event) {
        let selectedItem = this.currentSignSchedule.filter(function (ss) {
            return ss.Id === event.target.accessKey;
        })[0];

        this.removedSignScheduleItems.push(selectedItem);

        this.currentSignSchedule = this.currentSignSchedule.filter(function (ss) {
            return ss.Id !== event.target.accessKey;
        });

    }

    handleViewImage(event) {
        this.loaded = false;
        this.renderImage = false;
        var signScheduleItemId = event.target.accessKey;
        this.imageData = "";
        var signScheduleItems = [];

        try {         
            var index = 1;
            this.currentSignSchedule.forEach(x => {
                var signSchedule = {
                    Id: x.Id,
                    Line1__c: x.Line1,
                    Index__c: index,
                    Line10__c: x.Line10,
                    Line11__c: x.Line11,
                    Line12__c: x.Line12,
                    Line13__c: x.Line13,
                    Line14__c: x.Line14,
                    Line15__c: x.Line15,
                    Line16__c: x.Line16,
                    Line17__c: x.Line17,
                    Line18__c: x.Line18,
                    Line19__c: x.Line19,
                    Line2__c: x.Line2,
                    Line20__c: x.Line20,
                    Line3__c: x.Line3,
                    Line4__c: x.Line4,
                    Line5__c: x.Line5,
                    Line6__c: x.Line6,
                    Line7__c: x.Line7,
                    Line8__c: x.Line8,
                    Line9__c: x.Line9,
                    SignScheduleId__c: x.SignScheduleId__c,
                    Line1Font__c: x.Line1Font,
                    Line2Font__c: x.Line2Font,
                    Line3Font: x.Line3Font,
                    Line4Font__c: x.Line4Font,
                    Line5Font__c: x.Line5Font,
                    Line6Font__c: x.Line6Font,
                    Line7Font__c: x.Line7Font,
                    Line8Font__c: x.Line8Font,
                    Line9Font__c: x.Line9Font,
                    Line10Font__c: x.Line10Font,
                    Line11Font__c: x.Line11Font,
                    Line12Font__c: x.Line12Font,
                    Line13Font__c: x.Line13Font,
                    Line14Font__c: x.Line14Font,
                    Line15Font__c: x.Line15Font,
                    Line16Font__c: x.Line16Font,
                    Line17Font__c: x.Line17Font,
                    Line18Font__c: x.Line18Font,
                    Line19Font__c: x.Line19Font,
                    Line20Font__c: x.Line20Font

                }
                if(x.Id == signScheduleItemId)
                signScheduleItems.push(signSchedule);
                index = index + 1
            });

            saveScheduleItems({
                    SSItems: signScheduleItems
                }).then(data => {
                    if (data) {
                        try {
                            var myJSON = JSON.stringify(data);
                            console.log(myJSON);
                            if (data.toLowerCase().includes("error")) {
                                this.errorMessage = "Error saving schedule: " + data;
                                this.showError = true;
                            } else {
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
                                                this.renderImage = true;
                                            }
                    
                                        } catch (error) {
                                            console.log("Error rendering image: " + error);
                                            this.loaded = true;
                                            this.errorMessage = "Error rendering image1: " + error;
                                            this.showError = true;
                                        }
                    
                                    } else if (error) {
                                        this.errorMessage = error;
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

                            var myJSON = JSON.stringify(error);
                            console.log(myJSON);
                            console.log("Error saving schedule: " + myJSON);
                            this.loaded = true;
                            this.errorMessage = "Error saving schedule: " + myJSON;
                            this.showError = true;
                        }

                    } else if (error) {
                        this.errorMessage = error;
                        console.log(error);
                        this.loaded = true;
                        this.errorMessage = "Error saving schedule: " + error;
                        this.showError = true;
                    }
                })
                .catch(error => {
                    // TODO: handle error
                    var errorJson = JSON.stringify(error);
                    console.log("Error saving schedule: " + errorJson);
                    this.loaded = true;
                    this.errorMessage = "Error saving schedule: " + errorJson;
                    this.showError = true;
                });

        } catch (error) {
            console.log(error);
        }        
    }

    exportSchedule(event) {
        this.loaded = false;
        let selectedAlts = this.alternateList.filter(function (alt) {
            return alt.Selected === true;
        });

        var altList = [];
        selectedAlts.forEach(a => {
            altList.push(a.Id);
        });
        console.log("altlist length: " + altList.length);
        if(altList.length == 0)
        {
            this.errorMessage = "Please select an alternate.";
            this.showError = true;
            this.loaded = true;
            return;
        }

        // String recordId, List<Integer> alternates
        downloadSchedule({
                recordId: this.recordId,
                alternates: altList
            }).then(data => {
                if (data) {
                    try {
                        if (data.toLowerCase().includes("error")) {
                            this.errorMessage = "Error downloading schedule: " + data;
                            this.showError = true;
                        } else {

                            var myJSON = JSON.stringify(data);
                            console.log(myJSON);
                            this.downloadLink = 'data:application/pdf;base64,' + data;
                            console.log(this.downloadLink);
                            this.fileDownloaded = true;
                            this.loaded = true;
                        }

                    } catch (error) {
                        console.log("Error downloading schedule: " + error);
                        this.loaded = true;
                        this.errorMessage = "Error downloading schedule: " + error;
                        this.showError = true;
                    }

                } else if (error) {
                    this.errorMessage = error;
                    console.log(error);
                    this.loaded = true;
                    this.errorMessage = "Error downloading schedule: " + error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error downloading schedule: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
                this.errorMessage = "Error downloading schedule: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
                this.showError = true;
            });
    }

    saveSignPro(event) {
        this.loaded = false;
        let selectedAlts = this.alternateList.filter(function (alt) {
            return alt.Selected === true;
        });

        var altList = [];
        selectedAlts.forEach(a => {
            altList.push(a.Number);
        });

        if(altList.length == 0)
        {
            this.errorMessage = "Please select an alternate.";
            this.showError = true;
            this.loaded = true;
            return;
        }

        // String recordId, List<Integer> alternates
        downloadSignPro({
                recordId: this.recordId,
                alternates: altList,
                includesNotes: this.includesNotes,
                userId: userId
            }).then(data => {
                if (data) {
                    try {
                        if (data.toLowerCase().includes("error")) {
                            this.errorMessage = "Error downloading sign pro0: " + data;
                            this.showError = true;
                        } else {

                            var myJSON = JSON.stringify(data);
                            console.log(myJSON);
                            // this.downloadLink = 'data:application/pdf;base64,' + data;
                            // console.log(this.downloadLink);
                            //this.fileDownloaded = true;
                            this.errorMessage = data;
                            this.showSignProComplete = true;
                            this.loaded = true;
                        }

                    } catch (error) {
                        console.log("Error downloading sign pro1: " + error);
                        this.loaded = true;
                        this.errorMessage = "Error downloading sign pro2: " + error;
                        this.showError = true;
                    }

                } else if (error) {
                    this.errorMessage = error;
                    console.log(error);
                    this.loaded = true;
                    this.errorMessage = "Error downloading sign pro3: " + error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJSON = JSON.stringify(error);
                console.log("Error downloading sign pro4: " + errorJSON);
                this.loaded = true;
                this.errorMessage = "Error downloading sign pro5: " +  errorJSON;
                this.showError = true;
            });
    }

    importSchedule(event) {
        this.loaded = false;
        uploadSchedule({
                recordId: this.recordId,
                fileId: this.theFileId,
                userId: userId
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        if (data.toLowerCase().includes("error")) {
                            this.errorMessage = "Error downloading schedule: " + data;
                            this.showError = true;
                        } else {
                            this.startScreen = true;
                            this.editSignSchedule = false;
                            this.exportSignSchedule = false;
                            this.importSignSchedule = false;
                            
                            this.errorMessage = data;
                            this.showSignProComplete = true;
                            this.loaded = true;

                            // this.loadExistingAlternates();
                            // this.loadExistingProducts();
                        }

                    } catch (error) {

                        var myJSON = JSON.stringify(error);
                        console.log(myJSON);

                        console.log("Error uploading schedule: " + myJSON);
                        this.loaded = true;
                        this.errorMessage = "Error uploading schedule: " + myJSON;
                        this.showError = true;
                    }

                } else if (error) {
                    this.errorMessage = error;
                    console.log(error);
                    this.loaded = true;
                    this.errorMessage = "Error uploading schedule: " + error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error uploading schedule: " + errorJson);
                this.loaded = true;
                this.errorMessage = "Error uploading schedule: " + errorJson;
                this.showError = true;
            });
    }

    handleExportAltBoxOnChange(event) {
        var altId = event.target.accessKey;
        let selectedAlt = this.alternateList.filter(function (alt) {
            return alt.Id === altId;
        })[0];

        selectedAlt.Selected = event.target.checked;
    }

    handleIncludeNotesChange(event)
    {
        this.includesNotes = event.target.checked;
    }

    handleCheckAllChecked(event) {
        this.currentSignSchedule.forEach(ss => {
            ss.Selected = event.target.checked;
            console.log(ss.Selected);
        });
    }

    handleOptionChecked(event) {
        var prodId = event.target.accessKey;
        let selectedProd = this.currentSignSchedule.filter(function (prod) {
            return prod.Id === prodId;
        })[0];

        selectedProd.Selected = event.target.checked;
        console.log(selectedProd.Selected);
    }

    handleBlankLines(event) {
        try {


            console.log(this.selectedProductId);
            let Id = this.selectedProductId;
            let product = this.productList.filter(function (product) {
                return product.Id === Id;
            })[0];

            console.log(product.Quantity);
            console.log(this.currentSignSchedule.length);

            var count = product.Quantity - this.currentSignSchedule.length;

            if (count > 0) {
                for (let i = 0; i < count; i++) {
                    var signSchedule = {
                        Id: this.Index.toString(),
                        Selected: false,
                        Line1: '',
                        Line2: '',
                        Line3: '',
                        Line4: '',
                        Line5: '',
                        Line6: '',
                        Line7: '',
                        Line8: '',
                        Line9: '',
                        Line10: '',
                        Line11: '',
                        Line12: '',
                        Line13: '',
                        Line14: '',
                        Line15: '',
                        Line16: '',
                        Line17: '',
                        Line18: '',
                        Line19: '',
                        Line20: '',
                        MadeChanges: true,
                        SignScheduleId__c: product.SignScheduleId,
                        Line1Class: '',
                        Line2Class: '',
                        Line3Class: '',
                        Line4Class: '',
                        Line5Class: '',
                        Line6Class: '',
                        Line7Class: '',
                        Line8Class: '',
                        Line9Class: '',
                        Line10Class: '',
                        Line11Class: '',
                        Line12Class: '',
                        Line13Class: '',
                        Line14Class: '',
                        Line15Class: '',
                        Line16Class: '',
                        Line17Class: '',
                        Line18Class: '',
                        Line19Class: '',
                        Line20Class: ''   
                    };
                    this.Index = this.Index + 1;
                    this.currentSignSchedule.push(signSchedule);
                }
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleSpellCheck(event) {
        // var input = document.querySelector('input');
        // input.addSpellcheckRange( 4
        //                         , 9
        //                         , [ 'Chrome', 'Firefox', 'Opera', 'Internet Explorer' ]
        //                         );
    }

    handleDeleteSelected(event) {

        this.currentSignSchedule.filter(ss => {
            return ss.Selected === true;
        }).forEach(x => {
            this.removedSignScheduleItems.push(x);
        });
        this.currentSignSchedule = this.currentSignSchedule.filter(ss => {
            return ss.Selected === false;
        });
    }

    validateId(id) {

        if (id.length == 15 || id.length == 18) {
            this.ValidId = true;
        } else
            this.ValidId = false;
    }

    handleAssignOptions(event) {
        this.assignOptions = true;
    }

    handleAssignOptionChecked(event) {
        this.assignedObject[event.target.accessKey] = event.target.checked;
    }

    handleAssignFinish(event) {
        try {
            var myJSON = JSON.stringify(this.assignedObject);
            console.log(myJSON);
            Object.keys(this.assignedObject).forEach(key => {
                console.log(key, this.assignedObject[key]);
                this.currentSignSchedule.forEach(ssi => {
                    var newLineText = '';
                    if (ssi[key] != null)
                        newLineText = ssi[key].replace(/{.*}/, '');
                    newLineText = this.selectedOptionValue + newLineText;
                    ssi[key] = newLineText;
                });
            });
            this.assignedObject = {};
            this.assignOptions = false;
        } catch (error) {
            console.log(error);
        }
    }

    handleAssignCancel(event) {
        this.assignOptions = false;
        this.assignFonts = false;
        this.renderImage = false;
    }

    handleOptionComboBoxOnchange(event) {
        this.selectedOptionValue = event.target.value;
    }

    handleAssignFontChecked(event) {
        this.fontObject[event.target.accessKey + "Font"] = event.target.checked;
    }

    handleAssignFonts(event) {
        this.assignFonts = true;
        console.log(this.assignFonts);
    }

    handleAssignFontsFinish(event) {
        //Line1Font
        var myJSON = JSON.stringify(this.fontObject);
        console.log(myJSON);
        Object.keys(this.fontObject).forEach(key => {
            console.log(key, this.fontObject[key]);
            this.currentSignSchedule.forEach(ssi => {
                console.log(this.fontObject[key]);
                if (this.fontObject[key] == true)
                    ssi[key] = 2
                else
                    ssi[key] = 1;
                console.log(ssi[key]);
            });
        });
        this.assignFonts = false;
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

    handleGridInputOnFocus(event) {
        try {

            //console.log("width: " + event.target.style.width);
            // if(event.target.style.width + 5 > 32)
            // {
                event.target.style.width = (event.target.value.length + 8) + "ch";
            //}
        } catch (error) {

        }
    }





}