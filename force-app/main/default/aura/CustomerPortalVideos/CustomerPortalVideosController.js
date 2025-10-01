({
	doInit : function(component, event, helper) {
        console.log('doInit1');
		var action=component.get('c.videos');
        console.log('doInit2');
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state: ', state);
            if (state === "SUCCESS") {
                component.set("v.videos", response.getReturnValue());
              }
            console.log('response: ', response);
            console.log('response.getReturnValue(): ', response.getReturnValue());
        })
        ;$A.enqueueAction(action);
       
	},
    
    openvideoLink:function(component, event, helper) {
		//window.open("https://runwal--uat.sandbox.file.force.com/sfc/servlet.shepherd/document/download/"+chrg+"?operationContext=S1");
		window.open(event.getSource().get("v.value"));
    }
})