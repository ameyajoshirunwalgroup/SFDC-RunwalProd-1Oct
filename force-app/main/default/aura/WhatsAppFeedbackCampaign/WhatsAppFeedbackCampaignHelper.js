({
	updateCamp : function(component, sentStatus) {
        console.log('--updateCamp1');
		var campId = component.get("v.recordId");
        console.log('--updateCamp2');
        var action = component.get("c.updateCampaign");
        console.log('--updateCamp3');
        action.setParams({
            "campId":campId,
            "status":sentStatus
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('--updateCamp3');
            
        });
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
	}
})