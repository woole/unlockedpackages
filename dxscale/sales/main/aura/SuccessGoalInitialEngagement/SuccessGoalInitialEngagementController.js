({
    doInit: function(component, event, helper) {
        
        var action2 = component.get("c.getAllSuccessGoals");
        action2.setCallback(this, function(response) {
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
                component.set("v.InitialGoalList", plValues);
            }
        });
        $A.enqueueAction(action2);
        
        var getCurrentOppId=  component.get("v.recordId");
        var action = component.get("c.getStoredEngagements");
        action.setParams({
            "recId": getCurrentOppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.selectedInitialGoalList", result);
            }            
        });
        $A.enqueueAction(action);  
        
        var getCurrentOppIdd=  component.get("v.recordId");
        var action3 = component.get("c.getStoredOtherGoals");
        action3.setParams({
            "recId": getCurrentOppIdd
        });
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.OtherGoals", result);
            }            
        });
        $A.enqueueAction(action3); 
        
        var action4 = component.get("c.getAllOnboardingScores");
        action4.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var onboardingScoreList = [];
                for(var key in result){
                    onboardingScoreList.push({key: result[key], value: result[key]});
                }
                component.set("v.OnboardingScoreList", onboardingScoreList);
            }
        });
        $A.enqueueAction(action4);
        
        var action5 = component.get("c.getStoredOnboardingScore");
        action5.setParams({
            "recId": getCurrentOppIdd
        });
        action5.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.selectedOnboardingScore", result);
            }            
        });
        $A.enqueueAction(action5); 
    }, 
    
    handleOnboardingScore : function(component, event, helper) {
        
        var result = component.find("onboardingScore").get("v.value");
        component.set("v.selectedOnboardingScore",result);        
    },
    
    handleChange: function (component, event, helper) {
        var result =[];   
        result = event.getParam("value");
    },
    
    doGetValue : function(component, event, helper) {
        var result=event.getParam("SuccessGoalValue");    
        component.set("v.StoreValues", result);      
        var result2=event.getParam("SuccessGoalValuetwo");    
        component.set("v.StoreValuestwo", result2);        
    },
    
    saveRecord: function (component, event, helper) {   
        var selectedValuesone=[];
        selectedValuesone=  component.get("v.selectedInitialGoalList");
        var selectedValues=[];
        selectedValues= component.get("v.StoreValues");
        var selectedValuestwo=[];
        selectedValuestwo= component.get("v.StoreValuestwo");
        var onboardingScore = component.get("v.selectedOnboardingScore");
        var otherValues = component.get("v.OtherGoals");
        if(selectedValuesone==''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type" : "error",
                "message": "Please select some Success Goals before saving!"
            });
            toastEvent.fire();            
        }
        else{    
            if(selectedValues==''||selectedValues==null){
                var spinner = component.find("mySpinner");
                $A.util.removeClass(spinner, "slds-hide");
                var getCurrentOppId = component.get("v.recordId");
                var action = component.get("c.updateRecord");
                action.setParams({
                    "recId": getCurrentOppId,
                    "onboardingScore":onboardingScore,
                    "FinalValues":selectedValuestwo,
                    "Initialvalues":selectedValuesone,
                    "otherGoals" : otherValues
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS')
                    {
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Success Goals has been Saved Successfully!' ,
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire(); 
                    }
                    $A.get("e.force:refreshView").fire();           
                });
                $A.enqueueAction(action);
                
            }else{
                var spinner = component.find("mySpinner");
                $A.util.removeClass(spinner, "slds-hide");
                var getCurrentOppId = component.get("v.recordId");
                var action = component.get("c.updateRecord");
                action.setParams({
                    "recId": getCurrentOppId,
                    "onboardingScore":onboardingScore,
                    "FinalValues":selectedValues,
                    "Initialvalues":selectedValuesone,
                    "otherGoals" : otherValues
                });
                action.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS')
                    {
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Success Goals has been Saved Successfully!' ,
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire(); 
                    }
                    $A.get("e.force:refreshView").fire();           
                });
                $A.enqueueAction(action);
            }            
        }
    }
})