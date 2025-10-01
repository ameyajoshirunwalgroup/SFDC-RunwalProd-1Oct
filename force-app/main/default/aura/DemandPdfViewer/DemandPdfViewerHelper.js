({
	loadpdf:function(component,event){
          var action = component.get("c.getdemandPdf");
		  action.setParams({  
            "demandNumber": component.get("v.demandNumber") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();debugger;
            if (state === "SUCCESS") {debugger;
                var pdfjsframe = component.find('pdfFrame');
                var pdfData = response.getReturnValue();
                if(typeof pdfData != 'undefined'){
				pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
                }
                component.set("v.pdfData",pdfData);
            }
        
        });
          $A.enqueueAction(action);	
	}
})