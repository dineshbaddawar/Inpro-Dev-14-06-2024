import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getAlternates from '@salesforce/apex/AlternateHelper.getAlternates';

export default class AlternateRelatedList extends LightningElement {
    @api recordId;
    @track RecordCount = 0;
    @track data = [];
    @track columns = [ 
        {label: '', fieldName: 'RecordNumber', type: 'text', sortable: false, initialWidth: 30 },
        {label: 'Alternate', fieldName: 'RecordLink', type: 'url',sortable: true, initialWidth: 150, typeAttributes: {label: { fieldName: 'Name' }}},
        {label: 'Alt #', fieldName: 'Number__c', type: 'text', sortable: true, initialWidth: 130 },
        {label: 'Name', fieldName: 'Name__c', type: 'text', sortable: true, initialWidth: 400 },
        {label: 'CM', fieldName: 'CM__c', type: 'text', sortable: true, initialWidth: 100 },
        {label: 'Yield', fieldName: 'Yield__c', type: 'text', sortable: true, initialWidth: 100 },
        {label: 'Total Material', fieldName: 'Total_Material__c', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'USD' }},
        {label: 'Total List Price', fieldName: 'Total_List_Price__c', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'USD' }},
        {label: 'Freight Amount', fieldName: 'Freight_Amount__c', type: 'currency',  sortable: true, typeAttributes: { currencyCode: 'USD' }},
        {label: 'Total Tax', fieldName: 'Total_Tax__c', type: 'currency', sortable: true, typeAttributes: { currencyCode: 'USD' }},
        {label: 'Total (incl Freight/Tax)', fieldName: 'Total_incl_Freight_Tax__c', type: 'currency',  sortable: true, typeAttributes: { currencyCode: 'USD' }},
    ];
    
    @track sortedBy = 'Name__c';
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
        if (fieldname == 'RecordLink') fieldname = 'Name';
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

        var index = 1;
        parseData.forEach(item =>{
            item.RecordNumber = index++;
        });
        this.data = parseData;
    }   

    handleOpen(event){
        window.location.href = window.location.origin + '/lightning/r/Quote/' + this.recordId + '/related/Alternates__r/view';
    }

    connectedCallback(){
        this.populateRecordList();
    }

    populateRecordList()
    {
        var tempData = [];
        getAlternates({quoteId: this.recordId}).then(data =>{
            var index = 1;
            data.forEach(item =>{
                //item.Probability = item.Probability / 100;
                item.RecordLink = window.location.origin + '/' + item.Id;
                item.RecordNumber = index++;
                item.CM__c = (item.CM__c) + '%';
                item.Yield__c = (item.Yield__c) + '%';
                //item.Type = 'Direct';
                tempData.push(item);
            });

            //sort by Close Date descending
            tempData.sort((a, b) => (a.Number__c > b.Number__c) ? 1 : (a.Number__c === b.Number__c) ? 0 : -1);
            if (tempData.length > 0) this.hasData = true;
            this.data = tempData;
            this.RecordCount = tempData.length;
        });
        
    }
}