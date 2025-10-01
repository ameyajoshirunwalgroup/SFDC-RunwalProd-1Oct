({       
	doInit: function(component,event,helper) {
        
        console.log('********'+component.get("v.msg") );
        if(component.get("v.msg") != undefined && component.get("v.msg") !=null && component.get("v.msg") !=''){
            console.log('-----'+component.get("v.msg"));
            component.set("v.Spinner",true); 
            var action1 = component.get('c.saveBillDeskData'); 
            var details ={};
      
            details['msg'] = decodeURIComponent(component.get("v.msg"));
            details['towerId'] = component.get("v.towerId");
               console.log(details);
             action1.setParams({     
                 "DetailMap": details 
                 
            });
            action1.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS"){   
                    component.set("v.Spinner",false);                  
                 if(response.getReturnValue() == "Success"){
                     component.set("v.showSuccessMsg",true);
                     var action=component.get('c.showSuccessMessage');
                      $A.enqueueAction(action);
                      console.log('successful');
                 }   
                 else{   
                     component.set("v.showFailMsg",true);
                     var action=component.get('showFailureMessage');
                      $A.enqueueAction(action);  
                      console.log('failure');
                 }
                 component.set("v.Spinner",false);
                }
            });
            
            $A.enqueueAction(action1);                         
        }else{
            //var action = component.get("c.getBillDeskData");
            console.log('--msg--', component.get("v.msg"));
            var details ={};
            component.set("v.Spinner", true);
            var action = component.get("c.getBillDeskData");
            console.log('--BookingData--', component.get("v.BookingData"));
            console.log('--bookingId--', component.get("v.bookingId"));
            console.log('--OpportunityId--', component.get("v.OpportunityId"));
            
            details['bookingId'] = component.get("v.bookingId");
            details['TypeOfAmount']='Normal';
            details['OpportunityId'] = component.get("v.OpportunityId");
            details['towerId'] = component.get("v.towerId");
            details['Amount'] = component.get("v.Amount");
            details['ProjectUnit'] = component.get("v.ProjectUnit");
            details['TypeOfAmount'] = component.get("v.TypeOfAmount");
            
            console.log('--bookingId--', component.get("v.bookingId"));
            
            action.setParams({     
                 "DetailMap": details 
            });
            console.log('--DetailMap--', details);
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('--state--', state);
                console.log('--response.getError()--', response.getError());
                console.log('--response.getReturnValue()--', response.getReturnValue());
                if (state === "SUCCESS"){
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
                    let urlString = window.location.href;
                    
                    bdPayment.initialize ({
                        "msg":response.getReturnValue(), 
                        "options": options, 
                        "callbackUrl": urlString
                    });
                    console.log('component.get("v.msg") :', component.get("v.msg"));
                }
            });
            
            $A.enqueueAction(action);   
        }    
    },
    
    showSuccessMessage :function( component, event, helper ) {
        console.log('showSuccessMessage: ', showSuccessMessage);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Payment is successful.Payment details will be updated on portal in 2 days.",
            "type":'success'
        });
        toastEvent.fire();
        
        window.setTimeout(
            $A.getCallback(function() {
                window.open('https://uat-runwal.cs111.force.com/customer/s/customerledger','_top');
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
                    window.open('https://uat-runwal.cs111.force.com/customer/s/customerledger','_top');
                }), 5000
            );
    }
})