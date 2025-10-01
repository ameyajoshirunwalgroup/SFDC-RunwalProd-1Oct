@RestResource(urlMapping='/UpdateBooking/*')
global with sharing class UpdateProjectUnitStatus {
	public class Result
    {
        public string Message {get; set;}
        public string Id {get; set;}
    }
           
    @HttpPost
    global static string doPost(Opportunity BookingInfo)
    {
    	Result objResult = new Result();
    	
        try
        {
        	system.debug('BookingInfo=====' + BookingInfo);
        	        	
        	if(BookingInfo != null)
        	{
        		if(BookingInfo.Id != null)
    			{
    				update BookingInfo;
    				
    				if(BookingInfo.Id != null)
    				{
    					system.debug('BookingInfo Id=====' + BookingInfo.Id);
    					
    					objResult.Id = BookingInfo.Id;
    					objResult.Message = 'Updated Successfully';
    				}
    			}
        	}
        }
        catch(exception e)
        {
            system.debug('/UpdateBooking/ UpdateBooking Exception :: ' + e);
            
            objResult.Id = '0';
			objResult.Message = 'Error: ' + e;
        }
        
        string jsonResult = System.JSON.serialize(objResult);
        
        system.debug('jsonResult=====' + jsonResult);
         
        return jsonResult;
    }
}