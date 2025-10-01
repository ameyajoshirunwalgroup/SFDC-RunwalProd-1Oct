({
	getFeedBackData : function(component) {
		var action = component.get("c.getFeedBackData");
         action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(response.getReturnValue());
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null)
					component.set("v.lstFeedBack", response.getReturnValue());
				else
					component.set("v.lstFeedBack", null);
            }
        });
         $A.enqueueAction(action);
	},
    
    SaveFeedBackData : function(component) {
		var action = component.get("c.SaveFeedBackData");
        var lstFB = component.get("v.lstFeedBack");
        action.setParams({ "lstFeedBack" : lstFB});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
				alert(response.getReturnValue());
				if(response.getReturnValue().indexOf('Error - ') >= 0)
				{
					//alert(response.getReturnValue());
				}
				else
				{
					this.getFeedBackData(component);
				}
            }
        });
         $A.enqueueAction(action);
	}
})