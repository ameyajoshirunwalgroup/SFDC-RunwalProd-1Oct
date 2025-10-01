({
	getBookingRecordForRefundHandoverDocument: function(component, BookingID) {       
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}
        var action = component.get("c.getRefundHandoverInfo");
        action.setParams({
                "bookingId": BookingID
            });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue(); 
                component.set("v.info", allValues);
                if(spinner) {
                    $A.util.removeClass(spinner,"slds-show");
                    $A.util.addClass(spinner, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
})