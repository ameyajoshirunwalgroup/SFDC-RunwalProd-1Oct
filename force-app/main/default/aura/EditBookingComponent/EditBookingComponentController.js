({
    doInit : function(component, event, helper) {
        component.set("v.Spinner",true); 
        
        helper.getPicklistValues(component); 
        helper.getDependentPicklist(component);
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.getApplicants");
        action.setParams({ recordId :recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValues = response.getReturnValue();
                console.log(responseValues);
                debugger;
                
                 component.set("v.opportunityId",responseValues.bookingDetails.booking.Customer__c);
                
                component.set("v.applicantDetails",responseValues.bookingDetails.applicants);
                console.log(component.get("v.applicantDetails").length);
                debugger;
                
                component.set("v.availedOffer",responseValues.appliedOffer);                
                component.set("v.maxApplicants",responseValues.maxApplicants);
                
                var action1 =component.get("c.checkKYCAccepted");
       			 action1.setParams({ recordId :recordId});
                action1.setCallback(this, function(response) {
            var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.kycVerified",response.getReturnValue());
                    }
                    else{}});
                
                   $A.enqueueAction(action1);
                
                if(responseValues.bookingDetails.applicants.length == 1){
                    component.set("v.removeDisabled",true);
                }else
                {
                    component.set("v.removeDisabled",false);
                    
                }
                if(responseValues.bookingDetails.applicants.length == responseValues.maxApplicants){
                    component.set("v.addDisabled",true);
                }else{
                    component.set("v.addDisabled",false);
                    
                }
                component.set("v.Spinner",false); 
                
            }else
            {
                
                component.set("v.Spinner",false);
                
                // component.set("v.isInvalid",true);
            }
        })
        $A.enqueueAction(action);
        
    },
    addApplicant: function(component,event,helper){
        component.set("v.childSpinner",true);
        
        var applicants = component.get("v.applicantDetails")	;
        
        var action = component.get("c.addApplicants");
        action.setParams({ applicants :applicants });
        debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                var responseValues = response.getReturnValue();
                component.set("v.applicantDetails",responseValues);
                
                if(responseValues.length == 1){
                    component.set("v.removeDisabled",true);
                }else
                {
                    component.set("v.removeDisabled",false);
                    
                }
                if(responseValues.length == component.get("v.maxApplicants")){
                    component.set("v.addDisabled",true);
                }else{
                    component.set("v.addDisabled",false);
                    
                }
                component.set("v.childSpinner",false);
            }else{
                component.set("v.childSpinner",false);
                
            }
        })
        $A.enqueueAction(action);
        
    },
    removeApplicant:function(component,event,helper){
        debugger;
        component.set("v.childSpinner",true);
        var applicants = component.get("v.applicantDetails");
        var action = component.get("c.removeApplicants");
        action.setParams({ applicants :applicants });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                var responseValues = response.getReturnValue();
                component.set("v.applicantDetails",responseValues);
                if(responseValues.length == 1){
                    component.set("v.removeDisabled",true);
                }else
                {
                    component.set("v.removeDisabled",false);
                    
                }
                if(responseValues.length == component.get("v.maxApplicants")){
                    component.set("v.addDisabled",true);
                }else{
                    component.set("v.addDisabled",false);
                    
                }
                component.set("v.childSpinner",false); 
            }else
            {
                component.set("v.childSpinner",false);
            }})
        $A.enqueueAction(action);
        
    },
    editform:function(component,event,helper){
        component.set("v.readonly",false);
        
    },
    cancelform:function(component,event,helper)
    {debugger;
     //   component.set("v.Spinner",true); 
     component.set("v.readonly",true);
     $A.get('e.force:refreshView').fire();
     
    },
    saveform:function(component,event,helper)
    {                component.set("v.Spinner",true);
     debugger;
     var valid = helper.validate(component,event);
     
     if(!valid){
     var applicants = component.get("v.applicantDetails");
            for (var i = 0;i < applicants.length;  i++) {
             debugger;
             if(applicants[i] != null && applicants[i] != undefined && applicants[i].Id != null && applicants[i].Id != undefined &&  applicants[i].Id.length < 15){
               applicants[i].Id=null;  
             }
           } 
     var action = component.get("c.saveApplicants");
     action.setParams({ applicants :applicants });
     action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
             debugger;
             component.set("v.readonly",true);
             
             var responseValues = response.getReturnValue();
             component.set("v.applicantDetails",responseValues);
             
             
             component.set("v.Spinner",false);
         }else{
             component.set("v.Spinner",false);
             
         }
     })
     $A.enqueueAction(action);
     }else{
         
                 component.set("v.Spinner",false);
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     "title": "ERROR!",
                     "type":"error",
                     "message": "Please check and correct all the Applicant errors in form and then submit"
                 });
                 toastEvent.fire();
     }
    },
    
    handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },
      handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
             
                var action1 =component.get("c.confirmKYCAccepted");
       			 action1.setParams({ recordId :component.get("v.recordId")});
                action1.setCallback(this, function(response) {
            var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.kycVerified",response.getReturnValue());
                                component.set('v.showConfirmDialog', false);
   $A.get('e.force:refreshView').fire();

                    }
                    else{}});
                
                   $A.enqueueAction(action1);

    },
     handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
})