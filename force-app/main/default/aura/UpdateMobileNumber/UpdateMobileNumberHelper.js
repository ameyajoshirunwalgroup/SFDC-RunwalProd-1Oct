({
	countryCodePicklist : function(component, event){
        console.log('--countryCodePicklist helper');
        var action = component.get("c.getCountryCodeList");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.countryCodeValues",response.getReturnValue());               
            }else{
                console.log('Error: ',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    dialingCountryPicklist : function(component, event){
        console.log('--countryCodePicklist helper');
        var action = component.get("c.getDialingCountryList");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.dailingCountryValues",response.getReturnValue());               
            }
        });
        $A.enqueueAction(action);
    }
})