import {
    LightningElement,
    api,
    track
} from 'lwc';
import getActivities from '@salesforce/apex/RelatedActivityRollupHelper.getActivities';
import getHistoricalActivities from '@salesforce/apex/RelatedActivityRollupHelper.getHistoricalActivities';
import getActivityAttachmentsById from '@salesforce/apex/RelatedActivityRollupHelper.getActivityAttachmentsById';
import getActivityAttachmentFileById from '@salesforce/apex/RelatedActivityRollupHelper.getActivityAttachmentFileById';

const actions = [{
    label: 'Show details',
    name: 'show_details'
}];

const columns = [{
        label: '',
        fieldName: 'RecordNumber',
        type: 'text',
        sortable: false,
        initialWidth: 30
    },
    {
        label: 'Activity Date',
        fieldName: 'ActivityDate',
        type: "date",
        typeAttributes: {
            year: "numeric",
            month: "long",
            day: "2-digit"
        },
        sortable: true,
        initialWidth: 150
    },
    {
        label: 'Type',
        fieldName: 'TaskSubtype',
        type: 'text',
        sortable: true,
        initialWidth: 70
    },
    {
        label: 'Subject',
        fieldName: 'RecordLink',
        type: 'url',
        sortable: true,
        initialWidth: 200,
        typeAttributes: {
            label: {
                fieldName: 'Subject'
            }
        }
    },
    {
        label: 'Description',
        fieldName: 'Description',
        type: 'text',
        sortable: true,
        //initialWidth: 250
    },
    {
        label: 'Regarding',
        fieldName: 'WhatIdRecordLink',
        type: 'url',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {
            label: {
                fieldName: 'WhatIdName'
            }
        }
    },
    {
        label: 'Owner',
        fieldName: 'OwnerIdRecordLink',
        type: 'url',
        sortable: true,
        initialWidth: 100,
        typeAttributes: {
            label: {
                fieldName: 'OwnerIdName'
            }
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions
        },
    }

];

export default class RelatedActivityRollup extends LightningElement {

    @api recordId;
    @track RecordCount = 0;
    @track activities = [];
    @track allActivities = [];
    @track savedAllActivities = [];
    @track pageActivities = [];
    @api objectApiName;

    @track Description = '';
    @track columns = columns;
    @track sortedBy = 'ActivityDate';
    @track sortDirection = 'desc';
    @track searchValue = "";
    @track showGrid = true;
    @track loaded = false;

    @track searchPage = 1;
    @track maxPage = 1;
    @track pageLibrary = [];
    @track tableReady = false;

    @track allAttachments = []; //all attachments
    @track activityAttachments = []; //filled for current attachment
    @track containsAttachments = false;
    
    handlePageChange(event)
    {
        const name = event.target.name;

        if (name == 'Next')
        {
            var nextPage = parseInt(this.searchPage) + 1;
            if (nextPage <= parseInt(this.maxPage))
            {
                this.searchPage = nextPage.toString();
                this.handlePopulatePage();
            }
        }
        else if (name == 'Back')
        {
            var lastPage = parseInt(this.searchPage) - 1;
            if (lastPage >= 1)
            {
                this.searchPage = lastPage.toString();
                this.handlePopulatePage();
            }
        }
        else
        {
            const value = event.target.value;
            this.searchPage = value;
            this.handlePopulatePage();
        }
    }

    handlePopulatePage(){
        this.tableReady = false;
        this.activities = [];
        var temp = [];
        //console.log('Current Page: ' + parseInt(this.searchPage));
        var firstIndex = ((parseInt(this.searchPage)-1)*10);
        var lastIndex = (((parseInt(this.searchPage))*10));
        if (lastIndex > this.allActivities.length) lastIndex = this.allActivities.length;
        //console.log('Start of array: ' + firstIndex + ', end of array: ' + lastIndex + ', length of array: ' + this.allActivities.length)
        for(var i = firstIndex; i < lastIndex; i++)
        {
            temp.push(this.allActivities[i]);
        }
        this.activities = temp;
        
        this.tableReady = true;
    }

    handleRowAction(event) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log(row.Id);
        console.log(row.ActivityId.toLowerCase());
        console.log(row.Subject);
       
        this.activityAttachments = this.allAttachments.filter(x => {
            return x.ObjectId == row.ActivityId.toLowerCase();
        });

        if (this.activityAttachments.length > 0)
        {
            this.containsAttachments = true;
        }
        else
        {
            this.containsAttachments = false;
        }

        console.log('# All Attachments: ' + this.allAttachments.length);
        console.log('# Attachments found: ' + this.activityAttachments.length);

