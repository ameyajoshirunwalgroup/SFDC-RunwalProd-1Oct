({
	doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pageTransfer' );  
        component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).appdetails );  
         component.set( "v.selectedTabBookingId", JSON.parse( resultMsg ).bookingId); 
          
    }  ,
    
    downloadfile : function( component, event, helper ) 
    {  component.set("v.isOpen", true);
		var action = component.get("c.getIntertestLedgerPDF");
         action.setParams({     
            "customerNumber": event.getSource().get("v.name").customerNumber,
             "companycode":event.getSource().get("v.name").companyCode
            //"customerNumber":'0020000413',
             //"companycode":'1000'
        });  

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        
                        var pdfjsframe = component.find('pdfFrame');
                        pdfjsframe.getElement().contentWindow.postMessage(response.getReturnValue(),'*');
                        
                      /*  event.preventDefault();  
                        var navService = component.find( "navService" );  
                        var pageReference = {  
                            type: "comm__namedPage",  
                            attributes: {  
                                pageName: "pdf"  
                            },  
                            state: {  
                                pdfdata:response.getReturnValue()
                            }  
                        };  
                        sessionStorage.setItem('pdfpageTransfer', JSON.stringify(pageReference.state));  */
                      /*  
                        const handleUrl = (url) => {
                        window.open(url);
                    };
                    const handleError = (error) => {
                        console.log(error);
                    };*/
        				//navService.generateUrl(pageReference).then(handleUrl, handleError);
                        //navService.navigate(pageReference);
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
    }
})