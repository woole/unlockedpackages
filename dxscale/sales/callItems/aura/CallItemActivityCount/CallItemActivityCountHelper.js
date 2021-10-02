({
	showToast : function(type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "type" : type, "key" : "action:announcement", "message": message
    });
    toastEvent.fire();
}
})