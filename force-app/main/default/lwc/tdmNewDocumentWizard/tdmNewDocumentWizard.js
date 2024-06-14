import {
    LightningElement,
    api,
    track
} from 'lwc';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import UserSearch from '@salesforce/apex/TDMHelper.UserSearch';
import EmployeeSearch from '@salesforce/apex/TDMHelper.EmployeeSearch';
import GetDivisions from '@salesforce/apex/TDMHelper.GetDivisions';
import CampaignSearch from '@salesforce/apex/TDMHelper.CampaignSearch';
import LanguageSearch from '@salesforce/apex/TDMHelper.LanguageSearch';
import GetMarketSegments from '@salesforce/apex/TDMHelper.GetMarketSegments';
import GetRegions from '@salesforce/apex/TDMHelper.GetRegions';
import createDocument from '@salesforce/apex/TDMHelper.createDocument';
import GetDocumentTypes from '@salesforce/apex/TDMHelper.GetDocumentTypes';
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
import getDefaultLanaguage from '@salesforce/apex/TDMHelper.getDefaultLanaguage';
import getDefaultRegion from '@salesforce/apex/TDMHelper.getDefaultRegion';
import uploadChunkedFile from '@salesforce/apex/TDMHelper.uploadChunkedFile';

const MAX_FILE_SIZE = 4718592;
const CHUNK_SIZE = 750000;
export default class TdmNewDocumentWizard extends LightningElement {
    uploadedsize = 0;
    counter = 0;
    @api recordId;
    @track loaded = false;
    @track selectedEmployee = {};
    @track selectedUser = {};
    @track marketSegmentList = [];
    @track documentTypeList = [];
    @track documentControlList = [];
    @track regionList = [];
    @track divisionList = [];
    @track regionCount = 3;
    @track PublishedName = '';
    @track DocumentOwner = '';
    @track Requestor = '';
    @track Division = '';
    @track Language = '';
    @track MarketSegment = '';
    @track Campaign = '';
    @track Regions = [];    
    @track Description = '';
    @track SampleItemNo = '';
    @track DocumentType = '';
    @track DocumentTypeName ='';
    @track DocumentControl = 'Controlled';
    @track theRecord = {};
    
    mainForm = true;
    
    errorMessage = '';
    Controlled = true;
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
    docOwnerLookup = {};
    docRequestorLookup = {};
    languageLookup = {};
    campaignLookup = {};
    lookupsLoaded = false;
    showError = false;
    showSuccess = false;
    successMessage = '';

