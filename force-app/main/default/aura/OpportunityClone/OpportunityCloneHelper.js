({
    fetchOrder : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.creteCloneOpportunities");
        action.setParams({
            oppId : recordId
        });
        debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                debugger;
                var reasonOption = [];
                var select = false;
                var returnValue = response.getReturnValue();
                // alert(returnValue);
                if(returnValue.startsWith("006")){
                    //if(returnValue){
                    //var url = 'https://runwal--uat.lightning.force.com/lightning/r/Opportunity/'+returnValue+'/view';
                    var url = 'https://runwal--fullcopy.sandbox.lightning.force.com/lightning/r/Opportunity/'+returnValue+'/view';
                    //var url = 'https://runwal.lightning.force.com/lightning/r/Opportunity/'+returnValue+'/view';
                    helper.gotoURL(component, event, helper, url);
                    component.closeModalBox();
                    
                }
                else{
                    component.set("v.loading", false);
                    component.set("v.showErrorMsg", true);
                    component.set("v.errorMsg", 'There was while cloning the data');
                    component.set("v.visibleButton", false);
                }
                
                
                
            }else{
                debugger;
                component.closeModalBox();
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "Error",
                    "duration" : "5000ms",
                    "message": "There was an error while cloning the data" + errors[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    gotoURL : function (component, event, helper, url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})