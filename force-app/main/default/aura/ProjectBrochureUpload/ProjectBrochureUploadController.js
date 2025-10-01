({
    doInit : function(component, event, helper){  
        // helper.getUploadedFiles(component, event);
        
        var action = component.get("c.getProjectRecord");
        action.setParams({ "projectId":component.get("v.recordId")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   if(responsevalues.RW_Project_Brochure_ID__c)
                                   {
                                       component.set("v.BrochureId",responsevalues.RW_Project_Brochure_ID__c);
                                       if(component.get("v.BrochureId") !='' && component.get("v.BrochureId") != undefined)
                                       {
                                           helper.getUploadedBrochureFiles(component, event);
                                           
                                           component.set("v.BrochureuploadButton",true);
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
    
    brochureUploadFinished : function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files"); 
        component.set("v.BrochureId",uploadedFiles[0].documentId);
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['BrochureId'] = component.get("v.BrochureId");
        details['documentType'] = event.getSource().get("v.name");
        details['projectId'] = component.get("v.recordId");  
        
        var action = component.get("c.updateBrochureData");  
        action.setParams({     
            "DocDetails": details 
        });
        
        action.setCallback(this,function(response){ 
            
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                var result = response.getReturnValue();           
              
                component.set("v.BrochureuploadButton",true);
             helper.getUploadedBrochureFiles(component, event); 
                  $A.get('e.force:refreshView').fire();
            }  
        });  
        $A.enqueueAction(action); 
      
    }, 
        
    delFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;        
        helper.delUploadedfiles(component,documentId);  
    },
   
})