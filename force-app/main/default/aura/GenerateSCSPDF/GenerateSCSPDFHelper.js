({
    helperCloseModal : function(component, event, helper) {        
        $A.get("e.force:closeQuickAction").fire();
    },
    
    helperShowToast : function(toastTitle, toastMsg, toastType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": toastTitle,
            "message": toastMsg,
            "type": toastType
        });
        toastEvent.fire();
    }
})