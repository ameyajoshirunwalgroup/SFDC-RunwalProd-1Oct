({
	retrieveBookingRecord: function(component, BookingID) {
        var action1 = component.get("c.getBookingRecordData");
        action1.setParams({ "recordId" : component.get("v.recordId") });
        action1.setCallback(this, function(response) 
         {
            var state = response.getState();
             
             if (state === "SUCCESS") 
             {
                  var allValues = response.getReturnValue(); 
                  component.set("v.info", allValues);
                  if(response.getReturnValue().Approval_Status__c == 'Sent for Approval')
                  {
                      component.set("v.errormessage", "This record is already sent for Approval and is pending with Approver.");
                  }
                 
             }
 
         });
        $A.enqueueAction(action1);
    },
})