({
    doInit : function(component, event, helper){  
        // helper.getUploadedFiles(component, event);
        var action = component.get("c.getTCURecord");
        action.setParams({ "TCUId":component.get("v.recordId")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   if(responsevalues.RW_Tower_Construction_Photo_ID__c)
                                   {
                                       component.set("v.SanctionId",responsevalues.RW_Tower_Construction_Photo_ID__c);
                                       if(component.get("v.SanctionId") !='' && component.get("v.SanctionId") != undefined)
                                       {
                                           helper.getUploadedSanctionFiles(component, event);
                                           
                                           component.set("v.SanctionuploadButton",true);
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
    
    sanctionUploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files"); 
        //component.set("v.SanctionId",uploadedFiles[0].documentId);
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        //details['sanctionId'] = component.get("v.SanctionId");
        details['documentType'] = event.getSource().get("v.name");
        details['tcuId'] = component.get("v.recordId");  
        var action = component.get("c.updateSanctionData");  
        action.setParams({     
            "DocDetails": details 
        });
        
        action.setCallback(this,function(response){ 
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                var result = response.getReturnValue();           
                component.set("v.SanctionuploadButton",true);
                component.set("v.SanctionId",response.getReturnValue());
                helper.getUploadedSanctionFiles(component, event); 
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