        this.Description = row.Description;
        if (row.Html != null && row.Html != '')
            this.Description = row.Html;
        this.showGrid = false;
        switch (actionName) {
            case 'show_details':
                console.log('show details');
            default:
        }
    }

    handleCloseGrid() {
        this.showGrid = true;
    }

    handleSearch(event) {
        var value = event.target.value;
        var tempData = this.savedAllActivities.filter(x => {
            return x.Subject.toLowerCase().includes(value.toLowerCase()) || x.Description.toLowerCase().includes(value.toLowerCase());
        });
        console.log(tempData);
        //Update page threshold
        var pages = parseInt(Math.ceil(tempData.length / 10));
        console.log('Pages: ' + pages);
        this.maxPage = pages;
        this.pageLibrary = [];
        for(var i = 1; i <= pages; i++)
        {
            this.pageLibrary.push({value: i, label: i});
        }
        this.RecordCount = tempData.length;
        console.log('Set allactivities');
        this.allActivities = tempData;
        this.searchPage = 1;
        console.log('Repopulate on search term ' + value);
        this.handlePopulatePage();
    }

    sortBy(field, reverse, primer) {
        const key = primer ?
            function (x) {
                return primer(x[field]);
            } :
            function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const {
            fieldName: sortedBy,
            sortDirection
        } = event.detail;
        const cloneData = [...this.allActivities];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.allActivities = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.handlePopulatePage();
    }

    handleOpen(event) {
        // window.location.href = window.location.origin + '/lightning/r/Quote/' + this.recordId + '/related/Alternates__r/view';
    }

    connectedCallback() {
        console.log(this.objectApiName);
        this.populateRecordList();
    }

    downloadAttachment(event){
        let key = event.target.accessKey;
        console.log(event.target);
        console.log(event.detail);
        console.log('Key is: ' + key);
        getActivityAttachmentFileById({recordId: key}).then(data =>{
            console.log(data);
            try{
                var results = JSON.parse(data);
                //console.log(results);
        
                if (results != null)
                {
                    //Build blob buffer
                    var binaryString = window.atob(results.Body);
                    var binaryLen = binaryString.length;
                    var bytes = new Uint8Array(binaryLen);
                    for (var i = 0; i < binaryLen; i++) {
                        var ascii = binaryString.charCodeAt(i);
                        bytes[i] = ascii;
                    }
            
                    //Create document download link and automatically click it
                    var link = document.createElement('a');
                    link.href = window.URL.createObjectURL(new Blob([bytes] , {type:"text/plain"}));
                    var fileName = results.FileName;
                    link.download = fileName;
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }
            } catch(error){
                this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: 'An unexpected error occurred: ' + error,
                variant: 'error',
                mode: 'sticky'
                }));
            }
        });
    }

    populateRecordList() {
        var tempData = [];

        getActivities({
            recordId: this.recordId,
            recordType: this.objectApiName
        }).then(data => {
            var index = 1;
            try {
                console.log('tempData begin!');

                data.forEach(item => {

                    if (item.MSCRM_ID__c != null)
                        item.Id = item.MSCRM_ID__c;

                    item.RecordLink = window.location.origin + '/' + item.Id;

                    item.WhatIdRecordLink = window.location.origin + '/' + item.WhatId;
                    if (item.What != null)
                        item.WhatIdName = item.What.Name;
                    else if (item.ISR_Notes__c != null)
                        item.WhatIdName = item.ISR_Notes__c;
                    if (item.OwnerId != null)
                        item.OwnerIdRecordLink = window.location.origin + '/' + item.OwnerId;

                    if (item.Owner != null)
                        item.OwnerIdName = item.Owner.Name;
                    else if (item.Internal_Notes__c != null)
                        item.OwnerIdName = item.Internal_Notes__c;
                    if (item.Description == null)
                        item.Description = '';
                    if (item.Subject == null)
                        item.Subject = '';

                    if (item.ActivityDate == null)
                        item.ActivityDate = item.LastModifiedDate;

                    item.RecordNumber = index++;
                    tempData.push(item);
                });
                //console.log(data);
            } catch (error) {
                console.log(error);
            }
            //sort by Close Date descending
            // data.sort((a, b) => (a.Number__c > b.Number__c) ? 1 : (a.Number__c === b.Number__c) ? 0 : -1);
            // if (data.length > 0) this.hasData = true;
            //var tempList = JSON.parse(data);    


            getHistoricalActivities({
                recordId: this.recordId
            }).then(result => {

                var tempHistoricalIds = '';
                try {
                    console.log('Retreived historical activities');
                    console.log(result);
                    var results = JSON.parse(result);
                    results.forEach(r => {
                        r.RecordLink = 'javascript:void(0);';
                        r.WhatIdRecordLink = window.location.origin + '/' + r.Id;
                        r.WhatIdName = r.Regarding;
                        r.OwnerIdRecordLink = 'javascript:void(0);';
                        r.OwnerIdName = r.Owner;
                        r.TaskSubtype = r.Type + ' (H)';
                        if (r.Description == null)
                            r.Description = '';
                        // console.log(r.Subject);
                        if (r.Subject == null)
                            r.Subject = '';

                        r.ActivityDate = r.ActualEnd;
                        r.RecordNumber = index++;
                        tempData.push(r);
                        tempHistoricalIds += r.ActivityId + ',';
                    });
                    console.log('do the thing');
                    tempHistoricalIds = tempHistoricalIds.substring(0,tempHistoricalIds.length-1);
                    console.log(tempHistoricalIds);
                } catch (error) {
                    console.log(error);
                }
                if (tempHistoricalIds != '')
                {
                    getActivityAttachmentsById({
                        recordId: tempHistoricalIds
                    }).then(aData => {
                        if (aData != '')
                        {
                            this.allAttachments = JSON.parse(aData);
                            console.log(aData);
                        }
                    });
                }
                this.allActivities = tempData;

                //Update page threshold
                var pages = parseInt(Math.ceil(this.allActivities.length / 10));
                this.maxPage = pages;
                for(var i = 1; i <= pages; i++)
                {
                    this.pageLibrary.push({value: i, label: i});
                }
                this.RecordCount = tempData.length;

                const cloneData = [...this.allActivities];
                cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
                this.allActivities = cloneData;
                this.savedAllActivities = this.allActivities;
                this.handlePopulatePage();

                this.loaded = true;
            });
        });

    }

}