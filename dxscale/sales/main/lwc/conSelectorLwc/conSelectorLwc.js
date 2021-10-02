import { LightningElement, api, wire } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';


import JOB_ROLE from '@salesforce/schema/Contact.Job_Role__c';
import MOBILE from '@salesforce/schema/Contact.MobilePhone';
import PRIMARY from '@salesforce/schema/Contact.Primary__c';
import ALLOW_CALL from '@salesforce/schema/Contact.Allow_Call__c';
import PHONE from '@salesforce/schema/Contact.Phone';
import DONOTCALL from '@salesforce/schema/Contact.DoNotCall';
import OPTOUT_EMAIL from '@salesforce/schema/Contact.HasOptedOutOfEmail';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import TPSMOBILE_FIELD from '@salesforce/schema/Contact.TPS_Mobile__c';
import TPSPHONE_FIELD from '@salesforce/schema/Contact.TPS_Phone__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Contact.Description';
import MAILINGCOUNTRY_FIELD from '@salesforce/schema/Contact.MailingCountry';
import HARDBOUNCE_FIELD from '@salesforce/schema/Contact.HardBounce__c';

const FIELDS = ['Contact.Name', 'Contact.Local_CRM_Account_ID__c', 'Contact.MailingCountry'];

export default class ContactRecord extends LightningElement {
    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
    isModalOpen = false;
    contactName;
    warningMessage;
    lcrmAccountId;
    mailingCountry;


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.contactName = data.fields.Name.value;
            this.lcrmAccountId = data.fields.Local_CRM_Account_ID__c.value;
            this.mailingCountry = data.fields.MailingCountry.value;

        }
    }

    fields = [JOB_ROLE, PRIMARY, MOBILE, ALLOW_CALL, TPSMOBILE_FIELD, DONOTCALL, PHONE, EMAIL_FIELD, TPSPHONE_FIELD, OPTOUT_EMAIL, HARDBOUNCE_FIELD, DESCRIPTION_FIELD];

    handleSubmit(event) {
        //you can change values from here
        //const fields = event.detail.fields;
        //fields.Name = 'My Custom  Name'; // modify a field
        console.log('Contact detail : ', event.detail.fields);
        console.log('Contact name : ', event.detail.fields.Name);
    }

    openModal(event) {
        console.log(this.lcrmAccountId);
        if (this.lcrmAccountId != null && (this.mailingCountry == "United Kingdom" || this.mailingCountry == "Ireland")) {
            this.warningMessage = 'This account is synced to Intouch. Only the Primary Contact field can be amended. All other amendments must be carried out in Intouch.';
        }
        const contactSelection = new CustomEvent("contactselection", {
            detail: this.recordId
        });
        this.dispatchEvent(contactSelection);
        this.isModalOpen = true;
    }

    closeModal(event) {
        this.isModalOpen = false;
    }

    proceedNext(event) {
        const contactSelection = new CustomEvent("contactselection", {
            detail: this.recordId
        });
        this.dispatchEvent(contactSelection);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);

    }
}