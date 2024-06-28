import { LightningElement, api, wire, track } from 'lwc';
import getMilestones from '@salesforce/apex/ProjectManagementController.getMilestones';
import getManagers from '@salesforce/apex/ProjectManagementController.getManagers';
import saveNewMilestone from '@salesforce/apex/ProjectManagementController.saveNewMilestone';
import saveNewManager from '@salesforce/apex/ProjectManagementController.saveNewManager';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import PROJECT_MILESTONE_OBJECT from '@salesforce/schema/Project_Management_Milestone__c';
import DIVISION_FIELD from '@salesforce/schema/Project_Management_Milestone__c.Division__c';
import MILESTONE_FIELD from '@salesforce/schema/Project_Management_Milestone__c.Milestone__c';
import PROJECT_MANAGER_OBJECT from '@salesforce/schema/Project_Manager__c';
import USER_OBJECT from '@salesforce/schema/User';
import DIVSECTION_FIELDS from '@salesforce/schema/Project_Manager__c.Div_Section__c';
import getUsers from '@salesforce/apex/ProjectManagementController.getUsers';

const pmmcolumns = [
    { label: 'Division', fieldName: 'Division__c', editable: false },
    { label: 'Milestone', fieldName: 'Milestone__c', editable: false },
    { label: 'Date Created', fieldName: 'Date_Created__c', type: 'date', editable: true },
    { label: 'Date Completed', fieldName: 'Date_Completed__c', type: 'date', editable: true },
];
 
const pmcolumns = [
    { label: 'Division', fieldName: 'Division__c', editable: false },
    { label: 'User', fieldName: 'UserName', editable: false },
    { label: 'Division Section', fieldName: 'Div_Section__c', editable: false },
];
 
export default class PmFormMain extends LightningElement {
    @api recordId;
    @track selectedDivision = '';
    @track pmmdata = [];
    @track pmdata = [];
    @track pmmcolumns = pmmcolumns;
    @track pmcolumns = pmcolumns;
    @track rowOffset = 0;
    @track isMilestoneModalOpen = false;
    @track isManagerModalOpen = false;
    @track division = '';
    @track milestone = '';
    @track dateCreated = '';
    @track dateCompleted = '';
    @track divisionOptions = [];
    @track milestoneOptions = [];
    @track divsectionOptions = [];
    @track user = '';
    @track allPmmdata = [];
    @track allPmdata = [];
    @track userOptions = [];
 
    @wire(getMilestones, { projectId: '$recordId' })
    wiredMilestones({ error, data }) {
        if (data) {
            this.allPmmdata = data;
            this.filterDataByDivision();
        } else if (error) {
            console.error('Error:', error);
        }
    }
 
    @wire(getManagers, { projectId: '$recordId' })
    wiredManagers({ error, data }) {
        if (data) {
            this.allPmdata = data.map(manager => ({
                ...manager,
                UserName: manager.User__r.Name
            }));
            this.filterDataByDivision();
        } else if (error) {
            console.error('Error:', error);
        }
    }
 
    handleDivisionChange(event) {
        this.selectedDivision = event.target.value;
        this.filterDataByDivision();
    }
 
    filterDataByDivision() {
        if (this.selectedDivision) {
            this.pmmdata = this.allPmmdata.filter(
                item => item.Division__c === this.selectedDivision
            );
            this.pmdata = this.allPmdata.filter(
                item => item.Division__c === this.selectedDivision
            );
        } else {
            this.pmmdata = this.allPmmdata;
            this.pmdata = this.allPmdata;
        }
    }
 
    @wire(getObjectInfo, { objectApiName: PROJECT_MILESTONE_OBJECT })
    projectMilestoneInfo;
    @wire(getObjectInfo, { objectApiName: PROJECT_MANAGER_OBJECT })
    projectManagerInfo;
    @wire(getObjectInfo, { objectApiName: USER_OBJECT })
    userInfo;
 
    @wire(getPicklistValues, { recordTypeId: '$projectMilestoneInfo.data.defaultRecordTypeId', fieldApiName: DIVISION_FIELD })
    wiredDivisionValues({ error, data }) {
        if (data) {
            this.divisionOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Division picklist values:', error);
        }
    }
 
    @wire(getPicklistValues, { recordTypeId: '$projectMilestoneInfo.data.defaultRecordTypeId', fieldApiName: MILESTONE_FIELD })
    wiredMilestoneValues({ error, data }) {
        if (data) {
            this.milestoneOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Milestone picklist values:', error);
        }
    }
 
    @wire(getPicklistValues, { recordTypeId: '$projectManagerInfo.data.defaultRecordTypeId', fieldApiName: DIVSECTION_FIELDS })
    wiredDivSectionValues({ error, data }) {
        if (data) {
            this.divsectionOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching Division Section picklist values:', error);
        }
    }

    @wire(getUsers)
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
        } else if (error) {
            console.error('Error fetching users:', error);
        }
    }
 
    /*@wire(getPicklistValues, { recordTypeId: '$userInfo.data.defaultRecordTypeId', fieldApiName: USER_LOOKUP_FIELD })
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
        } else if (error) {
            console.error('Error fetching user picklist values:', error);
        }
    }*/
 
    handleNewMilestone() {
        this.isMilestoneModalOpen = true;
    }
 
    async handleSaveNewMilestone() {
        const newRecord = {
            Project_Management__c: this.recordId,
            Division__c: this.division,
            Milestone__c: this.milestone,
            Date_Created__c: this.dateCreated,
            Date_Completed__c: this.dateCompleted
        };
 
        try {
            await saveNewMilestone({ milestone: newRecord });
            this.showToast('Success', 'New milestone added successfully', 'success');
            this.isMilestoneModalOpen = false;
            this.clearModalFields();
            await refreshApex(this.wiredMilestones);
        } catch (error) {
            this.showToast('Error', error.body ? error.body.message : error.message, 'error');
        }
    }
    handleCloseMilestoneModal() {
        this.isMilestoneModalOpen = false;
        this.clearModalFields();
    }
    
    handleNewManager() {
        this.isManagerModalOpen = true;
    }
    
    async handleSaveNewManager() {
        const newRecord = {
            Project_Management__c: this.recordId,
            Division__c: this.division,
            User__c: this.user,
            Div_Section__c: this.divsection,
        };
    
        try {
            await saveNewManager({ manager: newRecord });
            this.showToast('Success', 'New manager added successfully', 'success');
            this.isManagerModalOpen = false;
            this.clearModalFields();
            await refreshApex(this.wiredManagers);
        } catch (error) {
            this.showToast('Error', error.body ? error.body.message : error.message, 'error');
        }
    }
    
    handleCloseManagerModal() {
        this.isManagerModalOpen = false;
        this.clearModalFields();
    }
    
    handleFieldChange(event) {
        //console.log(event.target.name);
        this[event.target.name] = event.target.value;
    
        if(event.target.name === 'user') {
            this.user = event.target.value;
        }
    }
    
    clearModalFields() {
        this.division = '';
        this.milestone = '';
        this.dateCreated = '';
        this.dateCompleted = '';
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}