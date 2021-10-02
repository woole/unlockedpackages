import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPP_OBJECT from '@salesforce/schema/Opportunity';

export default class OppStageDependentPicklist extends LightningElement {

    // Reactive variables
    @track controllingValues = [];
    @track dependentValues = [];
    @track dependentLevel1Values = [];
    @track dependentLevel2Values = [];
    @track dependentLevel3Values = [];
    @track completedMessage = '';

    @track selectedStage;
    @track selectedWinLossRejectReason;
    @track selectedWinLossRejectLevel1;
    @track selectedWinLossRejectLevel2;
    @track selectedWinLossRejectLevel3;
    @track selectedWinLossRejectComments;
    @track isEmpty = false;
    @track error;

    @track showClass1 = 'slds-col  slds-hide';
    @track showClass2 = 'slds-col  slds-hide';
    @track showClass3 = 'slds-col  slds-hide';
    @track showClass4 = 'slds-col  slds-hide';
    @track showClassInputText = 'slds-col slds-hide';

    

    controlValues;
    controlLevel1Values;
    controlLevel2Values;
    controlLevel3Values;
    totalDependentValues = [];
    totalDependentLevel1Values = [];
    totalDependentLevel2Values = [];
    totalDependentLevel3Values = [];
    winlossDefaultOptions = [{
        label: '--None--',
        value: '--None--'
    }];
    labelNone = '--None--';
    

    //@api selectedStageFlow;
    @api selectedStageFlow;
    @api selectedWinLossRejectReasonFlow;
    @api selectedWinLossRejectLevel1Flow;
    @api selectedWinLossRejectLevel2Flow;
    @api selectedWinLossRejectLevel3Flow;
    @api selectedWinLossRejectCommentsFlow;


    // Opportunity object info
    @wire(getObjectInfo, {
        objectApiName: OPP_OBJECT
    })
    objectInfo;

