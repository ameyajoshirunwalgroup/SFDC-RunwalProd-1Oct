({
    doInit : function(component, event, helper){
        var action = component.get("c.getinttLedgerPdf");
        
        action.setParams({ "recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State?  ' + state);
            if (state === "SUCCESS") {
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));
              
              //  component.set("v.CustomerNumber",responsevalues.Opportunity__r.SAP_Customer_Number__c);
              //  component.set("v.CompanyCode",responsevalues.Project__r.RW_SAP_Company_Code__c);
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