({
    validatePANNumber : function(component,event) 
    {debugger;
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
	}
    
})