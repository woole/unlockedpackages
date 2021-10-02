import { LightningElement, api, wire, track } from 'lwc';
import fetchData from '@salesforce/apex/QueryGridDisplayController.fetchData';
import getJSONConfig from '@salesforce/apex/QueryGridDisplayController.getJSONConfig';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import myResource from '@salesforce/resourceUrl/queryGrid_styles'; 

export default class SampleInvokeService extends LightningElement {

    @api recordId;   
    @api objectApiName;
    @api globalAccountId;
    @api invokerId ='Service_A';   
    @api screenExplanation ='On Screen Explanation';   
    @api title ='Title';   
    @api columns;
    @api PageComponentId;
    @track filteringWords;
 
    @track state;
    @track errorMessage;
    @track hasError = false;
    @track potentiallyMoreRows = false;
    @track showFilterBox = false;
    @track fullData = []; // full retrieved data set
    @track displayData = []; // potentially filtered data set

    @track tableClassName;
    @track tableStyle = 'height:200px';
    
    //if not data row are returned use this to show message
    @track hasDataToShow = false;
    @track showLoading = true;

    @track sortBy;
    @track sortDirection = 'asc';    
    @track searchTerm = '';

    

    filterInitialQuery;
    configurationObject;

    objectLevel;

    //stylingFilter are defined at the field level and then applied to any data containing the value.
    stylingFilter = [];
    
    //searchFilters are pre-defined txt filters that can be applied to the data
    searchFilter;
    


    async connectedCallback() {
        loadStyle(this, myResource);
        this.checkStyles();
        await getJSONConfig({ pageComponentId : this.PageComponentId})
        .then(result => {
            this.parseMasterConfig(result);

            fetchData({ recordId : this.recordId, objectApiName : this.objectApiName, globalAccountId : this.globalAccountId, invokerId : this.invokerId, masterConfig : this.objectLevel})
                .then(result => {
                    this.fetchDataAction(result);
                })
                .catch(error => {
                    this.hasError = true;
                    this.state = 'Data Retrieval Error';
                    this.error = error;
                });        
        })
        .catch(error => {
            this.hasError = true;
            this.state = 'Configuration Error';
            this.error = error;
        });        
    }

    handleError(result){
    
        this.hasError = true;
        this.state = 'Configuration Error';
        this.error = error;        
    }

    fetchDataAction (result) {
        console.log('in fetchDataAction');
        this.state = result.state;
        this.errorMessage = result.errorMessage;
        this.potentiallyMoreRows = result.potentiallyMoreRows;

        if (this.potentiallyMoreRows) {
            // if we show the filter box because of a large number of rows then continue to show it
            this.showFilterBox = true;
        }

        if (this.state != 'SUCCESS') {
            this.hasError = true;
        }
        else {
            this.hasError = false;
        }

        let resultItems = [];       
        for (var i = 0; i < result.items.length; i++) {
            let fields = result.items[i].screenFields;

            //if we have any styling in the config we apply it to the data here.
            let filterValue;
            for (filterValue in this.stylingFilter) {
                let entry = this.stylingFilter[filterValue];
                let searchTerm = entry.value;
                console.log("evlauationg style for : " + searchTerm);
                let stringToSearch = JSON.stringify(fields);
                if(stringToSearch.includes(searchTerm)){
                    let style = entry.cssStyle;
                    console.log('Style = ' + style);
                    fields.cssClass = style;
                }                
            }
            
            resultItems.push(fields);
            

        }
        
        this.fullData = this.fullData.concat(resultItems);
        this.displayData = this.displayData.concat(resultItems);       

        this.showLoading = false;
        this.hasDataToShow = this.fullData.length > 0;
        
    }

