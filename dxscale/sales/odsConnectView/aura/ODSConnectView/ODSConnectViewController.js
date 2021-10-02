({

    doInit: function (component, event, helper) {
        // Retrieve product holdings during component initialization
        // Beware potential race condition if callback of modules completes before holding. 
        // Hence using Promises to enforce completion of former.

        let headerResp = helper.initColumns(component);
        let countPromise = helper.initViewCount(component);

        countPromise
            .then(
                function(data) {
                    if (data == "SUCCESS" && headerResp == "SUCCESS") {
                        helper.setDisplayProperties(component);
                        // once the holdings Promise has returned SUCCESS we create a Promise for retrieving modules
                        return helper.initViewData(component);
                    }
                    else {
                        helper.showDataUnavailable(component);
                    }                    
                }               
            ).then( 
                function(data) {
                    console.log("countPromise successful:" , data);
                    // when the modules Promise has run we are good if it returns "SUCCESS", otherwise we mark the data as unavailable
                    if(data === 'SUCCESS'){
                        helper.hideLoading(component);
                    }
                    else {
                        helper.showDataUnavailable(component);
                    }
                }               
            )
            .catch(function(error) {
                // if any of the Promises are rejected then mark data as unavailable
                helper.showDataUnavailable(component);
            }); 

    },

    loadMoreData: function (component, event, helper) {
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading');
        

        let dataPromise = helper.initViewData(component);

        dataPromise
            .then(
                function(data) {
                    console.log("dataPromise successful:" , data);
                    if (data != "SUCCESS" && headerResp != "SUCCESS") {
                        helper.showDataUnavailable(component);
                    }
                    event.getSource().set("v.isLoading", false);
                    component.set('v.loadMoreStatus', '');
                }               
            )
            .catch(function(error) {
                // if any of the Promises are rejected then mark data as unavailable
                helper.showDataUnavailable(component);
                event.getSource().set("v.isLoading", false);
                component.set('v.loadMoreStatus', '');
            }); 
    }    

})