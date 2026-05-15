public class GenerateOtpControllerforProspect {
    
     public string OTPNumber {get;set;}
     public OTP__c otpobj{get;set;}
     public  string prosId{get;set;}   
     public boolean otp{get;set;}
     public integer xx {get;set;}
    // public Prospect__c prosobj {get;set;}
     public List<Prospect__c> lstpros{get;set;}
     public List<Opportunity> lstopp{get;set;}

    public GenerateOtpControllerforProspect()
     {    
      
        prosId= ApexPages.currentPage().getParameters().get('id'); 
        otpobj = new OTP__c();
         
         lstpros = [Select id,Name,Project__c,Last_Call_Attempt_Status__c,call_proposed_date_of_visit__c,Channel_Partner__c,Channel_Partner__r.Name,
                   Sales_Call_Attempt_Status__c,Sales_Call_Proposed_Date_Of_Visit__c, Account__c,Lead__c,Lead__r.IsConverted, Opportunity__c , Lead__r.RW_Project__c,
                   First_CRM_Call_Attempt_Status__c,Last_CRM_Call_Attempt_Status__c,CRM_Call_Proposed_Date_Of_Visit__c,Sourcing_Manager__c,Channel_Partner__r.Account__c,Customer_Reference__c,Customer_Reference__r.name,Lead_Sub_Source__c,Lead_Source__c,is_Converted__c,
                    Opportunity__r.RW_Opportunity_Status__c, Temp_Channel_Partner__c,Sourcing_Manager_LU__c
                    
                   From Prospect__c Where Id =:prosId];
    		     system.debug('lstpros' +lstpros );
      
         if(lstpros[0].Lead__c != null  || lstpros[0].Opportunity__c != null ||  lstpros[0].Account__c != null )
             {
                 otp= true;
             }
                                        
         if((lstpros[0].Sales_Call_Attempt_Status__c != null && lstpros[0].Sales_Call_Attempt_Status__c == 'Visit confirmed'|| lstpros[0].Sales_Call_Attempt_Status__c == 'Visit proposed') 
                ||( lstpros[0].Last_Call_Attempt_Status__c != null && lstpros[0].Last_Call_Attempt_Status__c == 'Visit Scheduled'|| lstpros[0].Last_Call_Attempt_Status__c == 'Visit Scheduled')
                &&( lstpros[0].Lead__c != null && lstpros[0].Lead__r.IsConverted == false || lstpros[0].Opportunity__c != null ||    
                   lstpros[0].Account__c != null )&& lstpros[0].Sales_Call_Proposed_Date_Of_Visit__c !=null)
                 {
                   otpobj.Customer_Site_Visit_On__c = string.valueof(lstpros[0].Sales_Call_Proposed_Date_Of_Visit__c);                                
                 }
           else if ((lstpros[0].Last_Call_Attempt_Status__c != null && lstpros[0].Last_Call_Attempt_Status__c == 'Visit Scheduled' || lstpros[0].Last_Call_Attempt_Status__c == 'Visit Scheduled')  ||
                    (lstpros[0].Sales_Call_Attempt_Status__c != null && lstpros[0].Sales_Call_Attempt_Status__c == 'Visit proposed'|| lstpros[0].Sales_Call_Attempt_Status__c == 'Visit confirmed')&&
                    (lstpros[0].Opportunity__c != null ||  lstpros[0].Account__c != null ||
                    lstpros[0].Lead__c != null && lstpros[0].Lead__r.IsConverted == false )&& lstpros[0].call_proposed_date_of_visit__c != null)
                 {
                    otpobj.Customer_Site_Visit_On__c = string.valueOf(lstpros[0].call_proposed_date_of_visit__c);
                 }
         
         else if((lstpros[0].Last_CRM_Call_Attempt_Status__c != null && lstpros[0].Last_CRM_Call_Attempt_Status__c == 'Visit proposed'|| lstpros[0].Last_CRM_Call_Attempt_Status__c == 'Visit confirmed')||
                 (lstpros[0].Last_Call_Attempt_Status__c != null && lstpros[0].Last_Call_Attempt_Status__c == 'Visit Scheduled' || lstpros[0].Last_Call_Attempt_Status__c == 'Visit Scheduled')  ||
                 (lstpros[0].Sales_Call_Attempt_Status__c != null && lstpros[0].Sales_Call_Attempt_Status__c == 'Visit confirmed'|| lstpros[0].Sales_Call_Attempt_Status__c == 'Visit proposed')&&
 				 (lstpros[0].Lead__c != null && lstpros[0].Lead__r.IsConverted == false || lstpros[0].Opportunity__c != null ||    
                  lstpros[0].Account__c != null )&& lstpros[0].CRM_Call_Proposed_Date_Of_Visit__c !=null)
                 {
                   otpobj.Customer_Site_Visit_On__c = string.valueof(lstpros[0].CRM_Call_Proposed_Date_Of_Visit__c);                                
                 }
                    
            else  {
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning,'This Customer does not have any site visit confirmed yet');
                 ApexPages.addMessage(myMsg);
                otp = false;
                 }
         system.debug('inside if else:' +otpobj.Customer_Site_Visit_On__c );    
            if(lstpros[0].Opportunity__c != Null && lstpros[0].Opportunity__r.RW_Opportunity_Status__c == 'Active'){    // Added by Sheetal on 18/1/2023 issue - I0289
                 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Active Opportunity is present on this prospect.');
                 ApexPages.addMessage(myMsg);
                 otp = false;
         }
         
         if(lstpros[0].Lead__r.RW_Project__c == null){ //Added by coServe 05-03-2024
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please add the Project in Lead.');
             ApexPages.addMessage(myMsg);
             otp = false;
         } 

 
     } 
             
    public void sendOTP()
     {   
        do{
           Double x = Math.random(); 
           long y = Math.round(x*100000);
           xx = String.valueOf(y).length();
           OTPNumber = String.valueOf(y);
       } while( xx < 5 );
                        
         try{                        
             otpobj.Generated_OTP__c = OTPNumber;
             otpobj.OTP_Generated_on__c = string.valueOf(system.now());
             otpobj.User_Info__c = userinfo.getFirstName() +' '+userinfo.getLastName();
             otpobj.Prospect__c = prosId;
             otpobj.Project__c = lstpros[0].Project__c;
             otpobj.User__c = UserInfo.getUserId();

             /*if(lstpros[0].Sourcing_Manager__c != Null)				//Added by Sheetal on 07/07/2022 to solve issue I0200 -Take Sourcing Manager from Prospect on OTP record.
             {
                 otpObj.Sourcing_Manager__c = lstpros[0].Sourcing_Manager__c;
             }*/ //Commented by Vinay 25-11-2025
             if(lstpros[0].Sourcing_Manager_LU__c != Null){ //Added by Vinay 25-11-2025
                 otpObj.Sourcing_Manager_LU__c = lstpros[0].Sourcing_Manager_LU__c;
             }
           if(otpObj.OTP_Generate_For__c == 'Referral' && lstpros[0].Lead_Source__c == 'Referral'  && lstpros[0].Lead_Sub_Source__c == 'Existing client reference' &&  lstpros[0].Customer_Reference__c != null){
               otpObj.Customer_Reference_Lookup__c = lstpros[0].Customer_Reference__c;
               otpObj.Referral_Sub_Source__c = lstpros[0].Lead_Sub_Source__c;
               
               lstopp = [Select Id,StageName,RW_Booking_Date_Opp__c, Name,SAP_Customer_Number__c,AccountId,RW_Project_Unit__c From Opportunity Where StageName =:'Unit Booked' AND AccountId =:lstpros[0].Customer_Reference__c ORDER BY RW_Booking_Date_Opp__c  DESC ];
               system.debug('lstopp ::'+lstopp);
               if(lstopp.size()>0){
                otpObj.Customer_reference_SAP_Code__c = lstopp[0].SAP_Customer_Number__c;
			    otpObj.Customer_reference_Booked_Unit__c = lstopp[0].RW_Project_Unit__c;
               }
           }
            /* if(otpObj.OTP_Generate_For__c == 'Referral' && lstpros[0].Lead_Source__c == 'Referral' && lstpros[0].Lead_Sub_Source__c == 'Existing client reference' && lstpros[0].Customer_Reference__c != null){
             lstopp = [Select Id,StageName,RW_Booking_Date_Opp__c, Name,SAP_Customer_Number__c,AccountId,RW_Project_Unit__c From Opportunity Where StageName =:'Unit Booked' AND AccountId =:lstpros[0].Customer_Reference__c ORDER BY RW_Booking_Date_Opp__c  DESC ];
             system.debug('lstopp ::'+lstopp);
               if(lstopp.size()>0){
                      otpObj.Customer_reference_SAP_Code__c = lstopp[0].SAP_Customer_Number__c;
					  otpObj.Customer_reference_Booked_Unit__c = lstopp[0].RW_Project_Unit__c;
               }
            
         }*/
             if(lstpros[0].Channel_Partner__c != null){
                 otpObj.CP_Name__c = 'Channel Partner Name: '+lstpros[0].Channel_Partner__r.Name;
             	 otpObj.Channel_Partner_Lookup__c = lstpros[0].Channel_Partner__c;
            	 List<Account> accList = [select id,name,Channel_Partner__c from Account where Channel_Partner__c =:lstpros[0].Channel_Partner__c ];
                 if(accList.size() > 0){							//Added by Sheetal on 16/09/2022
                 	otpObj.Account__c = accList[0].id ;   
                 }
             }
             if(lstpros[0].Temp_Channel_Partner__c != null){ //Added by coServe 07-02-2024
             	 otpObj.Temp_Channel_Partner__c = lstpros[0].Temp_Channel_Partner__c;
             }
             insert otpobj;
         
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'OTP Generated Successfully');
             ApexPages.addMessage(myMsg);
             
             system.debug('OTP:' + otpobj);
            }
                  
         catch(DmlException e)
         {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Input.');
            ApexPages.addMessage(myMsg);  
             system.debug('The following exception has occurred: ' + e.getMessage());
             }      
         otp=false;

  }
    
    public PageReference Back(){

    PageReference prospectobjpage = new pageReference('/' + prosId);
        prospectobjpage.setRedirect(true);
        return prospectobjpage;
    }
}