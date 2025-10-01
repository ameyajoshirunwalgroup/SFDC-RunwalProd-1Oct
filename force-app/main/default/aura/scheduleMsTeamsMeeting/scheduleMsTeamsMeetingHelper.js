({
   // sending Lead to cls
    handleSubmitHelper: function (component, event) {
     var action = component.get("c.msIntegration");
     var sObjectType = component.get("v.sobjecttype");
    console.log('sObjectType!!!',sObjectType);
      component.set("v.disableButton",true);
      component.set("v.Spinner", true); 
    
     console.log('selectItem in submit value ',component.find('selectItem').get("v.value"));
     action.setParams({
            "strLeadOROppId":component.get("v.recordId"),
            "sObjectType" :component.get("v.sobjecttype"),
            "startTime":component.find('StartTime').get("v.value"),
            "endTime":component.find('EndTime').get("v.value"),
            "subject":component.find('Subject').get("v.value"),
            "content":component.find('Content').get("v.value"),
            "btnLable": 'Schedule',
            "taskType": component.find('selectItem').get("v.value")
      });
       
       action.setCallback(this, function(response){  
          var state = response.getState();
          console.log('statel!!! ',state);
             if ("SUCCESS" === state ) {
                 //alert(response.getReturnValue());                
                if(null!=response.getReturnValue()){
					var msTeamObj = response.getReturnValue(); 
                    console.log('msTeamObj!!!',msTeamObj);
                     component.set("v.Spinner", false);
                    if(state == 'SUCCESS'){
                        if(msTeamObj.RW_MeetingID__c != '' && msTeamObj.RW_MeetingID__c != null){
                         var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Meeting has been Scheduled Successfully',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                        console.log('navEvt!!!',navEvt);
                        navEvt.setParams({
                        "recordId": msTeamObj.Id
                        
                       });
                      navEvt.fire();
                      $A.get("e.force:closeQuickAction").fire();
                      $A.get('e.force:refreshView').fire();
                    }  
				  }
                }
              }
			 });  
		
        $A.enqueueAction(action);  
     },
    
    handleCloseHelper : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
     },
    
    onChangeHelper : function(component, event, helper) {
        console.log('in on chnage helper');
        var startTime = component.find('StartTime').get("v.value");
        var endTime = component.find('EndTime').get("v.value");
        var subject = component.find('Subject').get("v.value");
        var content = component.find('Content').get("v.value");
         var selectItem = component.find('selectItem').get("v.value");
        if(startTime != null && startTime != '' && endTime != null && endTime != '' 
           && subject != null && subject != '' && content != null && content != ''
          && selectItem != null && selectItem != ''){
            
            component.set("v.disableButton",false);
        }else{
            component.set("v.disableButton",true); 
        }
    },
    handleDropDownHelper: function(component, event, helper) {
        console.log('In handleDropDownHelper');
    
    var selectItem = component.find('selectItem').get("v.value");
        console.log('selectItem in handleDropDownHelper ',selectItem);
        component.set("v.selectItem",selectItem);
         if(selectItem != null && selectItem != ''){
            
            component.set("v.disableButton",false);
        }else{
            component.set("v.disableButton",true); 
        }
    }   
   
   
})