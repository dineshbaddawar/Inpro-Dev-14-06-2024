import {
    LightningElement,
    api,
    track
} from 'lwc';

import getLineItems from '@salesforce/apex/OrderHelper.getLineItems';

export default class OrderLineRelatedList extends LightningElement {

    @api recordId;
    isOrder = true;
    @track LineCount = 0;
    data = [];
    @track columns = [{
            label: 'Item No',
            fieldName: 'ItemNumber',
            type: 'text',
            sortable: true
        },
        {
            label: 'Quantity',
            fieldName: 'Quantity',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Qty Committed',
            fieldName: 'QuantityCommitted',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Qty Fulfilled',
            fieldName: 'QuantityFulfilled',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Qty Invoiced',
            fieldName: 'QuantityInvoiced',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Qty Backordered',
            fieldName: 'QuantityBackordered',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Unit Price',
            fieldName: 'UnitPrice',
            type: 'currency',
            initialWidth: 100,
            sortable: true
        },
        {
            label: 'Total Price',
            fieldName: 'TotalPrice',
            type: 'currency',
            initialWidth: 100,
            sortable: true
        },
        {
            label: 'Line Description',
            fieldName: 'Description',
            type: 'text',
            sortable: true
        },
    ];

    @track InvColumns = [{
        label: 'Item No',
        fieldName: 'ItemNumber',
        type: 'text',
        sortable: true
    },    
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'text',
        initialWidth: 100,
        sortable: true
    },
    {
        label: 'Backordered Qty',
        fieldName: 'BackorderedQuantity',
        type: 'text',
        initialWidth: 100,
        sortable: true
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        initialWidth: 100,
        sortable: true
    },
    {
        label: 'Line Total',
        fieldName: 'TotalPrice',
        type: 'currency',
        initialWidth: 200,
        sortable: true
    }    
];
    @track hasData = false;
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
        let parseData = JSON.parse(JSON.stringify(this.data));
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
        this.data = parseData;
    }

    handleOpen(event) {

    }

    connectedCallback() {
        this.populateLineItemList();
    }

    populateLineItemList() {
        try {
            getLineItems({
                recordId: this.recordId
            }).then(data => {
                var i = 0;
                console.log(data);
                var lineItems = JSON.parse(data);
                lineItems.forEach(li => {
                    if(li.OrderNumber != null)
                        this.isOrder = false;
                    li.Id = i++;
                });
                console.log(lineItems);
                this.data = lineItems;
                this.hasData = true;
                this.LineCount = this.data.length;
                this.loaded = true;
            });
        } catch (error) {
            console.log(error);
            this.loaded =true;
        }
    }

}