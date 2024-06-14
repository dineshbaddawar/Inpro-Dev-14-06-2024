import {
    LightningElement,
    api,
    track,
    wire,
} from 'lwc';

import { publish, MessageContext } from 'lightning/messageService';

export default class Table extends LightningElement {

    @api records;
    @api keyfield;
    @api stickyColumn = -1;
    @api stickyRow = -1;
    @api displayRowNumber = false;
    @api displayRowSelect = false;
    @api columns;
    @api pageSize = 10;
    @api maxPageSize = 100;
    @api resizable = false;
    @api enableUpload = false;
    @api uploadFunction;
    @api selectMultiple = false;
    @api selectText = 'On Selected';
    @api selectFunction;
    @track pageButtons = [];
    @track recordCount;
    @track dataLoaded = false;
    @track searchValue;
    @track searchRecords;
    @track pagedRecords;
    @track maxPage;
    @track pageLibrary = [];
    @track pageCurrent = 1;
    @track sortLabel = 'RowId';
    @track sortDir = "asc"
    @track sortLast = null;
    @track currentSort = { Column: "RowId", Direction: "asc"};
    @track formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });
    @track isSelectActive = false;

    @track enableTopBar = true;
    
    handleUpload = function(){
        debugger;
        console.log(uploadFunction);
        this.uploadFunction();
    }

    handleSelectFunctionCall = function(){
        debugger;
        this.selectFunction(this.records);
    }

    handleRowSelect = function(event){
        debugger;
        const value = event.target.value;
        const checked = event.target.checked;
        
        if (value == 'all')
        {
          this.pagedRecords.forEach(x => { x.Selected = checked; });
        }
        else
        {
          let selected = this.pagedRecords.filter(x => x.Id == value)[0];
          selected.Selected = checked;
        }
    
        let selectedFiles = [];
    
        this.records.forEach(x => { 
          if (x.Selected) { 
            selectedFiles.push(x);
          }
        });
        this.isSelectActive = selectedFiles.length > 0;
        //this.rowSelect(event);
    }

    connectedCallback()
    {
        debugger;
        if (this.enableUpload == undefined) this.enableUpload = false;

        let tempList = [];
        let index = 1;

        if (this.displayRowNumber == true || this.displayRowNumber == "true")
        {
            var newArray = this.columns.slice();
            newArray.unshift({label: '#',fieldName: 'RowId',  type: 'number', sortable: true });
            this.columns = newArray;
        }
        if (this.displayRowSelect == true || this.displayRowSelect == "true")
        {
            var newArray = this.columns.slice();
            newArray.unshift({label: '',fieldName: 'Select',  type: 'select', onclick: this.handleRowSelect, isSelect : true, sortable: false });
            this.columns = newArray;
        }
        
        if (this.pageSize == undefined) this.pageSize = "50";
        if (this.pageSize.toString().toLowerCase() == "all")
        {
            this.enableTopBar = false;
            this.pageSize = 10000;
        }

        if (this.maxPageSize >= 10) this.pageButtons.push("10");
        if (this.maxPageSize >= 25) this.pageButtons.push("25");
        if (this.maxPageSize >= 50) this.pageButtons.push("50");
        if (this.maxPageSize >= 100) this.pageButtons.push("100");
        if (this.maxPageSize >= 250) this.pageButtons.push("250");
        if (this.maxPageSize >= 500) this.pageButtons.push("500");
        
        this.records.forEach(x => {
            let _x = {};

            for(let key of Object.keys(x))
            {
                _x[key] = x[key];
            }
            _x.values = [];
            _x.RowId = index.toString();
            
            this.columns.forEach(y => {
                if (y.type != undefined && y.type == 'url')
                {
                    //test
                    _x.values.push({
                        key: y.fieldName, 
                        url: x[y.fieldName],
                        value : x[y.typeAttributes.label.fieldName], 
                        style: y.dataStyle,
                        isUrl: true,
                        target: y.typeAttributes.target
                    });
                }
                else if (y.type != undefined && y.type == 'currency')
                {
                    _x.values.push({
                        key: y.fieldName, 
                        value : x[y.fieldName] != undefined ? this.formatter.format(x[y.fieldName]) : '', 
                        style: y.dataStyle,
                        isValue : true
                    });
                }
                else if (y.type != undefined && y.type == 'icon')
                {
                    _x.values.push({
                        key: y.fieldName, 
                        value : x[y.fieldName], 
                        style: y.dataStyle,
                        isIcon : true
                    });
                }
                else if (y.type != undefined && y.type == 'select')
                {
                    _x.values.push({
                        key: y.fieldName,
                        style: y.dataStyle,
                        isSelect : true,
                        onclick: this.rowSelect
                    });
                }
                else if (y.type != undefined && y.type == 'action')
                {
                    _x.values.push({
                        key: y.fieldName,
                        style: y.dataStyle,
                        isAction : true,
                        actions: y.actions
                    })
                }
                else if (y.type != undefined && y.type == 'date')
                {
                    var date = new Date(x[y.fieldName]);
                    _x.values.push({
                        key: y.fieldName, 
                        value : x[y.fieldName] != undefined ? (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear() : '', 
                        style: y.dataStyle,
                        isValue : true
                    });
                }
                else if (y.fieldName == 'RowId')
                {
                    _x.values.push({
                        key: y.fieldName, 
                        value : index.toString(), 
                        style: y.dataStyle,
                        isValue : true
                    });
                }
                else
                {
                    _x.values.push({
                        key: y.fieldName, 
                        value : x[y.fieldName], 
                        style: y.dataStyle,
                        isValue : true
                    });
                }
            });

            tempList.push(_x);
            index++;
        });

        this.records = tempList;
        console.log("RecordS:");
        console.log(this.records);
        this.recordCount = this.records.length;
        this.buildPage();

        this.dataLoaded = true;
    };

    @track firstRender = true;
    renderedCallback(){
        debugger;
        this.template.querySelectorAll('.page-size').forEach(x => {
            //console.log(x.name + ' : ' + this.pageSize.toString());
            //console.log(x.name == this.pageSize.toString());
            if (this.pageSize == undefined) this.pageSize = "";

            if (x.name == this.pageSize.toString())
            {
                x.variant = "brand";
            }
            else
            {
                x.variant = "brand-outline";
            }
        });

        if (this.firstRender && (this.resizable == true || this.resizable == "true"))
        {
            this.firstRender = false;
            this.handleResize();
        }
    }

    buildPage = function()
    {
        debugger;
        var pages = parseInt(Math.ceil(this.records.length / this.pageSize));
        this.maxPage = pages == 0 ? 1 : pages;
        this.pageLibrary = [];
        for(var i = 1; i <= pages; i++)
        {
            this.pageLibrary.push({value: i, label: i});
        }
    
        //Refresh table UI
        //let myNode = this.template.querySelector('[data-id="Name"]');
        //myNode.click();
        this.handleSearch();
    };

    handlePopulatePage = function(){
        debugger;
        this.pagedRecords = [];
        var temp = [];
        var firstIndex = ((parseInt(this.currentPage)-1)*this.pageSize);
        var lastIndex = (((parseInt(this.currentPage))*this.pageSize));
        if (lastIndex > this.searchRecords.length) lastIndex = this.searchRecords.length;
        for(var i = firstIndex; i < lastIndex; i++)
        {
            temp.push(this.searchRecords[i]);
        }
        this.pagedRecords = temp;
        
    };

    handlePageChange = function(event){
        debugger;
        const name = event.target.name;

        if (name == 'Next')
        {
            var nextPage = parseInt(this.currentPage) + 1;
            if (nextPage <= parseInt(this.maxPage))
            {
                this.currentPage = nextPage.toString();
                this.handlePopulatePage();
            }
        }
        else if (name == 'Back')
        {
            var lastPage = parseInt(this.currentPage) - 1;
            if (lastPage >= 1)
            {
                this.currentPage = lastPage.toString();
                this.handlePopulatePage();
            }
        }
        else
        {
            const value = event.target.value;
            this.currentPage = value;
            this.handlePopulatePage();
        }
    };

    handleSearch = function(event) {
        debugger;
        let sValue = event != undefined ? event.target.value : '';
        var tempData = this.records.filter(x => {
            let match = false;
            Object.entries(x).forEach(([key, value]) => {
                if (key != 'values' && x[key] != undefined && x[key] != null && x[key].toString().toLowerCase().includes(sValue.toString().toLowerCase()))
                    match = true;
            });
            return match;
        });

        //Update page threshold
        var pages = parseInt(Math.ceil(tempData.length / this.pageSize));
        
        this.maxPage = pages;
        this.pageLibrary = [];
        for(var i = 1; i <= pages; i++)
        {
            this.pageLibrary.push({value: i, label: i});
        }
        
        this.searchRecords = tempData;
        this.currentPage = 1;
        
        if (this.columns.filter(e=>e.fieldName == this.sortLabel)[0] != undefined)
        {
            if (this.currentSort.Direction == "asc") this.handleSortAsc();
            else this.handleSortDesc();
        }
        
        this.handlePopulatePage();
    };

    handleSort = function(event){
        debugger;
        let column = event.target.dataset.id;
        this.sortLabel = column;
        if (this.currentSort.Column == column && this.currentSort.Direction == "asc")
        { //descending sort
            this.handleSortDesc();
            event.target.iconName = "utility:chevrondown";
            //Remove chevron from last column if column changed
            if (this.lastTarget != null && this.lastTarget.dataset.id != column) this.lastTarget.iconName = "";
            this.lastTarget = event.target;
        }
        else
        { //ascending sort
            this.handleSortAsc();
            event.target.iconName = "utility:chevronup";
            //Remove chevron from last column if column changed
            if (this.lastTarget != null && this.lastTarget.dataset.id != column) this.lastTarget.iconName = "";
            this.lastTarget = event.target;
        }
        this.handlePopulatePage();
    };

    handleSortAsc = function(){
        debugger;
        console.log('handleSortAsc');
        console.log(this.sortLabel);

        let currentColumn = this.columns.filter(x => {return x.fieldName == this.sortLabel;})[0];

        if (currentColumn.type == 'date' || currentColumn.type == 'datetime')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                var aa = new Date(x[this.sortLabel]),
                    bb = new Date(y[this.sortLabel]);
                return aa < bb ? -1 : (aa > bb ? 1 : 0);
            });
        }
        else if (this.sortLabel == 'RowId')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return parseInt(x[this.sortLabel]) < parseInt(y[this.sortLabel]) ? -1 : 0;
            });
        }
        else if (currentColumn.type == 'url')
        {
            let displayFieldName = currentColumn.typeAttributes.label.fieldName;
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return x[displayFieldName] > y[displayFieldName] ? 1 :
                        x[displayFieldName] < y[displayFieldName] ? -1 : 0
            });
        }
        else
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return x[this.sortLabel] == undefined || x[this.sortLabel] == '' ? 1 : 
                        y[this.sortLabel] == undefined || y[this.sortLabel] == '' ? -1 : 
                        x[this.sortLabel] > y[this.sortLabel] ? 1 :
                        x[this.sortLabel] < y[this.sortLabel] ? -1 : 0
            });
        }
        
        this.currentSort.Column = this.sortLabel;
        this.currentSort.Direction = "asc";
    };
      
    handleSortDesc = function(){
        debugger;
        console.log('handleSortDesc');
        console.log(this.sortLabel);

        let currentColumn = this.columns.filter(x => {return x.fieldName == this.sortLabel;})[0];

        if (currentColumn.type == 'date' || currentColumn.type == 'datetime')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                var aa = new Date(x[this.sortLabel]),
                    bb = new Date(y[this.sortLabel]);
                return aa >  bb ? -1 : (aa < bb ? 1 : 0);
            });
        }
        else if (this.sortLabel == 'RowId')
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return parseInt(x[this.sortLabel]) > parseInt(y[this.sortLabel]) ? -1 : 0;
            });
        }
        else if (currentColumn.type == 'url')
        {
            let displayFieldName = currentColumn.typeAttributes.label.fieldName;
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return x[displayFieldName] > y[displayFieldName] ? -1 :
                        x[displayFieldName] < y[displayFieldName] ? 1 : 0
            });
        }
        else
        {
            this.searchRecords = this.searchRecords.sort((x,y) => {
                return x[this.sortLabel] == undefined || x[this.sortLabel] == '' ? -1 : 
                        y[this.sortLabel] == undefined || y[this.sortLabel] == '' ? 1 : 
                        x[this.sortLabel] > y[this.sortLabel] ? -1 :
                        x[this.sortLabel] < y[this.sortLabel] ? 1 : 0
            });
        }
        
        this.currentSort.Column = this.sortLabel;
        this.currentSort.Direction = "desc";
    };

    handlePageSizeChange = function(event){
        debugger;
        const name = event.target.name;
        this.pageSize = parseInt(name);
        this.pageCurrent = 1;
        this.template.querySelectorAll('.page-size').forEach(x => {
            console.log(x);
            if (x.name == name)
            {
                x.variant = "brand";
            }
            else
            {
                x.variant = "brand-outline";
            }
        });
        this.buildPage();
    }

    handleSortPopulate = function(){
        debugger;
        if (this.currentSort == "asc") this.handleSortAsc();
        else this.handleSortDesc();
    };

    handleResize = function(){
        debugger;
        var gridtext = '';
        //if (this.displayRowNumber == true || this.displayRowNumber == "true") gridtext += 'minmax(100px, 1fr) ';

        for(var i = 0; i < this.columns.length; i++)
        {
            gridtext += 'minmax(100px, 1.2fr) ';
        } 
       
        // Code By Webdevtrick ( https://webdevtrick.com )
        // Modified by Ben Sibley to use Apex templates
        const min = 50;
        // The max (fr) values for grid-template-columns
        const columnTypeToRatioMap = {
        numeric: 1,
        'text-short': 1.67,
        'text-long': 3.33 };
        
        
        const table = this.template.querySelector('table');
        table.classList.add('resize-table');
        table.style += ';grid-template-columns:' + gridtext;
                                                
        const columns = [];
        let headerBeingResized;

        // Where the magic happens. I.e. when they're actually resizing
        const onMouseMove = e => requestAnimationFrame(() => {
            console.log('onMouseMove');
        
            // Calculate the desired width
            let horizontalScrollOffset = document.documentElement.scrollLeft;
            const width = horizontalScrollOffset + e.clientX - headerBeingResized.offsetLeft;
        
            // Update the column object with the new size value
            const column = columns.find(({ header }) => header === headerBeingResized);
            column.size = Math.max(min, width) + 'px'; // Enforce our minimum
        
            // For the other headers which don't have a set width, fix it to their computed width
            columns.forEach(column => {
            if (column.size.startsWith('minmax')) {// isn't fixed yet (it would be a pixel value otherwise)
                column.size = parseInt(column.header.clientWidth, 10) + 'px';
                console.log(column.size);
            }
            });
        
            /* 
                Update the column sizes
                Reminder: grid-template-columns sets the width for all columns in one value
                */
            table.style.gridTemplateColumns = columns.
            map(({ header, size }) => size).
            join(' ');
        });
        
        // Clean up event listeners, classes, etc.
        const onMouseUp = () => {
            debugger;
            console.log('onMouseUp');
        
            window.removeEventListener('mousemove', onMouseMove);
            window.removeEventListener('mouseup', onMouseUp);
            headerBeingResized.classList.remove('header--being-resized');
            headerBeingResized = null;
        };
        
        // Get ready, they're about to resize
        const initResize = ({ target }) => {
            console.log('initResize');
        
            headerBeingResized = target.parentNode;
            window.addEventListener('mousemove', onMouseMove);
            window.addEventListener('mouseup', onMouseUp);
            headerBeingResized.classList.add('header--being-resized');
        };

        // Let's populate that columns array and add listeners to the resize handles
        this.template.querySelectorAll('th').forEach(header => {
            const max = columnTypeToRatioMap[header.dataset.type] + 'fr';
            columns.push({
            header,
            // The initial size value for grid-template-columns:
            size: `minmax(${min}px, ${max})` });
        
            header.querySelector('.resize-handle').addEventListener('mousedown', initResize);
        });
    }
}