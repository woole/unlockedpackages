({
    doInit: function (component, event, helper) {
        // 1) Retrieve Opportunity Contact Roles and Contact / Account details for the Opportunity
        // during component initialization
        // 2) Validate retrieved data including a check for public groups on the running user
        // - present validation results to the user if there are errors
        // 3) Update locales on related Contacts to match that on Account if necessary
        // 4) Build a request to the Quote API and send it if there are no validation errors
        // - if there are, present these onscreen
        // 5) Go to the Assisted Sales url using the retrieved quote

        var action = component.get('c.validatePromise');
        $A.enqueueAction(action);
    },

    validatePromise: function (component, event, helper) {

        let validationPromise = helper.getValidationPromise(component,event,helper);
        var close = $A.get('e.force:closeQuickAction');
        validationPromise
            .then( 
                function(data) {
                    console.log("validationPromise fulfilled:", data);
                    if (data == "SUCCESS") {
                        // the error leg will be run instead if validation or system errors are found
                        // once the validation Promise has returned SUCCESS we create a Promise for retrieving tokens
                        return helper.getTokensPromise(component,event,helper);
                    } else {
                        helper.showErrors(component,event,helper); 
                    }
                }               
            )
            .then( 
                function(data) {
                    console.log("tokensPromise fulfilled:", data);
                    if (data == "SUCCESS") {
                        // the error leg will be run instead if errors are found
                        // or no tokens are returned
                        helper.hideLoading(component,event,helper);
                        helper.goToAssistedSalesUI(component,event,helper);
                        close.fire();
                    } else {
                        helper.showErrors(component,event,helper); 
                    }
                }               
            )
            .catch(function (error) {
                // if any of the Promises are rejected then let the user know
                if (error == "LOCALE_INFO_MISSING") {
                    component.set('v.LocaleInfoMissing', true);
                    component.set('v.ContactRoleMissing', false);
                    helper.showLocaleinfo(component, event, helper);

                }else if(error == "CONTACTROLE_INFO_MISSING"){
                    component.set('v.LocaleInfoMissing', false);
                    component.set('v.ContactRoleMissing', true);
                    helper.showLocaleinfo(component, event, helper);
                }
                else { helper.showErrors(component, event, helper); }
            });      
    },

    handleAccountSave: function (component, event, helper) {
        var _this = this;
        console.log("Inside HandleAccountSave");

        var loc = component.find("selectLocale").get("v.value");
        var salOfc = component.find("selectSalesOffice").get("v.value");
        let oppId = component.get("v.recordId");
        var action = component.get("c.updateMissedAccountInfo");
        action.setParams({
            "oppId": oppId,
            "loc": loc,
            "salesOfc": salOfc
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("no dataupdate errors");
                $A.get('e.force:refreshView').fire();
            }
            else {
                console.log("failed to update data records");
                let dataErrors = response.getError();
            }
        });
        $A.enqueueAction(action);
        component.set('v.LocaleInfoMissing', false);
        component.set('v.ContactRoleMissing', false);

        var action = component.get('c.validatePromise');
        $A.enqueueAction(action);

    },

    handleContactRoleSave: function (component, event, helper) {
        var _this = this;

        let oppId = component.get("v.recordId");
        var action = component.get("c.updateMissedContactRoleInfo");
        action.setParams({
            "oppId": oppId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("no dataupdate errors");
                $A.get('e.force:refreshView').fire();
            }
            else {
                console.log("failed to update data records");
                let dataErrors = response.getError();
            }
        });
        $A.enqueueAction(action);
        component.set('v.LocaleInfoMissing', false);
        component.set('v.ContactRoleMissing', false);
        var action = component.get('c.validatePromise');
        $A.enqueueAction(action);

    }
})