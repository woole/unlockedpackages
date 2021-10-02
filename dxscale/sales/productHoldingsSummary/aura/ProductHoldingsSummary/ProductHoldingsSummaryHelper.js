({
    initProductHoldings: function (component,helper) {
        var _this = this; 
        var action = component.get("c.getScreenData");        
        let recId = this.getRecordID(component);
        
        action.setParams({
            'accountId': recId, 
            'queryConfig': component.get("v.ProdHoldingQueryConfig"),
            'invokerId': component.get("v.invokerId"),
            'fieldName': component.get("v.fieldName")
        });

        // wrap the action callback definition and enqueuing into a Promise
        let holdingPromise = _this.executeHoldingsAction(component, action, helper);        
        return holdingPromise;
    },

    // execute the callback for product holdings action returning a promise so that the modules call only implements after completion
    executeHoldingsAction: function(component, action, helper) {
        console.log("in executeHoldingsAction");
        var _this = this; 
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                
                if (state === "SUCCESS") {
                    let holdingsResponse = response.getReturnValue();
                    let displayColumns = helper.parseDisplayConfig(component,holdingsResponse.viewConfig);
        			component.set("v.holdingsColumns",displayColumns);
                    let resultItems = helper.processScreenData(holdingsResponse,component,"v.holdingsColumns");
                    component.set("v.holdingsData",resultItems);
                    let holdingsData = component.get("v.holdingsData");
                    component.set("v.totalHoldingRecordCount", holdingsData.length);
                    // we create an array of strings with the holdings keys that are in scope
                    // we don't want to process modules for other holdings 
                    let holdingKeys = [];

                    // we also create a masterObject which is an array where each element holds a Product Holding and associated Modules
                    // the modules will be populated later but we initialize the placeholder here.
                    let masterObjectArray = [];

                    for (var i = 0; i < holdingsData.length; i++) {
                        var tempkey = holdingsData[i]["ProductHolding_Key__c"];
                        holdingKeys.push(tempkey);
                        masterObjectArray.push({"holding" : holdingsData[i], "modules" : []});
                    } 
					
                    // store our objects
                    component.set("v.productHoldingKeyList", holdingKeys);
                    component.set("v.masterObjectArray", masterObjectArray);
                    helper.updateFilter(component);
                    resolve("SUCCESS");                    
                }
                else {
                    let errors = response.getError();
                    _this.handleErrors(errors);
                    reject("FAILED");
                }
            });
        $A.enqueueAction(action);
        });
    },   

    initProductHoldingModules: function (component,helper) {
        var action = component.get("c.getScreenData");
        var _this = this;
        
        let recId = this.getRecordID(component);

        action.setParams({
            'accountId': recId,
            'queryConfig': component.get("v.ProdHoldingModQueryConfig"),
            'invokerId': component.get("v.invokerId"),
            'fieldName': component.get("v.fieldName")
        });        

        // wrap the action callback definition and enqueuing into a Promise
        let modulesPromise = _this.executeModulesAction(component, action,helper);        
        return modulesPromise;
    },

    executeModulesAction: function(component, action, helper) {
        console.log("in executeModulesAction");
        var _this = this; 
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                
                if (state === "SUCCESS") {
                    let modulesResponse = response.getReturnValue();
                    // this sets the modulesData so we can grab it
                    let displayColumns = helper.parseDisplayConfig(component,modulesResponse.viewConfig);
        			component.set("v.modulesColumns",displayColumns);
                    let resultItems = helper.processScreenData(modulesResponse,component,"v.modulesColumns");
                    component.set("v.modulesData",resultItems);
                    
                    let modules = component.get("v.modulesData");
                    // now we have it in the right format, clear it down so it waits for change
                    component.set("v.modulesData", []);
                    let holdingKeys = component.get("v.productHoldingKeyList");
                    let masterObjectArray = component.get("v.masterObjectArray");
    
                    for (var i = 0; i < modules.length; i++) {
                        let parentKey = modules[i]["ProductHolding_Key__c"];
                        let thisIndex = holdingKeys.indexOf(parentKey);
                        if (thisIndex != -1) {
                            masterObjectArray[thisIndex].modules.push(modules[i]);
                        }
                    }
                    component.set("v.masterObjectArray", masterObjectArray);                                
                    resolve("SUCCESS");                    
                }
                else {
                    let errors = response.getError();
                    _this.handleErrors(errors);
                    reject("FAILED");
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    // checks to see if an accountId is passed if so, override the recordId
    getRecordID: function(component){
        let overrideId = component.get("v.accountId");
        let recId;
        if (overrideId) {
            recId = overrideId;
        } else {
            recId = component.get("v.recordId");
        }
        return recId;
    },

    showDataUnavailable: function(component) {
        console.log("showDataUnavailable");
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');
        
        let cmpDataUnavailable = component.find("DataUnavailable");            
        $A.util.addClass(cmpDataUnavailable, 'slds-show');
        $A.util.removeClass(cmpDataUnavailable, 'slds-hide');

        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-hide');
        $A.util.removeClass(cmpDataAvailable, 'slds-show');
    },

    hideLoading: function(component) {
        console.log("hideLoading");
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');

        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-show');
        $A.util.removeClass(cmpDataAvailable, 'slds-hide');
    },

    parseDisplayConfig: function (component,displayConfig) {
        console.log('in parseDisplayConfig');
        let objectLevel = JSON.parse(displayConfig);
        let fields = objectLevel.fields; 
        let fieldIndex;
        let displayColumns = [];
        let fieldApis = [];
		var tempStylingFilter = [];
        
        for (fieldIndex in fields) {
            let field = fields[fieldIndex];
            let thisapi = field.api;
            let thistype = field.type;

            fieldApis.push(thisapi);

            // may need to map some of the data types to specific column entries here.
            // e.g. numbers / currency / decimal....
            // see formatting with data types: https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation
            if (field.display == true) {
                let columnEntry;

                // columnEntry override
                if (thistype == 'date') {
                    columnEntry = { type: "date-local", typeAttributes:{ month: "2-digit", day: "2-digit" } };
                } else if (thistype == 'integer') {
                    columnEntry = { type : "number", typeAttributes: { maximumFractionDigits: 0 } };
                } else if (thistype == 'decimal') {
                    columnEntry = { type : "number", typeAttributes: { minimumFractionDigits: 2,maximumFractionDigits: 2 } };
                } else {
                    // default... type = phone, text etc
                    columnEntry = { type : thistype };
                }

                columnEntry.fieldName = thisapi;
                let thisLabel = field.label;
                columnEntry.label = thisLabel;
                
                columnEntry.wrapText = true;
                columnEntry.wrapTextMaxLines = 2;
                
                let thisSortable = field.sortable;
                if (thisSortable) { columnEntry.sortable = thisSortable; }
                
                let thisInitialWidth = field.initialWidth;
                if (thisInitialWidth) { columnEntry.initialWidth = thisInitialWidth; }
                
                let thisStyle = field.style;
                if (thisStyle) { columnEntry.style = thisStyle; }
                
                let thisCellAttributes = field.cellAttributes;
                // EAD-2449
                if  (columnEntry.fieldName == 'SupportExpiryDate__c'){
                	thisCellAttributes = {"class": {"fieldName": "showClass" }};
                }    
                //
                if (thisCellAttributes) { columnEntry.cellAttributes = thisCellAttributes; }
                
                displayColumns.push(columnEntry);
            }
        } 

        return displayColumns;
    },
    
    processScreenData: function(result,component,displayColumnName) {
        console.log('in processScreenData');
        let state = result.state;
        let errorMessage = result.errorMessage;

        if (state != 'SUCCESS') {
            component.set('v.hasError',true);
            component.set('v.errorMessage',errorMessage);
        }
        else {
            component.set('v.hasError',false);
            component.set('v.errorMessage',''); 
        }

        let resultItems = [];
        
        for (var i = 0; i < result.items.length; i++) {
            if (displayColumnName == "v.holdingsColumns") {
                var todayDateTime = new Date().getTime();
                var tempExpDate = new Date(result.items[i].screenFields["SupportExpiryDate__c"]).getTime();
                
                if (tempExpDate > todayDateTime) {
                    result.items[i].screenFields['_status'] = 'Active';
                    if (tempExpDate <= (parseInt(todayDateTime,10) + (30*24*60*60*1000))) {
                        result.items[i].screenFields['_highlight'] = 'slds-theme_warning';
                    } 
                } else {
                    result.items[i].screenFields['_status'] = 'Inactive';
                }
            }
                         
            //2021 bphan EAD-2449
            var supportStatus = result.items[i].screenFields["SupportRAGStatus__c"];
            if (supportStatus == 'Red')
            {
                result.items[i].screenFields['showClass'] = 'colorcoding-red'; 
            }else if ( supportStatus == 'Amber'){
                result.items[i].screenFields['showClass'] = 'colorcoding-yellow'; 
            }              
            // end EAD-2449
            
            let fields = result.items[i].screenFields;
            resultItems.push(fields);
        }

        return resultItems;
    }, 
    
    /*
     * Apply filter to the list of all items
     */
    updateFilter: function(component) {
        console.log('in updateFilter');
        var results = component.get("v.holdingsData");
        var isActive = component.get("v.isActive");
        var selectedHolding = component.get("v.selectedHolding");
        var selectedHoldingStatus;

        if (selectedHolding == null) {
            component.set("v.modulesDataCount", 0); 
            component.set("v.modulesData", []);
        } else {
            // we have a selected holding
            selectedHoldingStatus = selectedHolding._status;
            
            // need to clear row selection if any for transitions from Active to Inactive and vice-versa
            // workaround for platform bug, SF errors if selection is nulled
            if ((selectedHoldingStatus == "Active" && isActive == "Inactive") ||
                (selectedHoldingStatus == "Inactive" && isActive == "Active")) {
                component.set("v.modulesDataCount", 0); 
                component.set("v.modulesData", []); 
                component.set("v.selectedHoldings", []);
                component.set("v.selectedHolding", null);
            }
        }
        
        if (isActive != "") {
            try {
                results = results.filter(row => isActive == row._status);
            }
            catch(e) {
                // use full list and continue
                console.error(e);
            }
        } // results value was previously set to all holdings data if no filter required
        
        component.set("v.filteredHoldingsData", results);
        component.set("v.totalFilteredHoldingRecordCount", results.length);
    },

    handleErrors: function(errors) {
        console.log('handleErrors');
        var errorMessage = "";
        var _this = this; 
        
        if (errors && Array.isArray(errors) && errors.length > 0) {
             errorMessage = errors[0].message;
        }

        console.error('Error retrieving data: ' + errorMessage);
    },
    
    sortData: function (component, fieldName, sortDirection, dataSet) {
        console.log('sortData');
        var _this = this; 
        var data = component.get(dataSet); 
        // function to return the value stored in the fieldName
        var key = function(a) { return a[fieldName]; }
        var fieldType = function(a) { return a[fieldType]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // Check for field type as numbers/currency, text and dates require different sort algorithms
        // date sort works like text sort for field type "date-local" as this formats the date to yyyy-MM-ddTHH:mm:ssZ
        try {
            data.sort(function(a,b) {
                // check fieldtype to determine sort algorithm
                if (fieldType(a) == 'number' ||  fieldType(a) == 'currency') {
                    var a = key(a) ? key(a) : '';
                    var b = key(b) ? key(b) : '';
                } else {
                    // text fields, dates
                    var a = key(a) ? key(a).toLowerCase() : ''; 
                    var b = key(b) ? key(b).toLowerCase() : '';
                }
                return reverse * ((a > b) - (b > a));
            });    
        } catch(err) {
            _this.publishError("Error sorting column data.");
            console.error(err);
            reject("FAILED");
        }

        component.set(dataSet, data);
     }
})