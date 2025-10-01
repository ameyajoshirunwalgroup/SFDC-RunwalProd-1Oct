({
	getOpportunityData : function(component) {
		var action = component.get("c.getOpportunityData");
         action.setCallback(this, function(response) {
            var state = response.getState();
             //alert(response.getReturnValue());
            if (state === "SUCCESS") {
            	component.set("v.lstWrap", response.getReturnValue());  
                component.set("v.lstAtt", response.getReturnValue()[0].lstAttachment);
                component.set("v.objAtt",response.getReturnValue()[0].lstAttachment[0]);
            }
        });
         $A.enqueueAction(action);
	},
    
    getstageData : function(component, event) {
        component.set("v.topImage",null);
        var urlEvent = $A.get("e.force:navigateToSObject");
        //alert(event.target.id);
		var action = component.get("c.getstageData");
        action.setParams({ "strProjId" : event.target.id});
		action.setCallback(this, function(response) {
			var state = response.getState();
            //alert(response.getReturnValue());
            if (state === "SUCCESS") {
                //alert(component.get("v.imageIndex"));
                var returnvalue=response.getReturnValue();
                component.set("v.imageIndex", 0);                
            	component.set("v.lstAtt",returnvalue);  
                component.set("v.objAtt",returnvalue[0]); 
            }
			
        });
         $A.enqueueAction(action);
	},
    
    changeImgBack : function(component, event) {
        var currentImg = component.get("v.imageIndex");
        var lstAllAtt = component.get("v.lstAtt");
        component.set("v.imageIndex", currentImg - 1); 
        component.set("v.objAtt", lstAllAtt[currentImg - 1]); 
	},
    
    changeImgForwrd : function(component, event) {
        var currentImg = component.get("v.imageIndex");
        var lstAllAtt = component.get("v.lstAtt");
        component.set("v.imageIndex", currentImg + 1); 
        component.set("v.objAtt", lstAllAtt[currentImg + 1]); 
	},
})