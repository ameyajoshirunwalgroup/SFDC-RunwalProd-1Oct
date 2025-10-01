public class BookingFeedbackController {
        public Booking_Feedback__c cfObj {
                get;
                set;
        }
        public String errorMsg {
                get;
                set;
        }
        public boolean isSubmitted {
                get;
                set;
        }
    
    	public String bkName {
                get;
                set;
        }
    
    	public String rating {
                get;
                set;
        }
    
    	public String remarks {
                get;
                set;
        }

        public BookingFeedbackController() {
                cfObj = new Booking_Feedback__c();
        }
    	
    	
    
    	Public Id objId = System.currentPagereference().getParameters().get('id');
    	
    	
    
        public pageReference submitFeedback() {
                errorMsg = '';
                isSubmitted = false;
            String sobjectType = objId.getSObjectType().getDescribe().getName();
			 if (cfObj.Customer_Experience__c == null || cfObj.Customer_Experience__c == '') {
                        errorMsg += 'Please tell us how was your experience';
                }
            if(sobjectType == 'Case'){
                Case cs = [SELECT Id, CaseNumber FROM Case WHERE Id =: objId];
                if (rating != null || rating != ''){
                    cfObj.Customer_Experience__c = rating;
                    cfObj.Remarks__c = remarks;
                    cfObj.Related_To__c = 'Case';
                    cfObj.Case__c = cs.Id;
                    insert cfObj;
            	}
            }else if(sobjectType == 'Booking__c'){
                Booking__c booking = [Select Id, Name from Booking__c where Id =: objId];
                if (rating != null || rating != ''){
                    cfObj.Customer_Experience__c = rating;
                    cfObj.Remarks__c = remarks;
                    cfObj.Booking__c = booking.Id;
                    cfObj.Related_To__c = 'Booking';
                    insert cfObj;
            	}
            }
            
            	pageReference pageRef = new Pagereference('/apex/BookingFeedbackSubmitPage');
                pageRef.setRedirect(true);
                return pageRef;	
            
                /*if (cfObj.Customer_Experience__c == null || cfObj.Customer_Experience__c == '') {
                        errorMsg += 'Please tell us how was your experience';
                }
                if (errorMsg != '') {
                        return null;
                } else {
                        try {
                                Booking__c booking = [Select Id, Name from Booking__c where Id =: bkId];
                            	System.debug('booking: ' + booking);
                            	if (booking != null){
                                	cfObj.Booking__c = booking.Id;
                                    
                                }else{
                                    cfObj.Booking__c = 'booking1';
                                }
                                        
								insert cfObj;
                                
                                isSubmitted = true;
                            
                            
                                pageReference pageRef = new Pagereference('/apex/BookingFeedbackSubmitPage');
                                pageRef.setRedirect(true);
                                return pageRef;
                        } catch (Exception ex) {
                                system.debug('exception ocurred::' + ex.getMessage());
                                errorMsg = 'Error ocurred: ' + ex.getMessage();
                        }
                        return null;
                }*/

        }
}