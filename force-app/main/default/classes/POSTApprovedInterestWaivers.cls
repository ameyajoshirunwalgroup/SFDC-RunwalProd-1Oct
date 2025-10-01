public class POSTApprovedInterestWaivers {
    
    @InvocableMethod()
    public static void getApprovedIW(List<Id> lstIWIds) {
        system.debug('lstIWIds>>>>>' +lstIWIds);
        if (lstIWIds == null || lstIWIds.isEmpty()) {
            return; 
        }
        //    Id JobId = System.enqueueJob(new SAPInterestWaiverAPICallOut(lstIWIds)); existing API
        //if(!lstIWIds.isEmpty() && lstIWIds.size() > 0){
        Id JobId = System.enqueueJob(new SAPInterestWaiverAPICallOutNew(lstIWIds));
        system.debug('lstIWIds??????' +lstIWIds);
        /*  List<Interest_Waiver__c> lstWaiver = [SELECT Id, Name,Is_Send_To_SAP__c, Customer_Name__c,Waiver_Amount__c, Project_Name__c,Unit__c,Booking__r.Customer__r.RW_Mobile_No__c FROM Interest_Waiver__c  
WHERE Approval_Status__c = 'Approved' AND Id IN: lstIWIds];
system.debug('lstWaiver>>>>' +lstWaiver);

if(lstWaiver == null){
return;
}
if(!lstWaiver.isEmpty() && lstWaiver.size() > 0){

for(Interest_Waiver__c objIW : lstWaiver){
if(string.isNotBlank(objIW.Customer_Name__c) && String.isNotBlank(objIW.Unit__c)
&& String.isNotBlank(objIW.Booking__r.Customer__r.RW_Mobile_No__c) && objIW.Waiver_Amount__c != null && objIW.Is_Send_To_SAP__c == TRUE){
system.debug('call whatsapp mtd>>>>');
sendWhatsAppMsg(objIW.Id, objIW.Customer_Name__c, objIW.Unit__c, objIW.Booking__r.Customer__r.RW_Mobile_No__c, String.ValueOf(objIW.Waiver_Amount__c));
}
}
}*/
    }
}