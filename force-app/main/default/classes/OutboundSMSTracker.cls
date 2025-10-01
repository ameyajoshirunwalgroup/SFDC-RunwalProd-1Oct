@isTest(seealldata=true)
public class OutboundSMSTracker 
{ 
    static testMethod void ValidateConstructor() 
    {
        
        OutboundSMS__c objobs = new OutboundSMS__c();
        objobs.Is_Active__c= true;
        objobs.End_Point_URL__c='test.com';
		objobs.User_Name__c ='test@test.com';
		objobs.Password__c = 'Test@123';
		objobs.FromLabel__c ='test';
		objobs.Return_URL__c ='test@test.com';
		objobs.Name = 'test';
        insert objobs;
        //objobs.Is_SMS_Sent__c=true;
       // update objobs;

	   SMS_Templete__c objsmsTemp = new SMS_Templete__c();
	   objsmsTemp.Is_Active__c = true;
	   objsmsTemp.ReminderBefore__c = '1:10';
	   objsmsTemp.SMS_Templete__c = 'testtttt';
	   objsmsTemp.name = 'Test';
	   insert objsmsTemp;

        OutboundSMS.Booking objSiteVisit = new OutboundSMS.Booking();
        //objSiteVisit.setRcptNo = 'Test';
        objSiteVisit.setSalutation = 'Test'; 
        objSiteVisit.setSalesManager = 'Test';
        objSiteVisit.setDate = 'Test';
        objSiteVisit.setOppMobile = 'Test';
        objSiteVisit.setProjectName = 'Test';
        objSiteVisit.setOppName = 'Test';
        
        OutboundSMS objOutboundSMS = new OutboundSMS();
        objOutboundSMS.To = '1234567890';
        objOutboundSMS.setTemplete = 'Test';
        objOutboundSMS.SetSMSText = 'Test'; 
        
        
        ObjOutboundSMS.send(objSiteVisit);
        
        /*OutboundSMS.SiteVisit objBooking = new OutboundSMS.SiteVisit();
        objOutboundSMS.setTemplete = 'Test';
        objBooking.setProjectName = 'Test';
        objBooking.setDate = 'Test';
        objBooking.setTime = 'Test';
        objBooking.setDateTime = 'Test';
        objBooking.setLeadName = 'Test';
        objBooking.setLeadMobile = 'Test';
        objBooking.setLeadMobileAlt = 'Test';
        objBooking.setSalesRepName = 'Test';
        objBooking.setSalesRepContact = 'Test';
        ObjOutboundSMS.send(objBooking);*/
        
        objOutboundSMS.Send();
    }
    
}