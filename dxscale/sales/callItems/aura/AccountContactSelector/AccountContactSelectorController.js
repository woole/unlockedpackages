({
    doInit: function (component, event, helper) {
        helper.getMailingCountryPicklist(component);
        helper.getJobRolePicklist(component);
        helper.createClickToDialParamsJson(component, helper);
    },

    setContact: function (component, event, helper) {
        component.set("v.contactId", event.getParam("recordId"));
    },
    
    handleNavigate: function(component, event) {
        var navigate = component.get("v.navigateFlow");
        navigate(event.getParam("action"));
    },

    createContact: function (component, event, helper) {
        let target = event.getSource();
        let accountid = target.get("v.value");
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
                let newContact = response.getReturnValue();

                let contacts = component.get("v.contacts");
                // push the new contact to the start of the contacts list
                contacts.unshift(response.getReturnValue());

                component.set("v.contacts", contacts);
                component.set("v.contactId", newContact["Id"]);
                component.find("ContactItemLDS").saveRecord($A.getCallback(function (saveResult) {
                    component.find("ContactItemLDS").reloadRecord(true);

                    let successMessage = "Contact has been created " + nameforMessage + " and selected as Contact for this Account."

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