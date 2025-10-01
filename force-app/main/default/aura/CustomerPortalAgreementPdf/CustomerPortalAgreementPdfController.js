({
    doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pdfpageTransfer' ); 
        component.set( "v.pdfdata",JSON.parse( resultMsg ).pdfdata);
        component.set( "v.bookingId",JSON.parse( resultMsg ).bookingId);
        component.set( "v.agreementStatus",JSON.parse( resultMsg ).agreementStatus);
        if( component.get( "v.agreementStatus") == 'Approved')
        {
            component.set("v.enableButtons",false);
            component.set("v.enablereasonSection",false);
        }
        
        //component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).appdetails );  
        // component.set( "v.selectedTabBookingId", JSON.parse( resultMsg ).bookingId); 
          
    } ,
    
	loadpdf : function(component, event, helper) {
		helper.loadpdf(component,event);
	},
    
    onapproveAgreement: function( component, event, helper ) 
    {  
        var action = component.get("c.approveAgreement");
        action.setParams({ "BookingId":component.get("v.bookingId")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "SUCCESS!",
                                        "type":"success",
                                        "message": "Agreement document is approved."});
                                    toastEvent.fire();
                
                                   component.set("v.enableButtons",false);
                                   var jsonobject = {
                                    state: {  
                                        		pdfdata:component.get("v.pdfdata"),
                                				bookingId : component.get("v.bookingId"),
                                				agreementStatus:'Approved'

                                           } 
                                     };
        			sessionStorage.setItem('pdfpageTransfer', JSON.stringify(jsonobject.state));
                               }
                           });
        
         $A.enqueueAction(action);
    },
    
    onrejectSubmit: function( component, event, helper ) 
    {  
        var action = component.get("c.rejectAgreement");
        action.setParams({ "BookingId":component.get("v.bookingId"),"RejectionReason":component.get("v.rejectionreason")});
        //action.setParams({ "RejectionReason":component.get("v.rejectionreason")});
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   component.set("v.enableButtons",true);
                                   var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "SUCCESS!",
                                        "type":"success",
                                       	"message": "Rejection with reason is submitted.Relationship Manager will check and revert"});
                                    toastEvent.fire();
                                   
                                   component.set("v.enableButtons",false);
                                    component.set("v.enablereasonSection",false);
                               }
                           });
        
         $A.enqueueAction(action);
    },
    
    onrejectAgreement:function( component, event, helper ) 
    {  
        component.set("v.enablereasonSection",true);
    },
    
    oncancel:function( component, event, helper ) 
    {  
    	component.set("v.enablereasonSection",false);
	}
})