import {
    LightningElement,
    api,
    track
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import FillTree from '@salesforce/apex/TDMHelper.FillTree';
import FillListFolders from '@salesforce/apex/TDMHelper.FillListFolders';
import FillListSubFolders from '@salesforce/apex/TDMHelper.FillListSubFolders';
import FillList2SubFolders from '@salesforce/apex/TDMHelper.FillList2SubFolders';
import FillList3SubFolders from '@salesforce/apex/TDMHelper.FillList3SubFolders';
import FillList4SubFolders from '@salesforce/apex/TDMHelper.FillList4SubFolders';
import FillList5SubFolders from '@salesforce/apex/TDMHelper.FillList5SubFolders';
import getPdfPortalCategories from '@salesforce/apex/TDMHelper.getPdfPortalCategories';
import getSeries from '@salesforce/apex/TDMHelper.getSeries';
import getCategories from '@salesforce/apex/TDMHelper.getCategories';
import getFiles from '@salesforce/apex/TDMHelper.getFiles';
import createPublishSets from '@salesforce/apex/TDMHelper.createPublishSets';
import getOrphanedPublishSets from '@salesforce/apex/TDMHelper.getOrphanedPublishSets';
import updatePublishSets from '@salesforce/apex/TDMHelper.updatePublishSets';
import approveRevision from '@salesforce/apex/TDMHelper.approveRevision';
import publishInproInsiderDocuments from '@salesforce/apex/TDMHelper.publishInproInsiderDocuments';
import publishWebsiteDocuments from '@salesforce/apex/TDMHelper.publishWebsiteDocuments';
import hasExperlogixPublishSet from '@salesforce/apex/TDMHelper.hasExperlogixPublishSet';


export default class TdmPublishingWizard extends LightningElement {

    @api recordId;
    @track loaded = false;
    @track theRecord = {};
    folderLocations = [];
    selectedItemValue;
    sharepointLocation = '';
    items = [];
    sharepointUrl = '';
    fileName;
    fileList = [];
    publistSetId = 0;
    currentFiles = [];
    mainForm = true;
    chooseLocation = false;
    inproInsiderLocation = false;
    pdfPortalLocation = false;
    websiteLocation = false;
    experlogixLocation = false;
    pdfPortalCategoryList = [];
    pdfPortalCategory;
    seriesList = [];
    categoryList = [];
    allSeriesList = [];
    allCategoryList = [];
    WebsiteFriendlyName = '';
    fileSelection = false;
    showError = false;
    publishSetList = [];
    orphanedPublishSetList = [];
    fileDropDownList = [];
    hasOrphanedPulishSets = false;
    mapOrphanedPublishSets = false;
    selectedFile = '';
    missingOrphanedMapping = false;
    errorMessage = '';
    @track containsExperlogixPublishSet = false;

    columns = [{
        label: 'Name',
        fieldName: 'Name'
    }, ];

    publishSetColumns = [{
        label: 'Location Name',
        fieldName: 'Name'
    }, {
        label: 'Description',
        fieldName: 'Description'
    }, {
        label: 'File',
        fieldName: 'FileName'
    }];

    fileColumns = [{
        label: 'Name',
        fieldName: 'Name'
    }, {
        label: 'Suggested Location',
        fieldName: 'Suggested_Publish_Location__c'
    }];

    orphanColumns = [{
        label: 'Location Name',
        fieldName: 'Location__c'
    }, {
        label: 'Url',
        fieldName: 'SharePoint_Site_Url__c'
    }, {
        label: 'Category',
        fieldName: 'PdfPortalName'
    },
    {
        label: 'File',
        fieldName: 'FileName'
    }];

    checkExperlogixPublishSet() {
        hasExperlogixPublishSet(
            {
               documentId: this.recordId
            }
        ).then(results => {
            console.log("has exp pubset: " +results);
            this.containsExperlogixPublishSet = results;
           
        }).catch(error => {
            console.log(error);
        });
    }

    handleMapFile(event)
    {
        var psGrid = this.template.querySelector('[data-id="orphanGrid"]');
        var selectedPS = psGrid.getSelectedRows();
        var file = this.fileList.filter(x=> {
            return x.Id == this.selectedFile;
        })[0];
        selectedPS.forEach(x=>{
            x.FileId = this.selectedFile;
            x.FileName = file.Name;
        });
        this.orphanedPublishSetList = [...this.orphanedPublishSetList];
        console.log(this.orphanedPublishSetList);
        
    }

    handleCancelMapOrphans(event) {
        this.mainForm = true;
        this.mapOrphanedPublishSets = false;
    }

    handleOrphanFinish(event) {
        console.log('finish');
        console.log(this.orphanedPublishSetList);
        var tempArray = [];
        this.orphanedPublishSetList.forEach(x => {

            var ps = {Id:x.Id};
            if(x.FileId != null 
                && x.FileId != '')
            {            
                ps.Technical_Document_File__c = x.FileId;
                ps.Status__c = 'Active';
                //ps.Revision_Date__c = 
            }
            else
            {
                ps.Status__c = 'Inactive';
            }

            tempArray.push(ps);            
        });

        this.loaded = false;
        
        updatePublishSets({
            publishSets: tempArray
        }).then(data => {
            this.loaded = true;
            this.hasOrphanedPulishSets = false;
            this.mapOrphanedPublishSets = false;    
            this.missingOrphanedMapping = false;
            this.mainForm = true;
            console.log(data);
        }).catch(error => {
            console.log(error);
        });

        
    }

    handleValidateOrphanFinish(event)
    {        
        var file = this.orphanedPublishSetList.filter(x =>{
                return x.FileId == null
            })[0];

        if(file != null)
        {
           this.missingOrphanedMapping = true;
        }
        else
            this.handleOrphanFinish();
    }

    handleShowOrphanYes(event) {
        this.mapOrphanedPublishSets = true;
        this.hasOrphanedPulishSets = false;
    }

    handleShowOrphanNo(event) {
        this.hasOrphanedPulishSets = false;
        this.mainForm = true;
    }

    loadOrphanedPublishSets() {
        getOrphanedPublishSets({
            documentId: this.recordId
        }).then(results => 
            {
            console.log(this.recordId);
            console.log(results);

            if (results != null) 
            {
                results.forEach(x => 
                {
                    if (x.Technical_Document_PDF_Portal_Category__c != null)
                        x.PdfPortalName = x.Technical_Document_PDF_Portal_Category__r.Name;
                });

                if(results.length > 0)
                {
                    this.orphanedPublishSetList = results;
                    this.hasOrphanedPulishSets = true;
                    this.mainForm = false;
                }
            }
            this.loaded = true;
        }).catch(error => {
            console.log(error);
        });
    }

    handleCreatePublishSets(event) {
        try {
            this.loaded = false;
            var pSets = [];
            if(this.publishSetList.length > 0)
            {
            this.publishSetList.forEach(ps => {
                var pubSet = {};
                pubSet.DocumentId = this.recordId;
                pubSet.Location = ps.Name;
                pubSet.SharePointSiteUrl = ps.SharepointURL;
                pubSet.TechnicalDocumentFile = ps.FileId;
                pubSet.WebFriendlyName = ps.WebsiteFriendlyName;
                pubSet.Status = 'Active';
                pubSet.TechnicalDocumentPDFPortalCategory = ps.pdfPortalCategory;

                var series = '';
                if (ps.WebsiteSeries != null && ps.WebsiteSeries.length > 0)
                    series = ps.WebsiteSeries.join(',');
                pubSet.Series = series;

                var categories = '';
                if (ps.WebsiteCategories != null && ps.WebsiteCategories.length > 0)
                    categories = ps.WebsiteCategories.join(',');
                pubSet.Categories = categories;
                pSets.push(pubSet);
            });
            console.log(JSON.stringify(pSets[0]));
            
            createPublishSets({
                publishSets: pSets
            }).then(data => {
                this.toast("Publish Sets Created");                
                this.handPublishingDocuments();
                console.log(data);
            }).catch(error => {
                console.log(error);
            });
        }
        else{
            approveRevision({
                recordId: this.recordId
            }).then(data => {                
                this.toast("Revision Approved");                
                this.handPublishingDocuments();
                console.log(data);
            }).catch(error => {
                console.log(error);
            });
        }
        } catch (error) {
            console.log(error);
        }
    }

    handPublishingDocuments()
    {
        publishInproInsiderDocuments({
            documentId: this.recordId
        }).then(data => {
            this.loaded = true;
            if(data.includes('error'))
            {
                this.errorMessage = data;
                this.showError = true;
            }
            else{            
            console.log(data);            
            publishWebsiteDocuments({
                documentId: this.recordId
            }).then(data => {
                this.loaded = true;
                if(data.includes('error'))
                {
                    this.errorMessage = data;
                    this.showError = true;
                }
                else{
                this.toast("Publish Complete");
                window.location.reload();
                console.log(data);   
                
                }
            }).catch(error => {
                console.log(error);
            }); 


            }
        }).catch(error => {
            console.log(error);
        });    
    }

    handleErrorMessageBack(event)
    {
        this.showError = false;
        this.publishSetList = [];
    }

    handleAddPublishSet(event) {
        this.mainForm = false;
        this.fileSelection = true;
    }

    connectedCallback() {
        this.checkExperlogixPublishSet();
        this.loadTree();
        this.loadPdfPortalCategories();
        this.loadCategories();
        this.loadSeries();
        this.loadFiles();
        this.loadOrphanedPublishSets();
        this.mainForm = true;
    }

    loadTree() {
        FillTree().then(results => {
            console.log(results);
            var parsed = JSON.parse(results);
            var tempItems = [];
            parsed.Location.forEach(x => {
                try {
                    this.folderLocations = [...this.folderLocations, x];
                    var item = {
                        label: x.ListTitle,
                        name: x.ListTitle,
                        disabled: false,
                        expanded: true,
                        items: [],
                    };
                    tempItems.push(item);
                } catch (error) {
                    console.log(error);
                }
            });
            this.items = tempItems;
        }).catch(error => {
            console.log(error);
        });
    }

    FillListFolder(l) {
        try {

            console.log('fill list folders');
            var location = {
                ListTitle: l.ListTitle
            }
            FillListFolders({
                location: location
            }).then(results => {
                // console.log(results);
                var parsed = JSON.parse(results);
                var tempItems = [];
                parsed.Location.forEach(x => {
                    try {
                        this.folderLocations = [...this.folderLocations, x];
                        var item = {
                            label: x.FolderName,
                            name: x.FolderName,
                            disabled: false,
                            expanded: true,
                            items: [],
                        };
                        tempItems.push(item);
                    } catch (error) {
                        console.log(error);
                    }
                });
                var tItems = this.items;
                console.log(l.ListTitle);
                //var output = tItems.filter(x => x.items.every(y => y.name.includes(l.ListTitle)));
                var output = tItems.filter(x => {
                    return x.name == l.ListTitle
                })[0];
                console.log(output);
                output.items = tempItems;
                this.items = [...tItems];

            }).catch(error => {
                console.log(error);
            });
        } catch (error) {
            console.log(error);
        }
    }

    FillListSubFolder(l) {
        try {

            console.log('subfolder');

            var location = {
                ListTitle: l.ListTitle,
                FolderName: l.FolderName,
                SubFolderName: l.SubFolderName
            }

            FillListSubFolders({
                location: location
            }).then(results => {
                // console.log(results);
                var parsed = JSON.parse(results);
                var tempItems = [];
                parsed.Location.forEach(x => {
                    try {
                        this.folderLocations = [...this.folderLocations, x];

                        var name = '';

                        if (x.Type_x == 'SubFolder')
                            name = x.SubFolderName;
                        else if (x.Type_x == 'SubFolder2')
                            name = x.SubFolderName2;

                        var item = {
                            label: name,
                            name: name,
                            disabled: false,
                            expanded: true,
                            items: [],
                        };
                        tempItems.push(item);
                    } catch (error) {
                        console.log(error);
                    }
                });
                var tItems = this.items;
                console.log(this.selectedItemValue);
                // var output = tItems.filter(x => {
                //     return x.items.every(y => y.name.includes(l.FolderName))
                // });
                var output =
                    this.findNode(this.selectedItemValue, tItems);
                // tItems.map((x) => x.items)
                // .flat()
                // .find((y) => y.name === this.selectedItemValue);

                console.log(output);
                output.items = tempItems;
                this.items = [...tItems];

            }).catch(error => {
                console.log(error);
            });
        } catch (error) {
            console.log(error);
        }
    }

    FillList2SubFolder(l) {
        try {

            console.log('subfolder2');

            var location = {
                ListTitle: l.ListTitle,
                FolderName: l.FolderName,
                SubFolderName: l.SubFolderName,
                SubFolderName2: l.SubFolderName2,
                SubFolderName3: l.SubFolderName3,
                SubFolderName4: l.SubFolderName4
            }

            console.log(location);

            FillList2SubFolders({
                location: location
            }).then(results => {
                console.log(results);
                var parsed = JSON.parse(results);
                var tempItems = [];
                parsed.Location.forEach(x => {
                    try {
                        this.folderLocations = [...this.folderLocations, x];

                        var name = '';

                        if (x.Type_x == 'SubFolder2')
                            name = x.SubFolderName3;
                        else if (x.Type_x == 'SubFolder3')
                            name = x.SubFolderName4;

                        var item = {
                            label: name,
                            name: name,
                            disabled: false,
                            expanded: true,
                            items: [],
                        };
                        tempItems.push(item);
                    } catch (error) {
                        console.log(error);
                    }
                });
                var tItems = this.items;
                console.log(l.FolderName);
                // var output = tItems.filter(x => {
                //     return x.items.every(y => y.name.includes(l.FolderName))
                // });
                var output =
                    this.findNode(this.selectedItemValue, tItems);

                console.log(output);
                output.items = tempItems;
                this.items = [...tItems];

            }).catch(error => {
                console.log(error);
            });
        } catch (error) {
            console.log(error);
        }
    }

    FillList3SubFolder(l) {
        try {

            console.log('subfolder3');

            var location = {
                ListTitle: l.ListTitle,
                FolderName: l.FolderName,
                SubFolderName: l.SubFolderName,
                SubFolderName2: l.SubFolderName2,
                SubFolderName3: l.SubFolderName3,
                SubFolderName4: l.SubFolderName4,
                SubFolderName5: l.SubFolderName5
            }

            FillList3SubFolders({
                location: location
            }).then(results => {
                // console.log(results);
                var parsed = JSON.parse(results);
                var tempItems = [];
                parsed.Location.forEach(x => {
                    try {
                        this.folderLocations = [...this.folderLocations, x];

                        var name = '';

                        if (x.Type_x == 'SubFolder3')
                            name = x.SubFolderName5;
                        else if (x.Type_x == 'SubFolder4')
                            name = x.SubFolderName6;

                        var item = {
                            label: name,
                            name: name,
                            disabled: false,
                            expanded: true,
                            items: [],
                        };
                        tempItems.push(item);
                    } catch (error) {
                        console.log(error);
                    }
                });
                var tItems = this.items;
                console.log(l.FolderName);
                // var output = tItems.filter(x => {
                //     return x.items.every(y => y.name.includes(l.FolderName))
                // });
                var output =
                    this.findNode(this.selectedItemValue, tItems);

                console.log(output);
                output.items = tempItems;
                this.items = [...tItems];

            }).catch(error => {
                console.log(error);
            });
        } catch (error) {
            console.log(error);
        }
    }

    FillList4SubFolder(l) {
        try {

            console.log('subfolder4');

            var location = {
                ListTitle: l.ListTitle,
                FolderName: l.FolderName,
                SubFolderName: l.SubFolderName,
                SubFolderName2: l.SubFolderName2,
                SubFolderName3: l.SubFolderName3,
                SubFolderName4: l.SubFolderName4,
                SubFolderName5: l.SubFolderName5,
                SubFolderName6: l.SubFolderName6,
                SubFolderName7: l.SubFolderName7
            }

            FillList4SubFolders({
                location: location
            }).then(results => {
                // console.log(results);
                var parsed = JSON.parse(results);
                var tempItems = [];
                parsed.Location.forEach(x => {
                    try {
                        this.folderLocations = [...this.folderLocations, x];

                        var name = '';

                        if (x.Type_x == 'SubFolder4')
                            name = x.SubFolderName7;
                        else if (x.Type_x == 'SubFolder5')
                            name = x.SubFolderName8;

                        var item = {
                            label: name,
                            name: name,
                            disabled: false,
                            expanded: true,
                            items: [],
                        };
                        tempItems.push(item);
                    } catch (error) {
                        console.log(error);
                    }
                });
                var tItems = this.items;
                console.log(l.FolderName);
                // var output = tItems.filter(x => {
                //     return x.items.every(y => y.name.includes(l.FolderName))
                // });
                var output =
                    this.findNode(this.selectedItemValue, tItems);

                console.log(output);
                output.items = tempItems;
                this.items = [...tItems];

            }).catch(error => {
                console.log(error);
            });
        } catch (error) {
            console.log(error);
        }
    }

    FillList5SubFolder(l) {
        try {

            console.log('subfolder5');

            var location = {
                ListTitle: l.ListTitle,
                FolderName: l.FolderName,
                SubFolderName: l.SubFolderName,
                SubFolderName2: l.SubFolderName2,
                SubFolderName3: l.SubFolderName3,
                SubFolderName4: l.SubFolderName4,
                SubFolderName5: l.SubFolderName5,
                SubFolderName6: l.SubFolderName6,
                SubFolderName7: l.SubFolderName7,
                SubFolderName8: l.SubFolderName8,
                SubFolderName9: l.SubFolderName9,
                SubFolderName10: l.SubFolderName10
            }

            FillList5SubFolders({
                location: location
            }).then(results => {
                // console.log(results);
                var parsed = JSON.parse(results);
                var tempItems = [];
                parsed.Location.forEach(x => {
                    try {

                        this.folderLocations = [...this.folderLocations, x];
                        var name = '';

                        if (x.Type_x == 'SubFolder5')
                            name = x.SubFolderName9;
                        else if (x.Type_x == 'SubFolder6')
                            name = x.SubFolderName10;

                        var item = {
                            label: name,
                            name: name,
                            disabled: false,
                            expanded: true,
                            items: [],
                        };
                        tempItems.push(item);
                    } catch (error) {
                        console.log(error);
                    }
                });
                var tItems = this.items;
                console.log(l.FolderName);
                // var output = tItems.filter(x => {
                //     return x.items.every(y => y.name.includes(l.FolderName))
                // });
                var output =
                    this.findNode(this.selectedItemValue, tItems);

                console.log(output);
                output.items = tempItems;
                this.items = [...tItems];

            }).catch(error => {
                console.log(error);
            });
        } catch (error) {
            console.log(error);
        }
    }

    handleOnselect(event) {
        try {
            this.selectedItemValue = event.detail.name;
            console.log(event.detail.name);

            var location = this.folderLocations.filter(x => {
                return x.ListTitle == this.selectedItemValue && x.Type_x == 'List'
            })[0];

            var location2 = this.folderLocations.filter(x => {
                return x.FolderName == this.selectedItemValue && x.Type_x == 'Folder'
            })[0];

            var location3 = this.folderLocations.filter(x => {
                return x.SubFolderName == this.selectedItemValue && x.Type_x == 'SubFolder'
            })[0];

            var location4 = this.folderLocations.filter(x => {
                return (x.SubFolderName2 == this.selectedItemValue || x.SubFolderName3 == this.selectedItemValue) &&
                    x.Type_x == 'SubFolder2'
            })[0];
            var location5 = this.folderLocations.filter(x => {
                return (x.SubFolderName4 == this.selectedItemValue || x.SubFolderName5 == this.selectedItemValue) &&
                    x.Type_x == 'SubFolder3'
            })[0];
            var location6 = this.folderLocations.filter(x => {
                return (x.SubFolderName6 == this.selectedItemValue || x.SubFolderName7 == this.selectedItemValue) &&
                    x.Type_x == 'SubFolder4'
            })[0];
            var location7 = this.folderLocations.filter(x => {
                return (x.SubFolderName8 == this.selectedItemValue || x.SubFolderName9 == this.selectedItemValue) &&
                    x.Type_x == 'SubFolder5'
            })[0];

            if (location != null) {
                console.log(location);
                this.sharepointLocation = location.ListTitle;
                this.FillListFolder(location);
            } else if (location2 != null) {
                this.sharepointLocation = location2.FolderRelativeUrl;
                console.log(location2);
                this.FillListSubFolder(location2);
            } else if (location3 != null) {
                this.sharepointLocation = location3.SubFolderRelativeUrl;
                console.log(location3);
                this.FillListSubFolder(location3);
            } else if (location4 != null) {
                this.sharepointLocation = location4.SubFolderRelativeUrl3 ?? location4.SubFolderRelativeUrl2;
                console.log(location4);
                this.FillList2SubFolder(location4);
            } else if (location5 != null) {
                this.sharepointLocation = location5.SubFolderRelativeUrl4 ?? location5.SubFolderRelativeUrl5;
                console.log(location5);
                this.FillList3SubFolder(location5);
            } else if (location6 != null) {
                this.sharepointLocation = location6.SubFolderRelativeUrl6 ?? location6.SubFolderRelativeUrl7;
                console.log(location6);
                this.FillList4SubFolder(location6);
            } else if (location7 != null) {
                this.sharepointLocation = location7.SubFolderRelativeUrl8 ?? location7.SubFolderRelativeUrl9;
                console.log(location7);
                this.FillList5SubFolder(location7);
            }

        } catch (error) {
            console.log(error);
        }
    }

    findNode(name, items) {
        for (const node of items) {
            if (node.name === name) return node;
            if (node.items) {
                const child = this.findNode(name, node.items);
                if (child) return child;
            }
        }
    }

    isValidId(idStr) {
        const regex = RegExp('\\w{15,18}');
        const match = regex.test(idStr);
        return match;
    }

    handleInputUpdate(event) {
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.value);
        console.log(event.target.name);
        if (event.target.name == 'PdfPortalCategory') {
            this.pdfPortalCategory = event.target.value;
        } else if (event.target.name == 'WebsiteFriendlyName') {
            this.WebsiteFriendlyName = event.target.value;
        } else if(event.target.name == 'selectedFile')
        {
            this.selectedFile = event.target.value;
        }
    }

    loadSeries() {
        getSeries().then(results => {

            this.seriesList = results;
            this.allSeriesList = results;
        }).catch(error => {
            console.log(error);
        });
    }

    loadCategories() {
        getCategories().then(results => {
            this.categoryList = results;
            this.allCategoryList = results;

        }).catch(error => {
            console.log(error);
        });
    }

    loadFiles() {
        getFiles({
            recordId: this.recordId
        }).then(results => {
            this.fileList = results;
            var tempArray = [];
            this.fileList.forEach(x=>{                                    
                    tempArray.push({
                        value: x.Id,
                        label: x.Name
                    });
                });
                this.fileDropDownList = tempArray;
            this.loaded = true;
        }).catch(error => {
            console.log(error);
        });
    }

    loadPdfPortalCategories() {
        getPdfPortalCategories().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.Id,
                    label: x.Name
                });
            });
            this.pdfPortalCategoryList = tempArray;
        }).catch(error => {
            console.log(error);
        });
    }

    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }

    updateSpecifiedUrl(event) {
        this.sharepointUrl = event.target.value;
        console.log(this.sharepointUrl);
    }

    handleSpecifyUrl(event) {
        this.specifyURL(this.sharepointUrl);
    }

    specifyURL(url) {
        try {
            let decoded = decodeURIComponent(url);
            console.log(decoded);
            if (decoded.includes("RootFolder")) {
                this.sharepointLocation = this.getParameterByName("RootFolder", url);
            } else {
                this.sharepointLocation = this.getParameterByName("id", url);
            }
            console.log(this.sharepointLocation);
        } catch (error) {
            console.log(error);
        }
    }

    getParameterByName(name, url) {
        var url = new URL(url);
        return url.searchParams.get(name);
    }

    pickLocation(event) {
        try {
            var fileGrid = this.template.querySelector('[data-id="fileGrid"]');
            var selectedFiles = fileGrid.getSelectedRows();
            console.log(JSON.stringify(selectedFiles));
            var tempArray = [];
            selectedFiles.forEach(x => {
                tempArray.push(x.Id);
            });
            this.currentFiles = tempArray;
            console.log(this.currentFiles);
            this.chooseLocation = true;
            this.fileSelection = false;
            this.mainForm = false;
        } catch (error) {
            console.log(error);
        }
    }

    handleLocationSelection(event) {
        var choice = event.target.name;
        if (choice == 'InproInsider')
            this.inproInsiderLocation = true;
        if (choice == 'PDFPortal')
            this.pdfPortalLocation = true;
        if (choice == 'Website')
            this.websiteLocation = true;
        if (choice == 'Experlogix') {
            this.experlogixLocation = true;

            var files = this.fileList.filter(({
                Id
            }) => this.currentFiles.includes(Id));
            console.log(files);
            files.forEach(file => {
                var ps = {};
                ps.Name = 'Experlogix';
                ps.Description = 'Experlogix';
                ps.FileName = file.Name;
                ps.FileId = file.Id;
                ps.Id = this.publistSetId++;
                ps.Experlogix = true;
                console.log(ps);
                this.publishSetList = [...this.publishSetList, ps];
            });
            this.mainForm = true;
        }

        this.chooseLocation = false;
    }

    finishSharepointSelection(event) {
        try {
            var files = this.fileList.filter(({
                Id
            }) => this.currentFiles.includes(Id));
            console.log(files);
            files.forEach(file => {
                var ps = {};
                ps.SharepointURL = this.sharepointLocation;
                ps.Name = 'Inpro Insider';
                ps.Description = this.sharepointLocation;
                ps.FileName = file.Name;
                ps.FileId = file.Id;
                ps.Id = this.publistSetId++;
                console.log(ps);
                this.publishSetList = [...this.publishSetList, ps];
            });

            console.log(this.publishSetList);
            this.inproInsiderLocation = false;
            this.mainForm = true;
        } catch (error) {
            console.log(error);
        }
    }

    finishPDFPortalSelection(event) {

        var name = this.pdfPortalCategoryList.filter(x => {
            return x.value == this.pdfPortalCategory
        })[0].label;
        var files = this.fileList.filter(({
            Id
        }) => this.currentFiles.includes(Id));
        console.log(files);
        files.forEach(file => {
            var ps = {};
            ps.pdfPortalCategory = this.pdfPortalCategory;
            ps.Name = 'PDF Portal';
            ps.Description = name;
            ps.FileName = file.Name;
            ps.FileId = file.Id;
            ps.Id = this.publistSetId++;
            console.log(ps);
            this.publishSetList = [...this.publishSetList, ps];
        });
        console.log(this.publishSetList);
        this.pdfPortalLocation = false;
        this.mainForm = true;
    }

    cancelSelection(event) {
        this.inproInsiderLocation = false;
        this.pdfPortalLocation = false;
        this.websiteLocation = false;
        this.experlogixLocation = false;
        this.chooseLocation = false;
        this.fileSelection = false;
        this.mainForm = true;
    }

    finishWebsiteSelection(event) {
        //var el = this.template.querySelector('lightning-datatable');
        var categoryGrid = this.template.querySelector('[data-id="categoryGrid"]');
        var seriesGrid = this.template.querySelector('[data-id="seriesGrid"]');
        var selectedCategories = categoryGrid.getSelectedRows();
        var selectedSeries = seriesGrid.getSelectedRows();
        var names = '';
        var tempSeries = [];
        var tempCategories = [];
        if (selectedCategories != null)
            selectedCategories.forEach(x => {
                names += x.Name + ' ';
                tempCategories.push(x.Id);
            });

        if (selectedSeries != null)
            selectedSeries.forEach(x => {
                names += x.Name + ' ';
                tempSeries.push(x.Id);
            });

        var files = this.fileList.filter(({
            Id
        }) => this.currentFiles.includes(Id));
        console.log(files);
        files.forEach(file => {
            var ps = {};
            ps.WebsiteSeries = tempSeries;
            ps.WebsiteCategories = tempCategories;
            ps.WebsiteFriendlyName = this.WebsiteFriendlyName;
            ps.Name = 'Website';
            ps.Description = names;
            ps.FileName = file.Name;
            ps.FileId = file.Id;
            ps.Id = this.publistSetId++;
            console.log(ps);
            this.publishSetList = [...this.publishSetList, ps];
        });
        console.log(this.publishSetList);
        console.log(selectedCategories);
        console.log(selectedSeries);

        this.websiteLocation = false;
        this.mainForm = true;
    }

}