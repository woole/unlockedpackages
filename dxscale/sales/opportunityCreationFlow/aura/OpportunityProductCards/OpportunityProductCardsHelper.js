({
	getClickId : function(clickString) {
        return clickString.substring(0,18);
	},
    
	getClickLabel : function(clickString) {
        return clickString.substring(18);
	}

})