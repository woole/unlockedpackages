import { LightningElement, api, wire } from 'lwc';
import getContactList from '@salesforce/apex/CustomContactObjectSearch.getContactList';
import getContacts from '@salesforce/apex/CustomContactObjectSearch.getContacts';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Account.Name'];

export default class customSearch extends LightningElement {

  contactRecords;
  @api recordId;
  @api contactId;
  searchValue = '';
  error = '';
  accountName;
  showSearch= true;

  rowOffset = 0;

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) 
    wireuser({
        error,
        data
    }) {
    if (error) {
      this.error = error ; 
    } else if (data) {
        this.accountName = data.fields.Name.value;
    }
  }

  connectedCallback(){
    getContacts({accountId: this.recordId})
    .then(result => {
        console.log(result);
        if(result != null){
            this.contactRecords = result;
            this.showSearch = false;
        }
        // set @track contacts variable with return contact list from server  
      })
      .catch(error => {
        this.error = error;

        const event = new ShowToastEvent({
          title: 'Error',
          variant: 'error',
          message: error.body.message,
        });
        this.dispatchEvent(event);
        // reset contacts var with null   
        this.contactsRecord = null;
      });
  }
  

  // update searchValue var when input field value change
  searchKeyword(event) {
    console.log('_____account______',this.account);
    this.searchValue = event.target.value;
  }

  handleShowAll(event){
    this.searchValue = 'all';
    this.handleSearchKeyword();
  }

  // call apex method on button click 
  handleSearchKeyword() {
    this.contactRecords = null;
    console.log('_____Account Id________-',this.recordId);
    if (this.searchValue !== '') {
      getContactList({
        accountId: this.recordId, searchKey: this.searchValue
      })
        .then(result => {
          // set @track contacts variable with return contact list from server  
          this.contactRecords = result;

        })
        .catch(error => {
          this.error = error;

          const event = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: error.body.message,
          });
          this.dispatchEvent(event);
          // reset contacts var with null   
          this.contactsRecord = null;
        });
    } else {
      // fire toast event if input field is blank
      const event = new ShowToastEvent({
        variant: 'error',
        message: 'Search text missing..',
      });
      this.dispatchEvent(event);
    }
  }

  handleContactSelection(event){
      this.contactId = event.detail;
  }
}