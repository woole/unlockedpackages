({    
    doInit: function (component, event, helper) {
        // Retrieve product holdings during component initialization
        // Beware potential race condition if callback of modules completes before holding. 
        // Hence using Promises to enforce completion of former.
 
        let holdingPromise = helper.initProductHoldings(component,helper);

        holdingPromise
            .then( 
                function(data) {
                    console.log("holdingPromise successful:", data);
                    if (data == "SUCCESS") {
                        // once the holdings Promise has returned SUCCESS we create a Promise for retrieving modules
                        return helper.initProductHoldingModules(component,helper);
                    }
                    else {
                        helper.showDataUnavailable(component);
                    }
                }               
            )
            .then( 
                function(data) {
                    console.log("holdingModulesPromise successful:", data);
                    // when the modules Promise has run we are good if it returns "SUCCESS", otherwise we mark the data as unavailable
                    if (data == "SUCCESS") {
                        helper.hideLoading(component);
                    } else {
                        helper.showDataUnavailable(component); 
                    }
                }               
            )
            .catch(function(error) {
                // if any of the Promises are rejected then mark data as unavailable
                helper.showDataUnavailable(component);
            });      

    },

    updateFilter: function(component, event, helper) {
        helper.updateFilter(component, helper);
    },
    
    onRowSelection: function (component, event, helper) {
        console.log("in onRowSelection");
        var row = event.getParam('selectedRows')[0];
        if (row == undefined) {
            component.set("v.modulesDataCount", 0);
            component.set("v.selectedHolding", null);
            component.set("v.selectedHoldings", []);
            component.set("v.modulesData", []);
            exit;
        }

        // inspection to get index of selected item to retrieve row details and associated modules
        var productHoldings = component.get('v.holdingsData');
        var thisIndex = productHoldings.indexOf(row);
        component.set("v.selectedHolding", productHoldings[thisIndex]);

        let masterObjectArray = component.get("v.masterObjectArray");
        let modulesData = masterObjectArray[thisIndex].modules;

        for (var i = 0; i < modulesData.length; i++) {
            // Convert ProductHoldingModules_Key__c to a string for the datatable
            modulesData[i].ProductHoldingModules_Key__c = modulesData[i].ProductHoldingModules_Key__c.toString();
        }
        
        component.set("v.modulesDataCount", modulesData.length);
        component.set("v.modulesData", modulesData);    
    },
    
    handleSort: function(component, event, helper) {
        console.log("handleSort");
        // Return the field which has to be sorted
        // and the direction of sorting like asc or desc
        // NB these parameter names are standard and do not relate to the attribute names bound to your datatable
        var fieldName = event.getParam('fieldName');
        var sortedDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortedDirection);
        helper.sortData(component, fieldName, sortedDirection, "v.filteredHoldingsData");
    },

    handleModuleSort: function(component, event, helper) {
        console.log("handleModuleSort");
        var fieldName = event.getParam('fieldName');
        var sortedDirection = event.getParam('sortDirection');
        component.set("v.mSortedBy", fieldName);
        component.set("v.mSortedDirection", sortedDirection);
        helper.sortData(component, fieldName, sortedDirection, "v.modulesData");
    }
})