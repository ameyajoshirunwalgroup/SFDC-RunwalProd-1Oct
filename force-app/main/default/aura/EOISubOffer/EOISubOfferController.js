({
    
     doInit: function(component, event, helper)
    {
        if(component.get("v.recordId") != null && component.get("v.recordId") != undefined)
        {
        var action = component.get("c.getSubOfferRecord"); 
        action.setParams({ "recordId" : component.get("v.recordId") });
        action.setCallback(this, function(response) 
         {
            var state = response.getState();
             if (state === "SUCCESS") 
             {
                 if(response.getReturnValue()[0].Tower__c)
                 {
                     component.set("v.recordTowerValue",response.getReturnValue()[0].Tower__r.Name);
                     component.set("v.towerId",response.getReturnValue()[0].Tower__c);
                 }
       if(response.getReturnValue()[0].Project__c != undefined)
       {
       var action1 = component.get("c.getProjectTowers");
        action1.setParams({ "recordId" : response.getReturnValue()[0].Project__c });
        action1.setCallback(this, function(response) 
         {
            var state = response.getState();
             var towerNames = [];
             if (state === "SUCCESS") 
             {
                 
                        var conts = response.getReturnValue();
                        for(var key in conts)
                        {
                        towerNames.push({value:conts[key], key:key}  );
                        }
                        
                 
                 component.set("v.towerNames" , towerNames);
	         }
 
         });
        
        $A.enqueueAction(action1);
       }
             }
    });
        $A.enqueueAction(action);
        }
        else
        {
            component.set("v.disableTowerField",true);
        }
     
    },
	getTowers : function(component, event, helper) {
        if(event.getSource().get("v.value") !='' && event.getSource().get("v.value") != undefined)
        component.set("v.disableTowerField",false);
        else
        component.set("v.disableTowerField",true);   
        component.set("v.recordTowerValue",'');
        component.set("v.towerId",'');
		var action = component.get("c.getProjectTowers");
        action.setParams({ "recordId" : event.getSource().get("v.value") });
        action.setCallback(this, function(response) 
         {
            var state = response.getState();
             var towerNames = [];
             if (state === "SUCCESS") 
             {
                 
                        var conts = response.getReturnValue();
                        for(var key in conts)
                        {
                        towerNames.push({value:conts[key], key:key}  );
                        }
                        
                 
                 component.set("v.towerNames" , towerNames);
	}
});
         $A.enqueueAction(action);
        
    },
    
    handleSubmit : function(component, event, helper) 
    {
      
       /* var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Record Saved Successfully." 
                        });
                        toastEvent.fire();*/
            },
    
     handleError : function(component, event, helper) 
        {
            var error = event.getParams();
 
            // Get the error message
            var errorMessage = event.getParam("detail");
            var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": errorMessage 
                        });
                        toastEvent.fire();
                        return;
        },
    
     handleSuccess : function(component, event, helper) 
        {
            var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Record Saved Successfully." 
                        });
                        toastEvent.fire();
        },
     
     settower : function(component, event, helper) 
        {
            component.find("towerVal").set("v.value",component.get("v.towerId"));
        },
    
    redirectToOffer: function(component, event, helper) 
        {
            if(component.find("offerId").get("v.value") != '' || component.find("offerId").get("v.value") == undefined)
            {
             var navEvt = $A.get("e.force:navigateToSObject");
           // var params = event.getParams(); //get event params
        	//var recordId = params.response.id;
            navEvt.setParams({
              "recordId": component.find("offerId").get("v.value"),
              "slideDevName": "Detail"
            });
            navEvt.fire();
        }
        
    else
    {
       var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Offer should be selected to go back to that offer." 
                        });
                        toastEvent.fire();
	}
        }
    
    
})