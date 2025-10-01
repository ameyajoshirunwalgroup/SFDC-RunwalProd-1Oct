({
    doInit : function(component, event, helper){  
        // helper.getUploadedFiles(component, event);
        
        var action = component.get("c.getLoanRecord");
        action.setParams({ "loanId":component.get("v.recordId")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   component.set("v.SanctionStatus",responsevalues.RW_Sanction_Status__c);
                                   component.set("v.HomeLoanTakenFrom",responsevalues.Home_Loan_Taken_From__c);
                                   console.log('Home_Loan_Taken_From__c: ', responsevalues.Home_Loan_Taken_From__c);
                                   if(responsevalues.RW_Sanction_Letter_ID__c)
                                   {
                                       component.set("v.SanctionId",responsevalues.RW_Sanction_Letter_ID__c);
                                       if(component.get("v.SanctionId") !='' && component.get("v.SanctionId") != undefined)
                                       {
                                           helper.getUploadedSanctionFiles(component, event);
                                           
                                           component.set("v.SanctionuploadButton",true);
                                       }
                                   }
                                   
                                   if(responsevalues.RW_TPA_Letter_Id__c)
                                   {
                                       component.set("v.TPAId",responsevalues.RW_TPA_Letter_Id__c);
                                     //  component.set("v.NocGenerated",responsevalues.RW_NOC_Generated__c)
                                       if(component.get("v.TPAId") !='' && component.get("v.TPAId") != undefined)
                                       { 

                                           helper.getUploadedTPAFiles(component, event);
                                           
                                           component.set("v.TPAuploadButton",true);
                                       }
                                   }
                                   
                                  
                                   if(responsevalues.RW_NOC_Generated__c)
                                   {
                                       component.set("v.NocGenerated",responsevalues.RW_NOC_Generated__c)
                                       if(component.get("v.NocGenerated") == true)
                                       { 
                                             //component.set("v.TPAuploadButton",true);
                                           $A.get('e.force:refreshView').fire();
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
        component.set("v.SanctionId",uploadedFiles[0].documentId);
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['sanctionId'] = component.get("v.SanctionId");
        details['documentType'] = event.getSource().get("v.name");
        details['loanId'] = component.get("v.recordId");  
        
        var action = component.get("c.updateSanctionData");  
        action.setParams({     
            "DocDetails": details 
        });
        
        action.setCallback(this,function(response){ 
            
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                               
                var result = response.getReturnValue();           
              
                component.set("v.SanctionuploadButton",true);
             helper.getUploadedSanctionFiles(component, event); 
                  $A.get('e.force:refreshView').fire();
            }/*else{
                if(component.get("v.HomeLoanTakenFrom") == null){
                    component.set("v.errorMessage",'Please fill the Home Loan Taken From field before uploading the Sanction letter');
                }else{
                    component.set("v.errorMessage",'');
                }  
            }*/  
        });  
        $A.enqueueAction(action); 
      
    }, 
    
    TPAUploadFinished : function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files");
        component.set("v.TPAId",uploadedFiles[0].documentId);
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['TPAId'] = component.get("v.TPAId");
        details['documentType'] = event.getSource().get("v.name");
        details['loanId'] = component.get("v.recordId");  
        
        var action = component.get("c.updateTPAData");  
        action.setParams({     
            "DocDetails": details 
        });
        
        action.setCallback(this,function(response){ 
            
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                
                var result = response.getReturnValue();           
               
                component.set("v.TPAuploadButton",true);
              helper.getUploadedTPAFiles(component, event);
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
    
    delTPAFiles:function(component,event,helper){
        component.set("v.Spinner", true); 
        var documentId = event.currentTarget.id;        
        helper.delUploadedTPAfiles(component,documentId);  
    },
    
})