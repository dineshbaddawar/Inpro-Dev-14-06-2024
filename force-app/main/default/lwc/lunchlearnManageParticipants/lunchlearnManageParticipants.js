import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getLunchAndLearnEvent from '@salesforce/apex/LunchAndLearnManageParticipants.getLunchAndLearnEvent';
import getOrgUrl from '@salesforce/apex/LunchAndLearnManageParticipants.getOrgURL';
import deleteAttendees from '@salesforce/apex/LunchAndLearnManageParticipants.deleteAttendees';
import searchContacts from '@salesforce/apex/LunchAndLearnManageParticipants.searchContacts';
import searchLeads from '@salesforce/apex/LunchAndLearnManageParticipants.searchLeads';
import makeEventAttendee from '@salesforce/apex/LunchAndLearnManageParticipants.makeEventAttendee';

export default class LunchlearnManageParticipants extends LightningElement {

  @api recordId;
  @track lunchEvent;

  // UI
  @track loading = true;
  @track registeredCount;
  @track showDelete = false;

  // Search input
  @track results;
  @track noResults;
  @track objectType;
  @track objectTypeLead;
  @track objectTypeContact;
  objectTypeOptions;
  @track isObjectTypeContact;

  @track createMessage;
  @track createIcon;

  // Modal
  @track modalTypeView;
  @track modalTypeEdit;
  @track modalTypeDelete;
  @track modalTypeCreate;

  modalRecordIdBatch;
  modalRecordId;

  // Datatable
  @track attendees;
  @track sortedBy;
  @track sortedDirection;
  @track zeroAttendees;
  selectedRowIds;
  columns;
  rowActions;
  orgUrl;


  // Initialization
  connectedCallback() {
    this.initializeData();
    this.initializeDatatable();
    this.initializeForm();
    this.resetModalProps();
  }

  initializeData() {
    this.getOrgUrl();
    this.getLunchEventRecord();
  }

  async getOrgUrl() {
    const orgUrl = await getOrgUrl();
    this.orgUrl = orgUrl;
  }

  getLunchEventRecord() {
    getLunchAndLearnEvent({
      eventId: this.recordId
    }).then(lunchEvent => {
      this.lunchEvent = lunchEvent;
      this.prepAttendees(lunchEvent.Event_Attendees__r);
      this.stopLoading();
    }).catch(err => {
      this.handleError(err);
    });
  }

  initializeDatatable() {
    this.makeDatatableColumns();
    this.setInitialSort();
  }

  makeDatatableColumns() {
    const rowActions = this.getRowActions();
    const cols = [
      {
        label: 'Attendee',
        fieldName: 'relatedRecordUrl',
        type: 'url',
        initialWidth: 200,
        typeAttributes: {
          label: {
            fieldName: 'relatedRecordLabel'
          }
        },
        sortable: true,
        hideDefaultActions: false
      },
      {
        label: 'Status',
        fieldName: 'Status__c',
        initialWidth: 125,
        sortable: true,
        hideDefaultActions: false
      },
      {
        label: 'Project Follow-up',
        fieldName: 'Follow_up_with_a_Project__c',
        initialWidth: 125,
        type: 'boolean',
        sortable: true,
        hideDefaultActions: false,
        cellAttributes: {
          alignment: 'center'
        }
      },
      {
        label: 'Company',
        fieldName: 'CompanyOrAccount__c',
        initialWidth: 200,
        sortable: true,
        hideDefaultActions: false
      },
      {
        label: 'Email',
        fieldName: 'Email__c',
        type: 'email',
        initialWidth: 275,
        sortable: true,
        hideDefaultActions: false,
      },
      {
        label: 'Email Opt-In',
        fieldName: 'Email_Opt_In__c',
        initialWidth: 125,
        type: 'boolean',
        sortable: true,
        hideDefaultActions: false,
        cellAttributes: {
          alignment: 'center'
        }
      },
      {
        label: 'AIA Number',
        fieldName: 'LunchAndLearn_AIA_Number__c',
        initialWidth: 125,
        sortable: true,
        hideDefaultActions: false
      },
      {
        label: 'IDCEC Number',
        fieldName: 'IDCEC_Number__c',
        initialWidth: 125,
        sortable: true,
        hideDefaultActions: false
      },
      {
        label: 'GBCI Number',
        fieldName: 'GBCI_Number__c',
        initialWidth: 125,
        sortable: true,
        hideDefaultActions: false
      },
      {
        label: 'Name',
        fieldName: 'recordUrl',
        type: 'url',
        initialWidth: 200,
        typeAttributes: {
          label: {
            fieldName: 'recordURLLabel'
          }
        },
        sortable: true,
        hideDefaultActions: false
      },
      {
        type: 'action',
        typeAttributes: {
          rowActions: rowActions,
          menuAlightnment: 'left'
        }
      }

    ];
    this.columns = cols;
  }

