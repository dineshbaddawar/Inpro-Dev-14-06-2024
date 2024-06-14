import { LightningElement,
    api,
    wire,
    track } from 'lwc';

import LoadDivisions from '@salesforce/apex/NewBidderHelper.GetDivisionPicklist';
import LoadDivSections from '@salesforce/apex/NewBidderHelper.GetDivSectionPicklist';
import RetrieveConstructionProject from '@salesforce/apex/ReviewAllDivisionsHelper.retrieveConstructionProject';
import SendDivisionReviewRequest from '@salesforce/apex/ReviewAllDivisionsHelper.sendDivisionReviewRequest';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class ReviewAllDivisions extends LightningElement {

    @api objectApiName;
    @api recordId;

    @track loaded = false;
    @track divSectionData = [];
    @track divisionData = [];
    @track divisionColumns= [
        {label: 'Division', fieldName: 'Name'},
        {label: 'ISR', fieldName: 'ISR'},
        {label: 'Notes From SEC', fieldName: 'Notes', editable: true }
    ];
    @track divSectionColumns= [
        {label: 'Div Section', fieldName: 'Name'},
        {label: 'ISR', fieldName: 'ISR'},
        {label: 'Notes From SEC', fieldName: 'Notes', editable: true}
    ];
    @track activeSections = ['Divisions','DivSections'];

    @track clickezeSelected = false;
    @track hasRendered = false;

    @track ascendInsideRep = '';
    @track clickezeInsideRep = '';
    @track clickezeWTInsideRep = '';
    @track clickezeED12InsideRep = '';
    @track clickezeWebbInsideRep = '';
    @track endurantInsideRep = '';
    @track ipcInsideRep = '';
    @track jointmasterInsideRep = '';
    @track signscapeInsideRep = '';

    @track constructionProjectName = '';

    @track divisionSelectedRows = [];
    @track divSectionSelectedRows = [];
    @track divisionsSelected = [];
    @track divSectionsSelected = [];
    @track divisionsToSubmit = [];
    @track canSubmit = true;

    renderedCallback()
    {
        if(!this.hasRendered)
        {
            if(this.clickezeSelected == true)
            {
                this.activeSections = ['Divisions','DivSections'];
                this.hasRendered = true;
            }                
        }
        else
            this.hasRendered = false;       
    }
    
    connectedCallback() {
        this.retrieveConstructionProject();
    }

    retrieveConstructionProject()
    {
        RetrieveConstructionProject({
            constructionProjectId: this.recordId
        }).then(data => {
            if (data) {
                try {
                    if(data.Territory__r != null)
                    {   
                        if(data.Territory__r.Ascend_ISR__r != null)
                            this.ascendInsideRep = data.Territory__r.Ascend_ISR__r.Email;
                        if(data.Territory__r.Clickeze_CCT_ISR__r != null)
                            this.clickezeInsideRep = data.Territory__r.Clickeze_CCT_ISR__r.Email;
                        if(data.Territory__r.Clickeze_WT_ISR__r != null)
                            this.clickezeWTInsideRep = data.Territory__r.Clickeze_WT_ISR__r.Email;
                        if(data.Territory__r.Clickeze_ED12_ISR__r != null)
                            this.clickezeED12InsideRep = data.Territory__r.Clickeze_ED12_ISR__r.Email;
                        if(data.Territory__r.Clickeze_Webb_ISR__r != null)
                            this.clickezeWebbInsideRep = data.Territory__r.Clickeze_Webb_ISR__r.Email;
                        if(data.Territory__r.Endurant_ISR__r != null)
                            this.endurantInsideRep = data.Territory__r.Endurant_ISR__r.Email;
                        if(data.Territory__r.IPC_Team_Lead__r != null)
                            this.ipcInsideRep = data.Territory__r.IPC_Team_Lead__r.Email;
                        if(data.Territory__r.JointMaster_ISR__r != null)
                            this.jointmasterInsideRep = data.Territory__r.JointMaster_ISR__r.Email;
                        if(data.Territory__r.SignScape_ISR__r != null)
                            this.signscapeInsideRep = data.Territory__r.SignScape_ISR__r.Email;
                    }
                    if(data.Name != null)
                            this.constructionProjectName = data.Name; 
                        
                    LoadDivisions().then(data =>{
                        var tempArray = [];
                        data.forEach(x => {
                            tempArray.push({
                                Name: x.Name,
                                id: x.Id,
                                ISR: this.getISR(x.Name)
                            });
                        });
                        this.divisionData = tempArray;
                    }).catch(error => {
                        this.handleError(error);
                    });
            
                    LoadDivSections().then(data =>{
                        var tempArray = [];
                        data.forEach(x => {
                            if(x != 'Soft Goods')
                            {
                                tempArray.push({
                                    Name: x,
                                    id: x,
                                    ISR: this.getISR(x)
                                });
                            }
                        });
                        this.divSectionData = tempArray;
                    }).catch(error => {
                        this.handleError(error);
                    }); 
                    this.loaded = true;   
                    
                } catch (error) {
                    this.handleError(error);
                }
            }
        })
        .catch(error => {
            this.handleError(error);
        });
    }

    handleDivisionDataSelection(event){
        this.divisionsSelected = [];
        const selectedRows = event.detail.selectedRows;
        var tempSelectedRows = [];
        this.template.querySelector("[data-id='divisionTable']").selectedRows = [];
        var clickezeSelectedTemp = false;
        for(var i = 0; i < selectedRows.length; i++)
        {
            if(selectedRows[i].Name != null && selectedRows[i].Name == "Clickeze" && selectedRows[i].ISR != null && selectedRows[i].ISR != "")
                clickezeSelectedTemp = true;
            if(selectedRows[i].ISR == null || selectedRows[i].ISR == "")
            {
                alert("Error: The division selected does not have an ISR. It will now be deselected.");
            }
            else
            {
                tempSelectedRows.push(selectedRows[i].Name);
            }
        }
        this.divisionSelectedRows = tempSelectedRows;
        this.clickezeSelected = clickezeSelectedTemp;
             
    }

    handleDivSectionDataSelection(event){        
        this.divSectionsSelected = [];
        const selectedRows = event.detail.selectedRows;
        this.template.querySelector("[data-id='divSectionTable']").selectedRows = [];
        var tempSelectedRows = [];
        for(var i = 0; i < selectedRows.length; i++)
        {
            if(selectedRows[i].ISR == null || selectedRows[i].ISR == "")
                alert("Error: The division selected does not have an ISR. It will now be deselected.");
            else
            {
                tempSelectedRows.push(selectedRows[i].Name);
            }
        }
        this.divSectionSelectedRows = tempSelectedRows;            
    }

    handleInputOnChange(event)
    {
        if(event.target.name == "ta_Notes")
            this.notesToSEC = event.target.value;
    }

    handleCancel(event) {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleKeyUp(event)
    {
        if(event.which != 9)
            this.canSubmit = false;
        else
            this.canSubmit = true;
    }

    handleOnFocusOut()
    {
        this.canSubmit = true;
    }

    handleInlineEdit(event)
    {

    }

    handleSubmit()
    {
        this.template.querySelector("[data-id='iconObject']").focus();
        this.loaded = false;
        this.divisionsToSubmit = [];
        console.log('submitted');
        var divisionsSelected = this.template.querySelector("[data-id='divisionTable']").getSelectedRows();
        var tempTable = this.template.querySelector("[data-id='divisionTable']");
        var draftValues = tempTable.draftValues; 
        var czSelected = false;
        var divisionSelectionCount = 0;    
        var divSectionSelectionCount = 0;    

        if(divisionsSelected != null && divisionsSelected.length > 0)
        {
            for(var i = 0; i < divisionsSelected.length; i++)
            {
                if(divisionsSelected[i].Name != "Clickeze")
                {
                    var tempDivision = {};
                    tempDivision.DivisionName = divisionsSelected[i].Name;
                    tempDivision.DivSectionName = '';
                    tempDivision.ISR = divisionsSelected[i].ISR;
                    
                    let draftCell = draftValues.find((draftValue)=>draftValue.Name === divisionsSelected[i].Name);
                    if(draftCell != null) {
                        tempDivision.Notes = draftCell.Notes;
                    }
                    this.divisionsToSubmit = [...this.divisionsToSubmit, tempDivision];    
                    divisionSelectionCount++;                  
                }
                else
                    czSelected = true;
            }
        }

        if(czSelected)
        {
            var divSectionsSelected = this.template.querySelector("[data-id='divSectionTable']").getSelectedRows(); 
            tempTable = this.template.querySelector("[data-id='divSectionTable']");
            draftValues = tempTable.draftValues; 
            if(divSectionsSelected != null && divSectionsSelected.length > 0)
            {
                for(var i = 0; i < divSectionsSelected.length; i++)
                {
                    var tempDivision = {};
                    tempDivision.DivisionName = '';
                    tempDivision.DivSectionName = divSectionsSelected[i].Name;
                    tempDivision.Notes = divSectionsSelected[i].Notes;
                    tempDivision.ISR = divSectionsSelected[i].ISR;
                    let draftCell = draftValues.find((draftValue)=>draftValue.Name === divSectionsSelected[i].Name);
                    if(draftCell != null) {
                        tempDivision.Notes = draftCell.Notes;
                    }
                    this.divisionsToSubmit = [...this.divisionsToSubmit, tempDivision];
                    divSectionSelectionCount++;
                }
            }                
        }

        if(czSelected && divSectionSelectionCount == 0)
        {
            this.handleError('Error: Clickeze is selected, but an associated div section is not. Please select a div section.');
        }
        else if (divSectionSelectionCount == 0 && divisionsSelected == 0)
        {
            this.handleError('Error: No divisions have been selected. Please select the appropriate division(s) before submitting.');
        }
        else
        {
            SendDivisionReviewRequest({
                reviewRequests: this.divisionsToSubmit,
                constructionProjectId: this.recordId,
                constructionProjectName: this.constructionProjectName
            }).then(data => {
                if (data) {
                    try 
                    {     
                        if(!data.toLowerCase().includes("error"))
                            document.location = location.href;
                        else
                            this.handleError(data);                                      
                    } 
                    catch (error) 
                    {
                        this.handleError(error);
                    }
                }
                this.loaded = true;
            })
            .catch(error => {
                this.handleError(error);
            });
        }
    }

    getISR(divisionRef)
    {
        if(divisionRef == 'Clickeze')
            return this.clickezeInsideRep;
        else if(divisionRef == 'IPC')
            return this.ipcInsideRep;
        else if(divisionRef == 'JointMaster')
            return this.jointmasterInsideRep;
        else if(divisionRef == 'SignScape')
            return this.signscapeInsideRep;
        else if(divisionRef == 'Endurant')
            return this.endurantInsideRep;
        else if(divisionRef == 'Ascend')
            return this.ascendInsideRep;
        else if(divisionRef == 'Cubicles, Curtains, & Tracks')
            return this.clickezeInsideRep;
        else if(divisionRef == 'Window Treatment')
            return this.clickezeWTInsideRep;
        else if(divisionRef == 'ED12')
            return this.clickezeED12InsideRep;
        else if(divisionRef == 'Soft Goods')
            return this.clickezeInsideRep;
        else if(divisionRef == 'Webb')
            return this.clickezeWebbInsideRep;
        else
            return '';
   
    }
    
    handleError(error) {
        console.log(error);
        if (error.body !== undefined && error.body.pageErrors !== undefined && error.body.pageErrors[0] !== undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error! ' + error.body.pageErrors[0].statusCode,
                message: error.body.pageErrors[0].message,
                variant: 'warning'
            }));
        } else if (error.body !== undefined && error.body.message !== undefined)
        {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error.body.message,
                variant: 'warning'
            }));
        } 
        else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!',
                message: error,
                variant: 'warning'
            }));
        }
        this.loaded = true;
    }
}