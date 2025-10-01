/***************************************

    Created Date : 27th April 2020 
    Purpose : to store customer feedbacks 
    Author : Shailesh Devare
    VF page : CustomerFeedbackPage
    
****************************************/
public class CustomerFeedbackController {
        public Customer_Feedback__c cfObj {
                get;
                set;
        }
        public String errorMsg {
                get;
                set;
        }
        Public List < Account > accList {
                get;
                set;
        }
        public boolean isSubmitted {
                get;
                set;
        }

        public CustomerFeedbackController() {
                cfObj = new Customer_Feedback__c();
                accList = new List < Account > ();
        }
        public pageReference submitFeedback() {
                system.debug('inside submit method:Mobile Number::' + cfObj.Customer_Mobile_Number__c + '::experience::' + cfObj.Customer_Experience__c);
                errorMsg = '';
                isSubmitted = false;
                if (cfObj.Customer_Mobile_Number__c == null) {
                        errorMsg = 'Please enter your mobile number<br/>';
                }
                if (cfObj.Customer_Experience__c == null || cfObj.Customer_Experience__c == '') {
                        errorMsg += 'Please tell us how was your experience';
                }
                if (errorMsg != '') {
                        return null;
                } else {
                        try {
                                accList = [Select Id from Account where(Mobile_No__c =: cfObj.Customer_Mobile_Number__c OR Alternate_Mobile_No__c =: cfObj.Customer_Mobile_Number__c)];
                                if (accList != null && !accList.isEmpty() && accList.size() == 1)
                                        cfObj.Account__c = accList[0].Id;

                                insert cfObj;
                                isSubmitted = true;
                                pageReference pageRef = new Pagereference('/apex/CustomerFeedbackSubmitPage');
                                pageRef.setRedirect(true);
                                return pageRef;
                        } catch (Exception ex) {
                                system.debug('exception ocurred::' + ex.getMessage());
                                errorMsg = 'Error ocurred: ' + ex.getMessage();
                        }
                        return null;
                }

        }
        public pageReference submitAnotherResponse() {
                pageReference pageRef = new Pagereference('/apex/CustomerFeedbackPage');
                pageRef.setRedirect(true);
                return pageRef;
        }
}