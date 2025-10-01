({
    handleOpenModal: function(component, event, helper) {
        //For Display Modal, Set the "openModal" attribute to "true"
        component.set("v.openModal", true);
    },
     
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.openModal", false);
    },
     submitReferral : function(component, event, helper)  {
        var action = component.get("c.insertReferral");
        console.log('newReferral +',component.get("v.referralObject"));
        	action.setParams({newReferral:component.get("v.referralObject")});
        console.log('newReferral +',component.get("v.referralObject"));
        	action.setCallback(this, function(response) {
                    var state = response.getState();
                console.log('state');
                    if (state === "SUCCESS") 
                    {
                        component.set("v.ReferralWrapList",response.getReturnValue());
                                component.set("v.projectNames",response.getReturnValue().projectNames);
                                component.set("v.referralObject",'');
                         
                    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Referral Submitted successfully ."});
                        toastEvent.fire();
                   
                      /*  var action1 = component.get("c.getEnquiryRecords");
                        action1.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") 
                            {
                                //component.set("v.RunwalHomeWrap",response.getReturnValue());
                                component.set("v.ReferralWrapList",response.getReturnValue());
                                component.set("v.projectNames",response.getReturnValue().projectNames);
                            	
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
                                    
                            }
                        });
                $A.enqueueAction(action1);
                         return; */
                    }
               
                });
        component.set("v.openModal", false);
        $A.enqueueAction(action);
        
    } ,
    
    openMDMessage:function(component, event, helper) {
		//window.open("https://runwalgroup.in/corporate-profile#corp-4"); //Commented by coServe 28-10-2022
        window.open("https://runwalgroup.in/about-us.php#ourteam"); //Added by coServe 28-10-2022
    },
    
    openAffordabilityCalc:function(component, event, helper) {
		//window.open("https://runwalgroup.in/affordability-calculator"); //Commented by coServe 28-10-2022
        window.open("https://runwalgroup.in/affordability-calculator.php"); //Added by coServe 28-10-2022
    },
    
    openreferralScreen:function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );
         var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "referrals"  
            } 
            
        };  
          
        navService.navigate(pageReference);
    }
    
    
    
})