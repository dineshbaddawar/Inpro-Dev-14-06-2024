import { LightningElement, api, track } from 'lwc'; 
import fetchRecords from '@salesforce/apex/customRelatedListHelper.fetchRecords'; 
import { NavigationMixin } from 'lightning/navigation'; 
const actions = [
    { label: 'View', name: 'show_details' },
];
const columns = [
    {
        label: 'Product Code',
        fieldName: 'RecordUrl',
        type: 'url',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: {label: { fieldName: 'Item_Number__c' }, target: '_blank'}
    }, 
    {
        label: 'Description',
        fieldName: 'Description',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Description 2',
        fieldName: 'Description_2__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Color 1',
        fieldName: 'Color__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Alternate Name',
        fieldName: 'Alternate_Name__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }, {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }, {
        label: 'Sales Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
    {
        label: 'Note',
        fieldName: 'Note__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },
     {
        label: 'Subtotal',
        fieldName: 'Subtotal',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }
    , {
        label: 'Discount',
        fieldName: 'Discount__c',
        type: 'decimal',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }, {
        label: 'Total Price',
        fieldName: 'TotalPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },  
    {
        label: 'Yield(%)',
        fieldName: 'Yield__c',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },  
    {
        label: 'Product',
        fieldName: 'Product__c',
        type: 'text',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    },    
    {
        label: 'Sequence Number',
        fieldName: 'Sequence_Number__c',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' }
    }
];

export default class customRelatedList extends NavigationMixin( LightningElement ) { 
 

    @track data = [];
    @track columns = columns;
    @api recordId;
    @track loaded = false;
    record = {};

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy = "Sequence_Number__c";

    connectedCallback() {
        debugger;
        this.loadRecords();
    }

    refreshGrid()
    {
        debugger;
        this.data = [];
        this.loadRecords();
    }

    loadRecords() {
        debugger;
        fetchRecords({
                recordId: this.recordId
            }).then(data => {
                if (data) {
                    data.forEach(x => {
                        x.RecordUrl = window.location.origin + '/' + x.Id;
                    });
                    this.data = data;
                    this.sortedBy = "Sequence_Number__c";
                    this.loaded = true;
                } else if (error) {
                    this.error = error;
                    console.log(error);
                }                
            })
            .catch(error => {
                // TODO: handle error
                console.log("Error loading quote products: " + error.status + " " + error.body.message + " " + error.body.stackTrace);
            });


    }

    navigateToRecordViewPage(event) {       
        debugger; 
        this.record = event.detail.row;     
        console.log(this.record.Id);
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.record.Id,
                //objectApiName: 'Lead', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    sortBy(field, reverse, primer) {
        debugger;
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        debugger;
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
 
}