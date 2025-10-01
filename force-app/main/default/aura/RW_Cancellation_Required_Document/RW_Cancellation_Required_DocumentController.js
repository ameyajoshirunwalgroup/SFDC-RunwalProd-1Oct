({
    doInit: function(component, event, helper) {        
        var BookingID = component.get("v.recordId"); 
        if(BookingID != null)
        {
        	helper.retrieveBookingRecord(component,BookingID); 
            component.set("v.checkListTick",'none');
            component.set("v.cancelTick",'none');
            component.set("v.deedTick",'none');
            component.set("v.transferTick",'none');
        }   
    },
    
    closePopup :function(event){
        $A.get("e.force:closeQuickAction").fire();
    } ,
    
    
    checklistUpload : function(component, event, helper) {        
            var uploadedFiles = event.getParam("files"); 
            component.find("cancellationCheck").set("v.value",true);
            component.find("CancellationCheckList").set("v.value",uploadedFiles[0].documentId);
        	component.set("v.checklistButton",true);
        	component.set("v.checkListTick",' ');
    } ,
    
    letterUpload : function(component, event, helper) {
         var uploadedFiles = event.getParam("files"); 
            component.find("cancellationLet").set("v.value",true);
            component.find("CancellationLetter").set("v.value",uploadedFiles[0].documentId);
        	component.set("v.cancelButton",true);
        	component.set("v.cancelTick",' ');
    },
    
    deedUpload : function(component, event, helper) {
        var uploadedFiles = event.getParam("files"); 
            component.find("cancellationDeed").set("v.value",true);
            component.find("CancellationDeedDocument").set("v.value",uploadedFiles[0].documentId);
        	component.set("v.deedButton",true);
        	component.set("v.deedTick",' ');
    },
    
    unitTransferRequestFormUpload : function(component, event, helper) {
        var uploadedFiles = event.getParam("files"); 
            component.find("TransferRequestUp").set("v.value",true);
            component.find("transferRequestForm").set("v.value",uploadedFiles[0].documentId);
        	component.set("v.transferButton",true);
        	component.set("v.transferTick",' ');
    },
    
   /* unitTransferRequestFormUpload : function(component, event, helper) {
        // Get the list of uploaded files
        var BookingId = component.get("v.recordId");        
        var uploadedFiles = event.getParam("files");
 		var action = component.get('c.transferRequestUpload');
        action.setParams({
            "recordId": BookingId
        });    	
        $A.enqueueAction(action);
         var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        "title": "Success!",
        "message": "File "+uploadedFiles[0].name+" Uploaded successfully."
    });
	toastEvent.fire();   
    }, 
    */
    
    retainBooking : function(component, event, helper) {
        var msg ='Are you sure you want to retain this booking?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
        var BookingId = component.get("v.recordId");        
        var uploadedFiles = event.getParam("files");
 		var action = component.get('c.updateRetainBooking');
        action.setParams({
            "recordId": BookingId
        });    	
        $A.enqueueAction(action);
         var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
        "title": "Success!",
        "message": "Booking suceessfully retained"
    });
	toastEvent.fire();  
    var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
	dismissActionPanel.fire();  
    $A.get('e.force:refreshView').fire();
        }
    },
    
   handleSubmit: function(component, event, helper) {
        	
            event.preventDefault();       // stop the form from submitting
       		var cancellationRequestDate = component.find('cancellationRequestDate').get('v.value');
        	var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        if(component.find("cancelReason").get("v.value") == 'Unit transfer'){
            var transferdate = component.find('transferdate').get('v.value');            
    	    if(transferdate > today || transferdate < cancellationRequestDate)       
       		{        
       				   var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Transfer unit form upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
                		return;
    		}
        }
        
        if(component.find("cancelReason").get("v.value") == 'Unit cancelled'){
            
        
        	var checklistdate = component.find('checklistdate').get('v.value');         	
    		if(checklistdate > today || checklistdate < cancellationRequestDate)
    		 {        
      				  var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Cancellation checklist upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
                 		return;
  			 }
        
        	 var cancellationdate = component.find('cancellationdate').get('v.value');             
   			 if(cancellationdate > today || cancellationdate < cancellationRequestDate)      
      		 {        
       				   var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Cancellation letter upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
                 		return;
   			 }
            
            if(component.find("registrationStatus").get("v.value") == 'Registration Completed'){
        	var deeddate = component.find('deeddate').get('v.value'); 
   			if(deeddate > today || deeddate < cancellationRequestDate)       
    		{        
       	               var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Deed document upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
                		return;
    		}
            }
        }
            
            var fields = event.getParam('fields');
            if(component.find("approvalStatus").get("v.value") != 'Sent for Approval' && component.find("approvalStatus").get("v.value") != 'Approved' )
            {
                if(fields.Cancellation_Reason__c == 'Unit cancelled') 
                {
             //fields.Cancellation_Deed_Uploaded__c == true  &&       
            if(fields.Cancellation_Checklist_Uploaded__c == true &&  fields.Cancellation_Letter_Uploaded__c ==  true)
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
                            "message": "Booking Cancellation Approval request was sent successfully." 
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
                            "message": "Please upload all required documents before sending for approval." 
                        });
                        toastEvent.fire();
            }
                }
                else{
                    if(fields.Transfer_Request_Uploaded__c)
            	{
                component.find('myRecordForm').submit(fields);
                var action = component.get("c.sendApprovalRequestforUnitTransfer");
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
                            "message": "Please attach transfer request form before sending for approval." 
                        });
                        toastEvent.fire();
            }
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
                            "message": "The approval for Booking Cancellation request has been sent successfully." 
                        });
                        toastEvent.fire();
    },
    
     transferValidation : function(component, event, helper){
    	 var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         var transferdate = component.find('transferdate').get('v.value');
         var cancellationRequestDate = component.find('cancellationRequestDate').get('v.value');
    	if(transferdate > today || transferdate < cancellationRequestDate)       
       {        
        var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Transfer unit form upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
        
        
    }
   },
    deedValidation : function(component, event, helper){
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         var deeddate = component.find('deeddate').get('v.value');
         var cancellationRequestDate = component.find('cancellationRequestDate').get('v.value');
    if(deeddate > today || deeddate < cancellationRequestDate)       
       {        
        var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Deed document upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
        
        
    }
   },
   checklistValidation : function(component, event, helper){
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	 var checklistdate = component.find('checklistdate').get('v.value');
         var cancellationRequestDate = component.find('cancellationRequestDate').get('v.value');
    if(checklistdate > today || checklistdate < cancellationRequestDate)
       {        
        var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Cancellation checklist upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
    }
   },
    cancellationValidation : function(component, event, helper){
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
         var cancellationdate = component.find('cancellationdate').get('v.value');
         var cancellationRequestDate = component.find('cancellationRequestDate').get('v.value');
    if(cancellationdate > today || cancellationdate < cancellationRequestDate)      
       {        
        var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Cancellation letter upload date should be between Cancellation request date and today." 
                        });
                        toastEvent.fire();
    }
   },
})