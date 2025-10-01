({
	doInit : function(component, event, helper) {
        var lWidth = window.innerWidth ;//Get the window's width
        var action = component.get("c.lstFetchRunwalEvnts");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstRunwalEvent", response.getReturnValue());
            }
            
        //The setInterval() method calls a function or 
        //evaluates an expression at specified intervals (in milliseconds).
        window.setInterval($A.getCallback(function() { 
          //  helper.shiftDiv(component, event,lWidth);
        } ), 100);
        });
        
		$A.enqueueAction(action); 
	},
})