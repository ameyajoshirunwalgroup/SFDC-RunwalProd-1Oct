({
	doInit : function(component,  event, helper)
    {  
        var opprecordId = component.get("v.recordId");
		var action = component.get("c.getTowersOfProject");
        action.setParams({ "recordId" : opprecordId });
        action.setCallback(this, function(response) 
         {
            var state = response.getState();
             var towerNames = [];
             if (state === "SUCCESS") 
             {
                 
                        var conts = response.getReturnValue();
                        for(var key in conts)
                        {
                        towerNames.push({value:conts[key], key:key}  );
                        }
                        
                 
                 component.set("v.towerNames" , towerNames);
                 
                /* var action1 = component.get("c.getOffersForProject");
                 action1.setParams({ "OpprecId" : opprecordId , "offerType" : "EOI" });
                action1.setCallback(this, function(response) 
                 {
                    var state = response.getState();
                    var custs = [];
                    var conts = response.getReturnValue();
                    for(var key in conts){
                        custs.push({value:conts[key], key:key});
                    }
                     
                     
                    component.set("v.offers",custs); 
                     
                 });
                  $A.enqueueAction(action1);
                  */
             }
         });
        $A.enqueueAction(action);
        
        
    },
    
    sendEOIFormLink : function(component,  event, helper)
    {
        if(component.get("v.towerId") == '' || component.get("v.towerId") == undefined)
        {
             //component.set("v.errorMessage", response.getError()[0].message);
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                 "title": "ERROR!",
                 "type":"error",
                 "message": 'Please select the tower before sending EOI Link'
                  });
                  toastEvent.fire();
        }
        
        else if((component.get("v.offerName") != null && component.get("v.offerName") != undefined && component.get("v.offerName") != '')
                
                && (component.get("v.subofferName") == undefined || component.get("v.subofferName") == null || component.get("v.subofferName") == ''))
        {
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                 "title": "ERROR!",
                 "type":"error",
                 "message": 'Please select the sub offer if offer is selected'
                  });
                  toastEvent.fire();
                  return;
        }
        /* bkk */
        else if(component.get("v.PaymentGateway") == ""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": 'Please select the Payment Gateway before sending EOI Link'
            });
            toastEvent.fire();
        }
        
        else
        {
        var recordId = component.get("v.recordId");
        var amount = component.get("v.Amount");
		var action = component.get("c.sendEOILink");
        var details ={};
        
        details['offerName'] = component.get("v.offerName");
        details['subofferName'] = component.get("v.subofferName");
        
            action.setParams({ opprecordId : recordId , Amount : amount , towerId : component.get("v.towerId"), offerDetails: details, paymentGateway: component.get("v.PaymentGateway")});
                          
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") 
                          {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
				component.set("v.isSuccess", true);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                 "title": "SUCCESS!",
                 "type":"success",
                 "message": "Digital Link is sent to the customer successfully"
                  });
                  toastEvent.fire();
                // $A.get('e.force:refreshView').fire();
                 
                  $A.get("e.force:closeQuickAction").fire();
                              $A.get('e.force:refreshView').fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
             
             else if(state === 'ERROR')
             {
                 //component.set("v.isSuccess", false);
                 
                 component.set("v.errorMessage", response.getError()[0].message);
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                 "title": "ERROR!",
                 "type":"error",
                 "message": component.get("v.errorMessage")
                  });
                  toastEvent.fire();

               
            }
    });
        $A.enqueueAction(action);
        }
    },
    
    getSuboffers:  function(component,  event, helper)
    {
        var offerMap = component.get('v.offers');
        var suboff = [];
        for(var i=0 ; i<offerMap.length ; i++)
        {
            if(offerMap[i].key == component.get('v.offerName') )
            {
                for(var j =0; j<offerMap[i].value.length; j++)
                {
                    suboff.push(offerMap[i].value[j]);
                }
                //suboff.push({key:offerMap[i].key, value : offerMap[i].value});
                
            }
        }
        
        component.set("v.suboffer",suboff);
        
       
    },
    
    getOffers :  function(component,  event, helper)
    {
                var action1 = component.get("c.getOffersForTower");
                action1.setParams({ "towerId" : component.get("v.towerId") , "offerType" : "EOI" });
                action1.setCallback(this, function(response) 
                 {
                    var state = response.getState();
                    var custs = [];
                    var conts = response.getReturnValue();
                    for(var key in conts){
                        custs.push({value:conts[key], key:key});
                    }
                     
                     
                    component.set("v.offers",custs); 
                     
                 });
                  $A.enqueueAction(action1);
    }
    
  })