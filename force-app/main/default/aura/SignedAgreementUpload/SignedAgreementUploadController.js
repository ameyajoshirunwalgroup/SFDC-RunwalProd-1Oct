({
    doInit : function(component, event, helper){  
        var action = component.get("c.getBookingRecord");
        action.setParams({ "bookingId":component.get("v.recordId")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   if(responsevalues.RW_Signed_Agreement_Document_Id__c)
                                   {
                                       component.set("v.SignedAgreementId",responsevalues.RW_Signed_Agreement_Document_Id__c);
                                       if(component.get("v.SignedAgreementId") !='' && component.get("v.SignedAgreementId") != undefined)
                                       {
                                           helper.getUploadedAgreementFiles(component, event);
                                           
                                           component.set("v.AgreementnuploadButton",true);
                                       }
                                   }
                               }
                           });
        $A.enqueueAction(action);
        
        
    },      
    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },  
    
    AgreementUploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files"); 
        component.set("v.SignedAgreementId",uploadedFiles[0].documentId);
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['bookingId'] = component.get("v.recordId"); 
        var action = component.get("c.updateAgreementData");  
        action.setParams({     
            "DocDetails": details 
        });
        
        action.setCallback(this,function(response){ 
            var state = response.getState();  
            if(state=='SUCCESS'){
                component.set("v.AgreementnuploadButton",true);
                helper.getUploadedAgreementFiles(component, event);    
                var toastEvent = $A.get("e.force:showToast");
                // show toast on file uploaded successfully 
                toastEvent.setParams({
                    "message": "Files have been uploaded successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        
        $A.enqueueAction(action); 
        
    }, 
    
    
    delAgreementFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;        
        helper.delUploadedfiles(component,documentId);  
    },    
    
})