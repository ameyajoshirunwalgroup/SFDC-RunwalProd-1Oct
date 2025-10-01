public class CSATFeedbackController {
    
    public String rating {get;set;}
    public String remarks {get;set;}
    public boolean isSubmitted {get;set;}
    public String errorMsg {get;set;}
    //public Id recId{get;set;}
    public CSAT__c csat {get;set;}

    
    Public Id recId = System.currentPagereference().getParameters().get('id');
    
    public pageReference successPage(){
        CSAT__c csat1;
        
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        if(sobjectType == 'Case'){
            List<CSAT__c> csats = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Case__c =: recId LIMIT 1];
            if(csats.size() < 1){
                Case cs = [SELECT Id, AccountId, Account.PersonEmail, RW_Mobile_No__c FROM Case WHERE Id =: recId];
                CSAT__c csatNew = new CSAT__c();
                csatNew.Account__c = cs.AccountId;
                csatNew.Case__c = cs.Id;
                csatNew.Contact_Email__c = cs.Account.PersonEmail;
                csatNew.Contact_Number__c = cs.RW_Mobile_No__c;
                csatNew.Related_To__c = 'Case';
                insert csatNew;
                
                recId = csatNew.Id;
                csat1 = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Id =: csatNew.Id LIMIT 1];
            }else{
                csat1 = csats[0];
            }
            
               
        }else if(sobjectType =='CSAT__c'){
            csat1 = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Id =: recId LIMIT 1];
        }
        csat = csat1;
        //csat = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Id =: recId LIMIT 1];
        System.debug('csat: ' + csat);
        if(csat.Status__c != 'Not Responded' && csat.Status__c != null){
            pageReference pageRef = new Pagereference('/apex/FeedbackAlreadySubmitted');
            pageRef.setRedirect(true);
            return pageRef;
        }else{
           return submitFeedback();
        }
        
    }
        
    public pageReference submitFeedback(){
        //recId = apexpages.currentpage().getparameters().get('id');
        String sobjectType = recId.getSObjectType().getDescribe().getName();
        if(sobjectType == 'Case'){
            csat = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Case__c =: recId LIMIT 1];
        }else if(sobjectType == 'CSAT__c'){
            csat = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Id =: recId LIMIT 1];
        }
        //csat = [SELECT Id, Name, Case__c, Account__c, Status__c,Reason_for_UnHappy__c FROM CSAT__c WHERE Id =: recId LIMIT 1];
        if(rating == 'UnHappy' && remarks == null){
            isSubmitted = true;
            String rat = rating;
            pageReference pageRef = new Pagereference('/apex/CSATFeedbackForm?rating='+rat+'&id='+recId);
            pageRef.setRedirect(true);
            return pageRef;
        }else if(remarks != null && remarks != ''){
            csat.Status__c = apexpages.currentpage().getparameters().get('rating');
            csat.Reason_for_UnHappy__c = remarks;
            update csat;
        
            isSubmitted = true;
            String rat = rating;
            pageReference pageRef = new Pagereference('/apex/BookingFeedbackSubmitPage');
            pageRef.setRedirect(true);
            return pageRef;	
        }else if(rating == 'Happy'){
            isSubmitted = true;
            String rat = rating;
            csat.Status__c = rating;
            update csat;
            pageReference pageRef = new Pagereference('/apex/BookingFeedbackSubmitPage');
            pageRef.setRedirect(true);
            return pageRef;	
        }
        
        return null;
    }

}