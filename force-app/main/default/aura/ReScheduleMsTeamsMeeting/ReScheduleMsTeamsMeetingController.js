({
    doInit : function(component, event, helper) {
        var timezone = $A.get("$Locale.timezone");
        var datetimestring =  new Date().toLocaleString("en-US", {timeZone: timezone}),
         datetime = new Date(datetimestring);
         datetime.setHours(datetime.getHours());
         component.set('v.todayDate', datetime);
       
        helper.loadRecordIdHelper(component);   
	},
    handleSubmit : function(component, event, helper) {
        helper.handleSubmitHelper(component);
    },
    onChangeFields : function(component, event, helper) {
        helper.onChangeHelper(component, event, helper);
    },
    handleClose : function(component, event, helper) {
        helper.handleCloseHelper(component);
    }
})