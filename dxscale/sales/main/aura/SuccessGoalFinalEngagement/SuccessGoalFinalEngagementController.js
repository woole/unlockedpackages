({
    doInit: function(component, event, helper) {
        
        var getCurrentOppId= component.get("v.recId"); 
        var action = component.get("c.getStoredEngagements");
        action.setParams({
            "recId": getCurrentOppId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                component.set("v.FinalGoalList", plValues);
            } 
        });
        $A.enqueueAction(action);
        
        var getCurrentOppId= component.get("v.recId"); 
        var action1 = component.get("c.getStoredFinalEngagements");
        action1.setParams({
            "recId": getCurrentOppId
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.FinalselectedGoalList", result);
                component.set("v.FinalselectedGoalListonSave", result);
                var selectedValues=[];
                selectedValues=component.get("v.FinalselectedGoalListonSave");
                var getChangedValue=component.getEvent("onChangeOfValue");
                getChangedValue.setParams({
                    "SuccessGoalValuetwo" : selectedValues
                });
                getChangedValue.fire();  
            }  
        });
        $A.enqueueAction(action1);        
    },
    
    onChangeofInitial : function (component, event, helper) {    
        var result =[];   
        result = event.getParam("value");      
        var plValues = [];
        for (var i = 0; i < result.length; i++) {
            plValues.push({
                label: result[i],
                value: result[i]
            });
        }
        component.set("v.FinalGoalList", plValues);
    },
    
    handleGoalChange : function (component, event, helper) {  
        var selectedValues = event.getParam("value");
        if(selectedValues){
            component.set("v.FinalselectedGoalList", selectedValues);
        }else{
            component.set("v.FinalselectedGoalList", '');
        }
        var getChangedValue=component.getEvent("onChangeOfValue");
        getChangedValue.setParams({
            "SuccessGoalValue" : selectedValues
        });
        getChangedValue.fire();        
    }
    
})