public class SMSFutureHandler
{

    @future(Callout=true) 
    public static void outboundSMS(set<id> smsIds)
    {
      system.debug('Inside the SendSMSNewFutureHandler...');
             string myphone = '';
             string mymsg = '';
             string strURL = '';   
         system.debug('Inside the SendSMSNewFutureHandler...');
       
          
        //if(smsIds != null && smsIds.size() > 0 && !test.isRunningTest()) //Commented by Vinay 10-02-2025
        if(smsIds != null && smsIds.size() > 0) //Added by Vinay 10-02-2025
        {
            system.debug('Inside If Condition. : ' + smsIds);
            list<SMS_Schedule_SMS_c__c> smslist = new list<SMS_Schedule_SMS_c__c> ();
            smslist = [SELECT Id,Name, Sender_Mobile__c,SMS_Long_text__c, Project_Interested__c, SMS_Text__c FROM 
                       SMS_Schedule_SMS_c__c where Id in :smsIds];
            
            system.debug('smslist  : ' + smslist );           
     /*       
            Set<Id> projId = New Set<Id>();
            
            if(!smslist.isEmpty())
            {
                for(SMS_Schedule_SMS_c__c s : smslist)
                {
                   projId.add(s.Project_Interested__c);
                }
            }
            
            
            system.debug('projId ::'+projId);
            List<Project__c> projlist = new List<Project__c>();
            if(!projId.isEmpty()){
            projlist = [Select id, Name, Sender_Code__c from Project__c where id IN :projId];
            system.debug('projlist ::'+projlist );
            }
            */
            
            List <Vendor__c> vendorlist = new List<Vendor__c>();       
            vendorlist = [SELECT id,Name,Vendor_URL__c,Param_1_Name__c, Param_1_Value__c , Param_2_Name__c, Param_2_Value__c,  Param_3_Name__c, Param_8_Name__c, Param_3_Value__c,Param_5_Name__c, Param_5_Value__c , Param_4_Name__c, Param_4_Value__c , 
            Param_6_Name__c ,Param_7_Name__c, Param_7_Value__c,  Param_1_Status__c,Param_2_Status__c,Param_3_Status__c,Param_4_Status__c,Param_5_Status__c,Param_6_Status__c,Param_7_Status__c,Param_8_Status__c, Param_8_Value__c
            FROM Vendor__c WHERE Vendor_Status__c = true  limit 1]; 
            
           
           
           
           
            system.debug('vendorlist : ' + vendorlist);
         
            for(SMS_Schedule_SMS_c__c newsms :smslist)
            {
                        if(newsms.Sender_Mobile__c!= null)
                        {
                                myphone = newsms.Sender_Mobile__c;
                         }       
                        if(newsms.SMS_Long_text__c!= null)
                        {
                            System.debug('inside LONG SMS TEXT');
                            mymsg = newsms.SMS_Long_text__c;
                        }
             }   
                mymsg = EncodingUtil.URLENCODE(mymsg,'UTF-8');
                mymsg = mymsg.replace('%2B%E2%80%9D','%20');
                mymsg = mymsg.replace('%2B%E2%80%9C','%20');
               
                system.debug('myphone: ' + myphone);
                system.debug('mymsg : ' + mymsg);
                
                      
                
               if(vendorlist.size() > 0){ //Added if condition by Vinay 24-04-2025
                if(vendorlist[0].Param_1_Status__c == TRUE && vendorlist[0].Param_2_Status__c == TRUE && vendorlist[0].Param_3_Status__c  == TRUE && vendorlist[0].Param_4_Status__c == TRUE && vendorlist[0].Param_5_Status__c  == TRUE) // && Param 6 Status  == TRUE && Param 7 Status == TRUE
                {        
                        system.debug('Inside 1st IF');
                        strURL = vendorlist[0].Vendor_URL__c + 
                        '?' + vendorlist[0].Param_1_Name__c + '=' + vendorlist[0].Param_1_Value__c+                      
                        '&' + vendorlist[0].Param_2_Name__c + '=' + vendorlist[0].Param_2_Value__c+ 
                        '&' + vendorlist[0].Param_3_Name__c + '=' + myphone +  
                        '&' + vendorlist[0].Param_4_Name__c + '=' + vendorlist[0].Param_4_Value__c+  
                        '&' + vendorlist[0].Param_5_Name__c + '=' + mymsg +
                        '&' + vendorlist[0].Param_7_Name__c + '=' + vendorlist[0].Param_7_Value__c;
                        
                }
            }
                system.debug('strURL in Handler Class : ' + strURL);  
                              
               sendSMSClass.mySMS(strURL);    
          }
         } 
}