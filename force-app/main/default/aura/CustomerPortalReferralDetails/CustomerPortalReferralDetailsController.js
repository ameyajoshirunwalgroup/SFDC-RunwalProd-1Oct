({
    doInit: function(component, event, helper) 
    {
        var url = $A.get('$Resource.BackgroundImage');
        component.set('v.backgroundImageURL', url);
        

        component.set("v.Spinner",true);
	var action = component.get("c.getReferralRecords");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.ReferralWrapList",response.getReturnValue());
                        component.set("v.projectNames",response.getReturnValue().projectNames);
						component.set("v.Spinner",false);
                    }
                    else
                            {
                                var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "ERROR!",
                                        "type":"error",
                                        "message": "There was an error. Please try again later."});
                                    toastEvent.fire();
                                    component.set("v.Spinner",false);
                                    return;
                            }
                });
        $A.enqueueAction(action);
    },
    handleInputChange: function(component, event, helper) {
        var booleanValue = event.getParam('checked'); 
        component.set('v.referralObject.Opt_for_Referral__c', booleanValue);
    },
    submitReferral : function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        var controlAuraIds = ["firstName","lastName","emailId","contactnumber","howknown","optForReferral"];
        //reducer function iterates over the array and return false if any of the field is invalid otherwise true.
        var isAllValid = controlAuraIds.reduce(function(isValidSoFar, controlAuraId){
            //fetches the component details from the auraId
            var inputCmp = component.find(controlAuraId);
            console.log('inputCmp',inputCmp);
            //displays the error messages associated with field if any
            if(inputCmp != undefined)
            {
            inputCmp.reportValidity();
            //form will be invalid if any of the field's valid property provides false value.
            return isValidSoFar && inputCmp.checkValidity() ;
            }
            else
            {
                return true;
            }
             },true);
        
		console.log('isAllValid',isAllValid);   
        if(isAllValid)
        {
            console.log('opt-in: ',component.get("v.referralObject.Opt_for_Referral__c"));
            if(component.get("v.referralObject.RW_Project__c") == null || component.get("v.referralObject.RW_Project__c") == undefined || component.get("v.referralObject.RW_Project__c") == '' ) 
            {
                component.set("v.Spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please select a Project"});
                        toastEvent.fire();
                return;
            }
    		var action = component.get("c.insertReferral");
        	action.setParams({newReferral:component.get("v.referralObject")});
        	action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Referral Submitted successfully ."});
                        toastEvent.fire();
                        
                        var action1 = component.get("c.getReferralRecords");
                        action1.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") 
                            {
                                //component.set("v.RunwalHomeWrap",response.getReturnValue());
                                component.set("v.ReferralWrapList",response.getReturnValue());
                                component.set("v.projectNames",response.getReturnValue().projectNames);
                            	component.set("v.Spinner",false);
                                component.set("v.referralObject",'');

                            }
                            else
                            {
                                var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "ERROR!",
                                        "type":"error",
                                        "message": "There was an error. Please try again later."});
                                    toastEvent.fire();
                                    component.set("v.Spinner",false);
                                    return;
                            }
                        });
                $A.enqueueAction(action1);
                        
                        return;
                    }
                
                else if (state === "ERROR") 
                {
                                    var errors = response.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            // log the error passed in to AuraHandledException
                                           // console.log("Error message: " + 
                                                    // errors[0].message);
                                           var toastEvent = $A.get("e.force:showToast"); 
                                   			 toastEvent.setParams({
                                        "title": "ERROR!",
                                        "type":"error",
                                        "message": errors[0].message});
                                        toastEvent.fire();
                                        component.set("v.Spinner",false);
                                        return;
                                        }
                                    } else 
                                    {
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "title": "ERROR!",
                                                "type":"error",
                                                "message": "There was an error. Please try again later."});
                                            toastEvent.fire();
                                            component.set("v.Spinner",false);
                                            return;
                                    }
                                }
                });
               /* else
                {
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "There was an error. Please try again later."});
                        toastEvent.fire();
                        component.set("v.Spinner",false);
                        return;
                }*/
                
        $A.enqueueAction(action);
    }
    
    else
        {
            component.set("v.Spinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": "Please check and correct all the errors in form and then submit"
            });
            toastEvent.fire();
            
        }
    }
})