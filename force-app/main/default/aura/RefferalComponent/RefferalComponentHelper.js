({
	getLeadInfo : function(component) {
        // Load all event data
        var action = component.get("c.getLeadFromSFDC");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('response.getState()::'+response.getState());
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.Lead", response.getReturnValue());
               // alert(component.get("v.Lead"));
            }
			
            // Display toast message to indicate load status
            //var toastEvent = $A.get("e.force:showToast");
          
        });
         $A.enqueueAction(action);
    },
    getOpportunity : function(component) {
        // Load all event data
        var action = component.get("c.getOpp");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('response.getState()::'+response.getState());
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.Opportunity", response.getReturnValue());
                //alert(component.get("v.Opportunity"));
            }
			
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
          
        });
         $A.enqueueAction(action);
    },

	getProject : function(component) {
        // Load all event data
        var action = component.get("c.getProjName");
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('response.getState()::'+response.getState());
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.Project", response.getReturnValue());
				component.set("v.SelectedProj", response.getReturnValue()[0]);
                //alert(component.get("v.Opportunity"));
            }
			
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
          
        });
         $A.enqueueAction(action);
    },

	SaveReferralInfo : function(component,event) {
		var LastName = component.find("LastName").get("v.value");
   		 var FirstName = component.find("FirstName").get("v.value");
   		 var Mobile = component.find("Mobile").get("v.value");
   		 var Email = component.find("Email").get("v.value");
		 var ProjectSelected = component.get("v.SelectedProj");
        //alert('ProjectSelected::'+ProjectSelected);
        var action= component.get("c.insertLeadToServer"); 
        action.setParams({ "LastName" : LastName,
                          "FirstName":FirstName,
                          "Mobile":Mobile,
                          "Email":Email,
						  "SelectedProject":ProjectSelected});        
        action.setCallback(this, function(response) {
           
          // alert('state=='+response.getState());
            if(response.getState() == 'SUCCESS') 
			{
				alert(response.getReturnValue());
				if(response.getReturnValue().indexOf('Error : ') < 0)
				{
					component.set("v.LastName", "");
					component.set("v.FirstName", "");
					component.set("v.Mobile", "");
					component.set("v.Email", "");
					
				}
				
               //$A.get('e.force:refreshView').fire();              
      	     }
       	    else {
			alert("Oops. Something is wrong. Please contact you sales rep.");
       	     }
       	 });
		
        $A.enqueueAction(action);
	}
})