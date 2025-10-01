({
	doInit : function(component, event, helper) {
        
        // Retrieve scheme during component initialization
        helper.getLeadInfo(component);
        helper.getOpportunity(component);
		helper.getProject(component);
       
       
    },//Delimiter for future code
     geturlEvent : function(component,event) {
        var recorId=event.currentTarget.childNodes[0].attributes[0].value;
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
    	     "recordId": recorId,
    	     "slideDevName": "related"
    		});
    		navEvt.fire();
    },
    handleRedeem : function(component, event, helper){
        var target = event.getSource();
         var recordId = target.get("v.labelClass");
        
        var action = component.get("c.updateOpportunity");
        
        action.setParams({ "oppId" : recordId});
        //alert('recordId:::'+recordId);
        action.setCallback(this, function(response) {
            //alert('recordId:::'+recordId);
            //alert('state=='+response.getState());
            if(response.getState() == 'SUCCESS') {
                $A.get('e.force:refreshView').fire();
                alert('Successfully Redemmed.');
                
            }
            else {
                alert("problem in deleting row from server");
            }
        });
        $A.enqueueAction(action);
    },
    insertLead : function(component,event,helper)
    {
        helper.SaveReferralInfo(component,event);
		helper.getLeadInfo(component);
    }
})