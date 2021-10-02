({
    init: function (component, event, helper) {        
        var actions = [
            { label: 'Go to Record', name: 'go_to_record' }
        ];            
        component.set('v.columns', [
            {label: 'Serial Number', fieldName: 'SerialNumber', type: 'text'},
            {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
            {label: 'Customer Type', fieldName: 'AccountCustomerType', type: 'text'},
            {label: 'Street', fieldName: 'AccountStreet', type: 'text'},
            {label: 'City', fieldName: 'AccountCity', type: 'text'},
            {label: 'Postcode', fieldName: 'AccountPostCode', type: 'text'},
            {type: 'action', typeAttributes: { rowActions: actions }}
        ]);        
        component.set('v.data', []);
    },
           
    handleClickX : function(component, event, helper) {  
        // clear any previous search results by displaying loading layout
        helper.showDataLoading(component);
        // wrap the action callback definition into a Promise
        let ourPromise = helper.initProductHoldingSearch(component);
        
		ourPromise
            .then(
                function(data) {
                    if (data == "SUCCESS") {
                        // once the Holdings Promise has returned SUCCESS we go to display
                        helper.showDataAvailable(component);
                    } 
                    else {
                        helper.showDataUnavailable(component);
                    }                    
                }               
            )
            .catch(function(error) {
                // if the Promise is rejected then mark data as unavailable
                helper.showDataUnavailable(component);
            }); 
    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'go_to_record':
                var evtNav = $A.get("e.force:navigateToSObject");
                evtNav.setParams({
                    "recordId": row["AccountId"],
                    "slideDevName": "detail"
                });
                evtNav.fire();
                break;
        }
        
        // close the component as the Account record is accessed
        var utilityAPI = cmp.find("utilitybar");
        utilityAPI.minimizeUtility();
    } 
})