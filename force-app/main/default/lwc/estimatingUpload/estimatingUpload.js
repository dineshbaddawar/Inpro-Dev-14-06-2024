import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getAlternates from '@salesforce/apex/EstimatingUploadHelper.getAlternates';
import importEstimate from '@salesforce/apex/EstimatingUploadHelper.importEstimate';
import writeConfiguration from '@salesforce/apex/EstimatingUploadHelper.writeConfiguration';
import getDivision from '@salesforce/apex/EstimatingUploadHelper.getDivision';
import createAsyncProcess from '@salesforce/apex/QuickConfigHelper.createAsyncProcess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import userId from '@salesforce/user/Id';
export default class EstimatingUpload extends LightningElement {

    @api recordId;
    loaded = false;
    @track alternateList = [];
    @track productList = [];
    uploaded = false;
    fileUploaded = false;
    @track theFileId;
    @track obsoleteProducts = false;
    @track mismatchedColorProducts = false;
    @track colorMissingProducts = false;
    deduct = 0;
    FileName = '';

    alternateId = '';
    clearAlternate = false;
    alternateName = '';
    existingAlternates = false;
    createMaintenanceStock = false;
    maintenancePercent = 0;
    showError = false;
    errorMessage = '';
    missingInExperlogix = false;    
    newAlternate = false;

    isDoorAndWall = true;
    division = 'DW';

