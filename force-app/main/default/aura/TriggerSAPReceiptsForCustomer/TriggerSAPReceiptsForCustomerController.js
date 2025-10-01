({
    
	doInit : function(component, event, helper) {
        component.set("v.Spinner",true);
		var action = component.get("c.customerReceipts");
        action.setParams({
            "bkgId": component.get("v.recordId")
            //"timeStamp": component.get("v.timestamp")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Receipts were triggered!",
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