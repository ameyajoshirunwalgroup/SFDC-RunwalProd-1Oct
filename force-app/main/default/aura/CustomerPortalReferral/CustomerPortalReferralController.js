({
	doInit : function(component, event, helper) {
        
	var action = component.get("c.getEnquiryRecords");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('response.getState()');
                    if (state === "SUCCESS") 
                    {
                        
                        component.set("v.ReferralWrapList",response.getReturnValue());
                        //component.set("v.referralObject",component.get("v.ReferralWrapList"));
                        console.log('ReferralWrapList firstName ',response.getReturnValue().firstName);
                         console.log('ReferralWrapList',component.get("v.ReferralWrapList"));
                        
                        //component.set("RW_First_Name__c"
                        component.set("v.projectNames",response.getReturnValue().projectNames);
						//component.set("v.referralObject",'');
                    }
                    
                });
        $A.enqueueAction(action); 
    },
    
    submitReferral : function(component, event, helper)  {
        var action = component.get("c.insertReferral");
        console.log('newReferral +',component.get("v.referralObject"));
        component.get("v.referralObject").RW_First_Name__c = component.get("v.ReferralWrapList.firstName");
        component.get("v.referralObject").RW_Last_Name__c = component.get("v.ReferralWrapList.lastName");
        component.get("v.referralObject").RW_Email_Address__c = component.get("v.ReferralWrapList.emailId");
        component.get("v.referralObject").RW_Contact_Phone__c = component.get("v.ReferralWrapList.phone");
        	action.setParams({newReferral:component.get("v.referralObject")});
        console.log('newReferral +',component.get("v.referralObject"));
        	action.setCallback(this, function(response) {
                    var state = response.getState();
                console.log('state');
                    if (state === "SUCCESS") 
                    {
                     
                    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Referral Submitted successfully ."});
                        toastEvent.fire();
                    component.set("v.openModal", false);
                      
                    }
               
                });
       
        $A.enqueueAction(action);
        
    }
    
})