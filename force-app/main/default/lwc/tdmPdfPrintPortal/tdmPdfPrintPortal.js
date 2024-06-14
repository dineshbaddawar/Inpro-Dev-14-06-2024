import {
    LightningElement,
    api,
    track
} from 'lwc';

import getPdfPortalCategories from '@salesforce/apex/TDMHelper.getPdfPortalCategories';
import getPdfPortalPDFs from '@salesforce/apex/TDMHelper.getPdfPortalPDFs';
import downloadCombinedPDF from '@salesforce/apex/TDMHelper.downloadCombinedPDF';
import deleteFile from '@salesforce/apex/TDMHelper.deleteFile';

export default class TdmPdfPrintPortal extends LightningElement {

    @track loaded = false;
    categoryList = [];
    filteredPDFList = [];
    allPDFList = [];
    selectedItem;
    errorMessage = '';
    pdfGenerated = false;
    fileUrl = '';
    fileId = '';
    initialLoad = true;


    deleteFileVersion(event) {
        // try {
        //     this.pdfGenerated = false;
        //     if (this.isValidId(this.fileId)) {
        //         console.log('start delete');
        //         console.log(this.fileId);
        //         deleteFile({
        //             recordId: this.fileId
        //         }).then(results => {
        //             console.log(results);
        //         }).catch(error => {
        //             console.log(error);
        //         });
        //     }
        // } catch (error) {
        //     console.log(error);
        // }
    }

    isValidId(idStr) {
        const regex = RegExp('\\w{15,18}');
        const match = regex.test(idStr);
        return match;
    }

    printPDFs(event) {
        this.loaded = false;
        var selectedPdfs = this.allPDFList.filter(pdf => {
            return pdf.SequenceNumber > 0
        }).sort((a, b) => a.SequenceNumber - b.SequenceNumber);;
        console.log(selectedPdfs);
        var tempArray = [];
        selectedPdfs.forEach(x => {
            tempArray.push(x.Id);
        });
        var pdfJson = JSON.stringify(tempArray);
        downloadCombinedPDF({
            pdfs: pdfJson
        }).then(results => {
            console.log(results);
            this.loaded = true;
            if (this.isValidId(results)) {
                this.pdfGenerated = true;
                this.fileUrl = window.location.protocol + '//' + window.location.host + '/' + results;
                this.fileId = results;
            }
        }).catch(error => {
            console.log(error);
        });
    }


    printPreviewPDFs(event) {
        var tempArray = this.allPDFList.filter(pdf => {
            return pdf.SequenceNumber > 0
        }).sort((a, b) => a.SequenceNumber - b.SequenceNumber);
        this.filteredPDFList = [...tempArray];
    }

    connectedCallback() {
        this.loadPdfPortalCategories();
        this.loadPDFs();
    }

    loadPdfPortalCategories() {
        getPdfPortalCategories().then(results => 
        {            
            const map = new Map();
            const roots = [];            

            const cats = results.map(item => ({
                ...item,
                items: []
            }));
            console.log("categories:");
            console.log(cats);
            // Initialize the map
            cats.forEach(item => {
                item.items = [];
                map.set(item.Id, item);
            });
    
            // Build the tree structure
            cats.forEach(item => {
                if (item.Parent_PDF_Portal_Category__c) {
                    const parent = map.get(item.Parent_PDF_Portal_Category__c);
                    if (parent) {
                        parent.children.push(item);
                    }
                } else {
                    roots.push(item);
                }
            });
            this.categoryList = roots;

        }).catch(error => {
            console.log(error);
        });
    }

    loadPDFs() {
        getPdfPortalPDFs().then(results => {
            var tempArray = [];

            results.forEach(pdf => {
                try {
                    var tempItem = {};
                    tempItem.SequenceNumber = 0;
                    tempItem.CategoryId = pdf.Technical_Document_PDF_Portal_Category__c;
                    tempItem.CategoryName = pdf.Technical_Document_PDF_Portal_Category__r.Name;
                    tempItem.Id = pdf.Technical_Document_File__r.Id;
                    var re = /(?:\.([^.]+))?$/;
                    var ext = re.exec(pdf.Technical_Document_File__r.Name)[1];
                    tempItem.Name = pdf.Technical_Document__r.Name + '.' + ext;
                    if (ext.toLowerCase() == 'pdf')
                        tempArray.push(tempItem);
                } catch (error) {
                    console.log(error);
                }
            });
            console.log(JSON.stringify(tempArray));
            this.allPDFList = tempArray;
            this.filteredPDFList = tempArray;
            this.loaded = true;
        }).catch(error => {
            console.log(error);
        });
    }

    handleSelected(event) {
        try {
            //console.log(event.detail.name);

            if(this.initialLoad == true)
            {
                //This fixes a bug with clicking between categories, don't ask me why, seems like a bug in Salesforce's native libraries.
                this.selectedItem = this.categoryList[0].Id;
                this.filterListByCategory();
                this.initialLoad = false;
                console.log("load first");
            }

            if (event.detail.name) {
                this.loaded = false;
                this.selectedItem = event.detail.name;
                console.log(event.detail.name);
                this.filterListByCategory();
            }
        } catch (error) {
            var e = JSON.stringify(error);
            console.log(e);
            this.loaded = true;
        }
    }

    filterListByCategory() {
        try {
            var selection = this.selectedItem;
            console.log('selection: ' + selection);            
            var tempArray = this.allPDFList.filter(function (pdf) {
                return pdf.CategoryId === selection;
            });            
            console.log(tempArray);            
            this.filteredPDFList = [...tempArray];
             
            this.loaded = true;

        } catch (error) {
            console.log(error);
            this.loaded = true;
        }
    }

    // renderedCallback() {
    //     try {

    //         this.loaded = true;
    //         this.filteredPDFList = [...this.filteredPDFList];
    //     } catch (error) {
    //         console.log(error);
    //     }
    // }

    handleGridInputChange(event) {
        //here
        let selectedItem = this.allPDFList.filter(function (pdf) {
            return pdf.Id === event.target.accessKey;
        })[0];

        selectedItem.SequenceNumber = event.target.value;
    }

    handleErrorMessageBack(event) {
        this.showError = false;
    }

}