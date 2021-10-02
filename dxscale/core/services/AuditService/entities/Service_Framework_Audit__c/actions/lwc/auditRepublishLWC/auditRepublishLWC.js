import { LightningElement,api, track  } from 'lwc';
import rerun from '@salesforce/apex/AuditRepublish.rerun';
import getInput from '@salesforce/apex/AuditRepublish.getInput';



export default class AuditRepublishLWC extends LightningElement {
    @api recordId;
    @api inputMessage;
    @track state;
    @track errorMessage;    
    @track returnMessage;

    async connectedCallback() {

        console.log('connectedCallback');

        getInput({ recordId : this.recordId}).then(result => {
            console.log('recordId',this.recordId);
            console.log('getInput result',result);
            this.inputMessage = result;
        })
    }

    handleClick(){
        rerun({ recordId : this.recordId, inputMessage : this.inputMessage}).then(result => {
            console.log('recordId',this.recordId);
            console.log('rerun result',result);
            this.returnMessage = result.returnMessage;
        });
    }


    handleChange(event) {
        const field = event.target.name;
        if (field === 'inputMessage') {
            this.inputMessage = event.target.value;
        }
    }

}