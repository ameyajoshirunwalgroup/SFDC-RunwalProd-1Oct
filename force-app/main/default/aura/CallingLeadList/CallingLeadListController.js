({
	doInit : function(component, event, helper) {
		helper.statusPicklist(component);
        helper.campaignPicklist(component);
	},
    
    showData : function(component, event, helper){
        console.log('campaign: ', component.get("v.campName"));
        console.log('status: ', component.get("v.status"));
        var action = component.get("c.leadList");
        var status = component.find("status");
        action.setParams({
            "camp": component.get("v.campName"),
            "status": component.get("v.status")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.leadData", response.getReturnValue());
            if(response.getReturnValue() != null ){
                component.set("v.showData", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    openRec : function(component, event, helper){
        var recId = event.currentTarget.id;
        var url = 'https://runwal.lightning.force.com/lightning/r/Lead/'+recId+'/view';
        window.open(url);
    }
})