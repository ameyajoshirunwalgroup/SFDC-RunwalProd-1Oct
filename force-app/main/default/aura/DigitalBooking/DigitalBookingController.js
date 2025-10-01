({
    doInit: function(component,event,helper) {
        debugger;
        helper.getDependentPicklist(component);
        helper.getPicklistValues(component); 
        //helper.getPicklistValues2(component);     
        
        var data = component.get("v.data");
        debugger;
        data = data.split(" ").join('+');
        var action = component.get("c.getDetails");
        action.setParams({ data :decodeURIComponent(data) });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValues = response.getReturnValue();
                component.set("v.gateway",responseValues.gateway);
                component.set("v.LinkId",responseValues.LinkId);
                component.set("v.isLinkExpired",responseValues.linkExpired);
                
                component.set("v.booking",responseValues.bookingDetails.booking);
                /*PLN*/ component.set("v.PaymentGateway", responseValues.PaymentGateway);
                console.log(responseValues);
                debugger;
                if(component.get("v.encResp") != undefined && component.get("v.encResp") !=null && !responseValues.linkExpired)
                {			
                    component.set("v.accessCode", responseValues.gateway.Access_Code__c);	
                    var ccAvenue = component.get("c.getPaymentResponseDecryptedData");	
                    
                    var encryptedResponse = component.get("v.encResp");	
                    ccAvenue.setParams({ inputdata :encryptedResponse,decryptionKey : responseValues.gateway.Encryption_Key__c}); 
                    ccAvenue.setCallback(this, function(response) 
                                         {
                                             var state = response.getState();
                                             debugger;
                                             if (state === "SUCCESS") 
                                             {
                                                 var responsevalues = response.getReturnValue().toString().split('&');
                                                 var responseArray={};
                                                 for(var j=0;j<responsevalues.length;j++)
                                                 { 
                                                     responseArray[responsevalues[j].split('=')[0]]=responsevalues[j].split('=')[1];
                                                 }
                                                 console.log('*ENTERED here*');
                                                 if(responseArray['order_status'] == 'Success')
                                                 {    
                                                     component.set("v.isPaymentSuccess",responseArray['order_status']);
                                                     var action2 = component.get("c.getPaymentDetailsOfBooking"); 
                                                     action2.setParams({ "BookingRecordId" :component.get('v.booking').id,"TransactionId":responseArray['tracking_id'] });
                                                     console.log('*ENTERED here 2*');
                                                     action2.setCallback(this, function(paymentRecordResponse) {
                                                         var state = paymentRecordResponse.getState();
                                                         if (state === "SUCCESS") 
                                                         {
                                                             if(paymentRecordResponse.getReturnValue() != null && paymentRecordResponse.getReturnValue().length >0)
                                                             {}                                                           
                                                             else
                                                             {
                                                                 console.log('*ENTERED here 1*'+responseArray['order_status']);
                                                                 var paymentdetails ={};
                                                                 paymentdetails['bankReferenceNumber'] = responseArray['bank_ref_no'];
                                                                 paymentdetails['paymentTrackingId'] = responseArray['tracking_id'];
                                                                 paymentdetails['paymentMode'] = responseArray['payment_mode'];
                                                                 paymentdetails['paymentAmount'] = responseArray['amount'];
                                                                 paymentdetails['paymentDate'] = responseArray['trans_date'];
                                                                 paymentdetails['oppRecId'] = component.get('v.booking.Customer__c');
                                                                 paymentdetails['bookingId'] = component.get('v.booking.Id');
                                                                 paymentdetails['digitalLinkId'] = component.get('v.LinkId');
                                                                 var paymentaction = component.get("c.insertPaymentDetails"); 
                                                                 paymentaction.setParams({ "details" :paymentdetails });
                                                                 console.log('*ENTERED here 2*');
                                                                 paymentaction.setCallback(this, function(response) {
                                                                     var state = response.getState();
                                                                     if (state === "SUCCESS") 
                                                                     {
                                                                         console.log('*ENTERED here 3*');
                                                                         
                                                                         component.set("v.Spinner",false);                                                                         
                                                                     }else{
                                                                         component.set("v.hasError",true);
                                                                         component.set("v.errorMessage",response.getError()[0].message);
                                                                         component.set("v.Spinner",false);
                                                                     }
                                                                 });
                                                                 $A.enqueueAction(paymentaction);   
                                                             }
                                                         }
                                                     });
                                                     $A.enqueueAction(action2);      
                                                     
                                                     
                                                 }else if(responseArray['order_status'] == 'Failure'){
                                                     
                                                     component.set("v.isPaymentFailure",responseArray['order_status']);
                                                     component.set("v.Spinner",false);                                                                         
                                                 }else{
                                                     component.set("v.RecieptsList",responseValues.paymentdetail);   
                                                     
                                                     component.set("v.tokenAmount",responseValues.bookingDetails.booking.Token_Amount__c);
                                                     component.set("v.applicantDetails",responseValues.bookingDetails.applicants);
                                                     console.log(component.get("v.applicantDetails").length);
                                                     component.set("v.EncryptedProjectId",responseValues.EncryptedProjectId);
                                                     debugger;
                                                     component.set("v.UnitNo",responseValues.UnitNumber);
                                                     component.set("v.Project",responseValues.project);
                                                     component.set("v.applicableOffer",responseValues.applicableOffer);
                                                     component.set("v.isGatewayAvailable",responseValues.GatewayAvailable);   
                                                     component.set("v.communityURL",responseValues.CommunityUrl);   
                                                     debugger;
                                                     component.set("v.availedOffer",responseValues.appliedOffer);                
                                                     component.set("v.maxApplicants",responseValues.maxApplicants);
                                                     
                                                     if(responseValues.bookingDetails.applicants.length == 1){
                                                         component.set("v.removeDisabled",true);
                                                     }else
                                                     {
                                                         component.set("v.removeDisabled",false);
                                                         
                                                     }
                                                     if(responseValues.bookingDetails.applicants.length == responseValues.maxApplicants){
                                                         component.set("v.addDisabled",true);
                                                     }else{
                                                         component.set("v.addDisabled",false);
                                                         
                                                     }  
                                                     component.set("v.Spinner",false);   
                                                     
                                                 }
                                             }
                                             /* var paymentFailure = cmp.get("c.notifyPaymentFailure"); 
                                                     paymentFailure.setParams({ "eoiRecordId" :cmp.get('v.eoiId'),"TrackingId":responseArray['tracking_id'],"failureReason":responseArray['failure_message'] });
                                                     console.log('*ENTERED here 2*');
                                                     paymentFailure.setCallback(this, function(Response) {
                                                         
                                                         var state = Response.getState();
                                                         if (state === "SUCCESS") 
                                                         {
                                                             cmp.set("v.isPaymentFailure",responseArray['order_status']);
                                                         }
                                                     });
                                                     $A.enqueueAction(paymentFailure);      */
                                             component.set("v.Spinner",false);
                                             
                                             
                                         });    
                    $A.enqueueAction(ccAvenue);
                }
                //PLN                                        
                else if(component.get("v.msg") != undefined && component.get("v.msg") !=null && !responseValues.linkExpired){
                    component.set("v.Spinner",true); 
                    var billDeskAction = component.get("c.saveBillDeskResp"); 
                    
                    billDeskAction.setParams({ "msg": decodeURIComponent(component.get("v.msg")),"digitalLinkId" : component.get("v.LinkId"),"bRecId": component.get("v.booking.Id"),"towerId": component.get("v.booking.Unit_No__r.TowerName__c")});  
                    billDeskAction.setCallback(this, function(response) {
                        var state = response.getState();
                        //  Console.log(response.getReturnValue());
                        if (state === "SUCCESS") 
                        {                            
                            if(response.getReturnValue() == "Success")
                            {
                                
                                component.set("v.isPaymentSuccess",response.getReturnValue());
                                component.set("v.Spinner",false);   
                                
                            }   
                            else
                            {
                                component.set("v.isPaymentFailure",response.getReturnValue());
                                component.set("v.Spinner",false);   
                                
                            }
                            component.set("v.Spinner",false);
                        }
                        
                    });
                    //    $A.enqueueAction(action); 
                    $A.enqueueAction(billDeskAction);							   
                }
                
                    else{
                        component.set("v.RecieptsList",responseValues.paymentdetail);   
                        
                        component.set("v.tokenAmount",responseValues.bookingDetails.booking.Token_Amount__c);
                        component.set("v.applicantDetails",responseValues.bookingDetails.applicants);
                        console.log(component.get("v.applicantDetails").length);
                        component.set("v.EncryptedProjectId",responseValues.EncryptedProjectId);
                        debugger;
                        component.set("v.UnitNo",responseValues.UnitNumber);
                        component.set("v.Project",responseValues.project);
                        component.set("v.applicableOffer",responseValues.applicableOffer);
                        component.set("v.isGatewayAvailable",responseValues.GatewayAvailable);   
                        component.set("v.communityURL",responseValues.CommunityUrl);   
                        debugger;
                        component.set("v.availedOffer",responseValues.appliedOffer);                
                        component.set("v.maxApplicants",responseValues.maxApplicants);
                        
                        if(responseValues.bookingDetails.applicants.length == 1){
                            component.set("v.removeDisabled",true);
                        }else
                        {
                            component.set("v.removeDisabled",false);
                            
                        }
                        if(responseValues.bookingDetails.applicants.length == responseValues.maxApplicants){
                            component.set("v.addDisabled",true);
                        }else{
                            component.set("v.addDisabled",false);
                            
                        }  component.set("v.Spinner",false);
                    }
            }else
            {
                
                component.set("v.Spinner",false);
                
                component.set("v.isInvalid",true);
            }
        })
        
        
        
        
        $A.enqueueAction(action);
        
    },
    addApplicant: function(component,event,helper){
        component.set("v.childSpinner",true);
        
        var applicants = component.get("v.applicantDetails")	;
        var action = component.get("c.addApplicants");
        action.setParams({ applicants :applicants });
        debugger;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                debugger;
                var responseValues = response.getReturnValue();
                component.set("v.applicantDetails",responseValues);
                
                if(responseValues.length == 1){
                    component.set("v.removeDisabled",true);
                }else
                {
                    component.set("v.removeDisabled",false);
                    
                }
                if(responseValues.length == component.get("v.maxApplicants")){
                    component.set("v.addDisabled",true);
                }else{
                    component.set("v.addDisabled",false);
                    
                }
            }else{
                component.set("v.childSpinner",false);
                
            }
            component.set("v.childSpinner",false);
        })
        $A.enqueueAction(action);
        
    },
    removeApplicant:function(component,event,helper){
        debugger;
        component.set("v.childSpinner",true);
        var applicants = component.get("v.applicantDetails");
        var action = component.get("c.removeApplicants");
        action.setParams({ applicants :applicants });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                
                var responseValues = response.getReturnValue();
                component.set("v.applicantDetails",responseValues);
                if(responseValues.length == 1){
                    component.set("v.removeDisabled",true);
                }else
                {
                    component.set("v.removeDisabled",false);
                    
                }
                if(responseValues.length == component.get("v.maxApplicants")){
                    component.set("v.addDisabled",true);
                }else{
                    component.set("v.addDisabled",false);
                    
                }
                component.set("v.childSpinner",false); 
                component.set("v.selectTab","tabNum0"); 
                
            }else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type":"error",
                    "message": response.getError()[0].message 
                });
                toastEvent.fire();
                component.set("v.childSpinner",false);
            }})
        $A.enqueueAction(action);
        
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
                projectId : component.get("v.EncryptedProjectId")
                
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
                component.set("v.BillDeskTC",true);
                window.open("https://runwalgroup.in/t&c");
              /*
                let navService = component.find("navService");
        
        // Sets the route to [Org url]/[Community uri]/[pageName]
        let pageReference = {
            type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
            attributes: {
                pageName: 'termsandconditions' // pageName must be lower case
            },
            state: {
                projectId : component.get("v.EncryptedProjectId")
                
            }
        }
        
        const handleUrl = (url) => {
            window.open(url);
        };
            const handleError = (error) => {
            console.log(error);
        };
            navService.generateUrl(pageReference).then(handleUrl, handleError);
            
            */
                },       
                    generateOTP : function(component, event, helper)
                    {
                        
                        var isError = helper.validate(component,event);
                        var isPayError = false;
                        var paymentDetail = component.get("v.RecieptsList");
                        //if(paymentDetail.length > 0 ){
                        //    if(paymentDetail[0].Mode__c !='Digital'){
                        isPayError =  helper.paymentval(component,event);
                        //  }
                        // }
                        if(!isError && !isPayError)
                        {
                            if(component.get("v.ReadTermsandConditions")){
                                component.set("v.InvalidOTP",false);
                                component.set("v.Spinner",true);
                                var action = component.get("c.generateBookingOTP");
                                var applicantDetail = component.get("v.applicantDetails");
                                action.setParams({ OTPType : 'Booking' ,CustomerNo:applicantDetail[0].Mobile_Number__c, recordId : component.get("v.booking.Id"),bookingEmail:applicantDetail[0].Email_Address__c });
                                
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") 
                                    {debugger;
                                     component.set("v.Spinner",false);
                                     component.set("v.ActualOTP",response.getReturnValue());
                                     component.set("v.OTPEntered",'');
                                     component.set("v.showGenerateOTP" , false);
                                     component.set("v.showValidateOTP",true);
                                     cmp.find("OTPNumber").focus(); 
                                     
                                     //  afterRender(component,helper);                        
                                    }
                                    else
                                    {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "ERROR!",
                                            "type":"error",
                                            "message": response.getError()[0].message 
                                        });
                                        toastEvent.fire();
                                        component.set("v.Spinner",false);
                                    }
                                });
                                
                                $A.enqueueAction(action);  
                            }
                            else if(!component.get("v.BillDeskTC") && component.get("v.digitalPaymentMode") && component.get("v.PaymentGateway") == 'BillDesk')
                            {
                                component.set("v.Spinner",false);
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "ERROR!",
                                    "type":"error",
                                    "message": "Please click and read terms and conditions of BillDesk before submitting" });
                                toastEvent.fire();
                                return;   
                            }
                            else if(!component.get("v.ReadTermsandConditions")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        "title": "ERROR!",
                                        "type":"error",
                                        "message": "Please read Terms and Condition before submitting"
                                    })  
                                    
                                    toastEvent.fire();
                                }
                        }else{
                            var msg;
                            
                            
                            if(isError && isPayError){
                                msg="Please check and correct all the Applicant and Payment errors in form and then submit";
                                
                            }else    if(isPayError){
                                msg= "Please check and correct all the Payment errors in form and then submit"
                            }else  if(isError){
                                msg="Please check and correct all the Applicant errors in form and then submit";
                                
                            }
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "ERROR!",
                                "type":"error",
                                "message": msg
                            });
                            toastEvent.fire();
                            
                        }
                        component.set("v.Spinner",false);
                        
                    },
                    validateOTP : function(component, event, helper)
                    {debugger;
                     if(component.get("v.ActualOTP") == component.get("v.OTPEntered"))
                     {
                         component.set("v.showSubmitButton", true);
                         component.set("v.showValidateOTP",false);
                         component.set("v.InvalidOTP",false);
                         console.log($A.localizationService.formatDateTimeUTC(new Date()));
                         
                         component.set("v.booking.RW_Digitally_Accepted_On__c",$A.localizationService.formatDateTimeUTC(new Date(), "yyyy-MM-DDTHH:mm:ss.SSSZ"));
                     }
                     
                     else
                     {
                         component.set("v.showSubmitButton", false);
                         component.set("v.InvalidOTP",true);
                     }
                    },
                    
                    paymentgatewaybooking: function(cmp,event,helper) 
                    {debugger;
                     cmp.set("v.Spinner",true);
                     //have array of tab and name error array
                     //get the applicant details
                     //loop through applicant detail
                     //validate the individual tabs
                     //if error add it to array
                     //get the kyc validate the same
                     
                     
                     // validate the payment details
                     // check tnc checked
                     
                     //if no error pass the data to apex contorller by building the wrapper
                     debugger;
                     ;
                     debugger;
                     //helper.paymentval(cmp,event,helper);
                     
                     
                     
                     var isError = helper.validate(cmp,event);
                     
                     
                     
                     
                     debugger;  
                     if(!isError ){
                         if(cmp.get("v.ReadTermsandConditions")){
                             debugger;
                             var applicants = cmp.get("v.applicantDetails");
                             var booking = cmp.get("v.booking");
                             var paymentDetail = cmp.get("v.RecieptsList");
                             //   var bookingwrapper= new Object();
                             //    var bookingDetails =new Object();
                             // bookingDetails.applicants=applicants;
                             // bookingDetails.booking=booking;
                             //  bookingwrapper.bookingDetails=bookingDetails;
                             var ccdetails =  cmp.get("v.gateway");
                             // bookingwrapper.bookingDetails.applicants = applicants;
                             //  bookingwrapper.bookingDetails.booking = booking;
                             // bookingwrapper.paymentdetail= paymentDetail;
                             //    bookingwrapper.paymentdetail=paymentDetail;
                             //  console.log(bookingwrapper);
                             var billingaddress2;
                             var billingaddress3;
                             
                             if(applicants[0].Mailing_Address_Line_2__c== undefined)
                                 billingaddress2 = '';
                             else
                                 billingaddress2 = applicants[0].Mailing_Address_Line_2__c;
                             
                             if(applicants[0].Mailing_Address_Line_3__c == undefined)
                                 billingaddress3 = '';
                             else
                                 billingaddress3 = applicants[0].Mailing_Address_Line_3__c;
                             //var input = 'language=EN&order_id=0426588&amount=5000&currency=INR&redirect_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&merchant_id=257901&';
                             //var input = 'language=EN&order_id=0426588&amount='+cmp.get('v.PaymentDetailsWrap.RWPaymentAmount')+'&currency=INR&redirect_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&cancel_url=https://prodsb-runwal.cs73.force.com/rhdemo/s/eoi?data='+encodeURIComponent(cmp.get('v.data'))+'&merchant_id='+paymentResponse.getReturnValue().Merchant_Number__c+'&';
                             var input = 'language=EN&order_id='+booking.Name+'&amount='+cmp.get('v.tokenAmount')+
                                 '&currency=INR&redirect_url='+cmp.get('v.communityURL')+
                                 'onlinebooking?data='+cmp.get('v.data')+'&cancel_url='+
                                 cmp.get('v.communityURL')+'onlinebooking/?data='+cmp.get('v.data')+
                                 '&billing_name='+applicants[0].First_Name__c+' '+ applicants[0].Last_Name__c+'&billing_address='+
                                 applicants[0].Mailing_Address_Line_1__c+' ' +billingaddress2+' '+billingaddress3+
                                 '&billing_city='+applicants[0].Mailing_City__c+'&billing_state='+applicants[0].Mailing_State__c+
                                 '&billing_zip='+applicants[0].Mailing_Pincode__c+'&billing_country='
                             +applicants[0].Mailing_Country__c+'&billing_tel='+applicants[0].Mobile_Number__c+
                                 '&billing_email='+applicants[0].Email_Address__c+'&merchant_id='+ccdetails.Merchant_Number__c;
                             //+'&splitData=' '{"split_tdr_charge_type":"'+tdr+'","merComm":"'+comm+'","split_data_list":[{"splitAmount":"'+booking.Token_Amount__c+'","subAccId":"'+subid+'"},{"splitAmount":"'+booking.ST_Token_Amount__c+'","subAccId":"'+gstaccount+'"}]}';
                             
                             var action = cmp.get("c.submitBooking");             
                             action.setParams({ 'payload':input ,'encryptionKey':ccdetails.Encryption_Key__c, 'booking' :booking,'applicants':applicants,'paymentDetail':paymentDetail,'bookingLink':cmp.get("v.LinkId"),
                                               'comm':ccdetails.Merchant_Commission__c,'subid':ccdetails.Sub_Account_Id__c,'tdr':ccdetails.Split_TDR_Charge__c});
                             action.setCallback(this, function(response) {
                                 var state = response.getState();
                                 if (state === "SUCCESS") 
                                 {
                                     if(cmp.get("v.PaymentGateway") == 'BillDesk')
                                     {
                                         //   let button = event.getSource();
                                         //	 button.set('v.disabled',true);
                                         cmp.set("v.Spinner",true);
                                         var action = cmp.get("c.getBillDeskData");
                                         var details = {}; 
                                         debugger;
                                         details['oppRecId'] = cmp.get("v.booking.Customer__c");
                                         details['bRecId'] = cmp.get("v.booking.Id");
                                         details['towerId'] = cmp.get("v.booking.Unit_No__r.TowerName__c");
                                         details['Amount']  = cmp.get("v.booking.Token_Amount__c");
                                         details['projectUnit']  = cmp.get("v.booking.Unit_No__r.Id");
                                         
                                         action.setParams({     
                                             "DetailMap": details 
                                         }); 
                                         
                                         action.setCallback(this, function(response) {
                                             var state = response.getState();
                                             if (state === "SUCCESS") 
                                             {   
                                                 /* PLN*/
                                                 
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
                                                     "callbackUrl": cmp.get('v.communityURL')+'onlinebooking?data='+(cmp.get('v.data'))
                                                 });
                                             }
                                         });
                                         $A.enqueueAction(action); 
                                     }
                                     else if(cmp.get("v.PaymentGateway") == 'CCAvenue')
                                     {
                                         // place your code here
                                         cmp.set("v.Spinner",false);
                                         console.log(response.getReturnValue());   
                                         cmp.set("v.accessCode",  ccdetails.Access_Code__c) ;
                                         
                                         cmp.find("access_code").getElement().value =  ccdetails.Access_Code__c;
                                         
                                         cmp.find("encRequest").getElement().value = response.getReturnValue();
                                         cmp.find("paymentForm").getElement().submit();
                                     }
                                 }
                                 else
                                 { 
                                     cmp.set("v.errorMessage",response.getError()[0].message);
                                     cmp.set("v.Spinner",false);
                                 }});
                             
                             $A.enqueueAction(action);
                         }
                         else{
                             // cmp.set("v.Spinner",false);
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                                 "title": "ERROR!",
                                 "type":"error",
                                 "message": "Please read Terms and Condition before submitting"
                             })  
                             
                             cmp.set("v.Spinner",false);
                             toastEvent.fire();
                         } }
                     
                     else
                     {
                         var msg;
                         
                         cmp.set("v.Spinner",false);
                         var toastEvent = $A.get("e.force:showToast");
                         toastEvent.setParams({
                             "title": "ERROR!",
                             "type":"error",
                             "message": "Please check and correct all the Applicant errors in form and then submit"
                         });
                         toastEvent.fire();
                         
                     }      
                    },
                    chqBooking: function(cmp,event,helper) 
                    
                    {debugger;
                     cmp.set("v.Spinner",true);
                     
                     
                     var isError = helper.validate(cmp,event);
                     var isPayError =  helper.paymentval(cmp,event);
                     
                     debugger;  
                     if(!isError && !isPayError){
                         if(cmp.get("v.ReadTermsandConditions")){
                             var applicants = cmp.get("v.applicantDetails");
                             var booking = cmp.get("v.booking");
                             var paymentDetail = cmp.get("v.RecieptsList");
                             
                             var action = cmp.get("c.saveBooking");             
                             //    action.setParams({ 'bkwrap' :JSON.stringify(bookingwrapper),'bookingLink':cmp.get("v.LinkId")});
                             action.setParams({ 'booking' :booking,'applicants':applicants,'paymentDetail':paymentDetail,'bookingLink':cmp.get("v.LinkId")});
                             
                             
                             action.setCallback(this, function(response) {
                                 var state = response.getState();
                                 if (state === "SUCCESS") 
                                 {
                                     cmp.set ("v.isBookingSuccess",response.getReturnValue().isBookingSuccess);
                                     cmp.set("v.Spinner",false);
                                     
                                 }
                                 else
                                 {
                                     cmp.set ("v.isBookingSuccess",false);
                                     cmp.set("v.Spinner",false);
                                     
                                 }
                             });
                             $A.enqueueAction(action);
                         }else{                                      
                             cmp.set("v.Spinner",false);
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                                 "title": "ERROR!",
                                 "type":"error",
                                 "message": "Please read Terms and Condition before submitting"
                             }) 
                             toastEvent.fire();
                         }
                         
                     }else
                     {
                         var msg;
                         if(isPayError){
                             msg= "Please check and correct all the Payment errors in form and then submit"
                         }
                         if(isError){
                             msg="Please check and correct all the Applicant errors in form and then submit";
                             
                         }
                         if(isError && isPayError){
                             msg="Please check and correct all the Applicant and Payment errors in form and then submit";
                             
                         }
                         cmp.set("v.Spinner",false);
                         var toastEvent = $A.get("e.force:showToast");
                         toastEvent.setParams({
                             "title": "ERROR!",
                             "type":"error",
                             "message": msg
                         });
                         toastEvent.fire();
                         
                         
                         
                         
                     }
                    },
                    
                })