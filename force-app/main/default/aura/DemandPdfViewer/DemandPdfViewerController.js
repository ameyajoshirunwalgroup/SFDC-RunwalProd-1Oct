({
    doInit : function(component, event, helper){
        var action = component.get("c.getdemandPdf");
        
        action.setParams({ "recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State?  ' + state);
            if (state === "SUCCESS") {
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));
                
                component.set("v.demandNumber",responsevalues.RW_Billing_Document_Number__c);
                debugger;
                var pdfjsframe = component.find('pdfFrame');
                var pdfData = response.getReturnValue();
                if(typeof pdfData != 'undefined'){
                    pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
                    component.set("v.pdfData",pdfData);
                }
                
                
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    sendMail: function (component, event, helper) {
        
        debugger;
        var pdfData = component.get("v.pdfData");
        console.log('Data in the PDf' + pdfData);
        var action = component.get("c.sendDemandEmail");
        component.set("v.showSpinner", true);
        action.setParams({ "recordId": component.get("v.recordId"),
                          "pdfdata" : pdfData
                         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                component.set("v.showSpinner", false);
                var responsevalues = response.getReturnValue();
                
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    "type": 'success',
                    "title": "Success!",
                    "message": "Demand Letter has been sent to Customer successfully."
                });
                toastEvent.fire();
                
                
            }
            
            else
            {
                component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({	
                    
                    "type": 'error',
                    "title": "Error!",
                    "message": "There was an error sending email to customer. Please try again later."
                });
                toastEvent.fire();
            }
            $A. get("e. force:closeQuickAction");
        });
        $A.enqueueAction(action);
    },
})