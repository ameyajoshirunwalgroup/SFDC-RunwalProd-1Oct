({
	doInit : function(component, event, helper) {
        var campId = component.get("v.recordId");
        var action = component.get("c.whatsAppCapmaign");
        action.setParams({
            "campId":campId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var sentStatus;
            console.log('');
            component.set("v.Spinner",true); 
            //component.set("v.message",response.getReturnValue());
            //alert(response.getReturnValue());
            //$A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            if(state === "SUCCESS"){
                console.log('SUCCESS');
                if(response.getReturnValue() == 'Success'){
                    console.log('Success1');
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Campaign was sent Successfully!",
                        "type":"success"
                    });
                    console.log('Success2');
                }else if(response.getReturnValue() == 'Fail'){
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please add atleast one customer to send the Campaign",
                        "type":'error'
                    });
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue(),
                        "type":'error'
                    });
                }
                sentStatus = 'Campaign Sent';
            }else{
                sentStatus = 'Error';
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type":'error'
                });
            }
            
            toastEvent.fire();
            
            helper.updateCamp(component, sentStatus);
            $A.get("e.force:closeQuickAction").fire();
            component.set("v.Spinner",false); 
            });
        
            
        $A.enqueueAction(action);
	}
})