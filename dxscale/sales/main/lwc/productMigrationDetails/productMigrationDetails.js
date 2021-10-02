import { LightningElement, api } from 'lwc';
import PRODUCTMIGRATION_FIELD from '@salesforce/schema/Opportunity.Migrating_from_Product__c';

export default class ProductMigrationDetails extends LightningElement {
    // Expose a field to make it available in the template
    fields = [PRODUCTMIGRATION_FIELD];

    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
}