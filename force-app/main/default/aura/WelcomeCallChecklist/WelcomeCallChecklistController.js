({
    doInit : function(component, event, helper) {
      //component.set("v.spinner", true);
      
        helper.checkWelcomecallHelper(component,event,helper).then(function(result) { // Added by Vinay 13-12-2024
            console.log(result);
            component.set("v.hasNoWelcomeCall", result);
            if(result == false){
                helper.loadRecordIdHelper(component,event,helper);
                helper.getPicklistValuesBank(component); 
                helper.loadCriticalListHelper(component,event,helper);
                helper.loadPerviousCallRemarksHelper(component,event,helper);
                helper.loadYesNoDropDownHelper(component,event,helper);
                helper.loadModeOfFundingHelper(component,event,helper);
                
                helper.handleCheckboxHelper(component,event,helper); // Added by Vinay 21-02-2025
                
                helper.regConsultants(component); 
            }
        });
        console.log('hasNoWelcomeCall: ', component.get("v.hasNoWelcomeCall"));
        
        /*helper.loadRecordIdHelper(component,event,helper); // Commented by Vinay 13-12-2024
        helper.getPicklistValuesBank(component); 
        helper.loadCriticalListHelper(component,event,helper);
        helper.loadPerviousCallRemarksHelper(component,event,helper);
        helper.loadYesNoDropDownHelper(component,event,helper);
        helper.loadModeOfFundingHelper(component,event,helper);
        
        helper.regConsultants(component);*/
       
       // component.set("v.currentURL", window.location.pathname);

       
       
    },
      // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
       component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
   
    handleCheckbox: function(component, event, helper) {
        helper.handleCheckboxHelper(component, event);
    },
    
    handleCheckboxChange: function(component, event, helper) {
        helper.handleCheckboxChangeHelper(component, event);
    },

    handleAccept : function(component, event, helper) {
        helper.handleAcceptHelper(component, event);
    },
    handleClose : function(component, event, helper) {
        helper.handleCloseHelper(component, event);
    },

    handlebankLoan : function(component, event, helper) {
        helper.handlebankLoanHelper(component, event, helper);
    },
    
    handleModeOfFundingChange: function(component, event, helper) {
        helper.handleModeOfFundingChange(component, event, helper);
    },
    
    updateBooking : function(component, event, helper) {
        helper.updatebking(component, event);
    },
    updateConsChrag : function(component, event, helper) {
        helper.updateConsChrg(component, event);
    }
	
     
    
  
})