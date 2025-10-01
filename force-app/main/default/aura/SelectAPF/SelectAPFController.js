({
    doInit : function(component, event, helper){
        
    },
    
    fetchApf : function(component, event, helper) {
        helper.fetchApfHelper(component);
    },
    
    getSelectedAPF : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        for (var i = 0; i < selectedRows.length; i++){
            console.log('You selected: ', selectedRows[i].Id);
        }
        component.set("v.selectedApf",selectedRows[0].Id);
    },
    
    saveApf : function(component, event, helper){
        console.log('saveApf');
        var action = component.get("c.updateApfOnLoan");
        action.setParams({
            "apfId" : component.get("v.selectedApf"),
            "loanId" : component.get("v.recordId"),
            "code" : component.get("v.connectorCode")
        });
        action.setCallback(this, function(response){
            var navEvt = $A.get("e.force:navigateToSObject");
            console.log('navEvt!!!',navEvt);
            navEvt.setParams({
                "recordId":  component.get("v.recordId")
                
            });
            navEvt.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
	}
    
})