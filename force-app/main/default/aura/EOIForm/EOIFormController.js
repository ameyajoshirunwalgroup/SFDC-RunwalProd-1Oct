({
    doInit: function(cmp,event,helper) 
    {//debugger;
        cmp.set("v.Spinner",true);
        var dataEnc;
        console.log('--doInit--');
        if(cmp.get("v.data") != null && cmp.get("v.data") != undefined && cmp.get("v.data") !='')
        {
            console.log('--doInit1--');
            var action1 = cmp.get("c.getDecryptedData");
            /* if(/\s/.test(cmp.get("v.data")))
        {
			dataEnc = cmp.get("v.data").replace(/\s/,'%2B');            
        }
        else
        {
            dataEnc = cmp.get("v.data");  
        }*/
            var data = cmp.get("v.data");
            data = data.split(" ").join('+');
            
            action1.setParams({ data :decodeURIComponent(data)});
            //debugger;
            console.log('--action1--');
            action1.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    console.log('--action1--');
                    var responseValues = response.getReturnValue().toString().split(',');
                    cmp.set("v.opportunityId", responseValues[0]);
                    cmp.set("v.eoiId", responseValues[1]);
                    cmp.set("v.eoilinkrecordid" , responseValues[2]);
                    cmp.set("v.PaymentDetailsWrap.RWPaymentAmount", responseValues[3]);
                    cmp.set("v.digitalPaymentAmount",responseValues[3]);
                    cmp.set("v.towerId",responseValues[4]);
                    if(responseValues[5] != '' && responseValues[5] != undefined && responseValues[5] != null)
                    {
                        cmp.set("v.applicableOfferId",responseValues[5])
                    }
                    cmp.set("v.PaymentGateway", responseValues[6]);
                    
                    
                    var action2 = cmp.get("c.checkLinkExpiry");
                    action2.setParams({ eoiLinkRecordId :cmp.get("v.eoilinkrecordid") });
                    console.log('--action2--');
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") 
                        {
                            console.log('--action2 Success--');
                            if(response.getReturnValue()=="Expired")
                            {
                                cmp.set("v.isLinkExpired", true);
                                cmp.set("v.Spinner",false);
                            }   
                            else
                            {
                                
                                var communityURLAction = cmp.get("c.getCommunityDigitalEOIFormURL");
                                communityURLAction.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") 
                                    {
                                        cmp.set("v.communityURL",response.getReturnValue());
                                    }
                                });
                                
                                
                                var action3 = cmp.get("c.loadEOIdata");
                                action3.setParams({ eoiRecordId :cmp.get("v.eoiId") });
                                console.log('--action3--');
                                action3.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") 
                                    {
                                        console.log('--action3 success--');
                                        /* if(response.getReturnValue().RWCountryPhoneCode == null || response.getReturnValue().RWCountryPhoneCode == undefined || response.getReturnValue().RWCountryPhoneCode =='')
                                    {
                                        response.getReturnValue().RWCountryPhoneCode ='+91';
                                    }*/
                                    
                                    if(response.getReturnValue().RWNationality == null || response.getReturnValue().RWNationality == undefined || response.getReturnValue().RWNationality =='')
                                    {
                                        response.getReturnValue().RWNationality ='India';
                                    }
                                    cmp.set("v.EOIWrap", response.getReturnValue());
                                    if(cmp.get("v.EOIWrap.paymentGatewayAvailable"))	
                                    {	
                                        cmp.find('RWModeOfPayment').set("v.value",'Digital');	
                                    }
                                }
                                else
                                {
                                    cmp.set("v.hasError",true);
                                    cmp.set("v.errorMessage",response.getError()[0].message);
                                    cmp.set("v.Spinner",false);
                                    return;
                                }
                                
                            });
                            
                            var action4 = cmp.get("c.retreiveProjectName");
                            action4.setParams({ opportunityId : cmp.get("v.opportunityId") });
                            console.log('--action4--');
                            action4.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    
                                    
                                    cmp.set("v.ProjectName", response.getReturnValue());
                                    if(cmp.get("v.ProjectName") != undefined && cmp.get("v.EOIWrap.RWTowerName") != undefined )
                                    {
                                        
                                        /*if(cmp.get("v.ProjectName") == 'Runwal Forests'){ //Added by coServe 09-10-2024
                                            console.log('--ProjectName1--: ', cmp.get("v.ProjectName"));
                                            helper.getTCforRunwalMahalakshmi(cmp,event); 
                                        }*/
                                        var PreferredResAction = cmp.get("c.getPreferredResidence");
                                        PreferredResAction.setParams({ projectName : cmp.get("v.ProjectName") , TowerName :cmp.get("v.EOIWrap.RWTowerName") });
                                        
                                        PreferredResAction.setCallback(this, function(response) {
                                            var state = response.getState();
                                            if (state === "SUCCESS") 
                                            {
                                                var responsevalues = response.getReturnValue();
                                                if(responsevalues.PreferredUnits)
                                                {
                                                    cmp.set("v.unitTypes",responsevalues.PreferredUnits);
                                                }
                                                
                                                if(responsevalues.PreferredBudget)
                                                {
                                                    cmp.set("v.budgetTypes",responsevalues.PreferredBudget);
                                                }
                                                
                                                if(responsevalues.PreferredFloors)
                                                {
                                                    cmp.set("v.floorTypes",responsevalues.PreferredFloors);
                                                }
                                                
                                                if(responsevalues.PreferredSizes){ //Added by coServe 09-10-2024
                                                    cmp.set("v.sizes",responsevalues.PreferredSizes);
                                                }
                                                if(responsevalues.PreferredEoiAmounts){ //Added by coServe 09-10-2024
                                                    cmp.set("v.eoiAmounts",responsevalues.PreferredEoiAmounts);
                                                }
                                                if(responsevalues.ApplicationSources){ //Added by coServe 09-10-2024
                                                    cmp.set("v.applicationSources",responsevalues.ApplicationSources);
                                                }
                                                
                                                
                                            }
                                            else
                                            {
                                                cmp.set("v.hasError",true);
                                                cmp.set("v.errorMessage",response.getError()[0].message);
                                                cmp.set("v.Spinner",false);
                                            }
                                            
                                        });
                                        
                                        
                                        /*var action5 = cmp.get("c.getUnitType");
                                    action5.setParams({ projectName : cmp.get("v.ProjectName") , TowerName :cmp.get("v.EOIWrap.RWTowerName") });
                                    
                                    action5.setCallback(this, function(response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            
                                            cmp.set("v.unitTypes", response.getReturnValue());
                                            
                                        }
											else
										{
											 cmp.set("v.hasError",true);
											 cmp.set("v.errorMessage",response.getError()[0].message);
											 cmp.set("v.Spinner",false);
										}
                                        
                                    });
                                    
                                    var action6 = cmp.get("c.getBudget");
                                    action6.setParams({ projectName : cmp.get("v.ProjectName")  , TowerName :cmp.get("v.EOIWrap.RWTowerName") });
                                    
                                    action6.setCallback(this, function(response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            
                                            cmp.set("v.budgetTypes", response.getReturnValue());
                                            
                                        }
										else
									{
										 cmp.set("v.hasError",true);
										 cmp.set("v.errorMessage",response.getError()[0].message);
										 cmp.set("v.Spinner",false);
									}
                                        
                                    });
                                    */
                                    }
                                    
                                    else
                                    {
                                        cmp.set("v.hasError",true);
                                        cmp.set("v.errorMessage",'No Data found for Project/Tower');
                                        cmp.set("v.Spinner",false);
                                    }
                                    
                                    //----------
                                    
                                    
                                    if(cmp.get("v.encResp") != undefined && cmp.get("v.encResp") !=null)
                                    {
                                        
                                        cmp.set("v.accessCode",  cmp.get("v.EOIWrap").gateway.Access_Code__c);	
                                        var ccAvenue = cmp.get("c.getPaymentResponseDecryptedData");	
                                        var encryptedResponse = cmp.get("v.encResp");	
                                        ccAvenue.setParams({ inputdata :encryptedResponse,decryptionKey : cmp.get("v.EOIWrap").gateway.Encryption_Key__c}); 
                                        
                                        ccAvenue.setCallback(this, function(response) 
                                                             {
                                                                 var state = response.getState();
                                                                 if (state === "SUCCESS") 
                                                                 {
                                                                     /*var action1 = cmp.get("c.getDecryptedData");
                                         action1.setParams({ data :decodeURIComponent(cmp.get("v.data")) });
                                         
                                         action1.setCallback(this, function(decryptedresponse) {
                                             var state = decryptedresponse.getState();
                                             if (state === "SUCCESS") {
                                                 
                                                 var responseValues = decryptedresponse.getReturnValue().toString().split(',');
                                                 cmp.set("v.opportunityId", responseValues[0]);
                                                   cmp.set("v.eoiId", responseValues[1]);
                                                 
                                                 console.log('*response data*'+response.getReturnValue())
                                                 */
                                         var responsevalues = response.getReturnValue().toString().split('&');
                                         var responseArray={};
                                         for(var j=0;j<responsevalues.length;j++)
                                         {
                                             
                                             responseArray[responsevalues[j].split('=')[0]]=responsevalues[j].split('=')[1];
                                             
                                         }
                                         console.log('*ENTERED here*');
                                         if(responseArray['order_status'] == 'Success')
                                         {
                                             cmp.set("v.isPaymentSuccess",responseArray['order_status']);
                                             var action2 = cmp.get("c.getPaymentDetailsOfOpportunity"); 
                                             action2.setParams({ "oppRecordId" :cmp.get('v.opportunityId'),"TransactionId":responseArray['tracking_id'] });
                                             console.log('*ENTERED here 2*');
                                             action2.setCallback(this, function(paymentRecordResponse) {
                                                 
                                                 var state = paymentRecordResponse.getState();
                                                 if (state === "SUCCESS") 
                                                 {
                                                     if(paymentRecordResponse.getReturnValue() != null && paymentRecordResponse.getReturnValue().length >0)
                                                     {
                                                         
                                                     }
                                                     else
                                                     {
                                                         console.log('*ENTERED here 1*'+responseArray['order_status']);
                                                         var paymentdetails ={};
                                                         paymentdetails['bankReferenceNumber'] = responseArray['bank_ref_no'];
                                                         paymentdetails['paymentTrackingId'] = responseArray['tracking_id'];
                                                         paymentdetails['paymentMode'] = responseArray['payment_mode'];
                                                         paymentdetails['paymentAmount'] = responseArray['amount'];
                                                         paymentdetails['paymentDate'] = responseArray['trans_date'];
                                                         paymentdetails['oppRecId'] = cmp.get('v.opportunityId');
                                                         paymentdetails['eoiRecId'] = cmp.get('v.eoiId');
                                                         paymentdetails['digitalLinkId'] = cmp.get('v.eoilinkrecordid');
                                                         var action = cmp.get("c.insertPaymentDetails"); 
                                                         action.setParams({ "details" :paymentdetails });
                                                         console.log('*ENTERED here 2*');
                                                         action.setCallback(this, function(response) {
                                                             var state = response.getState();
                                                             if (state === "SUCCESS") 
                                                             {
                                                                 console.log('*ENTERED here 3*');
                                                                 
                                                                 cmp.set("v.Spinner",false);
                                                                 /* var toastEvent = $A.get("e.force:showToast");
                                                                         toastEvent.setParams({
                                                                             "title": "SUCCESS!",
                                                                             "type":"success",
                                                                             "message": "Your EOI submission and Payment are successfull"
                                                                         });
                                                                         toastEvent.fire();*/
                                                                     }
                                                                     else
                                                                     {
                                                                         cmp.set("v.hasError",true);
                                                                         cmp.set("v.errorMessage",response.getError()[0].message);
                                                                         cmp.set("v.Spinner",false);
                                                                     }
                                                                     
                                                                 });
                                                                 $A.enqueueAction(action);
                                                             }
                                                         }
                                                         else
                                                         {
                                                             cmp.set("v.hasError",true);
                                                             cmp.set("v.errorMessage",paymentRecordResponse.getError()[0].message);
                                                             cmp.set("v.Spinner",false);
                                                         }
                                                         
                                                     });
                                                     $A.enqueueAction(action2);      
                                                     
                                                     
                                                     
                                                     //console.log('*response tracking id*'+response.getReturnValue().tracking_id)
                                                 }
                                         else if(responseArray['order_status'] == 'Failure')
                                         {
                                             var paymentFailure = cmp.get("c.notifyPaymentFailure"); 
                                             paymentFailure.setParams({ "eoiRecordId" :cmp.get('v.eoiId'),"TrackingId":responseArray['tracking_id'],"failureReason":responseArray['failure_message'] });
                                             console.log('*ENTERED here 2*');
                                             paymentFailure.setCallback(this, function(Response) {
                                                 
                                                 var state = Response.getState();
                                                 if (state === "SUCCESS") 
                                                 {
                                                     cmp.set("v.isPaymentFailure",responseArray['order_status']);
                                                 }
                                             });
                                             $A.enqueueAction(paymentFailure);     
                                         }
                                         
                                         
                                         //}
                                         /* else
													{
														 cmp.set("v.hasError",true);
														 cmp.set("v.errorMessage",decryptedresponse.getError()[0].message);
														 cmp.set("v.Spinner",false);
													}
                                         });
                                         $A.enqueueAction(action1);
                                         */
                                     }
                                     else
                                     {
                                         cmp.set("v.hasError",true);
                                         cmp.set("v.errorMessage",response.getError()[0].message);
                                         cmp.set("v.Spinner",false);
                                     }
                                 });
            
            $A.enqueueAction(ccAvenue);
            
            
        }	
                                    /* bkk */
                                    if(cmp.get("v.msg") != undefined && cmp.get("v.msg") != null){
                                        var action = cmp.get("c.saveBillDeskResp"); 
                                        
                                        action.setParams({ "msg": decodeURIComponent(cmp.get("v.msg")), "digitalLinkId" : cmp.get("v.eoilinkrecordid"), "eoiRecId" : cmp.get('v.eoiId'), "towerId" : cmp.get("v.towerId")});  
                                        
                                        action.setCallback(this, function(response) {
                                            var state = response.getState();
                                            if (state === "SUCCESS") 
                                            {                       
                                                if(response.getReturnValue() == "Success")
                                                {
                                                    cmp.set("v.isPaymentSuccess",response.getReturnValue());
                                                }   
                                                else
                                                {
                                                    cmp.set("v.isPaymentFailure",response.getReturnValue());
                                                }
                                                cmp.set("v.Spinner",false);
                                            }
                                            else
                                            {
                                                cmp.set("v.hasError",true);
                                                cmp.set("v.errorMessage",response.getError()[0].message);
                                                cmp.set("v.Spinner",false);
                                            }
                                        });
                                        $A.enqueueAction(action); 
                                        
                                    } 
                                    /* bkk */
                                    
                                    //----------
                                    //$A.enqueueAction(action5);
                                    //$A.enqueueAction(action6);
                                    $A.enqueueAction(PreferredResAction);
                                    
                                    
                                }
                                
                            });
                            
                            
                            
                            var action7 = cmp.get("c.retreiveStatesList");
                            action7.setParams({ ObjectApiName : 'RW_EOI__c' , FieldName :'RW_State__c' });
                            
                            action7.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    
                                    cmp.set("v.state", response.getReturnValue());
                                    
                                }
                                else
                                {
                                    cmp.set("v.hasError",true);
                                    cmp.set("v.errorMessage",response.getError()[0].message);
                                    cmp.set("v.Spinner",false);
                                }
                                
                            });                            
                            
                            var action8 = cmp.get("c.retreiveCountryList");
                            action8.setParams({ ObjectApiName : 'RW_EOI__c' , FieldName :'RW_Countries__c' });
                            
                            action8.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    if(cmp.get("v.encResp") == undefined || cmp.get("v.encResp") ==null || cmp.get("v.encResp") =='')
                                    {
                                        cmp.set("v.country", response.getReturnValue());
                                        cmp.set("v.mailingcountry", response.getReturnValue());
                                        if(cmp.get("v.EOIWrap.RWCountry") != null && cmp.get("v.EOIWrap.RWCountry") != undefined && cmp.get("v.EOIWrap.RWCountry") !='')
                                        {
                                            var countryaction = cmp.get("c.getDependentStatePicklists");
                                            countryaction.setParams({ "objectName" : 'RW_EOI__c' ,"CountryFieldName":'RW_Countries__c', "CountryFieldValue" :cmp.get("v.EOIWrap.RWCountry") , "StateField":'RW_State__c' });
                                            countryaction.setCallback(this, function(response) 
                                                                      {
                                                                          var state = response.getState();
                                                                          if (state === "SUCCESS") 
                                                                          {
                                                                              var responsevalues = response.getReturnValue();
                                                                              
                                                                              cmp.set("v.state",responsevalues);
                                                                              
                                                                              //component.find("RWState").set("v.value","");
                                                                              if(responsevalues.length >0)
                                                                              {
                                                                                  cmp.set("v.hasState",true);
                                                                                  cmp.find("RWState").set("v.disabled",false); 
                                                                                  cmp.find("RWState").set("v.required",true);
                                                                              }
                                                                              else
                                                                              {
                                                                                  cmp.find("RWState").set("v.disabled",true);
                                                                                  cmp.find("RWState").set("v.required",false);
                                                                                  cmp.find("RWCity").set("v.disabled",true);
                                                                                  cmp.find("RWCity").set("v.required",false);
                                                                                  cmp.set("v.hasState",false);
                                                                                  cmp.set("v.hasCity",false);
                                                                              }
                                                                              
                                                                          }
                                                                      });
                                            
                                            $A.enqueueAction(countryaction);
                                            
                                            if(cmp.get("v.EOIWrap.RWState") != null && cmp.get("v.EOIWrap.RWState") != undefined && cmp.get("v.EOIWrap.RWState") !='')
                                            {
                                                var stateaction = cmp.get("c.getDependentCityPicklists");
                                                stateaction.setParams({ "objectName" : 'RW_EOI__c' ,"StateFieldName":'RW_State__c', "StateFieldValue" :cmp.get("v.EOIWrap.RWState") , "CityField":'RW_City__c' });
                                                stateaction.setCallback(this, function(response) 
                                                                        {
                                                                            var state = response.getState();
                                                                            if (state === "SUCCESS") 
                                                                            {
                                                                                var responsevalues = response.getReturnValue();
                                                                                
                                                                                cmp.set("v.cityPicklistOptions",responsevalues);
                                                                                if(responsevalues.length >0)
                                                                                {
                                                                                    cmp.set("v.hasCity",true);
                                                                                    cmp.find("RWCity").set("v.disabled",false);
                                                                                    cmp.find("RWCity").set("v.required",true);
                                                                                }
                                                                                
                                                                            }
                                                                        });
                                                
                                                $A.enqueueAction(stateaction);
                                            }
                                            
                                        }
                                        
                                        else
                                        {
                                            cmp.find("RWState").set("v.disabled",true);
                                            cmp.find("RWState").set("v.required",false);
                                            cmp.find("RWCity").set("v.disabled",true);
                                            cmp.find("RWCity").set("v.required",false);
                                            cmp.set("v.hasState",false);
                                            cmp.set("v.hasCity",false);
                                        }
                                        
                                        
                                        
                                        if(cmp.get("v.EOIWrap.RWMailingCountry") != null && cmp.get("v.EOIWrap.RWMailingCountry") != undefined && cmp.get("v.EOIWrap.RWMailingCountry") !='')
                                        {
                                            var mailcountryaction = cmp.get("c.getDependentStatePicklists");
                                            mailcountryaction.setParams({ "objectName" : 'RW_EOI__c' ,"CountryFieldName":'RW_Mailing_Country__c', "CountryFieldValue" :cmp.get("v.EOIWrap.RWMailingCountry") , "StateField":'RW_Mailing_State__c' });
                                            mailcountryaction.setCallback(this, function(response) 
                                                                          {
                                                                              var state = response.getState();
                                                                              if (state === "SUCCESS") 
                                                                              {
                                                                                  var responsevalues = response.getReturnValue();
                                                                                  
                                                                                  cmp.set("v.mailingstate",responsevalues);
                                                                                  
                                                                                  //component.find("RWState").set("v.value","");
                                                                                  if(responsevalues.length >0)
                                                                                  {
                                                                                      cmp.set("v.hasmailingState",true);
                                                                                      cmp.find("RWMailingState").set("v.disabled",false); 
                                                                                      cmp.find("RWMailingState").set("v.required",true);
                                                                                  }
                                                                                  else
                                                                                  {
                                                                                      cmp.find("RWMailingState").set("v.disabled",true);
                                                                                      cmp.find("RWMailingState").set("v.required",false);
                                                                                      cmp.find("RWMailingCity").set("v.disabled",true);
                                                                                      cmp.find("RWMailingCity").set("v.required",false);
                                                                                      cmp.set("v.hasmailingState",false);
                                                                                      cmp.set("v.hasmailingCity",false);
                                                                                  }
                                                                                  
                                                                              }
                                                                          });
                                            
                                            $A.enqueueAction(mailcountryaction);
                                            if(cmp.get("v.EOIWrap.RWMailingState") != null && cmp.get("v.EOIWrap.RWMailingState") != undefined && cmp.get("v.EOIWrap.RWMailingState") !='')
                                            {
                                                var mailstateaction = cmp.get("c.getDependentCityPicklists");
                                                mailstateaction.setParams({ "objectName" : 'RW_EOI__c' ,"StateFieldName":'RW_Mailing_State__c', "StateFieldValue" :cmp.get("v.EOIWrap.RWMailingState") , "CityField":'RW_Mailing_City__c' });
                                                mailstateaction.setCallback(this, function(response) 
                                                                            {
                                                                                var state = response.getState();
                                                                                if (state === "SUCCESS") 
                                                                                {
                                                                                    var responsevalues = response.getReturnValue();
                                                                                    
                                                                                    cmp.set("v.mailingcityPicklistOptions",responsevalues);
                                                                                    if(responsevalues.length >0)
                                                                                    {
                                                                                        cmp.set("v.hasmailingCity",true);
                                                                                        cmp.find("RWMailingCity").set("v.disabled",false);
                                                                                        cmp.find("RWMailingCity").set("v.required",true);
                                                                                    }
                                                                                    
                                                                                }
                                                                            });
                                                
                                                $A.enqueueAction(mailstateaction);
                                            }
                                        }
                                        
                                        else
                                        {
                                            cmp.find("RWMailingState").set("v.disabled",true);
                                            cmp.find("RWMailingState").set("v.required",false);
                                            cmp.find("RWMailingCity").set("v.disabled",true);
                                            cmp.find("RWMailingCity").set("v.required",false);
                                            cmp.set("v.hasmailingState",false);
                                            cmp.set("v.hasmailingCity",false);
                                        }
                                        
                                    }
                                    
                                }
                                else
                                {
                                    cmp.set("v.hasError",true);
                                    cmp.set("v.errorMessage",response.getError()[0].message);
                                    cmp.set("v.Spinner",false);
                                }
                                
                            }); 
                            
                            var action9 = cmp.get("c.getLoggedInProfileName");
                            
                            action9.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    
                                    cmp.set("v.LoggedInProfileName", response.getReturnValue());
                                    
                                }
                                else
                                {
                                    cmp.set("v.hasError",true);
                                    cmp.set("v.errorMessage",response.getError()[0].message);
                                    cmp.set("v.Spinner",false);
                                }
                                
                            });
                            
                            var action10 = cmp.get("c.getEOIApplicableOffers");
                            action10.setParams({ recordId : cmp.get("v.eoiId"),applicableOfferId : cmp.get("v.applicableOfferId") });
                            
                            action10.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    
                                    cmp.set("v.OfferRecords", response.getReturnValue());
                                    
                                }
                                else
                                {
                                    cmp.set("v.hasError",true);
                                    cmp.set("v.errorMessage",response.getError()[0].message);
                                    cmp.set("v.Spinner",false);
                                }
                                
                            });
                            
                            
                            /*		var action11 = cmp.get("c.retreiveCountryPhoneCode");
                            action11.setParams({ ObjectApiName : 'RW_EOI__c' , FieldName :'RW_Country_Phone_Code__c' });
                            
                            action11.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    
                                    cmp.set("v.CountryPhoneCode", response.getReturnValue());
                                    if(cmp.get("v.EOIWrap.RWPrimaryContactNo") != null && cmp.get("v.EOIWrap.RWPrimaryContactNo") != undefined && cmp.get("v.EOIWrap.RWPrimaryContactNo") !='')
                                    {
                                        for(var i=0; i<cmp.get("v.CountryPhoneCode").length;i++)
                                        {
                                            if(cmp.get("v.EOIWrap.RWPrimaryContactNo").startsWith(cmp.get("v.CountryPhoneCode")[i],0))
                                            {
                                                cmp.set("v.EOIWrap.RWPrimaryContactNo",cmp.get("v.EOIWrap.RWPrimaryContactNo").replace(cmp.get("v.CountryPhoneCode")[i],''));
                                            }
                                        }
                                    }
                                }
								else
									{
										 cmp.set("v.hasError",true);
										 cmp.set("v.errorMessage",response.getError()[0].message);
										 cmp.set("v.Spinner",false);
									}
                                
                            }); 
                                    */
                            var fieldNames = ["RW_Gender__c","RW_Nationality__c","RW_Occupation__c" ,"RW_Marital_Status__c","RW_Designation__c"];
                            var action12 = cmp.get("c.getPicklistValuesForFields");
                            action12.setParams({ "objectName" : 'RW_EOI__c' , fieldNames :fieldNames });
                            action12.setCallback(this, function(response) 
                                                 {
                                                     var state = response.getState();
                                                     if (state === "SUCCESS") 
                                                     {
                                                         var responsevalues = response.getReturnValue();
                                                         if(responsevalues.RW_Nationality__c)
                                                         {
                                                             cmp.set("v.NationalityPicklistOptions",responsevalues.RW_Nationality__c);
                                                         }
                                                         
                                                         if(responsevalues.RW_Occupation__c)
                                                         {
                                                             cmp.set("v.OccupationPicklistOptions",responsevalues.RW_Occupation__c);
                                                         }
                                                         
                                                         if(responsevalues.RW_Marital_Status__c)
                                                         {
                                                             cmp.set("v.MaritalStatusPicklistOptions",responsevalues.RW_Marital_Status__c);
                                                         }
                                                         
                                                         if(responsevalues.RW_Designation__c)
                                                         {
                                                             cmp.set("v.DesignationPicklistOptions",responsevalues.RW_Designation__c);
                                                         }
                                                         
                                                         if(responsevalues.RW_Gender__c)
                                                         {
                                                             cmp.set("v.GenderPicklistOptions",responsevalues.RW_Gender__c);
                                                         }
                                                         if(responsevalues.RW_City__c)
                                                         {
                                                             //cmp.set("v.cityPicklistOptions",responsevalues.RW_City__c);
                                                         }
                                                         if(responsevalues.RW_Mailing_CIty__c)
                                                         {
                                                             cmp.set("v.mailingcityPicklistOptions",responsevalues.RW_Mailing_CIty__c);
                                                         }
                                                     }
                                                     else
                                                     {
                                                         cmp.set("v.hasError",true);
                                                         cmp.set("v.errorMessage",response.getError()[0].message);
                                                         cmp.set("v.Spinner",false);
                                                     }
                                                 });
                            
                            
                            var receiptfieldNames = ["Mode__c","DraweeBank__c"];
                            var action13 = cmp.get("c.getPicklistValuesForFields");
                            action13.setParams({ "objectName" : 'Receipt__c' , fieldNames :receiptfieldNames });
                            action13.setCallback(this, function(response) 
                                                 {
                                                     var state = response.getState();
                                                     if (state === "SUCCESS") 
                                                     {
                                                         var responsevalues = response.getReturnValue();
                                                         if(responsevalues.Mode__c)
                                                         {
                                                             cmp.set("v.PaymentModePicklistOptions",responsevalues.Mode__c);
                                                         }
                                                         
                                                         if(responsevalues.DraweeBank__c)
                                                         {
                                                             cmp.set("v.PaymentBankPicklistOptions",responsevalues.DraweeBank__c);
                                                         }
                                                         
                                                         if(cmp.get("v.msg") == undefined || cmp.get("v.msg") == null){cmp.set("v.Spinner",false); } /* bkk */
                                                     }
                                                     else
                                                     {
                                                         cmp.set("v.hasError",true);
                                                         cmp.set("v.errorMessage",response.getError()[0].message);
                                                         cmp.set("v.Spinner",false);
                                                     }
                                                 });
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            $A.enqueueAction(communityURLAction);
                            $A.enqueueAction(action3);
                            $A.enqueueAction(action4);
                            
                            $A.enqueueAction(action7);
                            $A.enqueueAction(action8);
                            $A.enqueueAction(action9);
                            $A.enqueueAction(action10);
                            //$A.enqueueAction(action11);
                            $A.enqueueAction(action12); 
                            $A.enqueueAction(action13); 
                            
                            
                            
                            
                            
                            
                            
                        }
                    }
                    else
                    {
                        cmp.set("v.hasError",true);
                        cmp.set("v.errorMessage",response.getError()[0].message);
                        cmp.set("v.Spinner",false);
                    }
                    
                });
                
                $A.enqueueAction(action2);
                
                
                
                
            }
            
            else
            {
                cmp.set("v.hasError",true);
                cmp.set("v.errorMessage",response.getError()[0].message);
                cmp.set("v.Spinner",false);
            }
            
        });
            
            $A.enqueueAction(action1);
            
        }
        
        else
        {
            cmp.set("v.hasError",true);
            cmp.set("v.errorMessage",'No Data found to load the page');
            cmp.set("v.Spinner",false);
        }
        
    },
    
    validatePIN: function(component,event,helper)
    {
        //var inputCmp = component.find("RWPin");
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        var returnValue = helper.validatePinCode(component,event);
        if(returnValue == true)
        {
            inputCmp.setCustomValidity("");
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid Pin");
        }
        
        inputCmp.reportValidity();
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
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid PAN Number");
        }
        
        inputCmp.reportValidity();
    },
    
    validateAadhar: function(component,event,helper)
    {
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        var returnValue = helper.validateAadharNumber(component,event);
        if(returnValue == true)
        {
            inputCmp.setCustomValidity("");
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid Aadhar Number");
        }
        
        inputCmp.reportValidity();
    },
    
    validatePassport: function(component,event,helper)
    {
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        var returnValue = helper.validatePassportNumber(component,event);
        if(returnValue == true)
        {
            inputCmp.setCustomValidity("");
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid Passport Number");
        }
        
        inputCmp.reportValidity();
    },
    
    setRWPreferredUnitType : function(component,event,helper)
    {
        if(event.getSource().get("v.checked"))
        {
            component.set("v.EOIWrap.RWPreferredUnitType",event.getSource().get("v.label"));
            var field = component.find('RWPreferredUnitType');
            for(var j=0;j<field.length;j++)
            {
                if(field[j].get("v.label") != event.getSource().get("v.label"))
                {
                    field[j].set("v.disabled", true); 
                }
            }
        }
        
        else
        {
            var field = component.find('RWPreferredUnitType');
            for(var j=0;j<field.length;j++)
            {
                field[j].set("v.disabled", false); 
                component.set("v.EOIWrap.RWPreferredUnitType","");
            }
        }
    },
    
    setRWPreferredBudget : function(component,event,helper)
    {
        if(event.getSource().get("v.checked"))
        {
            component.set("v.EOIWrap.RWPreferredBudget",event.getSource().get("v.label"));
            var field = component.find('RWPreferredBudget');
            for(var j=0;j<field.length;j++)
            {
                if(field[j].get("v.label") != event.getSource().get("v.label"))
                {
                    field[j].set("v.disabled", true); 
                }
            }
        }
        
        else
        {
            var field = component.find('RWPreferredBudget');
            for(var j=0;j<field.length;j++)
            {
                field[j].set("v.disabled", false); 
                component.set("v.EOIWrap.RWPreferredBudget","");
            }
        }
    },
    
    onMailAddrChange: function(component,event,helper)
    {
        if(!event.getSource().get("v.checked"))
        {
            /* component.set("v.EOIWrap.RWMailingAddressLine1",'');
            		component.set("v.EOIWrap.RWMailingAddressLine2",'');
            		component.set("v.EOIWrap.RWMailingAddressLine3",'');
                    
                        
                    component.set("v.EOIWrap.RWMailingCity",'');
            		component.set("v.EOIWrap.RWMailingPin",'');
            		component.set("v.EOIWrap.RWMailingCountry",'');    
                    component.set("v.EOIWrap.RWMailingState",'');
                    */
            component.set("v.EOIWrap.RWMailingAddressLine1",'');
            component.set("v.EOIWrap.RWMailingAddressLine2",'');
            component.set("v.EOIWrap.RWMailingAddressLine3",'');
            component.find("RWMailingCountry").set("v.value",'');
            component.find("RWMailingState").set("v.value",'');
            component.find("RWMailingCity").set("v.value",'');
            component.find("RWMailingState").set("v.disabled",true);
            component.find("RWMailingState").set("v.required",false);
            component.find("RWMailingCity").set("v.disabled",true);
            component.find("RWMailingCity").set("v.required",false);
            component.set("v.hasmailingState",false);
            component.set("v.hasmailingCity",false);
            component.set("v.EOIWrap.RWMailingPin",'');
            
        }
        
    },
    /*setRWPreferredFloors : function(component,event,helper)
    {
        if(event.getSource().get("v.checked"))
        {
            component.set("v.EOIWrap.RWPreferredFloors",event.getSource().get("v.label"));
            var field = component.find('RWPreferredFloors');
            for(var j=0;j<field.length;j++)
            {
                if(field[j].get("v.label") != event.getSource().get("v.label"))
                {
                    field[j].set("v.disabled", true); 
                }
            }
        }
        
        else
        {
            var field = component.find('RWPreferredFloors');
            for(var j=0;j<field.length;j++)
            {
                field[j].set("v.disabled", false); 
                component.set("v.EOIWrap.RWPreferredFloors","");
            }
        }
    },*/
    
    onformSubmit: function(cmp,event,helper) 
    {
        cmp.set("v.Spinner",true);
        var controlAuraIds = ["RWPin","RWPrimaryFirstName","RWDateOfBirth","RWSecondaryFirstName","RWSecondaryMiddleName","RWSecondaryLastName","RWPrimaryMiddleName","RWPrimaryLastName","RWPrimaryEmail","RWPrimaryContactNo","RWPrimaryAlternateContactNo","RWPrimaryAlternateEmail","RWSecondaryContactNo","RWSecondaryEmail","RWSecondaryPANDetails","RWSecondaryAlternateEmail","RWPermanentAddressLine1"];
        //reducer function iterates over the array and return false if any of the field is invalid otherwise true.
        var isAllValid = controlAuraIds.reduce(function(isValidSoFar, controlAuraId){
            //fetches the component details from the auraId
            var inputCmp = cmp.find(controlAuraId);
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
        
        if(isAllValid)
        {
            var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var dateValue = cmp.get("v.EOIWrap.RWDateOfBirth");
            
            
            //var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            var threemonth = new Date();
            threemonth.setMonth(threemonth.getMonth() - 3);
            threemonth = $A.localizationService.formatDate(threemonth, "YYYY-MM-DD");
            var chequedateValue = cmp.get("v.PaymentDetailsWrap.RWPaymentDate");
            //event.getSource().get("v.value");
            
            if(cmp.get("v.EOIWrap.RWCountry") == undefined || cmp.get("v.EOIWrap.RWCountry") == '' ||
               cmp.get("v.EOIWrap.RWOccupation") == undefined || cmp.get("v.EOIWrap.RWOccupation") == '' ||
               cmp.get("v.EOIWrap.RWNationality") == undefined || cmp.get("v.EOIWrap.RWNationality") == '' ||
               cmp.get("v.EOIWrap.RWGender") == undefined || cmp.get("v.EOIWrap.RWGender") == '' ||
               cmp.get("v.EOIWrap.RWMaritalStatus") == undefined || cmp.get("v.EOIWrap.RWMaritalStatus") == ''
               
              )
            {
                cmp.set("v.Spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type":"error",
                    "message": "Please fill all mandatory details like Country,Occupation,Nationality,Gender and Marital Status."});
                toastEvent.fire();
                return;
                
            }
            
            else if(cmp.get("v.hasState") && (cmp.get("v.EOIWrap.RWState") == null || cmp.get("v.EOIWrap.RWState") == undefined || cmp.get("v.EOIWrap.RWState") == '' ) )
            {
                cmp.set("v.Spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type":"error",
                    "message": "Please select a value for State."});
                toastEvent.fire();
                return;
                
            }
            
                else if(cmp.get("v.hasCity")&& (cmp.get("v.EOIWrap.RWCity") == null || cmp.get("v.EOIWrap.RWCity") == undefined || cmp.get("v.EOIWrap.RWCity") == '' ))
                {
                    cmp.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "type":"error",
                        "message": "Please select a value for City."});
                    toastEvent.fire();
                    return;
                    
                }
            
                    else if(cmp.get("v.EOIWrap.RWDateOfBirth") != undefined && cmp.get("v.EOIWrap.RWDateOfBirth") != null && dateValue >= today)
                    {
                        cmp.set("v.Spinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Date of Birth cannot be today or in the future."});
                        toastEvent.fire();
                        return;
                        
                    }
            
            /* else if(cmp.get("v.EOIWrap.RWCountry") == 'India' && (cmp.get("v.EOIWrap.RWState") == undefined || cmp.get("v.EOIWrap.RWState") == null || cmp.get("v.EOIWrap.RWState") == ''))
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please select a value for State." 
                        });
                        toastEvent.fire();
                        return;
                    }*/
            
                else if(cmp.get("v.EOIWrap.RWCountry") == 'India' && (!cmp.get("v.EOIWrap.RWPin").match('^[1-9][0-9]{5}$')))
                {
                    cmp.set("v.Spinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "type":"error",
                        "message": "Pin code should be 6 digits when country is selected as India." 
                    });
                    toastEvent.fire();
                    return;
                    
                }
            
                    else if(cmp.find("RWMailPerm").get("v.checked") == false && (cmp.get("v.EOIWrap.RWMailingAddressLine1") == undefined || cmp.get("v.EOIWrap.RWMailingAddressLine1") == null || cmp.get("v.EOIWrap.RWMailingAddressLine1") == ''))
                    {
                        cmp.set("v.Spinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please fill Mailing Address." 
                        });
                        toastEvent.fire();
                        return;
                        
                    }	
            
                        else if(cmp.find("RWMailPerm").get("v.checked") == false && 
                                ((cmp.get("v.EOIWrap.RWMailingCity") == undefined || cmp.get("v.EOIWrap.RWMailingCity") == null || cmp.get("v.EOIWrap.RWMailingCity") == '')
                                 || (cmp.get("v.EOIWrap.RWMailingPin") == undefined || cmp.get("v.EOIWrap.RWMailingPin") == null || cmp.get("v.EOIWrap.RWMailingPin") == '')
                                 || (cmp.get("v.EOIWrap.RWMailingCountry") == undefined || cmp.get("v.EOIWrap.RWMailingCountry") == null || cmp.get("v.EOIWrap.RWMailingCountry") == '')
                                ))
                        {
                            cmp.set("v.Spinner",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "ERROR!",
                                "type":"error",
                                "message": "Please fill all the mandatory details for mailing address." 
                            });
                            toastEvent.fire();
                            return;
                            
                        }	
            
                            else if(cmp.get("v.hasmailingState") && (cmp.get("v.EOIWrap.RWMailingState") == null || cmp.get("v.EOIWrap.RWMailingState") == undefined || cmp.get("v.EOIWrap.RWMailingState") == '' ) )
                            {
                                cmp.set("v.Spinner",false);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "ERROR!",
                                    "type":"error",
                                    "message": "Please select a value for Mailing State."});
                                toastEvent.fire();
                                return;
                                
                            }
            
                                else if(cmp.get("v.hasmailingCity")&& (cmp.get("v.EOIWrap.RWMailingCity") == null || cmp.get("v.EOIWrap.RWMailingCity") == undefined || cmp.get("v.EOIWrap.RWMailingCity") == '' ))
                                {
                                    cmp.set("v.Spinner",false);
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "ERROR!",
                                        "type":"error",
                                        "message": "Please select a value for Mailing City."});
                                    toastEvent.fire();
                                    return;
                                    
                                }
            
                                    else if(cmp.get("v.EOIWrap.RWMailingCountry") == 'India' && (cmp.get("v.EOIWrap.RWMailingState") == undefined || cmp.get("v.EOIWrap.RWMailingState") == null || cmp.get("v.EOIWrap.RWMailingState") == ''))
                                    {
                                        cmp.set("v.Spinner",false);
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "ERROR!",
                                            "type":"error",
                                            "message": "Please select a value for Mailing State." 
                                        });
                                        toastEvent.fire();
                                        return;
                                        
                                    }
            
                                        else if(cmp.get("v.EOIWrap.RWMailingCountry") == 'India' && (!cmp.get("v.EOIWrap.RWMailingPin").match('^[1-9][0-9]{5}$')))
                                        {
                                            cmp.set("v.Spinner",false);
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                "title": "ERROR!",
                                                "type":"error",
                                                "message": "Mailing addresss Pin code should be 6 digits when Mailing country is selected as India." 
                                            });
                                            toastEvent.fire();
                                            return;
                                            
                                        }
            
                                            else if(cmp.get("v.EOIWrap.RWTypeofapplicant") == '' || cmp.get("v.EOIWrap.RWTypeofapplicant") == null)
                                            {
                                                cmp.set("v.Spinner",false);
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    "title": "ERROR!",
                                                    "type":"error",
                                                    "message": "Please select Applicant Type under KYC section." 
                                                });
                                                toastEvent.fire();
                                                return;
                                                
                                            }	
            
                                                else if(cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") == '' || cmp.get("v.EOIWrap.RWTypeofapplicant") == null)
                                                {
                                                    cmp.set("v.Spinner",false);
                                                    var toastEvent = $A.get("e.force:showToast");
                                                    toastEvent.setParams({
                                                        "title": "ERROR!",
                                                        "type":"error",
                                                        "message": "Please select Mode of Payment under Payments Section."
                                                    });
                                                    toastEvent.fire();
                                                    return;
                                                    
                                                }
            
            
            
                                                    else if(cmp.get("v.KYCDocumentErrorMessage") != undefined && cmp.get("v.KYCDocumentErrorMessage") != null && cmp.get("v.KYCDocumentErrorMessage") !='')
                                                    {
                                                        cmp.set("v.Spinner",false);
                                                        var toastEvent = $A.get("e.force:showToast");
                                                        toastEvent.setParams({
                                                            "title": "ERROR!",
                                                            "type":"error",
                                                            "message": cmp.get("v.KYCDocumentErrorMessage")           
                                                        });
                                                        toastEvent.fire();
                                                        return;
                                                        
                                                    }
            
                                                        else if((cmp.get("v.EOIWrap.RWPANDetails") == undefined || cmp.get("v.EOIWrap.RWPANDetails") == null || cmp.get("v.EOIWrap.RWPANDetails") == '') && cmp.get("v.EOIWrap.RWResidentialstatus") != 'For NRI') 
                                                        {
                                                            cmp.set("v.Spinner",false);
                                                            var toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                "title": "ERROR!",
                                                                "type":"error",
                                                                "message": "PAN Number is mandatory. Please fill under KYC Document section and submit again."            });
                                                            toastEvent.fire();
                                                            return;
                                                            
                                                        }
            
                                                            else if(cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") != '' && cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") != 'Digital' && ((cmp.get("v.PaymentDetailsWrap.RWInstrumentNumber") == undefined || cmp.get("v.PaymentDetailsWrap.RWInstrumentNumber") == '') || cmp.get("v.PaymentDetailsWrap.RWPaymentDate")== undefined || cmp.get("v.PaymentDetailsWrap.RWBankName") == ''))
                                                            {
                                                                cmp.set("v.Spinner",false);
                                                                var toastEvent = $A.get("e.force:showToast");
                                                                toastEvent.setParams({
                                                                    "title": "ERROR!",
                                                                    "type":"error",
                                                                    "message": "Please fill all details under Payment Section and then submit" });
                                                                toastEvent.fire();
                                                                return;
                                                                
                                                            }
            
                                                                else if(cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") == 'Cheque' && cmp.get("v.PaymentDetailsWrap.RWPaymentDate") != undefined && cmp.get("v.PaymentDetailsWrap.RWPaymentDate") != null && cmp.get("v.PaymentDetailsWrap.RWPaymentDate") != '' && (chequedateValue < threemonth))
                                                                    
                                                                {
                                                                    cmp.set("v.Spinner",false);
                                                                    var toastEvent = $A.get("e.force:showToast");
                                                                    toastEvent.setParams({
                                                                        "title": "ERROR!",
                                                                        "type":"error",
                                                                        "message": "Cheque Date cannot be before Last 3 months from today" });
                                                                    toastEvent.fire();
                                                                    return;
                                                                    
                                                                }
            
                                                                    else if(!cmp.get("v.EOIWrap.RWOptin"))
                                                                    {
                                                                        cmp.set("v.Spinner",false);
                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                        toastEvent.setParams({
                                                                            "title": "ERROR!",
                                                                            "type":"error",
                                                                            "message": "Please select the Terms and Conditions and then submit the form" });
                                                                        toastEvent.fire();
                                                                        return;
                                                                        
                                                                    }
            
                                                                        else if(!cmp.get("v.ReadTermsandConditions"))
                                                                        {
                                                                            cmp.set("v.Spinner",false);
                                                                            var toastEvent = $A.get("e.force:showToast");
                                                                            toastEvent.setParams({
                                                                                "title": "ERROR!",
                                                                                "type":"error",
                                                                                "message": "Please click and read terms and conditions before submitting" });
                                                                            toastEvent.fire();
                                                                            return;
                                                                            
                                                                        }
                                                                            else if(!cmp.get("v.ReadBillDeskTC") && cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") == 'Digital' && cmp.get("v.PaymentGateway") == 'BillDesk')
                                                                            {
                                                                                cmp.set("v.Spinner",false);
                                                                                var toastEvent = $A.get("e.force:showToast");
                                                                                toastEvent.setParams({
                                                                                    "title": "ERROR!",
                                                                                    "type":"error",
                                                                                    "message": "Please click and read terms and conditions of BillDesk before submitting" });
                                                                                toastEvent.fire();
                                                                                return;   
                                                                            }
                                                                                else if(!cmp.get("v.EOIWrap.BillDeskTC") && cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") == 'Digital' && cmp.get("v.PaymentGateway") == 'BillDesk')
                                                                                {
                                                                                    cmp.set("v.Spinner",false);
                                                                                    var toastEvent = $A.get("e.force:showToast");
                                                                                    toastEvent.setParams({
                                                                                        "title": "ERROR!",
                                                                                        "type":"error",
                                                                                        "message": "Please click and read terms and conditions of BillDesk before submitting" });
                                                                                    toastEvent.fire();
                                                                                    return;   
                                                                                }
            
                                                                                    else
                                                                                    {
                                                                                        if(cmp.find("RWMailPerm").get("v.checked") == true)
                                                                                        {
                                                                                            cmp.set("v.EOIWrap.RWMailingAddressLine1",cmp.get("v.EOIWrap.RWPermanentAddressLine1"));
                                                                                            cmp.set("v.EOIWrap.RWMailingAddressLine2",cmp.get("v.EOIWrap.RWPermanentAddressLine2"));
                                                                                            cmp.set("v.EOIWrap.RWMailingAddressLine3",cmp.get("v.EOIWrap.RWPermanentAddressLine3"));
                                                                                            
                                                                                            
                                                                                            cmp.set("v.EOIWrap.RWMailingCity",cmp.get("v.EOIWrap.RWCity"));
                                                                                            cmp.set("v.EOIWrap.RWMailingPin",cmp.get("v.EOIWrap.RWPin"));
                                                                                            cmp.set("v.EOIWrap.RWMailingCountry",cmp.get("v.EOIWrap.RWCountry"));    
                                                                                            cmp.set("v.EOIWrap.RWMailingState",cmp.get("v.EOIWrap.RWState"));
                                                                                        }
                                                                                        console.log('--saveEOIrecord--');
                                                                                        var action = cmp.get("c.saveEOIrecord");
                                                                                        cmp.set("v.EOIWrap.RWTower",cmp.get('v.towerId'));
                                                                                        var phoneNumber =cmp.get("v.EOIWrap.RWPrimaryContactNo");
                                                                                        var phoneNumberCode =cmp.get("v.EOIWrap.RWCountryPhoneCode");
                                                                                        
                                                                                        //cmp.set("v.EOIWrap.RWPrimaryContactNo",phoneNumberCode.concat(phoneNumber));
                                                                                        action.setParams({recordId: cmp.get("v.eoiId") , eoiRecord : JSON.stringify(cmp.get("v.EOIWrap")) });
                                                                                        
                                                                                        action.setCallback(this, function(response) 
                                                                                                           {  
                                                                                                               var state = response.getState();
                                                                                                               if (state === "SUCCESS") 
                                                                                                               {
                                                                                                                   if(cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") == 'Digital')
                                                                                                                   {
                                                                                                                       if(cmp.get("v.PaymentGateway") == 'BillDesk')
                                                                                                                       {   
                                                                                                                           cmp.set("v.Spinner",true);
                                                                                                                           var action = cmp.get("c.getBillDeskData");
                                                                                                                           var details = {};
                                                                                                                           details['oppRecId'] = cmp.get('v.opportunityId');
                                                                                                                           details['eoiRecId'] = cmp.get('v.eoiId');	
                                                                                                                           details['towerId']  = cmp.get('v.towerId');
                                                                                                                           details['Amount']   = cmp.get("v.PaymentDetailsWrap.RWPaymentAmount");
                                                                                                                           action.setParams({     
                                                                                                                               "DetailMap": details 
                                                                                                                           });  
                                                                                                                           
                                                                                                                           action.setCallback(this, function(response) {
                                                                                                                               var state = response.getState();
                                                                                                                               if (state === "SUCCESS") 
                                                                                                                               {   
                                                                                                                                   var options = {};
                                                                                                                                   options['enableChildWindowPosting'] = 'true';
                                                                                                                                   options['enablePaymentRetry'] = 'true';
                                                                                                                                   options['retry_attempt_count'] = '2';
                                                                                                                                   var txtPayCategory = response.getReturnValue().toString().split('|')[20];
                                                                                                                                   console.log(response.getReturnValue().toString());
                                                                                                                                   console.log(txtPayCategory);
                                                                                                                                   if(txtPayCategory != 'NA'){
                                                                                                                                       options['txtPayCategory'] = txtPayCategory;
                                                                                                                                   }
                                                                                                                                   
                                                                                                                                   cmp.set("v.Spinner",false);
                                                                                                                                   bdPayment.initialize ({  
                                                                                                                                       "msg": response.getReturnValue(), 
                                                                                                                                       "options": options, 
                                                                                                                                       "callbackUrl": cmp.get('v.communityURL')+'eoi/?data='+(cmp.get('v.data'))
                                                                                                                                   });
                                                                                                                               }
                                                                                                                               
                                                                                                                           });
                                                                                                                           $A.enqueueAction(action); 
                                                                                                                       }
                                                                                                                       else if(cmp.get("v.PaymentGateway") === 'EaseBuzz') {
                                                                                                                           cmp.set("v.Spinner", true);
                                                                                                                           
                                                                                                                           var action = cmp.get("c.generateHashAndReturnPaymentLink");
                                                                                                                           action.setParams({
                                                                                                                               "opportunityId": cmp.get('v.opportunityId'),
                                                                                                                               "amount": cmp.get("v.PaymentDetailsWrap.RWPaymentAmount")
                                                                                                                           });
                                                                                                                           console.log('generateHashAndReturnPaymentLink');
                                                                                                                           action.setCallback(this, function(response) {
                                                                                                                               var state = response.getState();
                                                                                                                               cmp.set("v.Spinner", false);  // Hide the spinner after response
                                                                                                                               console.log('generateHashAndReturnPaymentLink1');
                                                                                                                               if (state === "SUCCESS") {
                                                                                                                                   var paymentLink = response.getReturnValue();
                                                                                                                                   console.log('Successfully generated payment link:', paymentLink);
                                                                                                                                   
                                                                                                                                   if (paymentLink) {
                                                                                                                                       window.open(paymentLink);  // Open the payment link in a new window
                                                                                                                                   } else {
                                                                                                                                       console.error('Payment link is empty.');
                                                                                                                                   }
                                                                                                                               } else if (state === "ERROR") {
                                                                                                                                   var errors = response.getError();
                                                                                                                                   if (errors && errors[0] && errors[0].message) {
                                                                                                                                       console.error('Error: ' + errors[0].message);
                                                                                                                                   } else {
                                                                                                                                       console.error('Unknown error.');
                                                                                                                                   }
                                                                                                                               } else {
                                                                                                                                   console.error('Failed to get the payment link. State: ' + state);
                                                                                                                               }
                                                                                                                           });
                                                                                                                           
                                                                                                                           $A.enqueueAction(action);
                                                                                                                       }
                                                                                                                       
                                                                                                                           else if(cmp.get("v.PaymentGateway") == 'CCAvenue'){
                                                                                                                               cmp.set("v.Spinner",true);
                                                                                                                               cmp.set("v.accessCode",  cmp.get("v.EOIWrap").gateway.Access_Code__c) ;
                                                                                                                               var billingaddress2;
                                                                                                                               var billingaddress3;
                                                                                                                               if(cmp.get('v.EOIWrap.RWPermanentAddressLine2') == undefined)
                                                                                                                                   billingaddress2 = '';
                                                                                                                               else
                                                                                                                                   billingaddress2 = cmp.get('v.EOIWrap.RWPermanentAddressLine2');
                                                                                                                               
                                                                                                                               if(cmp.get('v.EOIWrap.RWPermanentAddressLine3') == undefined)
                                                                                                                                   billingaddress3 = '';
                                                                                                                               else
                                                                                                                                   billingaddress3 = cmp.get('v.EOIWrap.RWPermanentAddressLine3');
                                                                                                                               //var input = 'language=EN&order_id=0426588&amount=5000&currency=INR&redirect_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&merchant_id=257901&';
                                                                                                                               //var input = 'language=EN&order_id=0426588&amount='+cmp.get('v.PaymentDetailsWrap.RWPaymentAmount')+'&currency=INR&redirect_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&merchant_id='+paymentResponse.getReturnValue().Merchant_Number__c+'&';
                                                                                                                               var input = 'language=EN&order_id='+cmp.get('v.EOIWrap.RWName')+'&amount='+cmp.get('v.digitalPaymentAmount')+'&currency=INR&redirect_url='+cmp.get('v.communityURL')+'eoi/?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url='+cmp.get('v.communityURL')+'eoi/?data='+encodeURIComponent(cmp.get('v.data'))+'&billing_name='+cmp.get('v.EOIWrap.RWPrimaryFirstName')+' '+cmp.get('v.EOIWrap.RWPrimaryLastName')+'&billing_address='+cmp.get('v.EOIWrap.RWPermanentAddressLine1')+' ' +billingaddress2+' '+billingaddress3+'&billing_city='+cmp.get('v.EOIWrap.RWCity')+'&billing_state='+cmp.get('v.EOIWrap.RWState')+'&billing_zip='+cmp.get('v.EOIWrap.RWPin')+'&billing_country='+cmp.get('v.EOIWrap.RWCountry')+'&billing_tel='+cmp.get('v.EOIWrap.RWPrimaryContactNo')+'&billing_email='+cmp.get('v.EOIWrap.RWPrimaryEmail')+'&merchant_id='+cmp.get("v.EOIWrap").gateway.Merchant_Number__c+'&';
                                                                                                                               var action = cmp.get("c.encrypt");
                                                                                                                               action.setParams({
                                                                                                                                   "inputdata": input,
                                                                                                                                   "encryptionKey" :cmp.get("v.EOIWrap").gateway.Encryption_Key__c
                                                                                                                               });
                                                                                                                               var payload;
                                                                                                                               action.setCallback(this, function(response){
                                                                                                                                   var state = response.getState();
                                                                                                                                   if (state === "SUCCESS") {
                                                                                                                                       payload = response.getReturnValue()
                                                                                                                                       console.log(payload);
                                                                                                                                       cmp.find("encRequest").getElement().value = payload;
                                                                                                                                       cmp.set("v.Spinner",false);
                                                                                                                                       cmp.find("paymentForm").getElement().submit();
                                                                                                                                       
                                                                                                                                   }
                                                                                                                               });
                                                                                                                               $A.enqueueAction(action);
                                                                                                                           }
                                                                                                                       
                                                                                                                       
                                                                                                                       
                                                                                                                       
                                                                                                                   }
                                                                                                                   else if(cmp.get("v.PaymentDetailsWrap.RWModeOfPayment") == '')
                                                                                                                   {
                                                                                                                       var toastEvent = $A.get("e.force:showToast");
                                                                                                                       toastEvent.setParams({
                                                                                                                           "title": "SUCCESS!",
                                                                                                                           "type":"success",
                                                                                                                           "message": "Your data is saved successfully"
                                                                                                                       });
                                                                                                                       toastEvent.fire();
                                                                                                                       $A.get('e.force:refreshView').fire();
                                                                                                                   }
                                                                                                                   
                                                                                                                       else 
                                                                                                                       {
                                                                                                                           cmp.set("v.Spinner",true);
                                                                                                                           var paymentAction = cmp.get("c.savePaymentRecord");
                                                                                                                           paymentAction.setParams({"opprecordId": cmp.get("v.opportunityId") , "eoiRecId": cmp.get("v.eoiId"), "digitalLinkId" :cmp.get("v.eoilinkrecordid"), paymentRecord : JSON.stringify(cmp.get("v.PaymentDetailsWrap")) });
                                                                                                                           
                                                                                                                           paymentAction.setCallback(this, function(response) 
                                                                                                                                                     {
                                                                                                                                                         
                                                                                                                                                         var state = response.getState();
                                                                                                                                                         if (state === "SUCCESS") 
                                                                                                                                                         {
                                                                                                                                                             //var toastEvent = $A.get("e.force:showToast");
                                                                                                                                                             cmp.set("v.isEOISuccess",true);
                                                                                                                                                             cmp.set("v.Spinner",false);
                                                                                                                                                             //cmp.set("v.Spinner",false);
                                                                                                                                                             /* toastEvent.setParams({
                                                                                         "title": "SUCCESS!",
                                                                                         "type":"success",
                                                                                         "message": "Your EOI submission is successfull"
                                                                                     });
                                                                                     toastEvent.fire();
                                                                                     $A.get('e.force:refreshView').fire();*/
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     
                                                                                     cmp.set("v.hasError",true);
                                                                                     cmp.set("v.errorMessage",response.getError()[0].message);
                                                                                     cmp.set("v.Spinner",false);
                                                                                     
                                                                                 }
                                                                             });
                                                   
                                                   
                                                   
                                                   $A.enqueueAction(paymentAction);
                                               }
                                           }
                                       });
                    
                    $A.enqueueAction(action);
                    
                }
        }
        else
        {
            cmp.set("v.Spinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": "Please check and correct all the errors in form and then submit"
            });
            toastEvent.fire();
            
        }
    },
    
    PrintForm: function(cmp,event,helper) 
    {
        // document.getElementById('header').style.display = 'none';
        cmp.set("v.onPrint",true);
        event.preventDefault();
        window.print();
    },
    
    handleComponentEvent : function(cmp,event,helper)
    {
        var DocumentType = event.getParam("DocumentType");
        var DocumentNumber = event.getParam("DocumentNumber");
        var isValid = event.getParam("IsValid");
        
        if(isValid)
        {
            cmp.set("v.KYCDocumentErrorMessage","");
            if(DocumentType =='PAN Card')
            {
                cmp.set("v.EOIWrap.RWPANDetails",DocumentNumber);
            }
        }
        if(!isValid)
        {
            cmp.set("v.KYCDocumentErrorMessage",event.getParam("errorMessage"));
        }
    },
    
    showPaymentFields: function(cmp,event,helper)
    {
        if(event.getSource().get("v.value") != 'Digital' &&  event.getSource().get("v.value") != ''){
            cmp.set("v.showPaymentFields",true);
            cmp.set("v.EOIWrap.BillDeskTC",false); /* bkk */
        }
        else
        {
            cmp.set("v.showPaymentFields",false);
            cmp.set("v.PaymentDetailsWrap.RWPaymentAmount",cmp.get("v.digitalPaymentAmount"));
        }
    },
    
    getPicklistValues: function(component, event, helper)
    {
        
        var fieldNames = ["RW_Nationality__c","RW_Occupation__c" ,"RW_Marital_Status__c","RW_Designation__c"];
        var action12 = component.get("c.getPicklistValuesForFields");
        action12.setParams({ "objectName" : 'RW_EOI__c' , fieldNames :fieldNames });
        action12.setCallback(this, function(response) 
                             {
                                 var state = response.getState();
                                 if (state === "SUCCESS") 
                                 {
                                     var responsevalues = response.getReturnValue();
                                     if(responsevalues.RW_Nationality__c)
                                     {
                                         component.set("v.NationalityPicklistOptions",responsevalues.RW_Nationality__c)
                                     }
                                     
                                     if(responsevalues.RW_Occupation__c)
                                     {
                                         component.set("v.OccupationPicklistOptions",responsevalues.RW_Occupation__c)
                                     }
                                     
                                     if(responsevalues.RW_Marital_Status__c)
                                     {
                                         component.set("v.MaritalStatusPicklistOptions",responsevalues.RW_Marital_Status__c)
                                     }
                                     
                                     if(responsevalues.RW_Designation__c)
                                     {
                                         component.set("v.DesignationPicklistOptions",responsevalues.RW_Designation__c)
                                     }
                                     
                                 }
                             });
        
        $A.enqueueAction(action12); 
    },
    
    onCountryValueChange : function(component, event, helper)
    {
        /* if(event.getSource().get("v.value") != 'India')
        {
            component.find("RWState").set("v.value","");
            component.find("RWState").set("v.disabled",true);   
        }
        
        else
        {
            component.find("RWState").set("v.required",true);
            component.find("RWState").set("v.disabled",false);   
        }*/
        component.find("RWState").set("v.value",'');
        component.find("RWCity").set("v.value",'');
        component.find("RWCity").set("v.disabled",true);
        component.find("RWCity").set("v.required",false);
        component.set("v.hasCity",false);
        var action1 = component.get("c.getDependentStatePicklists");
        action1.setParams({ "objectName" : 'RW_EOI__c' ,"CountryFieldName":'RW_Countries__c', "CountryFieldValue" :event.getSource().get("v.value") , "StateField":'RW_State__c' });
        action1.setCallback(this, function(response) 
                            {
                                var state = response.getState();
                                if (state === "SUCCESS") 
                                {
                                    var responsevalues = response.getReturnValue();
                                    
                                    component.set("v.state",responsevalues);
                                    
                                    //component.find("RWState").set("v.value","");
                                    if(responsevalues.length >0)
                                    {
                                        component.set("v.hasState",true);
                                        component.find("RWState").set("v.disabled",false); 
                                        component.find("RWState").set("v.required",false);
                                    }
                                    else
                                    {
                                        component.find("RWState").set("v.disabled",true);
                                        component.find("RWState").set("v.required",false);
                                        component.find("RWCity").set("v.disabled",true);
                                        component.find("RWCity").set("v.required",false);
                                        component.set("v.hasState",false);
                                        component.set("v.hasCity",false);
                                    }
                                    
                                }
                            });
        
        $A.enqueueAction(action1);
        
        
    },
    
    onMailingCountryValueChange : function(component, event, helper)
    {
        /* if(event.getSource().get("v.value") != 'India')
        {
            component.find("RWMailingState").set("v.value","");
            component.find("RWMailingState").set("v.disabled",true);   
        }
        
        else
        {
            component.find("RWMailingState").set("v.required",true);
            component.find("RWMailingState").set("v.disabled",false);   
        
        }*/
        
        
        component.find("RWMailingState").set("v.value",'');
        component.find("RWMailingCity").set("v.value",'');
        component.find("RWMailingCity").set("v.disabled",true);
        component.find("RWMailingCity").set("v.required",false);
        component.set("v.hasmailingCity",false);
        var action1 = component.get("c.getDependentStatePicklists");
        action1.setParams({ "objectName" : 'RW_EOI__c' ,"CountryFieldName":'RW_Mailing_Country__c', "CountryFieldValue" :event.getSource().get("v.value") , "StateField":'RW_Mailing_State__c' });
        action1.setCallback(this, function(response) 
                            {
                                var state = response.getState();
                                if (state === "SUCCESS") 
                                {
                                    var responsevalues = response.getReturnValue();
                                    
                                    component.set("v.mailingstate",responsevalues);
                                    
                                    //component.find("RWState").set("v.value","");
                                    if(responsevalues.length >0)
                                    {
                                        component.set("v.hasmailingState",true);
                                        component.find("RWMailingState").set("v.disabled",false); 
                                        component.find("RWMailingState").set("v.required",false);
                                    }
                                    else
                                    {
                                        component.find("RWMailingState").set("v.disabled",true);
                                        component.find("RWMailingState").set("v.required",false);
                                        component.find("RWMailingCity").set("v.disabled",true);
                                        component.find("RWMailingCity").set("v.required",false);
                                        component.set("v.hasmailingState",false);
                                        component.set("v.hasmailingCity",false);
                                    }
                                    
                                }
                            });
        
        $A.enqueueAction(action1);
        
    },
    
    redirectToTCPage :function(component, event, helper)
    {
        component.set("v.ReadTermsandConditions",true);
        let navService = component.find("navService");
        
        // Sets the route to [Org url]/[Community uri]/[pageName]
        let pageReference = {
            type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
            attributes: {
                pageName: 'termsandconditions' // pageName must be lower case
            },
            state: {
                towerId : component.get("v.towerId")
                
            }
        }
        
        const handleUrl = (url) => {
            window.open(url);
        };
            const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
            //navService.navigate(pageReference);
        } ,
            redirectToBillDeskTC :function(component, event, helper)
            {
                component.set("v.ReadBillDeskTC",true);
                window.open("https://runwalgroup.in/t&c");
                /*  let navService = component.find("navService");
        
        // Sets the route to [Org url]/[Community uri]/[pageName]
        let pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'billdesktermsandcondtitons' // pageName must be lower case
            },
            state: {
            }
        }
        
        const handleUrl = (url) => {
            window.open(url);
        };
            const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);*/
    },       
            generateOTP : function(component, event, helper)
            {
                component.set("v.InvalidOTP",false);
                component.set("v.Spinner",true);
                var action = component.get("c.generateEOIOTP");
                action.setParams({ OTPType : 'EOI' ,CustomerNo: component.get("v.EOIWrap.RWPrimaryContactNo"), recordId : component.get("v.eoiId") });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        component.set("v.ActualOTP" , response.getReturnValue());
                        component.set("v.OTPEntered",'');
                        component.set("v.showGenerateOTP" , false);
                        component.set("v.showValidateOTP",true);
                        component.set("v.Spinner",false);
                    }
                    else
                    {
                        component.set("v.Spinner",false);
                    }
                });
                
                $A.enqueueAction(action);  
                
            },
            
            validateOTP : function(component, event, helper)
            {
                if(component.get("v.ActualOTP") == component.get("v.OTPEntered"))
                {
                    component.set("v.showSubmitButton", true);
                    component.set("v.showValidateOTP",false);
                    component.set("v.InvalidOTP",false);
                    
                    component.set("v.EOIWrap.RWDigitallyAcceptedOn",$A.localizationService.formatDateTimeUTC(new Date(), "dd/MM/yyyy hh:mm a"));
                }
                
                else
                {
                    component.set("v.showSubmitButton", false);
                    component.set("v.InvalidOTP",true);
                }
            },
            checkDateValidation: function(component, event, helper)
            {
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                var dateValue = event.getSource().get("v.value");
                if(dateValue >= today)
                {
                    component.set("v.dateValidationError", true);
                }
                else
                {
                    component.set("v.dateValidationError", false);
                }
                
            },
            
            checkInstrumentDate:function(component, event, helper)
            
            {
                if(component.get("v.PaymentDetailsWrap.RWModeOfPayment") == 'Cheque')
                {
                    var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    var threemonth = new Date();
                    threemonth.setMonth(threemonth.getMonth() - 3);
                    threemonth = $A.localizationService.formatDate(threemonth, "YYYY-MM-DD");
                    var dateValue = event.getSource().get("v.value");
                    
                    if(dateValue < threemonth)
                    {
                        component.set("v.chequedateValidationError", true);
                    }
                    else
                    {
                        component.set("v.chequedateValidationError", false);
                    }
                }
                
            },
            
            onStateValueChange:function(component, event, helper)
            
            {
                component.find("RWCity").set("v.value",'');
                var action1 = component.get("c.getDependentCityPicklists");
                action1.setParams({ "objectName" : 'RW_EOI__c' ,"StateFieldName":'RW_State__c', "StateFieldValue" :event.getSource().get("v.value") , "CityField":'RW_City__c' });
                action1.setCallback(this, function(response) 
                                    {
                                        var state = response.getState();
                                        if (state === "SUCCESS") 
                                        {
                                            var responsevalues = response.getReturnValue();
                                            
                                            component.set("v.cityPicklistOptions",responsevalues);
                                            if(responsevalues.length >0)
                                            {
                                                component.set("v.hasCity",true);
                                                component.find("RWCity").set("v.disabled",false);
                                                component.find("RWCity").set("v.required",true);
                                            }
                                            
                                        }
                                    });
                
                $A.enqueueAction(action1);
                
                
            },
            
            onMailingStateValueChange:function(component, event, helper)
            
            {
                component.find("RWMailingCity").set("v.value",'');
                var action1 = component.get("c.getDependentCityPicklists");
                action1.setParams({ "objectName" : 'RW_EOI__c' ,"StateFieldName":'RW_Mailing_State__c', "StateFieldValue" :event.getSource().get("v.value") , "CityField":'RW_Mailing_City__c' });
                action1.setCallback(this, function(response) 
                                    {
                                        var state = response.getState();
                                        if (state === "SUCCESS") 
                                        {
                                            var responsevalues = response.getReturnValue();
                                            
                                            component.set("v.mailingcityPicklistOptions",responsevalues);
                                            if(responsevalues.length >0)
                                            {
                                                component.set("v.hasmailingCity",true);
                                                component.find("RWMailingCity").set("v.disabled",false);
                                                component.find("RWMailingCity").set("v.required",true);
                                            }
                                            
                                        }
                                    });
                
                $A.enqueueAction(action1);
                
                
            },
    
    redirectToEasebuzzTC: function(component,event){ //Added by coServe 11-10-2024
        component.set("v.ReadEasebuzzTC",true);
        window.open("https://easebuzz.in/terms/");
    }  
            
            
            
            
        })