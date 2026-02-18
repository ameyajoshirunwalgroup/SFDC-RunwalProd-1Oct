public class BrokerageSchemeTriggerHandler {
    //Added by Prashant to Update all the bookings that come under scheme. //20-2-2025
	public static void BrokerageSchemeTagging(List<Id> bsIds){
        system.debug('brokerage scheme ids -->'+bsIds);
        List<Booking__c> bookingListtoUpdate = new List<Booking__c>();
        list<Brokerage_Scheme__c> brokerageScheme = [Select Id,Start_Date__c,End_Date__c,Type__c,Base_Brokerage_for_Local_Bookings__c,Name,Base_Brokerage_for_OS_NRI__c,Base_Brokerage_for_NRI__c from Brokerage_Scheme__c where Id IN: bsIds and Approval_Status__c = 'Approved by Level 2' ];
        list<Scheme_Configuration__c> schemeConfigurations = [Select Id,Project__r.Id,Tower__r.Id,Type__c from Scheme_Configuration__c where Brokerage_Scheme__c IN: bsIds ];
        List<String> schemeTowers = new List<String>();
        List<String> schemeProjects = new List<String>();
        String dynamicQuery = '';
        
        system.debug('schemeConfigurations'+schemeConfigurations);
        if(!schemeConfigurations.isEmpty()){
            for(Scheme_Configuration__c sc:schemeConfigurations){
                system.debug('schemeConfigurations :- Tower:-'+sc.Tower__r.Id + '| Project :-' + sc.Project__r.Id);
                if (sc.Tower__r.Id != null) {
                    schemeTowers.add(sc.Tower__r.Id);
                }
                if (sc.Project__r.Id != null) {
                    schemeProjects.add(sc.Project__r.Id);
                }
            }
        }
        system.debug('schemeProjects'+schemeProjects);
        system.debug('schemeTowers'+schemeTowers);
        
        if(!brokerageScheme.isEmpty() && !schemeConfigurations.isEmpty()){
            Date startDate = brokerageScheme[0].Start_Date__c;
            Date endDate = brokerageScheme[0].End_Date__c.addDays(1);   
            String typeofScheme = brokerageScheme[0].Type__c;
            
            system.debug('Inside brokerageScheme');
            
            dynamicQuery = 'SELECT Id, Name, Opportunity__c, BrokerIId__c, Agreement_Value_for_brokers__c, Project__c, Booking_Date__c, Tower__c, X5_Received__c, Type_of_Client__c, '+
                'RW_X9_99_Received__c, RW_Registration_Done__c, Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c, Type_Of_Client_Formula__c,Project__r.Name,Quotation__r.Brokerage_Agreement_Value__c,Passback_Amount__c '+
                'FROM Booking__c WHERE '+
                'Project__c != NULL AND (Status__c = \'Booking Confirmed\' OR Status__c = \'UnProcessed\' OR Status__c = \'Sent for Approval\') '+
                'AND BrokerIId__c != NULL AND Opportunity__c != NULL AND Exclude_From_Brokerage_Batch__c = FALSE '+
                'AND Brokerage_Summary__c = NULL '+
                'AND Booking_Date__c > 2022-09-29T23:01:01Z '+
                'AND Type_of_Client__c != NULL '+
                'AND Source_of_Booking__c = \'Channel Partner\' '+
                'AND Brokerage_Scheme__c = NULL '+
                'AND Booking_Date__c >=: startDate '+
                'AND Booking_Date__c <=: endDate ';                 

            if(typeofScheme == 'Both'){
                dynamicQuery += 'AND (Type_Of_Client_Formula__c =\'Local\' OR  Type_Of_Client_Formula__c =\'NRI\' OR Type_Of_Client_Formula__c =\'Outstation\') ';
            }else if(typeofScheme == 'Local' || typeofScheme == 'NRI' || typeofScheme == 'Outstation'){
                dynamicQuery += 'AND Type_Of_Client_Formula__c =: typeofScheme ';
            }
            if (!schemeTowers.isEmpty()) {
                dynamicQuery += ' AND Unit_No__r.TowerName__c IN :schemeTowers';
            }
            if (!schemeProjects.isEmpty()) {
                dynamicQuery += ' AND Project__c IN :schemeProjects';
            }
            dynamicQuery += ' ORDER BY Booking_Date__c ASC';
            system.debug('dynamicQuery'+dynamicQuery);
             list<Booking__c> bookingList = new list<Booking__c>();
           
            bookingList= Database.query(dynamicQuery);
            system.debug('bookingList'+bookingList);
            system.debug('bookingList size'+bookingList.size());
            Date bookingDate2 = Date.ValueOf('2024-04-1T06:00:00.000Z');
            if(!bookingList.isEmpty()){
                for(Booking__c bk : bookingList){
                     Date bookingDate = Date.ValueOf(bk.Booking_Date__c);
                    system.debug('Bookings to be Tagged --- > '+bk.Name + 'Project - ' + bk.Project__r.name);
                   /* if(brokerageScheme[0].Type__c == 'Local'  ){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if( brokerageScheme[0].Type__c == 'NRI' && bookingDate < bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }
                    else if( brokerageScheme[0].Type__c == 'NRI' && bookingDate >= bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }
                    else if( brokerageScheme[0].Type__c == 'Both' && (bk.Type_of_Client__c == 'Local' || bk.Type_of_Client__c == 'Corporate' )){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if( brokerageScheme[0].Type__c == 'Both' && (bk.Type_of_Client__c == 'NRI' || bk.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }
                    else if(brokerageScheme[0].Type__c == 'Both' && (bk.Type_of_Client__c == 'NRI' || bk.Type_of_Client__c == 'Outstation') && bookingDate >= bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }  */
                    
                    //Added by Prashant to Handle base brokerage for NRI differently// 22-10-25. START
                    if(!brokerageScheme.isEmpty() && (brokerageScheme[0].Type__c == 'Both' || brokerageScheme[0].Type__c == 'Local') && (bk.Type_of_Client__c == 'Local' || bk.Type_of_Client__c == 'Corporate' )){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(!brokerageScheme.isEmpty() && (brokerageScheme[0].Type__c == 'Both' || brokerageScheme[0].Type__c == 'NRI') && (bk.Type_of_Client__c == 'NRI') /*|| bk.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2*/){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_NRI__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    } else if(!brokerageScheme.isEmpty() && (brokerageScheme[0].Type__c == 'Both' || brokerageScheme[0].Type__c == 'Outstation') && (bk.Type_of_Client__c == 'Outstation') /*&& bookingDate < bookingDate2*/){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }
                     //Added by Prashant to Handle base brokerage for NRI differently// 22-10-25. END
                }
            }
            
            List<Id> updatedBookingIds = new List<Id>();
            
            List<Database.SaveResult> results = Database.update(bookingList, true);
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult result = results[i];
                if (result.isSuccess()) {
                    updatedBookingIds.add(bookingList[i].Id);
                } else {
                    for (Database.Error err : result.getErrors()) {
                        System.debug('Error: ' + err.getStatusCode() + ' ' + err.getMessage());
                    }
                }
            }
        
            //Send Emails to SM and inform the scheme tagging and document verification continuation for the customers.
            if(!updatedBookingIds.isEmpty()){
                //SendEmailtoSMforSchemeTagging.SendEmailtoSMforSchemeTagging(updatedBookingIds);
            }
    }
}
        
}