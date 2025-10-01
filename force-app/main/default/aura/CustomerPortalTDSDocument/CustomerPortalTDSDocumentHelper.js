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
    
       delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");           
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
    },
  
})