({
    getValidationPromise: function (component,event,helper) {
        console.log("in getValidationPromise");
        var _this = this; 
        var action = component.get("c.checkRequest");        
        let recId = component.get("v.recordId");
        
        action.setParams({
            'oppId': recId
        });

        // wrap the action callback definition and enqueuing into a promise
        let checkDataPromise = _this.runDataCheck(component, action, helper);        
        return checkDataPromise;
    },

    // execute the callback for validation action returning a promise 
    runDataCheck: function(component,action,helper) {
        console.log("in runDataCheck");
        var _this = this; 
        return new Promise(function(resolve,reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                
                if (state === "SUCCESS") {
                    let dataCheckResponse = response.getReturnValue();
                    // set the response in the view attribute
                    // from which any validation errors can be accessed
                    component.set('v.ascInfo', dataCheckResponse);
                    let errorsReturned = component.get('v.ascInfo.errorList');
                    let errStr = errorsReturned.toString();
                    
                    if ($A.util.isEmpty(errorsReturned)) {
                        console.log("no errors in data check");
                    	resolve("SUCCESS");
                    } else if (errStr.indexOf('supply a Sell To Contact Role on your Opportunity') != -1 ||
                        errStr.indexOf('supply a Bill To Contact Role on your Opportunity') != -1) {
                        reject("CONTACTROLE_INFO_MISSING");
                    } else if (errStr.indexOf('Sell To Contact needs to reference an Account') != -1 ||
                        errStr.indexOf('Bill To Contact needs to reference an Account') != -1) {
                        reject("LOCALE_INFO_MISSING");
                    }
                    else {
                        console.log("validation errors returned " + errorsReturned);
                        reject("FAILED");
                    }
                }
                else {
                    console.log("failure during data checks");
                    let errors = response.getError();
                    _this.handleErrors(errors);
                    reject("FAILED");
                }
            });
        $A.enqueueAction(action);
        });
    },   
    
    getTokensPromise: function (component,event,helper) {
        console.log("in getTokensPromise");
        var _this = this; 
        var action = component.get("c.getTokens");        
        let qreq = component.get("v.ascInfo.quoteRequest");
        let destUrl = component.get("v.ascInfo.destination");
        let same = component.get("v.ascInfo.sameWindow");
        
        action.setParams({
            'qrequest': qreq,
            'destinationUrl': destUrl,
            'sameWindow' : same
        });

        // wrap the action callback definition and enqueuing into a promise
        let checkTokensPromise = _this.runGetTokens(component, action, helper);        
        return checkTokensPromise;
    },
    
    // execute the callback for get tokens action returning a promise 
    runGetTokens: function(component,action,helper) {
        console.log("in runGetTokens");
        var _this = this; 
        return new Promise(function(resolve,reject) {
            action.setCallback(this, function (response) {
                let state = response.getState();
                
                if (state === "SUCCESS") {
                    let tokensCheckResponse = response.getReturnValue();
                    // set the response in the view attribute
                    // from which any errors can be accessed
                    component.set('v.ascInfo', tokensCheckResponse);
                    let errorsReturned = component.get('v.ascInfo.errorList');
                    if ($A.util.isEmpty(errorsReturned)) {
                        console.log("no errors getting tokens");
                    	resolve("SUCCESS");
                    } else {
                        console.log("errors returned attempting to get tokens for Quote API " + errorsReturned);
                        reject("FAILED");
                    }
                }
                else {
                    console.log("failure getting tokens");
                    let errors = response.getError();
                    _this.handleErrors(errors);
                    reject("FAILED");
                }
            });
        $A.enqueueAction(action);
        });
    },   
    
    goToAssistedSalesUI : function(component, event, helper) {
        console.log('in goToAssistedSalesUI');
        
        let quoteToken = component.get("v.ascInfo.quoteToken");
        let refreshToken = component.get("v.ascInfo.refreshToken");
        let destinationURL = component.get("v.ascInfo.destination"); 
        let commerceUrl = destinationURL + '?token=' + quoteToken + '&refreshToken=' + refreshToken;
        console.log('URL to open ' + commerceUrl);
        let namedWindow = component.get("v.ascInfo.sameWindow");
        
        if (namedWindow) {
            window.open(commerceUrl,"assisted-sales");
        } else {
            window.open(commerceUrl);
        }
    },
    
    handleErrors: function(errors) {
        console.log('in handleErrors');
        var errorMessage = "";
        var _this = this; 
        
        if (errors && Array.isArray(errors) && errors.length > 0) {
             errorMessage = errors[0].message;
        }

        console.error('Error detected: ' + errorMessage);
    },
    
    hideLoading: function(component) {
        console.log("in hideLoading");
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');
    },
    
    showErrors: function(component) {
        console.log("in showErrors");
        let cmpDataLoading = component.find("LoadingMsg");            
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');
        let cmpDataError = component.find("ErrorMessages");            
        $A.util.addClass(cmpDataError, 'slds-show');
        $A.util.removeClass(cmpDataError, 'slds-hide');
        let cmpDataLoadingLocaleInfo = component.find("LoadingLocaleInfo");
        $A.util.addClass(cmpDataLoadingLocaleInfo, 'slds-hide');
        $A.util.removeClass(cmpDataLoadingLocaleInfo, 'slds-show');
        $A.get('e.force:refreshView').fire();
    },

    showLocaleinfo: function (component) {
        console.log("in showLocaleinfo");
        //var _this = this;
        let cmpDataLoading = component.find("LoadingMsg");
        $A.util.addClass(cmpDataLoading, 'slds-hide');
        $A.util.removeClass(cmpDataLoading, 'slds-show');
        let cmpDataError = component.find("ErrorMessages");
        $A.util.addClass(cmpDataError, 'slds-hide');
        $A.util.removeClass(cmpDataError, 'slds-show');
        let cmpDataLoadingLocaleInfo = component.find("LoadingLocaleInfo");
        $A.util.addClass(cmpDataLoadingLocaleInfo, 'slds-show');
        $A.util.removeClass(cmpDataLoadingLocaleInfo, 'slds-hide');
        $A.get('e.force:refreshView').fire();
    }
})