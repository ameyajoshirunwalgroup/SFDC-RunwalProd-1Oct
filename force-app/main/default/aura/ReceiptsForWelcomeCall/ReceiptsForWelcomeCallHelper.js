({
	fetchReceiptList : function(component, event, helper) {
		var action = component.get("c.fetchReceiptData");
        action.setParams({ "strWcId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var receiptList = response.getReturnValue(); 
                    console.log('bookingObj!!!',receiptList);
                //alert(bookingObj);
                 //console.log('receiptList!!!!',bookingObj.receiptList.length);
                component.set("v.receiptList",receiptList);
               
            }
        });
        $A.enqueueAction(action);
	}
})