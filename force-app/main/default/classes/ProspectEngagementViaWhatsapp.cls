global class ProspectEngagementViaWhatsapp implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //List<String> stages = new List<String>{'Qualification', 'Video Call','Voice call','Site Visit','Lost'};
        List<String> stages = System.label.Prospect_Engagement_Whatsapp_Opp_Stages.split(',');
        Date dt = Date.today() - 10;
        return Database.getQueryLocator([SELECT Id, Name, RW_Mobile_No__c, RW_Project__r.Name, RW_Project__r.Presales_Contact_No__c, CreatedDate, Date_Of_Visit__c, RW_Project__r.Key_Features_Amenities_Video_Link__c, RW_Project__r.Prospect_Engagement_Team__c, RW_Project__r.Testimonial_Video_Link__c, RW_Project__r.Day_1_Whatsapp_Content__c, RW_Project__r.Day_3_Whatsapp_Content__c, Account.Country_Code__c, RW_Project__r.Photo_Album__c, RW_Project__r.Strategic_Location_Video__c FROM Opportunity WHERE StageName =: stages AND RW_Project__r.VDNB_Customer_Whatsapp_Journey__c = true AND Date_Of_Visit__c != null AND Date_Of_Visit__c >=: dt]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opps){
        Date dt = Date.today();
        List<String> oppIds = new List<String>();
        for(Opportunity opp : opps){
            oppIds.add(opp.Id);
        }
        List<CIF__c> cifs = [SELECT Id, Opportunity__c FROM CIF__c WHERE Opportunity__c =: oppIds];
        Map<String,String> oppVsCifMap = new Map<String, String>();
        for(CIF__c cif : cifs){
            oppVsCifMap.put(cif.Opportunity__c, cif.Id);
        }
        for(Opportunity opp : opps){
            if(oppVsCifMap.get(opp.Id) != null){ 
                // Day 3: Follow up
                if(Date.valueOf(opp.Date_Of_Visit__c) == dt - 2 && opp.RW_Project__c != null && opp.RW_Project__r.Day_3_Whatsapp_Content__c != null && opp.RW_Project__r.Key_Features_Amenities_Video_Link__c != null && opp.RW_Project__r.Testimonial_Video_Link__c != null && opp.RW_Project__r.Prospect_Engagement_Team__c != null && opp.RW_Project__r.Strategic_Location_Video__c != null && !Test.isRunningTest()){
                    System.debug('-- Day 3: Follow up');
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Day_3_Whatsapp_Content__c, opp.RW_Project__r.Key_Features_Amenities_Video_Link__c, opp.RW_Project__r.Testimonial_Video_Link__c, opp.RW_Project__r.Strategic_Location_Video__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, opp.Account.Country_Code__c, opp.RW_Mobile_No__c, 'Prospect Engagement Day 3');                    
                    //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch(opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Day_3_Whatsapp_Content__c, opp.RW_Project__r.Key_Features_Amenities_Video_Link__c, opp.RW_Project__r.Testimonial_Video_Link__c, opp.RW_Project__r.Strategic_Location_Video__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, opp.RW_Mobile_No__c, 'Prospect Engagement Day 3'); //Commented by Vinay 29-08-2025
                    if(System.label.Haptik_API_Version == 'New'){ //Added by Vinay 13-10-2025
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatchNew(null,opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Day_3_Whatsapp_Content__c, opp.RW_Project__r.Key_Features_Amenities_Video_Link__c, opp.RW_Project__r.Testimonial_Video_Link__c, opp.RW_Project__r.Strategic_Location_Video__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, opp.Account.Country_Code__c, opp.RW_Mobile_No__c, 'Prospect Engagement Day 3');
                    }else{
                        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch(opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Day_3_Whatsapp_Content__c, opp.RW_Project__r.Key_Features_Amenities_Video_Link__c, opp.RW_Project__r.Testimonial_Video_Link__c, opp.RW_Project__r.Strategic_Location_Video__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, opp.RW_Mobile_No__c, 'Prospect Engagement Day 3');
                    }
                }
                // Day 5: Detailed Information
                /*if(Date.valueOf(opp.Date_Of_Visit__c) == dt - 4 && !Test.isRunningTest()){
                    System.debug('-- Day 5: Detailed Information');
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Day_3_Whatsapp_Content__c, opp.RW_Project__r.Key_Features_Amenities_Video_Link__c, opp.RW_Project__r.Testimonial_Video_Link__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, '+91', opp.RW_Mobile_No__c, 'Prospect Engagement Day 3');                    
                }*/
                // Day 7: Personal Touch
                if(Date.valueOf(opp.Date_Of_Visit__c) == dt - 6 && opp.RW_Project__c != null && opp.RW_Project__r.Photo_Album__c != null && opp.RW_Project__r.Prospect_Engagement_Team__c != null && !Test.isRunningTest()){
                    System.debug('-- Day 7: Personal Touch');
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Photo_Album__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, opp.Account.Country_Code__c, opp.RW_Mobile_No__c, 'Prospect Engagement Day 7');                   
                    //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch(opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Photo_Album__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, null, opp.RW_Mobile_No__c, 'Prospect Engagement Day 7'); //Commented by Vinay 29-08-2025
                    if(System.label.Haptik_API_Version == 'New'){ //Added by Vinay 13-10-2025
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatchNew(null,opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Photo_Album__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, opp.Account.Country_Code__c, opp.RW_Mobile_No__c, 'Prospect Engagement Day 7');
                    }else{
                        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch(opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Photo_Album__c, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, null, opp.RW_Mobile_No__c, 'Prospect Engagement Day 7');
                    }
                }
                // Day 10: Final Reminder
                if(Date.valueOf(opp.Date_Of_Visit__c) == dt - 9 && opp.RW_Project__c != null && opp.RW_Project__r.Prospect_Engagement_Team__c != null && !Test.isRunningTest()){
                    System.debug('-- Day 10: Final Reminder');
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null, opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, null, opp.Account.Country_Code__c, opp.RW_Mobile_No__c, 'Prospect Engagement Day 10');                    
                    //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch(opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, null, null, opp.RW_Mobile_No__c, 'Prospect Engagement Day 10'); //Commented by Vinay 29-08-2025
					
                    if(System.label.Haptik_API_Version == 'New'){ //Added by Vinay 13-10-2025
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatchNew(null,opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, null, opp.Account.Country_Code__c, opp.RW_Mobile_No__c, 'Prospect Engagement Day 10');
                    }else{
                        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgBatch(opp.Name, opp.RW_Project__r.Name, opp.RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, null, null, opp.RW_Mobile_No__c, 'Prospect Engagement Day 10');
                    }
                }
            }
        }
        dummy();
    }
    
    public static void dummy(){
        String a;
        String b;
        String c;
    }
    
     global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        ProspectEngagementViaWhatsapp b = new ProspectEngagementViaWhatsapp();
        Database.executeBatch(b, 10);
    }

}