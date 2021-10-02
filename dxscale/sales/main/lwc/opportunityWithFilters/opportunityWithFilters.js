import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllOpportunities from '@salesforce/apex/OpportunityWithFilterController.getAllOpportunities';
import getOpenOpportunities from '@salesforce/apex/OpportunityWithFilterController.getOpenOpportunities';
import getClosedWonOpportunities from '@salesforce/apex/OpportunityWithFilterController.getClosedWonOpportunities';
import getClosedLostOpportunities from '@salesforce/apex/OpportunityWithFilterController.getClosedLostOpportunities';

export default class OpportunityWithFilters extends NavigationMixin(LightningElement) {

    //Colummn to be displayed
    columns = [
        {
            label: 'Opportunity name',
            fieldName: 'oppUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_parent'
            },
            initialWidth: 160
        },
        { label: 'Roll up of Opp Products', fieldName: 'Roll_up_of_Opp_Products__c', sortable: true, initialWidth: 190 },
        { label: 'Owner Full Name', fieldName: 'OwnerFullName', sortable: true, initialWidth: 160},
        { label: 'Total Contract Value (TCV)', fieldName: 'Total_Contract_Value_TCV_forecast__c', type: 'currency', sortable: true },
        { label: 'Opportunity Type', fieldName: 'Type', sortable: true },
        { label: 'Product Allocation Group', fieldName: 'Product_Allocation_Group__c', sortable: true },
        { label: 'Stage', fieldName: 'StageName', sortable: true },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date-local', sortable: true }

    ];

    @api recordId;
    error;
    openOppList;
    closedWonOppList;
    closedLostOppList;
    allOppList;
    viewOppList;
    sortBy;
    sortDirection;

    //sort by Columns
    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.viewOppList));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.viewOppList = parseData;
    }

    //to Display Open Opportunities
    handleOpenOpps() {
        getOpenOpportunities({ recordAccId: this.recordId })
            .then(
                result => {
                    this.populateLightningTableData(result);
                })
            .catch(error => {
                this.error;
            })
    }

    connectedCallback() {
        this.handleOpenOpps();
    }

    //to Display Closed Won Opportunities
    handleClosedWonOpps() {
        getClosedWonOpportunities({ recordAccId: this.recordId })
            .then(
                result => {
                    this.populateLightningTableData(result);
                })
            .catch(error => {
                this.error;
            })
    }

    //to Display Closed Lost Opportunities
    handleClosedLostOpps() {
        getClosedLostOpportunities({ recordAccId: this.recordId })
            .then(
                result => {
                    this.populateLightningTableData(result);
                })
            .catch(error => {
                this.error;
            })
    }

    //to Display Closed All Opportunities
    handleAllOpps() {
        getAllOpportunities({ recordAccId: this.recordId })
            .then(
                result => {
                    this.populateLightningTableData(result);
                })
            .catch(error => {
                this.error;
            })
    }

    //to Create New Opportunity
    navigateToNewOpportunity() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            },
            state: {
                useRecordTypeCheck: 1
            }
        });
    }

    // function to build the lightning datatable
    populateLightningTableData(result) {
        let oppUrl;
        let OwnerFullName;
        let CreatedByName;
        this.viewOppList = result.map(row => {
            oppUrl = `/${row.Id}`;
            OwnerFullName = row.Owner.Name;
            CreatedByName = row.CreatedBy.Name;
            return { ...row, oppUrl, OwnerFullName, CreatedByName }
        });
    }

}