({
    doInit : function(component, event, helper){
        var action = component.get("c.getCustLedgerPdf");
        
        action.setParams({ "recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State?  ' + state);
            if (state === "SUCCESS") {
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));
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
    }
})