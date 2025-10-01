({
	doInit : function(component, event, helper) {
        debugger;
        component.set("v.loading", true);
        helper.fetchOrder(component, event, helper);
    },
     closeModalBox : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})