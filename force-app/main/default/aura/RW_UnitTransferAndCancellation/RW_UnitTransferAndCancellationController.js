({
    
    doInit: function(component, event, helper) {        
        var BookingID = component.get("v.recordId"); 
        if(BookingID != null)
        {
        	helper.retrieveBookingInformation(component,BookingID); 
            //var status = component.find('bookingStatus').get('v.value');
            //alert(status);
        }        
       
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    saveCancellationReason: function(component , event , helper){
        var BookingID = component.get("v.recordId"); 
        var cancellationReason = component.find('cancellationReason').get('v.value');
        var cancellationSubReason = component.find('cancellationSubReason').get('v.value');
        if(cancellationReason == 'Unit cancelled' && cancellationSubReason != 'Z8' && cancellationSubReason != 'R3'){
            helper.saveBookingCancellation(component , BookingID);
        }else if(cancellationReason == 'Unit cancelled' && (cancellationSubReason == 'Z8' || cancellationSubReason == 'R3')){
            helper.saveBookingCancellationUpgrade(component , BookingID);
        }
        
        //helper.retrieveBookingInformation(component,BookingID);
    },
    unitTransferSave: function(component , event , helper){
        var BookingID = component.get("v.recordId"); 
        helper.saveBookingUnitTransfer(component , BookingID);
        //helper.retrieveBookingInformation(component,BookingID); 
        
    },
    generateChecklist: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var cancelReason = component.find('cancellationReason').get('v.value');               
        var cancellationSubReason = component.find('cancellationSubReason').get('v.value');
        if(cancelReason === 'Unit cancelled' && (cancellationSubReason == 'R3' || cancellationSubReason == 'Z8')){
            var url = '/apex/CancellationCheckListUpgrade?id=' + recordId;
        }else{
            var url = '/apex/CancellationCheckList?id=' + recordId;
        }
        window.open(url);
    },
    
    validatePercentage : function(component, event, helper){
    var Forfietpercent = component.find('ForfeiPercentage').get('v.value');
    if(Forfietpercent > 100)      
    {        
        var toastEvent = $A.get("e.force:showToast");
                       toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Forfeit percentage cannot be greater than 100." 
                        });
                        toastEvent.fire();
        component.find('ForfeiPercentage').set('v.value' , null);
    }
   },
    
    cal : function (component, helper) {
        debugger;
        var cancellationReason = component.find('cancellationReason').get('v.value');
        var cancellationSubReason = component.find('cancellationSubReason').get('v.value');
        if(cancellationReason == 'Unit cancelled' && cancellationSubReason != 'Z8' && cancellationSubReason != 'R3'){
            var AgreementValue = component.find('AgreementValue').get('v.value'); 
            var MVATM = component.find('MVATM').get('v.value'); 
            var TotalRecievedAmount = component.find('TotalRecievedAmount').get('v.value');
            var ForfeitureAmount = component.find('ForfeitureAmount').get('v.value');
            var BrokerageAmount = component.find('BrokerageAmount').get('v.value');
            var InterestValue = component.find('InterestValue').get('v.value');
            var Taxesifany = component.find('Taxesifany').get('v.value');
            var ForfeitureAmounttype = component.find('ForfeitureAmounttype').get('v.value');
            var Otherforfeitureamount = component.find('Otherforfeitureamount').get('v.value');
            var ForfeiPercentage = component.find('ForfeiPercentage').get('v.value');
            var TotalForfeitureAmount = component.find('TotalForfeitureAmount').get('v.value');
            var TDS = component.find('TDS').get('v.value'); 
            var TotalRefundAmount = component.find('TotalRefundAmount').get('v.value'); 
            var ForfeitureAmountCalculation;
            if(ForfeitureAmounttype == 'Total received amount'){
                ForfeitureAmountCalculation = ((ForfeiPercentage/100)   * TotalRecievedAmount);
            }else{
                ForfeitureAmountCalculation = ((ForfeiPercentage/100)   * AgreementValue);
            }
            if(isNaN(ForfeitureAmountCalculation)){
                ForfeitureAmountCalculation=0;
            }
            component.find('ForfeitureAmount').set('v.value' , ForfeitureAmountCalculation);      		 
            var gstPercent = $A.get("$Label.c.RW_GSTPercentage");
            var CGST = (gstPercent*ForfeitureAmountCalculation)/100;
            var SGST = (gstPercent*ForfeitureAmountCalculation)/100;
            component.find('SGST').set('v.value' ,SGST);
            component.find('CGST').set('v.value' ,CGST);
            var TotalRefundAmount1 = parseFloat(TotalRecievedAmount) - (parseFloat(ForfeitureAmountCalculation) + parseFloat(CGST) + parseFloat(SGST) +  parseFloat(BrokerageAmount) +  parseFloat(InterestValue) + parseFloat(Taxesifany) + parseFloat(MVATM)+ parseFloat(TDS)+ parseFloat(Otherforfeitureamount));
            var totalforfeitureamount = parseFloat(ForfeitureAmountCalculation) + parseFloat(MVATM) + parseFloat(CGST) + parseFloat(SGST) + parseFloat(BrokerageAmount) + parseFloat(InterestValue) + parseFloat(Taxesifany) +  parseFloat(TDS)+ parseFloat(Otherforfeitureamount);
            component.find('TotalRefundAmount').set('v.value' ,TotalRefundAmount1)	                  
            component.find('TotalForfeitureAmount').set('v.value' ,totalforfeitureamount);
        }else if(cancellationReason == 'Unit cancelled' && (cancellationSubReason == 'Z8' || cancellationSubReason == 'R3')){
            var AgreementValue1 = component.find('AgreementValue1').get('v.value'); 
            var MVATM1 = component.find('MVATM1').get('v.value'); 
            var TotalRecievedAmount1 = component.find('TotalRecievedAmount1').get('v.value');
            var BrokerageAmount1 = component.find('BrokerageAmount1').get('v.value');
            var InterestValue1 = component.find('InterestValue1').get('v.value');
            var Taxesifany1 = component.find('Taxesifany1').get('v.value');
            var gst1 = component.find('gst1').get('v.value');
            var TDS1 = component.find('TDS1').get('v.value'); 
            //var TotalRefundAmount1 = component.find('TotalRefundAmount1').get('v.value'); 
              		 
            var gstPercent = $A.get("$Label.c.RW_GSTPercentage");
            var CGST1 = (gstPercent*AgreementValue1)/100;
            var SGST1 = (gstPercent*AgreementValue1)/100;
            component.find('SGST1').set('v.value' ,SGST1);
            component.find('CGST1').set('v.value' ,CGST1);
            //var TotalRefundAmount1 = parseFloat(TotalRecievedAmount1) - (parseFloat(CGST1) + parseFloat(SGST1) +  parseFloat(BrokerageAmount1) +  parseFloat(InterestValue1) + parseFloat(Taxesifany1) + parseFloat(MVATM1)+ parseFloat(TDS1)+ parseFloat(gst1));;
            //component.find('TotalRefundAmount1').set('v.value' ,TotalRefundAmount1)	        
        }
        
        		
    },
    unitDetails : function(component,event, helper){
    	var UnitID = event.getParam("value")[0];
        var recordId = component.get("v.recordId");
        console.log('UnitID - ', UnitID);
        if(UnitID != null){
        	helper.retrieveUnitInformation(component,UnitID,recordId); 
        } 
        
	}
    
});