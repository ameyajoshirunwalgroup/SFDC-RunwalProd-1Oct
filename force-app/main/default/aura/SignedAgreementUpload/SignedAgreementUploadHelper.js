({
    getUploadedAgreementFiles : function(component, event){
        var action = component.get("c.getAgreementFiles");  
        action.setParams({  
           "agreementdocumentId": component.get("v.SignedAgreementId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.Agreementfiles",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
    delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "sdocumentId":documentId            
        });  
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                this.getUploadedAgreementFiles(component);
                component.set("v.Spinner", false); 
                
                $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action);  
    },
    
})