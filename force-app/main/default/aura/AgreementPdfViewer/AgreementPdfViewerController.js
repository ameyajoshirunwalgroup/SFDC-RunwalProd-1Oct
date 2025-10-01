({
	doInit : function(component, event, helper){
        console.log('agreementPdf');
        console.log('Spinner', component.get("v.Spinner"));
        var action = component.get("c.agreement");
        
        action.setParams({ "recordId" : component.get("v.recordId")});
        console.log('Spinner', component.get("v.Spinner"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State?  ' + state);
            if (state === "SUCCESS") {
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));
                //var pdfjsframe = component.find('pdfFrame');
                var pdfData = response.getReturnValue();
                component.set("v.pdfData",pdfData);
                component.set("v.Spinner",false);
                window.open(pdfData, "_self");
                /*if(typeof pdfData != 'undefined'){
                    pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
                      component.set("v.pdfData",pdfData);
                }*/
            }else if(state === "ERROR"){
                //alert('Problem with connection. Please try again.');
                alert(response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})