  setInitialSort() {
    this.setSort('relatedRecordUrl', 'desc');
  }

  getRowActions() {
    const actions = [{
      label: 'View',
      name: 'view'
    },
    {
      label: 'Edit',
      name: 'edit'
    },
    {
      label: 'Delete',
      name: 'delete'
    }
    ];
    return actions;
  }

  initializeForm() {
    this.setObjectTypeOptions();
    this.setObjectType('Contact');
  }

  setObjectType(type) {
    this.objectType = type;
    if (type == 'Contact')
      this.isObjectTypeContact = true;
    else
      this.isObjectTypeContact = false;
    this.updateCreateAction();
  }

  updateCreateAction() {
    const type = this.getObjectType();
    this.createMessage = 'Create New ' + type;
    this.createIcon = this.getCreateIconName(type);
  }

  getCreateIconName(type) {
    if (type === 'Lead') {
      return 'action:new_lead';
    }
    if (type === 'Contact') {
      return 'action:new_contact';
    }
  }

  updateObjectTypeBooleans() {
    const type = this.getObjectType();
    this.objectTypeLead = type === 'Lead';
    this.objectTypeContact = type === 'Contact';
  }

  setObjectTypeOptions() {
    this.objectTypeOptions = [{
      label: 'Contacts',
      value: 'Contact'
    },
    {
      label: 'Leads',
      value: 'Lead'
    }
    ];
  }

  resetModalProps() {
    this.modalTypeView = false;
    this.modalTypeEdit = false;
    this.modalTypeDelete = false;
    this.modalTypeCreate = false;
    this.setModalHeaderText('');
    this.setModalRecordIdBatch([]);
    this.setModalRecordId('');
  }

  // Data handling

  prepAttendees(attendees) {
    if (attendees && attendees.length > 0) {
      this.buildNewRows(attendees);
    } else {
      this.setAttendees([]);
    }
  }

  buildNewRows(attendees) {
    attendees.forEach(attendee => {
      attendee = this.prepareRowEntry(attendee);
    });
    attendees = this.sortRows(attendees);
    this.setAttendees(attendees);
  }

  prepareRowEntry(attendee) {
    attendee = this.setAttendeeType(attendee);
    attendee = this.setAttendeeUrls(attendee);
    return attendee;
  }

  setAttendeeType(attendee) {
    let type = '';
    const validLeadId = this.isValidId(attendee.Lead__c);
    const validContactId = this.isValidId(attendee.Contact__c);
    if (validLeadId && !validContactId) {
      type = 'Lead';
    } else if (validContactId && !validLeadId) {
      type = 'Contact';
    }
    attendee.type = type;
    return attendee;
  }

  isValidId(idStr) {
    const regex = RegExp('\\w{15,18}');
    const match = regex.test(idStr);
    return match;
  }

  setAttendeeUrls(attendee) {
    const recType = attendee.type;
    const recId = this.getRelatedId(attendee);
    const url = this.makeRecordUrl(recType, recId);
    attendee.relatedRecordUrl = url;
    attendee.relatedRecordLabel = `${attendee.FirstName__c} ${attendee.LastName__c}`;

    attendee.recordUrl = this.makeRecordUrl('Event_Attendee__c', attendee.Id);;
    attendee.recordURLLabel = attendee.Name;

    return attendee;
  }

  getRelatedId(attendee) {
    let recId = '';
    switch (attendee.type) {
      case 'Contact':
        recId = attendee.Contact__c;
        break;

      case 'Lead':
        recId = attendee.Lead__c;
        break;

      default:
        break;
    }
    return recId;
  }


