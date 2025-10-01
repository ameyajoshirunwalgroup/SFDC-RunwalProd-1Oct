({
	doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pageTransfer' );  
        component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).bookingdetails );  
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length >0)
                            {
                                        component.set("v.HasPreviousTDSCertificate",true);
                                        
                             }
                                
                            }
                        } 
          
     ,
    
    previewfile :   function(component, event, helper) {
    $A.get('e.lightning:openFiles').fire({ 
                     recordIds: [event.getSource().get('v.name')]
                 }); 
    },
    
    uploadTDSDocument :   function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files"); 
        var details ={};
        component.set('v.uploadedTDSDocumentID',uploadedFiles[0].documentId);
        
         
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
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
                        var jsonobject = {
            			state: {  
                                    bookingdetails: component.get('v.RunwalHomeWrapList')
                                } 
                         };
        			sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
					}
                });
        		$A.enqueueAction(action1); 
                
                
            }  
        });  
        $A.enqueueAction(action); 
	},
    
    onsubmitTDS :   function(component, event, helper) 
    {  
        var format = new RegExp('[0-9]+(\.[0-9][0-9]?)?');
        if(!format.test(component.get('v.tdsamount')))
        {
           var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
               "title": "ERROR!",
                "type":"error",
                "message": "Amount can only contain Numbers"
               });
             toastEvent.fire(); 
            return;
        }
        
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length >0)
                            {
                                        for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length;j++)
                                        {
                                             if(event.getSource().get('v.name').BookingId == component.get("v.RunwalHomeWrapList")[i].BookingId)
                                            {
                                                if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList[j].tdscertificateNumber == component.get('v.tdscertificateNumber'))
                                                   {
                                                   	var toastEvent = $A.get("e.force:showToast");
                                                 toastEvent.setParams({
                                                   "title": "ERROR!",
                                                    "type":"error",
                                                    "message": "Duplicate TDS Certificate Number is Entered. Please Check. "
                                                   });
                                                 toastEvent.fire(); 
                                                      
            									return;
                                                   }
                                            }
                                        }
                                        
                             }
                                
                            }
        
        var details ={};
        details['tdsdocumentId'] = component.get('v.uploadedTDSDocumentID');
        details['tdscertificateNumber'] = component.get('v.tdscertificateNumber');
        details['tdsamount'] = component.get('v.tdsamount');
        
        details['oppId'] = event.getSource().get('v.name').opportunityId;
           // component.find('oppId').get("v.value");
        details['bookingId'] = event.getSource().get('v.name').BookingId;
            
            //component.find('bookingId').get("v.value");
        
        var action = component.get("c.createTDSRecord");  
        action.setParams({     
            "DocDetails": details 
        });  
        
         action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS')
            {  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "SUCCCESS!",
                    "type":"success",
                    "message": "TDS Submitted Succesfully."});
                toastEvent.fire();
                
                component.set('v.uploadedTDSDocumentID','');
                component.set('v.tdscertificateNumber','');
                component.set('v.tdsamount','');
                var action1 = component.get("c.getPortalHomeData");
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
                        var jsonobject = {
            			state: {  
                                    bookingdetails: component.get('v.RunwalHomeWrapList')
                                } 
                         };
        			sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
                        var resultMsg =sessionStorage.getItem( 'pageTransfer' );
                    component.set( "v.RunwalHomeWrapList", JSON.parse( resultMsg ).bookingdetails );  
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length >0)
                            {
                                        component.set("v.HasPreviousTDSCertificate",true);
                             }
                                
                            }
					}
                });
        		$A.enqueueAction(action1); 
                
            }
         });
        
         $A.enqueueAction(action); 
    },
    
    onTabClick: function(component, event, helper) 
    {  
        console.log('**');
        component.set('v.uploadedTDSDocumentID','');
        component.set('v.tdscertificateNumber','');
        component.set('v.tdsamount','');
        component.set("v.HasPreviousTDSCertificate",false);
         for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length >0)
                            {
                                		if(event.getSource().get('v.id') == component.get("v.RunwalHomeWrapList")[i].BookingId)
                                        component.set("v.HasPreviousTDSCertificate",true);
                                        
                             }
                                
                            }
    },
    
    
    checkTDSNumber: function(component, event, helper) 
    { 
        var booleanValue = false;
        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length >0)
                            {
                                        for(var j=0; j<component.get("v.RunwalHomeWrapList")[i].tdsWrapperList.length;j++)
                                        {
                                             if(event.getSource().get('v.name').BookingId == component.get("v.RunwalHomeWrapList")[i].BookingId)
                                            {
                                                if(component.get("v.RunwalHomeWrapList")[i].tdsWrapperList[j].tdscertificateNumber == component.get('v.tdscertificateNumber'))
                                                   {
                                                    booleanValue = true;
                                                   	var toastEvent = $A.get("e.force:showToast");
                                                 toastEvent.setParams({
                                                   "title": "ERROR!",
                                                    "type":"error",
                                                    "message": "Duplicate TDS Certificate Number is Entered. Please Check. "
                                                   });
                                                 toastEvent.fire(); 
                                                      
            									//return;
                                                   }
                                            }
                                        }
                                        
                             }
                                
                            }
        
        component.set('v.duplicatecertificatenumber',booleanValue);
    }
    
    
})