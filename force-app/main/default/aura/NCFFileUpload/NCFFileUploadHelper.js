({
 getUploadedSanctionFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "ncfdocumentId": component.get("v.ncfdocumentId") 
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.ncffiles",result);  
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
                 
                 component.set("v.showSpinner", false); 
                 component.set("v.ncfuploadButton",false);
                 $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action);  
    },
  
})