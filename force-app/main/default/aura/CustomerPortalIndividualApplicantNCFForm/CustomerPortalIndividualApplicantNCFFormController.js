({
	doValidityCheck : function(component, event, helper) {
		console.log('**'+component.find('firstName'));
        var controlAuraIds = ["firstName","lastName","dateOfBirth","emailId","mobile","permanentaddr1","pincode"];
        //reducer function iterates over the array and return false if any of the field is invalid otherwise true.
        var isAllValid = controlAuraIds.reduce(function(isValidSoFar, controlAuraId){
            //fetches the component details from the auraId
            var inputCmp = component.find(controlAuraId);
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
        
        if(isAllValid)
        {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var dateValue = component.find("dateOfBirth").get("v.value");
            if(component.find("dateOfBirth").get("v.value") != undefined && component.find("dateOfBirth").get("v.value")  != null && dateValue >= today)
            {
                //cmp.set("v.Spinner",false);
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type":"error",
                    "message": "Date of Birth cannot be today or in the future for "+component.get('v.applicantdetails.appNumber')});
                toastEvent.fire();
                return false;
                
            }
            return true;
        }
        
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": "Please check and correct all the errors for "+component.get('v.applicantdetails.appNumber')
            });
            toastEvent.fire();
            return false;
        }
	},
    
    checkDateValidation: function(component, event, helper) 
    {
         var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var dateValue = event.getSource().get("v.value");
            if(dateValue >= today)
            {
            component.set("v.dateValidationError", true);
            }
            else
            {
                component.set("v.dateValidationError", false);
            }
    }
})