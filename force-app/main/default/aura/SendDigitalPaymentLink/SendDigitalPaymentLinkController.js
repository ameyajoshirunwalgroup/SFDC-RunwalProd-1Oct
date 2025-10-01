({
	 sendLink : function(component,  event, helper)
    {
        var recordId = component.get("v.recordId");
        var amount = component.get("v.Amount");
		var action = component.get("c.generateHashAndSendRequest");
        action.setParams({  opportunityId : recordId , amount : amount});
                          
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
                          {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
				component.set("v.isSuccess", true);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                 "title": "SUCCESS!",
                 "type":"success",
                 "message": "Digital Payment Link is sent to the customer successfully"
                  });
                  toastEvent.fire();
                // $A.get('e.force:refreshView').fire();
                 
                  $A.get("e.force:closeQuickAction").fire();
                              $A.get('e.force:refreshView').fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
             
             else if(state === 'ERROR')
             {
                 //component.set("v.isSuccess", false);
                 
                 component.set("v.errorMessage", response.getError()[0].message);
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                 "title": "ERROR!",
                 "type":"error",
                 "message": component.get("v.errorMessage")
                  });
                  toastEvent.fire();

               
            }
    });
        $A.enqueueAction(action);
    }
})