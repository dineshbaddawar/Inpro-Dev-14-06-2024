import { LightningElement, track, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RunReport from '@salesforce/apex/ReportGeneratorHelper.runSavedSearch';
import RetrieveAccount from '@salesforce/apex/AccountHelper.getAccount';
import RetrieveFilterValues from '@salesforce/apex/ReportGeneratorHelper.retrieveNetSuiteFilterValues';

export default class CustomerProductHistory extends LightningElement {
    @api recordId;
    @track loadMessage = 'Loading...';
    @track loaded = false;
    @track reportData = [];
    @track reportColumns = [];
    @track reportOptions = [];
    @track reportFilters = [];
    @track customerNumber = '';
    @track selectedReport = '';
    @track locations = [];
    @track divisions = [];
    @track fileData = '';
    @track reportReadyForDownload = false;
    @track theRecord = [];
    @track returnedMaxRows = false;

    connectedCallback()
    {
        RetrieveAccount({recordId: this.recordId}).then(data =>{
            data.forEach(account =>{
                this.theRecord['li_customerNumber'] = account.Customer_Number__c;
            });
            if(this.theRecord['li_customerNumber'] != null && this.theRecord['li_customerNumber'] != '')
            {
                this.retrieveFilterValues();
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'Error: The customer number could not be found.',
                    variant: 'warning'
                }));
            }
        });                     
    }

    //call to NetSuite API to grab filter options for multi-select filters
    retrieveFilterValues()
    {
        RetrieveFilterValues({}).then(data => {
            if (data) {
                try {
                    var results = JSON.parse(data);
                    
                    if(results.Status)
                    {
                        if(results.filterFields != null && results.filterFields.length > 0)
                        {
                            for(var i = 0; i < results.filterFields.length; i++)
                            {
                                if(results.filterFields[i].fieldName == 'division')
                                {
                                    if(results.filterFields[i].filterProperties != null && results.filterFields[i].filterProperties.length > 0)
                                    {
                                        for(var j = 0; j < results.filterFields[i].filterProperties.length; j++)
                                        {
                                            this.divisions.push({
                                                label: results.filterFields[i].filterProperties[j].filterName,
                                                value: results.filterFields[i].filterProperties[j].filterValue
                                            });
                                        }
                                    }
                                }
                                else if(results.filterFields[i].fieldName = 'location')
                                {
                                    if(results.filterFields[i].filterProperties != null && results.filterFields[i].filterProperties.length > 0)
                                    {
                                        for(var j = 0; j < results.filterFields[i].filterProperties.length; j++)
                                        {
                                            this.locations.push({
                                                label: results.filterFields[i].filterProperties[j].filterName,
                                                value: results.filterFields[i].filterProperties[j].filterValue
                                            });
                                        }
                                    }
                                }
                            }
                        }
                        this.runSelectedReport();
                    }
                    else
                    {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: results.Message,
                            variant: 'warning'
                        }));
                        this.loaded = true; 
                    }
                } catch (error) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'There was a problem retrieving the filter values: ' + error,
                        variant: 'warning'
                    }));                    
                    this.loaded = true; 
                } 
            } else if (error) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'There was a problem retrieving the filter values: ' + error,
                    variant: 'warning'
                })); 
                this.loaded = true; 
            }
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'There was a problem retrieving the filter values: ' + error,
                variant: 'warning'
            })); 
            this.loaded = true; 
        });
    }

    //event handler on change of inputs..
    handleInputOnChange(event)
    {
        if(event.target.name == "dl_location")
        {
            if(event.detail.value != null && event.detail.value.length > 0)
                this.theRecord[event.target.name] = this.convertListToString(event.detail.value);
            else
                this.theRecord[event.target.name] = '';
        }
        else if(event.target.name == "dl_division")
        {
            if(event.detail.value != null && event.detail.value.length > 0)
                this.theRecord[event.target.name] = this.convertListToString(event.detail.value);
            else
                this.theRecord[event.target.name] = '';
        }
        else
            this.theRecord[event.target.name] = event.target.value;
    }

    //converts multi select filters to a comma-delimited string
    convertListToString(list)
    {
        var returnString = '';
        for(var i = 0; i < list.length; i++)
        {
            returnString += list[i] + ',';
        }
        return returnString.substring(0,returnString.length - 1);
    } 

    downloadPDF()
    {
        var randomNumber = Math.random() * 100000;
        let element = document.createElement('a');
        element.setAttribute('href', 'data:application/pdf;base64,' + this.fileData);
        element.setAttribute('download', 'report' + randomNumber.toString() + '.pdf');
        element.style.display = 'none';
        document.body.appendChild(element);

        element.click();
        document.body.removeChild(element);
    }

    runSelectedReport()
    {
        if(this.theRecord['li_customerNumber'] != null && this.theRecord['li_customerNumber'] != '')
        {
            console.log('run report');
            var reportDataLocal = [];
            var reportColumnsLocal = [];
            this.loaded = false;
            this.reportFilters = [];
            this.reportColumns = [];
            this.reportData = [];

            this.handleSelectedFilters();
            
            RunReport({
                filters: this.reportFilters,
                reportId: 'customsearch_ipc_customer_product_hist',
                reportPath: ''
            }).then(data => {
                if (data) {
                    try {
                        var results = JSON.parse(data);
                        
                        if(results.searchRowCount != null && results.searchRowCount == 1000)
                            this.returnedMaxRows = true;     
                        else
                            this.returnedMaxRows = false;

                        if(results.Status)
                        {
                            if(results.columnHeaders != null)
                            {
                                for(var i = 0; i < results.columnHeaders.length; i++)
                                {
                                    reportColumnsLocal.push({label: results.columnHeaders[i].label, fieldName: results.columnHeaders[i].fieldName, initialWidth: parseInt(results.columnHeaders[i].initialWidth)});
                                }                  
                            }
                            if(results.reportDataRows != null)
                            {
                                for(var i = 0; i < results.reportDataRows.length; i++)
                                {
                                    if(results.reportDataRows[i].rowProperties != null)
                                    {
                                        var currentRow = {};
                                        for(var j = 0; j < results.reportDataRows[i].rowProperties.length; j++)
                                        {
                                            currentRow[results.reportDataRows[i].rowProperties[j].columnName] = results.reportDataRows[i].rowProperties[j].columnValue; 
                                        }
                                        reportDataLocal.push(currentRow);
                                    }
                                }
                            }
                            this.reportColumns = reportColumnsLocal;
                            this.reportData = reportDataLocal;
                            this.loaded = true;
                        }
                        else
                        {
                            this.dispatchEvent(new ShowToastEvent({
                                title: 'Error',
                                message: results.Message,
                                variant: 'warning'
                            }));
                            this.loaded = true; 
                        }
                    } catch (error) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'There was a problem processing the report: ' + error,
                            variant: 'warning'
                        })); 
                        this.loaded = true; 
                    } 
                } else if (error) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'There was a problem processing the report: ' + error,
                        variant: 'warning'
                    }));
                    this.loaded = true; 
                }
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'There was a problem processing the report: ' + error,
                    variant: 'warning'
                }));
                this.loaded = true; 
            });
        }
        else
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Error: The customer number could not be found.',
                variant: 'warning'
            }));
            this.loaded = true; 
        }
    }

    handleSelectedFilters()
    {
        this.reportFilters = [];
        if(this.theRecord['li_itemNumber'] != null && this.theRecord['li_itemNumber'] != '')
            this.reportFilters.push({ filterName: 'Item Number', filterValue: this.theRecord['li_itemNumber'] });
        if(this.theRecord['li_startDate'] != null && this.theRecord['li_startDate'] != '')
            this.reportFilters.push({ filterName: 'Start Date', filterValue: this.theRecord['li_startDate'] });
        if(this.theRecord['li_endDate'] != null && this.theRecord['li_endDate'] != '')
            this.reportFilters.push({ filterName: 'End Date', filterValue: this.theRecord['li_endDate'] });
        if(this.theRecord['dl_division'] != null && this.theRecord['dl_division'] != '')
            this.reportFilters.push({ filterName: 'Division', filterValue: this.theRecord['dl_division'] });
        if(this.theRecord['dl_location'] != null && this.theRecord['dl_location'] != '')
            this.reportFilters.push({ filterName: 'Location', filterValue: this.theRecord['dl_location'] });
        if(this.theRecord['li_documentNumber'] != null && this.theRecord['li_documentNumber'] != '')
            this.reportFilters.push({ filterName: 'Document Number', filterValue: this.theRecord['li_documentNumber'] });
        if(this.theRecord['li_customerNumber'] != null && this.theRecord['li_customerNumber'] != '')
            this.reportFilters.push({ filterName: 'Customer Number', filterValue: this.theRecord['li_customerNumber'] });   
        if(this.theRecord['li_quoteOpportunityName'] != null && this.theRecord['li_quoteOpportunityName'] != '')
            this.reportFilters.push({ filterName: 'Quote Opportunity Name', filterValue: this.theRecord['li_quoteOpportunityName'] });  
    }

    downloadCSVFile() {   
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.reportData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
        csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.reportData.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.reportData[i][rowKey] === undefined ? '' : this.reportData[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'Report Data - ' + new Date() + '.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
    }
}