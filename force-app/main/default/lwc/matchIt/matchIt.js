import {
    LightningElement,
    api,
    track,
    wire,
} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getRows from '@salesforce/apex/MatchItHelper.getRows';
import getResult from '@salesforce/apex/MatchItHelper.getResult';
import saveResults from '@salesforce/apex/MatchItHelper.saveResults';
import renameResultName from '@salesforce/apex/MatchItHelper.renameResultName';
import getPreviousResults from '@salesforce/apex/MatchItHelper.getPreviousResults';
import getResultsJson from '@salesforce/apex/MatchItHelper.getResultsJson';
import updateResultsJson from '@salesforce/apex/MatchItHelper.updateResultsJson';
import deleteAccountMatchResult from '@salesforce/apex/MatchItHelper.deleteAccountMatchResult';
import deleteAllAccountMatchResults from '@salesforce/apex/MatchItHelper.deleteAllAccountMatchResults';
import userId from '@salesforce/user/Id';
import isDebugUser from '@salesforce/apex/MatchItHelper.isDebugUser';

export default class MatchIt extends LightningElement {
    @api recordId;
    @track loaded = false;
    @track comparisonLoaded = false;
    @track previousResultsLoaded = false;
    @track loadMessage = 'Loading...';
    @track records = [];
    @track searchRecords = [];
    @track pagedRecords = [];
    @track pageCount = 1;
    @track pageSize = 25;
    @track pageSizeStyle10 = 'brand-outline';
    @track pageSizeStyle25 = 'brand';
    @track pageSizeStyle50 = 'brand-outline';
    @track pageSizeStyle100 = 'brand-outline';
    @track minScoreStyle0 = 'brand';
    @track minScoreStyle50 = 'brand-outline';
    @track minScoreStyle70 = 'brand-outline';
    @track minScoreStyle100 = 'brand-outline';
    @track pageCurrent = 1;
    @track fileId = '';
    @track searchValue = '';
    @track minScoreValue = 0;
    @track apexCount = 0;
    @track resultsLibrary = [];
    @track selectedResult;
    @track currentResult = '';
    @track currentResultName = '';
    @track previousResultSelected = false;
    @track sortLabel = 'RowId';
    @track sortDir = "asc"
    @track sortLast = null;
    @track currentSort = { Column: "RowId", Direction: "asc"};
    @track deleteIsActive = false;
    @track deleteText = '';
    @track startTime;
    @track endTime;
    @track index = 0;
    @track rowCount;
    @track saveText = '';
    @track saveIsActive = false;
    @track tempCurrentResult;
    @track loadResultsIsActive = false;
    @track renameIsActive = false;
    @track loadedResultName = '';
    @track isDeleteAll = false;

    @track debugResults = [];
    @track debugColumns = [
        {label: 'Name',fieldName: 'A'},
        {label: 'Address',fieldName: 'B'},
        {label: 'City',fieldName: 'C'},
        {label: 'Zip',fieldName: 'D'},
        {label: 'Membership Id',fieldName: 'E'},
    ]
    @track accountColumns = [
        {label: 'Name',fieldName: 'Name'},
        {label: 'Street',fieldName: 'ShippingStreet'},
        {label: 'City',fieldName: 'ShippingCity'},
        {label: 'Zip',fieldName: 'ShippingPostalCode'},
    ];
    handleLoadResults = function(){
        this.loadResultsIsActive = true;
    }

    handleLoadCancel = function(){
        this.loadResultsIsActive = false;
    }

    handleRename = function(event){
        const value = event.target.value;
        this.tempCurrentResult = value;
        this.currentResult = value;
        this.currentResultName = this.resultsLibrary.filter(x => { return x.File_Id__c == value})[0].Upload_Name__c;
        this.loadResultsIsActive = false;
        this.renameIsActive = true;
    }

    handleRenameCancel = function(){
        this.currentResultName = this.tempCurrentResult;
        this.renameIsActive = false;
        this.loadResultsIsActive = true;
       
    }

