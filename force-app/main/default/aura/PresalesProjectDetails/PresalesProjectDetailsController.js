({
    doInit : function(component, event, helper) {
        
       var StopWhatsAppSendProjectDetails = $A.get("$Label.c.StopWhatsAppSendProjectDetails");
       var optionsCheckBox;
        
         if(StopWhatsAppSendProjectDetails == 'No'){
             optionsCheckBox = [
                { label: "WhatsApp", value: "WhatsApp"},
                { label: "Email", value: "Email"}
            ];
            component.set("v.show",false); // to hide 
        }else{
            optionsCheckBox = [
                { label: "Email", value: "Email" }
            ];
            component.set("v.show",true); // to show
       }
            component.set("v.optionsCheckBox",optionsCheckBox);
    },
    handleChangeCheckboxGroup : function(component, event, helper) {
        helper.handleChangeCheckboxGroupHelper(component, event);
    },
    handleSend : function(component, event, helper) {
        helper.handleSendHelper(component, event);
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
});