    // Picklist values based on record type
    //If moving to DX this recordtypeid doesn't work
    @wire(getPicklistValuesByRecordType, {
        objectApiName: OPP_OBJECT,
        recordTypeId: '0121o000000wulLAAQ'
    })
    stagePicklistValues({
        error,
        data
    }) {


        if (data) {
            this.error = null;
            let stageOptions = [{
                label: 'Closed Won',
                value: 'Closed Won'
            },
            {
                label: 'Closed Lost',
                value: 'Closed Lost'
            }
            ];
            this.controllingValues = stageOptions;

            
            let winlossrejectOptions = this.winlossDefaultOptions;
            this.controlValues = data.picklistFieldValues.Why_We_Lost__c.controllerValues;
            this.totalDependentValues = data.picklistFieldValues.Why_We_Lost__c.values;
            this.totalDependentValues.forEach(key => {
                winlossrejectOptions.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.dependentValues = winlossrejectOptions;

           

            let winlossrejectLevel1Options = this.winlossDefaultOptions;
            this.controlLevel1Values = data.picklistFieldValues.Win_Loss_Reject_Reasons_Level1__c.controllerValues;

            this.totalDependentLevel1Values = data.picklistFieldValues.Win_Loss_Reject_Reasons_Level1__c.values;
            this.totalDependentLevel1Values.forEach(key => {
                winlossrejectLevel1Options.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.dependentLevel1Values = winlossrejectLevel1Options;

            let winlossrejectLevel2Options = this.winlossDefaultOptions;
            this.controlLevel2Values = data.picklistFieldValues.Win_Loss_Reject_Reasons_Level2__c.controllerValues;
            this.totalDependentLevel2Values = data.picklistFieldValues.Win_Loss_Reject_Reasons_Level2__c.values;
            this.totalDependentLevel2Values.forEach(key => {
                winlossrejectLevel2Options.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.dependentLevel2Values = winlossrejectLevel2Options;

            let winlossrejectLevel3Options = this.winlossDefaultOptions;
            this.controlLevel3Values = data.picklistFieldValues.Win_Loss_Reject_Reasons_Level3__c.controllerValues;
            this.totalDependentLevel3Values = data.picklistFieldValues.Win_Loss_Reject_Reasons_Level3__c.values;
            this.totalDependentLevel3Values.forEach(key => {
                winlossrejectLevel3Options.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.dependentLevel3Values = winlossrejectLevel3Options;



        } else if (error) {
            this.error = JSON.stringify(error);
        }


    }


    //getter property from statusOptions which return the items array
    get statusOptions() {
        return this.controllingValues;
    }

    showClassBasedonLevel(level0, level1, level2, level3, level4) {


        if (level0 === true) {
            this.showClass1 = 'slds-col slds-hide';
            this.showClass2 = 'slds-col slds-hide';
            this.showClass3 = 'slds-col slds-hide';
            this.showClass4 = 'slds-col  slds-hide';
        }
        if (level1 === true) {
        this.showClass1 = 'slds-col';
            this.showClass2 = 'slds-col  slds-hide';
            this.showClass3 = 'slds-col  slds-hide';
            this.showClass4 = 'slds-col slds-hide';
        }
        if (level2 === true) {
            this.showClass1 = 'slds-col';
            this.showClass2 = 'slds-col ';
            this.showClass3 = 'slds-col slds-hide';
            this.showClass4 = 'slds-col slds-hide';
        }
        if (level3 === true) {
            this.showClass1 = 'slds-col';
            this.showClass2 = 'slds-col ';
            this.showClass3 = 'slds-col';
            this.showClass4 = 'slds-col slds-hide';
        }
        if (level4 === true) {
            this.showClass1 = 'slds-col';
            this.showClass2 = 'slds-col ';
            this.showClass3 = 'slds-col';
            this.showClass4 = 'slds-col ';
        }

    }


    handleStageNameChange(event) {

        this.showClassBasedonLevel(true, false, false, false, false);
        this.selectedStage = event.target.value;
        this.selectedStageFlow = this.selectedStage;
        this.isEmpty = false;
        let dependValues = [];

        if (this.selectedStage) {
            // if Selected stage is none returns nothing
            if (this.selectedStage === this.labelNone) {
                this.isEmpty = true;
                dependValues = this.winlossDefaultOptions;
                this.selectedStage = null;
                this.selectedWinLossRejectReason = null;
                this.selectedWinLossRejectLevel1 = null;
                return;
            }

            // filter the total dependent values based on selected stage value 
            this.totalDependentValues.forEach(
                conValues => {

                    if (conValues.validFor.includes(this.controlValues[this.selectedStage])) {
                    dependValues.push({
                            label: conValues.label,
                            value: conValues.value
                        })
                    }
                })

           this.dependentValues = dependValues;
           if (dependValues.length > 0) {
             this.showClassBasedonLevel(false, true, false, false, false);
             } else {
                this.showClassInputText = 'slds-col slds-form-element';
             }

        }

    }

    handleWinLossRejectChange(event) {

        this.showClassBasedonLevel(false, true, false, false, false);
        this.selectedWinLossRejectReason = event.target.value;
        this.selectedWinLossRejectReasonFlow = this.selectedWinLossRejectReason;
        this.isEmpty = false;
        let dependValues = [];

        if (this.selectedWinLossRejectReason) {
            // if Selected stage is none returns nothing
            if (this.selectedWinLossRejectReason === this.labelNone) {
                this.isEmpty = true;
                dependValues = this.winlossDefaultOptions;
             return;
            }

            // filter the total dependent values based on selected stage value 
            this.totalDependentLevel1Values.forEach(conValues => {
             if (conValues.validFor.includes(this.controlLevel1Values[this.selectedWinLossRejectReason])) {
                dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })
            this.dependentLevel1Values = dependValues;

            if (dependValues.length > 0) {

                this.showClassBasedonLevel(false, false, true, false, false);
            } else {
                this.showClassInputText = 'slds-col';
            }

        }

    }


    handleWinLossRejectLevel1Change(event) {

        this.showClassBasedonLevel(false, false, true, false, false);
        this.selectedWinLossRejectLevel1 = event.target.value;
        this.selectedWinLossRejectLevel1Flow = this.selectedWinLossRejectLevel1;
        this.isEmpty = false;
        let dependValues = [];


        if (this.selectedWinLossRejectLevel1) {
            // if Selected stage is none returns nothing
            if (this.selectedWinLossRejectLevel1 === this.labelNone) {
                this.isEmpty = true;
                dependValues = this.winlossDefaultOptions;
                return;
            }

            // filter the total dependent values based on selected stage value 
            this.totalDependentLevel2Values.forEach(conValues => {
                if (conValues.validFor.includes(this.controlLevel2Values[this.selectedWinLossRejectLevel1])) {

                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

           this.dependentLevel2Values = dependValues;
            if (dependValues.length > 0) {

                this.showClassBasedonLevel(false, false, false, true, false);
            }
        }
    }


    handleWinLossRejectLevel2Change(event) {
        this.showClassBasedonLevel(false, false, false, true, false);
        this.selectedWinLossRejectLevel2 = event.target.value;
        this.selectedWinLossRejectLevel2Flow = this.selectedWinLossRejectLevel2;
        this.isEmpty = false;
        let dependValues = [];

        if (this.selectedWinLossRejectLevel2) {
            // if Selected stage is none returns nothing
            if (this.selectedWinLossRejectLevel2 === this.labelNone) {
                this.isEmpty = true;
                dependValues = this.winlossDefaultOptions;
                return;
            }

            // filter the total dependent values based on selected stage value 
            this.totalDependentLevel3Values.forEach(conValues => {
                if (conValues.validFor.includes(this.controlLevel3Values[this.selectedWinLossRejectLevel2])) {

                    dependValues.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            })

          this.dependentLevel3Values = dependValues;
             if (dependValues.length > 0) {
                this.showClassBasedonLevel(false, false, false, false, true);
             }
             else {
                this.showClassInputText = 'slds-col';
            }
        }
    }


    handleWinLossRejectLevel3Change(event) {
        this.selectedWinLossRejectLevel3 = event.target.value;
        this.selectedWinLossRejectLevel3Flow = this.selectedWinLossRejectLevel3;
        this.showClassInputText = 'slds-col';
    }

    handleWinLossRejectComments(event) {
        this.selectedWinLossRejectComments = event.target.value;
        this.selectedWinLossRejectCommentsFlow = this.selectedWinLossRejectComments;

    }

}