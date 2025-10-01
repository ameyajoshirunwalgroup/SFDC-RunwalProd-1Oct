({
    doInit: function(component, event, helper)
    {

       var action = component.get("c.getProjectSiteHead");
        action.setParams({ "eoiRecId" : component.get("v.recordId") });
        action.setCallback(this, function(response) 
         {
            var state = response.getState();
             if (state === "SUCCESS") 
             {
                  component.find("cancellationApprover").set("v.value",response.getReturnValue());
                
             }
 
         });
        
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getEOIRecordData");
        action1.setParams({ "eoiRecId" : component.get("v.recordId") });
        action1.setCallback(this, function(response) 
         {
            var state = response.getState();
             if (state === "SUCCESS") 
             {
                  if(response.getReturnValue().RW_Approval_Status__c == 'Sent for Approval')
                  {
                      component.set("v.errormessage", "This record is already sent for Approval and is pending with Approver.");
                  }
                 
             }
 
         });
        
        $A.enqueueAction(action1);
    },
    
	onUploadFinished :   function(component, event, helper) {  
            
            var uploadedFiles = event.getParam("files"); 
            //uploadedFiles[0].documentId;
            component.find("cancellationEmail").set("v.value",true);
            component.find("cancellationEmailId").set("v.value",uploadedFiles[0].documentId);
    },
    
    handleSubmit: function(component, event, helper) {
            event.preventDefault();       // stop the form from submitting
            
            var fields = event.getParam('fields');
            if(component.find("approvalStatus").get("v.value") != 'Sent for Approval' && component.find("approvalStatus").get("v.value") != 'Approved' )
            {
            if(fields.RW_Cancellation_Email_Uploaded__c)
            {
                component.find('myRecordForm').submit(fields);
                var action = component.get("c.sendApprovalRequest");
                action.setParams({ recordId :component.get("v.recordId")});
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                         var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Cancellation Approval request was sent successfully." 
                        });
                        toastEvent.fire();
                         $A.get("e.force:closeQuickAction").fire();
                              $A.get('e.force:refreshView').fire();
                    }
                    
                    else if(state === "ERROR")
                    {
                         var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": response.getError()[0].message 
                        });
                        toastEvent.fire();
                    }
                });
                
                $A.enqueueAction(action); 
            }
            
        
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please upload EOI cancellation email before sending for approval." 
                        });
                        toastEvent.fire();
            }
            }
        else if(component.find("approvalStatus").get("v.value") == 'Sent for Approval'  )
            
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "This record is already sent for Approval. Please check Approval History." 
                        });
                        toastEvent.fire();
            return;
        }
        
        else if(component.find("approvalStatus").get("v.value") == 'Approved'  )
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "This record is already Approved. Please check Approval History." 
                        });
                        toastEvent.fire();
            return; 
        }
                
        },
    
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "The approval for Cancellation request has been sent successfully." 
                        });
                        toastEvent.fire();
    }
})