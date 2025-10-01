({
    doInit : function(component,  event, helper)
    {  
        var opprecordId = component.get("v.recordId");
        var action = component.get("c.getQuotationMap");
        var quotationList = [];
        var towerMap = new Map();
        
        action.setParams({ "recordId" : opprecordId });
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               var towerNames = [];
                               if (state === "SUCCESS") 
                               {
                                   debugger;
                                   var  quotation = response.getReturnValue().quotationIdNameMap;
                                   component.set("v.isError",response.getReturnValue().isError);
                                   component.set("v.errorMsgs",response.getReturnValue().errors);
                                   for (var key in quotation) {
                                       if (quotation.hasOwnProperty(key)) {
                                           quotationList.push({value: key, label: quotation[key].Name});
                                           towerMap.set(key,quotation[key].Project_Unit__r.TowerName__c);
                                       }
                                   };
                                   var projectCarParkMap =  response.getReturnValue().AvailParking;
                                   component.set("v.projectCarParkMap",projectCarParkMap);
                                   component.set("v.quotationList",quotationList);
                                   component.set("v.quotationTowerMap",towerMap);
                                   component.set("v.quotationMap",quotation);
                                   if(Object.keys(quotation).length == 0){
                                       component.set("v.isQuotationTagged" ,false);
                                   }
                                   debugger;
                               }
                           });
        $A.enqueueAction(action);
        
    },
    
    sendBookingFormLink : function(component,  event, helper)
    {
        var recordId = component.get("v.recordId");
        var amount = component.get("v.Amount");
        component.set("v.disable",true);
        var quotationid = component.get("v.quotationId");
        var quotationMap =component.get("v.quotationMap");
        var projectMap = component.get("v.projectCarParkMap");
        var quote = quotationMap[quotationid];
        var availCarPark =projectMap[quote.Project__r.Name];
        var quoteerror = false;
        var errormsg = '';debugger;
        if(quote.Project_Unit__r.RW_Unit_Status__c == 'Booked'){
            errormsg='The project unit of the selected quotation is not available';
            quoteerror = true;	      
            
        }else if(quote.Payment_Plan_Modified__c && !(quote.Quote_Status__c == 'Valid')){
            errormsg='The modified quotation needs to be approved by site head before sending the quotation to customer';
            quoteerror = true;	      
            
        }else if(availCarPark['Tandem Covered'] == 0 && quote.Tandem_car_park_Additional__c >0 && availCarPark['Tandem Covered'] <quote.Tandem_car_park_Additional__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['Tandem Open'] == 0 && quote.Tandem_Open_Additional__c >0 && availCarPark['Tandem Open'] <quote.Tandem_Open_Additional__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['Single Open'] == 0 && quote.Single_Open_Additional__c >0 && availCarPark['Single Open'] <quote.Single_Open_Additional__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['Single Covered'] == 0 && quote.Single_car_park_Additional__c >0 && availCarPark['Single Covered'] <quote.Single_car_park_Additional__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['Stilt'] == 0 && quote.Stack_Additional__c >0 && availCarPark['Stilt'] <quote.Stack_Additional__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['MLCP'] == 0 && quote.MLCP_Additional__c >0 && availCarPark['MLCP'] <quote.MLCP_Additional__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['Podium'] == 0 && quote.Podium__c >0 && availCarPark['Podium'] <quote.Podium__c ){
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }else if(availCarPark['Puzzle Car Park'] == 0 && quote.Puzzle_Car_Park__c >0 && availCarPark['Puzzle Car Park'] <quote.Puzzle_Car_Park__c ){ //Added by Vinay 28-03-2025
            errormsg = 'The selected car park type has be exhausted';
            quoteerror = true;	      
        }
        
        if(component.get("v.offerName") != "" && component.get("v.subofferName") == ""){
            errormsg = 'You have selected the offer but not selected the suboffer, Please remove either the offer or select the suboffer';
            quoteerror = true;	 
            
        }
        if(quote.Quote_Status__c != 'Valid'){
            errormsg = 'Quotation should be approved before sending the digital booking link';
             quoteerror = true;	
        }
        if(quoteerror){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": errormsg
            });
            toastEvent.fire();
            component.set("v.disable",false);
            
        }
        //PrathamNadig
            if(component.get("v.PaymentGateway") == ""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": 'Please select the Payment Gateway before sending Booking Link'
            });
            toastEvent.fire();
        }
        //PrathamNadig
        else{
            component.set("v.disable",true);
                        component.set("v.Spinner",true);

            debugger;
            var details ={};         
            if(component.get("v.offerName") != "" && component.get("v.subofferName") != ""){
                details['offerName'] = component.get("v.offerName");
                details['subofferName'] = component.get("v.subofferName");}
            var action = component.get("c.sendBookingLink");
            
            action.setParams({ opprecordId : recordId , Amount : amount ,  offerDetails: details,quotationId:quotationid, PaymentGateway: component.get("v.PaymentGateway") });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") 
                {
                    // Alert the user with the value returned 
                    // from the server
                    //alert("From server: " + response.getReturnValue());
                    component.set("v.isSuccess", true);
                                            component.set("v.Spinner",false);

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
                                                               component.set("v.Spinner",false);
 
                    component.set("v.errorMessage", response.getError()[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "type":"error",
                        "message": component.get("v.errorMessage")
                    });
                    toastEvent.fire();
                    component.set("v.disable",false	);
                    
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getOffers:  function(component,  event, helper)
    {
        var towerMap=    component.get("v.quotationTowerMap");
        debugger;
        var towerId = towerMap.get(component.get("v.quotationId"));
        var action1 = component.get("c.getOffersForTower");
        action1.setParams({ "towerId" : towerId , "offerType" : "Booking" });
        debugger;     
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
        
        
    }  
    
     /*,
    
    afterScriptsLoaded : function(component, event, helper) {
    
	},
     redirectToBillDesk : function(component, event, helper) {
       bdPayment.initialize ({  
"msg":"BDSKUATY|123456|NA|100.00|XYZ|NA|NA|INR|DIRECT|R|bdskuaty|NA|NA|F|john@doe1.com|9820198201|NA|NA|NA|NA|NA|NA|DEFD74172756EC27C8E15FF151B7E3DA4E7C505ADAA93D25F0136F6739A37503", 
"options": { 
        "enableChildWindowPosting": true, 
        "enablePaymentRetry": true, 
        "retry_attempt_count": 2, 
        "txtPayCategory": "NETBANKING" 
    }, 
    "callbackUrl": "https://www.merchant-domain.com/payment_response.jsp" 
}); 
	} */
})