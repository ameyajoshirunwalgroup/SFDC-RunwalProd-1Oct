({
    doInit : function(component, event, helper){
        
        helper.countryCodePicklist(component);
        helper.dialingCountryPicklist(component);
        console.log('Country Codes: ', component.get("v.countryCodeValues"));
    },
    
    
    
	updateNum : function(component, event, helper) {
        
        var error;
        var errorMessage;
        if(component.get("v.CurrentUser.Profile.Name") == 'System Administrator' && component.get("v.mobileNum") == null && component.get("v.secondaryMobileNum") == null){
            //window.alert('You did not entered any mobile number');
            /*var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "You did not entered any mobile number!",
                "type":'error'
            });
            toastEvent.fire();*/
            errorMessage = "Please enter any mobile number!!";
            error = true;
        }
        
        if(component.get("v.CurrentUser.Profile.Name") != 'System Administrator' && component.get("v.secondaryMobileNum") == null){
            //window.alert('You did not entered Secondary mobile number');
            errorMessage = 'Please enter Secondary mobile number';
            error = true;
        }else if(component.get("v.secondaryMobileNum") != null && (component.get("v.selectedCountryCode") == 'None' || component.get("v.selectedCountryCode") == undefined)){
            //window.alert('Please select Country Code');
            errorMessage = 'Please select Country Code';
            error = true;
        }else if(component.get("v.secondaryMobileNum") != null && (component.get("v.selectedDailingCountry") == 'None' || component.get("v.selectedCountryCode") == undefined)){
            //window.alert('Please select Dailing Country');
            errorMessage = 'Please select Dailing Country';
            error = true;
        }
        if(error === true){
            console.log('Error: ', errorMessage);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": errorMessage,
                "type":'error'
            });
            toastEvent.fire();
        }else{
            console.log('--updateMobileNumber--');
            var action = component.get("c.updateMobileNumber");
             action.setParams({
                "recId" : component.get("v.recordId"),
                 "mobNum" : component.get("v.mobileNum"),
                 "secMobNum" : component.get("v.secondaryMobileNum"),
                 "countryCode" : component.get("v.selectedCountryCode"),
                 "dailingCountry" : component.get("v.selectedDailingCountry")
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
                        "message": "Mobile Numbers updated in Opportunity and Account successfully!",
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
		
	}
})