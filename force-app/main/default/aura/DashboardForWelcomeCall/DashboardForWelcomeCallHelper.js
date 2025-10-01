({
    fetchBookingHelper : function(component, event, helper) {
         var action = component.get("c.fetchBookingData");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.bookingList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})