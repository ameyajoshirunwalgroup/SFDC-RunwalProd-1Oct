({
    doInit : function(component, event, helper) {
        var action = component.get("c.checkforApproval");
        console.log('entered here -- >' + action);
        action.setParams({ "recId" : component.get("v.recordId") });
        action.setCallback(this, function(response) 
                           { 
                               var state = response.getState(); 
                               if (state === "SUCCESS") 
                               {debugger;
                                   var responsevalues = response.getReturnValue();
                                if(responsevalues.length>0){
                                   component.set("v.isError",true);
                                     component.set("v.errormessage",responsevalues);
                                }else{
                                                                       component.set("v.isError",false);

                                }
                                  
                               }});
        $A.enqueueAction(action); 
    }
    ,
    sendforapproval:function(component,event,helper){debugger;
        var action = component.get("c.sendApprovalRequest");
                                                     component.set("v.disabled",true);
        console.log(component.get("v.recordId"));
        console.log('entered here -- >' + action);
        action.setParams({ "recordId" : component.get("v.recordId"),"Comments":component.get("v.comments") });
        action.setCallback(this, function(response) 
                           { 
                               var state = response.getState(); 
                               if (state === "SUCCESS") 
                               { var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "SUCCESS!",
                                    "type":"success",
                                    "message": "Booking Approval request was sent successfully." 
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                $A.get('e.force:refreshView').fire();
                                
                               } if(state === "ERROR")
                               {component.set("v.disabled",false);
                                   var toastEvent = $A.get("e.force:showToast");
                                   toastEvent.setParams({
                                       "title": "ERROR!",
                                       "type":"error",
                                       "message": response.getError()[0].message 
                                   });
                                   toastEvent.fire();
                               }});
        $A.enqueueAction(action); 
        
    },
    closePopup :function(event){
        $A.get("e.force:closeQuickAction").fire();
    } ,
     handleClick: function (component, event, helper) {
         debugger;
               	 var recordId = event.target.dataset.sapid;
/*
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "objectApiName": "Payment_Milestone__c",
                        "slideDevName": "detail"

            
        });
        navEvt.fire();*/
         
          var navService = component.find("navService");
    var pageReference = {    
       "type": "standard__recordPage", //example for opening a record page, see bottom for other supported types
       "attributes": {
       "recordId": recordId, //place your record id here that you wish to open
       "actionName": "view"
        }
    }

    navService.generateUrl(pageReference)
    .then($A.getCallback(function(url) {
      console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
      window.open(url,'_blank'); //this opens your page in a seperate tab here
    }), 
    $A.getCallback(function(error) {
      console.log('error: ' + error);
    }));
    }
})