public class SendSalesExperienceWhatsappMsg {

    @InvocableMethod
    public static void sendMsg(List<Id> oppIds){
        
        List<Opportunity> opps = [SELECT Id, Name, RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name, Booking__r.RW_Country_Phone_Code__c, RW_Mobile_No__c FROM Opportunity WHERE Id =: oppIds]; 	//Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
        
        for(Opportunity opp : opps){
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(opp.Id, opp.Name, opp.Sales_Manager_User__r.Name, null, null, null, null, null, null, opp.Booking__r.RW_Country_Phone_Code__c, opp.RW_Mobile_No__c, 'Sales Experience'); 	//Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
            }
            opp.Send_Sales_Experience_Whatsapp_Message__c = true;
        }
        update opps;
    }
}