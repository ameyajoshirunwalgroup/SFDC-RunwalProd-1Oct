({
	doInit: function(component, event, helper) 
    {
        		var url = $A.get('$Resource.BookingImage1');
        	    component.set('v.backgroundImageURL', url);
        component.set('v.backgroundColor', 'Red');
        
		 		var action = component.get("c.getPortalHomeData");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
					}
                });
        $A.enqueueAction(action); 
    },
    
    openEOIForm: function(component, event, helper) 
    {
       /* console.log(event.getSource().get("v.name"));
        let pageReference = {
            type: 'standard__webPage',
            attributes: {
                url:event.getSource().get("v.name").domainURL+'/apex/CustomerPortalEOIForm?eoiId='+event.getSource().get("v.name").encryptedeoiRecordId
                //url: 'https://runwal--prodsb.lightning.force.com/apex/CustomerEOIForm?eoiId='+event.getSource().get("v.name")
            },

        };
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                console.log(url);
                navService.navigate(pageReference);


            }), $A.getCallback(function(error) {
                console.log(error); 
            }));
        
        */
        
        
        component.set("v.isOpen", true);
        var action = component.get("c.getEOIPdf");
        
        action.setParams({ "encryptedEoiRecordId" : event.getSource().get("v.name").eoiId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));
                var pdfjsframe = component.find('pdfFrame');
                var pdfData = response.getReturnValue();
                if(typeof pdfData != 'undefined'){
                    pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	

                }
                
                
                
                
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
        $A.enqueueAction(action);
        
        /*var message = event.getSource().get("v.name").encryptedeoiRecordId;
        var vfOrigin = 'https://runwal--prodsb--c.visualforce.com';
        
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, vfOrigin);*/
    },
    
     openBookingForm: function(component, event, helper) 
    {
        /*console.log(event.getSource().get("v.name"));
        let pageReference = {
            type: 'standard__webPage',
            attributes: {
                url:event.getSource().get("v.name").domainURL+'/apex/CustomerPortalBookingForm?id='+event.getSource().get("v.name").encryptedBookingId
                //url: 'https://runwal--prodsb.lightning.force.com/apex/CustomerEOIForm?eoiId='+event.getSource().get("v.name")
            },

        };
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                console.log(url);
                navService.navigate(pageReference);


            }), $A.getCallback(function(error) {
                console.log(error); 
            }));*/
        
        
         component.set("v.isOpen", true);
        var action = component.get("c.getBookingPdf");
        
        action.setParams({ "encryptedBookingRecordId" : event.getSource().get("v.name").BookingId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responsevalues = response.getReturnValue();
                console.log( 'Data - ' +  JSON.stringify(response.getReturnValue()));
                var pdfjsframe = component.find('pdfFrame');
                var pdfData = response.getReturnValue();
                if(typeof pdfData != 'undefined'){
                    pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	

                }
                
                
                
                
            }else if(state === "ERROR"){
                alert('Problem with connection. Please try again.');
            }
        });
        $A.enqueueAction(action);
    },
    
    openApplicantDetails: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "applicantdetails"  
            },  
            state: {  
                appdetails:component.get('v.RunwalHomeWrapList'), 
                bookingId:event.getSource().get("v.name")
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
    
   opensurveys: function(component, event, helper) 
    {
        var urlVal;
         if(event.getSource().get("v.name").possessionlinkId != undefined)
                {
                    //urlVal =event.getSource().get("v.name").domainURL+'/apex/CustomerPortalPossesionSurvey?sid='+event.getSource().get("v.name").possessionlinkId;
                    urlVal =event.getSource().get("v.name").sitelink+'/PossessionPage?sid='+event.getSource().get("v.name").possessionlinkId;
                	//url:event.getSource().get("v.name").sitelink+'/SurveyPage?sid='+event.getSource().get("v.name").possessionlinkId;
            	}
            	else if(event.getSource().get("v.name").bookinglinkId != undefined)
                {
                    //urlVal = event.getSource().get("v.name").domainURL+'/apex/BookingSurveyPage?sid='+event.getSource().get("v.name").bookinglinkId;
                	urlVal =event.getSource().get("v.name").sitelink+'/BookingSurveyPage?sid='+event.getSource().get("v.name").bookinglinkId;
                    //url:event.getSource().get("v.name").sitelink+'/SurveyPage?sid='+event.getSource().get("v.name").bookinglinkId;
            	}
        console.log(event.getSource().get("v.name"));
        if(urlVal == undefined || urlVal == null)
        {
            var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Information!",
        "type": "info",
        "message": "The feedback form is currently not available. Please check later."
    });
    toastEvent.fire();
            return;
        }
        
        else
        {
        let pageReference = {
            type: 'standard__webPage',
            attributes: {
               
                //url:event.getSource().get("v.name").domainURL+'/apex/CustomerPortalSurvey?sid='+event.getSource().get("v.name").surveylinkId
                //url:urlVal
                 url:urlVal
                //url:event.getSource().get("v.name").domainURL+'/apex/CustomerPortalPossesionSurvey?sid='+event.getSource().get("v.name").surveylinkId
                //url: 'https://runwal--prodsb.lightning.force.com/apex/CustomerEOIForm?eoiId='+event.getSource().get("v.name")
            },
        
        };
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                console.log(url);
                navService.navigate(pageReference);


            }), $A.getCallback(function(error) {
                console.log(error); 
            }));
        }
        
       /*  event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "survey"  
            },  
            state: {  
                sid:event.getSource().get("v.name").surveylinkId
            }  
        };  
        //sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);*/
    },
    
    openagreement: function(component, event, helper)
    {
        component.set("v.Spinner",true);
        var action = component.get("c.getAgreementPDF");
         action.setParams({     
            "salesorderNumber": event.getSource().get("v.name").salesorderNumber,
             //"salesorderNumber": '3010003697',
            //"customerNumber":'002000413',
             //"companycode":'2000'
        });  

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                         component.set("v.Spinner",false);
                        event.preventDefault();  
                        var navService = component.find( "navService" );  
                        var pageReference = {  
                            type: "comm__namedPage",  
                            attributes: {  
                                pageName: "agreementpdf"  
                            },  
                            state: {  
                                pdfdata:response.getReturnValue(),
                                bookingId : event.getSource().get("v.name").BookingId,
                                agreementStatus:event.getSource().get("v.name").agreementStatus
                            }  
                        };  
                        sessionStorage.setItem('pdfpageTransfer', JSON.stringify(pageReference.state));  
                        navService.navigate(pageReference);
                        //var pdfjsframe = component.find('pdfFrame');
                        //pdfjsframe.getElement().contentWindow.postMessage(response.getReturnValue(),'*');
                        //component.set("v.pdfValue",response.getReturnValue());
                        
					}
                    
                    else
                    {
                         component.set("v.Spinner",false);
                        /* component.set("v.Spinner",false);
                         event.preventDefault();  
                        var navService = component.find( "navService" );  
                        var pageReference = {  
                            type: "comm__namedPage",  
                            attributes: {  
                                pageName: "agreementpdf"  
                            },  
                            state: {  
                                pdfdata:response.getReturnValue(),
                                bookingId : event.getSource().get("v.name").BookingId,
                                agreementStatus:event.getSource().get("v.name").agreementStatus
                            }  
                        };  
                        sessionStorage.setItem('pdfpageTransfer', JSON.stringify(pageReference.state));  
                        navService.navigate(pageReference); */
                    }
                });
        $A.enqueueAction(action);
    },
    
    opensignedagreement:function(component, event, helper)
    {

    			$A.get('e.lightning:openFiles').fire({ 
                     recordIds: [event.getSource().get('v.name')]
                 }); 
         
    },
    
    
      closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    
    
})