    columns = [{
        label: 'Name',
        fieldName: 'Name'
    }, ];

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
        this.loadDefaultLanguage();
        this.loadDefaultRegion();
        this.loadMarketSegments();
        this.loadRegions();
        this.loadDocumentTypes();
        this.loadDocumentControlOptions();
        this.loadDivisions();        
        this.loadPdfPortalCategories();
        this.loadCategories();
        this.loadSeries();        
        this.loadTree();
        this.loaded = true;
    }

    createTechDocument(event) {
        console.log('Document Control: ' + this.DocumentControl);
        if(this.DocumentControl == null || this.DocumentControl === "")
        {
            this.handleError('Fill in DocumentControl.');
            return;
        }       
        
        // if(this.DocumentControl == 'Uncontrolled' && this.fileList.length == 0)
        // {
        //     this.handleError('Add atleast one file.');
        //     return;
        // }
        
        console.log('Published Name: ' + this.PublishedName);
        if(this.PublishedName == null || this.publishedName === "")
        {
            this.handleError('Fill in Published Name.');
            return;
        }
        console.log('Doc Owner: ' + this.DocumentOwner);
        if(this.DocumentOwner == null || this.DocumentOwner === "")
        {
            this.handleError('Fill in Document Owner.');
            return;
        }
        console.log('Requestor: ' + this.Requestor);
        if(this.Requestor == null || this.Requestor === "")
        {
            this.handleError('Fill in Document Requestor.');
            return;
        }
        console.log('Doc Type: ' + this.DocumentType);
        if(this.DocumentType == null || this.DocumentType === "")
        {
            this.handleError('Fill in Document Type.');
            return;
        }
        console.log('Division: ' + this.Division);
        if(this.Division == null || this.Division === "")
        {
            this.handleError('Fill in Division.');
            return;
        }
        console.log('Language: ' + this.Language);
        if(this.Language == null || this.Language === "")
        {
            this.handleError('Fill in Language.');
            return;
        }
        
        if(
             (this.DocumentTypeName == "Flyer" || this.DocumentTypeName == "Brochure" || this.DocumentTypeName == 'White Paper') 
              && this.Campaign == ''
          )
        {
            this.handleError('Fill in Campaign.');
            return;
        }
        console.log('Market Segment: ' + this.MarketSegment);
        console.log('Campaign: ' + this.Campaign);        
        console.log('Regions: ' + this.Regions);
        console.log('Description: ' + this.Description);
        console.log('Sample Item No: ' + this.SampleItemNo);
        this.loaded = false;
        var region = '';
        if (this.Regions != null && this.Regions.length > 0)
            region = this.Regions.join(',');



        createDocument({
                documentControl: this.DocumentControl,
                publishedName: this.PublishedName,
                documentOwner: this.DocumentOwner,
                requestor: this.Requestor,
                documentType: this.DocumentType,
                division: this.Division,
                language: this.Language,
                marketSegment: this.MarketSegment,
                campaign: this.Campaign,
                regions: region,
                description: this.Description,
                sampleItemNo: this.SampleItemNo
            }).then(data => {
                if (data) {
                    var dataJson = JSON.stringify(data);
                    console.log(dataJson);
                    if (this.isValidId(data)) 
                    {
                        if (!this.Controlled) {

                        window.location.href = window.location.origin + '/lightning/r/Technical_Document__c/' + data + '/view';
                        //     console.log("Uncontrolled");
                        //     this.counter = 0;                            
                        //     this.fileList.forEach(f => {
                        //         try {

                        //             var fromIndex = 0;
                        //             var toIndex = Math.min(f.FileData.length, fromIndex + CHUNK_SIZE);                                    
                        //             this.uploadChunk(f.FileName, f.FileData, fromIndex, toIndex, '', data, f.SuggestedLocations, f.WebsiteFriendlyName);
                                   
                        //         } catch (error) {
                        //             this.handleError(error);
                        //         }
                        //     });
                        } 
                       //else {
                            this.loaded = true;
                            this.showSuccess = true;
                            this.successMessage = 'Document Submitted Successfully.';
                        //}
                    }
                } else {
                    if (this.Controlled) {
                        this.loaded = true;
                        this.showSuccess = true;
                        this.successMessage = 'Document Submitted Successfully.';                        
                    }
                }
            })
            .catch(error => {
                // TODO: handle error
                this.handleError(error);
                this.loaded = true;
            });
    }
    
    uploadChunk(fileName, fileContents, fromIndex, toIndex, cvId, revisionId, suggestedLocations, websiteFriendlyName){
        try {
        var chunk = fileContents.substring(fromIndex, toIndex);
        uploadChunkedFile({             
            fileName: fileName,
            fileContent: encodeURIComponent(chunk),
            contentVersionId: cvId,
            revisionId: revisionId,
            suggestedLocations: suggestedLocations,
            websiteFriendlyName: websiteFriendlyName
        }).then(result => {
            cvId = result;
            console.log("CVID: " + cvId);
            fromIndex = toIndex;
            toIndex = Math.min(fileContents.length, fromIndex + CHUNK_SIZE);
            console.log("fromIndex: " + fromIndex);
            console.log("toIndex: " + toIndex);
            //this.uploadedsize = toIndex;            
            if (fromIndex < toIndex) {
                this.uploadChunk(fileName, fileContents, fromIndex, toIndex, cvId, 'test','test','test');  
            } else {
                this.counter++;
                console.log(counter);
                console.log(this.fileList.length);
                if(this.fileList.length == this.counter )
                {
                    this.successMessage = 'Document Submitted Successfully.';
                    this.loaded = true;
                    console.log(this.successMessage);
                    //this.showToast('Success', 'success', 'Files Uploaded successfully.');
                    //window.location.href = window.location.origin + '/lightning/r/Technical_Document__c/' + result + '/view';
                }
            }
        }).catch(error => {
           console.log(JSON.stringify(error));
        });
        } catch (error) {
            console.log(JSON.stringify(error));
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
        if (event.target.name == 'PublishedName') {
            this.PublishedName = event.target.value;
        } else if (event.target.name == 'MarketSegment') {
            this.MarketSegment = event.target.value;
        } else if (event.target.name == 'Region') {
            this.Regions = event.target.value;
            console.log(JSON.stringify(event.target.value));
        } else if (event.target.name == 'Description') {
            this.Description = event.target.value;
        } else if (event.target.name == 'SampleItemNo') {
            this.SampleItemNo = event.target.value;
        } else if (event.target.name == 'DocumentType') {
            this.DocumentType = event.target.value;
            this.DocumentTypeName = event.target.options.find(opt => opt.value === event.detail.value).label;
            console.log(this.DocumentTypeName);
        } else if (event.target.name == 'DocumentControl') {
            this.DocumentControl = event.target.value;
            if (this.DocumentControl == 'Controlled')
                this.Controlled = true;
            else
                this.Controlled = false;
        } else if (event.target.name == 'Division') {
            this.Division = event.target.value;
        } else if (event.target.name == 'PdfPortalCategory') {
            this.pdfPortalCategory = event.target.value;
        } else if (event.target.name == 'WebsiteFriendlyName') {
            this.WebsiteFriendlyName = event.target.value;
        }
    }

    handleLookupSelectionChange(event) {

        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        var name = '';
        if (selection.length > 0) {
            name = selection[0].title;
            var id = selection[0].id;
            //var subTitle = selection[0].subtitle;
        }
        console.log(event.target.name);
        console.log(name);
        console.log(id);

        //this.theRecord[event.target.name] = id;
        if (event.target.name == 'docOwnerLookup') {
            this.docOwnerLookup = selection;
            this.DocumentOwner = id;
        } else if (event.target.name == 'docRequestorLookup') {
            this.docRequestorLookup = selection;
            this.Requestor = id;
        } else if (event.target.name == 'languageLookup') {
            this.languageLookup = selection;
            this.Language = id;
        } else if (event.target.name == 'campaignLookup') {
            this.campaignLookup = selection;
            this.Campaign = id;
        }
    }

    loadDefaultLanguage() {
        getDefaultLanaguage().then(results => {

            console.log(results);
            var temp = {
                id: results.Id,
                sObjectType: 'Technical_Document_Language__c',
                icon: 'standard:account',
                title: results.Name,
                subtitle: results.Name
            };
            this.Language = results.Id;
            this.languageLookup = temp;            
        }).catch(error => {
            console.log(error);
        });
    }

    loadDefaultRegion() {
        getDefaultRegion().then(results => {
            console.log(results);
            var tempDefaultArray = [];
            tempDefaultArray.push(results.Id);
            this.Regions = [...tempDefaultArray]
            console.log("default regions: " + JSON.stringify(this.Regions));
        }).catch(error => {
            console.log(error);
        });
    }

    handleUserSearch(event) {
        const target = event.target;
        console.log(event.detail);
        UserSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting users: " + error);
            });
    }



    handleEmployeeSearch(event) {
        const target = event.target;
        console.log(event.detail);
        EmployeeSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting employees: " + error);
            });
    }

    handleCampaignSearch(event) {
        const target = event.target;
        console.log(event.detail);
        CampaignSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting campaigns: " + error);
            });
    }

    handleLanguageSearch(event) {
        const target = event.target;
        console.log(event.detail);
        LanguageSearch(event.detail)
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error);
                console.log("Error getting languages: " + error);
            });
    }

    loadMarketSegments() {
        GetMarketSegments().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.trim(),
                    label: x.trim()
                });
            });
            this.marketSegmentList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });
    }
    loadDivisions() {
        GetDivisions().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.trim(),
                    label: x.trim()
                });
            });
            this.divisionList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });
    }
    loadRegions() {
        GetRegions().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.Id,
                    label: x.Name
                });
            });
            this.regionList = tempArray;
            this.regionCount = tempArray.length;
            console.log("region List:" + JSON.stringify(this.regionList));           
        }).catch(error => {
            this.handleError(error);
        });
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

    loadDocumentTypes() {
        GetDocumentTypes().then(results => {
            var tempArray = [];
            results.forEach(x => {
                tempArray.push({
                    value: x.Id,
                    label: x.Name
                });
            });
            this.documentTypeList = tempArray;
        }).catch(error => {
            this.handleError(error);
        });
    }

    loadDocumentControlOptions() {
        var tempArray = [];
        tempArray.push({
            value: 'Controlled',
            label: 'Controlled'
        });
        tempArray.push({
            value: 'Uncontrolled',
            label: 'Uncontrolled'
        });
        this.documentControlList = tempArray;
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
                    console.log(error);
                }
            }
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
        this.lookupsLoaded = true;
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
            console.log(error);
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

    handleErrorMessageBack(event) {
        this.showError = false;
    }
    handleError(error) {
        var errorJson = JSON.stringify(error);
        this.errorMessage = errorJson;
        this.showError = true;
        console.log(error);
        this.loaded = true;
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }
    

}