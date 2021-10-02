({
    doInit: function (component, event, helper) {
        console.log('doInit');
        
        if (!component.get("v.autoFetch")) {
            helper.showFetchRequired(component);
        } else {
            let headerResp = helper.initColumns(component);
            // Using Promises to enforce completion of callback of modules
            let callAllowedPromise = helper.isCallAllowed(component);
            
            callAllowedPromise
            .then(
                function(data) {
                    if (data == "SUCCESS" && headerResp == "SUCCESS") {
                        // Once the call allowed Promise has returned SUCCESS we create a Promise for retrieving modules
                        return helper.initViewData(component, helper);
                    } else {
                        helper.showDataUnavailable(component);
                    }                    
                }               
            ).then( 
                function(data) {
                    console.log("result of load:", data);
                    // When the module's Promise has run we are good if it returns "SUCCESS" 
                    // otherwise we mark the data as unavailable
                    if (data === "SUCCESS"){
                        helper.hideLoading(component);
                    } else {
                        console.log("data = ", data);
                        helper.showDataUnavailable(component);
                    }
                }               
            ).catch(function(error) {
                // if any of the Promises are rejected then mark data as unavailable
                console.log("error = ", error);
                helper.showDataUnavailable(component);
            });
        }
    },

    updateFilter: function(component, event, helper) {
        helper.updateFilter(component, helper);
    },
    
    onFetch : function(component, event, helper) {
        component.set("v.autoFetch", true);
        var a = component.get('c.doInit');
        $A.enqueueAction(a);
    },
    
    onNext : function(component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },

    onPrev : function(component, event, helper) {
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },

    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },

    onFirst : function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },

    onLast : function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    }
})