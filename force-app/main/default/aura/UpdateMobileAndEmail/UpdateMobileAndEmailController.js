({
	doInit : function(component, event, helper) {
        
        component.set("v.showContinue", false);
        
        helper.countryCodePicklist(component);
        helper.dialingCountryPicklist(component);
        helper.secondaryCountryCodePicklist(component);
        
		var action = component.get("c.oppRecord");
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.oppRec",response.getReturnValue()); 
                /*console.log('mobile: ' + component.get("v.oppRec").RW_Mobile_No__c);
                var mob = component.get("v.oppRec").RW_Mobile_No__c;
                var secMob = component.get("v.oppRec").RW_Secondary_Mobile_No__c;
                component.set("v.mobileNumMasked", mob.replace(mob.substring(0,5), '*****'));
                component.set("v.secMobileNumMasked", secMob.replace(secMob.substring(0,5), '*****'));*/
            }else{
                console.log('Error: ',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	},
    
    updateNum : function(component, event, helper){
        var error;
        var errorMessage = '';
        if(component.get("v.oppRec").RW_Mobile_No__c != null &&component.get("v.mobileNum") == component.get("v.oppRec").RW_Mobile_No__c){
            error = true;
            //errorMessage += 'You entered the same Mobile number which is already existing! \n';
        }
        if(component.get("v.oppRec").RW_Secondary_Mobile_No__c != null &&component.get("v.secondaryMobileNum") == component.get("v.oppRec").RW_Secondary_Mobile_No__c){
            error = true;
            //errorMessage += 'You entered the same Secondary Mobile number which is already existing! \n';
        }
        if(component.get("v.oppRec").RW_Email__c != null && component.get("v.email") == component.get("v.oppRec").RW_Email__c){
            error = true;
            //errorMessage += 'You entered the same Email which is already existing! \n';
        }
        if(component.get("v.oppRec").RW_Secondary_Email__c != null && component.get("v.secondaryEmail") == component.get("v.oppRec").RW_Secondary_Email__c){
            error = true;
            //errorMessage += 'You entered the same Secondary Email which is already existing! \n';
        }
        if(component.get("v.oppRec").Account.Country_Code__c != null && component.get("v.selectedCountryCode") == component.get("v.oppRec").Account.Country_Code__c){
            error = true;
            //errorMessage += 'You entered the same Country code which is already existing! \n';
        }
        if(component.get("v.oppRec").Account.Country_Code_2__c != null && component.get("v.selectedSecCountryCode") == component.get("v.oppRec").Account.Country_Code_2__c){
            error = true;
            //errorMessage += 'You entered the same Secondary Country code which is already existing! \n';
        }
        if(component.get("v.oppRec").Account.Dialing_Country_2__c != null && component.get("v.selectedDailingCountry") == component.get("v.oppRec").Account.Dialing_Country_2__c){
            error = true;
            //errorMessage += 'You entered the same Country Name which is already existing! \n';
        }
        
        
        if(error === true){
            console.log('Error: ', errorMessage);
            //errorMessage += 'Please click Continiue to proceed.';
            errorMessage = 'There is no change in the requested values compared to those on the opportunity. This will still trigger approval process';
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": errorMessage,
                "type":'warning'
            });
            toastEvent.fire();
            component.set("v.showContinue", true);
        }else{
            
            helper.updateDetailsHelper(component);
            
            /*console.log('--updateMobileNumber--');
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
            $A.enqueueAction(action);*/
        }
    },

    updateDetails : function(component, event, helper){
        helper.updateDetailsHelper(component);
    }     
})