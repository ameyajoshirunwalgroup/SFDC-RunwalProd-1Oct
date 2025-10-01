({
    doInit : function( component, event, helper ) {  
        
        var resultMsg = sessionStorage.getItem( 'pageTransfer' );  
        component.set( "v.receipt", JSON.parse( resultMsg ).receiptdet );  
        component.set( "v.bookingId", JSON.parse( resultMsg ).bookingId);
        console.log("v.receipt" + component.get("v.receipt"));
        
    },
    
    receiptAsPdf:function( component, event, helper ) { 
        
        debugger;
            component.set("v.isOpen", true);
        var action = component.get("c.getreceiptPdf");
        
        action.setParams({ "recordId" : event.getSource().get("v.name")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State?  ' + state);
            if (state === "SUCCESS") {
            
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));               
                
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
    
    callContactUs: function(component, event, helper) {
        debugger;
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "contactus"  
            }
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
})