({
	doInit : function(component, event, helper) {
		var action = component.get("c.searchDocs"); 
        action.setParams({     
            "bkgId": component.get("v.recordId") 
        });
        
        action.setCallback(this,function(response){ 
            
            var state = response.getState();
            console.log('state: ', state);
            console.log('response: ', response);
            if(state=='SUCCESS'){ 
                var docs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    if(key == 'Error'){
                        console.log('Error Message: ', conts[key][0]);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": conts[key][0],
                            "type":"error",
                            "message": conts[key][0] 
                        });
                        toastEvent.fire();
                    }else{
                        docs.push({value:conts[key], key:key});
                    }
                }
                component.set("v.docDetails", docs);
                var result = response.getReturnValue();           
              	console.log('result: ', result);
                //component.set("v.docDetails",response.getReturnValue());
            } else{
                console.log('state: ', state);
            }
        });  
        $A.enqueueAction(action);
	},
    
    updateSelected : function(component, event, helper){
        component.set("v.DocType",event.getSource().get("v.value"));
        var sel = event.getSource().get("v.value");
        console.log('sel: ', sel);
    },
    
    formUploadFinished : function(component, event, helper){
        component.set("v.showSpinner", true);
        var uploadedFiles = event.getParam("files");
        component.set("v.DocId",uploadedFiles[0].documentId);
        var selected = component.get("v.DocType");
        
        console.log('selected: ', selected);
        
        console.log('documentId: ', uploadedFiles[0].documentId);
        console.log('bkgFrmId: ', component.get("v.BookingFormId"));
        console.log('documentType: ', event.getSource().get("v.name"));
        console.log('bookingId: ', component.get("v.recordId"));
        console.log('File Label: ', event.getSource().get("v.name"));
        var details ={};
        details['DocId'] = uploadedFiles[0].documentId;
        details['documentType'] = component.get("v.DocType");
        details['bookingId'] = component.get("v.recordId");
        
        var action = component.get("c.sendDocsToDms");  
        action.setParams({     
            "docIdVsBkgId": details 
        });
        action.setCallback(this,function(response){ 
            
            var state = response.getState();
            console.log('state: ', state);
            console.log('response: ', response);
            if(state=='SUCCESS'){ 
                            
                var result = response.getReturnValue();           
              	console.log('result: ', result);
                component.set("v.DocUrl",result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "SUCCESS!",
                    "type":"success",
                    "message": "File uploaded successfully." 
                });
                toastEvent.fire();
                component.set("v.showSpinner", false);
                //$A.get("e.force:closeQuickAction").fire();
                //$A.get('e.force:refreshView').fire();
                $A.enqueueAction(component.get('c.doInit'));
            } else{
                console.log('state: ', state);
            }
        });  
        $A.enqueueAction(action);
    }
})