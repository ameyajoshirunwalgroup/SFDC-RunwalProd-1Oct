({
	doInit : function(component, event, helper) {
		
	},
    
    showData : function(component, event, helper) {
        
        helper.aopCpData(component);
        helper.otherCpData(component);
		/*var action = component.get("c.reportData");
        action.setParams({
            "strtDt": component.find("startDate").get("v.value"),
            "endDt":component.find("endDate").get("v.value")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response ', response.getReturnValue());
            component.set("v.repDetails", response.getReturnValue());
        });
        $A.enqueueAction(action);*/
	},
    
    generatePdf : function(component, event, helper) {
        //helper.otherCpData(component);
        var sch = component.get("v.schemeName");
        var cp  = component.get("v.broker");
        window.open("https://runwal--c.vf.force.com/apex/BrokerageInvoiceReportPdf?scheme="+sch+"&cpId="+cp);
    }
})