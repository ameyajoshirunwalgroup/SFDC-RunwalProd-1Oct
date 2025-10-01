({
	doInit: function(component, event, helper) 
    {
        		var url = $A.get('$Resource.CustomerPortalAccount');
        		component.set('v.backgroundImageURL', url);
		 		var action = component.get("c.getPortalHomeData");
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        //component.set("v.RunwalHomeWrap",response.getReturnValue());
                        component.set("v.RunwalHomeWrapList",response.getReturnValue());
                        for(var i=0; i<component.get("v.RunwalHomeWrapList").length;i++)
                        {
                            if(component.get("v.RunwalHomeWrapList")[i].loanWrapperList.length >0)
                            {
                                component.set("v.sanctionLettersAvailable",true);
                            }
                        }
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
    
    openInterestLedger: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "interestledger"  
            },  
            state: {  
                appdetails:component.get('v.RunwalHomeWrapList'), 
                bookingId:event.getSource().get("v.name")
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
    
    openKYCDetails: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "kycdetails"  
            },  
            state: {  
                bookingdetails: event.getSource().get("v.name")
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
    
    handleApplicationEventFired: function(component, event, helper) 
    {
        sessionStorage.setItem('pageTransfer', component.get('v.RunwalHomeWrapList'));
    },
    
    openreferralScreen:function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );
         var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "referrals"  
            } 
            
        };  
          
        navService.navigate(pageReference);
    },
    
    openSanctionLetters: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "sanctiondetails"  
            },  
            state: {  
                bookingdetails:component.get('v.RunwalHomeWrapList'), 
                
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
    
        openHomeLoan: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "homeloan"  
            },  
            state: {  
                bookingdetails:component.get('v.RunwalHomeWrapList'), 
                
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },

    
    openTDSDetails: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "tds"  
            },  
            state: {  
                bookingdetails:component.get('v.RunwalHomeWrapList'), 
                
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    },
    
     openNCFForm: function(component, event, helper) 
    {
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "ncf"  
            },  
            state: {  
                bookingdetails:component.get('v.RunwalHomeWrapList'), 
                
            }  
        };  
        sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
        navService.navigate(pageReference);
    }
    
})