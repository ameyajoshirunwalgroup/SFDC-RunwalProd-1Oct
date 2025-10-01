public Class OutboundSMS
{
    public string To;
    public string setTemplete;
    public string setSMSId; 
    public string SetSMSText;
    public string SetURL;
    public string ackDate;
    
   // public class SiteVisit
   // {
      //  public string setProjectName;
     //   public string setDate;
     //   public string setTime;
      //  public string setSalutation;
      //  public string setOppName;
      //  public string setOppMobile;
      //  public string setOppMobileAlt;
     //   public string setSalesRepName;
      //  public string setSalesRepContact;
      //  public string setAssistantContact;
   // }
    
    public class Booking
    {
        //public string setRcptNo {get;set;}
       // public string setAmount;
        public string setDate;
        public string setOppMobile;
        public string setSalesManager;
        public string setProjectName;
        public string setOppName;
        public string setSalutation;
    }
    
    public void send(object SMS) 
    {
        if(SMS != null)
        {
            system.debug('Sumit Outbound SMS class called');
            list<OutboundSMS__c> lstOutboundSMS = OutboundSMS__c.getall().values();
            OutboundSMS__c objOutboundVender = new OutboundSMS__c();
            if(lstOutboundSMS != null && lstOutboundSMS.size() > 0 )
            {
                for(OutboundSMS__c objOBS: lstOutboundSMS)
                {
                    if(objOBS.Is_Active__c)
                        objOutboundVender = objOBS;
                }
            }
            
            string msgText = '';
            
            for(SMS_Templete__c objTemplete: SMS_Templete__c.getall().values())
            {
                if(objTemplete.Name == setTemplete && objTemplete.Is_Active__c)
                    msgText = objTemplete.SMS_Templete__c;
            }
            
            if(objOutboundVender.Is_Active__c && To != null && To != '' && msgText != '')
            {
                if(String.valueOf(SMS).split(':')[0] == 'Booking')
                {
                    Booking objBooking = (Booking)SMS;
                    
                    if(msgText.contains('$date') && objBooking.setDate != null)
                        msgText = msgText.replace('$date', objBooking.setDate); 
                    if(msgText.contains('$Phone') && objBooking.setOppMobile != null)
                        msgText = msgText.replace('$Phone', objBooking.setOppMobile);
                    if(msgText.contains('$salemanager') && objBooking.setSalesManager != null)
                        msgText = msgText.replace('$salemanager', objBooking.setSalesManager);
                    if(msgText.contains('$projectname') && objBooking.setProjectName != null)
                        msgText = msgText.replace('$projectname', objBooking.setProjectName);
                    if(msgText.contains('$firstname') && objBooking.setOppName != null)
                        msgText = msgText.replace('$firstname', objBooking.setOppName);
                    if(msgText.contains('$salutation') && objBooking.setSalutation != null)
                        msgText = msgText.replace('$salutation', objBooking.setSalutation);
                    if(msgText.contains('$eoiformurl') && SetURL != null)
                         msgText = msgText.replace('$eoiformurl', SetURL);
                    if(msgText.contains('$ackdate') && ackDate != null)
                         msgText = msgText.replace('$ackdate', ackDate);
                }
                 
                system.debug('msgText1-------'+msgText);   
                //msgText = EncodingUtil.urlEncode(msgText, 'UTF-8');
                msgText = msgText.replace('%E2%80%9D','%22');
                msgText = msgText.replace('%E2%80%9C','%22');
                msgText = msgText.replace(' ','%20');
                system.debug('msgText2-------'+msgText);
                
                if(objOutboundVender != null )
                {
                    string strURL = objOutboundVender.End_Point_URL__c;
                    strURL += '?username='+ objOutboundVender.User_Name__c;
                    strURL += '&password='+ objOutboundVender.Password__c;
                    strURL += '&to='+ To;
                    strURL += '&from='+ objOutboundVender.FromLabel__c;
                    strURL += '&text='+ msgText;
                    
                    if(setSMSId != null && setSMSId != '' && objOutboundVender.Return_URL__c != null && objOutboundVender.Return_URL__c != '')
                        strURL += '&udh=&dlr-mask=19&dlr-url='+ objOutboundVender.Return_URL__c + '?myid=' + setSMSId + '%26status=%25d%26updated_on=%25t%26res=%252'; 
                    
                    system.debug('Sumit msgText1 :: '+ msgText);
                    system.debug('Sumit strURL1 :: '+ strURL);  
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint (strURL);
                    req.setMethod ('GET');
                    Http http = new Http();
                    if(!Test.isRunningTest())
                    {
                        //Commented by Vinay(27-10-2021) - as per your comments in email this is not required
                        //HTTPResponse res = http.send(req);
                        //system.debug('Sumit HTTPResponse :: '+ res); 
                    }
                }
            }
        }
    }
    
    
    
    public void Send()
    {
        if(SetSMSText != null && SetSMSText != '')
        {
            string msgText = SetSMSText;
            list<OutboundSMS__c> lstOutboundSMS = OutboundSMS__c.getall().values();
            OutboundSMS__c objOutboundVender = new OutboundSMS__c();
            if(lstOutboundSMS != null && lstOutboundSMS.size() > 0 )
            {
                for(OutboundSMS__c objOBS: lstOutboundSMS)
                {
                    if(objOBS.Is_Active__c)
                        objOutboundVender = objOBS;
                }
            }
            
            if(objOutboundVender.Is_Active__c && To != null && To != '' && msgText != '')
            {
                msgText = EncodingUtil.urlEncode(msgText, 'UTF-8');
                msgText = msgText.replace('%E2%80%9D','%22');
                msgText = msgText.replace('%E2%80%9C','%22');
                
                if(objOutboundVender != null )
                {
                    string strURL = objOutboundVender.End_Point_URL__c;
                    strURL += '?username='+ objOutboundVender.User_Name__c;
                    strURL += '&password='+ objOutboundVender.Password__c;
                    strURL += '&to='+ To;
                    strURL += '&from='+ objOutboundVender.FromLabel__c;
                    strURL += '&text='+ msgText;
                    
                    if(setSMSId != null && setSMSId != '' && objOutboundVender.Return_URL__c != null && objOutboundVender.Return_URL__c != '')
                        strURL += '&udh=&dlr-mask=19&dlr-url='+ objOutboundVender.Return_URL__c + '?myid=' + setSMSId + '%26status=%25d%26updated_on=%25t%26res=%252'; 
                    
                    system.debug('Sumit msgText :: '+ msgText);
                    system.debug('Sumit strURL :: '+ strURL);  
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint (strURL);
                    req.setMethod ('GET');
                    Http http = new Http();
                    if(!Test.isRunningTest())
                    {
                        //Commented by Vinay(27-10-2021) - as per your comments in email this is not required
                        //HTTPResponse res = http.send(req);
                        //system.debug('Sumit HTTPResponse :: '+ res);
                    }
                }
            }
        }
    }
}