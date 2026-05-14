public class PrintEOIData 
{
    public RW_EOI__c eoi {
        get;
        private set;
    }
           
    public String address {
        get;
        private set;
    }
    
    public String digitallyAcceptedOn {
        get;
        private set;
    }
    
    public String eoiDate
    {
       get;
       private set; 
    }
    
    public List<String> budgetTypes
    {
       get;
       private set; 
    }
    
     public List<String> UnitTypes
    {
       get;
       private set; 
    }
        
    public List<String> floorTypes
    {
       get;
       private set; 
    }
    
    public List<String> applicationSource
    {
       get;
       private set; 
    }
    
    public PrintEOIData(){
        if(ApexPages.currentPage().getParameters().get('eoiId') != null){
            eoi =[SELECT Id,RW_Digitally_Accepted_On__c,RW_City__c,RW_EOI_Acknowledgement_Sent_Date_Time__c,	RW_Mailing_State__c,RW_Mailing_Country__c,RW_State__c, Name,RW_Company_Name__c,RW_Project_Name__c,RW_Opt_In__c,RW_Mailing_and_Permanent_Address_Same__c,RW_Alternate_Contact_No__c,RW_Mailing_Pin__c,RW_Mailing_City__c, RW_Mailing_Address_Line_1__c,RW_Mailing_Address_Line_2__c,RW_Mailing_Address_Line_3__c,Opportunity__c , Opportunity__r.Walkin_Source__c ,Opportunity__r.RW_Project__c ,Tower__r.Front_Page_Image__c,Tower__r.Footer_Page_Image__c, Tower__c ,Tower__r.RW_Terms_And_Conditions__c,RW_Date_of_Birth__c,RW_Marital_Status__c, Tower__r.Name, RW_Residential_Status__c,RW_Type_Of_Applicant__c, RW_Designation__c,RW_Occupation__c,RW_Nationality__c, RW_Type_Of_Origin__c,RW_Origin_Details__c,RW_Pan_Card_Number_of_AuthoritySignatory__c,RW_PassportNoDetails__c, RW_Country_Phone_Code__c ,RW_Gender__c,RW_Permanent_Address_Line_1__c,RW_Permanent_Address_Line_2__c,RW_Permanent_Address_Line_3__c,RW_Document_Number__c,RW_Document_Proof__c,RW_Primary_First_Name__c,RW_Source_RERA_No__c,RW_Primary_Middle_Name__c,RW_Primary_Last_Name__c,RW_Name_of_Company__c,RW_Channel_Partner_s_Name__c,RW_Channel_Partner_s_Company__c,RW_Residential_Company_Address__c,RW_Pin__c,RW_Countries__c,RW_Primary_Contact_No__c,RW_Primary_Email__c ,RW_Primary_PAN_Details__c ,RW_Primary_Alternate_Email__c,RW_Primary_Aadhar_Details__c,RW_Primary_Passport_Details__c ,RW_Secondary_First_Name__c,RW_Secondary_Middle_Name__c,RW_Secondary_Last_Name__c,RW_Secondary_Contact_No__c,RW_Secondary_Email__c,RW_Secondary_PAN_Details__c ,RW_Secondary_Alternate_Email__c ,RW_Secondary_Aadhar_Details__c ,RW_Secondary_Passport_Details__c ,RW_Preferred_Unit_Type__c,RW_Preferred_Budget__c,RW_Preferred_Floors__c,RW_Any_other_preference_please_specify__c,RW_Preferred_Unit_No__c,RW_Tentative_Agreement_Value__c ,RW_Tentative_All_Inclusive_Price__c,RW_Application_Source__c,RW_Sub_Source__c,RW_Closing_Type__c,RW_Source_Contact_No__c,RW_Source_Email_Id__c FROM RW_EOI__c WHERE Id =:ApexPages.currentPage().getParameters().get('eoiId')];
            //digitallyAcceptedOn = '29/08/2020 18:00 PM';
            //eoiDate = '29/08/2020';
            system.debug('*eoi Print*'+eoi);
            if(!String.isBlank(String.valueOf(eoi.RW_Digitally_Accepted_On__c))){
                digitallyAcceptedOn = String.valueOf(eoi.RW_Digitally_Accepted_On__c.format('dd/MM/yyyy HH:mm a','IST'));
                eoiDate = String.valueOf(eoi.RW_Digitally_Accepted_On__c.format('dd/MM/yyyy'));
            }
            String addressVal='';
            if(eoi.RW_Permanent_Address_Line_1__c != null && eoi.RW_Permanent_Address_Line_1__c !=''){
                addressVal += eoi.RW_Permanent_Address_Line_1__c;
            }
           
           if(eoi.RW_Permanent_Address_Line_2__c != null && eoi.RW_Permanent_Address_Line_2__c !=''){
               addressVal += ','+eoi.RW_Permanent_Address_Line_2__c;
           }
             
           if(eoi.RW_Permanent_Address_Line_3__c != null && eoi.RW_Permanent_Address_Line_3__c !=''){
               addressVal += ','+eoi.RW_Permanent_Address_Line_3__c;
           }
            
             
          /* if(eoi.RW_City__c != null && eoi.RW_City__c !='')
           {
               addressVal += eoi.RW_City__c+',';
           }
           
           if(eoi.RW_State__c != null && eoi.RW_State__c !='')
           {
               addressVal += eoi.RW_State__c+',';
           }
             
           if(eoi.RW_Countries__c != null && eoi.RW_Countries__c !='')
           {
               addressVal += eoi.RW_Countries__c+',';
           }
             
            if(eoi.RW_Pin__c != null && eoi.RW_Pin__c !='')
           {
               addressVal += eoi.RW_Pin__c;
           }*/
             
            address= addressVal;
         }
		applicationSource = new list<string>{'Channel Partner','Direct','Corporate','Referral / Loyalty'};    	
        Projects__mdt[] projMappings = [SELECT Id,Label FROM Projects__mdt Where Label =:eoi.RW_Project_Name__c ];
        if(projMappings != null && projMappings.size() >0){
            Project_Towers__mdt[] towerMappings = [SELECT Id,Label,Projects__c FROM Project_Towers__mdt Where Projects__c = :projMappings[0].Id and Label =:eoi.Tower__r.Name ];
            if(towerMappings != null && towerMappings.size() >0){
                Preferred_Unit_Type__mdt[] unitTypeMappings = [SELECT Id,Label,Project__c,Order__c FROM Preferred_Unit_Type__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                UnitTypes = new List<String>();                
                for(Preferred_Unit_Type__mdt unitTypeMapping : unitTypeMappings){
                    UnitTypes.add(unitTypeMapping.Label);                    
                }
                
                
                Preferred_Budget__mdt[] budgetMappings = [SELECT Id,Label,Project__c,Order__c FROM Preferred_Budget__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                budgetTypes = new List<String>();
                for(Preferred_Budget__mdt budgetMapping : budgetMappings){
                    budgetTypes.add(budgetMapping.Label);
                }
                
                Preferred_Floors__mdt[] floorMappings = [SELECT Id,Label,Projects__c,Order__c FROM Preferred_Floors__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                floorTypes = new List<String>();
                for(Preferred_Floors__mdt floorMapping : floorMappings){
                    floorTypes.add(floorMapping.Label);
                }
            }
        }
    }
}