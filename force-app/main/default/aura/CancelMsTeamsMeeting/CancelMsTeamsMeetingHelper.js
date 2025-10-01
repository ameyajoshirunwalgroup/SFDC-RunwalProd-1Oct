({
    loadRecordIdHelper: function (component, event) {
       var action = component.get("c.msTeamRecord");
       var sObjectType = component.get("v.sobjecttype");
         console.log('sObjectType!!!',sObjectType);
        action.setParams({
              "MsRecordID":component.get("v.recordId")
              
      });
         
         action.setCallback(this, function(response){  
           
            var state = response.getState();
               if ("SUCCESS" === state ) {            
                  if(null!=response.getReturnValue()){
                      var msTeamObj = response.getReturnValue(); 
                      console.log('msTeamObj!!!',msTeamObj);
                      if(null!=msTeamObj.Name){
                          component.set("v.msTeamObj", msTeamObj);
                    }
               }else if ("ERROR" === state ) {
                  var errors = response.getError();
                  if (errors) {
                      if (errors[0] && errors[0].message) {
                         
                      }
                  } else {
                     
                  }
              }
          }
      });  
          $A.enqueueAction(action);  
      },
  // sending Lead to cls
  handleSubmitHelper: function (component, event) {
   var msObj = component.get("v.msTeamObj");
   console.log('msObj.RW_MeetingID__c!!! ',msObj.RW_MeetingID__c);
    component.set("v.disableButton",true);
   var action = component.get("c.cancelMSMeeting");
    action.setParams({
         "MsRecordID":component.get("v.recordId"),
         "sobjecttype":component.get("v.sobjecttype"),
          "btnLable": 'Cancel',
          "meetingID": msObj.RW_MeetingID__c
         
    });
     
     action.setCallback(this, function(response){  
        var state = response.getState();
        console.log('statel!!! ',state);
           if ("SUCCESS" === state ) {
               //alert(response.getReturnValue());                
              if(null!=response.getReturnValue()){
                  var msTeamObj = response.getReturnValue(); 
                  console.log('msTeamObj!!!',msTeamObj);
                   if(state == 'SUCCESS'){
                       var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Meeting has been Cancelled',
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
           });  
      
      $A.enqueueAction(action);  
   }
})