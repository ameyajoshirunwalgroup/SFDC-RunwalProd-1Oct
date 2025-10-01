trigger WelcomeCallTriggerToLoan on RW_Welcome_Call__c (after insert, after update) {

    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Welcome_Call_Loan_Creation' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    if(!byPassTriggerExceution){
        Map<String, Bank_with_RM__c> mapBankRM = Bank_with_RM__c.getall();
        Map<String, Project_Shortforms__c> projShortName = Project_Shortforms__c.getall();
        Map<String, RM_Usernames__c> mapRM = RM_Usernames__c.getall();
        List<Home_Loan_RM__c> HLRMs = [SELECT Id, Name, Project__c, Project__r.Name, RM_Name__c, TL_Name__c, TL_Email__c 
                                    FROM Home_Loan_RM__c];
        Map<String, Home_Loan_RM__c> hlrmMap = new Map<String, Home_Loan_RM__c>();
        Map<String, Home_Loan_RM__c> projRMMap = new Map<String, Home_Loan_RM__c>();
        List<Id> bkgIds = new List<Id>();
        for(Home_Loan_RM__c rm : HLRMs){
            hlrmMap.put(rm.Name, rm);
            projRMMap.put(rm.Project__r.Name, rm);
        }
        List<Loan__c> loansToInsert = new List<Loan__c>();
        if(Trigger.isInsert){
            for(RW_Welcome_Call__c welcall: trigger.new){
            if(welcall.RW_Mode_of_funding__c == 'Bank Loan' && welcall.RW_Welcome_Call_Status__c == 'Accept'){ 
                List<String> pref = new List<String>();
                if(welcall.RW_Banking_Preference_for_Loan__c != null){
                    pref = welcall.RW_Banking_Preference_for_Loan__c.split(',');
                }
                bkgIds.add(welcall.Booking_Id__c);
                Loan__c ln =  new Loan__c();
                ln.RW_Booking__c = welcall.Booking_Id__c;
                ln.RW_Customer_Loan_Preference__c = welcall.RW_Banking_Preference_for_Loan__c;
                ln.RW_Opportunity__c = welcall.RW_Booking__r.Customer__c;
                ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
                ln.RW_Project_Name__c = welcall.RW_Booking__r.Project__c;
                ln.RW_Tower__c = welcall.RW_Tower__c;
                ln.RW_Unit_No__c = welcall.RW_Booking__r.Unit_No__c;
                if(pref.size() > 0){
                    ln.RW_Bank_Name__c = pref[0];
                    for(Integer i=0;i<pref.size();i++){
                        if(i == 0){
                            ln.RW_Bank_Preference_1__c = pref[i];
                        }
                        if(i == 1){
                            ln.RW_Bank_Preference_2__c = pref[i];
                        }
                        if(i == 2){
                            ln.RW_Bank_Preference_3__c = pref[i];
                        }
                        
                    }
                    
                    //if(welcall.RW_Project__c == 'Runwal Gardens'){
                    if(mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c) != null){
                        ln.HL_RM_Name__c = mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).RM_Name__c;
                        ln.HL_TL_Name__c = mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Name__c;
                        ln.TL_Email__c = mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Email__c;
                    }else{
                        ln.HL_RM_Name__c = mapBankRM.get('Other' + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).RM_Name__c;
                        ln.HL_TL_Name__c = mapBankRM.get('Other' + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Name__c;
                        ln.TL_Email__c = mapBankRM.get('Other' + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Email__c;
                    }
                        
                    /*}else{
                        System.debug('welcall.RW_Project__c: ' + welcall.RW_Project__c);
                        System.debug('projRMMap.get(welcall.RW_Project__c): ' + projRMMap.get(welcall.RW_Project__c));
                        ln.HL_RM_Name__c = projRMMap.get(welcall.RW_Project__c).RM_Name__c;
                        ln.HL_TL_Name__c = projRMMap.get(welcall.RW_Project__c).TL_Name__c;
                        ln.TL_Email__c = projRMMap.get(welcall.RW_Project__c).TL_Email__c;
                    }*/
                    
                }/*else if(welcall.RW_Project__c == 'Runwal Gardens'){
                    ln.HL_TL_Name__c = System.label.Home_Loan_TL_Name;
                    ln.TL_Email__c = System.label.Home_Loan_TL_Email;
                }*/
                else{
                    ln.HL_RM_Name__c = projRMMap.get(welcall.RW_Project__c).RM_Name__c;
                    ln.HL_TL_Name__c = projRMMap.get(welcall.RW_Project__c).TL_Name__c;
                    ln.TL_Email__c = projRMMap.get(welcall.RW_Project__c).TL_Email__c;
                    }
                
                loansToInsert.add(ln);
            }
        }
        }
        
        if(Trigger.isUpdate){
            for(RW_Welcome_Call__c welcall: trigger.new){
            RW_Welcome_Call__c oldWelCall = (RW_Welcome_Call__c) Trigger.oldMap.get(welcall.Id);
            if(welcall.RW_Mode_of_funding__c == 'Bank Loan' && welcall.RW_Welcome_Call_Status__c == 'Accept' && 
            (oldWelCall.RW_Mode_of_funding__c != 'Bank Loan' || oldWelCall.RW_Welcome_Call_Status__c != 'Accept')){ 
                
                List<String> pref = new List<String>();
                if(welcall.RW_Banking_Preference_for_Loan__c != null){
                    pref = welcall.RW_Banking_Preference_for_Loan__c.split(',');
                }
                bkgIds.add(welcall.Booking_Id__c);
                Loan__c ln =  new Loan__c();
                ln.RW_Booking__c = welcall.Booking_Id__c;
                ln.RW_Customer_Loan_Preference__c = welcall.RW_Banking_Preference_for_Loan__c;
                ln.RW_Opportunity__c = welcall.RW_Booking__r.Customer__c;
                ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
                ln.RW_Project_Name__c = welcall.RW_Booking__r.Project__c;
                ln.RW_Tower__c = welcall.RW_Tower__c;
                ln.RW_Unit_No__c = welcall.RW_Booking__r.Unit_No__c;
                if(pref.size() > 0){
                    ln.RW_Bank_Name__c = pref[0];
                    for(Integer i=0;i<pref.size();i++){
                        if(i == 0){
                            ln.RW_Bank_Preference_1__c = pref[i];
                        }
                        if(i == 1){
                            ln.RW_Bank_Preference_2__c = pref[i];
                        }
                        if(i == 2){
                            ln.RW_Bank_Preference_3__c = pref[i];
                        }
                        
                    }
                    
                    //if(welcall.RW_Project__c == 'Runwal Gardens'){
                    system.debug('mapBankRM.getpref[0]'+mapBankRM.get(pref[0]));
                    system.debug('projShortName.get(welcall.RW_Project__c).Short_Name__c'+projShortName.get(welcall.RW_Project__c).Short_Name__c);   
                    if(mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c) != null){
                        ln.HL_RM_Name__c = mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).RM_Name__c;
                        ln.HL_TL_Name__c = mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Name__c;
                        ln.TL_Email__c = mapBankRM.get(pref[0] + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Email__c;
                    }else{
                        ln.HL_RM_Name__c = mapBankRM.get('Other' + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).RM_Name__c;
                        ln.HL_TL_Name__c = mapBankRM.get('Other' + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Name__c;
                        ln.TL_Email__c = mapBankRM.get('Other' + '-' + projShortName.get(welcall.RW_Project__c).Short_Name__c).TL_Email__c;
                    }
                        
                    /*}else{
                        System.debug('welcall.RW_Project__c: ' + welcall.RW_Project__c);
                        System.debug('projRMMap.get(welcall.RW_Project__c): ' + projRMMap.get(welcall.RW_Project__c));
                        ln.HL_RM_Name__c = projRMMap.get(welcall.RW_Project__c).RM_Name__c;
                        ln.HL_TL_Name__c = projRMMap.get(welcall.RW_Project__c).TL_Name__c;
                        ln.TL_Email__c = projRMMap.get(welcall.RW_Project__c).TL_Email__c;
                    }*/
                    
                }/*else if(welcall.RW_Project__c == 'Runwal Gardens'){
                    ln.HL_TL_Name__c = System.label.Home_Loan_TL_Name;
                    ln.TL_Email__c = System.label.Home_Loan_TL_Email;
                }*/
                else{
                    ln.HL_RM_Name__c = projRMMap.get(welcall.RW_Project__c).RM_Name__c;
                    ln.HL_TL_Name__c = projRMMap.get(welcall.RW_Project__c).TL_Name__c;
                    ln.TL_Email__c = projRMMap.get(welcall.RW_Project__c).TL_Email__c;
                    }
                
                loansToInsert.add(ln);
            }
        }
        }
        
        insert loansToInsert;
        List<Booking__c> bkgs = [SELECT Id, Name, Funding_Status__c FROM Booking__c WHERE Id =: bkgIds];
        List<Booking__c> bksToUpdate =  new List<Booking__c>();
        for(Booking__c bk : bkgs){
            bk.Funding_Status__c = 'Loan Bank';
            bksToUpdate.add(bk);
        }
        BookingTriggerHandler.byPass = true;
        update bksToUpdate;
        BookingTriggerHandler.byPass = false;
        List<Loan__c> lns = new List<Loan__c>();
        for(Loan__c l : loansToInsert){
            if(l.HL_RM_Name__c == null){
                lns.add(l);
            }
        }
    }
}