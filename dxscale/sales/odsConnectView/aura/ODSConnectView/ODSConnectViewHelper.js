({
    initColumns:function(component){
        var columnJsonString = component.get("v.columnJsonString");
        if(!columnJsonString){
            alert("component not properly configured - please add in JSON column definition");
            return "FAILED";
        }
        try{
            var pCols = JSON.parse(columnJsonString);
            component.set('v.viewColumns',pCols);
            return "SUCCESS"; 
        }catch(err){
            console.log("Error parsing JSON Column definition" + err);
            return "FAILED";
        }

    },

    initViewData: function (component,event) {
        console.log('initViewData');
        
        var offSetCount = component.get("v.numRecords");
        var rowsToLoad = component.get('v.rowsToLoad');
        var action = component.get("c.getViewData");
        
        var _this = this;

        action.setParams({
            'accountId': component.get("v.recordId"),
            'viewName': component.get("v.viewName"),
            'rowLimit': rowsToLoad, 
            'rowOffSet':offSetCount
        });

        // wrap the action callback definition and enqueuing into a Promise
        let holdingPromise = _this.executeAction(component, action);        
        return holdingPromise;
    },

    // execute the callback for product holdings action returning a promise so that the modules call only implements after completion

    executeAction: function(component,action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
               
                if (state === "SUCCESS") {
                    let viewData = response.getReturnValue();
                    if (component.get('v.viewData').length >= component.get('v.maxRecordCount')) {
                        component.set('v.enableInfiniteLoading', false);
                        component.set('v.loadMoreStatus', 'No more data to load');
                    } else {
                        var currentData = component.get('v.viewData');
                        var newData = currentData.concat(viewData); 
                        component.set("v.viewData", newData); 
                        component.set("v.numRecords",newData.length);                        
                    }
                    resolve("SUCCESS");                    
                }
                else {
                    
                    reject("FAILED");
                }
            });
        $A.enqueueAction(action); 
        });
    },

    initViewCount: function (component,event) {
        console.log('initViewCount');
        
        var action = component.get("c.getRecordCount");
        var _this = this;

        action.setParams({
            'accountId': component.get("v.recordId"),
            'viewName': component.get("v.viewName"),
        });

        // wrap the action callback definition and enqueuing into a Promise
        let holdingPromise = _this.executeCountAction(component, action);        
        return holdingPromise;
    },    
      
    executeCountAction: function(component, action, callback) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    var recCount = response.getReturnValue();
                    component.set("v.maxRecordCount", recCount);
                    resolve("SUCCESS");                    
                }
                else {
                    reject("FAILED");
                }
            });
            $A.enqueueAction(action);
    
        });
    },  
    
    
    setDisplayProperties: function(component){
        var rowCount = component.get("v.maxRecordCount");
        var baseLabel = component.get("v.label");
        var fullLabel = baseLabel.concat(' (',rowCount,')');
        component.set("v.fullLabel",fullLabel);
        var tabelView = component.find("tableView");
        component.set("v.isSetUp",true);
        
        if(rowCount < 3){
            $A.util.addClass(tabelView, 'view-small');
        }else if(rowCount < 7){
            $A.util.addClass(tabelView, 'view-medium');
        }else{
            $A.util.addClass(tabelView, 'view-large');
        }
    },
    

    showDataUnavailable: function (component) {
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
    hideLoading: function (component) {
        console.log("showLoading");
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');

        let cmpDataAvailable = component.find("DataAvailable");            
        $A.util.addClass(cmpDataAvailable, 'slds-show');
        $A.util.removeClass(cmpDataAvailable, 'slds-hide');
    },    
    

})