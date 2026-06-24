({
	doInit : function( component, event, helper ) {  
        
        console.log('mahalaxmiPaymentMessage: '+component.get("v.mahalaxmiPaymentMessage") );
        /*if(component.get("v.mahalaxmiPaymentMessage") != undefined && component.get("v.mahalaxmiPaymentMessage") != null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": component.get("v.mahalaxmiPaymentMessage") ,
                "type":'success'
            });
            toastEvent.fire();
        }*/
        
        var query = window.location.search.substring(1);
        console.log('query: ', query);
        var vars = query.split("&");
        console.log('vars: ', vars);
        vars.forEach(function(v) {
            var pair = v.split("=");
            if (pair[0] === "c__mahalaxmiPaymentMessage") component.set("v.mahalaxmiPaymentMessage", decodeURIComponent(pair[1]));
            if (pair[0] === "c__mahalaxmiPaymentStatus") component.set("v.mahalaxmiPaymentStatus", decodeURIComponent(pair[1]));
        });
        console.log('mahalaxmiPaymentMessage: '+component.get("v.mahalaxmiPaymentMessage") );
        if(component.get("v.mahalaxmiPaymentStatus") == 'success'){
            if(component.get("v.mahalaxmiPaymentMessage") != undefined && component.get("v.mahalaxmiPaymentMessage") != null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": component.get("v.mahalaxmiPaymentMessage") ,
                    "type":'success'
                });
                toastEvent.fire();
            }
        }else if(component.get("v.mahalaxmiPaymentStatus") == 'fail'){
            if(component.get("v.mahalaxmiPaymentMessage") != undefined && component.get("v.mahalaxmiPaymentMessage") != null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": component.get("v.mahalaxmiPaymentMessage") ,
                    "type":'error'
                });
                toastEvent.fire();
            }
        }
        
      
       console.log('********'+component.get("v.msg") );
         if(component.get("v.msg") != undefined && component.get("v.msg") !=null){
                     console.log('*******'+component.get("v.msg"));
                                                            component.set("v.Spinner",true); 
                                        var action1 = component.get('c.saveBillDeskData'); 

       var details ={};
      
        details['msg'] = decodeURIComponent(component.get("v.msg"));
        details['towerId'] = component.get("v.BookingData.TowerId");
           console.log(details);
         action1.setParams({     
             "DetailMap": details 
             
        });   
             
  
                    action1.setCallback(this, function(response) {
                                            var state = response.getState();
                        
                                            if (state === "SUCCESS") 
                                            {           component.set("v.Spinner",false);                  
                                                if(response.getReturnValue() == "Success")
                                                { var action=component.get('c.showSuccessMessage');
                                                   
                                                $A.enqueueAction(action);
                                                 console.log('successful');
                                                }   
                                                else
                                                {   var action=component.get('showFailureMessage');
                                                  $A.enqueueAction(action);  
                                                 console.log('failure');
                                                }
                                                component.set("v.Spinner",false);
                                            }
                                        });

                                        $A.enqueueAction(action1); 
																			   
                                    
                } 
            
      
    },
    
    downloadfile : function( component, event, helper ) 
    {  
        component.set("v.isOpen", true);
		var action = component.get("c.getCustomerLedgerPdf");
         action.setParams({     
            "customerNumber": event.getSource().get("v.name"),
             "companycode": component.get("v.BookingData.companyCode")
        });  

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                       
                        var pdfjsframe = component.find('pdfFrame');
                        pdfjsframe.getElement().contentWindow.postMessage(response.getReturnValue(),'*');
                        
                        //var pdfjsframe = component.find('pdfFrame');
                        //pdfjsframe.getElement().contentWindow.postMessage(response.getReturnValue(),'*');
                        //component.set("v.pdfValue",response.getReturnValue());
                        
					}
                });
        $A.enqueueAction(action); 
	},
    
       closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    payProjectSpecificAmount : function( component, event, helper ) 
    { //invoking spinner on click event
        if(component.get('v.hasreadTC'))
        {
        component.set("v.Spinner",true);
        /*var action = component.get("c.getBillDeskData");  //Commented by Vinay 02-05-2025
        var details ={};
          details['bookingId'] = component.get("v.BookingData.BookingId");
            
            details['ButtonType']=event.getSource().get("v.name");
             details['OpportunityId'] = component.get("v.BookingData.opportunityId");
             
        details['towerId'] = component.get("v.BookingData.TowerId");
        details['Amount'] = component.get("v.BookingData.ProjectSpecificAmount");
         details['ProjectUnit'] = component.get("v.BookingData.unitNo");
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
                        //changes done by Srinivas on 15/07/21
                        component.set("v.Spinner",false);
                        
                        //ends
                             bdPayment.initialize ({  
                            "msg":response.getReturnValue(), 
                            "options": options, 
                                "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                            });
    				}             
                   
                    
		});
        $A.enqueueAction(action); */
            if(component.get("v.BookingData.ProjectName") == '7 Mahalaxmi'){  //Added by Vinay 02-05-2025
                console.log('payAmount2');
                var action = component.get("c.paymentForMahalaxmi");
                var details ={};
                details['bookingId'] = component.get("v.BookingData.BookingId");
                details['TypeOfAmount']='Normal';
                details['OpportunityId'] = component.get("v.BookingData.opportunityId");
                details['towerId'] = component.get("v.BookingData.TowerId");
                details['Amount'] = component.get("v.BookingData.TotalAmountPaid");
                details['ProjectUnit'] = component.get("v.BookingData.unitNo");
                action.setParams({     
                    "DetailMap": details 
                }); 
                console.log('payAmount3');
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state: ' + state);
                    console.log('Response: ' + response.getReturnValue());
                    if (state === "SUCCESS") {
                        console.log('Response: ' + response.getReturnValue());
                        component.set("v.htmlCode", response.getReturnValue());
                        //component.set("v.htmlCode", "<html><head></head><body>	Testing HTML</body></html>");
                        component.set("v.Spinner",false);
                    }
                    console.log('htmlCode: '+ component.get("v.htmlCode"));
                    console.log('current url: ', window.location.pathname);
                    /*bdPayment.initialize ({  
                            "msg":response.getReturnValue(), 
                            "options": options, 
                            "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                        });*/
                    
                });
                $A.enqueueAction(action);
            }else{
                var action = component.get("c.getBillDeskData");
                var details ={};
                details['bookingId'] = component.get("v.BookingData.BookingId");
                
                details['ButtonType']=event.getSource().get("v.name");
                details['OpportunityId'] = component.get("v.BookingData.opportunityId");
                
                details['towerId'] = component.get("v.BookingData.TowerId");
                details['Amount'] = component.get("v.BookingData.ProjectSpecificAmount");
                details['ProjectUnit'] = component.get("v.BookingData.unitNo");
                action.setParams({     
                    "DetailMap": details 
                });  
                
                action.setCallback(this, function(response) {
                    
                    var state = response.getState();
                    console.log('response.getReturnValue().toString(): ', response.getReturnValue().toString());
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
                        //changes done by Srinivas on 15/07/21
                        component.set("v.Spinner",false);
                        
                        //ends
                        bdPayment.initialize ({  
                            "msg":response.getReturnValue(), 
                            "options": options, 
                            "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                        });
                    }             
                    
                    
                });
                $A.enqueueAction(action);
            }
        }
         else
        {
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Please read Terms and Conditions by clicking on below link.",
            "type":'error'
        });
        toastEvent.fire();
        }
    },
    
     payAmount : function( component, event, helper ) 
    { //invoking spinner on click event
        if(component.get('v.hasreadTC'))
           {
        component.set("v.Spinner",true);
        /*var action = component.get("c.getBillDeskData");  //Commented by Vinay 02-05-2025
        var details ={};
       details['bookingId'] = component.get("v.BookingData.BookingId");
            details['TypeOfAmount']='Normal';
             details['OpportunityId'] = component.get("v.BookingData.opportunityId");
            
        details['towerId'] = component.get("v.BookingData.TowerId");
        details['Amount'] = component.get("v.BookingData.TotalAmountPaid");
         details['ProjectUnit'] = component.get("v.BookingData.unitNo");
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
                        //changes done by Srinivas on 15/07/21
                        component.set("v.Spinner",false);
                        
                        //ends
                             bdPayment.initialize ({  
                            "msg":response.getReturnValue(), 
                            "options": options, 
                                "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                                    });
    				}             
                   
                    
		});
      
        $A.enqueueAction(action); */
               if(component.get("v.BookingData.ProjectName") == '7 Mahalaxmi'){ //Added by Vinay 02-05-2025
                   console.log('payAmount2');
                   var action = component.get("c.paymentForMahalaxmi");
                   var details ={};
                   details['bookingId'] = component.get("v.BookingData.BookingId");
                   details['TypeOfAmount']='Normal';
                   details['OpportunityId'] = component.get("v.BookingData.opportunityId");
                   details['towerId'] = component.get("v.BookingData.TowerId");
                   details['Amount'] = component.get("v.BookingData.TotalAmountPaid");
                   details['ProjectUnit'] = component.get("v.BookingData.unitNo");
                   action.setParams({     
                       "DetailMap": details 
                   }); 
                   console.log('payAmount3');
                   action.setCallback(this, function(response) {
                       var state = response.getState();
                       console.log('state: ' + state);
                       console.log('Response: ' + response.getReturnValue());
                       if (state === "SUCCESS") {
                           console.log('Response: ' + response.getReturnValue());
                           component.set("v.htmlCode", response.getReturnValue());
                           //component.set("v.htmlCode", "<html><head></head><body>	Testing HTML</body></html>");
                           component.set("v.Spinner",false);
                       }
                       console.log('htmlCode: '+ component.get("v.htmlCode"));
                       console.log('current url: ', window.location.pathname);
                       bdPayment.initialize ({  
                            "msg":response.getReturnValue(), 
                            "options": options, 
                            "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                        });
                       
                   });
                   $A.enqueueAction(action);
               }else{
                   var action = component.get("c.getBillDeskData");
                   var details ={};
                   details['bookingId'] = component.get("v.BookingData.BookingId");
                   details['TypeOfAmount']='Normal';
                   details['OpportunityId'] = component.get("v.BookingData.opportunityId");
                   
                   details['towerId'] = component.get("v.BookingData.TowerId");
                   details['Amount'] = component.get("v.BookingData.TotalAmountPaid");
                   details['ProjectUnit'] = component.get("v.BookingData.unitNo");
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
                           //changes done by Srinivas on 15/07/21
                           component.set("v.Spinner",false);
                           
                           //ends
                           bdPayment.initialize ({  
                               "msg":response.getReturnValue(), 
                               "options": options, 
                               "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                           });
                       }             
                       
                       
                   });
                   
                   $A.enqueueAction(action);
               }
           }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Please read Terms and Conditions by clicking on below link.",
            "type":'error'
        });
        toastEvent.fire();
        }
    },
    showSuccessMessage :function( component, event, helper ) {
     
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success!",
        "message": "Payment is successful.Payment details will be updated on portal in 2 days.",
        "type":'success'
    });
    toastEvent.fire();
        
        window.setTimeout(
    $A.getCallback(function() {
        window.open('https://customer.runwalgroup.in/s/customerledger','_top');
    }), 5000
);
   
    },
     showFailureMessage :function( component, event, helper ) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Error!",
        "message": "Payment is Failed.",
        "type":'error'
    });
    toastEvent.fire();
         
         window.setTimeout(
    $A.getCallback(function() {
        window.open('https://customer.runwalgroup.in/s/customerledger','_top');
    }), 5000
);
    },
    
   payGstAmount : function( component, event, helper ) 
    { //invoking spinner on click event
        if(component.get('v.hasreadTC'))
           {
        component.set("v.Spinner",true);
        /*var action = component.get("c.getBillDeskData");  //Commented by Vinay 02-05-2025
        var details ={};
details['bookingId'] = component.get("v.BookingData.BookingId");
            
             details['OpportunityId'] = component.get("v.BookingData.opportunityId");
             details['TypeOfAmount']='GST';
        details['towerId'] = component.get("v.BookingData.TowerId");
        details['Amount'] = component.get("v.BookingData.TotalGSTPaid");
        details['ProjectUnit'] = component.get("v.BookingData.unitNo");
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
                        //changes done by Srinivas on 15/07/21
                        component.set("v.Spinner",false);
                        
                        //ends
                             bdPayment.initialize ({  
                            "msg":response.getReturnValue(), 
                            "options": options, 
                                "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                         });
    				}             
                   
                    
		});
        $A.enqueueAction(action); */
               if(component.get("v.BookingData.ProjectName") == '7 Mahalaxmi'){ //Added by Vinay 02-05-2025
                   console.log('payAmount2');
                   var action = component.get("c.paymentForMahalaxmi");
                   var details ={};
                   details['bookingId'] = component.get("v.BookingData.BookingId");
                   details['TypeOfAmount']='Normal';
                   details['OpportunityId'] = component.get("v.BookingData.opportunityId");
                   details['towerId'] = component.get("v.BookingData.TowerId");
                   details['Amount'] = component.get("v.BookingData.TotalAmountPaid");
                   details['ProjectUnit'] = component.get("v.BookingData.unitNo");
                   action.setParams({     
                       "DetailMap": details 
                   }); 
                   console.log('payAmount3');
                   action.setCallback(this, function(response) {
                       var state = response.getState();
                       console.log('state: ' + state);
                       console.log('Response: ' + response.getReturnValue());
                       if (state === "SUCCESS") {
                           console.log('Response: ' + response.getReturnValue());
                           component.set("v.htmlCode", response.getReturnValue());
                           //component.set("v.htmlCode", "<html><head></head><body>	Testing HTML</body></html>");
                           component.set("v.Spinner",false);
                       }
                       console.log('htmlCode: '+ component.get("v.htmlCode"));
                       console.log('current url: ', window.location.pathname);
                       
                       
                   });
                   $A.enqueueAction(action);
               }else{
                   var action = component.get("c.getBillDeskData");  
                   var details ={};
                   details['bookingId'] = component.get("v.BookingData.BookingId");
                   
                   details['OpportunityId'] = component.get("v.BookingData.opportunityId");
                   details['TypeOfAmount']='GST';
                   details['towerId'] = component.get("v.BookingData.TowerId");
                   details['Amount'] = component.get("v.BookingData.TotalGSTPaid");
                   details['ProjectUnit'] = component.get("v.BookingData.unitNo");
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
                           //changes done by Srinivas on 15/07/21
                           component.set("v.Spinner",false);
                           
                           //ends
                           bdPayment.initialize ({  
                               "msg":response.getReturnValue(), 
                               "options": options, 
                               "callbackUrl": "https://customer.runwalgroup.in/s/customerledger" 
                           });
                       }             
                       
                       
                   });
                   $A.enqueueAction(action);
               }
    }
    else
    {
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Please read Terms and Conditions by clicking on below link.",
            "type":'error'
        });
        toastEvent.fire();
	}
    },
    
     redirectToTCPage :function(component, event, helper)
    {
         component.set("v.hasreadTC",true);
         window.open("https://runwalgroup.in/terms&conditions.php");
      /*  component.set("v.hasreadTC",true);
       let navService = component.find("navService");

        // Sets the route to [Org url]/[Community uri]/[pageName]
        let pageReference = {
            type: "comm__namedPage", // community page. See https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm
            attributes: {
                pageName: 'billdesktermsandcondtitons' // pageName must be lower case
            }
            ,
            state: {
            }
            
        }
        
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageReference).then(handleUrl, handleError);
        //navService.navigate(pageReference); */
    }
  

})