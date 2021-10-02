import { LightningElement, wire, api } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class WireGetPicklistValuesByRecordType extends LightningElement {
    picklistValues;
    error;
    @api recordTypeId;
    @api fieldApiName;
    @api fieldLabelName;
    @api objectApiName;
    @api selectedValue;
    @api selectedValueInFlow;
    @api isRequired;
    picklistOptions = [];

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: '$objectApiName',
        recordTypeId: '$recordTypeId'
    })
    wiredValues({ error, data }) {
        if (data) {
            this.picklistValues = this.buildPicklistOptions(data.picklistFieldValues);
            console.log('data.picklistFieldValues', data.picklistFieldValues);
            this.error = undefined;
        } else {
            this.error = error;
            this.picklistValues = undefined;
        }
    }

    buildPicklistOptions(picklistValues) {

        Object.keys(picklistValues).filter((picklist) => picklist === this.fieldApiName).forEach((picklist) => {
            picklistValues[picklist].values.map((item) =>
                this.picklistOptions = [...this.picklistOptions, { value: item.value, label: item.label }]);
        });
    }


    //getter property from statusOptions which return the items array
    get PicklistOptions() {
        console.log(this.picklistOptions);
        return this.picklistOptions;
    }

    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedValue = event.detail.value;
        this.selectedValueInFlow = this.selectedValue;
    }


}