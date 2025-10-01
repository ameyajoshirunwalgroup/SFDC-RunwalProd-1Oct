({ 
    getcollA: function(component) { 
        var action = component.get("c.getCollateralsA");
        console.log('Inside doinit:::');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var finalBrandList = response.getReturnValue();  
                component.set("v.contentsA",finalBrandList);  
            }
        });
        $A.enqueueAction(action);  
    }, 
    getcollB: function(component) { 
        var action = component.get("c.getCollateralsB");
        console.log('Inside doinit:::');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var finalBrandList = response.getReturnValue();  
                component.set("v.contentsB",finalBrandList);  
            }
        });
        $A.enqueueAction(action);  
    } 
})