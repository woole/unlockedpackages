import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import AllSecondaryOpportunityPartners from '@salesforce/apex/MakePrimaryPartner.getAllSecondaryOpportunityPartners';
import ChangePrimaryPartner from '@salesforce/apex/MakePrimaryPartner.changePrimaryPartner';
import DeletePartner from '@salesforce/apex/MakePrimaryPartner.deletePartner';
import PrimaryOpportunityPartner from '@salesforce/apex/MakePrimaryPartner.getPrimaryOpportunityPartner';

const actions = [
    { label: 'Mark Primary', name: 'markprimary' },
    { label: 'Delete', name: 'delete' }
];

const deleteaction = [
    { label: 'Delete', name: 'delete' }
];
export default class EditOpportunityPartner extends NavigationMixin(LightningElement) {
    primarycolumns = [
        {
            label: 'Account',
            fieldName: 'AccountUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'AccountName' },
                target: '_parent'
            }
        },
        { label: 'Role', fieldName: 'Role', sortable: false },
        {
            type: 'action',
            typeAttributes: { rowActions: deleteaction }
        }
    ];


    columns = [
        {
            label: 'Account',
            fieldName: 'AccountUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'AccountName' },
                target: '_parent'
            }
        },
        { label: 'Role', fieldName: 'Role', sortable: false },
        {
            type: 'action',
            typeAttributes: { rowActions: actions }
        }
    ];

    @api recordId;
    error;
    viewPrimaryPartner = [];
    viewPrimaryPartnerList;
    viewOpportunityPartnerList;
    tempList = [];
    selRowId = null;
    notifytitle;
    notifyvariant;
    notifymessage;

    //function to get all Partners except primary
    @wire(AllSecondaryOpportunityPartners, { oppId: '$recordId' })
    handleViewPartners(result) {

        this.tempList = result;

        if (result.data) {
            this.populateLightningTableData(result.data);
            this.error = undefined;
        }
        else if (result.error) {
            this.error = error;
        }
    }

    //function to get Partners primary
    @wire(PrimaryOpportunityPartner, { oppId: '$recordId' })
    handlePrimaryPartner(result) {
        this.viewPrimaryPartner = result;

        if (result.data) {
            let res1 = result.data;
            try {
                let AccountName;
                let AccountUrl;
                this.viewPrimaryPartnerList = res1.map(row => {
                    AccountUrl = `/${row.AccountToId}`;
                    AccountName = row.AccountTo.Name;
                    return { ...row, AccountUrl, AccountName }
                });
            }
            catch (error) {
                this.error = error;
            }
            this.error = undefined;
        }
        else if (result.error) {
            this.error = error;
        }
    }

    // function to build the lightning datatable
    populateLightningTableData(result) {
        try {
            let AccountName;
            let AccountUrl;
            this.viewOpportunityPartnerList = result.map(row => {
                AccountUrl = `/${row.AccountToId}`;
                AccountName = row.AccountTo.Name;
                return { ...row, AccountUrl, AccountName }
            });
        }
        catch (error) {
            this.error = error;
        }
    }

    // New Partner Creation
    navigateToNewOpportunityPartner() {
        let defaultValues = encodeDefaultFieldValues({
            OpportunityId: this.recordId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'OpportunityPartner',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });

        refreshApex(this.tempList);
        refreshApex(this.viewPrimaryPartner);
    }

    // To show toast message
    showNotification(notifytitle, notifymessage, notifyvariant) {
        const evt = new ShowToastEvent({
            title: notifytitle,
            message: notifymessage,
            variant: notifyvariant,
        });
        this.dispatchEvent(evt);
    }

    // To Mark Partner as Primary
    handleClick(recId) {
        ChangePrimaryPartner({ PartnerId: recId })
            .then((result) => {
                this.showNotification('Success', 'Partner marked as Primary', 'success');
                refreshApex(this.tempList);
                refreshApex(this.viewPrimaryPartner);
            })
            .catch(error => {
                this.showNotification('Error', 'Error', 'error');
                this.error = error;
            });
    }

    // To delete an opportunity partner
    handleDelete(recId) {
        DeletePartner({ PartnerId: recId })
            .then((result) => {
                this.showNotification('Success', 'Record successfully deleted', 'success');
                refreshApex(this.tempList);
                refreshApex(this.viewPrimaryPartner);
            })
            .catch(error => {
                this.showNotification('Error', 'Error', 'error');
                this.error = error;
            });
    }

    // Row Actions
    handleRowAction(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        switch (actionName) {
            case 'markprimary':
                this.handleClick(row.Id);
                break;
            case 'delete':
                this.handleDelete(row.Id);
                break;
            default:
        }

    }
}