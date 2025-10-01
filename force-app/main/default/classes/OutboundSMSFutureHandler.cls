public class OutboundSMSFutureHandler 
{
	@future(Callout=true)
	public static void SendSMSOnOppProcess(set<id> setOpporunityId)
    {
    	if(setOpporunityId!=null && setOpporunityId.size()>0)
    	{
    		list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where id in:setOpporunityId];
    		map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
    		for(Opportunity objOpp: lstOpp)
    		{
    			OutboundSMS objOutboundSMS = new OutboundSMS();
                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
                //objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
                if(objOpp.RW_Sales_Associate__c!=null)
                {
                	objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                	
                	if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c)!=null)
                		objBooking.setOppMobile = string.valueOf(mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c).RW_Phone__c);
            		else
            			objBooking.setOppMobile = 'NA';
                }
            	else
            	{
            		objBooking.setSalesManager = 'NA';
            		objBooking.setOppMobile = 'NA';
            	}
                objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
                objBooking.setOppName = objOpp.Name;
                objBooking.setDate = string.valueOf(objOpp.First_Site_Visit_Date__c);
                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
                objOutboundSMS.setTemplete = 'Site Visit Completion';
                objOutboundSMS.Send(objBooking); 
    		}
    	}
    }
    @future(Callout=true)
	public static void SendSMSOnOppSiteVisitConfrm(set<id> setEventId)
    {
    	if(setEventId!=null && setEventId.size()>0)
    	{
    		list<event> lstevent = [select id, StartDateTime, WhatId from event where Subject=:'Site Visit' and id in: setEventId];
    		map<id,dateTime> mapOfOppToStartDate = new map<id,dateTime>(); 
    		map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
    		if(lstevent!=null && lstevent.size()>0)
    		{
    			for(event objEvent: lstevent)
    				mapOfOppToStartDate.put(objEvent.WhatId, objEvent.StartDateTime);
				list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where id in: mapOfOppToStartDate.keyset()];
	    		if(lstOpp!=null && lstOpp.size()>0)
	    		for(Opportunity objOpp: lstOpp)
	    		{
	    			OutboundSMS objOutboundSMS = new OutboundSMS();
	                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
	                objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
	                if(objOpp.RW_Sales_Associate__c!=null)
	                {
	                	objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
	                	
	                	if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c)!=null)
	                		objBooking.setOppMobile = string.valueOf(mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c).RW_Phone__c);
                		else
                			objBooking.setOppMobile = 'NA';
	                }
                	else
                	{
                		objBooking.setSalesManager = 'NA';
                		objBooking.setOppMobile = 'NA';
                	}
	                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
	                objBooking.setOppName = objOpp.Name;
	                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
	                objOutboundSMS.setTemplete = 'Site Visit Scheduling';
	                objBooking.setDate = mapOfOppToStartDate.get(objOpp.id).format('dd/MM/yy')+' at '+mapOfOppToStartDate.get(objOpp.id).format('HH:mm');
	                objOutboundSMS.Send(objBooking); 
	    		}
    		}
    	}
    }
    
    @future(Callout=true)
	public static void SendSMSOnOppCallCompletion(set<id> setOpporunityId)
    {
    	if(setOpporunityId!=null && setOpporunityId.size()>0)
    	{
    		list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where id in:setOpporunityId];
    		map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
    		for(Opportunity objOpp: lstOpp)
    		{
    			OutboundSMS objOutboundSMS = new OutboundSMS();
                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
                objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
                objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                if(objOpp.RW_Sales_Associate__c!=null)
                {
                	objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                	
                	if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c)!=null)
	            		objBooking.setOppMobile = string.valueOf(mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c).RW_Phone__c);
	        		else
	        			objBooking.setOppMobile = 'NA';
                }
                else
            	{
            		objBooking.setSalesManager = 'NA';
            		objBooking.setOppMobile = 'NA';
            	}
                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
                objBooking.setOppName = objOpp.Name;
                objBooking.setDate = string.valueOf(objOpp.First_Site_Visit_Date__c);
                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
                objOutboundSMS.setTemplete = 'Call Completion';
                objOutboundSMS.Send(objBooking); 
    		}
    	}
    }
    @future(Callout=true)
	public static void SendSMSOnOppMissedCall(set<id> setOpporunityId)
    {
    	if(setOpporunityId!=null && setOpporunityId.size()>0)
    	{
    		list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where id in:setOpporunityId];
    		for(Opportunity objOpp: lstOpp)
    		{
    			OutboundSMS objOutboundSMS = new OutboundSMS();
                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
                objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
                objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
                objBooking.setOppName = objOpp.Name;
                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
                objOutboundSMS.setTemplete = 'Missed Call';
                objOutboundSMS.Send(objBooking); 
    		}
    	}
    }
    @future(Callout=true)
	public static void SendSMSOnOppBooking(set<id> setUnitId)
    {
    	if(setUnitId!=null && setUnitId.size()>0)
    	{
    		list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where RW_Project_Unit__c in:setUnitId];
    		for(Opportunity objOpp: lstOpp)
    		{
    			OutboundSMS objOutboundSMS = new OutboundSMS();
                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
                objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
                objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
                objBooking.setOppName = objOpp.Name;
                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
                objOutboundSMS.setTemplete = 'Booking';
                objOutboundSMS.Send(objBooking); 
    		}
    	}
    }
    //update on the 5/3 for change in requirement by Adarsh on task
    @future(Callout=true)
	public static void SendSMSOnOppCallCompletionTask(set<id> setTaskId)
    {
    	if(setTaskId!=null && setTaskId.size()>0)
    	{
    		list<Task> lstTask = [select id, WhatId, RW_Call_Completion__c, RW_Sales_Associate__c from Task where id in:setTaskId];
    		map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
    		map<string, Task> mapOfTaskToOpp = new map<string, Task>();
    		for(Task objTask: lstTask)
    		{
    			if(objTask.WhatId != null)
    				mapOfTaskToOpp.put(objTask.WhatId, objTask);
    		}
    		if(mapOfTaskToOpp.size() > 0)
    		{
    			list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, 
    											First_Site_Visit_Date__c from Opportunity where id in:mapOfTaskToOpp.keySet()];
    			
    			if(lstOpp != null && lstOpp.size() > 0)
    			{
    				for(Opportunity objOpp : lstOpp)
    				{
    					OutboundSMS objOutboundSMS = new OutboundSMS();
		                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
		                objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
		                /*if(objOpp.RW_Sales_Associate__c!=null)
		                {
		                	objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
		                	
		                	if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c)!=null)
			            		objBooking.setOppMobile = string.valueOf(mapOfCustomSetting.get(objOpp.RW_Sales_Associate__c).RW_Phone__c);
			        		else
			        			objBooking.setOppMobile = 'NA';
		                }
		                else
		            	{
		            		objBooking.setSalesManager = 'NA';
		            		objBooking.setOppMobile = 'NA';
		            	}*/
		            	if(mapOfTaskToOpp.get(objOpp.id) !=null && mapOfTaskToOpp.get(objOpp.id).RW_Sales_Associate__c !=null)
		            	{
		            		objBooking.setSalesManager = mapOfTaskToOpp.get(objOpp.id).RW_Sales_Associate__c;
		                	
		                	if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(mapOfTaskToOpp.get(objOpp.id).RW_Sales_Associate__c)!=null)
			            		objBooking.setOppMobile = string.valueOf(mapOfCustomSetting.get(mapOfTaskToOpp.get(objOpp.id).RW_Sales_Associate__c).RW_Phone__c);
			        		else
			        			objBooking.setOppMobile = 'NA';
		            	}
		            	else
		            	{
		            		objBooking.setSalesManager = 'NA';
		            		objBooking.setOppMobile = 'NA';
		            	}
		                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
		                objBooking.setOppName = objOpp.Name;
		                objBooking.setDate = string.valueOf(objOpp.First_Site_Visit_Date__c);
		                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
		                objOutboundSMS.setTemplete = 'Call Completion';
		                objOutboundSMS.Send(objBooking); 
    				}
    			}
    		}
    	}
    }
}