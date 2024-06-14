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
import uploadFile from '@salesforce/apex/TDMHelper.uploadFile';
import createRevision from '@salesforce/apex/TDMHelper.createRevision';
import uId from '@salesforce/user/Id';
import hasExperlogixPublishSet from '@salesforce/apex/TDMHelper.hasExperlogixPublishSet';


export default class TdmRevisionWizard extends LightningElement {

    @api recordId;
    @track loaded = false;
    @track TypeList = [];
    @track ChangeDetail = '';
    @track Type = '';
    @track theRecord = {};
    @track trashCanId = uId;
    mainForm = true;

    folderLocations = [];
    selectedItemValue;
    sharepointLocation = '';
    items = [];
    sharepointUrl = '';

    fileName;
    fileList = [];
    fileId = 0;
    currentFileId;
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
    showError = false;
    errorMessage = '';
   @track containsExperlogixPublishSet = false;

    columns = [{
        label: 'Name',
        fieldName: 'Name'
    }, ];

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

    connectedCallback() {
        this.checkExperlogixPublishSet();
        this.loadTypeOptions();
        this.loadTree();
        this.loadPdfPortalCategories();
        this.loadCategories();
        this.loadSeries();
        this.loaded = true;
    }

    createRevision(event) {

        console.log('Revision Type: ' + this.Type);
        if(this.Type == null || this.Type === "")
        {
            this.handleError('Fill in Type.');
            return;
        }
        console.log('Change Details: ' + this.ChangeDetail);
        if(this.ChangeDetail == null || this.ChangeDetail === "")
        {
            this.handleError('Fill in ChangeDetail.');
            return;
        }
        if(this.fileList.length == 0)
        {
            this.handleError('Add Files.');
            return;
        }

        this.loaded = false;        

        createRevision({
                documentId: this.recordId,
                type: this.Type,
                changeDetail: this.ChangeDetail
            }).then(data => {
                if (data) {
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);
                    if (this.isValidId(data)) {
                        var counter = 0;
                        this.fileList.forEach(f => {
                            try {

                                uploadFile({
                                    revisionId: data,
                                    fileName: f.FileName,
                                    fileData: f.FileData,
                                    suggestedLocations: f.SuggestedLocations,
                                    sharepointURL: f.SharepointURL,
                                    pdfPortalCategory: f.PdfPortalCategory,
                                    websiteSeries: JSON.stringify(f.WebsiteSeries),
                                    websiteCategories: JSON.stringify(f.WebsiteCategories),
                                    websiteFriendlyName: f.WebsiteFriendlyName
                                }).then(result => {
                                    counter++;
                                    console.log(result);
                                    if(counter == this.fileList.length)
                                    {
                                        this.toast("Revision Submitted Successfully.");
                                        this.closeQuickAction();
                                    }
                                });
                            } catch (error) {
                                this.handleError(error);
                            }
                        });
                    }
                    else
                    {
                        this.handleError(data);
                    }
                } else if (error) {
                    this.handleError(error);
                }
            })
            .catch(error => {
               this.handleError(error);
            });
    }

    handleError(error)
    {
        var errorJson = JSON.stringify(error);
        this.errorMessage = errorJson;
        this.showError = true;        
        console.log(error);
        this.loaded = true;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);        
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
        if (event.target.name == 'ChangeDetail') {
            this.ChangeDetail = event.target.value;
        } else if (event.target.name == 'Type') {
            this.Type = event.target.value;
        } else if (event.target.name == 'PdfPortalCategory') {
            this.pdfPortalCategory = event.target.value;
        } else if (event.target.name == 'WebsiteFriendlyName') {
            this.WebsiteFriendlyName = event.target.value;
        }
    }

    loadSeries() {
        getSeries().then(results => {

            this.seriesList = results;
            this.allSeriesList = results;
        }).catch(error => {
            this.handleError(error);
        });
    }

    loadCategories() {
        getCategories().then(results => {
            this.categoryList = results;
            this.allCategoryList = results;

        }).catch(error => {
            this.handleError(error);
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
           this.handleError(error);
        });
    }

    loadTypeOptions() {
        var tempArray = [];
        tempArray.push({
            value: 'Major',
            label: 'Major'
        });
        tempArray.push({
            value: 'Minor',
            label: 'Minor'
        });
        this.TypeList = tempArray;
    }

    openfileUpload(event) {
        try {

            console.log('file uploaded');
            const file = event.target.files[0]
            var reader = new FileReader()
            reader.readAsDataURL(file)
            this.fileName = file.name;


            reader.onload = () => {
                try {
                    var base64 = reader.result.split(',')[1]
                    console.log(base64);
                    //console.log(this.fileData)   
                    var f = {
                        Id: this.fileId++,
                        FileName: this.fileName,
                        FileData: base64,
                        SuggestedLocations: ''
                    };
                    this.fileList = [...this.fileList, f];
                    console.log(this.fileList);
                } catch (error) {
                    this.handleError(error);
                }
            }
        } catch (error) {
            this.handleError(error);
        }
    }

    handleUploadFinished(event) {
        try {

            // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " + uploadedFiles.length);
        console.log(uploadedFiles[0].documentId + " " + uploadedFiles[0].name);
        var FileId = uploadedFiles[0].documentId;
        var FileName = uploadedFiles[0].name;       

            //console.log(this.fileData)   
            var f = {
                Id: this.fileId++,
                FileName: FileName,
                FileData: FileId,
                SuggestedLocations: ''
            };
            this.fileList = [...this.fileList, f];
            console.log(this.fileList);
        } catch (error) {
            console.log(error);
        }

    }



    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }

    deleteFile(event) {
        console.log("remove: " + event.target.accessKey);
        var id = event.target.accessKey;

        this.fileList = this.fileList.filter(function (f) {
            return f.Id !== id;
        });
    }

    pickLocation(event) {

        this.currentFileId = event.target.accessKey;
        console.log('choose' + this.currentFileId);
        this.chooseLocation = true;
        this.mainForm = false;
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
            var id = this.currentFileId;
            var file = this.fileList.filter(function (f) {
                return f.Id == id;
            })[0];

            if (file.SuggestedLocations != null)
                file.SuggestedLocations = file.SuggestedLocations + " - Experlogix";
            else
                file.SuggestedLocations = "Experlogix";
            file.Experlogix = true;
            this.mainForm = true;
        }

        this.chooseLocation = false;
    }

    finishSharepointSelection(event) {
        try {

            console.log(this.currentFileId);
            var id = this.currentFileId;
            var file = this.fileList.filter(function (f) {
                return f.Id == id;
            })[0];

            if (file.SuggestedLocations != null)
                file.SuggestedLocations = file.SuggestedLocations + " - Inpro Insider: " + this.sharepointLocation;
            else
                file.SuggestedLocations = "Inpro Insider: " + this.sharepointLocation;
            file.SharepointURL = this.sharepointLocation;
            this.inproInsiderLocation = false;
            this.mainForm = true;
        } catch (error) {
            this.handleError(error);
        }
    }

    finishPDFPortalSelection(event) {
        console.log(this.currentFileId);
        var id = this.currentFileId;
        var file = this.fileList.filter(function (f) {
            return f.Id == id;
        })[0];

        var name = this.pdfPortalCategoryList.filter(x => {
            return x.value == this.pdfPortalCategory
        })[0].label;

        if (file.SuggestedLocations != null)
            file.SuggestedLocations = file.SuggestedLocations + " - PDF Portal: " + name;
        else
            file.SuggestedLocations = "PDF Portal: " + name;
        file.PdfPortalCategory = this.pdfPortalCategory;
        console.log(this.pdfPortalCategory);
        this.pdfPortalLocation = false;
        this.mainForm = true;
    }

    cancelSelection(event) {
        this.inproInsiderLocation = false;
        this.pdfPortalLocation = false;
        this.websiteLocation = false;
        this.experlogixLocation = false;
        this.chooseLocation = false;
        this.mainForm = true;
    }

    finishWebsiteSelection(event) {
        console.log(this.currentFileId);
        var id = this.currentFileId;
        var file = this.fileList.filter(function (f) {
            return f.Id == id;
        })[0];

        //var el = this.template.querySelector('lightning-datatable');
        var categoryGrid = this.template.querySelector('[data-id="categoryGrid"]');
        var seriesGrid = this.template.querySelector('[data-id="seriesGrid"]');
        var selectedCategories = categoryGrid.getSelectedRows();
        var selectedSeries = seriesGrid.getSelectedRows();
        var names = '';
        if (selectedCategories != null)
            selectedCategories.forEach(x => {
                names += x.Name + ' ';
            });

        if (selectedSeries != null)
            selectedSeries.forEach(x => {
                names += x.Name + ' ';
            });

        if (file.SuggestedLocations != null)
            file.SuggestedLocations = file.SuggestedLocations + " - Website: " + names;
        else
            file.SuggestedLocations = "Website: " + names;

        console.log(selectedCategories);
        console.log(selectedSeries);
        file.WebsiteSeries = selectedSeries;
        file.WebsiteCategories = selectedCategories;
        file.WebsiteFriendlyName = this.WebsiteFriendlyName;
        this.websiteLocation = false;
        this.mainForm = true;
    }

    handleSearchGrids(event) {
        if (event.target.name == 'searchSeries') {

        } else {

        }
    }

    handleErrorMessageBack(event)
    {
        this.showError = false;
    }

}