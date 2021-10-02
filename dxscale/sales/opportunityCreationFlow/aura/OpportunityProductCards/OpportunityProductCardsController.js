({

    /*
    v.productJSONString represents an array of products.
    It is an input and output parameter. Although its primary role is as output it is also used as an input for cases where the user moves away and then back to the product selection screen.
    It is the storage mechanism with the Flow for the currently selected items and is the variable that is then used to create the OLIs later in the flow.

    The same logic applies to v.selectedLookUpRecordsString
    It is an input and output parameter. Its primary role is to hold the list of selected products in the search component
    The complexity comes in where uses navigate back and forwards through the flow, in which case it provides the necessary marker.
    */
    
        doInit : function(component, event, helper) {       
            var currencyCode = component.get("v.currencyISOCode");

            let productJSONString = component.get("v.productJSONString");
            let mydata = JSON.parse(productJSONString);        
            component.set("v.mydata", mydata);    

            let selectedLookUpRecordsString = component.get("v.selectedLookUpRecordsString");
            let selectedLookUpRecords = JSON.parse(selectedLookUpRecordsString); 
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
                        nonRecurringRevenue: 0,
                        monthlyRecurringRevenue: 0,
                        clickedPerpetual: false,
                        clickedSubscription: true,
                        clickedPremise: false,
                        clickedSageCloud: true,
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

         handleSave: function (component, evt, helper) {
            var mydata = component.get("v.mydata");   
			
             var mapRadioClicksCM = component.get("v.mapRadioClicksCM");              
             var mapRadioClicksPD = component.get("v.mapRadioClicksPD");              
             
             for (var i = 0; i < mydata.length; i++) {
                 var mydatum = mydata[i];
                 var myclicksCM = mapRadioClicksCM[mydatum.id];
                 var myclicksPD = mapRadioClicksPD[mydatum.id];
                 
                 if (myclicksCM == "Perpetual") {
                    mydatum.commercialisationMode = "Perpetual";
                    mydatum.clickedPerpetual = true;
                    mydatum.clickedSubscription = false;
                }
                 if (myclicksCM == "Subscription") {
                    mydatum.commercialisationMode = "Subscription";                    
                    mydatum.clickedPerpetual = false;
                    mydatum.clickedSubscription = true;
                }
                 
                 if (myclicksPD == "Sage Cloud") {
                    mydatum.productDeployment = "Sage Cloud";
 				    mydatum.clickedSageCloud = true;
                    mydatum.clickedPremise = false;
                    mydatum.clickedPartnerCloud = false; // 02/09/2021 bphan EAD-2033
                }
                 if (myclicksPD == "Premise") {
                    mydatum.productDeployment = "Premise";                    
					mydatum.clickedSageCloud = false;
                    mydatum.clickedPremise = true;
                    mydatum.clickedPartnerCloud = false; // 02/09/2021 bphan EAD-2033
                }
                if (myclicksPD == "Partner Cloud") {// 02/09/2021 bphan EAD-2033
                    mydatum.productDeployment = "Partner Cloud";                    
	                mydatum.clickedSageCloud = false;
                    mydatum.clickedPremise = false;
                    mydatum.clickedPartnerCloud = true; 
                }
 
            };
            component.set("v.productJSONString", JSON.stringify(mydata)); 
            component.set("v.productsaved", "true");  
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success",
                "type": "Success",
                "message": "Products have been saved"
            });
            toastEvent.fire();             
        },    

		radioClickProductDeployment : function(component, event, helper) {
			var mapRadioClicksPD = component.get("v.mapRadioClicksPD");            
            const clickString = event.getSource().get('v.value');

            var clickId = helper.getClickId(clickString);
			var clickLabel = helper.getClickLabel(clickString);

            mapRadioClicksPD[clickId] = clickLabel;
            component.set("v.mapRadioClicksPD",mapRadioClicksPD); 
        },    

        radioClickCommercializationMode : function(component, event, helper) {
			var mapRadioClicksCM = component.get("v.mapRadioClicksCM");            
            const clickString = event.getSource().get('v.value');

            var clickId =	helper.getClickId(clickString);
			var clickLabel =	helper.getClickLabel(clickString);

            mapRadioClicksCM[clickId] = clickLabel;
            component.set("v.mapRadioClicksCM",mapRadioClicksCM); 
        },    
        
})