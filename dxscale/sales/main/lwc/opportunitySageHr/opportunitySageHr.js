import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import INDUSTRY_FIELD from '@salesforce/schema/Opportunity.Account.Industry';
import NUMBER_OF_EMPLOYEES_FIELD from '@salesforce/schema/Opportunity.Account.Number_of_Employees__c';

const fields = [INDUSTRY_FIELD, NUMBER_OF_EMPLOYEES_FIELD];

export default class LeadDetail extends NavigationMixin(LightningElement) 
    { 
        
  @api recordId; @api objectApiName; 
    
  @track disabledSave = true;

  handleChange(event){
      this.disabledSave = false;
  }
  
  handleSave() {
    this.handleRecordSave();
    this.disabledSave = true;
  }
  
  handleCancel(event) {
      this.disabledSave = true;
      const inputFields = this.template.querySelectorAll(
          'lightning-input-field'
      );
      if (inputFields) {
          inputFields.forEach(field => {
              field.reset();
          });
      }
      this.dispatchEvent(
          new ShowToastEvent({
              title: '',
              message: 'Modifications on this page are removed and not saved.',
              variant: 'success',
              mode: 'dismissable'
          }),
      );  
  }

  handleReset(event) {
    const inputFields = this.template.querySelectorAll(
      'lightning-input-field'
    );
    if (inputFields) {
      inputFields.forEach(field => {
        field.reset();
      });
    }
  }
  
  handleSuccess(event) {
      this.handleReset();
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: this.recordId,
          objectApiName: 'Lead',
          actionName: 'view'
        },
      });        
    this.dispatchEvent(
      new ShowToastEvent({
          title: '',
          message: event.detail.apiName + ' saved.',
          variant: 'success',
          mode: 'dismissable'
      }),
  ); 
  }
  
  handleRecordSave() {
    this.template.querySelector('lightning-record-edit-form').submit(this.fields);
  }

  @wire(getRecord, { recordId: '$recordId', fields })
  opportunity;

  get industry() {
      return getFieldValue(this.opportunity.data, INDUSTRY_FIELD);
  }

  get employees() {
      return getFieldValue(this.opportunity.data, NUMBER_OF_EMPLOYEES_FIELD);
  }
}