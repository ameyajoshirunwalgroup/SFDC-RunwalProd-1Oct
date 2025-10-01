({
	doInit : function(component, event, helper) {
		var action = component.get("c.nrrCheck");
        action.setParams({
            "recId" : component.get("v.recordId"),
            "oppId" : component.get("v.oppId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: ',state);
            if(state === "SUCCESS"){
                console.log('NRR: ', response.getReturnValue());
                component.set("v.NRR",response.getReturnValue());
                console.log('NRR: ', component.get("v.NRR"));
            }
        });
        $A.enqueueAction(action); 
	},
    
    handleUpdate: function(component, event, helper){
        var action = component.get("c.nrrUpdate");
        action.setParams({
            "nrr" : component.get("v.NRR")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: ',state);
            if(state === "SUCCESS"){
                console.log('NRR: ', response.getReturnValue());
                component.set("v.NRR",response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    },
    
    printNRR: function(component, event, helper){
        console.log('--printCheckList--');
        window.open("https://runwal--uat--c.sandbox.vf.force.com/apex/NRRPage?id=" + component.get("v.recordId"), '_blank');
    },
    
    selectOpp: function(component, event, helper){
        var lookupId = event.getParam("value")[0];
        console.log('lookupId: ', lookupId);
        var action = component.get("c.nrrCheck");
        action.setParams({
            "recId" : component.get("v.recordId"),
            "oppId" : lookupId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: ',state);
            if(state === "SUCCESS"){
                console.log('NRR: ', response.getReturnValue());
                component.set("v.NRR",response.getReturnValue());
                console.log('NRR: ', component.get("v.NRR"));
            }
        });
        $A.enqueueAction(action); 
    },
    
    updateParkings: function(component, event, helper){
        
        var action = component.get("c.updateCarParks");
        action.setParams({
            "nrr" : component.get("v.NRR")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: ',state);
            if(state === "SUCCESS"){
                console.log('NRR: ', response.getReturnValue());
                component.set("v.NRR",response.getReturnValue());
                console.log('NRR: ', component.get("v.NRR"));
            }
        });
        $A.enqueueAction(action); 
    },
    
    updateGST: function(component, event, helper){
        
        var action = component.get("c.updateGSTValues");
        action.setParams({
            "nrr" : component.get("v.NRR")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: ',state);
            if(state === "SUCCESS"){
                console.log('NRR: ', response.getReturnValue());
                component.set("v.NRR",response.getReturnValue());
                console.log('NRR: ', component.get("v.NRR"));
            }
        });
        $A.enqueueAction(action); 
    }
})