    get acceptedFormats() {
        return ['.xls', '.xlsx', '.csv'];
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
        //TODO: Check division
        this.loadDivision();
        this.loadAlternates();
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
                                AlternateId: alt.Id
                            };
                            this.existingAlternates = true;
                            this.alternateList.push(alternate);
                        });

                    } catch (error) {
                        console.log("Error Loading Alternates: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting alternates: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    loadDivision() {
        getDivision({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    try {

                     console.log(data);
                        if(data != null && data != 'IPC')
                        {
                            this.division = 'JM';
                            this.isDoorAndWall = false;
                        }

                    } catch (error) {
                        console.log("Error Loading Division: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error getting division: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    saveEstimate() {
        this.loaded = false;
        this.uploaded = true;
        var tempProductList = [];
        console.log(this.theFileId);
        console.log(this.deduct);
        console.log(this.maintenancePercent);
        importEstimate({
                recordId: this.recordId,
                fileId: this.theFileId,
                deduct: this.deduct,
                division: this.division
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        var ID = 0;
                        data.forEach(prod => {
                            var product = {
                                ID: ID,
                                ItemNumber: prod.ItemNumber,
                                ValidExperlogix: prod.ValidExperlogix,
                                Obsolete: prod.Obsolete,
                                Quantity: prod.Quantity,
                                Color: prod.Color,
                                Deduct: prod.Deduct,
                                Notes: prod.Notes,
                                Description1: prod.Description1,
                                Description2: prod.Description2,
                                MetricDescription1: prod.MetricDescription1,
                                MetricDescription2: prod.MetricDescription2,
                                UnitCost: prod.UnitCost,
                                UnitWeight: prod.UnitWeight,
                                UOM: prod.UOM,
                                ValidMacola: prod.ValidMacola,
                                ColorPallette: prod.ColorPallette,
                                MismatchedColor: prod.MismatchedColor,
                                IsSpecialPalette: prod.IsSpecialPalette,
                                Width: prod.Width,
                                Height: prod.Height,
                                Background: 'lightgreen',
                                BackgroundExperlogix: 'lightgreen',
                                BackgroundObsolete: 'lightgreen',
                                BackgroundColorValid: 'lightgreen',
                                AlternateName: prod.AlternateName,
                                LetterCode: prod.LetterCode,
                                Qty: prod.Qty,
                                ValidProduct: prod.ValidProduct,
                                ExperlogixNotes: prod.ExperlogixNotes
                            };
                            ID = ID + 1;

                            if (this.isDoorAndWall) {
                                if (product.Color == '')
                                {
                                    product.BackgroundColorValid = 'salmon';
                                    this.colorMissingProducts = true;
                                }
                                if (product.MismatchedColor == true)
                                {
                                    product.BackgroundColorValid = 'salmon';
                                    this.mismatchedColorProducts = true;
                                }
                                if (product.ValidExperlogix == false)
                                {
                                    this.missingInExperlogix = true;
                                    product.BackgroundExperlogix = 'salmon';
                                }                               
                                if (product.Obsolete == 'Yes')
                                {
                                    this.obsoleteProducts = true;
                                    product.BackgroundObsolete = 'salmon';
                                }
                            } else {
                                if (product.ValidProduct == true && product.Obsolete == 'true')
                                {
                                    //product.Background = 'salmon';
                                    product.BackgroundObsolete == 'salmon';
                                    product.BackgroundExperlogix == 'salmon';
                                    product.BackgroundColorValid == 'salmon';
                                }
                                if (product.ValidProduct == false || product.ValidExperlogix != true)
                                {
                                    //product.Background = 'bisque';
                                    product.BackgroundObsolete == 'salmon';
                                    product.BackgroundExperlogix == 'salmon';
                                    product.BackgroundColorValid == 'salmon';
                                }
                            }

                            if(product.BackgroundObsolete == 'salmon' || 
                               product.BackgroundExperlogix == 'salmon' || product.BackgroundColorValid == 'salmon')
                                this.productList.push(product);
                            else
                                tempProductList.push(product);
                        });

                        if(tempProductList.length > 0)
                        {
                            for(var i = 0; i < tempProductList.length; i++)
                            {
                                this.productList.push(tempProductList[i]);
                            }
                        }

                    } catch (error) {
                        console.log("Error importing estimate: " + error);
                        this.loaded = true;
                        this.errorMessage = "Error importing estimate: " + error;
                        this.showError = true;
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                    this.loaded = true;
                    this.errorMessage = "Error importing estimate: " + error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error importing estimate: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
                this.loaded = true;
                this.errorMessage = "Error importing estimate: " + error.status + " " + error.body.message + " " + error.body.stackTrace;
                this.showError = true;
            });
    }

    createAsyncTask() {              
        console.log(this.recordId);
        console.log(userId);
        console.log("create async task");
        createAsyncProcess({
                recordId: this.recordId,
                UserId: userId
            }).then(data => {
                if (data) {        
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);              
                    
                    if (data.includes("Save in progress")) {
                        this.showError = true;
                        this.errorMessage = data;
                        this.loaded = true;
                    }
                    else
                        this.writeEstimate();
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }                
            })
            .catch(error => {
                // TODO: handle error
                var errorJson = JSON.stringify(error);
                console.log("Error creating async process: " + errorJson);
                this.loaded = true;
            });
    }


    writeEstimate() {
        this.loaded = false;
        //recordId, alternateId, clearAlternate, alternateName, productList, 
        //existingAlternates, createMaintenanceStock, maintenancePercent
        console.log(this.recordId);
        console.log(this.alternateId);
        console.log(this.clearAlternate);
        console.log(this.alternateName);

        var productJson = JSON.stringify(this.productList);
        console.log(productJson);
        console.log(this.existingAlternates);
        console.log(this.createMaintenanceStock);
        console.log(this.maintenancePercent);
        console.log(this.newAlternate);

        writeConfiguration({
                recordId: this.recordId,
                alternateId: this.alternateId,
                clearAlternate: this.clearAlternate,
                alternateName: this.alternateName,
                productList: this.productList,
                existingAlternates: this.existingAlternates,
                createMaintenanceStock: this.createMaintenanceStock,
                maintenancePercent: this.maintenancePercent,
                newAlternate: this.newAlternate,
                division: this.division
            }).then(data => {
                if (data) {
                    try {
                        var myJSON = JSON.stringify(data);
                        console.log(myJSON);
                        if (data !== 'true') {
                            this.errorMessage = "Error uploading configuration, please send this error to IT support: " + myJSON;
                            this.showError = true;
                        } else {
                            this.errorMessage = "Save in progress, you will be notified when it finishes (Bell icon in the upper right corner).";
                            this.showError = true;
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Success!',
                                message: 'Save in progress, you will be notified when it finishes (Bell icon in the upper right corner).',
                                variant: 'success',
                                mode: 'sticky'
                            }));

                        }
                    } catch (error) {
                        console.log("Error writing configuration: " + error);
                    }

                } else if (error) {
                    this.error = error;
                    console.log(error);
                    this.errorMessage = error;
                    this.showError = true;
                }
                this.loaded = true;
            })
            .catch(error => {
                // TODO: handle error
                var myJSON = JSON.stringify(error);
                console.log("Error writing configuration: " + myJSON);
                this.errorMessage = myJSON;
                this.showError = true;
            });
    }


    handleNewAlternateChecked(event) {
        if (event.target.checked)
            this.newAlternate = true;
        else
            this.newAlternate = false;
    }

    handleDeductChecked(event) {
        if (event.target.checked)
            this.deduct = 1;
        else
            this.deduct = 0;
    }

    handleAltOptionSelected(event) {
        var value = event.target.value;

        if (value.includes("Create")) {
            this.clearAlternate = false;

        } else if (value.includes("Append")) {
            this.clearAlternate = false;

        } else if (value.includes("Replace")) {
            this.clearAlternate = true;
        }
        console.log('Clear Alt');
        console.log(this.clearAlternate);
    }

    handleFormInputChange(event) {
        console.log(event.target.name);
        console.log(event.target.value);
        if (event.target.name == 'MaintenanceStock') {
            this.maintenancePercent = event.target.value;
        } else if (event.target.name == 'AlternateName') {
            this.alternateName = event.target.value;
        }
    }

    handleGroupCheckBoxOnChange(event) {
        var altId = event.target.accessKey;
        this.alternateId = altId;
    }

    handleMaintenanceStockChecked(event) {
        if (event.target.checked)
            this.createMaintenanceStock = true;
        else
            this.createMaintenanceStock = false;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}