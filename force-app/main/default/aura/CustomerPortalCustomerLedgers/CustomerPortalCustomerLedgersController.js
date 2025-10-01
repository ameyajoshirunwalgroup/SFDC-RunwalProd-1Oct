({
	doInit : function(component, event, helper) {
      
        var url = $A.get('$Resource.CustomerPortalLedger');
        component.set('v.backgroundImageURL', url);
        var action=component.get('c.getPortalHomeData');
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state ='+state);
            if (component.isValid() && state === "SUCCESS") {
               

                component.set("v.RunwalHomeWrapList", response.getReturnValue());
                console.log('v.RunwalHomeWrapList='+JSON.stringify(response.getReturnValue()));
            }
        });$A.enqueueAction(action);
        
    },
    
})