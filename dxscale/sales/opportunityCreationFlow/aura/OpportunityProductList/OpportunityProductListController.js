({

    /*
    v.productJSONString represents an array of products.
    It is an input and output parameter. Although its primary role is as output it is also used as an input for cases where the user moves away and then back to the product selection screen.
    It is the storage mechanism with the Flow for the currently selected items and is the variable that is then used to create the OLIs later in the flow.

    The same logic applies to v.selectedLookUpRecordsString
    It is an input and output parameter. Its primary role is to hold the list of selected products in the search component
    The complexity comes in where uses navigate back and forwards through the flow, in which case it provides the necessary marker.

    The grid has a first column and last column which represent Product and (financial) Amount
    The other columns are buttons to represent options for Commercialization Mode and Product Deployment
    At time of writing there are two options for each of these.
    The buttons columns have typeAttributes with distinct variants which enable use to distinguish which button was clicked and perform the correct actions as a result.

    This extends datatables about as far as we can. 
    IF AT A FUTURE POINT we need more complex logic we may need to implement as an iterator but there will be a lot more code for this.

    */
        doInit : function(component, event, helper) {       

            var currencyCode = component.get("v.currencyISOCode");

            var mycolumns =          
            [
                {label: 'Product', fieldName: 'productName', type: 'text', editable: false, typeAttributes: { required: true }},
                {label: 'Commercialization Mode', disabled: false, fieldName: 'commsub', type: 'button', editable: true, value: 'comm', cellAttributes: { alignment: 'right' }, typeAttributes: { label: 'Subscription', variant: {fieldName: 'variantValueSubscription'} } },
                {label: '', disabled: false, fieldName: 'commperp', type: 'button', editable: true, value: 'pub', typeAttributes: { label: 'Perpetual', variant: {fieldName: 'variantValuePerpetual'}}},
                {label: 'Product Deployment', disabled: false, fieldName: 'prodpremise', type: 'button', editable: true, value: 'premise',cellAttributes: { alignment: 'right' }, typeAttributes: { label: 'Premise', variant: {fieldName: 'variantValuePremise'} } },
                {label: '', disabled: false, fieldName: 'prodsagecloud', type: 'button', editable: true, value: 'Sage Cloud',typeAttributes: { label: 'Sage Cloud', variant: {fieldName: 'variantValueSageCloud'}}},
 			    {label: 'Non Recurrring Amount', fieldName: 'nonRecurringRevenue', type: 'currency', editable: true, typeAttributes: { currencyCode: currencyCode, required: true }},
                {label: 'Monthly Recurrring Amount', fieldName: 'monthlyRecurringRevenue', type: 'currency', editable: true, typeAttributes: { currencyCode: currencyCode, required: true}
              
                }
            ];
            component.set("v.mycolumns", mycolumns);
            component.set("v.draftValues", []);
            
            let productJSONString = component.get("v.productJSONString");
            let mydata = JSON.parse(productJSONString);        
            component.set("v.mydata", mydata);    

            let selectedLookUpRecordsString = component.get("v.selectedLookUpRecordsString");
            let selectedLookUpRecords = JSON.parse(selectedLookUpRecordsString); 
            console.log("doInit: selectedLookUpRecordsString", selectedLookUpRecordsString);

            component.set("v.selectedLookUpRecords", selectedLookUpRecords);    

        },
    
        /* Handles when products are added or removed from the select panel */
        itemsChange: function(component, evt) {   

            // the first time this method is called is because of the assignment of attribute
            // "v.selectedLookUpRecords" in init. In that instance we don't wish the datatable to be modified 
            // initPhase (originally set to true) and set to false after the first change to selectedLookUpRecords lets us know the state.
            let initPhase = component.get("v.initPhase");    

            if (!initPhase) {
                let newList = evt.getParam("value");
                let mydata = component.get("v.mydata");

                let newListLength = newList.length;
                let mydataLength = mydata.length;

                if (newListLength > mydataLength) {
                    // if the length of the selected products lists has increase we need to push the last to the data grid
                    let newVal = evt.getParam("value")[newList.length - 1];

                    mydata.push({
                        id: newVal["Id"],
                        productName: newVal["Name"],
                        quantity: 1,
                        amount: 1000,
                        variantValuePerpetual: 'Neutral',
                        variantValueSubscription: 'Brand',
                        variantValuePremise: 'Neutral',
                        variantValueSageCloud: 'Brand',
      				    commercialisationMode: "Subscription",
                        productDeployment: "Sage Cloud"
                    });
                }
                else {
                    // if the length of the selected products lists has decreased we need to remove an element from mydata
                    // the item we need to remove is either the first to not match the id of the same placed element in the existing array
                    // or, if we don't find any such mismatch, the last element in the existing array.
                    var indexToRemove = - 1;
                    for (var i = 0; i < mydataLength; i++) {
                        if (i == (mydataLength - 1)) {
                            indexToRemove = i;
                            break;
                        }
                        if (mydata[i]["id"] != newList[i]["Id"]) {
                            indexToRemove = i;
                            break;
                        }
                    }
                    mydata.splice(indexToRemove, 1);
                }

                // we update the data grid and our flow storage variables
                component.set("v.mydata", mydata);
                component.set("v.productJSONString", JSON.stringify(mydata));

                let selectedLookUpRecords = component.get("v.selectedLookUpRecords");
                let selectedLookUpRecordsString = JSON.stringify(selectedLookUpRecords);

                component.set("v.selectedLookUpRecordsString", selectedLookUpRecordsString);
                component.set("v.productsaved", "false"); 
            }
            else {
                component.set("v.initPhase", false);
            }
        },

        /* If the grid has been edited the new values are stored in v.draftValues
         * These need to be Saved and stored into the v.productJSONString variable before the flow can be aware.        
         * To do this, update any draft values into the mydata attribute and clear the draft values to reset the table
         * Finally serialize the mydata grid variable into the string storage variable v.productJSONString */

         handleSave: function (component, evt, helper) {
            let draftValues = evt.getParam('draftValues');
            component.set('v.draftValues', evt.getParam('draftValues'));
            var mydata = component.get("v.mydata");   
            
            for (var i = 0; i < draftValues.length; i++) {
                let row = draftValues[i];                
                var mydataLength = mydata.length;
                
                for (var i = 0; i < mydataLength; i++) {
                    if (mydata[i]["id"] == row["id"]) {
                        console.log("found the row");   
                        for (var k in row) {
                            console.log("found a key", k);  
                            if (k != "id") {
                                console.log("found a key I need to change", k);  
                                mydata[i][k] = row[k];                            
                            }                        
                        }                    
                    }                                
                }
            }        
            component.set("v.mydata", mydata);   
            component.set('v.draftValues', []);            
            component.set("v.productJSONString", JSON.stringify(mydata)); 
            component.set("v.productsaved", "true");  
        },    

        // make subscription and cloud the defaults....
        handleRowAction: function (component, event, helper) {

            console.log("handleRowAction enter");
    
            var action = event.getParam('action');
            var row = event.getParam('row');
            var rowId = row["id"];
    
            var mydata = component.get("v.mydata");    

            mydata = mydata.map(function(rowData) {
                if (rowData["id"] == rowId) {
                    if (action["label"] == "Perpetual")
                    {
                        rowData.variantValuePerpetual = 'Brand';
                        rowData.variantValueSubscription = 'Neutral';
                        rowData.commercialisationMode = "Perpetual";
                    }        
                    if (action["label"] == "Subscription")
                    {
                        rowData.variantValuePerpetual = 'Neutral';
                        rowData.variantValueSubscription = 'Brand';
                        rowData.commercialisationMode = "Subscription";
                    }
                    if (action["label"] == "Premise")
                    {
                        rowData.variantValuePremise = 'Brand';
                        rowData.variantValueSageCloud = 'Neutral';
  					    rowData.productDeployment = "Premise";
                    }        
                    
                    if (action["label"] == "Sage Cloud")
                    {
                        rowData.variantValuePremise = 'Neutral';
                        rowData.variantValueSageCloud = 'Brand';
        				rowData.productDeployment = "Sage Cloud";
                    }
                }
                return rowData;
            });

            component.set("v.mydata", mydata);    
            component.set("v.productJSONString", JSON.stringify(mydata));    

        },

        clickSaveWarningChange: function (component, event, helper) {        
            component.set("v.clickSaveWarning", true);    
        }
        
    })