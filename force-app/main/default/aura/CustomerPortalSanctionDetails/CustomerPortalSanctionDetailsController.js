({
	doInit : function( component, event, helper ) {  
          
       /* var resultMsg = sessionStorage.getItem( 'pageTransfer' );  
        component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).bookingdetails );  
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].loanWrapperList.length >0)
                            {
                                for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].loanWrapperList.length;j++)
                                {
                                    if(component.get("v.RunwalHomeWrapList")[i].loanWrapperList[j].loanstatus=='Loan Closed')
                                    {
                                        
                                        component.set("v.HasPreviousLoanSanctionMap",true);
                                    }
                                }
                            }
                        } */
          
    } ,
    
    previewfile :   function(component, event, helper) {
    $A.get('e.lightning:openFiles').fire({ 
                     recordIds: [event.getSource().get('v.name')]
                 }); 
    },
    
    uploadDocument :   function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files"); 
        var details ={};
       
         
         
        details['documentId'] = uploadedFiles[0].documentId;
        details['loanId'] = event.getSource().get('v.name');
        
        var action = component.get("c.updateLoanRecord");  
        action.setParams({     
            "DocDetails": details 
        });  
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue(); 
                
                var action1 = component.get("c.getPortalHomeData");
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalWrapList",response.getReturnValue());
                        var jsonobject = {
            			state: {  
                               
                                   /*  bookingdetails: component.get('v.RunwalHomeWrapList')*/
                            bookingdetails: response.getReturnValue()
                                } 
                         };
        			sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
					}
                });
        		$A.enqueueAction(action1); 
                
                
            }  
        });  
        $A.enqueueAction(action); 
	}
})