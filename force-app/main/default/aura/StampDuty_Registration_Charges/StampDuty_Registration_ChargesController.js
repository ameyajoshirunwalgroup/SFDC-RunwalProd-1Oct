({
	doInit: function(component, event, helper) { 
        var BookingRecordID = component.get("v.recordId");         
        component.set("v.infocheck",'none');
        if(BookingRecordID != null)
        {            
        	helper.retrieveConsultantList(component);
            helper.retriveWelcomeCallstatus(component , BookingRecordID);
        }	
    },
    
    onChangeConsultant: function (component, event, helper) {
        
        var consultantId = event.getSource().get("v.value");        
        helper.retrieveConsultantInfo(component , consultantId);
        component.set("v.infocheck",'');
        component.set("v.emaildiv",'none');
    },
    
	saveCharges: function (component, event , helper) {
        var recordId = component.get("v.recordId");   
        helper.saveConsultationCharges(component , recordId);
        var consultationcharges = component.find('consultationcharges').get('v.value');
        if(consultationcharges != undefined && consultationcharges != null && consultationcharges != '')
        {
            helper.retrieveEmailContent(component, recordId);
        }
    },    
        
    customerEmail: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var emailContent = component.get("v.emailVal");  
        var action = component.get("c.sendEmail");
		 action.setParams({
                "emailContent": emailContent,
                "recordId" : recordId
            });
        action.setCallback(this, function(response) {
           
            if (response.getState() == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Email sent to customer successfully" 
                        });
                        toastEvent.fire();
                		$A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    CheckLength : function(component, event, helper) {
        var val = component.find("consultationcharges").get('v.value');
        if(val.length > 9){
            var comp = component.find("consultationcharges");
            comp.set('v.value',null);
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Invalid Amount" 
                        });
                        toastEvent.fire();
        }
    }
})