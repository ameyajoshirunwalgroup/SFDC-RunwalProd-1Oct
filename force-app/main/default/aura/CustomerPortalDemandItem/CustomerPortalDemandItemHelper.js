({
	helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show'); debugger; 
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
})