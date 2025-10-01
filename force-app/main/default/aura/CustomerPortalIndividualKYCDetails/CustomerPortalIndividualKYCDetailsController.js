({
		 doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pageTransfer' );  
        component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).bookingdetails );  
          
    }  ,
    
     handleApplicationEventFired: function(component, event, helper) 
    {
        var jsonobject = {
            			state: {  
                                    bookingdetails: component.get('v.RunwalHomeWrapList')
                                } 
                         };
        sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
    }
})