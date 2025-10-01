({
    doInit: function (component, event, helper) {
        var action = component.get("c.fetchADFDetail");
        action.setParams({ bookingId: component.get("v.recordId") });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast("Success", "ADF data fetched and updated.", "success");
            } else {
                var error = response.getError();
                var message = error && error[0] && error[0].message ? error[0].message : "Unknown error";
                helper.showToast("Error", message, "error");
            }

            $A.get("e.force:closeQuickAction").fire(); // Close the modal
            $A.get("e.force:refreshView").fire();      // Optional: refresh record page
        });

        $A.enqueueAction(action);
    }
})