/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
import Card1Headline from '@salesforce/label/c.Card1Headline';
import Card2Headline from '@salesforce/label/c.Card2Headline';
import getAccountId from '@salesforce/apex/KeyAccountInfoCtrl.getRecordId';
import getAccountExtra from '@salesforce/apex/KeyAccountInfoCtrl.getAccountExtra';
import getAcccountPartner from '@salesforce/apex/KeyAccountInfoCtrl.getAcccountPartner';
import getAccountPrompt from '@salesforce/apex/KeyAccountInfoCtrl.getAccountPrompt';
import getCustomerInteraction from '@salesforce/apex/KeyAccountInfoCtrl.getCustomerInteraction';
import getAccountOriginInfo from '@salesforce/apex/KeyAccountInfoCtrl.getAccountOriginInfo';

/* eslint no-console: "error" */
export default class KeyAccountInfo extends LightningElement {

    @api recordId;
    @api globalAccountId;
    
    
    @api invokerId;
    @api title ='Title';
    label = {
        Card1Headline,
        Card2Headline,
    };
    
    @api objectApiName;

    
    @track error;
    @track cardone = [];
    @track cardtwo = [];
    @track showCard1 = false;
    @track showCard2 = false;
    @track showLoading = true;
    @track showNoRecords = false;


    @track infoMessage = "Loading...";
    @track dataUnavailable = false;    
    @track accountId;

    @wire(getAccountExtra) accExtra;
    @wire(getAccountPrompt) accPrompts;
    @wire(getAcccountPartner) accPartners;
    @wire(getCustomerInteraction) accCustInter;
    @wire(getAccountOriginInfo) accOriginInfo;
    noCalls = 0;

    connectedCallback() {
        //As this can be added to and Account record or any Object with a field called Account we first workout the recordId
        getAccountId({ recordId : this.recordId, objectApiName : this.objectApiName, globalAccountId : this.globalAccountId})
        .then(result => {
            this.accountId = result;
        }).catch(error => {
            this.processError(error);
        }).finally(() => {
            //then we do the async call for the data
            this.fetchData(this.accountId);
        })         
     
    }

    async fetchData(recId){
        console.log('fetching for account : ' + recId);
       await getAccountExtra({ recordId : recId, invokerId : this.invokerId})
            .then(result => {
                
                this.processInfoItems('getAccountExtra',result);
            }).catch(error => {
                this.processError(error);
            }).finally(() => {
                this.checkCards();
            })
        await getAccountPrompt({ recordId : recId, invokerId : this.invokerId})
            .then(result => {
                
                this.processInfoItems('getAccountPrompt',result);
            }).catch(error => {
                this.processError(error);
            }).finally(() => {
                this.checkCards();
            })
        await getAcccountPartner({ recordId : recId, invokerId : this.invokerId})
            .then(result => {
                this.processInfoItems('getAcccountPartner',result);

            }).catch(error => {
                this.processError(error);
            }).finally(() => {
                this.checkCards();
            })
        await getCustomerInteraction({ recordId : recId, invokerId : this.invokerId})
            .then(result => {
                this.processInfoItems('getCustomerInteraction',result);
                
            }).catch(error => {
                this.processError(error);
            }).finally(() => {
                this.checkCards();
            })     
        await getAccountOriginInfo({ recordId : recId, invokerId : this.invokerId, globalAccountId : this.globalAccountId})
            .then(result => {
                this.processInfoItems('getAccountOriginInfo',result);
                
            }).catch(error => {
                this.processError(error);
            }).finally(() => {
                this.checkCards();
            }) 
    }
    
    checkCards(){
        this.noCalls++;
        if(!this.showCard1 && this.cardone.length > 0){
            this.showCard1 = true;
            this.showLoading = false;
        }
        if(!this.showCard2 && this.cardtwo.length > 0){
            this.showCard2 = true;
            this.showLoading = false;
        }
        //all calls but no data ?
        if(this.noCalls === 3 && (!this.showCard2 && !this.showCard1)){
            this.showLoading = false;
            this.showNoRecords = true
        }

    }
    

    processError(error){

        this.infoMessage = 'Unknown error';
        this.dataUnavailable = true;
        if (Array.isArray(error.body)) {
            this.infoMessage = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.infoMessage = error.body.message;
        }
    }
    processInfoItems(method,result) {

        if (result) {
            console.log(method+'->'+JSON.stringify(result));
            let fOne = result.filter(info => info.priority === 1);
            let fTwo = result.filter(info => info.priority === 2);
            this.cardone = this.cardone.concat(fOne);
            this.cardtwo = this.cardtwo.concat(fTwo);
            
            console.log('cardone->'+JSON.stringify(this.cardone));
            console.log('cardtwo->'+JSON.stringify(this.cardtwo));
        }
    }    


}