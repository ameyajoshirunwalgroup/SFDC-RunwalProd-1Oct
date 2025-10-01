({
	getExhibitonData : function(component) {
		var action = component.get("c.getExhibitonData");
         action.setCallback(this, function(response) {
            var state = response.getState();
             //alert(response.getReturnValue());
            if (state === "SUCCESS") {
				component.set("v.lstWrap", response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
	},
    
    addExhibitionHelper : function(component) {
        var lstEx = component.get("v.lstWrap");
		var action = component.get("c.addExhibitionApex");
        action.setParams({ "stringWrp" : JSON.stringify(lstEx)});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				alert(response.getReturnValue());
            }
        }); 
         $A.enqueueAction(action);
	}
})