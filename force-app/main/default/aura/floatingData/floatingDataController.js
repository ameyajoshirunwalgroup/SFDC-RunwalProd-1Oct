({
    doInit : function(component, event, helper) {
        var lWidth = window.innerWidth ;
        var action = component.get("c.lstFetchRunwalEvnts");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnData = response.getReturnValue();
                returnData.forEach((eachEvent,index)=>{
                    eachEvent['style'] = index == 0 ? window.innerWidth-150:-1600;
                });
                component.set("v.lstRunwalEvent", returnData);
                if(returnData.length > 0){
                    let intervalId = window.setInterval($A.getCallback(function() { 
                        helper.shiftDiv(component, event,lWidth);
                    } ), 60);
                     component.set("v.popssition",intervalId);
                }
               
            }
        });
      
		$A.enqueueAction(action); 
        
    },
    hadleMouseover : function(component, event, helper) {
         window.clearInterval(component.get("v.popssition"));
    },
    handleMouseout : function(component, event, helper) {
         let intervalId = window.setInterval($A.getCallback(function() { 
                    helper.shiftDiv(component, event,window.innerWidth);
                } ), 60);
          component.set("v.popssition",intervalId);
    }
})