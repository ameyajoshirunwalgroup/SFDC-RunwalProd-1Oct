({
 getUploadedFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "InspPossDocumentId": component.get("v.fileId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.InspPossfiles",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },
    
   
    
    
       delUploadedfiles : function(component,documentId) {  
        var action = component.get("c.deleteFiles");           
        action.setParams({
            "IPdocumentId":documentId            
        });  
           
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                 this.getUploadedFiles(component);
                component.set("v.Spinner", false); 
                
                 component.set("v.fileUploadButton",false);
                 $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action);  
    },
    

  
})