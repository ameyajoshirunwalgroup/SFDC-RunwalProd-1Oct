public class SiteVisitSurveyController {
    
    public Opportunity opp {get;set;}
    public String optyId {get;set;}
    
    public SiteVisitSurveyController(ApexPages.StandardController controller){  
        optyId = controller.getId();
        opp = [SELECT Id, Name, How_do_you_prefer_searching_property__c, How_did_you_find_out_about_Runwal__c, What_locations_are_you_considering__c,
               What_is_the_reason_for_home_purchase__c, Which_other_property_you_considered__c, Property_Comparison_Amenities__c, Rating__c,
               Property_Comparison_Location__c, Property_Comparison_Prices__c, Property_Comparison_Connectivity__c, What_did_you_like_about_Runwal__c,
               What_did_you_not_like_about_Runwal__c, How_can_we_make_your_experience_better__c, Additional_Comments__c,
               Other_Details_DOB__c, Other_Details_Gender__c, Other_Details_Occupation__c, Other_Details_Home_Location__c, How_can_make_experience_better_Others__c,
               Account.Name, Account.IsPersonAccount, Account.Birth_Date__c, Account.Gender__c, Account.RW_Occupation__c, Account.Locality__c, 
               RW_Project__c, Other_Details_First_Name__c, Other_Details_Last_Name__c, Account.FirstName, Account.LastName, RW_Project__r.Name
               FROM Opportunity WHERE Id =: optyId];
        opp.Other_Details_First_Name__c = opp.Account.FirstName;
        opp.Other_Details_Last_Name__c = opp.Account.LastName;
        opp.Other_Details_DOB__c = opp.Account.Birth_Date__c;
        opp.Other_Details_Gender__c = opp.Account.Gender__c;
        opp.Other_Details_Occupation__c = opp.Account.RW_Occupation__c;
        opp.Other_Details_Home_Location__c = opp.Account.Locality__c;
    }
    

    public pageReference save(){
        Boolean updateAcc = false;
        Account acc = new Account();
        acc.Id = opp.AccountId;
        System.debug('opp.Account.FirstName: ' + opp.Account.FirstName);
        System.debug('opp.Other_Details_First_Name__c: ' + opp.Other_Details_First_Name__c);
        if(opp.Other_Details_First_Name__c != opp.Account.FirstName){
            acc.FirstName = opp.Other_Details_First_Name__c;
            updateAcc = true;
        }
        if(opp.Other_Details_Last_Name__c != opp.Account.LastName){
            acc.LastName = opp.Other_Details_Last_Name__c;
            updateAcc = true;
        }
        if(opp.Other_Details_DOB__c != opp.Account.Birth_Date__c){
            acc.Birth_Date__c = opp.Other_Details_DOB__c;
            updateAcc = true;
        }
        if(opp.Other_Details_Gender__c != opp.Account.Gender__c){
            acc.Gender__c = opp.Other_Details_Gender__c;
            updateAcc = true;
        }
        if(opp.Other_Details_Occupation__c != opp.Account.RW_Occupation__c){
            acc.RW_Occupation__c = opp.Other_Details_Occupation__c;
            updateAcc = true;
        }
        if(opp.Other_Details_Home_Location__c != opp.Account.Locality__c){
            acc.Locality__c = opp.Other_Details_Home_Location__c;
            updateAcc = true;
        }
        update opp;
        if(updateAcc == true){
            update acc;
        }
        if(opp.How_can_we_make_your_experience_better__c == 'Others' && (opp.How_can_make_experience_better_Others__c == '' || opp.How_can_make_experience_better_Others__c == null)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please specify your comments for better experience'));
            return null;
        }else if(opp.How_can_we_make_your_experience_better__c != 'Others' && (opp.How_can_make_experience_better_Others__c != '' && opp.How_can_make_experience_better_Others__c != null)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'You can add the comments only if you seleced the Others'));
            return null;
        }else{
            pageReference pageRef = new Pagereference('/'+optyId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        
    }
    
    public pageReference backToOpp(){
        pageReference pageRef = new Pagereference('/'+optyId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}