({
    doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pdfpageTransfer' ); 
        component.set( "v.pdfdata",JSON.parse( resultMsg ).pdfdata);
        
        //component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).appdetails );  
        // component.set( "v.selectedTabBookingId", JSON.parse( resultMsg ).bookingId); 
          
    } ,
    
	loadpdf : function(component, event, helper) {
		helper.loadpdf(component,event);
	}
})