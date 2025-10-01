({
	doInit : function(component, event, helper) {
		var action = component.get("c.getBookingRecord");
        action.setParams({"bkgId":component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var responsevalues = response.getReturnValue();
                console.log('responsevalues: ', responsevalues);
                component.set("v.BookingFormId",responsevalues.Booking_Form_Id__c);
                component.set("v.BookingFormUploaded",responsevalues.Booking_Form_Uploaded__c);
                component.set("v.SignedCostSheetId",responsevalues.Signed_Cost_Sheet_Form_Id__c);
                component.set("v.SignedCostSheetUploaded",responsevalues.Signed_Cost_Sheet_Uploaded__c);
                component.set("v.IOMId",responsevalues.IOM_Document_Id__c);
                component.set("v.IOMUploaded",responsevalues.IOM_Document_Uploaded__c);
                component.set("v.DeviationApprovalId",responsevalues.Deviation_Approval_Doc_Id__c);
                component.set("v.DeviationApprovalUploaded",responsevalues.Deviation_Approval_Doc_Uploaded__c);
                component.set("v.TokenPaymentId",responsevalues.Token_Payment_Doc_Id__c);
                component.set("v.TokenPaymentUploaded",responsevalues.Token_Payment_Doc_Uploaded__c);
                helper.getUploadedFiles(component, event);
                /*if(responsevalues.Booking_Form_Id__c){
                    component.set("v.BookingFormId",responsevalues.Booking_Form_Id__c);
                    component.set("v.BookingFormUploaded",responsevalues.Booking_Form_Uploaded__c);
                    if(component.get("v.BookingFormId") !='' && component.get("v.BookingFormId") != undefined){
                        helper.getUploadedFiles(component, event);
                        component.set("v.BkgFrmFileUploadButton",true);
                    }
                }*/
            }
        });
        $A.enqueueAction(action);
	},
    
    formUploadFinished : function(component, event, helper){
        var uploadedFiles = event.getParam("files");
        //component.set("v.BookingFormId",uploadedFiles[0].documentId);
        if(event.getSource().get("v.name") === 'Booking Form'){
            component.set("v.BookingFormId",uploadedFiles[0].documentId);
        }else if(event.getSource().get("v.name") === 'Signed Cost Sheet'){
            component.set("v.SignedCostSheetId",uploadedFiles[0].documentId);
        }else if(event.getSource().get("v.name") === 'IOM'){
            component.set("v.IOMId",uploadedFiles[0].documentId);
        }else if(event.getSource().get("v.name") === 'Deviation Approvals'){
            component.set("v.DeviationApprovalId",uploadedFiles[0].documentId);
        }else if(event.getSource().get("v.name") === 'Token Payment Details'){
            component.set("v.TokenPaymentId",uploadedFiles[0].documentId);
        }
        console.log('documentId: ', uploadedFiles[0].documentId);
        console.log('bkgFrmId: ', component.get("v.BookingFormId"));
        console.log('documentType: ', event.getSource().get("v.name"));
        console.log('bookingId: ', component.get("v.recordId"));
        console.log('File Label: ', event.getSource().get("v.name"));
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['bkgFrmId'] = component.get("v.BookingFormId");
        details['documentType'] = event.getSource().get("v.name");
        details['bookingId'] = component.get("v.recordId");
        details['fileType'] = event.getSource().get("v.name");
        
        var action = component.get("c.updateBookingFormData");  
        action.setParams({     
            "DocDetails": details 
        });
        action.setCallback(this,function(response){ 
            
            var state = response.getState();
            console.log('state: ', state);
            console.log('response: ', response);
            if(state=='SUCCESS'){ 
                            
                var result = response.getReturnValue();           
              	console.log('result: ', result);
                /*if(event.getSource().get("v.name") === 'Booking Form'){
                    component.set("v.BookingFormUploaded",true);
                }else if(event.getSource().get("v.name") === 'Signed Cost Sheet'){
                    component.set("v.SignedCostSheetUploaded",true);
                }else if(event.getSource().get("v.name") === 'IOM'){
                    component.set("v.IOMUploaded",true);
                }else if(event.getSource().get("v.name") === 'Deviation Approvals'){
                    component.set("v.DeviationApprovalUploaded",true);
                }else if(event.getSource().get("v.name") === 'Token Payment Details'){
                    component.set("v.TokenPaymentUploaded",true);
                }*/
                component.set("v.FileUploadButton",true);
             	helper.getUploadedFiles(component, event); 
                $A.get('e.force:refreshView').fire();
            } else{
                console.log('state: ', state);
            }
        });  
        $A.enqueueAction(action);
    },
    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },
    
    delFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;   
        var documentName = event.currentTarget.name; 
        helper.delUploadedfiles(component,documentId,documentName);
        helper.getUploadedFiles(component, event); 
        $A.get('e.force:refreshView').fire();
    },
    
    BookingFormCheck: function(component,event,helper){
        var checkCmp = component.find("bkgFrmCheckbox");
        console.log('checkCmp-- ', checkCmp.get("v.value"));
        component.set("v.BookingFormUploaded", checkCmp.get("v.value"));
        
        var action = component.get("c.updateCheckBox");  
        action.setParams({  
            "bkgId": component.get("v.recordId"),
            "checkBoxValue" : checkCmp.get("v.value"),
            "fileType" : "Booking Form"
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('getUploadedFiles-result :', result);
                //component.set("v.BookingFormUploaded",result);  
                $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action); 
    },
    
    SignedCostSheetCheck: function(component,event,helper){
        var checkCmp = component.find("signedCheckbox");
        console.log('checkCmp-- ', checkCmp.get("v.value"));
        component.set("v.SignedCostSheetUploaded", checkCmp.get("v.value"));
        
        var action = component.get("c.updateCheckBox");  
        action.setParams({  
            "bkgId": component.get("v.recordId"),
            "checkBoxValue" : checkCmp.get("v.value"),
            "fileType" : "Signed Cost Sheet"
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('getUploadedFiles-result :', result);
                //component.set("v.BookingFormUploaded",result);
                $A.get('e.force:refreshView').fire();  
            }  
        });  
        $A.enqueueAction(action); 
    },
    
    IOMCheck: function(component,event,helper){
        var checkCmp = component.find("iomCheckbox");
        console.log('checkCmp-- ', checkCmp.get("v.value"));
        component.set("v.IOMUploaded", checkCmp.get("v.value"));
        
        var action = component.get("c.updateCheckBox");  
        action.setParams({  
            "bkgId": component.get("v.recordId"),
            "checkBoxValue" : checkCmp.get("v.value"),
            "fileType" : "IOM"
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('getUploadedFiles-result :', result);
                //component.set("v.BookingFormUploaded",result);  
                $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action); 
    },
    
    deviationCheck: function(component,event,helper){
        var checkCmp = component.find("deviationCheckbox");
        console.log('checkCmp-- ', checkCmp.get("v.value"));
        component.set("v.DeviationApprovalUploaded", checkCmp.get("v.value"));
        
        var action = component.get("c.updateCheckBox");  
        action.setParams({  
            "bkgId": component.get("v.recordId"),
            "checkBoxValue" : checkCmp.get("v.value"),
            "fileType" : "Deviation Approval"
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('getUploadedFiles-result :', result);
                //component.set("v.BookingFormUploaded",result); 
                $A.get('e.force:refreshView').fire(); 
            }  
        });  
        $A.enqueueAction(action); 
    },
    
    tokenPayCheck: function(component,event,helper){
        var checkCmp = component.find("tokenPayCheckbox");
        console.log('checkCmp-- ', checkCmp.get("v.value"));
        component.set("v.TokenPaymentUploaded", checkCmp.get("v.value"));
        
        var action = component.get("c.updateCheckBox");  
        action.setParams({  
            "bkgId": component.get("v.recordId"),
            "checkBoxValue" : checkCmp.get("v.value"),
            "fileType" : "Token Payment"
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('getUploadedFiles-result :', result);
                //component.set("v.BookingFormUploaded",result); 
                $A.get('e.force:refreshView').fire(); 
            }  
        });  
        $A.enqueueAction(action); 
    }
})