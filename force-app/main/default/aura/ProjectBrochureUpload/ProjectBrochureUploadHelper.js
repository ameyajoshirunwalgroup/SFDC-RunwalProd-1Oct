({
 getUploadedBrochureFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "BrochureDocumentId": component.get("v.BrochureId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.Brochurefiles",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
   
    
    
       delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "bdocumentId":documentId            
        });  
           
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                 this.getUploadedBrochureFiles(component);
                component.set("v.Spinner", false); 
                
                 component.set("v.BrochureuploadButton",false);
                 $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action);  
    },
    

  
})