public class EOIOutboundSMSFutureHandler 
{

     @future(Callout=true)
	public static void SendSMSOnEOIInterest(List<String> data)
    {
    	if(data!=null && data.size()>0)
    	{
            System.debug('**inside !**'+data);
    		list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where id =:data[0]];
    		//map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
    		for(Opportunity objOpp: lstOpp)
    		{
    			OutboundSMS objOutboundSMS = new OutboundSMS();
                OutboundSMS.Booking objBooking = new  OutboundSMS.Booking(); 
                //objBooking.setOppMobile = objOpp.RW_Mobile_No__c;
               /* if(objOpp.RW_Sales_Associate__c!=null)
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
                //objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
                objBooking.setOppName = objOpp.Name;
                //objBooking.setDate = string.valueOf(objOpp.First_Site_Visit_Date__c);
                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
                objOutboundSMS.setTemplete = 'EOI';
                //objOutboundSMS.SetURL = data[1].replace('%2B','+');
                objOutboundSMS.SetURL = data[1];
                System.debug('**before send !**'+objBooking);
                objOutboundSMS.Send(objBooking); 
    		}
    	}
    }
    
     @future(Callout=true)
	public static void SendSMSOnEOIConfirm(List<String> data)
    {
    	if(data!=null && data.size()>0)
    	{
            System.debug('**inside !**'+data);
    		list<Opportunity> lstOpp = [select id, Name, RW_Project__c, RW_Project__r.name, RW_Sales_Associate__c, RW_Mobile_No__c, First_Site_Visit_Date__c from Opportunity where id =:data[0]];
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
                //objBooking.setSalesManager = objOpp.RW_Sales_Associate__c;
                objBooking.setProjectName = objOpp.RW_Project__c!=null? objOpp.RW_Project__r.name:null;
                objBooking.setOppName = objOpp.Name;
                //objBooking.setDate = string.valueOf(objOpp.First_Site_Visit_Date__c);
                objOutboundSMS.To = objOpp.RW_Mobile_No__c;
                objOutboundSMS.setTemplete = 'EOI Confirm';
                //objOutboundSMS.SetURL = data[1].replace('%2B','+');
                System.debug('**before send date'+data[1]);
                objOutboundSMS.ackDate = data[1];
                System.debug('**before send !**'+objBooking);
                objOutboundSMS.Send(objBooking); 
    		}
    	}
    }
}