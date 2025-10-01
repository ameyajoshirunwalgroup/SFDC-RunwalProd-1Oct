({
	doInit: function(component, event, helper) 
    {
      
        
		 		var action = component.get("c.getPortalHomeData");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state: ' + state);
                    console.log('response: ' + response);
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
                        var a = component.get("v.RunwalHomeWrapList");
                        console.log('component var' + JSON.stringify(a));
					}
                    else if (state === "ERROR"){
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                		} 
                    }
                });
        
        
        $A.enqueueAction(action);
        
        
        //Get last login user account
        var action = component.get("c.getLastLoginTime");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var users = response.getReturnValue();
                if (users && users.length > 0) {
                    component.set("v.accountId", users[0].AccountId);
                    console.log('Last Login'+users[0].LastLoginDate);
                    const lastLoginDate = new Date(users[0].LastLoginDate);
                    const today = new Date();
                    today.setHours(0, 0, 0, 0);

                    console.log('lastLoginDate :: ', lastLoginDate);
                    console.log('today :: ', today);
                    if (lastLoginDate < today) {
                        console.log('true');
                        component.set("v.lastlogingtrthanToday", true);
                    } else {
                        console.log('false');
                        component.set("v.lastlogingtrthanToday", false);
                    }

                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})