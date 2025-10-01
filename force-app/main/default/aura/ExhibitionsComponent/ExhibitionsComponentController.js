({
	doInit : function(component, event, helper) {
		helper.getExhibitonData(component);
	},
    
    addExhibition : function(component, event, helper) {
		helper.addExhibitionHelper(component);
        helper.getExhibitonData(component);
	}
})