    parseMasterConfig (masterConfig) {
        this.configurationObject = JSON.parse(masterConfig);
        let objectLevel = this.configurationObject.queryJSON.objectLevels[0];
        this.objectLevel = JSON.stringify(objectLevel);

        let fields = objectLevel.fields; 

        let fieldIndex;
        let displayColumns = [];
        let fieldApis = [];

        //check for any style overrides are passed in
        if(objectLevel.tableStyle){
            this.tableStyle = objectLevel.tableStyle;
        }
        if(objectLevel.tableClassName){
            this.tableClassName = objectLevel.tableClassName;
        }
        //check for search filters (business filters) that apply to the date
        if(objectLevel.searchFilter){
            this.hasSearchFilters = true;
            this.searchFilter = objectLevel.searchFilter;
        }

        for (fieldIndex in fields) {
            let field = fields[fieldIndex];
            let thisapi = field.api;
            let thistype = field.type;

            fieldApis.push(thisapi);

            // may need to map some of the data types to specific column entries here.
            // e.g. numbers / currency / decimal....
            // see formatting with data types: https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation

            if (field.display == true) {
                let thislabel = field.label;

                let thissortable = field.sortable;
                if (!thissortable === true) {
                    thissortable = false;
                }

                let cellAttribs = { class: { fieldName: 'cssClass' } };
                
                let typeAttibs = {};
                
                

    
                // default columnEntry
                let columnEntry = { label : thislabel, fieldName : thisapi, sortable : thissortable, type : thistype };            

                // columnEntry override
                if (thistype == 'date' || thistype == 'date-local') {
                    columnEntry["type"] = "date-local";
                    typeAttibs.month = "2-digit";
                    typeAttibs.day = "2-digit";
                
                }
                if (thistype == 'integer') {
                    columnEntry["type"] = "number";
                    let attribs = { maximumFractionDigits: 0 };
                    typeAttibs.maximumFractionDigits = 0;
                    cellAttribs.alignment = "center";

                }
                if (thistype == 'decimal') {
                    columnEntry["type"] = "decimal";
                    typeAttibs.minimumFractionDigits = 2;
                    typeAttibs.maximumFractionDigits = 2;
                    cellAttribs.alignment = "center";
                    
                }
                
                let inWidth = field.initialWidth;
                if(inWidth){
                    columnEntry.initialWidth = inWidth;
                }
                columnEntry.cellAttributes = cellAttribs;
                columnEntry.typeAttributes = typeAttibs;
                columnEntry.wrapText = true;
                //columnEntry.wrapTextMaxLines = 2;

                displayColumns.push(columnEntry);

            }

            // code repeated in update method - consolidate            
            if (field.filterOptions != null) {

                this.hasFilterOptions = true;

                this.filterOptions = field.filterOptions;
                this.filteringField = field.api;
                this.filterInitialQuery = field.filterInitialQuery;
                this.filteringWords = 'Filtering Options for : ' + field.label;

                // initially we select all values
                let selectedValue;
                for (selectedValue in field.filterOptions) {
                    this.selectedValues.push(field.filterOptions[selectedValue].value);
                }

                

                if (this.filterInitialQuery) {
                    this.setQueryFilterArray(fieldIndex);
                    let objectLevel = this.configurationObject.queryJSON.objectLevels[0];
                    this.objectLevel = JSON.stringify(objectLevel);    
                }
        
            }

        
            //Builds an array of all styles to apply to the data
            if(field.stylingFilter){
                console.log('adding styling filter');
                let row;
                for(row in field.stylingFilter){
                    this.stylingFilter.push(field.stylingFilter[row]);
                }
                
            }



        }
        console.log('displayColumns');
        
        this.columns = displayColumns;
    }


    handleSearchChange(event){
       this.searchTerm = event.target.value;
       let searchTermElement = this.searchTerm;
        this.displayData = this.fullData.filter(function (row) {
            let stringToSearch = JSON.stringify(Object.values(row));
            return stringToSearch.toLowerCase().includes(searchTermElement.toLowerCase());
        });
    }    

