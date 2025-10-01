public class NOCTemplateControllerNew {
    
    public List<RW_NOC_Template__c> nocRecord;
    public RW_NOC_Template__c noc{get;set;}
    public Loan__c loanRecord{get;set;}
    public Boolean isError{get;set;}
    public String loanId{get;set;}
    
    public NOCTemplateControllerNew(){
        
        Boolean isError = false;
        loanId = ApexPages.currentpage().getParameters().get('id');
        Map<String, NOC_Variable_Mapping__c> nocVar = NOC_Variable_Mapping__c.getall();
        String qryStr = '';
        Set<String> fields = new Set<String>();
        for(String str : nocVar.keySet()){
            if(nocVar.get(str).Field__c != null && nocVar.get(str).Field__c != ''){
                fields.add(nocVar.get(str).Field__c);
            }
        }
        for(String str : fields){
            qryStr += ', ' + str;
        }
        System.debug('qryStr: ' + qryStr);
        
        String qry = 'SELECT Id, RW_Sanction_Letter_ID__c, RW_Booking__c, RW_Booking__r.Quotation__r.Grand_Total__c, RW_Booking__r.RW_Registration_Status__c, RW_Loan_Record_Status__c, RW_NOC_Generated__c' + qryStr +  ' FROM Loan__c WHERE Id = : loanId LIMIT 1';
        if(!Test.isRunningTest()){
            loanRecord =  Database.query(qry);
        }else{
            loanRecord = [select id, name, RW_Bank_Branch__c,RW_Sanction_Letter_ID__c, RW_Bank_Name__c,RW_Booking__c, RW_Project_Name__r.name, RW_Booking__r.Unit_No__r.Carpet_Area__c, RW_Booking__r.Unit_No__r.Deck_Area__c, RW_Booking__r.Booking_Date__c,
                          RW_Booking__r.Unit_No__r.Utility_Area__c, RW_Booking__r.RW_Signed_Agreement_to_Customer_Date__c, RW_Booking__r.Unit_No__r.New_Floor__c,
                          RW_Booking__r.Unit_No__r.TowerName__r.name, RW_Booking__r.Quotation__r.Grand_Total__c, RW_Booking__r.Unit_No__r.RW_Param4__c, RW_Booking__r.Quotation__r.Agreement_Value__c, RW_Booking__r.RW_Registration_Status__c, RW_Loan_Record_Status__c, RW_NOC_Generated__c ,
                          RW_Project_Name__r.RDS_Company_Code__r.Account_Name_Flat_Cost__c , RW_Project_Name__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c,						  
                          RW_Project_Name__r.RDS_Company_Code__r.Account_Name_Service_Tax__c , RW_Project_Name__r.RDS_Company_Code__r.Account_Number_Service_tax__c
                          from Loan__c 
                          WHERE Id = : ApexPages.currentpage().getParameters().get('id') LIMIT 1];
        }
        
        List<Booking__c> bookingR = [select id, name, (select id, Name from ApplicantDetails__r) from Booking__c where id =:loanRecord.RW_Booking__c];
        
        List<String> ApplicantsName = new List<String>();
        string applicantsNames = null;
        
        if(bookingR.size()>0){
            for(Booking__c book : bookingR){
                for(Applicant_Details__c app : book.ApplicantDetails__r){
                    system.debug('Applicant Details --> ' + app);
                    ApplicantsName.add(app.Name);
                    system.debug('ApplicantsName in the List' + ApplicantsName);
                }  
            }
            applicantsNames = String.join(ApplicantsName, ' AND ');
            system.debug('applicantsNames' + applicantsNames);
        }
        
        nocRecord = [SELECT id,name,RW_Template__c,RW_Keyword__c,RW_Runwal_Logo__c , RW_Project__r.RDS_Company_Code__r.Name , RW_Project__r.RDS_Company_Code__r.RDS_Company_Name__c
                     from RW_NOC_Template__c WHERE RW_Bank_Name__c =: loanRecord.RW_Bank_Name__c AND RW_Project__c =: loanRecord.RW_Project_Name__c];
        system.debug('nocrecord -->'+ nocRecord);
        if(nocRecord!=null && nocRecord.size()>0){
            system.debug('nocrecord inside -->'+ nocRecord);
            noc = nocRecord[0];
            //  nocText = nocRecord[0].RW_Template__c;
        }
        // First create Map<String,String>
        Map<String,String> keywordValueMap = new Map<String,String>();
        
        
        
        //string AgreementAmountInWords =  S_NumberToWord.convertNumbertoWords(loanRecord.RW_Booking__r.Quotation__r.Agreement_Value__c);
        //system.debug('AgreementAmountInWords-->'+ AgreementAmountInWords);
        
        //Added by coServe 11-01-2024 Start
        List<String> Keywords = noc.RW_Keyword__c.split(',');
        //Map<String, NOC_Variable_Mapping__c> nocVar = NOC_Variable_Mapping__c.getall();
        Map<String,String> dataValues = new Map<String, String>();
        for(String str : nocVar.keySet()){
            System.debug('--: ' + nocVar.get(str).Field__c);
            String field = nocVar.get(str).Field__c;
            System.debug('field: ' + field);
            List<String> strSplit = new List<String>();
            if(field != null && field != ''){
                strSplit = field.split('\\.');
            }
            
            System.debug('size: ' + strSplit);
            String value;
            if(Keywords.contains(str)){
                
                
                if(strSplit.size() == 1){
                    if(loanRecord.get(nocVar.get(str).Field__c) != null && loanRecord.get(nocVar.get(str).Field__c) != ''){
                        if(nocVar.get(str).Is_Date__c){
                            value = String.valueof(Date.valueof(loanRecord.get(nocVar.get(str).Field__c)).format());
                        }else{
                            value = String.valueof(loanRecord.get(nocVar.get(str).Field__c));
                        }
                    }else{
                        noc.RW_Template__c = '<h3> The value is missing for : ' + str.subString(1,str.length()-1) + ' : ' + strSplit[0] + ' </h3>';
                        isError = true;
                    }
                }else if(strSplit.size() == 2){
                    if(loanRecord.getSObject(strSplit[0]).get(strSplit[1]) != null && loanRecord.getSObject(strSplit[0]).get(strSplit[1]) != ''){
                        if(nocVar.get(str).Is_Date__c){
                            value = String.valueof(Date.valueof(loanRecord.getSObject(strSplit[0]).get(strSplit[1])).format());
                        }else{
                            value = String.valueof(loanRecord.getSObject(strSplit[0]).get(strSplit[1]));
                        }
                    }else{
                        System.debug('str: ' + str);
                        noc.RW_Template__c = '<h3> The value is missing for : ' + str.subString(1,str.length()-1) + ' : ' + strSplit[0] + '.' + strSplit[1] + '</h3>';
                        isError = true;
                    }
                }else if(strSplit.size() == 3){
                    if(loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).get(strSplit[2]) != null && loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).get(strSplit[2]) != ''){
                        if(nocVar.get(str).Is_Date__c){
                            value = String.valueof(Date.valueof(loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).get(strSplit[2])).format());
                        }else{
                            value = String.valueof(loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).get(strSplit[2]));
                        }  
                    }else{
                        noc.RW_Template__c = '<h3> The value is missing for : ' + str.subString(1,str.length()-1) + ' : ' + strSplit[0] + '.' + strSplit[1] + '.' + strSplit[2] + '</h3>';
                        isError = true;
                    }
                }else if(strSplit.size() == 4){
                    if(loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).getSObject(strSplit[2]).get(strSplit[3]) != null && loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).getSObject(strSplit[2]).get(strSplit[3]) != ''){
                        if(nocVar.get(str).Is_Date__c){
                            value = String.valueof(Date.valueof(loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).getSObject(strSplit[2]).get(strSplit[3])).format());
                        }else{
                            value = String.valueof(loanRecord.getSObject(strSplit[0]).getSObject(strSplit[1]).getSObject(strSplit[2]).get(strSplit[3]));
                        }
                    }else{
                        noc.RW_Template__c = '<h3> The value is missing for : ' + str.subString(1,str.length()-1) + ' : ' + strSplit[0] + '.' + strSplit[1] + '.' + strSplit[2] + '.' + strSplit[3] + '</h3>';
                        isError = true;
                    }
                }
                /*if(str == '[AgreementAmountInWords]_Fixed'){
                value = S_NumberToWord.convertNumbertoWords(Decimal.valueof(value));
                }*/
                if(isError == false){
                    /*if(str == '[ApplicantNames]_Fixed'){
                    value = applicantsNames;
                    }
                    if(str == '[Today]_Fixed'){
                    value = String.valueOf(system.today().format());
                    }*/
                    if(nocVar.get(str).In_Words__c){
                        value = S_NumberToWord.convertNumbertoWords(Decimal.valueof(value).setscale(0));
                    }
                    if(nocVar.get(str).Multiplier__c != null){
                        value = String.valueOf(Decimal.valueof(value) * nocVar.get(str).Multiplier__c);
                    }
                    if(nocVar.get(str).Decimal_Places__c != null){
                        value = String.valueOf(Decimal.valueof(value).setscale(Integer.valueOf(nocVar.get(str).Decimal_Places__c)));
                    }
                }
                
                
                System.debug('value: ' + value);
                dataValues.put(str.split('_')[0],value);
            }
            if(str == '[ApplicantNames]_Fixed'){
                value = applicantsNames;
                dataValues.put(str.split('_')[0],value);
            }
            if(str == '[Today]_Fixed'){
                value = String.valueOf(system.today().format());
                dataValues.put(str.split('_')[0],value);
            }
        }
        for(String key : Keywords){
            if(dataValues.keySet().contains(key)){
                KeywordValueMap.put(key,dataValues.get(key));
            }else{
                noc.RW_Template__c = '<h3> The key word '+ key + ' not present in Custom settings(NOC Variable Mapping) </h3>';
                isError = true;
            }
        }
        System.debug('KeywordValueMap: ' + KeywordValueMap);
        
        system.debug('BranchName-->' + loanRecord.RW_Bank_Branch__c);
        
        if(noc!=null && isError == false){
            List<String> KeywordList = noc.RW_Keyword__c.split(',');
            system.debug(KeywordList+'^^^^^^^^^^^^^^^^^^^^^^66');
            
            if(loanRecord.RW_Booking__r.Unit_No__r.Carpet_Area__c!=null || loanRecord.RW_Project_Name__r.name!=null || loanRecord.RW_Booking__r.Unit_No__r.Deck_Area__c!=null || 
               loanRecord.RW_Booking__r.Unit_No__r.Utility_Area__c!=null || loanRecord.RW_Bank_Name__c!=null || loanRecord.RW_Booking__r.Unit_No__r.New_Floor__c!=null || loanRecord.RW_Booking__r.Unit_No__r.TowerName__r.name!=null ||
               loanRecord.RW_Booking__r.Quotation__r.Grand_Total__c!=null || loanRecord.RW_Booking__r.Quotation__r.FlatNo__c!=null || loanRecord.RW_Booking__r.Quotation__r.Agreement_Value__c!=null || loanRecord.RW_Bank_Branch__c!=null ){
                   system.debug('map of keyword ' + keywordValueMap);
                   system.debug('inside if carper area all '+ loanRecord.RW_Booking__r.Unit_No__r.Carpet_Area__c + loanRecord.RW_Booking__r.Unit_No__r.Deck_Area__c + loanRecord.RW_Booking__r.RW_Registration_Status__c + loanRecord.RW_Loan_Record_Status__c + loanRecord.RW_Sanction_Letter_ID__c );
                   if(loanRecord.RW_Booking__r.RW_Registration_Status__c == 'Registration Completed' && loanRecord.RW_Loan_Record_Status__c == 'Loan Sanctioned' && loanRecord.RW_Sanction_Letter_ID__c !=null){ 
                       system.debug('map of keyword 2 '+KeywordList + keywordValueMap);
                       for(String listOfKey :KeywordList){
                           system.debug('KeywordValueMap' + KeywordValueMap);
                           system.debug('listOfKey' + listOfKey);
                           
                           if(KeywordValueMap.ContainsKey(listOfKey)){
                               system.debug('listOfKey  -> 2' + listOfKey + '**' + KeywordValueMap.get(listOfKey));
                               if(KeywordValueMap.get(listOfKey) !=null){
                                   noc.RW_Template__c = noc.RW_Template__c.replace(listOfKey,KeywordValueMap.get(listOfKey)); 
                               }
                               
                               else{
                                   noc.RW_Template__c = noc.RW_Template__c.replace(listOfKey,'');                                 
                               }
                           }
                       }
                       noc.RW_Template__c = noc.RW_Template__c.replace('[justify start]','<div style="text-align: justify;">'); 
                       noc.RW_Template__c = noc.RW_Template__c.replace('[justify end]','</div>');
                   }  
               }
            
        }
    }
}