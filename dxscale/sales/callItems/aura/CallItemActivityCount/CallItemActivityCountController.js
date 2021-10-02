({
    doInit : function(component, event, helper) {
        var action = component.get('c.callCounter');
        var recordId = component.get("v.recordId");

        action.setParams({recordId: recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state !== 'SUCCESS') {
                let failMessage = "Error has occurred, please contact System Administrator";

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