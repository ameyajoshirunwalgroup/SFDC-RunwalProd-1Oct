({
	doInit : function(component, event, helper) {
		helper.getFeedBackData(component);
	},
    
    SaveFB : function(component, event, helper) {
		helper.SaveFeedBackData(component);
        //helper.getFeedBackData(component);
	}
})