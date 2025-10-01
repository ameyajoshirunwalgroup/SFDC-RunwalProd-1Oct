({
	statusPicklist : function(component, event, helper) {
		var action = component.get("c.getStatusValues");
        var statusVal = component.find("status");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "All",
                value: "All"
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            statusVal.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
	},
    
    campaignPicklist : function(component, event, helper) {
		var action = component.get("c.getCampaignValues");
        var campVal = component.find("camp");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "--None--",
                value: ""
            });
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            campVal.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
	}
})