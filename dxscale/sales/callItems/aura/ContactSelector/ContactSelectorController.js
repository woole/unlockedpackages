({
    doInit: function (component, event, helper) {
        // Retrieve contacts during component initialization
        // helper.loadContacts(component);
        helper.getMailingCountryPicklist(component);
        helper.getJobRolePicklist(component);
        helper.createClickToDialParamsJson(component, helper);
    },

    setContact: function (component, event, helper) {
        component.set("v.simpleRecord.Contact__c", event.getParam("recordId"));

        component.find("callItemLDS").saveRecord($A.getCallback(function (saveResult) {
           

            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                 component.find("callItemLDS").reloadRecord(true);
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Contact has been updated."
            });
            toastEvent.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                           
                var failMessage = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i++) {
                    failMessage += saveResult.error[i].message + "\n";
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Problem!",
                    "type": "error",
                    "message": failMessage
                });
                toastEvent.fire();
                console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
            
        }));
    },

    createContact: function (component, event, helper) {
        let target = event.getSource();
        let accountid = target.get("v.value");
        console.log("xxxxx: accountid: ", accountid);
        component.set("v.createMode", true);


        component.find("contactRecordCreator").getNewRecord(
            "Contact", // objectApiName
            null, // recordTypeId
            false, // skip cache?
            $A.getCallback(function () {
                var rec = component.get("v.newContact");
                var error = component.get("v.newContactError");
                if (error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.apiName);
                }
            })
        );
    },

    saveNewContact: function (component, event, helper) {

        component.set("v.createMode", false);

        let accountid = component.get("v.accountId");
        var MailingCountry = component.get("v.mailingCountryString")
        var JobRole = component.get("v.jobRoleString")

        var snc = component.get("v.simpleNewContact");

        var action = component.get("c.saveNewContactApex");

        action.setParams({
            'callItemId': component.get("v.recordId"),
            'newContactFirstName': snc["FirstName"],
            'newContactLastName': snc["LastName"],
            'newContactPhone': snc["Phone"],
            'newContactEmail': snc["Email"],
            'newJobRole': JobRole,
            'newContactMailingCity': snc["MailingCity"],
            'newContactMailingPostalCode': snc["MailingPostalCode"],
            'newContactMailingCountry': MailingCountry,
            'newContactAccountId': accountid
        });

        let nameforMessage = snc["FirstName"] + ' ' + snc["LastName"];

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("saveNewContact", response.getReturnValue());
                let newContact = response.getReturnValue();

                console.log("saveNewContact.newContact", newContact, JSON.stringify(newContact));

                let contacts = component.get("v.contacts");
                // push the new contact to the start of the contacts list
                contacts.unshift(response.getReturnValue());

                component.set("v.contacts", contacts);

                component.set("v.simpleRecord.Contact__c", newContact["Id"]);

                component.find("callItemLDS").saveRecord($A.getCallback(function (saveResult) {
                    component.find("callItemLDS").reloadRecord(true);

                    let successMessage = "Contact has been created " + nameforMessage + " and selected as Contact for this call."

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": successMessage
                    });
                    toastEvent.fire();
                }));
            }
            else {

                let failMessage = "Contact " + nameforMessage + " was not created. Please ensure all mandatory fields are entered";

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Problem!",
                    "type": "error",
                    "message": failMessage
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})