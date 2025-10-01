public class CancellationSurveyController {
    
    Public List<string> res {get;set;}
    Public List<string> config {get;set;}
    Public List<string> payStr {get;set;}
    Public string salesTeam {get;set;}
    Public string crmRep {get;set;}
    Public String recm {get;set;}
    Public string otherFB {get;set;}
    Public string otherRes {get;set;}
    Public string otherConfig {get;set;}
    Public string otherPayStr {get;set;}
    public Cancellation_Survey__c cs {get;set;}
    Public string custName {get;set;}
    Public Boolean showOtherRes {get;set;}
    Public Boolean showconfigOtherRes {get;set;}
    Public Boolean showpayStrOtherRes {get;set;}
    Public Id recId = System.currentPagereference().getParameters().get('id');
    public CancellationSurveyController(){
        res = new List<string>();
        config = new List<string>();
        payStr = new List<string>();
        salesTeam = '';
        crmRep = '';
        recm = '';
        otherFB = '';
        otherRes = '';
        otherConfig = '';
        otherPayStr = '';
        showOtherRes = false;
        showconfigOtherRes = false;
        showpayStrOtherRes = false;
        cs = new Cancellation_Survey__c();
    }
    
    public pageReference recCS(){
        cs = [SELECT Id, Reason_for_Cancellation__c, Applicant_Name__c FROM Cancellation_Survey__c WHERE Id =: recId];
        custName = cs.Applicant_Name__c;
        return null;
    }
     
    public List<SelectOption> getReasons(){
        Schema.sObjectType sobject_type = Cancellation_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Reason_for_Cancellation__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry a : pick_list_values){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getConfigList(){
        Schema.sObjectType sobject_type = Cancellation_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Configuration_or_Project__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry a : pick_list_values){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getPaymentList(){
        Schema.sObjectType sobject_type = Cancellation_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Payment_Structure__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry a : pick_list_values){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getSalesTeamList(){
        Schema.sObjectType sobject_type = Cancellation_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Sales_Team_Booking_process__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry a : pick_list_values){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getCrmRepList(){
        Schema.sObjectType sobject_type = Cancellation_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('CRM_Rep_Post_Sales_Process__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry a : pick_list_values){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public List<SelectOption> getrecmList(){
        Schema.sObjectType sobject_type = Cancellation_Survey__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Recommend_to_Anyone__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry a : pick_list_values){
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public void reasons(){
        system.debug('selectedReason -' + res);
        for(String str : res){
            if(str == 'Other'){
                showOtherRes = true;
            }else{
                showOtherRes = false;
            }
        }
    }
    
    public void configRes(){
        system.debug('selectedReason -' + res);
        for(String str : config){
            if(str == 'Other'){
                showconfigOtherRes = true;
            }else{
                showconfigOtherRes = false;
            }
        }
    }
    
    public void payStrRes(){
        system.debug('selectedReason -' + res);
        for(String str : payStr){
            if(str == 'Other'){
                showpayStrOtherRes = true;
            }else{
                showpayStrOtherRes = false;
            }
        }
    }
     
    public pagereference addReasons(){
        system.debug('selectedReason -' + res);
        String reasonValues = '';
        for(String str : res){
            if(reasonValues == ''){
                reasonValues += str;
            }else{
                reasonValues += ';' + str;
            }
        }
        String configValues = '';
        for(String str : config){
            if(configValues == ''){
                configValues += str;
            }else{
                configValues += ';' + str;
            }
        }
        String payStrValues = '';
        for(String str : payStr){
            if(payStrValues == ''){
                payStrValues += str;
            }else{
                payStrValues += ';' + str;
            }
        }
        system.debug('reasonValues -' + reasonValues);
        cs.Id = recId;
        cs.Reason_for_Cancellation__c = reasonValues;
        cs.Other_Cancellation_Reason__c = otherRes;
        cs.Configuration_or_Project__c = configValues;
        cs.Other_Reason_Configuration_or_Project__c = otherConfig;
        cs.Payment_Structure__c = payStrValues;
        cs.Other_Reason_Payment_Structure__c = otherPayStr;
        cs.CRM_Rep_Post_Sales_Process__c = crmRep;
        cs.Sales_Team_Booking_process__c = salesTeam;
        cs.Recommend_to_Anyone__c = recm;
        cs.Sales_Team_Booking_process__c = salesTeam;
        cs.Other_Feedback__c = otherFB;
        update cs;
        pageReference pageRef = new Pagereference('/apex/BookingFeedbackSubmitPage');
            pageRef.setRedirect(true);
            return pageRef;
    }
    
  

}