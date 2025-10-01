({
	validatePinCode : function(component,event) 
    {
		var format = '^[1-9][0-9]{5}$';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
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
        
        else
        {
            return true;
        }
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
	},
    
    validateAadharNumber : function(component,event) 
    {
		//var format = '^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$';
        var format = '^[0-9]{12}$';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
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
        
        else
        {
            return true;
        }
	},
    
    validatePassportNumber: function(component,event) 
    {
		var format = '^[A-PR-WYa-pr-wy][1-9]\\d\\s?\\d{4}[1-9]$';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
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
        
        else
        {
            return true;
        }
	},
    
    getPicklistValues: function(component,nameOfObject,fields)
    {
    var action = component.get("c.getPicklistValues");
    action.setParams({ "objectName" : nameOfObject , fieldNames :fields });

    action.setCallback(this, function(response) 
    {
        var state = response.getState();
       if (state === "SUCCESS") 
       {
           return response.getReturnValue();
       }
    });
 
     $A.enqueueAction(action); 
    }
    
    /*getTCforRunwalMahalakshmi: function(component,event){
        var action = component.get("c.getTCforRunwalMahalakshmiProj");
        console.log('--getTCforRunwalMahalakshmiProj');
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('--getTCforRunwalMahalakshmiProj: ', response.getState());
            console.log('--getTCforRunwalMahalakshmiProj: ', response.getReturnValue());
            if (state == "SUCCESS") {
                component.set("v.mahalakshmiTC",response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action); 
    }*/
})