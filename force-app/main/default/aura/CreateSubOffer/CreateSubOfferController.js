({
    doInit: function(component, event, helper)
    {
         component.set("v.disableTowerField",true);
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
       /*if(component.find("towerVal").get("v.value") == '' || component.find("towerVal").get("v.value")== undefined)
       {
           var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please select a tower for the offer." 
                        });
                        toastEvent.fire();
                        return;
       }*/
        
       
        
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
            
            var navEvt = $A.get("e.force:navigateToSObject");
            var params = event.getParams(); //get event params
        	var recordId = params.response.id;
            navEvt.setParams({
              "recordId": recordId,
              "slideDevName": "Detail"
            });
            navEvt.fire();
        
        },
    
     settower : function(component, event, helper) 
        {
            component.find("towerVal").set("v.value",component.get("v.towerId"));
        }
})