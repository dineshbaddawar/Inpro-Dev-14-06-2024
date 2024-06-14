import {
    LightningElement,
    api,
    track
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import getTeamMembers from '@salesforce/apex/RepBackupHelper.getTeamMembers';
import getFutureUTO from '@salesforce/apex/RepBackupHelper.getFutureUTO';
import getFutureBackups from '@salesforce/apex/RepBackupHelper.getFutureBackups';
import verifyAvailability from '@salesforce/apex/RepBackupHelper.verifyAvailability';
import verifyAvailabilityEdit from '@salesforce/apex/RepBackupHelper.verifyAvailabilityEdit';
import addUTO from '@salesforce/apex/RepBackupHelper.addUTO';
import editUTO from '@salesforce/apex/RepBackupHelper.editUTO';
import deleteUTOList from '@salesforce/apex/RepBackupHelper.deleteUTOList';
import getAvailable from '@salesforce/apex/RepBackupHelper.getAvailable';
import getAvailableByDateList from '@salesforce/apex/RepBackupHelper.getAvailableByDateList';
import getUnavailableByDateList from '@salesforce/apex/RepBackupHelper.getUnavailableByDateList';
import getMarkedBackupsDateRange from '@salesforce/apex/RepBackupHelper.getMarkedBackupsDateRange';
import getMarkedBackupsDateList from '@salesforce/apex/RepBackupHelper.getMarkedBackupsDateList';
import userSearch from '@salesforce/apex/AccountNewOpportunityHelper.UserSearch';
import userId from '@salesforce/user/Id';

export default class RepBackup extends LightningElement {
    @api isDashboard;
    @track currentUserId = userId;
    @track loaded = false;
    @track isViewModal = false;
    @track isBackup = false;
    @track isSelectionActive = false;
    @track isEditSingle = false;
    @track isFind = false;
    @track isEditFind = false;
    @track isDeleteConfirm = false;
    @track isManager = false;
    @track isManagerView = false;
    @track isMarkedBackup = false;
    @track markedBackupData = [];
    @track managerId = '';
    @track managerText = '';
    @track managerUsers = [];
    @track utoData = [];
    @track filteredUtoData = [];
    @track latestUtoData = [];
    @track backupData = [];
    @track backups = [];
    @track unavailableUtoList = [];
    @track filteredUnavailableUtoList = [];
    @track selectedBackup;
    @track selectedBackupUser = Array(0);
    @track secondarySearchTerm;
    @track startDate;
    @track endDate;
    @track currentBackup;
    @track currentDate;
    @track currentUtoId;
    @track searchValue = '';
    @track availableUsers = [];
    @track filteredAvailableUsers = [];
    @track selectedUtoRows = [];
    @track selectedDates = [];
    
    @track userColumns = 
    [ 
        { label: 'Name', fieldName: 'Name',  type: 'text', sortable: true},
        {
            label: 'Action',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'utility:add',
                title: 'Select',
                variant: 'border-filled',
                alternativeText: 'View',
                name: 'selectUser'
            }
          }
    ];
    @track userManagerColumns = 
    [ 
        { label: 'Name', fieldName: 'Name',  type: 'text', sortable: true},
        {
            label: 'Action',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'utility:edit',
                title: 'Select',
                variant: 'border-filled',
                alternativeText: 'View',
                name: 'selectManagedUser'
            }
          }
    ];
    @track utoColumns = 
    [ 
        { label: 'Date', fieldName: 'Date__c',  type: 'date-local', sortable: true},
        { label: 'Backup', fieldName: 'Backup__r',  type: 'text', sortable: true }
    ];
    @track uunavailableColumns = 
    [ 
        { label: 'Date', fieldName: 'Date__c',  type: 'date-local', sortable: true},
        { label: 'User', fieldName: 'User__r',  type: 'text', sortable: true }
    ];
    @track backupColumns = 
    [ 
        { label: 'Date', fieldName: 'Date__c',  type: 'date-local', sortable: true},
        { label: 'Who You\'re Covering', fieldName: 'User__r',  type: 'text', sortable: true }
    ];
    @track editColumns = 
    [ 
        { label: 'Date', fieldName: 'Date__c',  type: 'date-local', sortable: true},
        { label: 'Backup', fieldName: 'Backup__r',  type: 'text', sortable: true },
        {
            label: 'Action',
            type: 'button-icon',
            initialWidth: 75,
            typeAttributes: {
                iconName: 'utility:edit',
                title: 'Open',
                variant: 'border-filled',
                alternativeText: 'View',
                name: 'edit'
            }
        }
    ];
    
    connectedCallback() {
        // initialize component
        if (this.isDashboard == undefined) this.isDashboard = true;
        else this.isDashboard = this.isDashboard == 'true';
        /*if (!this.isDashboard)
        {
            this.isViewModal = true;
        }*/
        getTeamMembers({managerId: this.currentUserId}).then(data => {
            console.log('Manager?');
            console.log(data);
            if (data.length > 0)
            {
                this.isManager = true;
                this.managerId = userId;
                this.managerUsers = data;
            }
            
            this.refreshData();
        });
    };

    /** Component Logic **/

    refreshData()
    {
        getFutureUTO({userId: this.currentUserId}).then(data => {
            data.forEach(x => {
                x.Backup__r = x.Backup__r.Name;
            });
            this.utoData = data;
            this.latestUtoData = data.slice(0,data.length > 5 ? 5 : data.length);

            this.loaded = true;
        });

        getFutureBackups({userId: this.currentUserId}).then(data =>{
            if (data.length > 0)
            {
                data.forEach(x => {
                    x.User__r = x.User__r.Name;
                });
                this.isBackup = true;
                this.backupData = data;
                this.backupData = data.slice(0,data.length > 5 ? 5 : data.length);
            }
        });
    }

    handleInput(event){
        let name = event.target.name;
        let value = event.target.value;
        if (name == 'backups'){
            this.selectedBackup = value;
        }
        else if (name == 'startDate'){
            this.startDate = value;
            if (this.isFind)
            {
                this.handleFindSearch();
            }
        }
        else if (name == 'endDate'){
            this.endDate = value;
            if (this.isFind)
            {
                this.handleFindSearch();
            }
        }
        else if (name == 'userSearch')
        {
            this.searchValue = value;
            this.filterUsers();
        }
    }
    
    filterUsers()
    {
        var tempArray = [];
        this.availableUsers.forEach(x => {
            if (x.Name.toLowerCase().indexOf(this.searchValue.toLowerCase()) != -1)
            {
                tempArray.push(x);
            }
        });
        this.filteredAvailableUsers = tempArray;

        var tempArray2 = [];
        this.unavailableUtoList.forEach(x => {
            if (x.User__r.toLowerCase().indexOf(this.searchValue.toLowerCase()) != -1)
            {
                tempArray2.push(x);
            }
        });
        this.filteredUnavailableUtoList = tempArray2;
    }

    handleSelect(event)
    {
        let selectedRows = event.detail.selectedRows;
        let tempArray = [];
        let dateArray = [];
        this.isSelectionActive = selectedRows.length > 0;
        
        for (let i = 0; i < selectedRows.length; i++) {
            tempArray.push(selectedRows[i].Id);
            dateArray.push(selectedRows[i].Date__c);
        }
        this.filteredUtoData = selectedRows;
        this.selectedUtoRows = tempArray;
        this.selectedDates = dateArray;
    }

    handleClearSelection(event)
    {
        this.selectedBackupUser = Array(0);
        this.selectedUtoRows = [];
        this.selectedDates = [];
        this.isSelectionActive = false;
    }

    handleRowAction( event ) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'edit':
                this.isEditSingle = true;
                this.currentBackup = row.Backup__r;
                this.currentDate = this.parseDate(row.Date__c);
                console.log(this.currentDate);
                this.currentUtoId = row.Id;
                let params = {
                    userId: this.currentUserId,
                    startDate: this.currentDate,
                    isTeam: 'false'
                }
                this.loaded = false;
                
                getAvailable(params).then(data => {
                    console.log(data);
                    this.availableUsers = data;
                    this.filteredAvailableUsers = data;
                    this.loaded = true;
                });
                let params2 = {
                    userId: this.currentUserId,
                    dates: [this.currentDate]
                }
                getUnavailableByDateList(params2).then(data => {
                    console.log(data);
                    data.forEach(x => {
                        x.User__r = x.User__r.Name;
                    });
                    this.unavailableUtoList = data;
                    this.filteredUnavailableUtoList = data;
                });

                let params3 = {
                    userId: this.currentUserId,
                    dates: [this.currentDate]
                }
                getMarkedBackupsDateList(params3).then(data => {
                    if (data.length > 0)
                    {
                        this.isMarkedBackup = true;
                        data.forEach(x => {
                            x.User__r = x.User__r.Name;
                        });
                        this.markedBackupData = data;
                    }
                    else
                    {
                        this.isMarkedBackup = false;
                        this.markedBackupData = [];
                    }
                });
                break;
            case 'selectUser':
                this.selectedBackupUser = Array(0);
                this.selectedBackupUser = {
                    title: row.Name,
                    id: row.Id,
                    subTitle: row.Name
                };
                this.selectedBackup = row.Id;
                break;
            case 'selectManagedUser':
                this.currentUserId = row.Id;
                this.isManager = false;
                this.isManagerView = true;
                this.managerText = '(as ' + row.Name + ')';
                this.loaded = false;
                this.refreshData();
                break;
            default:
        }
    }

    handleManagerClose(event)
    {
        this.isManager = true;
        this.currentUserId = this.managerId;
        this.isManagerView = false;
        this.managerText = '';
        this.loaded = false;
        this.refreshData();
    }

    handleUpdate(event)
    {
        let dates = [];
        let backups = [];
        let utoIds = [];

        if (this.isEditSingle)
        {
            dates.push(this.currentDate);
            backups.push(this.selectedBackup);
            utoIds.push(this.currentUtoId);
        }
        else
        {
            for (var i = 0; i < this.selectedUtoRows.length; i++) {
                
                backups.push(this.selectedBackup);
                dates.push(this.parseDate(this.selectedDates[i]));
                utoIds.push(this.selectedUtoRows[i]);
            }
    
        }
        
        let params = {
            userId: this.currentUserId,
            backups: backups,
            dates: dates
        };
        console.log(params);

        if (this.selectedBackup == undefined || this.selectedBackup == '')
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Must select backup.',
                variant: 'error'
            }));

            return;
        }
        else if (this.selectedBackup == this.currentUserId)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'You cannot select yourself as your backup.',
                variant: 'error'
            }));
            return;
        }

        this.loaded = false;
        verifyAvailabilityEdit(params).then(messages =>{
            console.log('Verify complete');
            console.log(messages);

            if (messages.length > 0)
            {
                this.loaded = true;
                let message = '';
                messages.forEach(x =>{
                    message += x + '; ';
                })
                message = message.substring(0, message.length-2) + '.';

                this.dispatchEvent(new ShowToastEvent({
                    title: 'UTO Availability Error',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                }));
            }
            else
            {
                let params2 = {
                    userId: this.currentUserId,
                    utoIds: utoIds,
                    backups: backups,
                    dates: dates
                };
                editUTO(params2).then(data =>{
                    if (data == '')
                    {
                        this.isEditSingle = false;
                        this.isEditFind = false;
                        this.selectedBackupUser = Array(0);
                        this.selectedUtoRows = [];
                        this.selectedDates = [];
                        this.isSelectionActive = false;
                        this.refreshData();
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'UTO Backup row(s) have been updated.',
                            variant: 'success'
                        }));
                    }
                    else
                    {
                        this.loaded = true;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Server Error',
                            message: data,
                            variant: 'error',
                            mode: 'sticky'
                        }));
                    }
                });
            }
        });
    }

    parseDate(dateStr)
    {
        let d = new Date(Date.parse(dateStr));
        d.setDate(d.getDate() + 1);
        let month = (d.getMonth()+1 < 10 ? ('0' + (d.getMonth()+1)) : d.getMonth() + 1);
        let day = (d.getDate() < 10 ? ('0' + d.getDate()) : d.getDate()) ;
        let year = d.getFullYear();
        let temp =  month + '/' + day + '/'+ year;
        console.log(temp);
        return temp;
    }

    handleDelete(event)
    {
        this.isDeleteConfirm = true;
    }

    handleDeleteConfirm(event)
    {
        var tempArray = [];
        this.selectedUtoRows.forEach(x =>{
            tempArray.push(x);
        });
        let params = {utoIdList: tempArray};
        console.log(params);
        this.loaded = false;
        deleteUTOList(params).then(data=>{
            if (data == '')
            {
                this.isDeleteConfirm = false;
                this.refreshData();
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'UTO Backup row(s) have been deleted.',
                    variant: 'success'
                }));
            }
            else
            {
                this.loaded = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Server Error',
                    message: data,
                    variant: 'error',
                    mode: 'sticky'
                }));
            }
        });
    }
    
    handleLookupSelectionChange(event) {
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        const target = event.target;
        console.log(target);
        var name = '';

        if (selection.length > 0) {
            this.tempInt = 1;
            name = selection[0].title;
            var id = selection[0].id;
            var subTitle = selection[0].subtitle;
            console.log(name);
            console.log(id);
            console.log(subTitle);
            
            this.selectedBackup = id;
            this.selectedBackupUser = selection[0];
        }
    }
    
    /** CRUD Actions **/

    handleUserSearch(event) {
        const target = event.target;
        console.log(event.detail);
        userSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting accounts: " + error);
            });
    }

    handleFindSearch(event)
    {
        console.log('Start find');
        if (this.startDate == undefined || this.endDate == undefined)
        {
            return;
        }

        let startDate = new Date(Date.parse(this.startDate));
        startDate.setDate(startDate.getDate() + 1);
        startDate.setHours(0,0,0,0);
        let endDate = new Date(Date.parse(this.endDate));
        endDate.setDate(endDate.getDate() + 1);
        endDate.setHours(0,0,0,0);
        let today =  new Date(Date.now());
        today.setHours(0,0,0,0);
        if (endDate < startDate)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Start Date must be before End Date.',
                variant: 'error'
            }));
            return;
        }
        if (startDate < today)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Start Date must be today or in the future.',
                variant: 'error'
            }));
            return;
        }
        
        console.log('Start search');
        this.loaded = false;
        let params = {
            userId: this.currentUserId,
            startDate: this.parseDate(this.startDate),
            endDate: this.parseDate(this.endDate),
            isTeam: 'false'
        }
        console.log(params);
        getAvailable(params).then(data => {
            console.log(data);
            this.availableUsers = data;
            this.filteredAvailableUsers = data;
            
            let dates = [];
            startDate = new Date(this.startDate);
            endDate = new Date(Date.parse(this.endDate));
            for (var d = startDate; d <= endDate; d.setDate(d.getDate() + 1)) {
                dates.push(this.parseDate(d));
            }
            let params2 = {
                userId: this.currentUserId,
                dates: dates
            }
            getUnavailableByDateList(params2).then(data2 => {
                console.log(data2);
                data2.forEach(x => {
                    x.User__r = x.User__r.Name;
                });
                this.unavailableUtoList = data2;
                this.filteredUnavailableUtoList = data2;
                this.filterUsers();
                this.loaded = true;
            });

            let params3 = {
                userId: this.currentUserId,
                dates: dates
            }
            getMarkedBackupsDateList(params3).then(data => {
                if (data.length > 0)
                {
                    this.isMarkedBackup = true;
                    data.forEach(x => {
                        x.User__r = x.User__r.Name;
                    });
                    this.markedBackupData = data;
                }
                else
                {
                    this.isMarkedBackup = false;
                    this.markedBackupData = [];
                }
            });
        });

        
    }

    handleAdd(event)
    {
        console.log('Verify first');

        var params = {
            userId: this.currentUserId,
            backupId: this.selectedBackup,
            startDate: this.startDate,
            endDate: this.endDate
        };
        console.log(params);

        let startDate = new Date(Date.parse(this.startDate));
        startDate.setDate(startDate.getDate() + 1);
        startDate.setHours(0,0,0,0);
        let endDate = new Date(Date.parse(this.endDate));
        endDate.setDate(endDate.getDate() + 1);
        endDate.setHours(0,0,0,0);
        let today =  new Date(Date.now());
        today.setHours(0,0,0,0);

        if (this.startDate == undefined || this.endDate == undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Must select both start and end dates.',
                variant: 'error'
            }));
            return;
        }
        if (endDate < startDate)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Start Date must be before End Date.',
                variant: 'error'
            }));
            return;
        }
        else if (startDate < today)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Start Date must be today or in the future.',
                variant: 'error'
            }));
            return;
        }
        else if (this.selectedBackup == undefined || this.selectedBackup == '')
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'Must select backup.',
                variant: 'error'
            }));
            return;
        }
        else if (this.selectedBackup == this.currentUserId)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Input Error',
                message: 'You cannot select yourself as your backup.',
                variant: 'error'
            }));
            return;
        }

        this.loaded = false;
        verifyAvailability(params).then(messages =>{
            console.log('Verify complete');
            console.log(messages);

            if (messages.length > 0)
            {
                this.loaded = true;
                let message = '';
                messages.forEach(x =>{
                    message += x + '; ';
                })
                message = message.substring(0, message.length-2) + '.';

                this.dispatchEvent(new ShowToastEvent({
                    title: 'UTO Availability Error',
                    message: message,
                    variant: 'error',
                    mode: 'sticky'
                }));
            }
            else
            {
                let dates = [];
                let backups = [];
                console.log(this.startDate);
                let startDate = new Date(this.startDate);
                startDate.setDate(startDate.getDate() + 1);
                let endDate = new Date(Date.parse(this.endDate));
                endDate.setDate(endDate.getDate() + 1);
                for (var d = startDate; d <= endDate; d.setDate(d.getDate() + 1)) {
                    let temp = (d.getMonth()+1) + '/' + (d.getDate()) +'/'+ d.getFullYear();
                    console.log(temp);
                    backups.push(this.selectedBackup);
                    dates.push(temp);
                }
                let params2 = {
                    userId: this.currentUserId,
                    backups: backups,
                    dates: dates
                };
                addUTO(params2).then(data =>{
                    if (data == '')
                    {
                        this.selectedBackupUser = Array(0);
                        this.isFind = false;
                        this.refreshData();
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'UTO Backup row(s) have been added.',
                            variant: 'success',
                        }));
                    }
                    else
                    {
                        this.loaded = true;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Server Error',
                            message: data,
                            variant: 'error',
                            mode: 'sticky'
                        }));
                    }
                });
            }
        });
    }

    /** Screen Logic **/

    handleGoToUKG()
    {
        window.open('https://inpro.ultipro.com/', '_blank');
    }

    handleEditFind(event)
    {
        this.selectedBackupUser = Array(0);
        this.isEditFind = true;
        this.loaded = false;
        let params = {
            userId: this.currentUserId,
            dates: this.selectedDates
        }
        getAvailableByDateList(params).then(data => {
            console.log(data);
            this.availableUsers = data;
            this.filteredAvailableUsers = data;
            this.loaded = true;
        });
        let params2 = {
            userId: this.currentUserId,
            dates: this.selectedDates
        }
        getUnavailableByDateList(params2).then(data => {
            console.log(data);
            data.forEach(x => {
                x.User__r = x.User__r.Name;
            });
            this.unavailableUtoList = data;
            this.filteredUnavailableUtoList = data;
        });
        let params3 = {
            userId: this.currentUserId,
            dates: this.selectedDates
        }
        getMarkedBackupsDateList(params3).then(data => {
            if (data.length > 0)
            {
                this.isMarkedBackup = true;
                data.forEach(x => {
                    x.User__r = x.User__r.Name;
                });
                this.markedBackupData = data;
            }
            else
            {
                this.isMarkedBackup = false;
                this.markedBackupData = [];
            }
        });
    }
    
    handleOpenModal(event)
    {
        this.isViewModal = true;
    }
    
    handleEditStart(event)
    {
        this.isViewModal = false;
        this.isEditModal = true;
    }

    handleCloseEdit(event)
    {
        this.isEditModal = false;
        this.isViewModal = true;
        this.clearSelections();
    }

    handleCloseEditSingle(event)
    {
        this.isEditSingle = false;
        this.clearSelections();
    }

    handleFind(event)
    {
        this.selectedBackupUser = Array(0);
        this.isFind = true;
    }

    handleEditFindClose(event)
    {
        this.isEditFind = false;
        this.clearSelections();
    }

    handleFindClose(event)
    {
        this.isFind = false;
        this.clearSelections();
    }

    handleClose(event)
    {
        if (!this.isDashboard)
        {
            setTimeout(
                function() {
                    window.history.back();
                },
                1000
            );
        }
        this.isViewModal = false;
        this.clearSelections();
    }

    handleDeleteClose(event)
    {
        this.isDeleteConfirm = false;
    }

    clearSelections()
    {
        this.searchValue = '';
        this.isMarkedBackup = false;
        this.markedBackupData = [];
        this.selectedBackupUser = Array(0);
        this.filteredAvailableUsers = [];
        this.availableUsers = [];
        this.unavailableUtoList = [];
        this.filteredUnavailableUtoList = [];
        this.startDate = undefined;
        this.endDate = undefined;
        this.selectedBackup = undefined;
    }
}