  makeRecordUrl(recType, recId) {
    const urlSuffix = `/lightning/r/${recType}/${recId}/view`;
    const fullUrl = this.orgUrl + urlSuffix;
    return fullUrl;
  }

  setAttendees(attendees) {
    this.attendees = attendees;
    this.setRegisteredCount(attendees.length);
  }

  setRegisteredCount(count) {
    this.registeredCount = count;
    this.zeroAttendees = count === 0;
  }


  // Search

  handleChangeObjectType(event) {
    this.closeResultBox();
    const obj = event.currentTarget.value;
    this.setObjectType(obj);
  }

  handleQuery(event) {
    event.stopImmediatePropagation();
    const query = event.currentTarget.value;
    if (query.length === 0) {
      this.closeResultBox();
    } else {
      this.sendQuery(query);
    }
  }

  async sendQuery(query) {
    let result = [];
    const objType = this.getObjectType();
    try {
      switch (objType) {
        case 'Contact':
          result = await searchContacts({
            queryStr: query
          });
          break;

        case 'Lead':
          result = await searchLeads({
            queryStr: query
          });
          break;

        default:
          break;
      }
    } catch (err) {
      this.handleError(err);
    }
    this.processQueryResult(result);
  }

  getObjectType() {
    return this.objectType;
  }

  processQueryResult(result) {
    let entries = [];
    if (result.length > 0) {
      entries = this.makeResultEntries(result);
    }
    this.setResults(entries);
    this.openResultBox();
  }

  makeResultEntries(result) {
    const entryMaker = this.getEntryMaker();
    let entries = [];
    result.forEach(res => {
      const entry = entryMaker(res);
      entries.push(entry);
    });
    return entries;
  }

  getEntryMaker() {
    let maker;
    const objType = this.getObjectType();
    switch (objType) {
      case 'Contact':
        maker = this.makeEntryContact;
        break;

      case 'Lead':
        maker = this.makeEntryLead;
        break;

      default:
        break;
    }
    return maker;
  }

  makeEntryLead(lead) {
    const entry = {
      id: lead.Id,
      firstName: lead.FirstName,
      lastName: lead.LastName,
      account: lead.Company,
      email: lead.Email,
      iconName: 'standard:lead'
    };
    return entry;
  }

  makeEntryContact(contact) {
    var accountName = '';
    if (contact.Account != null) {
      accountName = contact.Account.Name;
    }
    const entry = {
      id: contact.Id,
      firstName: contact.FirstName,
      lastName: contact.LastName,
      account: accountName,
      email: contact.Email,
      iconName: 'standard:contact'
    };
    return entry;
  }

  setResults(entries) {
    if (entries.length === 0) {
      this.showNoResults();
    } else {
      this.hideNoResults();
    }
    this.results = entries;
  }

  // Results

  openResultBox() {
    const resultBox = this.getResultBox();
    this.showElement(resultBox);
  }

  closeResultBox() {
    const resultBox = this.getResultBox();
    this.hideElement(resultBox);
  }

  getResultBox() {
    const resultBox = this.template.querySelector('.resultbox');
    return resultBox;
  }

  showNoResults() {
    this.noResults = true;
  }

  hideNoResults() {
    this.noResults = false;
  }

  // Add attendee

  handleResultClick(event) {
    const recId = event.currentTarget.dataset.id;
    this.addNewAttendee(recId);
  }

  addNewAttendee(recId) {
    if (!this.attendeeExists(recId)) {
      this.makeAttendeeRecord(recId);
    } else {
      this.showToast('This participant already listed for this event', 'error');
    }
  }

  attendeeExists(recId) {
    const attendees = this.getAttendees();
    let exists = false;
    for (let i = 0; i < attendees.length; i++) {
      const att = attendees[i];
      const relatedId = this.getRelatedId(att);
      if (recId === relatedId) {
        exists = true;
        break;
      }
    }
    return exists;
  }

  makeAttendeeRecord(recId) {
    const attendee = this.prepNewAttendee(recId);
    makeEventAttendee({
      input: attendee
    })
      .then(newRecord => {
        this.finishAddAttendee(newRecord);
      }).catch(err => {
        this.handleError(err);
      });
  }

