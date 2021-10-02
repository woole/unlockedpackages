({    
    initProductHoldingSearch: function (component,event) {
        console.log('initProductHoldingSearch');
        
        var action = component.get("c.searchForXProductHoldings");
        var _this = this;

        action.setParams({
            'rowsToLoad': component.get("v.rowsToLoad"),
            'searchText': component.get("v.searchText")
        });

        // wrap the action callback definition and enqueuing into a Promise
        let holdingPromise = _this.executeAction(component, action);        
        return holdingPromise;
    },    

    // Execute the callback for Product Holdings action returning a promise 
    // so that the module call only implements after completion
    executeAction: function(component,action) {
        return new Promise(function(resolve,reject) {
            action.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                	component.set('v.data', response.getReturnValue());
                    resolve("SUCCESS");
                } else {     
                    reject("FAILED");
                }
            });
        	$A.enqueueAction(action); 
        });
    },

    showDataLoading: function (component) {
        console.log("showDataLoading");
        
        let cmpDataLoading = component.find("DataLoading");            
        $A.util.addClass(cmpDataLoading, 'slds-show');
        $A.util.removeClass(cmpDataLoading, 'slds-hide');
        
        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-hide');
        $A.util.removeClass(cmpDataAvailable, 'slds-show');
        
        let cmpDataUnavailable = component.find("DataUnavailable");            
        $A.util.addClass(cmpDataUnavailable, 'slds-hide');
        $A.util.removeClass(cmpDataUnavailable, 'slds-show');
    },
    
    showDataAvailable: function (component) {
        console.log("showDataAvailable");
        
        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-show');
        $A.util.removeClass(cmpDataAvailable, 'slds-hide');
        
        let cmpDataUnavailable = component.find("DataUnavailable");            
        $A.util.addClass(cmpDataUnavailable, 'slds-hide');
        $A.util.removeClass(cmpDataUnavailable, 'slds-show');
        
        let cmpDataLoading = component.find("DataLoading");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');
    },
    
    showDataUnavailable: function (component) {
        console.log("showDataUnavailable");
        
        let cmpDataUnavailable = component.find("DataUnavailable");            
        $A.util.addClass(cmpDataUnavailable, 'slds-show');
        $A.util.removeClass(cmpDataUnavailable, 'slds-hide');
        
        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-hide');
        $A.util.removeClass(cmpDataAvailable, 'slds-show');
        
        let cmpDataLoading = component.find("DataLoading");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');
    }
})