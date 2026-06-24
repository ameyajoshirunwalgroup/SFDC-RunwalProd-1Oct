({
	retrieveBookingInformation: function(component, BookingID) {       
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}
        var action = component.get("c.getBookingInformation");
        action.setParams({
                "bookingId": BookingID
            });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue(); 
                component.set("v.bookingInfo", allValues);
                var reason = allValues.Cancellation_Reason__c;
                var depMap = component.get("v.parentChildMap");
                
                if (reason && depMap && depMap[reason]) {
                    component.set("v.subReasonOptions", depMap[reason]);
                }
                if(spinner) {
                    $A.util.removeClass(spinner,"slds-show");
                    $A.util.addClass(spinner, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    saveBookingCancellation:function(component , BookingID ){ 
        debugger;
        var spinner = component.find("mySpinner");
        if(spinner){
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
        }
        var bookingRec = component.get("v.bookingInfo");
        console.log('--saveBookingCancellation Booking---->',bookingRec);
        console.log('--saveBookingCancellation');
				 var cancelReason = component.find('cancellationReason').get('v.value');        
       			 var cancellationdescription = component.find('cancellationdescription').get('v.value');        
            	 var cancellationSubReason = component.find('cancellationSubReason').get('v.value');
                 var ForfeitureAmount = component.find('ForfeitureAmount').get('v.value');
        		 var BrokerageAmount = component.find('BrokerageAmount').get('v.value');
       		     var InterestValue = component.find('InterestValue').get('v.value');
       			 var Taxesifany = component.find('Taxesifany').get('v.value');
       			 var ForfeitureAmounttype = component.find('ForfeitureAmounttype').get('v.value');
       			 var Otherforfeitureamount = component.find('Otherforfeitureamount').get('v.value');
			     var ForfeiPercentage = component.find('ForfeiPercentage').get('v.value');
       			 var TotalForfeitureAmount = component.find('TotalForfeitureAmount').get('v.value');
            	 var TotalRefundAmount = component.find('TotalRefundAmount').get('v.value');
       			 var FinalRefundAmount = component.find('FinalRefundAmount').get('v.value');
        		 var TotalRecievedAmount = component.find('TotalRecievedAmount').get('v.value');
                 var TDS = component.find('TDS').get('v.value');
       			 var MVAT = component.find('MVATM').get('v.value');
            	 var CGST = component.find('CGST').get('v.value');
       			 var SGST = component.find('SGST').get('v.value');
        		 var cancSubType = component.find('cancSubType').get('v.value');
        		 var modeofCanc = component.find('modeofCanc').get('v.value');
                 var payRefAmt = component.find('payRefAmt').get('v.value');
        var ResaleStatus = component.find('ResaleStatus') ? component.find('ResaleStatus').get('v.value') : null;
        var newRate = component.find('newRate') ? component.find('newRate').get('v.value') : null;
        var newFlatAgrVal = component.find('newFlatAgrVal') ? component.find('newFlatAgrVal').get('v.value') : null;
        var recvAmt = component.find('recvAmt') ? component.find('recvAmt').get('v.value') : null;
        var referralAmt = component.find('referralAmt') ? component.find('referralAmt').get('v.value') : null;
        var meetingSatus = component.find('meetingStatus') ? component.find('meetingStatus').get('v.value') : null;
        var meetingDate = component.find('meetingDate') ? component.find('meetingDate').get('v.value') : null;
                 var otherReason = component.find('otherReason') ? component.find('otherReason').get('v.value') : null;
        var details ={};
        details['BookingId'] = BookingID;
        details['cancellationdescription'] = cancellationdescription;
        details['cancelReason'] = cancelReason;
        details['cancellationSubReason'] = cancellationSubReason;
        details['ForfeitureAmount'] = ForfeitureAmount;
        details['BrokerageAmount'] = BrokerageAmount;
        details['InterestValue'] = InterestValue;
        details['Taxesifany'] = Taxesifany;
        details['ForfeitureAmounttype'] = ForfeitureAmounttype;
        details['Otherforfeitureamount'] = Otherforfeitureamount;
        details['ForfeiPercentage'] = ForfeiPercentage;
        details['TotalForfeitureAmount'] = TotalForfeitureAmount;
        details['TotalRefundAmount'] = TotalRefundAmount;
        details['FinalRefundAmount'] = FinalRefundAmount;
        details['TotalRecievedAmount'] = TotalRecievedAmount;
        details['TDS'] = TDS;
        details['MVAT'] = MVAT;
        details['SGST'] = SGST;
        details['cancSubType'] = cancSubType;
        details['modeofCanc'] = modeofCanc;
        details['payRefAmt'] = payRefAmt;
        details['ResaleStatus'] = ResaleStatus;
        details['newRate'] = newRate;
        details['newFlatAgrVal'] = newFlatAgrVal;
        details['recvAmt'] = recvAmt;
        details['referralAmt'] = referralAmt;
        details['meetingSatus'] = meetingSatus;
        details['meetingDate'] = meetingDate;
        details['otherReason'] = otherReason;
        
        
        
		if(ForfeiPercentage == undefined || TotalRecievedAmount == undefined || ForfeitureAmounttype == '--Select--' || BrokerageAmount == undefined || cancellationSubReason == '--None--' || cancellationdescription == undefined ||
           InterestValue == undefined || Taxesifany == undefined || TDS == undefined || MVAT == undefined || TotalForfeitureAmount == undefined || Otherforfeitureamount == undefined || TotalRefundAmount == undefined || FinalRefundAmount == undefined
          || payRefAmt == undefined)    {
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "All fields are mandatory.Before saving, please click on Button Calculate forfieture Amount." 
                        });
                        toastEvent.fire();
            			$A.util.removeClass(spinner,"slds-show");
           				$A.util.addClass(spinner, "slds-hide");
            			return;            
        } 
        
        var action = component.get("c.bookingcancelled");
            action.setParams({
                "cancDetails": details
            });  
                action.setCallback(this, function(response) {  
                alert(response.getState());
                if (response.getState() == "SUCCESS") {                      
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                        //var closepop = $A.get("e.force:closeQuickAction");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Booking Cancellation information saved and cancellation checklist generated." 
                        });
                        toastEvent.fire();
                        var recordId = component.get("v.recordId");
       					var url = '/apex/CancellationCheckList?id=' + recordId;
       					window.open(url);
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
						dismissActionPanel.fire();  
                         $A.get('e.force:refreshView').fire();
                    }  
            }      
                    
             else if(response.getState() === "ERROR")
                    {
                        console.log(response.getError()[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": response.getError()[0].message 
                        });
                        toastEvent.fire();
                    }       
        });
    	$A.enqueueAction(action);
        
        
        
    },   
    saveBookingCancellationUpgrade:function(component , BookingID ){ 
        debugger;
        var spinner = component.find("mySpinner");
        if(spinner){
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
        }
        console.log('--saveBookingCancellation');
				 var cancelReason = component.find('cancellationReason').get('v.value');        
       			 var cancellationdescription = component.find('cancellationdescription').get('v.value');        
            	 var cancellationSubReason = component.find('cancellationSubReason').get('v.value');
        		 // var BrokerageAmount = component.find('BrokerageAmount1').get('v.value');
       		     // var InterestValue = component.find('InterestValue1').get('v.value');
       			 // var tax = component.find('Taxesifany1').get('v.value');
       			 // var gst = component.find('gst1').get('v.value');
            	 //var TotalRefundAmount = component.find('TotalRefundAmount1').get('v.value');
        		 // var TotalRecievedAmount = component.find('TotalRecievedAmount1').get('v.value');
                 // var TDS = component.find('TDS1').get('v.value');
       			 // var MVAT = component.find('MVATM1').get('v.value');
            	 // var CGST = component.find('CGST1').get('v.value');
       			 // var SGST = component.find('SGST1').get('v.value');
        		 var cancSubType = component.find('cancSubType').get('v.value');
        		 var modeofCanc = component.find('modeofCanc').get('v.value');
        		 // var referralAmt = component.find('referralAmt1').get('v.value');
        		 // var swipeCharges = component.find('swipeCharges1').get('v.value');
        		 // var brokeragePaid = component.find('brokeragePaid1').get('v.value');
        		 // var totalAmtToBeTransfrd = component.find('totalAmtToBeTransfrd').get('v.value');
        		 // var note = component.find('note').get('v.value');
        		 // var stmpDutyAmt = component.find('stmpDutyAmt').get('v.value');
        var meetingSatus = component.find('meetingStatus') ? component.find('meetingStatus').get('v.value') : null;
        var meetingDate = component.find('meetingDate') ? component.find('meetingDate').get('v.value') : null;
                 var otherReason = component.find('otherReason') ? component.find('otherReason').get('v.value') : null;
        
		/*if(TotalRecievedAmount == undefined || BrokerageAmount == undefined || InterestValue == undefined || tax == undefined ||
           TDS == undefined || MVAT == undefined || gst == undefined || referralAmt == undefined || swipeCharges == undefined ||
           brokeragePaid == undefined || totalAmtToBeTransfrd == undefined || note == undefined || stmpDutyAmt == undefined)    {
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "All fields are mandatory.Before saving, please click on Button Calculate forfieture Amount." 
                        });
                        toastEvent.fire();
            			$A.util.removeClass(spinner,"slds-show");
           				$A.util.addClass(spinner, "slds-hide");
            			return;            
        } 
        */
        var details ={};
        details['BookingId'] = BookingID;
        details['cancelReason'] = cancelReason;
        details['cancellationSubReason'] = cancellationSubReason;
        // details['BrokerageAmount'] = BrokerageAmount;
        // details['InterestValue'] = InterestValue;
        // details['Taxesifany'] = tax;
        // details['gst'] = gst;
        // details['TDS'] = TDS;
        // details['MVAT'] = MVAT;
        details['cancellationdescription'] = cancellationdescription;
        // details['CGST'] = CGST;
        // details['SGST'] = SGST;
        // details['TotalRecievedAmount'] = TotalRecievedAmount;
        details['cancSubType'] = cancSubType;
        details['modeofCanc'] = modeofCanc;
        // details['referralAmt'] = referralAmt;
        // details['swipeCharges'] = swipeCharges;
        // details['brokeragePaid'] = brokeragePaid;
        // details['totalAmtToBeTransfrd'] = totalAmtToBeTransfrd;
        // details['note'] = note;
        // details['stmpDutyAmt'] = stmpDutyAmt;
        details['meetingSatus'] = meetingSatus;
        details['meetingDate'] = meetingDate;
        details['otherReason'] = otherReason;
        
        var action = component.get("c.bookingcancelledUpgrade");
        action.setParams({     
            "cancDetails": details 
        });
            /*action.setParams({
                "BookingId" : BookingID ,
                "cancelReason" : cancelReason,
                "cancellationSubReason" : cancellationSubReason,
                "BrokerageAmount" : BrokerageAmount,
                "InterestValue" : InterestValue,
                "Taxesifany" : tax,
                "gst" : gst,
                "TDS" : TDS,
                "MVAT" : MVAT,
                "cancellationdescription" : cancellationdescription,
                'CGST' : CGST,
                'SGST' : SGST,
                'TotalRecievedAmount' : TotalRecievedAmount,
                'cancSubType' : cancSubType,
                'modeofCanc' : modeofCanc,
                'referralAmt' : referralAmt,
                'swipeCharges' : swipeCharges,
                'brokeragePaid' : brokeragePaid,
                'totalAmtToBeTransfrd' : totalAmtToBeTransfrd,
                'note' : note,
                'stmpDutyAmt' : stmpDutyAmt
            });  */
                action.setCallback(this, function(response) {  
                alert(response.getState());
                if (response.getState() == "SUCCESS") {                      
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                        //var closepop = $A.get("e.force:closeQuickAction");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Booking Cancellation information saved and cancellation checklist generated." 
                        });
                        toastEvent.fire();
                        var recordId = component.get("v.recordId");
       					var url = '/apex/CancellationCheckListUpgrade?id=' + recordId;
       					window.open(url);
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
						dismissActionPanel.fire();  
                         $A.get('e.force:refreshView').fire();
                    }  
            }      
                    
             else if(response.getState() === "ERROR")
                    {
                        console.log(response.getError()[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": response.getError()[0].message 
                        });
                        toastEvent.fire();
                    }       
        });
    	$A.enqueueAction(action);
        
        
        
    },
    saveBookingUnitTransfer:function(component , BookingID ){ 
        var spinner = component.find("mySpinner");
        if(spinner){
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
        }
		var cancelReason = component.find('cancellationReason').get('v.value');
        var cancellationdescription = component.find('cancellationdescription').get('v.value');
        var cancellationSubReason = component.find('cancellationSubReasonUnitTransfer').get('v.value');
        var registrationStatus = component.find('registrationStatus').get('v.value');
        
      /*  if(registrationStatus == 'Registration Completed'){
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Unit transfer is not allowed when registration is completed" 
                        });
                        toastEvent.fire();
            			$A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
            			return;
            
        }*/
        	
        if(cancellationSubReason == '--None--' || cancellationdescription == undefined) {
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "All fields are mandatory." 
                        });
                        toastEvent.fire();
            			$A.util.removeClass(spinner,"slds-show");
           				$A.util.addClass(spinner, "slds-hide");
            			return;
            
        } 
        
        var action = component.get("c.bookingUnitTransfer");
            action.setParams({
                "BookingId" : BookingID ,
                "cancelReason" : cancelReason,
                "cancelSubReason" : cancellationSubReason,
                "cancellationdescription" : cancellationdescription,
                
            }); 
        //alert(BookingID + cancellationSubReason + cancellationdescription)
           action.setCallback(this, function(response) {  
           alert(response.getState());
                if (response.getState() == "SUCCESS") {                      
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Unit transfer information saved." 
                        });
                        toastEvent.fire();
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
						dismissActionPanel.fire();  
                         $A.get('e.force:refreshView').fire();
                    }   
            }  
               
            else if(response.getState() === "ERROR")
                    {
                        console.log(response.getError()[0].message);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": response.getError()[0].message 
                        });
                        toastEvent.fire();
                    }    
        });
    	$A.enqueueAction(action);
        
    },   
    retrieveUnitInformation : function(component, UnitID, recordId){
        
        var action = component.get("c.getUnitInfo");
        action.setParams({
                "unitId": UnitID,
           		"bkgId" : recordId
            });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var unitDetails = response.getReturnValue(); 
                component.set("v.unitInfo", unitDetails);
            }
        });
        $A.enqueueAction(action);
    },
    /*fetchPicklistValues: function(component) {
        var action = component.get("c.getCancellationReasons");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Reasons fetched: ', response.getReturnValue());
                component.set("v.reasonOptions", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },*/
    fetchPicklistValues: function(component) {
        var action = component.get("c.getDependentMap"); // Call the new Map method
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.parentChildMap", result);
                
                // Extract keys for the first picklist
                var keys = Object.keys(result);
                component.set("v.reasonOptions", keys);
                
                // If there's already a value (Edit mode), populate sub-reasons immediately
                var existingReason = component.get("v.bookingInfo.Cancellation_Reason__c");
                if(existingReason) {
                    component.set("v.subReasonOptions", result[existingReason]);
                }
            }
        });
        $A.enqueueAction(action);
    },
    fetchDynamicPicklists: function(component) {
        var action = component.get("c.getMultiplePicklistOptions");
        
        // Pass the list of fields you want to fetch dynamically
        action.setParams({
            "fieldNames": ["Mode_of_Cancellation__c", "Cancellation_Subtype__c", "Meeting_Status__c"]
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.picklistMap", result);
            } else {
                console.error("Error fetching picklists: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchSubtypeMapping: function(component) {
        var action = component.get("c.getSubReasonToTypeMap");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.subReasonToTypeMap", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
})