({
	doInit : function(component, event, helper) {
        //alert('here i m');
		helper.getOpportunityData(component);
	},
    
    showStage : function(component, event, helper) {
		helper.getstageData(component, event);
	},
    
    changeImgBack : function(component, event, helper) {
		helper.changeImgBack(component, event);
	},
    
    changeImgForwrd : function(component, event, helper) {
		helper.changeImgForwrd(component, event);
	}
})