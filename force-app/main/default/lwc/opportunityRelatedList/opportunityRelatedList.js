import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import getOpportunities from '@salesforce/apex/OpportunityHelper.getOpportunities';
import getBuildingOwnerOpportunities from '@salesforce/apex/OpportunityHelper.getBuildingOwnerOpportunities';

export default class OpportunityRelatedList extends LightningElement {
    @api recordId;
    @track OpportunityCount = 0;
    @track data = [];
    @track columns = [{
            label: 'Opportunity Name',
            fieldName: 'OpportunityLink',
            type: 'url',
            initialWidth: 300,
            sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                }
            }
        },
        {
            label: '#',
            fieldName: 'Opportunity_Number__c',
            type: 'text',
            initialWidth: 80,
            sortable: true
        },
        {
            label: 'Relationship Type',
            fieldName: 'Type',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Stage',
            fieldName: 'StageName',
            type: 'text',
            initialWidth: 150,
            sortable: true
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            initialWidth: 120,
            sortable: true
        },
        {
            label: 'Pipeline Amount',
            fieldName: 'Amount',
            type: 'currency',
            initialWidth: 120,
            sortable: true,
            typeAttributes: {
                currencyCode: 'USA'
            }
        },
        {
            label: 'Probability',
            fieldName: 'Probability',
            type: 'percent',
            sortable: true
        },
        {
            label: 'Rating',
            fieldName: 'Rating__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Close Date',
            fieldName: 'CloseDate',
            type: 'date',
            initialWidth: 120,
            sortable: true
        }
    ];
    @track hasMore = false;
    @track hasData = false;
    @track sortedBy = 'CloseDate';
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
        if (fieldname == 'OpportunityLink') fieldname = 'Name';
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
        if (event.target.value == "1") {
            window.location.href = window.location.origin + '/lightning/r/Account/' + this.recordId + '/related/Opportunities/view';
        } else if (event.target.value == "2") {
            window.location.href = window.location.origin + '/lightning/r/Account/' + this.recordId + '/related/BOOpportunities__r/view';
        } else if (event.target.value == "3") {
            window.location.href = window.location.origin + '/lightning/r/Account/' + this.recordId + '/related/Opportunities2__r/view';
        }
    }

    connectedCallback() {
        this.populateOpportunityList();
    }

    populateOpportunityList() {
        var tempData = [];
        getOpportunities({
            accountId: this.recordId
        }).then(data => {
            if (data != null && data.length == 20)
                this.hasMore = true;
            data.forEach(item => {
                item.Probability = item.Probability / 100;
                item.OpportunityLink = window.location.origin + '/' + item.Id;
                item.Type = 'Direct';
                tempData.push(item);
            });
            getBuildingOwnerOpportunities({
                accountId: this.recordId
            }).then(data => {

                if (data != null && data.length == 20)
                    this.hasMore = true;
                data.forEach(item => {
                    item.Probability = item.Probability / 100;
                    item.OpportunityLink = window.location.origin + '/' + item.Id;
                    item.Type = 'Building Owner';
                    var index = tempData.map(function (e) {
                        return e.Id;
                    }).indexOf(item.Id);
                    if (index == -1) tempData.push(item);
                });
                //sort by Close Date descending
                tempData.sort((a, b) => (a.CloseDate > b.CloseDate) ? -1 : (a.CloseDate === b.CloseDate) ? 0 : 1);
                if (tempData.length > 0) this.hasData = true;
                this.data = tempData;
                this.OpportunityCount = tempData.length;
            });
        });

    }
}