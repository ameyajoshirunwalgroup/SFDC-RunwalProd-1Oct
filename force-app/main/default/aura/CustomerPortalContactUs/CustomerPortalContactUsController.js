({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getPortalHomeData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistfound = false;
                component.set("v.RunwalHomeWrapList",response.getReturnValue());
                for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(picklistfound != true)
                            {

                            if(component.get("v.RunwalHomeWrapList")[i].complaintdependentPicklistMap != undefined && component.get("v.RunwalHomeWrapList")[i].complaintdependentPicklistMap != null)
                            {
                                if(component.get("v.RunwalHomeWrapList")[i].complaintdependentPicklistMap.RW_Complaint_SubType__c != undefined)
                                {
                                    picklistfound = true;
                                    console.log('**'+component.get("v.RunwalHomeWrapList")[i].complaintdependentPicklistMap.RW_Complaint_SubType__c)
                                    var map =component.get('v.DependentPicklistMap');
                                    var obj = component.get("v.RunwalHomeWrapList")[i].complaintdependentPicklistMap.RW_Complaint_SubType__c.pickListMap;
                                    var complaintTypes = [];
                                    for (var key in obj) {
                                      if (obj.hasOwnProperty(key)) {
                                        complaintTypes.push(key);
										map[key] = obj[key];
                                      }
                                    }
                                    
                                    component.set('v.DependentPicklistMap',map);
                                    component.set('v.ComplaintTypePicklistOptions', complaintTypes);
                                    console.log('complaintTypes: ', complaintTypes);
                                    
                                     var map1 =component.get('v.DependentCaseTypePicklistOptions');
                                     var ctobj = component.get("v.RunwalHomeWrapList")[i].caseTypedependentPicklistMap.Customer_Lifecycle_Touchpoint__c.pickListMap;
                                    var caseTypecomplaintTypes = [];
                                    for (var key in ctobj) {
                                      if (ctobj.hasOwnProperty(key)) {
                                        caseTypecomplaintTypes.push(key);
										map1[key] = ctobj[key];
                                      }
                                    }
                                    component.set('v.DependentCaseTypePicklistOptions',map1);
                                    component.set('v.CaseTypePicklistOptions', caseTypecomplaintTypes);
                                    console.log('complaintTypes: ', caseTypecomplaintTypes);
                                    
                                    //component.set('v.ComplaintPicklistOptions',component.get("v.RunwalHomeWrapList")[i].complaintdependentPicklistMap.RW_Complaint_SubType__c );
                                    
                                    var map2 =component.get('v.DependentCustLifeCyclePicklistOptions');
                                     var ctobj = component.get("v.RunwalHomeWrapList")[i].custLifedependentPicklistMap.RW_Complaint_Type__c.pickListMap;
                                    var custLifeCycleTypes = [];
                                    for (var key in ctobj) {
                                      if (ctobj.hasOwnProperty(key)) {
                                        custLifeCycleTypes.push(key);
										map2[key] = ctobj[key];
                                      }
                                    }
                                    component.set('v.DependentCustLifeCyclePicklistOptions',map2);
                                    component.set('v.CustLifeCyclePicklistOptions', custLifeCycleTypes);
                                    console.log('custLifeCycleTypes: ', custLifeCycleTypes);
                                }
                            }
                            }
                        }
                //helper.disableContactUs(component,event); //Added by Vinay 09-06-2025
            }
        });
        $A.enqueueAction(action); 
    },
    
     onComplaintTypeChange:  function(component, event, helper) 
    {
        var dependepicklist=[];
      for (var key in component.get('v.DependentPicklistMap')) 
      {
          if(key == event.getSource().get('v.value'))
          {
              component.get('v.DependentPicklistMap')[key];
              for(var i=0; i<component.get('v.DependentPicklistMap')[key].length; i++)
              {
                  dependepicklist.push(component.get('v.DependentPicklistMap')[key][i]);
              }
          }
      }
     component.set('v.ComplaintSubTypePicklistOptions', dependepicklist);
    
	},
    
    onCaseTypeChange:  function(component, event, helper) 
    {
        var dependepicklist=[];
      for (var key in component.get('v.DependentCaseTypePicklistOptions')) 
      {
          if(key == event.getSource().get('v.value'))
          {
              component.get('v.DependentCaseTypePicklistOptions')[key];
              for(var i=0; i<component.get('v.DependentCaseTypePicklistOptions')[key].length; i++)
              {
                  dependepicklist.push(component.get('v.DependentCaseTypePicklistOptions')[key][i]);
              }
          }
      }
     //component.set('v.ComplaintTypePicklistOptions', dependepicklist);
      component.set('v.CustLifeCyclePicklistOptions', dependepicklist);
    
	},
    
   onCustLifeCycleChange:  function(component, event, helper) 
    {
        var dependepicklist=[];
      for (var key in component.get('v.DependentCustLifeCyclePicklistOptions')) 
      {
          if(key == event.getSource().get('v.value'))
          {
              component.get('v.DependentCustLifeCyclePicklistOptions')[key];
              for(var i=0; i<component.get('v.DependentCustLifeCyclePicklistOptions')[key].length; i++)
              {
                  dependepicklist.push(component.get('v.DependentCustLifeCyclePicklistOptions')[key][i]);
              }
          }
      }
     component.set('v.ComplaintTypePicklistOptions', dependepicklist);
    
	},
    
    onsubmit:  function(component, event, helper) 
    {
        component.set("v.Spinner",true);
        
        if((component.get('v.complaintRecord.RW_Case_Type__c') != undefined && component.get('v.complaintRecord.RW_Case_Type__c') != null && component.get('v.complaintRecord.RW_Case_Type__c') != '')
            && (component.get('v.unitNumber') != undefined && component.get('v.unitNumber') != null && component.get('v.unitNumber') != '')
            && ((component.get('v.complaintRecord.Description') != undefined && component.get('v.complaintRecord.Description') != null && component.get('v.complaintRecord.Description') != ''))
          )
        {
        var details ={};
        details['bookingName'] = component.get("v.bookingName"); 
        details['bookingId'] = component.get("v.bookingId");
        details['unitnumber'] = component.get("v.unitNumber"); 
        details['projectId'] = component.get("v.projectId"); 
    	var action = component.get("c.insertCase");
        	action.setParams({newCase:component.get("v.complaintRecord"),"Details": details});
        	action.setCallback(this, function(response) {
                    var state = response.getState();
                console.log('response.getReturnValue(): ', response.getReturnValue());
                    if (state === "SUCCESS") 
                    {
                        
                        component.set("v.Spinner",false);
                        component.set("v.complaintRecord.RW_Complaint_Type__c","");
                        component.set("v.complaintRecord.RW_Complaint_SubType__c","");
                        component.set("v.unitNumber","");
                        component.set("v.complaintRecord.Description","");
                        component.set("v.complaintRecord.Customer_Lifecycle_Touchpoint__c","");
                        component.set("v.complaintRecord.RW_Case_Type__c","");
                        
                        var message = response.getReturnValue();
                        console.log('message: ', message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            //"title": "SUCCESS!",
                            "type":"success",
                            "mode": "sticky",
                            "message" : message});
                        toastEvent.fire();
                    }
                else
                {
                    component.set("v.Spinner",false);
                    component.set("v.complaintRecord.RW_Complaint_Type__c","");
                        component.set("v.complaintRecord.RW_Complaint_SubType__c","");
                        component.set("v.unitNumber","");
                        component.set("v.complaintRecord.Description","");
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "There was an error. Please try later." + response.getReturnValue()});
                        toastEvent.fire();
                    $A. get('e. force:refreshView').fire();
                }
            });

		$A.enqueueAction(action);
        }
        else
        {
            component.set("v.Spinner",false);
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                           "message": "Please fill all mandatory fields and then submit"});
                        toastEvent.fire();
                    $A. get('e. force:refreshView').fire();
        }
                       
	},
    
    setfields:  function(component, event, helper) 
    {
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].unitNumber == event.getSource().get('v.value'))
                            {
                                component.set('v.bookingName',component.get("v.RunwalHomeWrapList")[i].BookingName);
                                component.set('v.bookingId',component.get("v.RunwalHomeWrapList")[i].BookingId);
                                component.set('v.projectId',component.get("v.RunwalHomeWrapList")[i].ProjectId);
                            }
                        }
    }
})