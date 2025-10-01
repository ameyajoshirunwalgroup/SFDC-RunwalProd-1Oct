({
    doInit : function(component, event, helper){  
        // helper.getUploadedFiles(component, event);
        
        var action = component.get("c.getInspPossRecord");
        action.setParams({ "InspPossId":component.get("v.recordId")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   if(responsevalues.RW_InspectionPossession_File_ID__c)
                                   {
                                       component.set("v.fileId",responsevalues.RW_InspectionPossession_File_ID__c);
                                       if(component.get("v.fileId") !='' && component.get("v.fileId") != undefined)
                                       {
                                           helper.getUploadedFiles(component, event);
                                           
                                           component.set("v.fileUploadButton",true);
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
    
    fileUploadFinished : function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files"); 
        component.set("v.fileId",uploadedFiles[0].documentId);
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['fileId'] = component.get("v.fileId");
        details['documentType'] = event.getSource().get("v.name");
        details['InspPossId'] = component.get("v.recordId");  
        
        var action = component.get("c.updateInspPossData");  
        action.setParams({     
            "DocDetails": details 
        });
        
        action.setCallback(this,function(response){ 
            
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                var result = response.getReturnValue();           
              
                component.set("v.fileUploadButton",true);
             helper.getUploadedFiles(component, event); 
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