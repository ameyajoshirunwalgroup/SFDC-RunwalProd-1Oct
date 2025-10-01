({
	doInit : function(component, event, helper) {
        
		var action = component.get("c.resetPassword");
        action.setParams({
            "oppId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Password Reset link was sent successfully!",
                    "type":'success'
                });
                toastEvent.fire();
                component.set("v.Spinner",false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }else if(state === 'ERROR'){
                console.log('error message: ', response.getError()[0].message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type":'error'
                });
                toastEvent.fire();
                component.set("v.Spinner",false);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})