({
		
    retrieveConsultantList: function(component) {
        
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}
        
        var action = component.get("c.getConsultantList");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                
                if (allValues != undefined && allValues.length > 0 && allValues != null) {
                    opts.push({
                        class: "optionClass",
                        label: "--None--",
                        value: ""
                    });
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({                           
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.consultantList", opts);
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "No consultant found." 
                        });
                        toastEvent.fire();
                    	$A.get("e.force:closeQuickAction").fire();
                    	return;
                }
                
               
                if(spinner) {
                    $A.util.removeClass(spinner,"slds-show");
                    $A.util.addClass(spinner, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
     retriveWelcomeCallstatus: function(component , elementId) { 
        
        var action = component.get("c.getWelcomeStatus"); 
        action.setParams({
                "recordId": elementId
            });
        
        action.setCallback(this, function(response) {
          
            if (response.getState() == "SUCCESS") {                
                var allValues = response.getReturnValue();
                
                if(allValues != undefined || allValues != null){
                component.set("v.welcomeStatus", allValues);  
                //alert(JSON.stringify(allValues[0].RW_Welcome_Call_Status__c));
                if(allValues[0].RW_Welcome_Call_Status__c != 'Accept'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "You can send SDR Letter only when Welcome call status is Accept" 
                        });
                        toastEvent.fire();
                    	$A.get("e.force:closeQuickAction").fire();
                    	return;
                }
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Welcome call not found" 
                        });
                        toastEvent.fire();
                    	$A.get("e.force:closeQuickAction").fire();
                    	return;
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    retrieveConsultantInfo: function(component , elementId) {        
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}        
        var action = component.get("c.getConsultantInfo"); 
        action.setParams({
                "consultantId": elementId
            });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.consultantInfo", allValues);
               
                if(spinner) {
                    $A.util.removeClass(spinner,"slds-show");
                    $A.util.addClass(spinner, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    retrieveEmailContent: function(component , elementId) {        
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}        
        var action = component.get("c.getEmailContent"); 
        action.setParams({
                "recordId": elementId
            });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.emailVal", allValues);
               
                if(spinner) {
                    $A.util.removeClass(spinner,"slds-show");
                    $A.util.addClass(spinner, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    saveConsultationCharges:function(component , elementId ){
		var consultationcharges = component.find('consultationcharges').get('v.value');
        var idInfo = component.find('idInfo').get('v.value');
        if(consultationcharges == '' || consultationcharges == undefined || consultationcharges == null) {
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please fill the consultation charges" 
                        });
                        toastEvent.fire();            			
            			return;
            
        } 
        
        var action = component.get("c.saveChargesInfo");
            action.setParams({
                "BookingId" : elementId ,
                "consultationcharges" : consultationcharges,
                "idInfo":idInfo
            }); 
           action.setCallback(this, function(response) {  
          
                if (response.getState() == "SUCCESS") { 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Consultation charges information saved" 
                        });
                        toastEvent.fire(); 
                        component.set("v.infocheck",'none');
                        component.set("v.firstdiv",'none');
        			    component.set("v.emaildiv",'');
        				
                     
            }  
               
            else if(state === "ERROR")
                    {
                        console.log(response.getError()[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": response.getError()[0].message 
                        });
                        toastEvent.fire();
                    }    
        });
    	$A.enqueueAction(action);
        
    },   
})