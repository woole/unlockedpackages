import { LightningElement, api } from 'lwc';

export default class GenerateLightningURL extends LightningElement {


    @api recordId;
    @api recordName;

    recordURL;

    connectedCallback() {
        this.recordURL = window.location.href.split('lightning/')[0] + this.recordId;

    }
}