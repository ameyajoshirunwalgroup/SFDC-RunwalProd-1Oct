({
	disableContactUs : function(component,event) { //Added by Vinay 06-06-2025
		var action = component.get("c.disableContactUs");  
        action.setParams({  
           "bookingId":component.get("v.RunwalHomeWrapList")[0].BookingId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                component.set("v.disableContactUsSection", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})