  prepNewAttendee(recId) {
    let input = {
      LunchAndLearnEvent__c: this.lunchEvent.Id,
      Course__c: this.lunchEvent.Course_Name__c,
      Lead__c: '',
      Contact__c: ''
    };
    const objType = this.getObjectType();
    switch (objType) {
      case 'Contact':
        input.Contact__c = recId;
        break;

      case 'Lead':
        input.Lead__c = recId;
        break;

      default:
        break;
    }
    return input;
  }

  finishAddAttendee(newRecord) {
    this.closeResultBox();
    this.showToast('Participant Added', 'success');
    const newEntry = this.prepareRowEntry(newRecord);
    this.addRow(newEntry);
  }

  addRow(newEntry) {
    const attendees = this.getAttendees();
    let updatedList = attendees.slice();
    updatedList.unshift(newEntry);
    this.setAttendees(updatedList);
  }

  getAttendees() {
    return this.attendees;
  }

  // Datatable

  handleRowSelect(event) {
    const selectedRows = event.detail.selectedRows;
    let recIds = [];
    if (selectedRows.length > 0) {
      recIds = this.extractIds(selectedRows);
      this.showDeleteButton();
    } else {
      this.hideDeleteButton();
    }
    this.setSelectedRowIds(recIds);
  }

  extractIds(selectedRows) {
    let ids = [];
    selectedRows.forEach(row => {
      ids.push(row.Id);
    });
    return ids;
  }

  setSelectedRowIds(recIds) {
    this.selectedRowIds = recIds;
  }

  showDeleteButton() {
    this.showDelete = true;
  }

  hideDeleteButton() {
    this.showDelete = false;
  }

  getModalRecordIdBatch() {
    return this.modalRecordIdBatch;
  }

  handleSort(event) {
    const field = event.detail.fieldName;
    const direction = event.detail.sortDirection;
    this.setSort(field, direction);
    this.sortCurrentRows();
  }

  setSort(field, direction) {
    this.sortedBy = field;
    this.sortedDirection = direction;
  }

  sortCurrentRows() {
    const attendees = this.getAttendees();
    const sorted = this.sortRows(attendees);
    this.setAttendees(sorted);
  }

  sortRows(rows) {
    const field = this.sortedBy;
    const direction = this.sortedDirection
    let sortedList = rows.slice();
    sortedList.sort((a, b) => {
      const aVal = a[field].toLowerCase();
      const bVal = b[field].toLowerCase();
      let result = -1;
      if (aVal > bVal) {
        result = 1;
      } else if (aVal === bVal) {
        result = 0;
      }
      return result;
    });
    if (direction == 'desc') {
      sortedList.reverse();
    }
    return sortedList;
  }

  // Actions & Modal

  handleRowMenuClick(event) {
    const action = event.detail.action.name;
    const attendeeId = event.detail.row.Id;
    this.setModalRecordId(attendeeId);
    this.openModal(action);
  }

  setModalRecordId(recId) {
    this.modalRecordId = recId;
  }

  openModal(action) {
    this.prepModal(action);
    this.showModalElement();
  }

  prepModal(action) {
    switch (action) {

      case 'create':
        this.prepModalCreate();
        break;

      case 'view':
        this.prepModalView();
        break;

      case 'edit':
        this.prepModalEdit();
        break;

      case 'delete':
        this.prepModalDelete();
        break;

      default:
        break;
    }

  }

  prepModalCreate() {
    this.modalTypeCreate = true;
  }

  getCreateMessage(recType) {
    return 'Create New ' + recType;
  }

  getCreateIcon(recType) {
    if (recType === 'Lead') {
      return 'action:new_lead';
    }
    if (recType === 'Contact') {
      return 'action:new_contact';
    }
  }

  prepModalView() {
    this.modalTypeView = true;
    this.setModalHeaderText('View Participant');
  }

  setModalHeaderText(text) {
    this.modalHeaderText = text;
  }

  prepModalEdit() {
    this.modalTypeEdit = true;
    this.setModalHeaderText('Edit Participant');
  }

  prepModalDelete() {
    this.modalTypeDelete = true;
    const text = this.getModalHeaderDelete();
    this.setModalHeaderText(text);
    const sldsContainer = this.getModalSLDSContainer();
    sldsContainer.classList.add('modal-delete');
  }

