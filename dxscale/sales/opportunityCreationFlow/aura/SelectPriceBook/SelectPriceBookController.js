({
    init: function (cmp, event, helper) {
        var action = cmp.get("c.getPricebooksCurrency");
        action.setParams({
            'userid' : "" ,
            'currencyIsoCode': cmp.get("v.currencyIsoCode"),
            'excludedPriceBookNames': cmp.get("v.excludedPriceBookNames")
          });
          action.setCallback(this, function(result){
            var options = result.getReturnValue();
            cmp.set("v.options", options);
            cmp.set("v.selectedValue", options[0].Id);                
            // Let DOM state catch up.
            window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
            		cmp.set("v.selectedValue", options[0].Id);                

                }));
       });
         $A.enqueueAction(action);
    }    
})