@RestResource(urlMapping='/CancelBooking/*')
global with sharing class CancelBookingRestService {
	public class Result
	    {
	        public string Message {get; set;}
	        public string Id {get; set;}
	    }
	           
	    @HttpPost
	    global static string doPost(Opportunity CancelInfo)
	    {
	    	Result objResult = new Result();
	    	
	        try
	        {
	        	system.debug('CancelInfo=====' + CancelInfo);
	        	
	        	if(CancelInfo != null)
	        	{
	        		if(CancelInfo.Id != null)
	        		{
	        			if(CancelInfo.FV_Cancellation_Flag__c == 'C')
	        			{
		        			Opportunity updateCancelOpportunity = [Select 	Id, RW_Project_Unit__c,
		        															FV_Cancellation_Flag__c, FV_Cancelled_Date__c,FV_Booked_ID__c
		        													From Opportunity
		        													Where Id =: CancelInfo.Id];
		        			
		        			system.debug('updateCancelOpportunity=====' + updateCancelOpportunity);
		        			
		        			Project_Unit__c objProjectUnit = [Select Id, RW_Seventh_Day__c from Project_Unit__c
		        												Where Id =: updateCancelOpportunity.RW_Project_Unit__c];
		        			
		        			updateCancelOpportunity.FV_Cancellation_Flag__c = CancelInfo.FV_Cancellation_Flag__c;
		        			updateCancelOpportunity.FV_Cancelled_Date__c = CancelInfo.FV_Cancelled_Date__c;
		        			updateCancelOpportunity.FV_Booked_ID__c = CancelInfo.FV_Booked_ID__c;
	        			
		        			update updateCancelOpportunity;
			        						
		        			if(updateCancelOpportunity.Id != null)
			    			{
			    				objProjectUnit.RW_Seventh_Day__c = true;
		        				update objProjectUnit;
		        			
		        				if(objProjectUnit.Id != null && objProjectUnit.RW_Seventh_Day__c == true)
		        				{
		        					system.debug('Cancelled opp Id=====' + updateCancelOpportunity.Id);
			    					
			    					objResult.Id = updateCancelOpportunity.Id;
			    					objResult.Message = 'Cancelled Successfully';
			    				}
		        			}
	        			}
	        		}
	        	}
	        }
	        catch(exception e)
	        {
	            system.debug('/CancelBooking/ CancelBooking Exception :: ' + e);
	            
	            objResult.Id = '0';
				objResult.Message = 'Error: ' + e;
	        }
	        
	        string jsonResult = System.JSON.serialize(objResult);
	        
	        system.debug('jsonResult=====' + jsonResult);
	         
	        return jsonResult;
    }
}