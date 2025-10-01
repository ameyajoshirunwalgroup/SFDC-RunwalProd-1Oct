({
	onerrorMessage : function( component, event, helper,errormessage ) 
    {
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type":"error",
                    "message": errormessage});
                toastEvent.fire();
        return;
    },
    
     validatePANNumber : function(component,event) 
    {
		var format = '[A-Z]{5}[0-9]{4}[A-Z]{1}';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
        {
            if(event.getSource().get("v.value").length > 10)
            {
                return false;  
            }
            else
            {
                if(event.getSource().get("v.value").match(format))
                {  
                return true;
                }  
        
                else
                {
                  return false;  
                }
            }
        }
        
        else
        {
            return true;
        }
	}
})