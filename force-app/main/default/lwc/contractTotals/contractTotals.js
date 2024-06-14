import { 
    LightningElement, 
    track, 
    api } 
from 'lwc';

import LoadContractTotals from '@salesforce/apex/ContractHelper.loadContractTotals';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContractTotals extends LightningElement {
    
    @api recordId;
    @track executedContractData = [];
    @track executedContractColumns = [];
    @track openOrderData = [];
    @track openOrderColumns = [];
    @track billedOrderData = [];
    @track billedOrderColumns = [];
    @track remainingContractData = [];
    @track remainingContractColumns = [];
    @track executedContractTotal = '';
    @track totalOpenOrderAmount = '';
    @track pendingContractTotal = '';
    @track totalBilledOrderAmount = '';
    @track loaded;
    @track loadMessage = 'Loading...';
    @track activeSections = ['grandTotals','executedTotals','openOrderTotals','billedOrderTotals','remainingContractTotals'];

    connectedCallback()
    {
        this.loaded = false;
        console.log('start');
        this.retrieveContractTotals();
    }

    retrieveContractTotals()
    {
        LoadContractTotals({
            recordId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    console.log('ran');
                    var results = JSON.parse(data);                   
                    if(results.Status)
                    {
                        var executedContractDataLocal = [];
                        var executedContractColumnsLocal = [];
                        var openOrderDataLocal = [];
                        var openOrderColumnsLocal = [];
                        var billedOrderDataLocal = [];
                        var billedOrderColumnsLocal = [];
                        var remainingContractDataLocal = [];
                        var remainingContractColumnsLocal = [];

                        this.executedContractTotal = results.executedContractAmount;
                        this.totalOpenOrderAmount = results.totalOpenOrderAmount;
                        this.totalBilledOrderAmount = results.totalBilledOrderAmount;
                        this.pendingContractTotal = results.pendingContractAmount;
                        
                        //executed totals
                        if(results.executedDivisionalTotals != null && results.executedDivisionalTotals.columnHeaders != null)
                        {
                            for(var i = 0; i < results.executedDivisionalTotals.columnHeaders.length; i++)
                            {
                                executedContractColumnsLocal.push({label: results.executedDivisionalTotals.columnHeaders[i].label, fieldName: results.executedDivisionalTotals.columnHeaders[i].fieldName});
                            }                  
                        }
                        if(results.executedDivisionalTotals != null && results.executedDivisionalTotals.reportDataRows != null)
                        {
                            for(var i = 0; i < results.executedDivisionalTotals.reportDataRows.length; i++)
                            {
                                if(results.executedDivisionalTotals.reportDataRows[i].rowProperties != null)
                                {
                                    var currentRow = {};
                                    for(var j = 0; j < results.executedDivisionalTotals.reportDataRows[i].rowProperties.length; j++)
                                    {
                                        currentRow[results.executedDivisionalTotals.reportDataRows[i].rowProperties[j].columnName] = results.executedDivisionalTotals.reportDataRows[i].rowProperties[j].columnValue; 
                                    }
                                    executedContractDataLocal.push(currentRow);
                                }
                            }
                        }

                        //open orders
                        if(results.openOrderDivisionalTotals != null && results.openOrderDivisionalTotals.columnHeaders != null)
                        {
                            for(var i = 0; i < results.openOrderDivisionalTotals.columnHeaders.length; i++)
                            {
                                openOrderColumnsLocal.push({label: results.openOrderDivisionalTotals.columnHeaders[i].label, fieldName: results.openOrderDivisionalTotals.columnHeaders[i].fieldName});
                            }                  
                        }
                        if(results.openOrderDivisionalTotals != null && results.openOrderDivisionalTotals.reportDataRows != null)
                        {
                            for(var i = 0; i < results.openOrderDivisionalTotals.reportDataRows.length; i++)
                            {
                                if(results.openOrderDivisionalTotals.reportDataRows[i].rowProperties != null)
                                {
                                    var currentRow = {};
                                    for(var j = 0; j < results.openOrderDivisionalTotals.reportDataRows[i].rowProperties.length; j++)
                                    {
                                        currentRow[results.openOrderDivisionalTotals.reportDataRows[i].rowProperties[j].columnName] = results.openOrderDivisionalTotals.reportDataRows[i].rowProperties[j].columnValue; 
                                    }
                                    openOrderDataLocal.push(currentRow);
                                }
                            }
                        }

                        //billed orders
                        if(results.billedOrderDivisionalTotals != null && results.billedOrderDivisionalTotals.columnHeaders != null)
                        {
                            for(var i = 0; i < results.billedOrderDivisionalTotals.columnHeaders.length; i++)
                            {
                                billedOrderColumnsLocal.push({label: results.billedOrderDivisionalTotals.columnHeaders[i].label, fieldName: results.billedOrderDivisionalTotals.columnHeaders[i].fieldName});
                            }                  
                        }
                        if(results.billedOrderDivisionalTotals != null && results.billedOrderDivisionalTotals.reportDataRows != null)
                        {
                            for(var i = 0; i < results.billedOrderDivisionalTotals.reportDataRows.length; i++)
                            {
                                if(results.billedOrderDivisionalTotals.reportDataRows[i].rowProperties != null)
                                {
                                    var currentRow = {};
                                    for(var j = 0; j < results.billedOrderDivisionalTotals.reportDataRows[i].rowProperties.length; j++)
                                    {
                                        currentRow[results.billedOrderDivisionalTotals.reportDataRows[i].rowProperties[j].columnName] = results.billedOrderDivisionalTotals.reportDataRows[i].rowProperties[j].columnValue; 
                                    }
                                    billedOrderDataLocal.push(currentRow);
                                }
                            }
                        }

                        //remaining contract values
                        if(results.remainingContractDivisionalTotals != null && results.remainingContractDivisionalTotals.columnHeaders != null)
                        {
                            for(var i = 0; i < results.remainingContractDivisionalTotals.columnHeaders.length; i++)
                            {
                                remainingContractColumnsLocal.push({label: results.remainingContractDivisionalTotals.columnHeaders[i].label, fieldName: results.remainingContractDivisionalTotals.columnHeaders[i].fieldName});
                            }                  
                        }
                        if(results.remainingContractDivisionalTotals != null && results.remainingContractDivisionalTotals.reportDataRows != null)
                        {
                            for(var i = 0; i < results.remainingContractDivisionalTotals.reportDataRows.length; i++)
                            {
                                if(results.remainingContractDivisionalTotals.reportDataRows[i].rowProperties != null)
                                {
                                    var currentRow = {};
                                    for(var j = 0; j < results.remainingContractDivisionalTotals.reportDataRows[i].rowProperties.length; j++)
                                    {
                                        currentRow[results.remainingContractDivisionalTotals.reportDataRows[i].rowProperties[j].columnName] = results.remainingContractDivisionalTotals.reportDataRows[i].rowProperties[j].columnValue; 
                                    }
                                    remainingContractDataLocal.push(currentRow);
                                }
                            }
                        }
                        this.executedContractData = executedContractDataLocal;
                        this.executedContractColumns = executedContractColumnsLocal;
                        this.openOrderData = openOrderDataLocal;
                        this.openOrderColumns = openOrderColumnsLocal;
                        this.billedOrderData = billedOrderDataLocal;
                        this.billedOrderColumns = billedOrderColumnsLocal;
                        this.remainingContractData = remainingContractDataLocal;
                        this.remainingContractColumns = remainingContractColumnsLocal;
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

    closeQuickAction(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}