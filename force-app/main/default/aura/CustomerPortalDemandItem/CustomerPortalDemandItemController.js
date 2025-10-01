({
    doInit : function(component, event, helper) {
        
        /* var action=component.get('c.getPortalHomeData');
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state ='+state);
            if (component.isValid() && state === "SUCCESS") {
               

                component.set("v.dem", response.getReturnValue());
                console.log('v.dem='+JSON.stringify(response.getReturnValue()));
              }
        });$A.enqueueAction(action);
        
        
*/      
            console.log("v.dem" + component.get("v.dem"));
        },
    
    sectionOne : function(component, event, helper) {
        helper.helperFun(component,event,'articleOne');
        debugger;
    },
    
    onAccordionClick: function(component, event, helper) {
        component.set("v.expanded",true);
    },
    
    callReceipts:function(component, event, helper) {
        debugger;
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "receiptdetails"  
            },  
            state: {  
                receiptdet:component.get('v.receipt'), 
                bookingId:event.getSource().get("v.name")
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
    
    callPdfViewer:function(component, event, helper) {
        debugger;
        component.set("v.isOpen", true);
        var action = component.get("c.getdemandPdf");
        
        action.setParams({ "recordId" : event.getSource().get("v.name")});
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
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    toggle: function(component, event, helper) {
        var items = component.get("v.dem"), index = event.getSource().get("v.value");
        items[index].expanded = !items[index].expanded;
        component.set("v.dem", dem);
    }
})