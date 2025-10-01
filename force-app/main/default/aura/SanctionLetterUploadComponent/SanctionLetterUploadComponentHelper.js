({
 getUploadedSanctionFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "SanctionDocumentId": component.get("v.SanctionId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.Sanctionfiles",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
     getUploadedTPAFiles : function(component, event){
        var action = component.get("c.getTPAFiles");  
        action.setParams({  
            "TPADocumentId": component.get("v.TPAId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.TPAfiles",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    
    
     /*  delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");
       if(component.get("v.SanctionStatus") =="Loan Sanctioned") 
       {
             var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                         "title": "ERROR!",
                         "type":"error",
                         "message": "Once Sanction Letter Uploaded cannot be deleted, Please verify!"
                     })
                    
                    
                     toastEvent.fire();
       }
           else{
               
                 action.setParams({
            "sdocumentId":documentId            
        });  
           
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                 this.getUploadedSanctionFiles(component);
                component.set("v.Spinner", false); 
                
                 component.set("v.SanctionuploadButton",false);
                 $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action);
           }
           
    }, */
    
      delUploadedfiles : function(component,documentId) {
     //   component.set("v.showSpinner", true); 
        var action1 = component.get("c.getLoanRecord");
        
        action1.setParams({ "loanId":component.get("v.recordId")}); 
        
        action1.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                if(response.getReturnValue().RW_Sanction_Status__c=="Loan Sanctioned")
                {      
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "type":"error",
                        "message": "Once Sanction Letter Uploaded cannot be deleted, Please verify!"
                    })
    
                    toastEvent.fire();
                    return;
                }
                else {
                    var action = component.get("c.deleteFiles");
                    action.setParams({
                        "sdocumentId":documentId            
                    });  
                    
                    action.setCallback(this,function(response){  
                        var state = response.getState();  
                        if(state=='SUCCESS'){ 
                            
                            this.getUploadedSanctionFiles(component);
                          //  component.set("v.showSpinner", false); 
                            
                            component.set("v.SanctionuploadButton",false);
                            $A.get('e.force:refreshView').fire();
                        }  
                    });  
                    $A.enqueueAction(action);
                }
            }  
        }); 
        $A.enqueueAction(action1);
        
        
        
    },
    
    
          delUploadedTPAfiles : function(component,documentId) {  
        var action = component.get("c.deleteTPAFiles");           
        action.setParams({
            "sdocumentId":documentId            
        });  
           
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
               this.getUploadedTPAFiles(component);
                component.set("v.Spinner", false); 
                
                 component.set("v.TPAuploadButton",false);
                 $A.get('e.force:refreshView').fire();
                
            }  
        });  
        $A.enqueueAction(action);  
    },
    
  
})