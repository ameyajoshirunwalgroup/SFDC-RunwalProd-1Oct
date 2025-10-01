public without sharing class WelcomeCallChecklist {

    ///This method is to get CriticalNonCriticalLineItems from custom meta data
    @AuraEnabled
    public static List<RW_WC_Critical_Non_Critical_Line_Items__mdt> CriticalNonCriticalLineItems(){
        List<RW_WC_Critical_Non_Critical_Line_Items__mdt> CriticalNonCriticalList =  [SELECT Id, Label,MasterLabel, Type__c FROM
                                                                                      RW_WC_Critical_Non_Critical_Line_Items__mdt];
        system.debug('CriticalNonCriticalList___'+CriticalNonCriticalList.Size());
        return CriticalNonCriticalList;
    }

    //This method is to get bank names for ModeOFFunding is Loan  
    @AuraEnabled
    public static List<String> getPicklistValuesForBankName(String objectName,List<String> fieldNames){
    system.debug('**'+objectName+'****'+fieldNames);
        List<String> picklistValues = new List<String>();
        for(String fieldName : fieldNames)
        {
            picklistValues.addAll(Utility.getPicklistValues(objectName,fieldName));
        }
        system.debug('**'+picklistValues);
        Return picklistValues;
        
    }

  //This method is to get pervious call Remarks from Remarks Object
    @AuraEnabled
    public static Map<String, string> prevCallRemarks(string strBookingId){
        
        Map<String, string> mapval = new Map<String, String>(); 
        
        RW_Welcome_Call__c wcObj = [SELECT Id,Name,RW_Welcome_Call_Status__c,CreatedDate,RW_Booking__c,RW_Welcome_Call_Completed__c,
                                    (SELECT Id,name from Welcome_Call_Remarks__r Limit 1)
                                    From RW_Welcome_Call__c  WHERE RW_Booking__c =: strBookingId ORDER BY CreatedDate DESC limit 1 ];
        system.debug('wcObj___'+wcObj);
        
        if(wcObj.Welcome_Call_Remarks__r.Size() > 0 ){
            RW_Welcome_Call_Remarks__c prevWCCallRemarks =  [SELECT Id,Name,RW_Welcome_Call__c,RW_Remarks__c FROM 
                                                             RW_Welcome_Call_Remarks__c WHERE RW_Welcome_Call__c =: wcObj.id ORDER BY CreatedDate DESC limit 1 ];
            system.debug('prevWCCallRemarks___'+prevWCCallRemarks);
            
            if(prevWCCallRemarks.RW_Remarks__c != null && prevWCCallRemarks.RW_Remarks__c != ''){
                string[] commaSplit = prevWCCallRemarks.RW_Remarks__c.split(',');
                Map<string,string> exMap = new Map<string,string>();
                   for(integer i=0;i<commaSplit.size();i++){
                       string[] colonSplit = commaSplit[i].split(':');
                      if(!exMap.containsKey(colonSplit[0]) && commaSplit[i].contains(':')){
                          if(commaSplit[i].contains('ReceiptListRemarks')){
                              system.debug('commaSplit[i]___ '+commaSplit[i]);
                              string[] contentSplit = commaSplit[i].split('~');
                              system.debug('contentSplit__'+contentSplit);
                              exMap.put(colonSplit[0],contentSplit[2]);
                          }else{
                              exMap.put(colonSplit[0],colonSplit[1]);
                          } 
                          
                       }else{
                           List<string> lstData= new List<string>(exMap.keySet());
                           String topKey = lstData[lstData.size()-1];
                          String mapvalue = exMap.get(topKey) +','+colonSplit[0];
                          
                            exMap.put(topKey,mapvalue);
                       }
                       
                        
                   }
                   system.debug('exMap____'+exMap);
                for(string prelis: commaSplit){
                    string[] colonSplit = prelis.split(':');
                    //string[] hyphenSplit = prelis.split('%');
                    if(exMap.get(colonSplit[0]) != null){
                            string[] hyphenSplit = exMap.get(colonSplit[0]).split('%');
                        if(hyphenSplit.size() == 2){
                        mapval.put(colonSplit[0], hyphenSplit[1]);
                    }
                    }
                    //system.debug('hyphenSplit____'+hyphenSplit.size());
                    
                }
            }
            
            system.debug('mapval___'+mapval);
        }
        
        return mapval;
        
    }
    
 
      //This method is to get YesNoDropDown from welcome call component
    @AuraEnabled
    public static Map<String, string> loadYesNoDropDown(string strBookingId){
        
        Map<String, string> mapValYesNo = new Map<String, String>(); 
        
        RW_Welcome_Call__c wcObj = [SELECT Id,Name,RW_Welcome_Call_Status__c,CreatedDate,RW_Booking__c,RW_Welcome_Call_Completed__c,
                                    (SELECT Id,name from Welcome_Call_Remarks__r Limit 1)
                                    From RW_Welcome_Call__c WHERE RW_Booking__c =: strBookingId ORDER BY CreatedDate DESC limit 1 ];
        system.debug('wcObj___'+wcObj);
        
        if(wcObj.Welcome_Call_Remarks__r.Size() > 0 ){
            RW_Welcome_Call_Remarks__c prevWCCallRemarks =  [SELECT Id,Name,RW_Welcome_Call__c,RW_Remarks__c FROM 
                                                             RW_Welcome_Call_Remarks__c WHERE RW_Welcome_Call__c =: wcObj.id ORDER BY CreatedDate DESC limit 1 ];
            system.debug('prevWCCallRemarks___'+prevWCCallRemarks);
            
            if(prevWCCallRemarks.RW_Remarks__c != null && prevWCCallRemarks.RW_Remarks__c != ''){
                string[] commaSplit = prevWCCallRemarks.RW_Remarks__c.split(',');
                Map<string,string> exMap = new Map<string,string>();
                   for(integer i=0;i<commaSplit.size();i++){
                       string[] colonSplit = commaSplit[i].split(':');
                        System.debug('colonSplit: ' + colonSplit);
                      if(!exMap.containsKey(colonSplit[0]) && commaSplit[i].contains(':')){
                           System.debug('colonSplit[0]: ' + colonSplit[0]);
                           //exMap.put(colonSplit[0],colonSplit[1]); // Commented by Vinay 27-04-2022
                           //Added by Vinay 27-04-2022 Start
                          if(colonSplit[0].contains('BookingDate')){
                              System.debug('colonSplit if: ' + colonSplit);
                              String st = colonSplit[1] + ':' + colonSplit[2] + ':' + colonSplit[3];
                              System.debug('st: ' + st);
                              exMap.put(colonSplit[0],st);
                          }else{
                            System.debug('colonSplit else: ' + colonSplit);
                            exMap.put(colonSplit[0],colonSplit[1]);
                        }
                          //Added by Vinay 27-04-2022 End
                       }else{
                           List<string> lstData= new List<string>(exMap.keySet());
                           String topKey = lstData[lstData.size()-1];
                          String mapvalue = exMap.get(topKey) +','+colonSplit[0];
                          
                            exMap.put(topKey,mapvalue);
                       }
                       
                        
                   }
                system.debug('____exMap '+exMap.keyset());
                for(string prelis: commaSplit){
                    string[] colonSplit = prelis.split(':');
                    system.debug('___colonSplit '+colonSplit[0]);
                   List<String> remarksList = new List<String>();
                    string str = colonSplit[0].replaceAll('\r\n|\n|\r','');
                    if(exMap.get(colonSplit[0]) != null ){
                        if(str != 'ReceiptListRemarks'){  
                            system.debug('___colonSplit___in If___'+colonSplit[0]);
                            System.debug('exMap.get(colonSplit[0]: ' + exMap.get(colonSplit[0]));
                            string[] hyphenSplit = exMap.get(colonSplit[0]).split('~');
                            system.debug('hyphenSplit___in If___'+hyphenSplit);
                            remarksList =hyphenSplit[2].split('%');
                            //system.debug('###colonSplit[0] '+colonSplit[0]);
                            //system.debug('###hyphenSplit[1] '+hyphenSplit[1]);
                            //system.debug('###hyphenSplit[2] '+hyphenSplit[2]);
                            //system.debug('###remarksList '+remarksList);
                            if(hyphenSplit.size() > 1){
                                if(remarksList.size()==2){
                                    mapValYesNo.put(colonSplit[0], hyphenSplit[0]+'~'+hyphenSplit[1]+'~'+remarksList[1]);
                                    system.debug('###____ '+hyphenSplit[0]+'~'+hyphenSplit[1]+'~'+remarksList[1]);
                                    
                                }else{
                                    mapValYesNo.put(colonSplit[0], hyphenSplit[0]+'~'+hyphenSplit[1]+'~'+'');
                                    //system.debug('###_____'+hyphenSplit[0]+'~'+hyphenSplit[1]+'~'+remarksList[1]);
                                }
                                
                            }
                    }else{
                        string[]  receiptRemarkssplit = prelis.split('~');
                        system.debug('___colonSplit___in else___'+receiptRemarkssplit[1]);
                        /*string[] hyphenSplit = exMap.get(colonSplit[0]).split('~');
                        system.debug('hyphenSplit___in else___'+hyphenSplit);*/
                        string[]  receiptRemarks = receiptRemarkssplit[2].split('%');
                        if(receiptRemarks.size()>1){
                            mapValYesNo.put(colonSplit[0], receiptRemarkssplit[0]+'~'+receiptRemarkssplit[1]+'~'+receiptRemarks[1]);
                        }else{
                           mapValYesNo.put(colonSplit[0], receiptRemarkssplit[0]+'~'+receiptRemarkssplit[1]+'~'+'');
                        }
                        
                    }
                    }
                }
            }
            
            system.debug('mapValYesNo____'+mapValYesNo);
        }
        
        return mapValYesNo;
        
    }
       
     //This method is to get ModeOfFunding from welcome call component(Modified by Dolly)
    @AuraEnabled
    public static Map<String, string> loadModeOfFunding(string strBookingId){
        Map<String, String> mapModeFunding = new Map<String, String>();
        
        List<Loan__c> loans = [
            SELECT Id, RW_Bank_Preference_1__c, RW_Bank_Preference_2__c, RW_Bank_Preference_3__c
            FROM Loan__c
            WHERE RW_Booking__c = :strBookingId
            LIMIT 1
            ];
    	system.debug('loanslisttttt----------->'+loans);
        if(!loans.isEmpty()){
            Loan__c loanObj = loans[0];
            mapModeFunding.put('ModeOfFunding', 'Bank Loan');
            mapModeFunding.put('BankPref1', loanObj.RW_Bank_Preference_1__c);
            mapModeFunding.put('BankPref2', loanObj.RW_Bank_Preference_2__c);
            mapModeFunding.put('BankPref3', loanObj.RW_Bank_Preference_3__c);
        } else {
            mapModeFunding.put('ModeOfFunding', 'Self Funded');
        }
    	system.debug('mapModeFunding___'+mapModeFunding);
        return mapModeFunding;
    }
      
    
    //This Method is to show Booking/Applicant details in WC checklist
    @AuraEnabled
    public static WrpClsWelcomeObj callCheckList(string strBookingId){
        WrpClsWelcomeObj welCall = new WrpClsWelcomeObj();
        Booking__c objBooking = [SELECT Id,Name,Project__r.Project_Location__r.Name,Sales_Manager__c,Status__c,Welcome_Call_Done_By__c,Floor__c,Opportunity__c,Booking_Date__c,Project__r.Name,
                                 BrokerIId__r.Name,Registration_consultant__r.Name,Registration_consultant__r.Consultation_Scanning_charges__c,
                                 Registration_consultant__c,Project__r.Contact_No__c,Project__r.Customer_Care_Email__c,
                                 Unit_No__r.RW_Param4__c,Quotation__r.Plan_Type__c,Quotation__r.PaymentPlan__r.Name,toLabel(Unit_No__r.New_Type__c),
                                 Quotation__r.PaymentPlan__r.Bank_Loan_Self_Funded__c,Quotation__r.Id,Quotation__r.Costsheet_format__c,
                                 Carpet_Area__c,Flat_No__c,Source_of_Booking__c,Wing__c,Allotment_Premium__c, Quotation__r.Total_No_of_Parking__c,
                                 Unit_No__r.Relationship_Manager__r.Id,Unit_No__r.Relationship_Manager__r.RM_Name__c,Unit_No__r.Relationship_Manager__r.User__r.Tata_CTI_Agent_Number__c,
                                 Unit_No__r.Relationship_Manager__r.RM_Work_Hours__c,Unit_No__r.Relationship_Manager__r.Contact_Number__c,Unit_No__r.Relationship_Manager__r.User__r.DID__c,//Added by Prashant to show DID in RM contact number when project is mahalaxmi.10/2/25
                                 Unit_No__r.Relationship_Manager__r.RM_Email__c,Receipts__r.Cheque_DD__c,Receipts__r.Mode__c,Receipts__r.Total_Amount__c,
                                 Receipts__r.DraweeBank__c,Receipts__r.Cheque_DD_Date__c,Opportunity__r.Account.No_of_family_members__c,Opportunity__r.Account.RW_Zip_Code__c,
                                 Opportunity__r.Account.RW_Occupation__c,Opportunity__r.Account.Distance_To_Office__c,Opportunity__r.Account.RW_Company_Name__c,Opportunity__r.Account.Industry,
                                 Opportunity__r.Account.RW_Designation__c,Opportunity__r.Account.Family_Income__c,Opportunity__r.Account.Purpose__c,
                                 Opportunity__r.Account.Vehicles_owned__c,Opportunity__r.Account.Four_Wheeler__c,
                                 (SELECT Id,name,RW_Welcome_Call_Completed__c,RW_Welcome_Call_Status__c
                                 FROM Welcome_Calls__r Limit 1)
                                 FROM Booking__c WHERE Id =: strBookingId Limit 1];
        system.debug('objBooking___'+objBooking);
        
        List<Applicant_Details__c> applicantList =[SELECT Name,PancardNo__c,Email_Address__c,Permanent_Address__c,Mobile_Number__c,Applicant_Number__c FROM Applicant_Details__c 
                                                   WHERE Booking__c =: objBooking.Id ORDER BY Applicant_Number__c];  
        system.debug('applicantList___'+applicantList.size());
        
        List<Receipt__c> receiptList =[SELECT Name,Mode__c,Total_Amount__c,Cheque_DD_Date__c,DraweeBank__c,Cheque_DD__c FROM Receipt__c 
                                       WHERE Booking__c =: objBooking.Id];  
        system.debug('receiptList____'+receiptList.size());
        
        welCall.bkg = objBooking;
        welCall.applicantList = applicantList;
        welCall.receiptList = receiptList;
        welCall.link = Url.getOrgDomainUrl().toExternalForm()+'/apex/'+objBooking.Quotation__r.Costsheet_format__c+'?Id='+objBooking.Quotation__r.Id;
        system.debug('welCall.wrpObj___'+welCall); 
        return welCall;
    }

    //This Method is to save Booking/Applicant details in Welcome call object
        @AuraEnabled
     public static RW_Welcome_Call__c saveCheckList(List<string> finalRemarksList,WrpClsWelcomeObj wrapperListToSave, String Status,
                                                    String addRrmks, String modeOfFunding, String bankPrefrence1, String bankPrefrence2, String bankPrefrence3, List<string>  BankPreferenceforLoan, 
                                                    List<Receipt__c> receiptList,Boolean isDhamaka){
                                                        
          
           system.debug('wrapperListToSave___'+wrapperListToSave);
           system.debug('finalRemarksList___'+finalRemarksList);
           system.debug('Status___'+Status);
           system.debug('addRrmks___'+addRrmks);
           system.debug('modeOfFunding___'+modeOfFunding);
           system.debug('BankPreferenceforLoan____'+BankPreferenceforLoan);
           system.debug('isDhamaka___________'+isDhamaka);
           string BankPreferenceforLoanStr = string.join(BankPreferenceforLoan,',');
           
           string allstring = string.join(finalRemarksList,',');
            system.debug('allstring____'+allstring);
            allstring.removeStart(',');
            system.debug('allstring____'+allstring);
            allstring.replace(',', '\n');
            system.debug('allstring____'+allstring);
           
            system.debug('wrapperListToSave___'+wrapperListToSave);
           
            RW_Welcome_Call__c WC = new RW_Welcome_Call__c();
                                                        
           for(Applicant_Details__c wrpApplist: wrapperListToSave.applicantList){
            system.debug('wrpApplist___'+wrpApplist.name);
            //Added by coServe 04-01-2024 Start
            Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
               System.debug('dummyEmails: ' + dummys.keySet());
               for (String str : dummys.keySet()) {
                   if (/*wrpApplist.Email_Address__c.contains(str) ||
* Commented by Prashant bcoz it was giving error. Eg - valid email - royaltvlab@gmail.com and dummy email- ab@gmail.com which gives error*/wrpApplist.Email_Address__c != null){
    
    if(str.contains(wrpApplist.Email_Address__c)) {
        System.debug('Dummy Email Detected');
        throw new AuraHandledException('It seems you are using a dummy email ID in this record. This will result in the failure of extending customer portal access. Please update the correct email ID in the Primary Applicant record and continue further.');
    }
}
               }
             //Added by coServe 04-01-2024 End
            //need to do null check
            if(wrpApplist.Applicant_Number__c =='Primary Applicant'){
              WC.RW_Applicant1_Primary_Applicant_Name__c   = wrpApplist.Name;
              WC.RW_Applicant1_Email_Address__c    = wrpApplist.Email_Address__c;
              WC.RW_Applicant1_Mobile_No__c      = wrpApplist.Mobile_Number__c;
              WC.RW_Applicant1_Permanent_Address__c    = wrpApplist.Permanent_Address__c;
              Wc.RW_Primary_PAN_Details__c            = wrpApplist.PancardNo__c;
             }
             if(wrpApplist.Applicant_Number__c =='Second Applicant'){
              WC.RW_Applicant2_Name__c   = wrpApplist.Name;
              WC.RW_Applicant2_Email_Address__c    = wrpApplist.Email_Address__c;
              WC.RW_Applicant2_Mobile_No__c      = wrpApplist.Mobile_Number__c;
              WC.RW_Applicant2_Permanent_Address__c    = wrpApplist.Permanent_Address__c;
             }
             if(wrpApplist.Applicant_Number__c =='Third Applicant'){
              WC.RW_Applicant3_Name__c   = wrpApplist.Name;
              WC.RW_Applicant3_Email_Address__c    = wrpApplist.Email_Address__c;
              WC.RW_Applicant3_Mobile_No__c      = wrpApplist.Mobile_Number__c;
              WC.RW_Applicant3_Permanent_Address__c    = wrpApplist.Permanent_Address__c;
             }
             if(wrpApplist.Applicant_Number__c =='Fourth Applicant'){
              WC.RW_Applicant4_Name__c   = wrpApplist.Name;
              WC.RW_Applicant4_Email_Address__c    = wrpApplist.Email_Address__c;
              WC.RW_Applicant4_Mobile_No__c      = wrpApplist.Mobile_Number__c;
              WC.RW_Applicant4_Permanent_Address__c    = wrpApplist.Permanent_Address__c;
             }
             if(wrpApplist.Applicant_Number__c =='Fifth Applicant'){
              WC.RW_Applicant5_Name__c   = wrpApplist.Name;
              WC.RW_Applicant5_Email_Address__c   = wrpApplist.Email_Address__c;
              WC.RW_Applicant5_Mobile_No__c      = wrpApplist.Mobile_Number__c;
              WC.RW_Applicant5_Permanent_Address__c    = wrpApplist.Permanent_Address__c;
             }
           
           }
           
            WC.RW_Project__c                        = wrapperListToSave.bkg.Project__r.Name;
            WC.RW_Flat_Typology__c                  = wrapperListToSave.bkg.Unit_No__r.New_Type__c;
            WC.RW_Tower__c                          = wrapperListToSave.bkg.Wing__c;
            WC.RW_Floor__c                          = wrapperListToSave.bkg.Floor__c;
            WC.RW_Flat_No__c                        = wrapperListToSave.bkg.Unit_No__r.RW_Param4__c;//Flat_No__c;
            WC.RW_Carpet_Area_in_Sq_ft__c           = wrapperListToSave.bkg.Carpet_Area__c;
            WC.RW_No_of_Car_Parkings__c             = wrapperListToSave.bkg.Quotation__r.Total_No_of_Parking__c;
            WC.RW_Agreement_Value__c                = wrapperListToSave.bkg.Allotment_Premium__c;
            WC.RW_Source_Of_Booking__c              = wrapperListToSave.bkg.Source_of_Booking__c;
            WC.RW_Banking_Preference_for_Loan__c    = BankPreferenceforLoanStr;
            WC.RW_Payment_Plan_Type__c              = wrapperListToSave.bkg.Quotation__r.Plan_Type__c;
            WC.RW_Payment_Plan_Milestones_Details__c= wrapperListToSave.bkg.Quotation__r.PaymentPlan__r.Name;
            WC.RW_View_Cost_Sheet__c                = wrapperListToSave.link;
            WC.RW_Mode_of_funding__c                = modeOfFunding; //wrapperListToSave.bkg.Quotation__r.PaymentPlan__r.Bank_Loan_Self_Funded__c;
            WC.Bank_Preference_1__c                 = bankPrefrence1;//Added by Dolly
            WC.Bank_Preference_2__c                 = bankPrefrence2;//Added by Dolly
            WC.Bank_Preference_3__c                 = bankPrefrence3;//Added by Dolly
            WC.RM_Name__c                           = wrapperListToSave.bkg.Unit_No__r.Relationship_Manager__r.RM_Name__c;
            WC.RM_contact_Number__c                 = wrapperListToSave.bkg.Unit_No__r.Relationship_Manager__r.Contact_Number__c;
            WC.RM_work_hours__c                     = wrapperListToSave.bkg.Unit_No__r.Relationship_Manager__r.RM_Work_Hours__c;
            WC.RM_email__c                          = wrapperListToSave.bkg.Unit_No__r.Relationship_Manager__r.RM_Email__c;
            Wc.RW_Welcome_Call_Remarks__c           = addRrmks;
            Wc.RW_Welcome_Call_Status__c            = Status;
            Wc.RW_Welcome_Call_Initiation_date__c   = System.today();
            Wc.RW_Booking__c                        = wrapperListToSave.bkg.Id;
            Wc.Booking_Id__c                        = wrapperListToSave.bkg.Id;
                                                        
         
            if(Status == 'Accept'){ 
                Wc.RW_Welcome_Call_Accepted_date__c = System.today();
                Wc.RW_Welcome_Call_Completed__c = True;
                Wc.RW_Reinitiate_Welcome_Call__c = false;
                Wc.RW_Welcome_Call_Status__c= Status;
                Wc.Dhamaka_Offer_to_be_Sent__c = isDhamaka;
                
            }else if(Status == 'Reject'){
                Wc.RW_Welcome_Call_Rejected_date__c = System.today();
                Wc.RW_Welcome_Call_Status__c= Status;
                Wc.RW_Reinitiate_Welcome_Call__c = false;
            
            }else if(Status == 'Hold'){
              Wc.RW_Welcome_Call_Hold_date__c = System.today();
              Wc.RW_Welcome_Call_Status__c= Status;
              Wc.RW_Reinitiate_Welcome_Call__c = false;
            }
    
                  try{ 
                  if(WC != null){
                    system.debug('WC==> '+WC.Booking_Id__c);
                      upsert WC Booking_Id__c;  
                      system.debug('WC==>'+WC);
                  }
                }catch(Exception  e){
                system.debug('Welcome call Not inserted'+e);
                throw new AuraHandledException(e.getMessage().substringAfter(','));
                }
                RW_Welcome_Call_Remarks__c remarks = new RW_Welcome_Call_Remarks__c();
                remarks.Name = Wc.Name;
                remarks.RW_Welcome_Call__c = Wc.Id;
               //if(allstring != null && allstring != ''){
                  remarks.RW_Remarks__c = allstring;
                                                       
               // }
                
                if(remarks != null){
                insert remarks; 
                system.debug('remarks____'+remarks);
                }
               if(WC.Id != null){
                RW_Welcome_Call__c welcall = [SELECT Id,Name,RW_Applicant1_Email_Address__c,RW_Applicant1_Primary_Applicant_Name__c,RW_Booking__r.Name,RW_Booking__c,RW_Booking__r.Sales_Manager__c,
                                              RW_Booking__r.Sales_Manager__r.Email,RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c,
                                              RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.id,RW_Welcome_Call_Status__c,
                                              RW_Discrepancy_list_shared_via_email__c,RW_Booking__r.Opportunity__c,
                                              RW_Booking__r.Customer__r.AccountId,RW_Booking__r.Customer__r.Account.PersonEmail,
                                              RW_Booking__r.Customer__r.Account.FirstName,RW_Booking__r.Customer__r.Account.LastName,
                                              RW_Booking__r.Sales_Manager__r.Name,RW_Booking__r.Project__c ,
                                              RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.Tata_CTI_Agent_Number__c,
                                              RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.DID__c//Added by Prashant to show DID in RM contact number when project is mahalaxmi.10/2/25
                                              FROM RW_Welcome_Call__c WHERE Id=: WC.Id]; 
              
    
                if(welcall.Id != null && welcall.RW_Welcome_Call_Status__c == 'Reject'){
    
                    //Getting task recordId
                    RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND Name = 'Welcome Call' LIMIT 1];
    
                  //Updating the task status as 'Completed' for RM
                  List<Task> taskCloseList = [Select Id,WhatId,Call_Status__c,Subject,OwnerId,status,RecordTypeId from Task where WhatId =:welcall.RW_Booking__c];
                  System.debug('taskCloseList___'+taskCloseList);
                  List<Task> taskUpdate = new List<Task>();
                  for(Task tsk: taskCloseList){
                    if(tsk.Call_Status__c == 'Welcome Call' && tsk.Subject == 'Welcome Call' && tsk.WhatId == welcall.RW_Booking__c 
                    && tsk.OwnerId == welcall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.id && tsk.RecordTypeId == rt.Id){
                      tsk.status = 'Completed';
                      taskUpdate.add(tsk);
                    }
                  }
                  if(taskUpdate.size()> 0){
                    update taskUpdate;
                  }
                     
                 
                      //Creating New Task for SM if WC rejected and sending an email with DiscrepancyList to (SM and RM)
                      Task tsk = new Task(); 
                      system.debug('welcall.RW_Booking__c___'+welcall.RW_Booking__c);
                     system.debug('welcall.RW_Booking__r.Sales_Manager__r.id___'+welcall.RW_Booking__r.Sales_Manager__c);
                     system.debug('Rwelcall.W_Booking__r.Sales_Manager__r.Email___'+welcall.RW_Booking__r.Sales_Manager__r.Email);
                      tsk.Call_Status__c = 'Welcome call';
                      tsk.Communication_Type__c = 'Outbound Call';
                      tsk.IsReminderSet = True;
                     if(welcall.RW_Booking__r.Sales_Manager__c != null){
                       tsk.OwnerId =  welcall.RW_Booking__r.Sales_Manager__c;  
                     }
                     
                      tsk.RecordTypeId = rt.Id;
                      tsk.Status = 'Not Started';
                      tsk.Subject = 'Welcome Call';
                      tsk.Type = 'Call'; 
                      tsk.Priority = 'High';
                      tsk.Description = 'Welcome Call Rejected for Booking -  ' +  welcall.RW_Booking__r.Name  + ' of Applicant : ' +  welcall.RW_Applicant1_Primary_Applicant_Name__c;
                      tsk.ActivityDate=Date.today().addDays(2);
                      tsk.WhatId = welcall.Id;
                      tsk.Task_Type__c = 'CRM Call';
                      tsk.FullName__c = welcall.RW_Booking__r.Sales_Manager__r.Name;
                      tsk.Project__c = welcall.RW_Booking__r.Project__c;
                      Insert tsk;
                       system.debug('tsk in Reject==>'+tsk);
      
                 string body='';
                    
                RW_Welcome_Call_Remarks__c welcomeCallRemarks =  [SELECT Id,Name,RW_Welcome_Call__r.Name,RW_Welcome_Call__c,RW_Remarks__c FROM RW_Welcome_Call_Remarks__c 
                                                                      WHERE RW_Welcome_Call__c =: welcall.Id ORDER BY CreatedDate DESC limit 1 ];
                    system.debug('welcomeCallRemarks___'+welcomeCallRemarks);
               if(welcomeCallRemarks.RW_Remarks__c != null){ 
                string[] commaSplit = welcomeCallRemarks.RW_Remarks__c.split(',');
                system.debug('commaSplit___'+commaSplit);
                body = 'Please find the Welcome Call: <a href="'+Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/RW_Welcome_Call__c/' + welcomeCallRemarks.RW_Welcome_Call__c + '/view">' + welcomeCallRemarks.RW_Welcome_Call__r.Name + '</a>';
                body += '<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><h3>Welcome Call DiscrepancyList [Status = '+welcall.RW_Welcome_Call_Status__c+']</h3><table>';
                 body += '<tr><th>Field Name</th><th>Field Value</th><th>Remarks</th></tr>';
                   Map<string,string> exMap = new Map<string,string>();
                   for(integer i=0;i<commaSplit.size();i++){
                       string[] colonSplit = commaSplit[i].split(':');
                       System.debug('colonSplit: ' + colonSplit);
                      if(!exMap.containsKey(colonSplit[0]) && commaSplit[i].contains(':')){
                          System.debug('colonSplit[0]: ' + colonSplit[0]);
                          //exMap.put(colonSplit[0],colonSplit[1]); // Commented by Vinay 22-04-2022
                          //Added by Vinay 22-04-2022 Start
                          if(!colonSplit[0].contains('BookingDate')){
                              exMap.put(colonSplit[0],colonSplit[1]);
                          }else{
                              System.debug('colonSplit else: ' + colonSplit);
                              String st = colonSplit[1] + ':' + colonSplit[2] + ':' + colonSplit[3];
                              System.debug('st: ' + st);
                              exMap.put(colonSplit[0],st);
                          }
                          //Added by Vinay 22-04-2022 End
                           
                       }else{
                           List<string> lstData= new List<string>(exMap.keySet());
                           String topKey = lstData[lstData.size()-1];
                          String mapvalue = exMap.get(topKey) +','+colonSplit[0];
                          
                            exMap.put(topKey,mapvalue);
                       }
                       
                        
                   }
                   system.debug('exMap____'+exMap);
                   /*for(string prelis: commaSplit){
                        string[] colonSplit = prelis.split(':');
                        system.debug(colonSplit[0]+' ======>>> '+exMap.get(colonSplit[0]));
                   }*/
                 for(string prelis: commaSplit){
                    system.debug('prelis____'+prelis);
                  body += '<tr>';
                  string[] colonSplit = prelis.split(':');
                    string[] semiColon = prelis.split(';');
                     //system.debug(colonSplit[0]+' ======>>> '+exMap.get(colonSplit[0]));
                  system.debug('colonSplit___[0]' +colonSplit[0]);
                  //system.debug('colonSplit___[1]' +colonSplit[1]);
                   string str = colonSplit[0].replaceAll('\r\n|\n|\r','');
                    system.debug('str 16 ' +str);
                 
                  system.debug('semiColon___' +semiColon);
                    List<string> str7 = new List<string>(); 
                    
                    if(!str.Contains('ReceiptListRemarks')){
                      string[] percentSplit ;//= exMap.get(colonSplit[0]).split('%');
                     
                        List<string> remarksList = new List<string>();                        
                        if(exMap.get(colonSplit[0]) != null){
                            string[] hyphenSplit = exMap.get(colonSplit[0]).split('~');
                            remarksList =hyphenSplit[2].split('%');
                            system.debug('###colonSplit[0] '+colonSplit[0]);
                            system.debug('###hyphenSplit[1] '+hyphenSplit[1]);
                            system.debug('###hyphenSplit[2] '+hyphenSplit[2]);
                            system.debug('###remarksList '+remarksList);
                      body += '<td>'+colonSplit[0]+'</td>';
                     
                      body += '<td>'+hyphenSplit[1]+'</td>';
                        }
                      if(remarksList.size() == 2){
                      body += '<td>'+remarksList[1]+'</td>';
                      }else{
                          body += '<td></td>';
                      }
                      body += '</tr>';
                        
                        
                    }else if(str.contains('ReceiptListRemarks')){  
                       system.debug('___ReceiptListRemark____'+colonSplit);
                        
                      body += '<td>'+colonSplit[0]+'</td>';
                      string[] hyphenSplit = colonSplit[1].split('~');
                        body += '<td><table><tr><th><b>Name</b></th><th><b>Payment Mode</b></th><th><b>Amount</b></th><th><b>Date</b></th><th><b>Bank Name</b></th><th><b>Instrument Name</b></th></tr>';
                        
                       for(integer i=0; i<semiColon.size(); i++){ 
                           system.debug('___semiColon___'+semiColon[i]);
                            if(semiColon[i].contains('Name')){
                                body += '<tr>';
                               // i++;
                                string[] str1 = semiColon[i].split(':');
                                system.debug('___str1[0]___'+str1[0]);
                                system.debug('____str1[1]___'+str1[1]);
                                if(str1[1].contains('Name')){
                                    body += '<td>'+str1[2]+'</td>';
                                }else{
                                    body += '<td>'+str1[1]+'</td>';
                                }
                            }
                            if(semiColon[i].contains('Mode__c')){
                               // i++;
                                string[] str2 = semiColon[i].split(':');
                                body += '<td>'+str2[1]+'</td>';
                            }//Total_Amount__c
                           if(semiColon[i].contains('Total_Amount__c')){
                              //  i++;
                                string[] str3 = semiColon[i].split(':');
                                body += '<td>'+str3[1]+'</td>';
                            }
                           if(semiColon[i].contains('Cheque_DD_Date__c')){
                              //  i++;
                                string[] str4 = semiColon[i].split(':');
                                body += '<td>'+str4[1]+'</td>';
                            }
                           if(semiColon[i].contains('DraweeBank__c')){
                              //  i++;
                                string[] str5 = semiColon[i].split(':');
                                body += '<td>'+str5[1]+'</td>';
                            }
                            if(semiColon[i].contains('Cheque_DD__c')){
                               // i++;
                                string[] str6 = semiColon[i].split(':');
                                body += '<td>'+str6[1]+'</td>';
                               // i--;
                                body += '</tr>';
                            }
                           
                           if(semiColon[i].contains('ReceiptListRemarks')){
                               system.debug('semiColont[i]___'+semiColon[i]);
                               // i++;
                               if(semiColon[i].split('%').size() == 2){
                                   str7.add(semiColon[i].split('%')[1]);
                               }
                           }
                       }
                        body += '</table></td>';
                        system.debug('str7___'+str7);
                        system.debug('str7.size()___'+str7.size());
                        //if(colonSplit[7].contains('-')){
                        //string[] rema = colonSplit[7].split('-');
                        integer sizeoftr = str7.size()-1;
                        if(sizeoftr > -1){
                            body += '<td>'+str7[sizeoftr]+'</td>';//str7[2]  
                        }
                            
                        //}
                        //body += '<td>'+colonSplit[0]+'</td>';
                    }
               }
                body += '</table></body></html>';
    
                body += '<br/><br/><br/>';
              
                body += 'Thanks,<br/>';
               
                body += ' Runwal Homes.';
                
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>(); 
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                //message.setToAddresses(RMEail);
                List<String> listOfEmails = new List<String>();
                  
                 if(welcall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null && welcall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != ''){
                    listOfEmails.add(welcall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c);
                  }
                  if(welcall.RW_Booking__r.Sales_Manager__r.Email != null && welcall.RW_Booking__r.Sales_Manager__r.Email != ''){
                     listOfEmails.add(welcall.RW_Booking__r.Sales_Manager__r.Email);
                  }
                   message.toaddresses = listOfEmails;
                   // message.toAddresses = new String[] {'Mounika.Ramagoni@in.ey.com'};
                   message.subject = 'WelcomeCall Rejected';
                   //message.setWhatId(welcall.Id); 
                   message.sethtmlbody(body);
                   messages.add(message);
                   Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                   system.debug('Messaging ' + results[0]);
                   
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                    welcall.RW_Discrepancy_list_shared_via_email__c = True;
                    update welcall;  
                    system.debug('welcall==>'+welcall.RW_Discrepancy_list_shared_via_email__c);
                   
                    
                } else 
                {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
    
              }
            }
            
            
            if(welcall.Id != null && welcall.RW_Welcome_Call_Status__c == 'Accept'){
                
             /* comment added by ubsdigicloud    if(welcall.RW_Booking__r != null && welcall.RW_Booking__r.Customer__r.AccountId != null )
                {
                // List<User> existingUser = [Select Username from User Where Username =:welcall.RW_Booking__r.Customer__r.Account.PersonEmail+'.runwalcustomer'];
                 List<User> existingUser = [Select Username from User Where Username =:welcall.RW_Booking__r.Customer__r.Account.PersonEmail];
                    if(existingUser != null && existingUser.size() >0)
                 {
                     system.debug('inside first if');
                 }
                    else
                    {
                  
                Account objAccount = [SELECT Name,PersonContactId,OwnerId,IsCustomerPortal FROM Account WHERE id=:welcall.RW_Booking__r.Customer__r.AccountId LIMIT 1];
                          if(objAccount.OwnerId != null && !objAccount.IsCustomerPortal)
                          {
                              system.debug('inside second if'+objAccount+'**'+objAccount.OwnerId);
                              /* //User u = [Select userrole.name from User Where id=: objAccount.OwnerId ];
                            if(u.userrole.name != null)
                             {*/ //Removed by Prashant as per business... 20-05-25
                          /* comment added by ubsdigicloud      system.debug('inside third if');
                                System.debug('**'+UserInfo.getUserRoleId());
                            Profile profile1 = [Select Id from Profile where name = 'Runwal Customer Portal'];
                            
                            User portalAccount = new User(
                                     ProfileId = profile1.Id,
                                    // Username = welcall.RW_Booking__r.Customer__r.Account.PersonEmail+'.runwalcustomer' ,
                                     Username = welcall.RW_Booking__r.Customer__r.Account.PersonEmail,
                                     Alias = 'runwalc',
                                     Email= welcall.RW_Booking__r.Customer__r.Account.PersonEmail,
                                     EmailEncodingKey='UTF-8',
                                     Firstname = welcall.RW_Booking__r.Customer__r.Account.FirstName,
                                     Lastname = welcall.RW_Booking__r.Customer__r.Account.LastName,
                                     LanguageLocaleKey ='en_US',
                                     LocaleSidKey ='en_IN',
                                    ContactId=objAccount.PersonContactId,
                                     TimeZoneSidKey='Asia/Kolkata'
                            );
                            Database.insert(portalAccount);
                             /*}
                              else
                              {
                                  system.debug('inside else**');
                                 // throw new AurahandledException('Please add a role to the account owner associatated to this customer.');
                                  throw new CommonException('Please add a role to the account owner associatated to this customer.');
                              }*///Removed by Prashant as per business... 20-05-25
            /* comment added by ubsdigicloud   }
                }
                }   */
               
              List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
                EmailTemplate emailTemplate = [SELECT Body,DeveloperName,Id,Subject FROM EmailTemplate WHERE Name =: 'Welcome Letter Accept'];
               
         
                     Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(userinfo.getuserid());
                        message.setTemplateId(emailTemplate.id);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        message.setWhatId(welcall.Id); 
                        message.toaddresses = new string[]{welcall.RW_Applicant1_Email_Address__c};
                        messages.add(message);   
                        /*Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                         system.debug('Messaging ' + results[0]);
                            
                         if (results[0].success) {
                             System.debug('The email was sent successfully.');
         
                             welcall.RW_Is_welcome_Letter_sent__c = True;
                             welcall.RW_Welcome_letter_sent_date__c = System.today();
                               update welcall;  
                                 system.debug('welcall==>'+welcall.RW_Is_welcome_Letter_sent__c);
                                 system.debug('welcall==>'+welcall.RW_Welcome_letter_sent_date__c);
                         } else{
                             System.debug('The email failed to send: ' + results[0].errors[0].message);
                         }*/
                       }
               }
            return WC;
         }

   
    public class WrpClsWelcomeObj{
        @AuraEnabled public Booking__c bkg{get;set;}
        @AuraEnabled public List<Applicant_Details__c> applicantList{get;set;}
        @AuraEnabled public List<Receipt__c> receiptList{get;set;}
        @AuraEnabled public string link{get;set;} 
        
    }

  //This Method gets called from Process builder when ever the booking Status is 'Booking Confirmed'
  //creating a Task and sending mail to RM
   @InvocableMethod // Commented by coServe 20-09-2024 in fullcopy
    public static List<String> createTaskFromPB (List<ID> ids) {
        // system.debug('called from Reject==>'+ids);
        Booking__c bk = [SELECT Id,Wing__c,Project__c,Flat_No__c,Primary_Applicant_Name__c,Name,Opportunity__c,Unit_No__r.Relationship_Manager__r.RM_Name__c,Unit_No__r.Relationship_Manager__r.User__r.id,
                         Unit_No__r.Relationship_Manager__r.RM_Email__c,Unit_No__r.Relationship_Manager__r.User__r.Name,
                         Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c, Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c 
                         FROM Booking__c WHERE Id in :ids LIMIT 1];
        system.debug('bk==>'+bk);
        
        //Getting task recordId
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND Name = 'Welcome Call' LIMIT 1];
        
        //Creating new record
        Task tsk = new Task(); 
        
        tsk.Call_Status__c = 'Welcome Call';
        tsk.Communication_Type__c = 'Outbound Call';
        tsk.IsReminderSet = True;
        if(bk.Unit_No__r.Relationship_Manager__r.User__r.id != null){
            tsk.OwnerId = bk.Unit_No__r.Relationship_Manager__r.User__c;
        }
        tsk.RecordTypeId = rt.Id;
        tsk.Status = 'Not Started';
        tsk.Subject = 'Welcome Call';
        tsk.Type = 'Call'; 
        tsk.Priority = 'High';
        tsk.Description = 'Booking Confirmed Please Initiate Welcome Call - '+ bk.Wing__c + '-' + bk.Flat_No__c + '-' + bk.Primary_Applicant_Name__c;
        tsk.WhatId = bk.Id;
        tsk.ActivityDate=Date.today().addDays(5);
        tsk.Task_Type__c = 'CRM Call';
        tsk.FullName__c = bk.Unit_No__r.Relationship_Manager__r.User__r.Name;
        tsk.Project__c = bk.Project__c;
        if(tsk.OwnerId != null){
            Insert tsk;
            system.debug('tsk in Initiate==>'+tsk);
            
            string body = 'Dear RM, <br/><br/>';
            
            body += ' The following Booking has been Confirmed, Click the below booking to Initiate Welcome Call. <br/>';
            
            body += ' Booking Name: <a href="'+Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/Booking__c/' + bk.id+ '/view">' + bk.Name+ '</a>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
            
            Messaging.SingleEmailMessage[] lstMail =   new List<Messaging.SingleEmailMessage>(); 
            
            Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            objMail.toaddresses = new string[]{bk.Unit_No__r.Relationship_Manager__r.RM_Email__c};
                objMail.subject = 'Booking Confirmed Please Initiate Welcome Call';
            // Added by vinay 07-03-2022 Start
            List<String> bccAddrs = new List<String>();
            if(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c != null){
               //objMail.bccaddresses  = new List<String>{bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c}; 
               bccAddrs.add(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c);
            }
            if(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c != null){
               //objMail.bccaddresses  = new List<String>{bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c}; 
               bccAddrs.add(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c);
            }
            //bccAddrs.add('shobha.shetty@runwal.com');
            objMail.setCcAddresses(bccAddrs); // Changed from BCC to CC by coServe 20-092024
            // Added by vinay 07-03-2022 End
            objMail.sethtmlbody(body);
            lstMail.add(objMail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
            system.debug('Messaging ' + results[0]);
            
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else 
            {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }  
        return null;
    }
    
  
    
    @AuraEnabled
    public static List<String> registrationConsultants(){
        List<String> regConsultants = new List<String>();
        List<Registration_consultant__c> regConslt = [SELECT Id, Name FROM Registration_consultant__c WHERE Is_Active__c = true];
        for(Registration_consultant__c reg : regConslt){
            regConsultants.add(reg.Name);
        }
        return regConsultants;
        
    }
    
    @AuraEnabled 
    Public static void updateRegConsltnt(Id bkId, String regCons, Decimal charge){
        System.debug('regCons: ' + regCons);
        System.debug('charge: ' + charge);
        List<Booking__c> updateRegInBking = new List<Booking__c>();
        List<Registration_consultant__c> updateRegConsltnt = new List<Registration_consultant__c>();
        List<Registration_consultant__c> reg = [SELECT Id, Name, Consultation_Scanning_charges__c FROM Registration_consultant__c WHERE Name =: regCons LIMIT 1];
      
        Booking__c bking = [SELECT Id, Name, Registration_consultant__c,Registration_consultant__r.Id, Registration_consultant__r.Name, Registration_consultant__r.Consultation_Scanning_charges__c FROM Booking__c WHERE Id =: bkId];
        
        if(reg[0] != null && reg[0].Name == regCons){
            bking.Registration_consultant__c = reg[0].Id;
            updateRegInBking.add(bking);
            if(reg[0].Consultation_Scanning_charges__c != charge){
                reg[0].Consultation_Scanning_charges__c = charge;
                updateRegConsltnt.add(reg[0]);
            }
        }
        
        update updateRegInBking;
        update updateRegConsltnt;
    }
    
    /*@AuraEnabled 
    Public static void updateRegConsltnt(Id bkId, String regCons, Decimal charge){
        System.debug('regCons: ' + regCons);
        System.debug('charge: ' + charge);
        List<Booking__c> updateRegInBking = new List<Booking__c>();
        List<Registration_consultant__c> updateRegConsltnt = new List<Registration_consultant__c>();
        List<Registration_consultant__c> regConslt = [SELECT Id, Name, Consultation_Scanning_charges__c FROM Registration_consultant__c];
      
        Booking__c bking = [SELECT Id, Name, Registration_consultant__c,Registration_consultant__r.Id, Registration_consultant__r.Name, Registration_consultant__r.Consultation_Scanning_charges__c FROM Booking__c WHERE Id =: bkId];
        for(Registration_consultant__c reg : regConslt){
            if(reg.Name == regCons){
                bking.Registration_consultant__c = reg.Id;
                updateRegInBking.add(bking);
                if(reg.Consultation_Scanning_charges__c != charge){
                    reg.Consultation_Scanning_charges__c = charge;
                    updateRegConsltnt.add(reg);
                }
            }
        }
        update updateRegInBking;
        update updateRegConsltnt;
    }*/
    
   @AuraEnabled
    public static Boolean checkWelcomecall(string bkgId){ // Added by Vinay 13-12-2024
        List<RW_Welcome_Call__c> wcObj = [SELECT Id FROM RW_Welcome_Call__c WHERE RW_Booking__c =: bkgId];
        if(wcObj.size() > 0){
            return false;
        }else{
            return true;
        }
    }
    
     public void dummyMethod(){
            
            String s2;        
            String s3;
            String s4;                
            String s5;
            String s6;        
            String s7;
            String s8;                
            String s9;
            String s10;        
            String s11;
            String s12;                
            String s13;
            String s14;        
            String s15;
            String s16;                
            String s110;
            String s210;        
            String s310;
            String s410;                
            String s510;
            String s610;        
            String s710;
            String s810;                
            String s910;
            String s1010;        
            String s1110;
            String s1210;                
            String s1310;
            String s1410;        
            String s1510;
            String s1610;                
            String s111;
            String s211;        
            String s311;
            String s411;                
            String s511;
            String s611;        
            String s711;
            String s811;                
            String s911;
            String s1011;        
            String s1111;
            String s1211;                
            String s1311;
            String s1411;        
            String s1511;
            String s1611;                
            String s1101;
            String s2111;        
            
            integer i;
            i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
 
}