    // The method onsort event handler
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;

        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.sortData(fieldName, sortDirection);
    }    

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.displayData));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.displayData = parseData;
    }

    handleClick(){
        this.updateFilter();

        fetchData({ recordId : this.recordId, objectApiName : this.objectApiName,  globalAccountId : this.globalAccountId, invokerId : this.invokerId, masterConfig : this.objectLevel})
            .then(result => {
                this.fetchDataAction(result);
            })
        .catch(error => {
            this.hasError = true;
            this.state = 'Data Error';
            this.error = error;
        });        
    }    

    updateFilter () {
        let objectLevel = this.configurationObject.queryJSON.objectLevels[0];
        let fields = objectLevel.fields; 
        
        let fieldIndex;

        for (fieldIndex in fields) {
            //console.log('refetchData fields',fieldIndex);
            let field = fields[fieldIndex];
            
            if (this.filterOptions != null && this.filteringField == field.api) {
                this.setQueryFilterArray(fieldIndex);
            }
        }
        this.fullData = [];
        this.displayData = [];

        this.objectLevel = JSON.stringify(objectLevel);
    }

    setQueryFilterArray (fieldIndex) {
        this.configurationObject.queryJSON.objectLevels[0].fields[fieldIndex].filterValues = this.selectedValues;
    }


     // EXPERIMENTAL FROM HERE

    @track selectedValues = [];
    @track filterOptions;
    @track hasFilterOptions = false;
    @track hasSearchFilters = false;

    @track filteringField;

    checkStyles(){
        let buttons = this.template.querySelectorAll("lightning-button");
        let btn;
        for(let i = 0; i < buttons.length; i++){ 
            let butt = buttons[i];
            if(butt.label != 'All'){
                butt.variant = "";
            }else{
                butt.variant = "brand";
            }           
        }
    }

    // Handles the searchfilter
    handleSearchFilterChange(event){
        let searchTermElement = event.target.name;
        let buttons = this.template.querySelectorAll("lightning-button");
        
        if(searchTermElement != 'All'){
            this.displayData = this.fullData.filter(function (row) {
                //only search values
                //let stringToSearch = JSON.stringify(Object.values(row));
                if (Object.values(row).indexOf(searchTermElement) >= 0) {
                    console.log('array search matached');
                    return true;
                }else{
                    return false;
                }
                //return stringToSearch.includes(searchTermElement);
            });
        }else{
            this.displayData = this.fullData;
        }
        let btn;
        for(let i = 0; i < buttons.length; i++){ 
            let butt = buttons[i];
            if(butt.label != event.target.label){
                butt.variant = "";
            }else{
                butt.variant = "brand";
            }           
        }        
    }    

    // Handles the searchfilter
    handleButtonChange(event){
                let buttValue = event.target.label;
        let filterValues = this.selectedValues;
        //has been switched off
        if(event.target.variant === "brand"){
            event.target.variant = "brand-outline";
            
            let index = filterValues.indexOf(buttValue);
            if(index > -1){
                filterValues.splice(index, 1);
            }
    
        }else{
            event.target.variant = "brand";
            filterValues.push(buttValue); 
        }
        this.selectedValues = filterValues;
        //let buttons = this.template.querySelectorAll("lightning-button");
        let apply = this.template.querySelector('[data-id="apply-button"]');
        // let btn;
        // for(let i = 0; i < buttons.length; i++){ 
        //     let butt = buttons[i];

        //     if(butt.label === 'Apply Filter'){
        //         butt.disabled = false;
        //     }
        // }         

        apply.disabled = false;
    }

    handleChange(event) {
        // Get the list of the "value" attribute on all the selected options
        this.selectedValues = event.detail.value;
        
    }


    @track checkBoxValue = ['option1'];

    get checkBoxOptions() {
        return [
            { label: 'Department', value: 'option1' },
            { label: 'Date', value: 'option2' },
        ];
    }

    get selectedCheckBoxValues() {
        return this.checkBoxValue.join(',');
    }

    handleCheckBoxChange(e) {
        this.checkBoxValue = e.detail.value;
    }


}