import { LightningElement,
    api,
    track 
} from 'lwc';

import getItemFulfillments from '@salesforce/apex/OrderHelper.getItemFulfillments';
import getItemFulfillmentItems from '@salesforce/apex/OrderHelper.getItemFulfillmentItems';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class OrderFulfillmentRelatedList extends LightningElement {
    @api recordId;
    @track selectedFulfillmentId = '';
    @track FullfillmentCount = 0;
    @track FullfillmentItemCount = 0;
    @track fulfillmentData = [];
    @track fulfillmentItemData = [];
    @track fulfillmentColumns = [{
            label: 'Ship Date',
            fieldName: 'ShipDate',
            type: 'date',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'text',
            sortable: true
        },
        {
            label: 'Tracking Number',
            fieldName: 'TrackingNumber',
            type: 'text',
            sortable: true
        },
        {
            label: 'Shipping Method',
            fieldName: 'ShippingMethod',
            type: 'text',
            sortable: true
        },
        {
            label: 'Internal ID',
            fieldName: 'internalId',
            type: 'text',
            sortable: true
        }    
    ];

    @track fulfillmentItemColumns = [{
        label: 'Item Number',
        fieldName: 'ItemNumber',
        type: 'text',
        sortable: true
    },    
    {
        label: 'Description',
        fieldName: 'Description',
        type: 'text',
        sortable: true
    },
    {
        label: 'Division',
        fieldName: 'Division',
        type: 'text',
        sortable: true
    },
    {
        label: 'Location',
        fieldName: 'Location',
        type: 'text',
        sortable: true
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'number',
        sortable: true
    }    
];
    @track hasFulfillmentData = false;
    @track hasFulfillmentItemData = false;
    loaded = false;
    @track sortedBy = 'ItemNumber';
    @track sortDirection = 'desc';

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log(this.sortBy);
        console.log(this.sortDirection);
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.fulfillmentItemData));
        // Return the value stored in the field
        //if (fieldname == 'OpportunityLink') fieldname = 'Name';
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.fulfillmentItemData = parseData;
    }

    connectedCallback() {
        this.populateItemFulfillmentList();
    }

    populateItemFulfillmentList()
    {
        try {
            getItemFulfillments({
                recordId: this.recordId
            }).then(data => {
                console.log(data);
                var fulfillments = JSON.parse(data);                
                console.log(fulfillments);
                this.fulfillmentData = fulfillments;
                this.hasFulfillmentData = true;
                this.FullfillmentCount = this.fulfillmentData.length;
                this.loaded = true;
            });
        } catch (error) {
            console.log(error);
            this.loaded =true;
        }
    }

    populateFulfillmentItems()
    {
        this.loaded = false;
        var selectedRecords =  this.template.querySelector("[data-id='dg_itemGrid']").getSelectedRows();
        if(selectedRecords.length == 1){
            console.log('selectedRecords are ', selectedRecords);
    
            this.selectedFulfillmentId = '';
            selectedRecords.forEach(currentItem => {
                this.selectedFulfillmentId = currentItem.internalId;
            });

            getItemFulfillmentItems({
                fulfillmentId: this.selectedFulfillmentId
            }).then(data => {
                console.log(data);
                var fulfillmentItems = JSON.parse(data);                
                console.log(fulfillmentItems);
                this.fulfillmentItemData = fulfillmentItems;
                this.FullfillmentItemCount = this.fulfillmentItemData.length;
                this.loaded = true;
                this.hasFulfillmentItemData = true;
            });
        }
        else
        {
            this.handleError('Error: You must select exactly one item fulfillment to pull up the associated items.');
            this.loaded = true;
        }

    }

    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Server Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }
}