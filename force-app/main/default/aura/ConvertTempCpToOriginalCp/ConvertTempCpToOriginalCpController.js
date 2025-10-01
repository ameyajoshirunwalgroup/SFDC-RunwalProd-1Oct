({
	doInit : function(component, event, helper) {
        var action = component.get("c.convertCp");
        action.setParams({
            "tempCpId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            component.set("v.Spinner",true); 
            var toastEvent = $A.get("e.force:showToast");
            console.log('state: ', state);
            if(state === "SUCCESS"){
                console.log('SUCCESS');
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Temp CP converted to Original CP Successfully!",
                    "type":"success"
                });
                
            }else if(state === 'ERROR'){
                console.log('------: ', response.getError());
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": "Error: " + response.getError()[0].message
                });
                
            }
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
            component.set("v.Spinner",false); 
            });
        
            
        $A.enqueueAction(action);
	}
})