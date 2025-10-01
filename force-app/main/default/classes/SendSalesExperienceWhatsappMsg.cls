public class SendSalesExperienceWhatsappMsg {

    @InvocableMethod
    public static void sendMsg(List<Id> oppIds){
        
        List<Opportunity> opps = [SELECT Id, Name, RW_Sales_Associate__c, Booking__r.RW_Country_Phone_Code__c, RW_Mobile_No__c FROM Opportunity WHERE Id =: oppIds];
        
        for(Opportunity opp : opps){
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(opp.Id, opp.Name, opp.RW_Sales_Associate__c, null, null, null, null, null, null, opp.Booking__r.RW_Country_Phone_Code__c, opp.RW_Mobile_No__c, 'Sales Experience');
            }
            opp.Send_Sales_Experience_Whatsapp_Message__c = true;
        }
        update opps;
    }
}