  getModalHeaderDelete() {
    const count = this.getModalRecordCount();
    let header = 'Delete ' + count + ' Participant';
    header = count > 1 ? header + 's' : header;
    return header;
  }

  showModalElement() {
    const modalContainer = this.getModalHiddenContainer();
    this.showElement(modalContainer);
  }

  getModalHiddenContainer() {
    const modalContainer = this.template.querySelector('.attendee-modal');
    return modalContainer;
  }

  getModalSLDSContainer() {
    const modalContainer = this.template.querySelector('.slds-modal__container');
    return modalContainer;
  }

  handleDeleteButtonClick(event) {
    this.setModalRecordIdBatch(this.selectedRowIds);
    this.openModal('delete');
  }

  setModalRecordIdBatch(recIds) {
    this.modalRecordIdBatch = recIds;
  }

  handleCreateSuccess(event) {
    const recId = event.detail.id;
    this.makeAttendeeRecord(recId);
    this.closeModal();
    console.log(JSON.stringify(event));
  }

  closeModal() {
    this.clearModalStyle();
    this.hideModalElement();
    this.resetModalProps();
  }

  clearModalStyle() {
    if (this.modalTypeDelete) {
      const sldsContainer = this.getModalSLDSContainer();
      sldsContainer.classList.remove('modal-delete');
    }
  }

  hideModalElement() {
    const modalContainer = this.getModalHiddenContainer();
    this.hideElement(modalContainer);
  }

  handleDeleteConfirm(event) {
    this.deleteRecords();
  }

  deleteRecords() {
    const ids = this.getDeleteIds();
    deleteAttendees({
      attendeeIds: ids
    }).then(() => {
      this.finishDelete();
    }).catch(err => {
      this.handleError(err);
    });
  }

  getDeleteIds() {
    let ids = [];
    const modalBatch = this.getModalRecordIdBatch();
    if (!this.arrayIsEmpty(modalBatch)) {
      ids = modalBatch;
    } else {
      const modalSingle = this.getModalRecordId();
      ids = [modalSingle];
    }
    return ids;
  }

  getModalRecordId() {
    return this.modalRecordId;
  }

  finishDelete() {
    const ids = this.getDeleteIds();
    this.removeRows(ids);
    const msg = this.getDeleteSuccessMessage();
    this.showToast(msg, 'success');
    this.closeModal();
  }

  getDeleteSuccessMessage() {
    const idCount = this.getModalRecordCount();
    let msg = '';
    if (idCount > 1) {
      msg = idCount + ' Participants Deleted';
    } else {
      msg = 'Participant Deleted'
    }
    return msg;
  }

  getModalRecordCount() {
    let count = 0;
    const ids = this.getModalRecordIdBatch();
    if (this.arrayIsEmpty(ids)) {
      count = 1;
    } else {
      count = ids.length;
    }
    return count;
  }

  arrayIsEmpty(arr) {
    return (
      arr === null ||
      arr.length === 0
    );
  }

  removeRows(rowIds) {
    const attendees = this.getAttendees();
    const filteredAttendees = attendees.filter(attendee => {
      const result = !rowIds.includes(attendee.Id);
      return result;
    });
    this.setAttendees(filteredAttendees);
  }

  handleSave(event) {
    this.showToast('Participant Updated', 'success');
    this.closeModal();
  }

  // Create new lead / contact
  handleCreateClick(event) {
    this.openModal('create');
  }

  // General utils

  hideElement(elem) {
    elem.classList.add('slds-hide');
  }

  showElement(elem) {
    elem.classList.remove('slds-hide');
  }

  handleModalError(event) {
    console.log(JSON.stringify(event));
  }

  handleError(err) {
    let message = '';
    if (err.body) {
      if (typeof err.body === 'string') {
        message = err.body;
      } else if (err.body.message) {
        message = err.body.message;
      }
    } else if (err.message) {
      message = err.message;
    }
    console.error(message);
    if (err.stack) {
      console.error(err.stack);
    }
    this.showToast(message, 'error');
  }

  showToast(msg, type) {
    const toast = new ShowToastEvent({
      message: msg,
      variant: type
    });
    this.dispatchEvent(toast);
  }

  stopLoading() {
    this.loading = false;
  }

}