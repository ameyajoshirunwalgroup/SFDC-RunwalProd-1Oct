({
	doInit : function(component, event, helper) {
        var sURL = window.location.href;
		var recordId = sURL.split('recordId=')[1];
        console.log('recordId : ',recordId)
        component.set("v.recordId",recordId)
	}
})