({
    doInit: function(component, event, helper) {        
        var BookingID = component.get("v.recordId"); 
        if(BookingID != null)
        {
        	helper.getBookingRecordForRefundHandoverDocument(component,BookingID); 
            component.set("v.uploadedCheck",'none');
        }        
       
    },
    
    dateValidation : function(component, event, helper){
    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    var dateValue = component.find('refundDate').get('v.value');
    if(dateValue > today){
        var dateValue1 = component.find('refundDate').get('v.value'); 
        component.find('refundDate').set('v.value' , null);
        var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Refund handover date should not be future date." 
                        });
                        toastEvent.fire();
        
        
    }
   },
    
    handoverDocument : function(component, event, helper) {
        var uploadedFiles = event.getParam("files"); 
            component.find("refundUploaded").set("v.value",true);
            component.find("refundDocument").set("v.value",uploadedFiles[0].documentId);
        	component.set("v.handoverButton",true);
        	component.set("v.uploadedCheck",' ');
    },
    
    closePopup :function(event){
        $A.get("e.force:closeQuickAction").fire();
    } ,
    
 	handleSubmit: function(component, event, helper) {        
            event.preventDefault(); 
        	 var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
   			 var dateValue = component.find('refundDate').get('v.value');
   			 if(dateValue > today){ 
       		 var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Refund handover date should not be future date." 
                        });
                        toastEvent.fire();
                 return;
   			 }
        
            var fields = event.getParam('fields');
        	
            if(fields.Refund_handover_document_uploaded__c)
            {
                
                component.find('myRecordForm').submit(fields);
                var action = component.get("c.updateRefundHandoverDocument");
                action.setParams({
                    recordId :component.get("v.recordId"),                   
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                         var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Refund process completed." 
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
                            "message": "Please upload Refund Handover documents" 
                        });
                        toastEvent.fire();
            }
        },
    
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "The Reund Handover Document saved." 
                        });
                        toastEvent.fire();
    }
})