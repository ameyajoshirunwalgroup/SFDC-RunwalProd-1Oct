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
    
    secondaryCountryCodePicklist : function(component, event){
        console.log('--secCountryCodePicklist helper');
        var action = component.get("c.getSecondaryCountryCodeList");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.secCountryCodeValues",response.getReturnValue());               
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
    },
    
    updateDetailsHelper : function(component, event){
        console.log('--updateMobileNumber--');
        var action = component.get("c.updateMobileNumber");
        action.setParams({
            "recId" : component.get("v.recordId"),
            "mobNum" : component.get("v.mobileNum"),
            "secMobNum" : component.get("v.secondaryMobileNum"),
            "countryCode" : component.get("v.selectedCountryCode"),
            "dailingCountry" : component.get("v.selectedDailingCountry"),
            "email" : component.get("v.email"),
            "secEmail" : component.get("v.secondaryEmail"),
            "secCountryCode" : component.get("v.selectedSecCountryCode")
        });
        
        
        component.set("v.Spinner",true);
        action.setCallback(this, function(response){
            component.set("v.Spinner",true);
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Mobile & Email updated was submitted for Approval!",
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