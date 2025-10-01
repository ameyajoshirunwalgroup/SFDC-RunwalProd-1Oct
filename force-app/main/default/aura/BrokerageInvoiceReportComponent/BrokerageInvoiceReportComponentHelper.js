({
	aopCpData : function(component, event, helper) {
		var action = component.get("c.aopCpReportData");
        console.log('scheme ', component.get("v.schemeName"));
        console.log('cpId ', component.get("v.broker"));
        action.setParams({
            "scheme": component.get("v.schemeName"),
            "cpId":component.get("v.broker")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.aopCpDetails", response.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    
    otherCpData : function(component, event, helper) {
        console.log('scheme ', component.get("v.schemeName"));
        console.log('cpId ', component.get("v.broker"));
		var action = component.get("c.otherCpReportData");
        action.setParams({
            "scheme": component.get("v.schemeName"),
            "cpId":component.get("v.broker")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.otherCpDetails", response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})