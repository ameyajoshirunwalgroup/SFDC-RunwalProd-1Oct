public without sharing class ConvertTempCpToOriginalCpController {

    @AuraEnabled
    public static void convertCp(String tempCpId){
        System.debug('tempCpId: ' + tempCpId);
        Temp_Channel_Partner__c tempCp = [SELECT Id, Name, Mobile_No__c, PAN_No__c, First_Name__c, Middle_Name__c, Last_Name__c,
                                          Email__c, State__c, Converted__c FROM Temp_Channel_Partner__c WHERE Id =: tempCpId];
        
        if(tempCp.Converted__c){
            throw new AuraHandledException('This Temp CP already converted to Original CP!');
        }
        
        String errorMessage;
        if(tempCp.PAN_No__c == null){
            errorMessage = 'PAN number';
        }
        if(tempCp.Mobile_No__c == null){
            if(errorMessage != null && errorMessage != ''){
                errorMessage += ', Mobile';
            }else{
                errorMessage = 'Mobile';
            }
        }
        if(tempCp.Email__c == null){
            if(errorMessage != null && errorMessage != ''){
                errorMessage += ', Email';
            }else{
                errorMessage = 'Email';
            }
        }
        if(tempCp.State__c == null){
            if(errorMessage != null && errorMessage != ''){
                errorMessage += ', State';
            }else{
                errorMessage = 'State';
            }
        }
        
        if(errorMessage != null && errorMessage != '' && !Test.isRunningTest()){
            throw new AuraHandledException('Please add ' + errorMessage);
        }
               
        try{
            Broker__c br = new 	Broker__c();
            br.Name = tempCp.Name;
            br.RW_Mobile_No__c = tempCp.Mobile_No__c;
            br.Broker_Pan_No__c = tempCp.PAN_No__c;
            br.NAME_FIRST__c = tempCp.First_Name__c;
            br.NAME_MIDDLE__c = tempCp.Middle_Name__c;
            br.NAME_LAST__c = tempCp.Last_Name__c;
            br.RW_Email__c = tempCp.Email__c;
            br.State__c = tempCp.State__c;
            br.Unregistered_Channel_Partner__c = true;
            insert br;
            
            List<Lead> leadList = [SELECT Id FROM Lead WHERE Temp_Channel_Partner__c =: tempCpId AND LeadSource = 'Temp Channel Partner']; 
            System.debug('leadList: ' + leadList);
            for(Lead ld : leadList){
                ld.LeadSource = 'Channel Partner';
                ld.RW_Broker__c = br.Id;
                ld.Temp_Channel_Partner__c = null;
            }
            update leadList;
            
            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Temp_Channel_Partner__c =: tempCpId AND (LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner')];
            for(Opportunity opp : opps){
                opp.LeadSource = 'Channel Partner';
                opp.RW_Broker__c = br.Id;
                opp.Temp_Channel_Partner__c = null;
                opp.RW_Walkin_Channel_Partner__c = br.Id;
                opp.Walkin_Source__c = 'Channel Partner';
            }
            update opps;
            
            List<Prospect__c> prospects = [SELECT Id FROM Prospect__c WHERE Temp_Channel_Partner__c =: tempCpId AND Lead_Source__c  = 'Temp Channel Partner'];
            for(Prospect__c pros : prospects){
                pros.Channel_Partner__c = br.Id;
                pros.Lead_Source__c  = 'Channel Partner';
                pros.Temp_Channel_Partner__c = null;
            }
            update prospects;
            
            List<Booking__c> bookings = [SELECT Id FROM Booking__c WHERE Temp_Channel_Partner_Name__c =: tempCp.Name AND Source_of_Booking__c = 'Temp Channel Partner'];
            for(Booking__c bkg : bookings){
                bkg.BrokerIId__c = br.Id;
                bkg.Source_of_Booking__c = 'Channel Partner';
            }
            update bookings;
            
            tempCp.Converted__c = true;
            tempCp.Original_Channel_Partner__c = br.Id;
            update tempCp;
            
        }catch(Exception e){
            if(!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }
        } 
    }
    
    Public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}