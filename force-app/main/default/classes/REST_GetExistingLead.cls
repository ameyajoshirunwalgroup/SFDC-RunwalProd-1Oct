@RestResource(urlMapping='/NPS/GetLeadId/*')
    
global with sharing class REST_GetExistingLead 
{
    global static final String PARAM_MISSING = 'MISSING REQUIRED PARAMETERS';
    global static final String LEAD_FOUND = 'TRUE';
    global static final String ACCOUNT_FOUND = 'TRUE';
    global static final String NOTHING = 'FALSE';

    @HttpPost
    global static REST_result GetId(String mobileNumber) 
    {
        REST_result r = new REST_Result();
        String mobile=mobileNumber;
        
        if(string.isBlank(mobileNumber)) 
        {
            r.returnCode = 1;
            r.message =PARAM_MISSING;
            return r;
        } 
        else 
        {
           List<Lead>ll=new List<Lead>();
           List<Account>al=new List<Account>();
    
           if (String.isNotBlank(mobile)) 
           {
               ll=[select id,name,IsConverted from Lead where RW_Mobile_No__c=:mobile OR Phone=:mobile];  
               System.debug('The size of ll is :'+ll);
               
               if(ll.size()>0&&ll[0].IsConverted==false)
               {
                   System.debug('Lead found');
                   r.returnCode = 2;
                   r.message =LEAD_FOUND;
                   r.recordId =ll[0].id;
                   //return r; 
               }
               else
               {
                   al=[select id,name from Account where Mobile_No__c=:mobile OR RW_Secondary_Mobile_No__pc=:mobile];
                   if(al.size()>0)
                   {
                       System.debug('Account Found');
                       r.returnCode = 3;
                       r.message =ACCOUNT_FOUND;
                       r.recordId =al[0].id;
                       //return r;
                   }
                   else
                   {
                       System.debug('Nothing Found');
                       r.returnCode = 4;
                       r.message =NOTHING;
                       
                       
                   }
              }
               
            }
    
        } return r;
   }
   
   global class REST_result 
   {
        webservice Integer returnCode;
        webservice String message;
        webservice String recordId;
        
   } 
   
}