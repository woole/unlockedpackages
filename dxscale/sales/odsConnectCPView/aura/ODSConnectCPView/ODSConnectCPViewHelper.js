({
    initColumns : function(component) {
        console.log('initColumns');
        var columnJsonString = component.get("v.columnJsonString");
        
        if (!columnJsonString) {
            alert("Component not properly configured - please add in JSON column definition");
            return "FAILED";
        }

        try {
            var pCols = JSON.parse(columnJsonString);
            component.set('v.columns', pCols);
            
            // Determine searchable fields (of type "text" or "number") and store these for use in filters
            let fields = [];
            for (var i=0; i<pCols.length; i++) {
                if (pCols[i].type == 'text' || pCols[i].type == 'number') {
                    fields.push(pCols[i].fieldName);
                }
            }
            component.set('v.searchFields', fields);

            return "SUCCESS"; 
        } catch(err) {
            console.log("Error parsing JSON Column definition" + err);
            return "FAILED";
        }
    },
    
    isCallAllowed : function (component, event) {
        console.log('isCallAllowed');
        var action = component.get("c.getBypassSetting");
        // wrap the action callback definition and enqueuing into a Promise
        let holdingPromise = this.executeCallAllowedAction(component, action);
        return holdingPromise;
    },
    
    executeCallAllowedAction : function(component, action, callback) {
        console.log('executeCallAllowedAction');
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let okToGo = response.getReturnValue();
                    console.log('okToGo = ' + okToGo);
                    component.set("v.ODSCallAllowed", okToGo);
                    if (!okToGo) {
                        resolve("BLOCKED");
                    } else {
                    	resolve("SUCCESS");
                    }    
                } else {
                    reject("FAILED");
                }
            });
            $A.enqueueAction(action);
        });
    },
    
    initViewData : function(component, helper) {
        console.log('initViewData');
        var action = component.get("c.getViewData");
        var _this = this;

        action.setParams({
            'accountId': component.get("v.recordId"),
            'viewName': component.get("v.viewName"),
        });

        // wrap the action callback definition and enqueuing into a Promise
        let holdingPromise = _this.executeAction(component, action, helper);
        return holdingPromise;
    },

    // execute the callback for action returning a promise so that the module's call only implements after completion
    executeAction : function(component, action, helper) {
        console.log('executeAction');
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();

                if (state === "SUCCESS") {
                    let allData = response.getReturnValue();
                    let pageSize = component.get("v.pageSize");
                    component.set("v.totalRecordCount", allData.length);
                    let pages = Math.ceil(allData.length/pageSize);
                    component.set("v.totalPages", pages);
                    component.set("v.filteredPages", pages);
                    component.set("v.allData", allData);
                    component.set("v.filteredData", allData);
                    component.set("v.currentPageNumber", 1);
                    helper.setDisplayProperties(component);
                    helper.buildData(component, helper);
                    resolve("SUCCESS");
                } else {
                    reject("FAILED");
                }
            });
        $A.enqueueAction(action);
        });
    },

    /*
     * Apply filter to the list of all items
     * */
    updateFilter: function(component, helper) {
        console.log('updateFilter');
        var allData = component.get("v.allData");
        var term = component.get("v.filter");
        var results = allData, regex;
        var fields = component.get("v.searchFields");
        
        try {
            regex = new RegExp(term, "i");
            results = allData.filter(row => (!term) || regex.test(row[fields[0]])
                                                    || regex.test(row[fields[1]])
                                                    || regex.test(row[fields[2]])
                                                    || regex.test(row[fields[3]])
                                                    || regex.test(row[fields[4]])
                                                    || regex.test(row[fields[5]])
                                                    || regex.test(row[fields[6]])
                                                    || regex.test(row[fields[7]])
                                                    || regex.test(row[fields[8]])
                                                    || regex.test(row[fields[9]]));
        } catch(e) {
            console.log('invalid regex'); 
            // invalid regex, use full list
        	console.log(e);
        }
        
        component.set("v.filteredData", results);
        component.set("v.currentPageNumber", 1);
        let pageSize = component.get("v.pageSize");
        component.set("v.filteredPages", Math.ceil(results.length/pageSize));
        helper.buildData(component, helper);
    }, 
    
    /*
     * This function will build table data on the page
     * based on current page selection
     * */
    buildData : function(component, helper) {
        console.log('buildData');
        var allFilteredData = component.get("v.filteredData");
        var paginate = component.get("v.paginate");
        
        if (paginate) {
            var data = [];
            var pageNumber = component.get("v.currentPageNumber");
            var pageSize = component.get("v.pageSize");
            
            var x = (pageNumber-1) * pageSize;
    
            //creating data-table data
            for (; x < pageNumber*pageSize; x++) {
                if (allFilteredData[x]) {
                    data.push(allFilteredData[x]);
                }
            }
            component.set("v.pageData", data);
            helper.generatePageList(component, pageNumber);
        } else {
            // if pagination is not being used, all the retrieved (filtered) table data is simply pushed into the component
            component.set("v.pageData", allFilteredData);
        }
    },
    
    /*
     * This function generates the page list
     * */
    generatePageList : function(component, pageNumber) {
        console.log('generatePageList');
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var filteredPages = component.get("v.filteredPages");
        
        if (filteredPages > 1) {
            if (filteredPages <= 10) {
                // display all pages in the middle pages list except the last one
                var counter = 2;
                for (; counter < (filteredPages); counter++) {
                    pageList.push(counter);
                }
            } else {
                // more than 10 pages, select 5 to show
                if (pageNumber < 5) {
                    pageList.push(2, 3, 4, 5, 6);
                } else {
                    if (pageNumber > (filteredPages-5)) {
                        pageList.push(filteredPages-5, filteredPages-4, filteredPages-3, filteredPages-2, filteredPages-1);
                    } else {
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        } // don't display middle pages if there is only one
        
        component.set("v.pageList", pageList);
        component.set("v.pageListLast", pageList[pageList.length - 1]);
    },
    
    setDisplayProperties : function(component){
        console.log('setDisplayProperties');
        var rowCount = component.get("v.totalRecordCount");
        var baseLabel = component.get("v.label");
        var fullLabel = baseLabel.concat(' (',rowCount,')');
        component.set("v.fullLabel", fullLabel);
        var tableView = component.find("tableView");
        component.set("v.isSetUp", true);
        var toPaginate = component.get("v.paginate");
        
        if (!toPaginate) {
            if (rowCount < 3 ) {
                $A.util.addClass(tableView, 'view-small');
            } else if (rowCount < 7) {
                $A.util.addClass(tableView, 'view-medium');
            } else{
                $A.util.addClass(tableView, 'view-large');
            }
        }
    },

    showFetchRequired : function(component) {
        console.log("showFetchRequired");
        
        let cmpFetchRequired = component.find("FetchRequired");            
        $A.util.addClass(cmpFetchRequired, 'slds-show');
        $A.util.removeClass(cmpFetchRequired, 'slds-hide');
        
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');

        let cmpDataUnavailable = component.find("DataUnavailable");            
        $A.util.addClass(cmpDataUnavailable, 'slds-hide');
        $A.util.removeClass(cmpDataUnavailable, 'slds-show');

        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-hide');
        $A.util.removeClass(cmpDataAvailable, 'slds-show');
    },
    
    showDataUnavailable : function(component) {
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
        
        let cmpFetchRequired = component.find("FetchRequired");            
        $A.util.addClass(cmpFetchRequired, 'slds-hide');
        $A.util.removeClass(cmpFetchRequired, 'slds-show');
    },

    hideLoading : function(component) {
        console.log("hideLoading");
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');

        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-show');
        $A.util.removeClass(cmpDataAvailable, 'slds-hide');
        
        let cmpFetchRequired = component.find("FetchRequired");            
        $A.util.addClass(cmpFetchRequired, 'slds-hide');
        $A.util.removeClass(cmpFetchRequired, 'slds-show');

        let cmpDataUnavailable = component.find("DataUnavailable");            
        $A.util.addClass(cmpDataUnavailable, 'slds-hide');
        $A.util.removeClass(cmpDataUnavailable, 'slds-show');
    },
})