({
	 doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pageTransfer' );  
        component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).appdetails );  
         component.set( "v.selectedTabBookingId", JSON.parse( resultMsg ).bookingId);
          
    }  
})