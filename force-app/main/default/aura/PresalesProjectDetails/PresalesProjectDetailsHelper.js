({
    
	handleChangeCheckboxGroupHelper: function (component, event, helper) {
           component.set("v.disableButton",false);
        var selectedCheckBoxValue = event.getParam('value');
        console.log('selectedCheckBoxValue!!! ',component.get("v.valueCheckBox"));
        component.set("v.selectedCheckBoxValue", selectedCheckBoxValue); 
       
     },
    handleSendHelper: function (component, event, helper) {
        var action = component.get("c.sendProjectDetailsAsEmail");
        var sObjectType = component.get("v.sobjecttype");
       console.log('sObjectType!!! ',sObjectType);
        console.log('recordId ',component.get("v.recordId"));
        console.log('selectedCheckBoxValue ',component.get("v.selectedCheckBoxValue"));
        
          action.setParams({
             "strLeadIdOROppIdORProspectID" :component.get("v.recordId"),
             "strSObjectType" :component.get("v.sobjecttype"),
             "ltsSelectedCheckBoxValueIs" :component.get("v.valueCheckBox")
             
        }); 
           
           action.setCallback(this, function(response){  
              var state = response.getState();
                if ("SUCCESS" === state ) {
                    component.set("v.errorMessage",'');
                    if(null!=response.getReturnValue()){
                       var presalesCommunication = response.getReturnValue(); 
                        console.log('presalesCommunication!!!',presalesCommunication);
                       var navEvt = $A.get("e.force:navigateToSObject");
                        console.log('navEvt!!!',navEvt);
                    navEvt.setParams({
                        "recordId": presalesCommunication.Id
                        
                    });
                    navEvt.fire();
                    }  
                }else
                 {
                     component.set("v.errorMessage",response.getError()[0].message);
                 }
                
            });  
		
        $A.enqueueAction(action);  
        
    }
})