    handleRenameSave = function(){
        let params = {
            fileId: this.currentResult,
            name: this.currentResultName
        }

        this.loaded = false;
        renameResultName(params).then(data => {
            this.buildResultsLibrary(this.currentResult);
            this.renameIsActive = false;
            this.loadResultsIsActive = true;
        }).catch(error => this.handleError(error));
    }

    handleSaveCancel = function(){
        this.saveIsActive = false;
    };

    handleNoSaveConfirm = function(){
        this.hasChanges = false;
        this.saveIsActive = false;
        this.handleResultsChange({ target: { value: this.tempCurrentResult}});
    }

    handleSaveConfirm = function(event){
        this.hasChanges = false;
        this.saveIsActive = false;
        
        let params = {
            resultId: this.currentResult,
            resultsJson: JSON.stringify(this.records)
        }

        console.log(params);
        this.loaded = false;
        updateResultsJson(params).then(newFileId =>{
            let tempList = [];
            this.resultsLibrary.forEach(x => {
                if (x.value == this.currentResult)
                {
                    x.value = newFileId;
                }
                tempList.push(x);
            });
            this.resultsLibrary = tempList;
            this.currentResult = newFileId;
            this.hasChanges = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Result file updated.',
                variant: 'success',
            }));
            this.handleResultsChange({ target: { value: this.tempCurrentResult}});
        });
    };

    handleResultsChange = function(event){
        console.log(event);
        const value = event.target.value;
        this.currentResult = value;
        

        if (this.hasChanges)
        {
            this.saveIsActive = true;
            this.saveText = 'You have unsaved changes for ' + this.currentResultName +
                            '. Save changes?';
            return;
        }

        this.currentResultName = this.resultsLibrary.filter(x => { return x.File_Id__c == value})[0].Upload_Name__c;
        this.tempCurrentResult = value;

        this.loadedResultName = this.currentResultName;

        this.loaded = false;
        this.loadResultsIsActive = false;
        this.loadMessage = 'Loading previous results...';
        getResultsJson({fileId: this.currentResult}).then(data => {
            console.log(JSON.parse(data));
            this.records = JSON.parse(data);
            this.errors = [];
            this.hasErrors = this.records.filter(x => { return x.HasError != undefined && x.HasError == true}).length > 0;
            let tempIndex = 1;
            this.records.forEach(x => {
                x.AccountLink = window.location.protocol + '//' + window.location.host + '/lightning/r/' + x.MatchedAccountId + '/view';
                x.ParentAccountLink = window.location.protocol + '//' + window.location.host + '/lightning/r/' + x.MatchedParentAccountId + '/view';
            });
            this.searchRecords = this.records;
            this.pageCurrent = 1;
            this.searchValue = '';
            this.previousResultSelected = true;
            this.handleSortPopulate();
            this.handleSearch();
        }).catch(error => this.handleError(error));
    };

    handleDelete = function(event){
        const value = event.target.value;
        this.tempCurrentResult = this.currentResultName;
        this.currentResult = value;
        this.currentResultName = this.resultsLibrary.filter(x => { return x.File_Id__c == value})[0].Upload_Name__c;
        this.loadResultsIsActive = false;
        this.deleteIsActive = true;
        this.deleteText = 'Are you sure you want to delete your previous result \'' + this.currentResultName + '\'?';
    };

    
    handleDeleteAll = function(event){
        this.loadResultsIsActive = false;
        this.deleteIsActive = true;
        this.isDeleteAll = true;
        this.deleteText = 'Are you sure you want to delete all your previous records?';
    }

    handleOpenRecord = function(event){
        console.log('handleOpenRecord');
        const recordId = event.target.value;

        window.open(window.location.protocol + '//' + window.location.host + '/lightning/r/' + recordId + '/view','_blank');
    };

    renderedCallback(){
        this.template.querySelectorAll('.btn-header').forEach(x => {
            console.log(x);
            x.style.whiteSpace = 'nowrap !important';
        });
    }

    handleDeleteConfirm = function(){
        this.deleteIsActive = false;
        this.loaded = false;
        this.loadMessage = 'Deleting results...';
        if (this.isDeleteAll)
        {
            this.isDeleteAll = false;
            deleteAllAccountMatchResults().then(data => {
                this.records = [];
                this.searchRecords = [];
                this.handleSearch();
                this.buildResultsLibrary();
                this.currentResultName = this.tempCurrentResult;
                this.loadResultsIsActive = true;
                this.loadMessage = 'Loading...';
            }).catch(error => this.handleError(error));
        }
        else
        {   
            deleteAccountMatchResult({fileId: this.currentResult}).then(data => {
                this.records = [];
                this.searchRecords = [];
                this.handleSearch();
                this.buildResultsLibrary();
                this.currentResultName = this.tempCurrentResult;
                this.loadResultsIsActive = true;
                this.loadMessage = 'Loading...';
            }).catch(error => this.handleError(error));
        }
    };

    handleDeleteCancel = function(){
        this.currentResultName = this.tempCurrentResult;
        this.deleteIsActive = false;
        this.loadResultsIsActive = true;
        this.isDeleteAll = false;
    };

    getComputationTime = function(date1,date2)
    {
        var difference = date1.getTime() - date2.getTime();

        var daysDifference = Math.floor(difference/1000/60/60/24);
        difference -= daysDifference*1000*60*60*24

        var hoursDifference = Math.floor(difference/1000/60/60);
        difference -= hoursDifference*1000*60*60

        var minutesDifference = Math.floor(difference/1000/60);
        difference -= minutesDifference*1000*60

        var secondsDifference = Math.floor(difference/1000);

        return minutesDifference + 'm ' + 
                secondsDifference + 's';
    }

    @track enableDebug = false;
    connectedCallback(){
        isDebugUser({userId: userId}).then(data => {
            console.log('Is user system admin? ' + data);
            if (data == true)
            {
                this.enableDebug = true;
            }
        })
        this.buildResultsLibrary();
    };

    buildResultsLibrary = function(selection) {
        this.previousResultsLoaded = false;
        this.resultsLibrary = [];
        getPreviousResults().then(data => {
            console.log(data);
            this.resultsLibrary = data;
            if (selection != undefined)
            {
                this.currentResult = selection;
                this.currentResultName = this.resultsLibrary.filter(x => { return x.File_Id__c == selection})[0].Upload_Name__c;
                this.loadedResultName = this.currentResultName;
                this.previousResultSelected = true;
            }
            else
            {
                this.currentResult = '';
                this.previousResultSelected = false;
            }
            this.previousResultsLoaded = true;
            this.loaded = true;
        }).catch(error => this.handleError(error));
    };

    buildPageLibrary = function() {
        console.log('buildPageLibrary');

        this.pageCurrent = 1;
        let pages = parseInt(Math.ceil(this.searchRecords.length / this.pageSize))
        this.pageCount = pages == 0 ? 1 : pages;
        this.pageLibrary = [];
        for (var i = 1; i <= pages; i++)
        {
            this.pageLibrary.push({value: i, label: i});
        }
    };

    populatePage = function() {
        console.log('populatePage');
        this.loaded = false;
        this.pagedRecords = [];
        let temp = [];
        let firstIndex = ((parseInt(this.pageCurrent)-1)*this.pageSize);
        let lastIndex = (((parseInt(this.pageCurrent))*this.pageSize));
        if (lastIndex > this.searchRecords.length) lastIndex = this.searchRecords.length;
        for(var i = firstIndex; i < lastIndex; i++)
        {
            temp.push(this.searchRecords[i]);
        }
        this.pagedRecords = temp;
        this.loaded = true;
    }

    handleSearch = function(event) {
        if (event != undefined)
        {
            this.searchValue = event.target.value;
        }
        
        this.searchRecords = this.records.filter(x => {
            return ((x.Name != undefined && x.Name.toLowerCase().includes(this.searchValue.toLowerCase())) || 
                   (x.Address != undefined && x.Address.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.Zip != undefined && x.Zip.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.Phone != undefined && x.Phone.toLowerCase().includes(this.searchValue.toLowerCase())) || 
                   (x.MembershipId != undefined && x.MembershipId.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.MatchedName != undefined && x.MatchedName.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.MatchedAddress != undefined && x.MatchedAddress.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.MatchedZip != undefined && x.MatchedZip.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.MatchedPhone != undefined && x.MatchedPhone.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                   (x.AccountNumber != undefined && x.AccountNumber.toLowerCase().includes(this.searchValue.toLowerCase()))) &&
                   (x.MatchScore >= this.minScoreValue);
        });

        //Update page threshold
        this.buildPageLibrary();
        this.populatePage();
    };

    handlePageChange = function(event){
        console.log('handlePageChange');
        const name = event.target.name;

        if (name == 'Next')
        {
            var nextPage = parseInt(this.pageCurrent) + 1;
            if (nextPage <= parseInt(this.pageCount))
            {
                this.pageCurrent = nextPage.toString();
                this.populatePage();
            }
        }
        else if (name == 'Back')
        {
            var lastPage = parseInt(this.pageCurrent) - 1;
            if (lastPage >= 1)
            {
                this.pageCurrent = lastPage.toString();
                this.populatePage();
            }
        }
        else
        {
            const value = event.target.value;
            this.pageCurrent = value;
            this.populatePage();
        }
    };

    handlePageSizeChange = function(event){
        const name = event.target.name;
        this.pageSize = parseInt(name);
        this.pageSizeStyle10 = this.pageSize == 10 ? 'brand' : 'brand-outline';
        this.pageSizeStyle25 = this.pageSize == 25 ? 'brand' : 'brand-outline';
        this.pageSizeStyle50 = this.pageSize == 50 ? 'brand' : 'brand-outline';
        this.pageSizeStyle100 = this.pageSize == 100 ? 'brand' : 'brand-outline';
        this.handleSearch();
        this.buildPageLibrary();
        this.populatePage();
    }

    handleMinScoreChange = function(event){
        const name = event.target.name;
        this.minScoreValue = parseInt(name);
        this.minScoreStyle0 = this.minScoreValue == 0 ? 'brand' : 'brand-outline';
        this.minScoreStyle50 = this.minScoreValue == 50 ? 'brand' : 'brand-outline';
        this.minScoreStyle70 = this.minScoreValue == 70 ? 'brand' : 'brand-outline';
        this.minScoreStyle90 = this.minScoreValue == 90 ? 'brand' : 'brand-outline';
        this.handleSearch();
    }

    handle

    handleProcessRow = function(rows, i, uploadedFiles, debug)
    {
        if (this.apexCount == 7)
        {
            setTimeout(function(){
                this.handleProcessRow(rows,i,uploadedFiles, debug);
            }.bind(this),50);
        }
        else
        {
            let params3 = {
                row: rows[i], 
                index: (i + 1),
                nameIndex: this.nameIndex,
                addressIndex: this.addressIndex,
                zipIndex: this.zipIndex,
                cityIndex: this.cityIndex,
                membershipIndex: this.membershipIndex,
                parentAccountIndex: this.parentAccountIndex,
                startDateIndex: this.startDateIndex,
                accountDebug: debug
            };

            console.log(params3);
            this.apexCount++;
            getResult(params3).then(data => {
                if (debug == true)
                {
                    console.log(data);
                    this.index++;
                    this.loadMessage = 'Parsing row ' + (this.index + 1) + '/' + this.rowCount + '...';
                    this.apexCount--;
                    let result = JSON.parse(data);
                    let tempArray = [];
                    for(var z = 0; z < result.length; z++)
                    {
                        tempArray.push(result[z]);
                    }
                    let strArray = params3.row.split(',');
                    let inputObj = {
                        Id: i,
                        A: strArray[0],
                        B: strArray[1],
                        C: strArray[2],
                        D: strArray[3],
                        E: strArray[4],
                    }
                    let tempObj = {
                        id: i,
                        input: [inputObj],
                        results: tempArray
                    }

                    let tempArray2 = this.debugResults;
                    tempArray2.push(tempObj);
                    this.debugResults = tempArray2;

                    console.log(this.debugResults);
                    this.loaded = true;
                }
                else
                {
                    console.log(data);
                    this.index++;
                    this.loadMessage = 'Parsing row ' + (this.index + 1) + '/' + this.rowCount + '...';
                    this.apexCount--;
                    let result = JSON.parse(data);
                    result.AccountLink = window.location.protocol + '//' + window.location.host + '/lightning/r/' + result.MatchedAccountId + '/view';
                    result.ParentAccountLink = window.location.protocol + '//' + window.location.host + '/lightning/r/' + result.MatchedParentAccountId + '/view';
                    result.HasError = false;
                    this.records.push(result);
                    this.handleProcessRowComplete(rows, i, uploadedFiles);
                }
                
            }).catch(error => {
                //console.log(error);
                this.index++;
                this.apexCount--;
                this.errors.push({index: params3.index, params: JSON.stringify(params3), message: error.body.message});
                this.records.push({
                    RowId: params3.index, 
                    params: JSON.stringify(params3),
                     message: error.body.message, 
                     HasError: true, MatchScore: 0,
                     Name: ''
                });
                this.hasErrors = true;
                this.handleProcessRowComplete(rows, i, uploadedFiles);
            });
        }
    }

    handleProcessRowComplete = function(rows, i, uploadedFiles){
        if (this.apexCount == 0 && this.index == (this.rowCount - 1))
        {
            this.endTime = new Date();
            let timeDifference = this.getComputationTime(this.endTime, this.startTime);

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Results took ' + timeDifference + ' to complete.',
                variant: 'success'
            }));

            let params2 = {
                fileId: uploadedFiles[0].documentId,
                resultsJson: JSON.stringify(this.records)
            };

            saveResults(params2).then(data2 => {
                this.loaded = true;
                this.searchRecords = this.records;
                this.handleSortPopulate();
                this.buildResultsLibrary(data2);
                this.handleSearch();
            }).catch(error => this.handleError(error));
        }
    };

    @track hasErrors = false;
    @track errors = [];
    @track uploadedFiles;
    @track uploadIsActive = false;
    @track rows;
    @track nameIndex = -1;
    @track addressIndex = -1;
    @track zipIndex = -1;
    @track cityIndex = -1;
    @track membershipIndex = -1;
    @track parentAccountIndex = -1;
    @track startDateIndex = -1;
    @track tempColumns = [];
    @track tempColumnsLength = 6;

    handleUploadFinished = function(event){
        this.records = [];
        this.uploadedFiles = event.detail.files;

        this.loaded = false;

        let params = {
            fileId: this.uploadedFiles[0].documentId
        };

        console.log(params);

        getRows(params).then(rowData => {
            this.rows = JSON.parse(rowData);
            this.loadMessage = 'Parsing ' + (this.rows.length - 1) + ' results...';
            this.startTime = new Date();
            this.rowCount = this.rows.length;
            this.index = 0;
            console.log(this.rows[0]);
            this.nameIndex = this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('name'));
            this.addressIndex = this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('address') || x.includes('street'));
            this.cityIndex = this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('city'));
            this.zipIndex = this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('zip') || x.includes('post'));
            this.membershipIndex = this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('member'));
            this.parentAccountIndex =  this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('parent'));
            this.startDateIndex =  this.rows[0].toLowerCase().split(',').findIndex(x => x.includes('date') || x.includes('start'));
            this.buildTempColumns();
            this.uploadIsActive = true;
        }).catch(error => this.handleError(error));
    }
    
    buildTempColumns(){
        this.tempColumns = [];
        let columns = [];
        if (this.nameIndex > -1) columns.push({ Id: this.nameIndex, Name: 'Name' });
        if (this.addressIndex > -1) columns.push({ Id: this.addressIndex, Name: 'Address' });
        if (this.cityIndex > -1) columns.push({ Id: this.cityIndex, Name: 'City' });
        if (this.zipIndex > -1) columns.push({ Id: this.zipIndex, Name: 'Zip' });
        if (this.membershipIndex > -1) columns.push({ Id: this.membershipIndex, Name: 'Membership Id' });
        if (this.parentAccountIndex > -1) columns.push({ Id: this.parentAccountIndex, Name: 'Parent Account' });
        if (this.startDateIndex > -1) columns.push({ Id: this.startDateIndex, Name: 'Start Date' });

        for(var i = 0; i <= Math.max(...columns.map(o => o.Id)); i++)
        {
            //get column if it exists
            let j = columns.filter(x => {return x.Id == i;});
            if (j.length > 0)
            {
                this.tempColumns.push(j[0])
            }
            else //push fake column if it doesn't
            {
                this.tempColumns.push({Id: i, Name: '<?>'});
            }
        }
        this.tempColumnsLength = this.tempColumns.length;
        this.tempColumns.sort((a,b) => {if (a.Id < b.Id) return -1; if (a.Id > b.Id) return 1; return 0;});
    }
    @track debugAccounts = false;

    handleDebugCancel(){
        this.debugAccounts = false;
        this.debugResults = [];
    }

    handleUploadConfirmDebug(){
        this.errors = [];
        this.hasErrors = false;
        this.uploadIsActive = false;
        this.debugAccounts = true;
        for(var i = 1; i < this.rows.length; i++)
        {
            this.handleProcessRow(this.rows,i,this.uploadedFiles, true);
        }
    }
    handleUploadConfirm(){
        this.errors = [];
        this.hasErrors = false;
        this.debugAccounts = false;
        this.uploadIsActive = false;
        for(var i = 1; i < this.rows.length; i++)
        {
            this.handleProcessRow(this.rows,i,this.uploadedFiles, false);
        }
    }

    handleUploadCancel(){
        this.uploadIsActive = false;
        this.loaded = true;
    }

    handleSort = function(event){
        console.log('handleSort');
        let column = event.target.dataset.id;
        this.sortLabel = column;
        console.log(this.sortLabel);
        if (this.currentSort.Column == column && this.currentSort.Direction == "asc")
        { //descending sort
            this.handleSortDesc();
            event.target.iconName = "utility:chevrondown";
            //Remove chevron from last column if column changed
            if (this.sortLast != null && this.sortLast.dataset.id != column) this.sortLast.iconName = "";
            this.sortLast = event.target;
        }
        else
        { //ascending sort
            this.handleSortAsc();
            event.target.iconName = "utility:chevronup";
            //Remove chevron from last column if column changed
            if (this.sortLast != null && this.sortLast.dataset.id != column) this.sortLast.iconName = "";
            this.sortLast = event.target;
        }
        this.populatePage();
    };

    handleSortPopulate = function(){
        console.log('handleSortPopulate');
        if (this.sortDir == "asc") this.handleSortAsc();
        else this.handleSortDesc();
    };

    handleSortAsc = function(){
        console.log('handleSortAsc');
        if (this.sortLabel == 'CreatedDate')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                var aa = new Date(x[this.sortLabel]),
                    bb = new Date(y[this.sortLabel]);
                return (aa > bb ? 1 : 0);
            });
        }
        else if (this.sortLabel == 'RowId')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return parseInt(x[this.sortLabel]) < parseInt(y[this.sortLabel]) ? -1 : 0;
            });
        }
        else
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return x[this.sortLabel] > y[this.sortLabel] ? 1 :
                        x[this.sortLabel] < y[this.sortLabel] ? -1 : 0
            });
        }
        
        this.currentSort.Column = this.sortLabel;
        this.currentSort.Direction = "asc";
    };
      
    handleSortDesc = function(){
        console.log('handleSortDesc');
        if (this.sortLabel == 'CreatedDate')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                var aa = new Date(x[this.sortLabel]),
                    bb = new Date(y[this.sortLabel]);
                return (aa < bb ? 1 : 0);
            });
        }
        else if (this.sortLabel == 'RowId')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return parseInt(x[this.sortLabel]) > parseInt(y[this.sortLabel]) ? -1 : 0;
            });
        }
        else
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return x[this.sortLabel] > y[this.sortLabel] ? -1 :
                        x[this.sortLabel] < y[this.sortLabel] ? 1 : 0
            });
        }
        
        this.currentSort.Column = this.sortLabel;
        this.currentSort.Direction = "desc";
    };

    handleError = function(error) {
        //console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning',
                mode: 'sticky'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'warning',
                mode: 'sticky'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'warning',
                mode: 'sticky'
            }));
        }
        this.loadMessage = 'Loading...';
        this.loaded = true;
    };

    @track hasChanges = false;

    handleInput = function(event){
        const name = event.target.name;
        const value = event.target.value;

        if (name == 'Add Strike')
        {
            let Id = event.target.accessKey;
            var selectedItem = this.records.filter(item => {
                return item.RowId == Id;
            })[0];
            selectedItem.HasStrike = true;
            selectedItem.Class = 'strike-out';
            this.hasChanges = true;
        }
        else if (name == 'Remove Strike')
        {
            let Id = event.target.accessKey;
            var selectedItem = this.records.filter(item => {
                return item.RowId == Id;
            })[0];
            selectedItem.HasStrike = false;
            selectedItem.Class = '';
            this.hasChanges = true;
        }
        else if (name == 'Note')
        {
            let Id = event.target.accessKey;
            var selectedItem = this.records.filter(item => {
                return item.RowId == Id;
            })[0];
            selectedItem.Note = value;
            this.hasChanges = true;
        }
        else if (name == 'Add Note')
        {
            let Id = event.target.accessKey;
            var selectedItem = this.records.filter(item => {
                return item.RowId == Id;
            })[0];
            selectedItem.HasNote = true;
            this.hasChanges = true;
        }
        else if (name == 'Hide Note')
        {
            let Id = event.target.accessKey;
            var selectedItem = this.records.filter(item => {
                return item.RowId == Id;
            })[0];
            selectedItem.HasNote = false;
            this.hasChanges = true;
        }
        else if (name == 'currentResultName')
        {
            this.currentResultName = value;
        }
        else if (name == 'Name')
        {
            if (value < 0) this.nameIndex = -1;
            else this.nameIndex = value;
            this.buildTempColumns();
        }
        else if (name == 'Address')
        {
            if (value < 0) this.addressIndex = -1;
            else this.addressIndex = value;
            this.buildTempColumns();
        }
        else if (name == 'City')
        {
            if (value < 0) this.cityIndex = -1;
            else this.cityIndex = value;
            this.buildTempColumns();
        }
        else if (name == 'Zip')
        {
            if (value < 0) this.zipIndex = -1;
            else this.zipIndex = value;
            this.buildTempColumns();
        }
        else if (name == 'Membership Id')
        {
            if (value < 0) this.membershipIndex = -1;
            else this.membershipIndex = value;
            this.buildTempColumns();
        }
        else if (name == 'Parent Account')
        {
            if (value < 0) this.parentAccountIndex = -1;
            else this.parentAccountIndex = value;
            this.buildTempColumns();
        }
        else if (name == 'Start Date')
        {
            if (value < 0) this.startDateIndex = -1;
            else this.startDateIndex = value;
            this.buildTempColumns();
        }
    };

    handleSave = function(){
        let params = {
            resultId: this.currentResult,
            resultsJson: JSON.stringify(this.records)
        }

        console.log(params);
        this.loaded = false;
        updateResultsJson(params).then(newFileId =>{
            let tempList = [];
            this.resultsLibrary.forEach(x => {
                if (x.value == this.currentResult)
                {
                    x.value = newFileId;
                }
                tempList.push(x);
            });
            this.resultsLibrary = tempList;
            this.currentResult = newFileId;
            this.hasChanges = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Result file updated.',
                variant: 'success',
            }));
            this.loaded = true;
        });
    }

    handleDownloadCSV = function(event){
        console.log('handleDownloadCSV');
        let value = event.target.value;
        this.currentResultName = this.resultsLibrary.filter(x => { return x.File_Id__c == value})[0].Upload_Name__c;
        this.loadedResultName = this.currentResultName;
        this.loadMessage = 'Downloading result...';
        this.loaded = false;

        getResultsJson({fileId: value}).then(data => {
            console.log(JSON.parse(data));
            this.records = JSON.parse(data);
            this.errors = [];
            this.hasErrors = this.records.filter(x => { return x.HasError != undefined && x.HasError == true}).length > 0;
            this.records.forEach(x => {
                x.AccountLink = window.location.protocol + '//' + window.location.host + '/lightning/r/' + x.MatchedAccountId + '/view';
                x.ParentAccountLink = window.location.protocol + '//' + window.location.host + '/lightning/r/' + x.MatchedParentAccountId + '/view';
            });
            this.searchRecords = this.records;
            this.pageCurrent = 1;
            this.searchValue = '';
            this.previousResultSelected = true;
            this.handleSortPopulate();
            this.handleSearch();

            let csv = 
                'Match Score,Matched Account Number,ACTION,INPRO #,Name,Address,City,Zip,Membership Id,Start Date,Parent Account,'+
                'Matched Account Name,Matched Address,Matched Zip,Matched Phone,Matched Parent Account,Matched GPO Name(s),Matched Membership Id,'+
                'Matched GPO Divisions,Matched GPO Status,Matched Account Link,Parent Account Link\r\n';
            
            this.records.forEach(x => {
                csv += this._replaceBadCSVChars(x.MatchScore,',');
                csv += this._replaceBadCSVChars(x.AccountNumber,',');

                csv += this._replaceBadCSVChars(x.Note,',');
                csv += this._replaceBadCSVChars('',',');

                csv += this._replaceBadCSVChars(x.Name,',');
                csv += this._replaceBadCSVChars(x.Address,',');
                csv += this._replaceBadCSVChars(x.City,',');
                csv += this._replaceBadCSVChars(x.Zip,',');
                csv += this._replaceBadCSVChars(x.MembershipId,',');
                csv += this._replaceBadCSVChars(x.StartDate,',');
                csv += this._replaceBadCSVChars(x.ParentAccount,',');
                
                csv += this._replaceBadCSVChars(x.MatchedName,',');
                csv += this._replaceBadCSVChars(x.MatchedAddress,',');
                csv += this._replaceBadCSVChars(x.MatchedZip,',');
                csv += this._replaceBadCSVChars(x.MatchedPhone,',');
                csv += this._replaceBadCSVChars(x.MatchedParentAccount,',');
                
                csv += this._replaceBadCSVChars(x.MatchedGPOName,',');
                csv += this._replaceBadCSVChars(x.MatchedMembershipId,',');
                csv += this._replaceBadCSVChars(x.MatchedDivisions,',');
                csv += this._replaceBadCSVChars(x.MatchedGPOStatus,',');
                csv += this._replaceBadCSVChars(x.AccountLink,',');
                csv += this._replaceBadCSVChars(x.ParentAccountLink,'\r\n');
            });

            let link = document.createElement('a')
            link.id = 'download-csv-'+Date.now();
            link.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(csv));
            link.setAttribute('download', this.currentResultName + ' Results.csv');
            document.body.appendChild(link);
            document.querySelector('#' + link.id).click();
            this.loaded = true;
        }).catch(error => this.handleError(error));
        
    };

    _replaceBadCSVChars = function(str, suffix)
    {
        return str != undefined ? str.toString().replaceAll(';',' ').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll(',',' ') + suffix : suffix;
    }
}