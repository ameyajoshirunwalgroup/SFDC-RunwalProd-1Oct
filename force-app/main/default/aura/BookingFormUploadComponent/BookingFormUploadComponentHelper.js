({
	getUploadedFiles : function(component, event){
        console.log('getUploadedFiles--');
        var action = component.get("c.getFiles");  
           
        //var newVal =  component.get("v.BookingFormId")+ ',' +component.get("v.SignedCostSheetId");   
        var DocIds = component.get("v.DocIds");
        if(component.get("v.BookingFormId") != undefined){
            DocIds.push(component.get("v.BookingFormId"));
        }
        if(component.get("v.SignedCostSheetId") != undefined){
            DocIds.push(component.get("v.SignedCostSheetId"));
        }
        if(component.get("v.IOMId") != undefined){
            DocIds.push(component.get("v.IOMId"));
        }
        if(component.get("v.DeviationApprovalId") != undefined){
            DocIds.push(component.get("v.DeviationApprovalId"));
        }
        if(component.get("v.TokenPaymentId") != undefined){
            DocIds.push(component.get("v.TokenPaymentId"));
        }
        
        console.log('DocIds: ', DocIds);
        component.set("v.DocIds", DocIds);
        action.setParams({  
            "docIds": DocIds 
        });
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();  
                console.log('getUploadedFiles-result :', result);
                console.log('result length :', result[component.get("v.BookingFormId")]);
                
                component.set("v.BkgFormfiles",result[component.get("v.BookingFormId")]);  
                component.set("v.SignedCostSheetfiles",result[component.get("v.SignedCostSheetId")]);
                component.set("v.IOMfiles",result[component.get("v.IOMId")]);
                component.set("v.DeviationApprovalfiles",result[component.get("v.DeviationApprovalId")]);
                component.set("v.TokenPaymentfiles",result[component.get("v.TokenPaymentId")]);
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    delUploadedfiles : function(component,documentId,documentName) {
        component.set("v.showSpinner", true); 
        var action1 = component.get("c.getBookingRecord");
        
        action1.setParams({ "BookingId":component.get("v.recordId")}); 
        
        action1.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                var action = component.get("c.deleteFiles");
                    action.setParams({
                        "sdocumentId":documentId,
                        "documentName":documentName,
                        "BookingId": component.get("v.recordId")
                    });  
                    
                    action.setCallback(this,function(response){  
                        var state = response.getState();  
                        if(state=='SUCCESS'){ 
                            console.log('delUploadedfiles');
                            this.getUploadedFiles(component);
                            console.log('delUploadedfiles1');
                            //component.set("v.showSpinner", false); 
                            console.log('delUploadedfiles2');
                            $A.get('e.force:refreshView').fire();
                            window.location.href = "/" + component.get("v.recordId");
                            console.log('delUploadedfiles3');
                            component.set("v.showSpinner", false);
                        }  
                        if(state === "ERROR"){
                         component.set("v.disabled",false);
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
        }); 
        $A.enqueueAction(action1);
    }
})