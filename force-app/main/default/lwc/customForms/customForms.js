import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getCustomOrderForms from '@salesforce/apex/CustomFormsHelper.getCustomOrderForms';
import downloadOrderForms from '@salesforce/apex/CustomFormsHelper.downloadOrderForms';

export default class CustomForms extends LightningElement {
    @api recordId;
    loaded = false;
    @track CustomFormList = [];
    @track isBlank = true;
    @track isMetric = false;
    @track downloadLink = '';
    @track fileDownloaded = false;
    @track showError = false;
    @track errorMessage = false;

    connectedCallback() {
        // initialize component
        this.loadCustomForms();        
    }

    loadCustomForms() {

        getCustomOrderForms().then(data => {
                if (data) {
                    try {
                        console.log(data);
                        var obj = JSON.parse(data);
                        obj.forEach(customForm => {
                            customForm.Selected = false;
                            this.CustomFormList.push(customForm);
                        });
                        this.loaded = true;
                    } catch (error) {
                        console.log("Error Loading Custom Forms: " + error);
                    }
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }
                this.loaded = true;
            })
            .catch(error => {
                var errorJSON = JSON.stringify(error);
                console.log("Error getting custom forms: " + errorJSON);
            });
    }

    handleOptionChecked(event) {
        let Id = event.target.accessKey;
        var selectedItem = this.CustomFormList.filter(customForm => {
            return customForm.ISOName == Id;
        })[0];
        selectedItem.Selected = event.target.checked;
    }

    saveDocuments(event) {
        this.loaded = false;
        console.log(this.recordId);
        console.log(this.isBlank);
        console.log(this.isMetric);
        var reportName = '';
        var selectedDivision = '';

        var customForms = this.CustomFormList.filter(x => {
            return x.Selected == true
        });
        var counter = 0;

        customForms.forEach(c => {
            if(selectedDivision == '' || selectedDivision == c.Division)
                selectedDivision = c.Division;
            else
            {
                this.loaded = true;
                this.error = 'Error: You selected custom forms from multiple divisions. Please ensure that you select forms that correspond to the same division.';
                this.showError = true;
                this.errorMessage = 'Error: You selected custom forms from multiple divisions. Please ensure that you select forms that correspond to the same division.';
            }
            counter++;
            if (customForms.length == counter)
                reportName += c.ISOName;
            else
                reportName += c.ISOName + ',';
        });

        console.log(reportName);
        //string recordId, string reportName, Boolean isBlank, Boolean isMetric
        if(!this.showError)
        {
            downloadOrderForms({
                recordId: this.recordId,
                reportName: reportName,
                isBlank: this.isBlank,
                isMetric: this.isMetric,
                division: selectedDivision
            }).then(data => {
                if (data) {

                    var myJSON = JSON.stringify(data);
                    console.log(myJSON);
                    try {
                        if (data.includes("error")) {
                            this.errorMessage = data;
                            this.showError = true;
                        } else {

                            this.downloadLink = 'data:application/png;base64,' + data;
                            this.fileDownloaded = true;
                        }

                    } catch (error) {
                        var myJSON = JSON.stringify(error);
                        console.log("Error downloading custom form: " + myJSON);
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
                console.log("Error downloading custom forms1: " + myJSON);
                this.errorMessage = myJSON;
                this.showError = true;
            });
        }
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }
    
    handleIncludeProductsChecked(event)
    {
        this.isBlank = event.target.checked;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}