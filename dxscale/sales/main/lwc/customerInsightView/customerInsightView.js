import { LightningElement, api } from 'lwc';
import checkIsEditable from '@salesforce/apex/CustomerInsightViewController.getInsightFieldAccess';


export default class CustomerInsightView extends LightningElement {
    @api recordId;
    isEditable = false;

    connectedCallback() {
        checkIsEditable()
        .then(result => {
            this.isEditable = result;
        })
        .catch(error => {
            this.error = error;
        });
    }

    showToast(){
        alert('Record Updated Successfully');
    }
}