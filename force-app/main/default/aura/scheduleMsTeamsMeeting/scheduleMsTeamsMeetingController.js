({
    doInit : function(component, event, helper) {
        var timezone = $A.get("$Locale.timezone");
        var datetimestring =  new Date().toLocaleString("en-US", {timeZone: timezone}),
           datetime = new Date(datetimestring);
          datetime.setHours(datetime.getHours());
         component.set('v.todayDate', datetime);
        var dropDownOpts = [
            { value: "", label: "--None--" },
            { value: "Presales Call", label: "Presales Call" },
            { value: "Sales Call", label: "Sales Call" }
        ];
        component.set("v.dropDownOpts",dropDownOpts );
    },
    handleSubmit : function(component, event, helper) {
        helper.handleSubmitHelper(component);
    },
    onChangeFields : function(component, event, helper) {
        helper.onChangeHelper(component, event, helper);
    },
    handleDropDown: function(component, event, helper) {
        helper.handleDropDownHelper(component, event);
    },
     handleClose : function(component, event, helper) {
        helper.handleCloseHelper(component);
    }
})