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
                 }
            }
        });  
            $A.enqueueAction(action);  
        },
	
    // sending Lead to cls
    handleSubmitHelper: function (component, event) {
     var action = component.get("c.reScheduleMSMeeting");
     var msObj = component.get("v.msTeamObj");
     console.log('msObj.meetingID!!! ',msObj);
      component.set("v.disableButton",true);
      component.set("v.Spinner", true); 
         var leadId = '';  
        var leadEmail = '';
        var leadName = '';
        var oppId = '';  
        var oppEmail = '';
        var oppName = '';
       
        if(msObj.RW_Object_Type__c == 'Lead'){
            if(msObj.RW_Lead__c != null && msObj.RW_Lead__c != ''&& msObj.RW_Lead__c != 'undefined'){
            leadId = msObj.RW_Lead__c;
            }
             if(msObj.RW_Lead__r.Email != null && msObj.RW_Lead__r.Email != '' && msObj.RW_Lead__r.Email != 'undefined'){
               leadEmail = msObj.RW_Lead__r.Email;
             }
            if(msObj.RW_Lead__r.Name != null && msObj.RW_Lead__r.Name != '' && msObj.RW_Lead__r.Name != 'undefined'){
               leadName = msObj.RW_Lead__r.Name;
            }
        }else if(msObj.RW_Object_Type__c == 'Opportunity'){
            if(msObj.RW_Opportunity__c != null && msObj.RW_Opportunity__c != '' && msObj.RW_Opportunity__c != undefined){
              oppId = msObj.RW_Opportunity__c;
            }
             if(msObj.RW_Opportunity__r.RW_Email__c != null && msObj.RW_Opportunity__r.RW_Email__c != '' && msObj.RW_Opportunity__r.RW_Email__c != 'undefined'){
               oppEmail = msObj.RW_Opportunity__r.RW_Email__c;
             }
            if(msObj.RW_Opportunity__r.Name != null && msObj.RW_Opportunity__r.Name != '' && msObj.RW_Opportunity__r.Name != 'undefined'){
               oppName = msObj.RW_Opportunity__r.Name;
            }
        }
        
      action.setParams({
            "MsRecordID":component.get("v.recordId"),
            "sobjecttype":component.get("v.sobjecttype"),
            "startTime":component.find('StartTime').get("v.value"),
            "endTime":component.find('EndTime').get("v.value"),
            "content":component.find('Content').get("v.value"),
            "btnLable": 'ReSchedule',
            "meetingID" : msObj.RW_MeetingID__c,
            "leadId" : leadId,
            "leadEmail": leadEmail,
            "leadName": leadName,
            "oppId": oppId,
            "oppEmail": oppEmail,
            "oppName": oppName,
            "subject": msObj.RW_Title__c

      });
       
       action.setCallback(this, function(response){  
          var state = response.getState();
          console.log('statel!!! ',state);
             if ("SUCCESS" === state ) {
                 //alert(response.getReturnValue());
                   component.set("v.Spinner", false);                
                if(null!=response.getReturnValue()){
					var msTeamObj = response.getReturnValue(); 
                    console.log('msTeamObj!!! line 87',msTeamObj);
                    if(state == 'SUCCESS'){
                         var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success',
                                message: 'Meeting has been ReScheduled Successfully',
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
     },
    
    handleCloseHelper : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
     },
    
    onChangeHelper : function(component, event, helper) {
        console.log('in on chnage helper');
         var startTime = component.find('StartTime').get("v.value");
         var endTime = component.find('EndTime').get("v.value");
         var content = component.find('Content').get("v.value");
      
         if(startTime != null && startTime != '' && endTime != null && endTime != ''
            && content != null && content != ''){
            component.set("v.disableButton",false);
         }else{
            component.set("v.disableButton",true); 
         }
    }
    
})