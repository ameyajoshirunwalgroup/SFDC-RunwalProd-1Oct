({
    doInit: function(cmp,event,helper) 
    {
        cmp.set("v.Spinner",true);
        var action1 = cmp.get("c.getDecryptedData");
        action1.setParams({ data :decodeURIComponent(cmp.get("v.data")) });
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                
                var responseValues = response.getReturnValue().toString().split(',');
                cmp.set("v.opportunityId", responseValues[0]);
                cmp.set("v.eoiId", responseValues[1]);
                cmp.set("v.paymentlinkrecordid" , responseValues[2]);
                cmp.set("v.PaymentDetailsWrap.RWPaymentAmount", responseValues[3]);
                
                
                
                var action2 = cmp.get("c.checkLinkExpiry");
                action2.setParams({ eoiLinkRecordId :cmp.get("v.paymentlinkrecordid") });
                
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
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
                            
                            action3.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") 
                                {
                                    if(response.getReturnValue().RWCountryPhoneCode == null || response.getReturnValue().RWCountryPhoneCode == undefined || response.getReturnValue().RWCountryPhoneCode =='')
                                    {
                                        response.getReturnValue().RWCountryPhoneCode ='+91';
                                    }
                                    cmp.set("v.EOIWrap", response.getReturnValue());
                                    if(cmp.get("v.encResp") == undefined || cmp.get("v.encResp") ==null)
                                        {
                                                cmp.set("v.Spinner",false);
                                        }
                                    
                                }
                                
                                else
                                {
                                    cmp.set("v.hasError",true);
                                    cmp.set("v.errorMessage",response.getError()[0].message);
                                    cmp.set("v.Spinner",false);
                                }
                                
                            });
                            
                            var oppAction = cmp.get("c.loadOpportunityData");
                            oppAction.setParams({ oppRecordId :cmp.get("v.opportunityId") });
                            
                            oppAction.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") 
                                {
                                    cmp.set("v.opportunityWrapper", response.getReturnValue());
                                    cmp.set("v.ProjectName", response.getReturnValue().ProjectName);
                                    
                                     if(cmp.get("v.encResp") != undefined && cmp.get("v.encResp") !=null)
                            {
                               
                                        cmp.set("v.accessCode",  cmp.get("v.EOIWrap").gateway.Access_Code__c)  
                                        var ccAvenue = cmp.get("c.getPaymentResponseDecryptedData");
                                        var encryptedResponse = cmp.get("v.encResp");
                                        ccAvenue.setParams({ inputdata :encryptedResponse, decryptionKey : cmp.get("v.EOIWrap").gateway.Encryption_Key__c});
                                        ccAvenue.setCallback(this, function(response) 
                                                             {
                                                                 var state = response.getState();
                                                                 if (state === "SUCCESS") 
                                                                 {
                                                                     
                                                                     console.log('*response data*'+response.getReturnValue())
                                                                     var responsevalues = response.getReturnValue().toString().split('&');
                                                                     var responseArray={};
                                                                     for(var j=0;j<responsevalues.length;j++)
                                                                     {
                                                                         
                                                                         responseArray[responsevalues[j].split('=')[0]]=responsevalues[j].split('=')[1];
                                                                         
                                                                     }
                                                                     console.log('*ENTERED here*');
                                                                     if(responseArray['order_status'] == 'Success')
                                                                     {
                                                                         
                                                                         var action5 = cmp.get("c.getPaymentDetailsOfOpportunity"); 
                                                                         action5.setParams({ "oppRecordId" :cmp.get('v.opportunityId'),"TransactionId":responseArray['tracking_id'],"BankRefNumber":responseArray['bank_ref_no'] });
                                                                         console.log('*ENTERED here 2*');
                                                                         action5.setCallback(this, function(paymentRecordResponse) {
                                                                             
                                                                             var state = paymentRecordResponse.getState();
                                                                             if (state === "SUCCESS") 
                                                                             {
                                                                                 if(paymentRecordResponse.getReturnValue() != null && paymentRecordResponse.getReturnValue().length >0)
                                                                                 {
                                                                                     cmp.set("v.Spinner",false);
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
                                                                                     paymentdetails['digitalLinkId'] = cmp.get('v.paymentlinkrecordid');
                                                                                     var action6 = cmp.get("c.insertPartialPaymentDetails"); 
                                                                                     action6.setParams({ "details" :paymentdetails });
                                                                                     console.log('*ENTERED here 2*');
                                                                                     action6.setCallback(this, function(response) {
                                                                                         var state = response.getState();
                                                                                         if (state === "SUCCESS") 
                                                                                         {
                                                                                             console.log('*ENTERED here 3*');
                                                                                             cmp.set("v.isPaymentSuccess",responseArray['order_status']);
                                                                                             cmp.set("v.Spinner",false);
                                                                                         }
                                                                                         else
                                                                                         {
                                                                                             cmp.set("v.hasError",true);
                                                                                             cmp.set("v.errorMessage",response.getError()[0].message);
                                                                                             cmp.set("v.Spinner",false);
                                                                                         }
                                                                                     });
                                                                                     $A.enqueueAction(action6);
                                                                                 }
                                                                             }
                                                                             
                                                                             else
                                                                             {
                                                                                 cmp.set("v.hasError",true);
                                                                                 cmp.set("v.errorMessage",response.getError()[0].message);
                                                                                 cmp.set("v.Spinner",false);
                                                                             }
                                                                             
                                                                         });
                                                                         $A.enqueueAction(action5);      
                                                                         
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
                                    
                               cmp.set("v.Spinner",false);     
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
                            $A.enqueueAction(oppAction);
                            
                            
                           
                            
                            
                            
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
    },
    onformSubmit : function(cmp, event, helper) 
    
    {
        
       
                cmp.set("v.accessCode",  cmp.get("v.EOIWrap").gateway.Access_Code__c) 
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
                //var input = 'language=EN&order_id=0426588&amount='+cmp.get('v.PaymentDetailsWrap.RWPaymentAmount')+'&currency=INR&redirect_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/digital-payment?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/digital-payment?data='+encodeURIComponent(cmp.get('v.data'))+'&billing_name='+cmp.get('v.EOIWrap.RWPrimaryFirstName')+' '+cmp.get('v.EOIWrap.RWPrimaryLastName')+'&billing_address='+cmp.get('v.EOIWrap.RWPermanentAddressLine1')+' ' +cmp.get('v.EOIWrap.RWPermanentAddressLine2')+' '+cmp.get('v.EOIWrap.RWPermanentAddressLine3')+'&billing_city='+cmp.get('v.EOIWrap.RWCity')+'&billing_state='+cmp.get('v.EOIWrap.RWState')+'&billing_zip='+cmp.get('v.EOIWrap.RWPin')+'&billing_country='+cmp.get('v.EOIWrap.RWCountry')+'&billing_tel='+cmp.get('v.EOIWrap.RWPrimaryContactNo')+'&billing_email='+cmp.get('v.EOIWrap.RWPrimaryEmail')+'&merchant_id='+paymentResponse.getReturnValue().Merchant_Number__c+'&';
                var input = 'language=EN&order_id='+cmp.get('v.EOIWrap.RWName')+'&amount='+cmp.get('v.PaymentDetailsWrap.RWPaymentAmount')+'&currency=INR&redirect_url='+cmp.get('v.communityURL')+'digital-payment/?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url='+cmp.get('v.communityURL')+'digital-payment/?data='+encodeURIComponent(cmp.get('v.data'))+'&billing_name='+cmp.get('v.EOIWrap.RWPrimaryFirstName')+' '+cmp.get('v.EOIWrap.RWPrimaryLastName')+'&billing_address='+cmp.get('v.EOIWrap.RWPermanentAddressLine1')+' ' +billingaddress2+' '+billingaddress3+'&billing_city='+cmp.get('v.EOIWrap.RWCity')+'&billing_state='+cmp.get('v.EOIWrap.RWState')+'&billing_zip='+cmp.get('v.EOIWrap.RWPin')+'&billing_country='+cmp.get('v.EOIWrap.RWCountry')+'&billing_tel='+cmp.get('v.EOIWrap.RWPrimaryContactNo')+'&billing_email='+cmp.get('v.EOIWrap.RWPrimaryEmail')+'&merchant_id='+cmp.get("v.EOIWrap").gateway.Merchant_Number__c+'&' 

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
                        cmp.find("paymentForm").getElement().submit();
                        
                        
                    }
                });
                $A.enqueueAction(action);
                
            
    }
    
})