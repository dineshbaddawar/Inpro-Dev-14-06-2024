import {  LightningElement,
    api,
    wire,
    track } from 'lwc';

import getOrders from '@salesforce/apex/ContractHelper.getOrders';
import getContract from '@salesforce/apex/ContractHelper.getContract';

export default class ContractOrderRelatedList extends LightningElement {
    @api recordId;
    @track OrderCount = 0;
    @track data = [];
    @track columns = [ 
        {label: 'Order #', fieldName: 'OrderLink', type: 'url', initialWidth: 100, sortable: true, typeAttributes: {label: { fieldName: 'NetSuite_TranId__c' }}},
        {label: 'PO #', fieldName: 'PoNumber', type: 'text', initialWidth: 120, sortable: true },
        {label: 'Account', fieldName: 'AccountLink', type: 'url', initialWidth: 150, sortable: true, typeAttributes: {label: { fieldName: 'AccountName' }} },
        {label: 'Type', fieldName: 'Type', type: 'text', initialWidth: 150, sortable: true },
        {label: 'Order Status', fieldName: 'Status', type: 'text', initialWidth: 120, sortable: true },
        {label: 'Terms', fieldName: 'Terms__c', type: 'text', initialWidth: 120, sortable: true},
        {label: 'Account #', fieldName: 'AccountNumber', type: 'text', initialWidth: 100, sortable: true},
        {label: 'Entered Date', fieldName: 'EffectiveDate', type: 'date', initialWidth: 120, sortable: true},
        {label: 'Ship Date', fieldName: 'Exp_Ship_Date__c', type: 'date', initialWidth: 120, sortable: true},
        {label: 'Order Total', fieldName: 'Total_Cost__c', type: 'currency', initialWidth: 120, sortable: true, typeAttributes: { currencyCode: 'USA' }}
    ];
    @track hasData = false;
    @track sortedBy = 'Exp_Ship_Date__c';
    @track sortDirection = 'desc';

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log(this.sortBy);
        console.log(this.sortDirection);
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        if (fieldname == 'OrderLink') fieldname = 'NetSuite_TranId__c';
        if (fieldname == 'AccountLink') fieldname = 'AccountName';
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    // handleOpen(event){
    //     if (event.target.value == "1")
    //     {
    //         window.location.href = window.location.origin + '/lightning/r/Account/' + this.recordId + '/related/Opportunities/view';
    //     }
    //     else if (event.target.value == "2")
    //     {
    //         window.location.href = window.location.origin + '/lightning/r/Account/' + this.recordId + '/related/BOOpportunities__r/view';
    //     }
    //     else if (event.target.value == "3")
    //     {
    //         window.location.href = window.location.origin + '/lightning/r/Account/' + this.recordId + '/related/Opportunities2__r/view';
    //     }
    // }

    connectedCallback(){
        this.populateOrderList();
    }

    populateOrderList()
    {
        var poNumber = '';
        var accountId = '';
        console.log('Record ID: ' + this.recordId);
        getContract({recordId: this.recordId}).then(data =>{
            data.forEach(item =>{
                poNumber = item.Original_PO_Contract_No__c;
                accountId = item.Account__c;
            });
            if(poNumber != '' && accountId != '')
            {
                var tempData = [];
                getOrders({poNumber: poNumber, accountId: accountId}).then(data =>{
                    data.forEach(item =>{
                        this.OrderCount++;
                        this.hasData = true;
                        item.OrderLink = window.location.origin + '/' + item.Id;
                        item.AccountLink = window.location.origin + '/' + item.AccountId;
                        item.AccountName = item.Account.Name;
                        item.Type = 'Order';
                        item.AccountNumber = item.Account.Customer_Number__c;
                        tempData.push(item);
                    });
                    this.data = tempData;
                });    
            }   
        });        
    }
}