({
	 doInit : function( component, event, helper ) {  
          
        var action = component.get("c.getPortalHomeData");
         console.log('accId: ', component.get("v.accountId"));
         action.setParams({     
            "accId": component.get("v.accountId")
        });  
         action.setCallback(this, function(response) {
             var state = response.getState();
             console.log('state: ', state);
             console.log('--Error--', response.getError());
             if (state === "SUCCESS") 
             {
                 component.set("v.RunwalHomeWrapList",response.getReturnValue());
                 console.log('RunwalHomeWrapList: ', response.getReturnValue());
             }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type":'error'
                });
                toastEvent.fire();
            }
         });
        $A.enqueueAction(action);       
    },
    
    onsubmit : function( component, event, helper ) 
    {
        component.set("v.Spinner",true);
        var isValid ='true';
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length >0)
                            {
                                for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length;j++)
                                {
                                    if(event.getSource().get('v.name')== component.get("v.RunwalHomeWrapList")[i].BookingId)
                                    {
                                        var findarray = component.find(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                        var child;
                                        if(Array.isArray(findarray))
                                        {
                                          for(var k=0; k <findarray.length ; k++)
                                          {
                                              if(component.find(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber)[k].get('v.applicantdetails').bookingId == event.getSource().get('v.name'))
                                              {
                                                  child = component.find(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber)[k];
                                              }
                                          }
                                        }   
                                        else
                                        {
                                            child = component.find(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                        }
                                            
                                        //var child = component.find(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
     									var isChildValid = child.doValidityCheck();
                                        if(!isChildValid)
                                        {
                                            component.set("v.Spinner",false);
                                            return;
                                            
                                        }
                                        
                                        
        var controlAuraIds = ["poapannumber","nomineepannumber","poamobile","poaemail"];
        //reducer function iterates over the array and return false if any of the field is invalid otherwise true.
        var isAllValid = controlAuraIds.reduce(function(isValidSoFar, controlAuraId){
            //fetches the component details from the auraId
            
            var findarray = component.find(controlAuraId);
                                        var child;
                                        if(Array.isArray(findarray))
                                        {
                                          for(var k=0; k <findarray.length ; k++)
                                          {
                                              if(component.find(controlAuraId)[k].get('v.name') == event.getSource().get('v.name'))
                                              {
                                                  child = component.find(controlAuraId)[k].get('v.name');
                                              }
                                          }
                                        }   
                                        else
                                        {
                                            child = component.find(controlAuraId);
                                        }
            
            var inputCmp = child;
            //var inputCmp = component.find(controlAuraId);
            //displays the error messages associated with field if any
            if(inputCmp != undefined)
            {
            inputCmp.reportValidity();
            //form will be invalid if any of the field's valid property provides false value.
            return isValidSoFar && inputCmp.checkValidity() ;
            }
            else
            {
                return true;
            }
           
        },true);
                                        
        if(!isAllValid)
        {
           helper.onerrorMessage(component,event,helper,'Please check and correct all errors under Nominee/POA');
           isValid = 'false';
           component.set("v.Spinner",false);
           return; 
        }


                                        
                                      /* if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].firstName =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].firstName == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter First Name for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].lastName =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].lastName == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Last Name for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].dateOfBirth =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].dateOfBirth == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Date Of Birth for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].email =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].email == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Email for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].mobile =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].mobile == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Mobile Number for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                         if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].permanentaddr1 =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].permanentaddr1 == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Permanent Address Line 1 for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].country =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].country == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Country for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].state =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].state == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter State for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].city =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].city == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter City for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                         if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].pin =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].pin == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Pin for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].applicantType =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].applicantType == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Type Of Applicant under KYC Documents Section for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].residentialStatus =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].residentialStatus == undefined) 
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter Residential Status under KYC Documents Section for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        if((component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].panCard =='' || component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].panCard == undefined) && component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].residentialStatus =='Indian National')
                                       {
                                           helper.onerrorMessage(component,event,helper,'Please enter PAN Number under KYC Documents Section for '+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber);
                                           isValid = 'false';
                                           return;
                                       }
                                        
                                        */
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
        
        if(isValid == 'true')
        {
        var ncfprimaryapplicantdetails;
        var ncfotherapplicantdetails ={};
        var ncfotherdetails ={};
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length >0)
                            {
                                for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length;j++)
                                {
                                    if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Primary Applicant' && event.getSource().get('v.name')== component.get("v.RunwalHomeWrapList")[i].BookingId)
                                    {
                                    	//console.log('**'+component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].firstName);
                                        component.set("v.ncfData",component.get("v.RunwalHomeWrapList")[i].ncfdata);
                                        
                                       /* ncfotherdetails['nomineename'] = component.get("v.RunwalHomeWrapList")[i].nomineename;
                                        ncfotherdetails['nomineepan'] = component.get("v.RunwalHomeWrapList")[i].nomineepan;
                                        ncfotherdetails['poaname'] = component.get("v.RunwalHomeWrapList")[i].poaname;
                                        ncfotherdetails['poapan'] = component.get("v.RunwalHomeWrapList")[i].poapan;
                                        ncfotherdetails['poamobile'] = component.get("v.RunwalHomeWrapList")[i].poamobile;
                                        ncfotherdetails['poaemail'] = component.get("v.RunwalHomeWrapList")[i].poaemail;*/
                                    }
                                    
                                    else if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber != 'Primary Applicant' && event.getSource().get('v.name')== component.get("v.RunwalHomeWrapList")[i].BookingId)
                                    {
                                        ncfotherapplicantdetails[component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber] = component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j];
                                    }
                                }
                            }
                        }
        
        var action = component.get("c.createNCFRecord");  
        action.setParams({     
            "NCFDetails":  component.get("v.ncfData") ,
            "NCFOtherApplicantDetails":ncfotherapplicantdetails,
            "RemovedAppIds" : component.get('v.removedAppIds'),
            "BookingRecordId" :event.getSource().get('v.name')
            
        });  
        
         action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "SUCCESS!",
                    "type":"success",
                    "message": "NCF Form is submitted successfully."});
                toastEvent.fire();
                
                var result = response.getReturnValue(); 
                
                var action1 = component.get("c.getPortalHomeData");
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
                        var jsonobject = {
            			state: {  
                                    bookingdetails: component.get('v.RunwalHomeWrapList')
                                } 
                         };
        			sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
                        component.set("v.Spinner",false);
					}
                });
        		$A.enqueueAction(action1); 
                
            }
             else
             {
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type":"error",
                    "message": "There was an error submitting NCF Form. Please try later."});
                toastEvent.fire();
                 component.set("v.Spinner",false);
             }
         });
        
         $A.enqueueAction(action); 
        }
    },
    
    onRemoveApplicant: function( component, event, helper ) 
    {
        
        var applicantNumber = event.getSource().get('v.name').split("|")[1];
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].BookingId ==  event.getSource().get('v.name').split("|")[0])
                            {
                            if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length >0)
                            {
                                for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length;j++)
                                {
                                    if(event.getSource().get('v.name').split("|")[1] == component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber )
                                    {
                                       
                                        if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].applicantId !='' && component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].applicantId != undefined)
                                        component.get('v.removedAppIds').push(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].applicantId); 
                                          
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.splice(j, 1);
                                        console.log(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length);
                                    }
                                }
                            }
                            }
            
           
    }
        
        
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].BookingId ==  event.getSource().get('v.name').split("|")[0])
                            {
                            if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length >0)
                            {
                                for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length;j++)
                                {
                                    if(applicantNumber == 'Second Applicant')
                                    {
                                      if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Third Applicant' ) 
                                      {
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber ='Second Applicant';  
                                      }
                                        
                                      if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Fourth Applicant' ) 
                                      {
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber ='Third Applicant' ;  
                                      }
                                        
                                       if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Fifth Applicant' ) 
                                      {
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber = 'Fourth Applicant';  
                                      }
                                    }
                                    
                                    if(applicantNumber == 'Third Applicant')
                                    {
                                      
                                        
                                      if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Fourth Applicant' ) 
                                      {
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber ='Third Applicant' ;  
                                      }
                                        
                                       if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Fifth Applicant' ) 
                                      {
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber = 'Fourth Applicant' ;  
                                      }
                                    }
                                    
                                     if(applicantNumber == 'Fourth Applicant')
                                    {
                                        
                                       if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber == 'Fifth Applicant' ) 
                                      {
                                        component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList[j].appNumber ='Fourth Applicant' ;  
                                      }
                                    }
                                    
                                    
                                }
                            }
                            }
                        }
        
        console.log('**'+component.set("v.RunwalHomeWrapList",component.get("v.RunwalHomeWrapList")));
        //$A.get('e.force:refreshView').fire();
    },
    
    onAddApplicant: function( component, event, helper )
    {
        
         component.set("v.Spinner",true);
         var newapplicantdetails;
         for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].BookingId ==  event.getSource().get('v.name').split("|")[0])
                            {
                                if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length == '1')
                                {
                                    //applicantdetails['appNumber'] = 'Fourth Applicant';
                                    newapplicantdetails ={'appNumber':'Second Applicant','bookingId':event.getSource().get('v.name').split("|")[0],'opportunityId':event.getSource().get('v.name').split("|")[1]};
                                    component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.push(newapplicantdetails);
                                    console.log(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList);
                                    
                                }
                                
                                else if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length == '2')
                                {
                                    //applicantdetails['appNumber'] = 'Fourth Applicant';
                                    newapplicantdetails ={'appNumber':'Third Applicant','bookingId':event.getSource().get('v.name').split("|")[0],'opportunityId':event.getSource().get('v.name').split("|")[1]};
                                    component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.push(newapplicantdetails);
                                    console.log(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList);
                                }
                                
                                else if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length == '3')
                                {
                                    //applicantdetails['appNumber'] = 'Fourth Applicant';
                                    newapplicantdetails ={'appNumber':'Fourth Applicant','bookingId':event.getSource().get('v.name').split("|")[0],'opportunityId':event.getSource().get('v.name').split("|")[1]};
                                    component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.push(newapplicantdetails);
                                    console.log(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList);
                                }
                                
                                else if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length == '4')
                                {
                                    //applicantdetails['appNumber'] = 'Fourth Applicant';
                                    newapplicantdetails ={'appNumber':'Fifth Applicant','bookingId':event.getSource().get('v.name').split("|")[0],'opportunityId':event.getSource().get('v.name').split("|")[1]};
                                    component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.push(newapplicantdetails);
                                    console.log(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList);
                                }
                                
                                else if(component.get("v.RunwalHomeWrapList")[i].appDetailsWrapperList.length >= '5')
                                {
                                    var toastEvent = $A.get("e.force:showToast");
                                                                         toastEvent.setParams({
                                                                             "title": "ERROR!",
                                                                             "type":"error",
                                                                             "message": "Only Five applicants can be added."
                                                                         });
                                                                         toastEvent.fire();
                                }
                                
                            }
                        }
        
        console.log('**'+component.set("v.RunwalHomeWrapList",component.get("v.RunwalHomeWrapList")));
        component.find("accordion").set('v.activeSectionName', newapplicantdetails.appNumber);
        component.set("v.Spinner",false);
        //var target = component.find(newapplicantdetails.appNumber);
        //document.getElementById(newapplicantdetails.appNumber).scrollIntoView({
          //behavior: 'smooth'
        //});
        //var element = target.getElement();
        //var rect = element.getBoundingClientRect();
        //scrollTo({top: rect.top, behavior: "smooth"});
   //window.scrollTo(newapplicantdetails.appNumber,document.body.scrollHeight);
        //window.scrollTo(0,document.body.scrollHeight);
        
    },
    
    validatePAN: function(component,event,helper)
    {
        event.getSource().set("v.value",event.getSource().get("v.value").toUpperCase());
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        var returnValue = helper.validatePANNumber(component,event);
        if(returnValue == true)
        {
            inputCmp.setCustomValidity("");
             //component.set('v.errorMessage',"");
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid PAN Number");
            /*if(event.getSource().getLocalId() =='nomineepannumber')
            component.set('v.errorMessage',"Please enter Valid PAN Number for Nominee");*/
        }
        
        inputCmp.reportValidity();
    },
    
    onCancel:function(component,event,helper)
    {
    component.set("v.Spinner",true);
    var action1 = component.get("c.getPortalHomeData");
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
                        var jsonobject = {
            			state: {  
                                    bookingdetails: component.get('v.RunwalHomeWrapList')
                                } 
                         };
        			sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
                        component.set("v.Spinner",false);
					}
                    else
                    {
                        component.set("v.Spinner",false);
                    }
                });
        		$A.enqueueAction(action1); 

		}
    
})