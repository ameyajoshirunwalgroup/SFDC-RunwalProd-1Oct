public class CaseFeedbackForController {
    Public String userInput{get;set;}
    public Integer rating1 { get; set; }
    public String selectedRating1 { get;  set; }
    public String selectedValueInput { get; set; }
    public List<Case> clist{get;set;}
    public Datetime dt{get;set;}
    public String dateOnly{get;set;}
    public Boolean errorOccurred { get; set; }
    Public boolean showpanel{get;set;}
    Public boolean isExpired{get;set;}
     Public boolean ShowExpirePanel{get;set;}
    public String loggedInUserName { get; set; }
    public Boolean showConfirmationDialog { get; set; }
    public String remark{get;set;}
    Public boolean disableSubmit{get;set;}
    public CaseFeedbackForController(){
        disableSubmit=true;
        showConfirmationDialog = false;
        showpanel=false;
        loggedInUserName = UserInfo.getName();
        remark='yes';
        isExpired = false;
          dt = System.today(); 
        String profileLabel = System.Label.Form_Expiry_Day;
        Integer labelValue = Integer.valueOf(profileLabel);
        System.debug('labelValue'+labelValue);
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        clist=[Select Id,CaseNumber,Last_Closed_Date__c,CreatedDate,Subject,Status,Account.Name,LastModifiedBy.Name,RW_RM_Name__c,owner.name,ClosedDate,CSAT_Feedback_Remark__c,CSAT_Feedback_Rating__c from Case where Id=:caseId];
        system.debug('caseId'+caseId);
        system.debug('clist'+clist);
        dt=system.today(); 
        dateOnly=dt.format('dd/MM/yyyy');
        loggedInUserName = clist[0].LastModifiedBy.Name;
        Date expiryDate = clist[0].Last_Closed_Date__c.date().addDays(labelValue);
        System.debug('expiryDate:::'+expiryDate);
        if (expiryDate < dt) {
            System.debug('inside check expiry');
            isExpired = true;
        }
        if(String.isnotBlank(clist[0].CSAT_Feedback_Rating__c))
        {
            showpanel = true;
        }
    }
    public PageReference updateRemark() {
        remark = String.valueOf(ApexPages.currentPage().getParameters().get('remarkValue'));
        return null;
    }
    public void updateRating1() {
        rating1 = Integer.valueOf(ApexPages.currentPage().getParameters().get('ratingValue'));
    }
    
    public PageReference  SubmitFeedback() { 
        selectedRating1 = String.valueOf(rating1);
        System.debug('selectedRating1:::'+selectedRating1);
         
            List<String> missingFields = new List<String>();
            if (String.isBlank(selectedRating1)) {
                missingFields.add('Rating');
            }
            if (!missingFields.isEmpty()) {
                String errorMessage = 'Please fill in the following required field(s): ' + String.join(missingFields, ', ');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                return null;
            }
            Case c = clist[0];
            System.debug('selectedRating1:::'+selectedRating1);
            if(selectedRating1 == '1'||selectedRating1 == '2'){
                c.CSAT_Feedback_Rating__c = 'Unhappy';
                c.Status = 'Reopened';
            }else if(selectedRating1 == '3'){
                c.CSAT_Feedback_Rating__c = 'Fair';
            }else if(selectedRating1 == '4'|| selectedRating1 == '5'){
                c.CSAT_Feedback_Rating__c = 'Happy';
                
            }
            c.CSAT_Feedback_Remark__c = userInput;   
            c.CSAT_Feedback_Status__c = 'Feedback Submitted'; //Added by Vinay 09-04-2025   
            try{
                update c;
                
            }catch (Exception ex) {
                System.debug('Error:::' + ex.getMessage());
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Feedback submitted successfully!'));
            PageReference thankYouPage = Page.ThankYouPage; 
            thankYouPage.setRedirect(true);
            return thankYouPage;     
        
    }
    
}