({
	getExistingCase: function (component) {
		var action = component.get("c.getCase");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				//alert(response.getReturnValue());
				if(response.getReturnValue() != null)
				{
					component.set("v.wrapCase", response.getReturnValue());
				}
            }
			
        });
         $A.enqueueAction(action);
	},

	getProjectUnit : function(component) {
		var action = component.get("c.fetchUnits");
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstOfUnit", response.getReturnValue());
				component.set("v.SelectedUnit", response.getReturnValue()[0]);
            }
        });
         $A.enqueueAction(action);
	},

	getCaseType : function(component) {
		var action = component.get("c.fetchCaseType");
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstOfCaseType", response.getReturnValue());
				component.set("v.SelectedCaseType", response.getReturnValue()[0]);
            }
        });
         $A.enqueueAction(action);
	},
})