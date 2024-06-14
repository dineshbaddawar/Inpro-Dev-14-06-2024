import { LightningElement, track, api } from 'lwc';

import RunReport from '@salesforce/apex/ReportGeneratorHelper.runSavedSearch';
import RetrieveFilterValues from '@salesforce/apex/ReportGeneratorHelper.retrieveNetSuiteFilterValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReportGenerator extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track loadMessage = 'Loading...';
    @track loaded = false;
    @track reportData = [];
    @track reportColumns = [];
    @track reportOptions = [];
    @track reportFilters = [];
    @track locations = [];
    @track divisions = [];
    @track theRecord = [];
    @track selectedReport = '';
    @track fileData = '';
    @track reportReadyForDownload = false;

    //on load
    connectedCallback()
    {
        console.log('Enter');                       
        this.populateReportOptions();
        this.retrieveFilterValues();     
    }

    //called on change of DOM to handle filter visibility
    renderedCallback()
    {
        this.toggleAvailableFilters(this.theRecord['lcb_reportSelection']); 
    }

    //adds the report options to the dropdown list
    populateReportOptions()
    {
        this.reportOptions.push({
            value: 'customsearch_ipc_inventory_qty_by_item',
            label: 'Inventory Quantities by Item'
        }); 
        this.reportOptions.push({
            value: 'customsearch_ipc_work_ord_by_assmbly_itm',
            label: 'Open Work Orders by Assembly Item'
        });
        this.reportOptions.push({
            value: 'customsearch_ipc_customer_product_hist',
            label: 'Customer Product History'
        });
        this.reportOptions.push({
            value: 'customsearch_ipc_dne_sales_late_order_vw',
            label: 'Late Order - Sales View'
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

    //pushes the appropriate filter values to a list before executing the apex call
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
    }

    //toggles visibility of filters based on selected report
    toggleAvailableFilters(selectedReport)
    {
        //checks to see if the filters are visible in the DOM
        if(this.template.querySelector("[data-id='li_startDate']") != null)
        {
            if(selectedReport == 'customsearch_ipc_inventory_qty_by_item')
            {
                this.template.querySelector("[data-id='li_startDate']").disabled = true;
                this.template.querySelector("[data-id='li_endDate']").disabled = true;
                this.template.querySelector("[data-id='dl_division']").disabled = true;
                this.template.querySelector("[data-id='dl_location']").disabled = false;
                this.template.querySelector("[data-id='li_itemNumber']").disabled = false;
                this.template.querySelector("[data-id='li_documentNumber']").disabled = true;
                this.template.querySelector("[data-id='li_customerNumber']").disabled = true;
            }
            else if(selectedReport == 'customsearch_ipc_work_ord_by_assmbly_itm')
            {
                this.template.querySelector("[data-id='li_startDate']").disabled = true;
                this.template.querySelector("[data-id='li_endDate']").disabled = true;
                this.template.querySelector("[data-id='dl_division']").disabled = false;
                this.template.querySelector("[data-id='dl_location']").disabled = false;
                this.template.querySelector("[data-id='li_itemNumber']").disabled = false;
                this.template.querySelector("[data-id='li_documentNumber']").disabled = false;
                this.template.querySelector("[data-id='li_customerNumber']").disabled = true;
            }
            else if(selectedReport == 'customsearch_ipc_customer_product_hist')
            {
                this.template.querySelector("[data-id='li_startDate']").disabled = false;
                this.template.querySelector("[data-id='li_endDate']").disabled = false;
                this.template.querySelector("[data-id='dl_division']").disabled = false;
                this.template.querySelector("[data-id='dl_location']").disabled = true;
                this.template.querySelector("[data-id='li_itemNumber']").disabled = false;
                this.template.querySelector("[data-id='li_documentNumber']").disabled = false;
                this.template.querySelector("[data-id='li_customerNumber']").disabled = false;
            }
            else if(selectedReport == 'customsearch_ipc_dne_sales_late_order_vw')
            {
                this.template.querySelector("[data-id='li_startDate']").disabled = true;
                this.template.querySelector("[data-id='li_endDate']").disabled = true;
                this.template.querySelector("[data-id='dl_division']").disabled = true;
                this.template.querySelector("[data-id='dl_location']").disabled = true;
                this.template.querySelector("[data-id='li_itemNumber']").disabled = true;
                this.template.querySelector("[data-id='li_documentNumber']").disabled = false;
                this.template.querySelector("[data-id='li_customerNumber']").disabled = true;
            }
            else
            {
                this.template.querySelector("[data-id='li_startDate']").disabled = true;
                this.template.querySelector("[data-id='li_endDate']").disabled = true;
                this.template.querySelector("[data-id='dl_division']").disabled = true;
                this.template.querySelector("[data-id='dl_location']").disabled = true;
                this.template.querySelector("[data-id='li_itemNumber']").disabled = true;
                this.template.querySelector("[data-id='li_documentNumber']").disabled = true;
                this.template.querySelector("[data-id='li_customerNumber']").disabled = true;
            }
        }
    }

    //apex call to retrieve report results
    runSelectedReport()
    {
        if(this.theRecord['lcb_reportSelection'] == 'customsearch_ipc_dne_sales_late_order_vw' && (this.theRecord['li_documentNumber'] == null || this.theRecord['li_documentNumber'] == ''))
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Missing Order Number',
                message: 'An order number must be specified to run this report.',
                variant: 'error'
            }));
            this.loaded = true;
        }
        else
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
                reportId: this.theRecord['lcb_reportSelection'],
                reportPath: ''
            }).then(data => {
                if (data) {
                    try {
                        var results = JSON.parse(data);                   
                        if(results.Status)
                        {
                            if(results.columnHeaders != null)
                            {
                                for(var i = 0; i < results.columnHeaders.length; i++)
                                {
                                    reportColumnsLocal.push({label: results.columnHeaders[i].label, fieldName: results.columnHeaders[i].fieldName, wrapText: true});
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
    }
   
    //event handler on change of inputs..
    handleInputOnChange(event)
    {
        if(event.target.name == "lcb_reportSelection")
        {
            this.theRecord[event.target.name] = event.target.value;
            this.toggleAvailableFilters(this.theRecord[event.target.name]);
        }
        else if(event.target.name == "dl_location")
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
    
    // this method validates the data and creates the csv file to download
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