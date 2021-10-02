({
    selectContact : function(component, event, helper) {
        component.getEvent("selectContact").setParams({ "recordId" : component.get("v.iObject")["Id"] }).fire();
    	component.set("v.isOpen",true);
    },
    closeModel : function(component, event, helper) {
        component.set("v.isOpen",false);
    },
    Previous: function(component, event, helper) {
        component.set("v.isOpen",false);
        var actionClicked = event.getSource().getLocalId();
        
        // Call that action
        var navigate = component.getEvent("navigateFlowEvent");
        navigate.setParam("action", actionClicked);
        navigate.fire();
    },
    Next: function(component, event, helper) {
        component.set("v.isOpen",false);
        var actionClicked = event.getSource().getLocalId();
        // Call that action
        var navigate = component.getEvent("navigateFlowEvent");
        navigate.setParam("action", actionClicked);
        navigate.fire();
    }
})