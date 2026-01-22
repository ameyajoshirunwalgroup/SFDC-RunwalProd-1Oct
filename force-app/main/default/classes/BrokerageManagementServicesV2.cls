public class BrokerageManagementServicesV2 {
    public static void brokerageCalculation(Set<ID> bookingId){
        system.debug('Inside brokerageCalculation method');
        List<Opportunity> optyList = new List<Opportunity>();
        List<Opportunity> optyList1 = new List<Opportunity>();
        List<Booking__c> bkList1 = new List<Booking__c>();
        List<Booking__c> bkList2 = new List<Booking__c>();
        List<Booking__c> bkList3 = new List<Booking__c>();
        List<Booking__c> bkList4 = new List<Booking__c>();
        List<Booking__c> bkList5 = new List<Booking__c>();
        List<Booking__c> updatebkList = new List<Booking__c>();
        List<Brokerage_Scheme__c> brokerageScheme = new List<Brokerage_Scheme__c>();
        List<Brokerage_Scheme__c> brokerageScheme1 = new List<Brokerage_Scheme__c>();
        List<Brokerage__c> brokerage = new List<Brokerage__c>();
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        List<Brokerage_Slab__c> brokerageSlab = new List<Brokerage_Slab__c>();
        List<Scheme_Configuration__c> sc = new List<Scheme_Configuration__c>();
        List<Scheme_Configuration__c> scprojtower = new List<Scheme_Configuration__c>();
        set<ID> scprj = new set<ID>();
        set<ID> sctower = new set<ID>();
        set<ID> cpID = new set<ID>();
        set<ID> bcpID = new set<ID>();
        set<ID> bId = new set<ID>();
        set<ID> bookId = new set<ID>();
        List<Project__c> proj1 = new List<Project__c>();
        List<Tower__c> t1 = new List<Tower__c>();
        Integer count = 0;
        Date bookingDate1;
        Date startDate;
        Date endDate;
        Decimal totalAV = 0.0;
        String KickerIncentiveId;
        Decimal KickerPercentage;
        bkList1 = [select Id,Name,Opportunity__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,Passback__c,Type_of_Client__c,RW_Registration_Date__c,
                   RW_Total_Receipt_Amount_Received__c,RW_Registration_Done__c,RW_Registration_Status__c,Brokerage_Scheme__c,BrokerIId__c,Is_Special_Brokerage_Scheme__c,RW_X9_99_Received__c,Is_AOP_CP_Applicable__c,Type_Of_Client_Formula__c  from Booking__c 
                   where Id IN : bookingId and Project__c != null and BrokerIId__c != null and Brokerage_Summary__c = null and Opportunity__c != null];
        system.debug('bkList1::'+bkList1);
        system.debug('bkList1 size::'+bkList1.size());
        
        if(!bkList1.isEmpty()){
            system.debug('Inside bkList1 if block---');
            for(Booking__c bk : bkList1){
                system.debug('Inside for loop 1');
                bookingDate1 = Date.ValueOf(bk.Booking_Date__c);
                sc = [Select Id,Name,Brokerage_Scheme__c,Type__c,Tower__c,Project__c from Scheme_Configuration__c where ((Project__c =:bk.Project__c and Tower__c =:bk.Tower__c) OR (Project__c =:bk.Project__c and Tower__c =:null)) and (Type__c =: bk.Type_Of_Client_Formula__c OR Type__c =: 'Both') and Active__c = true];
                system.debug('sc::'+sc);
                
                if(bk.BrokerIId__c != null && bk.Project__c != null ){
                    system.debug('Inside if of for loop 1');
                    if(!sc.isEmpty()){
                        scprojtower = [Select id,Tower__c,Project__c from Scheme_Configuration__c where Brokerage_Scheme__c =: sc[0].Brokerage_Scheme__c];
                        for(Scheme_Configuration__c scon :scprojtower){
                            if(scon.Project__c != null && scon.Tower__c != null){
                                scprj.add(scon.Project__c);
                                sctower.add(scon.Tower__c);
                            }else{
                                scprj.add(scon.Project__c);
                            }
                        }
                        system.debug('scprj::'+scprj);
                        system.debug('sctower::'+sctower);
                        brokerageScheme1 = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,Approval_Status__c,Type__c,AOP_CP__c,
                                            Start_Date__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and
                                            Start_Date__c <=: bookingDate1 and (End_Date__c = null or End_Date__c >=: bookingDate1) and Approval_Status__c = 'Approved by Level 2'];
                        system.debug('brokerageScheme1::'+brokerageScheme1);
                    }
                    if(!brokerageScheme1.isEmpty()){
                        system.debug('Inside brokerageScheme1 if-- ');
                        bk.Brokerage_Scheme__c = brokerageScheme1[0].id;
                        bkList2.add(bk);
                        startDate = brokerageScheme1[0].Start_Date__c;
                        endDate = brokerageScheme1[0].End_Date__c;
                        system.debug('startDate::'+ startDate +' endDate::'+endDate);
                    }
                    if(!bkList2.isEmpty()){
                        update bkList2;
                        system.debug('updated bkList2::'+bkList2);
                        system.debug('updated bkList2 size::'+bkList2.size());
                    }
                    if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && sctower.isEmpty()){
                        if(brokerageScheme1[0].Type__c == 'Local' && (bk.RW_Registration_Date__c != Null || (bk.RW_Registration_Date__c ==null &&(bk.Is_Special_Brokerage_Scheme__c == true || bk.Is_AOP_CP_Applicable__c == true)))){
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Is_Special_Brokerage_Scheme__c,RW_X9_99_Received__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_X9_99_Received__c = true or X5_Received__c = true ) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                            system.debug('bkList3 Local::'+bkList3);
                                        system.debug('Local bkList3 size::'+bkList3.size());
                        }else if(brokerageScheme1[0].Type__c == 'NRI'){
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                        (RW_X9_99_Received__c = true or  X5_Received__c = true) and  
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }else if(brokerageScheme1[0].Type__c == 'Both'){
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and (Type_of_Client__c =:'Local' OR Type_of_Client__c =:'NRI') and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       ( RW_Registration_Date__c != null or(RW_Registration_Date__c = Null and  (Type_of_Client__c ='NRI' or  Type_of_Client__c ='Outstation' or Is_Special_Brokerage_Scheme__c = true or Is_AOP_CP_Applicable__c = true ))) and (RW_X9_99_Received__c = true or X5_Received__c = true) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }
                    } 
                        else if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty()){
                        if(brokerageScheme1[0].Type__c == 'Local' && (bk.RW_Registration_Date__c != Null || (bk.RW_Registration_Date__c ==null && (bk.Is_Special_Brokerage_Scheme__c == true ||bk.Is_AOP_CP_Applicable__c == true)))){
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and (RW_X9_99_Received__c = true or  X5_Received__c = true) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }
                         
                        else if(brokerageScheme1[0].Type__c == 'NRI'){
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_X9_99_Received__c = true or  X5_Received__c = true) and 
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                           
                        }else if(brokerageScheme1[0].Type__c == 'Both'){
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and (Type_of_Client__c =:'Local' OR Type_of_Client__c =:'NRI') and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       ( RW_Registration_Date__c != null or(RW_Registration_Date__c = Null and  (Type_of_Client__c ='NRI' or  Type_of_Client__c ='Outstation' or  Is_Special_Brokerage_Scheme__c = true) ))  and (RW_X9_99_Received__c = true or X5_Received__c = true) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }
                    }
                    
                    system.debug('ngs                         vt::'+bkList3);
                    system.debug('bkList3 size::'+bkList3.size());
                }
                if(bk.Id != null){
                    bId.add(bk.Id);
                    system.debug('bId::'+ bId);
                    system.debug('bId::'+ bId.size());
                }
            }
        }
        
        bkList5 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Type_of_Client__c,Passback__c,Account__c,X5_Received__c,Is_AOP_CP_Applicable__c,RW_Registration_Date__c,
                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Brokerage__c,Custom_Base_Brokerage__c,Unit_No__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c,Passback_Amount__c, Dif_Br__c,Type_Of_Client_Formula__c
                   from Booking__c where Id IN: bId
                   and BrokerIId__c != null];
        if(!bkList3.isEmpty()){
            for(Booking__c bk : bkList5){
                Date bookingDate = Date.ValueOf(bk.Booking_Date__c);
                Date startDate1;
                Date endDate1;
                system.debug('bookingDate::'+bookingDate);
                if(bk.BrokerIId__c != null){
                    system.debug('Inside 1st If----op.BrokerIId__c::'+bk.BrokerIId__c);
                    cpID.add(bk.BrokerIId__c);
                    system.debug('cpID::'+cpID);
                }
                sc = [Select Id,Name,Brokerage_Scheme__c,Type__c from Scheme_Configuration__c where ((Project__c =:bk.Project__c and Tower__c =:bk.Tower__c) OR (Project__c =:bk.Project__c and Tower__c =:null)) and (Type__c =: bk.Type_of_Client__c OR Type__c =: 'Both')  and Active__c = true];
                system.debug('sc::'+sc);
                
                
                if(!sc.isEmpty()){
                    system.debug('Inside 2nd If----bk.Project__c::'+bk.Project__c);
                    brokerageScheme = [select Id,Name,Base_Brokerage__c,AOP_CP__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,Approval_Status__c,Base_Brokerage_for_Local_Bookings__c,Base_Brokerage_for_OS_NRI__c,Base_Brokerage_for_NRI__c,
                                       Start_Date__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and
                                       Start_Date__c <=: bookingDate and (End_Date__c = null or End_Date__c >=: bookingDate) and Approval_Status__c = 'Approved by Level 2'];
                    
                }
                system.debug('brokerageScheme::'+brokerageScheme);
                if(!brokerageScheme.isEmpty()){
                    startDate1 = brokerageScheme[0].Start_Date__c;
                    endDate1 = brokerageScheme[0].End_Date__c;
                    List<Brokerage_Summary__c> bs1 = new List<Brokerage_Summary__c>();
                    List<Brokerage__c> brokerage1 = new List<Brokerage__c>();
                    List<Brokerage__c> Kickerincentive1 = new List<Brokerage__c>();
                    system.debug('Inside BrokerageScheme if');
                    bk.Brokerage_Scheme__c = brokerageScheme[0].Id;
                    bk.Brokerage_Scheme_Name__c = brokerageScheme[0].Name;
                    KickerIncentiveId = GetKickerIncentives(bk.Unit_No__c,bookingDate,bk.Project__c,bk.Tower__c,bk.Type_of_Client__c);
                    if(bk.Custom_Base_Brokerage__c != null){
                        bk.Base_Brokerage__c = bk.Custom_Base_Brokerage__c - bk.Passback__c ;
                        bk.Brokerage__c = bk.Custom_Base_Brokerage__c - bk.Passback__c;
                        bk.Kicker_Incentive_lookup__c = KickerIncentiveId;
                    }else{
                        if(bk.Type_Of_Client_Formula__c == 'Local' || bk.Type_Of_Client_Formula__c == 'Corporate'){
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c ;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c ;
                            if(KickerIncentiveId != null){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        }
                        //Added by Prashant to add NRI base brokerage.//22-10-25.START
                        else if(bk.Type_Of_Client_Formula__c == 'NRI'){
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - bk.Passback__c;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - bk.Passback__c;
                            if(KickerIncentiveId != null){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        }  
                        //Added by Prashant to add NRI base brokerage.//22-10-25.END
                        else if(bk.Type_Of_Client_Formula__c == 'Outstation'){
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c;
                            if(KickerIncentiveId != null){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        }  
                    }
                    
                    
                    updatebkList.add(bk);
                    if(!updatebkList.isEmpty()){
                        update updatebkList;
                        system.debug('updatebkList::'+updatebkList);
                    }
                    
                    brokerSummaryList = [select Id,Name,Broker__c,Brokerage_Scheme__c,Opportunity__c from Brokerage_Summary__c where Booking__c =: bk.Id and Broker__c IN : cpID];
                    system.debug('brokerSummaryList::'+brokerSummaryList);
                    
                    
                    List<Brokerage_Summary__c> updateBrokerSummarySlab1 = new List<Brokerage_Summary__c>();
                    List<Brokerage_Slab__c> brokerageSlab1 = new List<Brokerage_Slab__c>();
                    List<Brokerage_Slab__c> brokerageSlabAV = new List<Brokerage_Slab__c>();
                    List<Booking__c> bookingList11 = new List<Booking__c>();
                    List<Brokerage_Scheme__c> brokerageScheme2 = new List<Brokerage_Scheme__c>();
                    List<Brokerage__c> brokerage2 = new List<Brokerage__c>();
                    List<Brokerage__c> brokerage3 = new List<Brokerage__c>();
                    List<Brokerage__c> Existingbrokerage = new List<Brokerage__c>();
                    List<Brokerage_Summary__c> updateBrokerSummarySlab = new List<Brokerage_Summary__c>();
                    List<Brokerage_Summary__c> BrokerSummarySlab2 = new List<Brokerage_Summary__c>();
                    List<Brokerage_Summary__c> updateBrokerSummarySlab3 = new List<Brokerage_Summary__c>();
                    List<Booking__c> bookList11 = new List<Booking__c>();
                    set<Id> bkId = new set<Id>();
                    map<Id,Id> mapforoptyAndBrokerSum = new map<Id,Id>();
                    
                    brokerageSlab1 = [select id,Name,From__c,To__c,Total_Brokerage__c,Base_Brokerage__c,Additional_Brokerage__c,Brokerage_Scheme__c,
                                      Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c,Base_Brokerage_for_Local_Bookings__c,
                                      Base_Brokerage_for_OS_NRI__c,Base_Brokerage_for_NRI__c,Total_Brokerage_for_OS_NRI__c,Total_Brokerage_for_Local_Bookings__c from Brokerage_Slab__c
                                      where Brokerage_Scheme__c =: brokerageScheme[0].Id And Slab_No__c = 1];
                    system.debug('brokerageSlab1::'+brokerageSlab1);
                    
                    
                    
                    bkList4 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,Type_of_Client__c,Passback__c,
                               RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Is_Special_Brokerage_Scheme__c,RW_X9_99_Received__c,X5_Received__c,Type_Of_Client_Formula__c from Booking__c where Id =: bk.Id];
                    system.debug('bkList4::'+bkList4);
                    
                    if(bk.Is_AOP_CP_Applicable__c){
                        if((bk.X5_Received__c && bk.RW_X9_99_Received__c == false) ||( bk.RW_X9_99_Received__c && bk.RW_Registration_Date__c ==Null) ) {
                            if(brokerSummaryList.isEmpty() && !brokerageSlab1.isEmpty()){
                                system.debug('Inside empty brokerSummaryList-------');
                                //create a brokerage summary record
                                Brokerage_Summary__c bs = new Brokerage_Summary__c();
                                bs.Channel_Partner__c = bk.BrokerIId__c;
                                bs.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                bs.CP_Account__c = bk.Account__c;
                                if(!bkList4.isEmpty())
                                    bs.Booking__c = bkList4[0].id;
                                bs.Opportunity__c = bkList4[0].Customer__c;
                                bs.Status__c = 'Not Due';
                                bs1.add(bs) ;
                                if(!bs1.isEmpty()){
                                    insert bs1;
                                    system.debug('bs1 inserted::'+bs1);
                                    for(Brokerage_Summary__c bss :bs1){
                                        Booking__c book = new Booking__c();
                                        book.Brokerage_Summary__c = bss.id;
                                        book.Id = bk.Id;
                                        update book;
                                    }
                                }
                                
                                // if(!brokerageSlab1.isEmpty()){
                                //create a brokerage slab record
                                Brokerage__c b = new Brokerage__c();
                                if(brokerSummaryList.isEmpty()){
                                    b.Brokerage_Summary__c = bs1[0].Id;
                                }else{
                                    b.Brokerage_Summary__c = brokerSummaryList[0].Id;
                                }
                                b.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                b.Opportunity__c = bk.Customer__c;
                                b.Booking__c = bk.Id;
                                b.Channel_Partner__c = bk.BrokerIId__c;
                                b.Brokerage_Type__c = 'Base Brokerage';
                                b.Name = 'Base Brokerage';
                                b.Eligible_Slab__c = 'Slab 1';
                                b.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                                /* if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Is_Special_Brokerage_Scheme__c == true ||bkList4[0].Is_Special_Brokerage_Scheme__c == true)){
b.Status__c = 'Due';
}
if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Type_of_Client__c == 'NRI' ||bk.Type_of_Client__c == 'Outstatoin')){
b.Status__c = 'Due';
}*/
                                
                                
                                if(bk.Custom_Base_Brokerage__c != null){
                                    b.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                        
                                    }
                                    
                                }else{	
                                    if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                        b.Brokerage__c = brokerageSlab1[0].Base_Brokerage_for_Local_Bookings__c - brokerageScheme[0].AOP_CP__c;
                                        // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );  
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                        }
                                    }
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'NRI'){
                                        b.Brokerage__c = brokerageSlab1[0].Base_Brokerage_for_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } 
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'Outstation'){
                                        b.Brokerage__c = brokerageSlab1[0].Base_Brokerage_for_OS_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } 
                                    /*else{
                                        b.Brokerage__c = brokerageSlab1[0].Base_Brokerage_for_OS_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } */
                                }                                                                                                
                                brokerage1.add(b);                                   
                                Brokerage__c b1 = new Brokerage__c();
                                if(brokerSummaryList.isEmpty()){
                                    b1.Brokerage_Summary__c = bs1[0].Id;
                                }else{
                                    b1.Brokerage_Summary__c = brokerSummaryList[0].Id;
                                }
                                b1.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                b1.Opportunity__c = bk.Customer__c;
                                b1.Booking__c = bk.Id;
                                b1.Channel_Partner__c = bk.BrokerIId__c;
                                b1.Brokerage_Type__c = 'Base Brokerage';
                                b1.Name = '1% Brokerage';
                                b1.Eligible_Slab__c = 'Slab 1';
                                b1.AOP_CP__c = true;
                                b1.Status__c = 'Due';
                                b1.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                                if(bk.Custom_Base_Brokerage__c != null){
                                    b1.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b1.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                        system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );
                                    }
                                    else{
                                        b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b1.Brokerage__c / 100))) ;
                                        system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c);
                                        
                                    }
                                    
                                }else{	
                                    if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                        b1.Brokerage__c = brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );              
                                        }
                                        else{
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+b1.Brokerage_Amount__c );
                                            
                                        }
                                                                                
                                    }else{
                                        b1.Brokerage__c = brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c ) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c ) / 100)));
                                            system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );
                                            
                                        }
                                        
                                    } 
                                }
                                brokerage1.add(b1);
                                if(!brokerage1.isEmpty() ){
                                    insert brokerage1;
                                    system.debug('brokerage1 inserted::'+brokerage1);
                                    
                                    Brokerage_Summary__c bs3 = new Brokerage_Summary__c();
                                    bs3.Id = brokerage1[0].Brokerage_Summary__c; 
                                    bs3.Applied_Slab_Name__c = brokerageSlab1[0].Name;
                                    system.debug('Applied_Slab_Name__c::'+bs3.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+brokerageSlab1[0].Name);
                                    updateBrokerSummarySlab1.add(bs3);
                                    system.debug('Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                
                                if(!updateBrokerSummarySlab1.isEmpty()){
                                    update updateBrokerSummarySlab1;
                                    system.debug('Updated Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                
                            }
                            
                        }else if((bk.X5_Received__c && bk.RW_X9_99_Received__c && (bk.RW_Registration_Date__c != null ||(bk.RW_Registration_Date__c == Null &&  (bk.Type_of_Client__c =='NRI' ||  bk.Type_of_Client__c =='Outstation' || bk.Is_Special_Brokerage_Scheme__c == true ))))){//( RW_Registration_Date__c != null or(RW_Registration_Date__c = Null and  (Type_of_Client__c ='NRI' or  Type_of_Client__c ='Outstation' or Is_Special_Brokerage_Scheme__c = true or Is_AOP_CP_Applicable__c = true )))
                            if(brokerSummaryList.isEmpty() && !brokerageSlab1.isEmpty()){
                                system.debug('Inside empty brokerSummaryList-------');
                                //create a brokerage summary record
                                Brokerage_Summary__c bs = new Brokerage_Summary__c();
                                bs.Channel_Partner__c = bk.BrokerIId__c;
                                bs.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                bs.CP_Account__c = bk.Account__c;
                                if(!bkList4.isEmpty())
                                    bs.Booking__c = bkList4[0].id;
                                bs.Opportunity__c = bkList4[0].Customer__c;
                                bs.Status__c = 'Not Due';
                                bs1.add(bs) ;
                                if(!bs1.isEmpty()){
                                    insert bs1;
                                    system.debug('bs1 inserted::'+bs1);
                                    for(Brokerage_Summary__c bss :bs1){
                                        Booking__c book = new Booking__c();
                                        book.Brokerage_Summary__c = bss.id;
                                        book.Id = bk.Id;
                                        update book;
                                    }
                                }
                                //create a brokerage slab record
                                Brokerage__c b = new Brokerage__c();
                                if(brokerSummaryList.isEmpty()){
                                    b.Brokerage_Summary__c = bs1[0].Id;
                                }else{
                                    b.Brokerage_Summary__c = brokerSummaryList[0].Id;
                                }
                                b.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                b.Opportunity__c = bk.Customer__c;
                                b.Booking__c = bk.Id;
                                b.Channel_Partner__c = bk.BrokerIId__c;
                                b.Brokerage_Type__c = 'Base Brokerage';
                                b.Name = 'Base Brokerage';
                                b.Eligible_Slab__c = 'Slab 1';
                                b.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
     
                                if(bk.Custom_Base_Brokerage__c != null){
                                    b.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                        system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        
                                    }
                                    
                                }else{	
                                    if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                        b.Brokerage__c = (brokerageSlab1[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                                                                        
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                                                                
                                    }
                                    //Added by Prashant
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'NRI'){
                                        b.Brokerage__c = brokerageSlab1[0].Base_Brokerage_for_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } 
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'Outstation'){
                                        b.Brokerage__c = brokerageSlab1[0].Base_Brokerage_for_OS_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } 
                                    
                                    /*else{
                                        b.Brokerage__c = (brokerageSlab1[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }
                                        
                                    } */
                                    //Added by Prashant END
                                }
                                                               
                                brokerage1.add(b);
                                if(!brokerage1.isEmpty() ){
                                    insert brokerage1;
                                    system.debug('brokerage1 inserted::'+brokerage1);
                                    
                                    Brokerage_Summary__c bs3 = new Brokerage_Summary__c();
                                    bs3.Id = brokerage1[0].Brokerage_Summary__c; 
                                    bs3.Applied_Slab_Name__c = brokerageSlab1[0].Name;
                                    system.debug('Applied_Slab_Name__c::'+bs3.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+brokerageSlab1[0].Name);
                                    updateBrokerSummarySlab1.add(bs3);
                                    system.debug('Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                
                                if(!updateBrokerSummarySlab1.isEmpty()){
                                    update updateBrokerSummarySlab1;
                                    system.debug('Updated Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                
                            }
                        }
                    }else{
                        if(brokerSummaryList.isEmpty() && !brokerageSlab1.isEmpty() && bk.RW_X9_99_Received__c && (bk.RW_Registration_Date__c != null ||(bk.RW_Registration_Date__c == Null &&  (bk.Type_of_Client__c =='NRI' ||  bk.Type_of_Client__c =='Outstation' || bk.Is_Special_Brokerage_Scheme__c == true )))){
                            system.debug('Inside empty brokerSummaryList-------');
                            //create a brokerage summary record
                            Brokerage_Summary__c bs = new Brokerage_Summary__c();
                            bs.Channel_Partner__c = bk.BrokerIId__c;
                            bs.Brokerage_Scheme__c = brokerageScheme[0].Id;
                            bs.CP_Account__c = bk.Account__c;
                            if(!bkList4.isEmpty())
                                bs.Booking__c = bkList4[0].id;
                            bs.Opportunity__c = bkList4[0].Customer__c;
                            bs.Status__c = 'Not Due';
                            bs1.add(bs) ;
                            if(!bs1.isEmpty()){
                                insert bs1;
                                system.debug('bs1 inserted::'+bs1);
                                for(Brokerage_Summary__c bss :bs1){
                                    Booking__c book = new Booking__c();
                                    book.Brokerage_Summary__c = bss.id;
                                    book.Id = bk.Id;
                                    update book;
                                }
                            }                            
                            // if(!brokerageSlab1.isEmpty()){
                            //create a brokerage slab record
                            Brokerage__c b = new Brokerage__c();
                            if(brokerSummaryList.isEmpty()){
                                b.Brokerage_Summary__c = bs1[0].Id;
                            }else{
                                b.Brokerage_Summary__c = brokerSummaryList[0].Id;
                            }
                            b.Brokerage_Scheme__c = brokerageScheme[0].Id;
                            b.Opportunity__c = bk.Customer__c;
                            b.Booking__c = bk.Id;
                            b.Channel_Partner__c = bk.BrokerIId__c;
                            b.Brokerage_Type__c = 'Base Brokerage';
                            b.Name = 'Base Brokerage';
                            b.Eligible_Slab__c = 'Slab 1';
                            b.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                             if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Is_Special_Brokerage_Scheme__c == true ||bkList4[0].Is_Special_Brokerage_Scheme__c == true)){
b.Status__c = 'Due';
}
if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Type_of_Client__c == 'NRI' ||bk.Type_of_Client__c == 'Outstation')){
b.Status__c = 'Due';
}
                            
                            if(bk.Custom_Base_Brokerage__c != null){
                                b.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                if(bk.Passback_Amount__c > 0){
                                    b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                    system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                }
                                else{
                                    b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                    system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    
                                }
                                
                            }else{	
                                if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                    b.Brokerage__c = (brokerageSlab1[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                        system.debug('Brokerage Amount 291 ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                        
                                    }                                    
                                    
                                }
                                
                                else if(bkList4[0].Type_Of_Client_Formula__c == 'NRI'){
                                    b.Brokerage__c = (brokerageSlab1[0].Base_Brokerage_for_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                        system.debug('Brokerage Amount 291 ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                        
                                    }                                                                                  
                                } 
                                else if(bkList4[0].Type_Of_Client_Formula__c == 'Outstation'){
                                    b.Brokerage__c = (brokerageSlab1[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                        system.debug('Brokerage Amount 291 ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                        
                                    }                                                                                   
                                } 
                                /*else{
                                    b.Brokerage__c = (brokerageSlab1[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                        system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                        system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        
                                    }
                                    
                                } */
                                //Added by Prashant END
                            }
                           brokerage1.add(b);
                            if(!brokerage1.isEmpty() ){
                                insert brokerage1;
                                system.debug('brokerage1 inserted::'+brokerage1);
                                
                                Brokerage_Summary__c bs3 = new Brokerage_Summary__c();
                                bs3.Id = brokerage1[0].Brokerage_Summary__c; 
                                bs3.Applied_Slab_Name__c = brokerageSlab1[0].Name;
                                system.debug('Applied_Slab_Name__c::'+bs3.Applied_Slab_Name__c);
                                system.debug('brokerageSlab1[0].Name::'+brokerageSlab1[0].Name);
                                updateBrokerSummarySlab1.add(bs3);
                                system.debug('Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                            }
                            
                            if(!updateBrokerSummarySlab1.isEmpty()){
                                update updateBrokerSummarySlab1;
                                system.debug('Updated Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                            }
                            
                        }
                    }
                    
                }
            }
            
        }        
        
        
    }
    
    public static void insertCancelledBrokerage(set<Id> bId){
        system.debug('Inside insertCancelledBrokerage method------');
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Booking__c> bookList = new List<Booking__c>();
        List<Booking__c> bookList2 = new List<Booking__c>();
        List<Booking__c> bookList3 = new List<Booking__c>();
        List<Brokerage_Summary__c> brokerSummary1 = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> brokerSummary2 = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> updateBrokerSummarySlab4 = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerage4 = new List<Brokerage__c>();
        List<Brokerage__c> brokerage5 = new List<Brokerage__c>();
        List<Brokerage_Slab__c> slab1 = new List<Brokerage_Slab__c>();
        List<Brokerage_Slab__c> slab2 = new List<Brokerage_Slab__c>();
        List<Brokerage_Slab__c> slab3 = new List<Brokerage_Slab__c>();
        List<Brokerage_Scheme__c> scheme = new List<Brokerage_Scheme__c>();
        List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
        List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
        set<Id> oppId1 = new set<Id>();
        set<Id> slabId1 = new set<Id>();
        Decimal totalAV = 0.0;
        Integer count = 0;
        bookList = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,
                    RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c ,Type_Of_Client_Formula__c from Booking__c where
                    Id IN:bId and Status__c = 'Cancelled' and BrokerIId__c != null];
        
        cancelledbrokerage = [Select id,name,Cancelled__c,Brokerage_Summary__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                              from Brokerage__c where Cancelled__c = false and Brokerage_Type__c != 'Cancellation Brokerage'];
        
        system.debug('bookList::'+bookList);
        system.debug('size of bookList::'+bookList.size());
        
        if(!bookList.isEmpty()){
            system.debug('Inside if of bookList');
            for(Booking__c bk : bookList){
                system.debug('Inside for loop of bookList');
                if(bk.Brokerage_Scheme__c != null){
                    bk.Brokerage_Cancelled__c = true;
                    bookList2.add(bk);
                    system.debug('oppId1::'+oppId1);
                    brokerSummary1 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Channel_Partner__c,
                                      Brokerage_Scheme__c,Booking__r.Custom_Base_Brokerage__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Booking__c,Booking__r.Type_of_Client__c,
                                      Booking__r.Brokerage__c,Booking__r.Base_Brokerage__c,Invoice_Submitted_by_CP__c,Booking__r.Type_Of_Client_Formula__c from Brokerage_Summary__c where Booking__c =: bk.Id 
                                      and Brokerage_Scheme__c =: bk.Brokerage_Scheme__c and Channel_Partner__c =: bk.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                    system.debug('brokerSummary1::'+brokerSummary1);
                    
                    scheme = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,
                              Start_Date__c from Brokerage_Scheme__c where Id =: bk.Brokerage_Scheme__c];
                    
                }
            }
            if(!bookList2.isEmpty()){
                update bookList2;
                system.debug('updated bookList2::'+bookList2);
            }
            if(!brokerSummary1.isEmpty()){
                for(Brokerage_Summary__c bs : brokerSummary1){
                    if(bs.Invoice_Submitted_by_CP__c == false){
                        if(bs.Booking__r.Custom_Base_Brokerage__c != null){
                            if(bs.Booking__r.Type_Of_Client_Formula__c == 'Local' || bs.Booking__r.Type_Of_Client_Formula__c == 'Corporate'){
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_Local_Bookings__c,
                                         Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    for(Brokerage__c cb :cancelledbrokerage){
                                        if(cb.Brokerage_Summary__c == bs.Id){
                                            cb.Cancelled__c = true;
                                            Updatecancelledbrokerage.add(cb);
                                        }
                                    }
                                    system.debug('br::'+br);
                                }
                            }
                            else{
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c,
                                         Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_Local_Bookings__c
                                         from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    system.debug('bs.Booking__r.Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                    system.debug('slab1[0].Additional_Brokerage_for_OS_NRI__c::'+slab1[0].Additional_Brokerage_for_OS_NRI__c);
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                    for(Brokerage__c cb :cancelledbrokerage){
                                        if(cb.Brokerage_Summary__c == bs.Id){
                                            cb.Cancelled__c = true;
                                            Updatecancelledbrokerage.add(cb);
                                        }
                                    }
                                }
                            }
                        }
                        
                        else{
                            if(bs.Booking__r.Type_Of_Client_Formula__c == 'Local' || bs.Booking__r.Type_Of_Client_Formula__c == 'Corporate'){
                                system.debug('Inside for loop of Local brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_OS_NRI__c,
                                         Additional_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                    for(Brokerage__c cb :cancelledbrokerage){
                                        system.debug('cb.Brokerage_Summary__c::'+cb.Brokerage_Summary__c);
                                        system.debug('bs.Id::'+bs.Id);
                                        if(cb.Brokerage_Summary__c == bs.Id){
                                            cb.Cancelled__c = true;
                                            Updatecancelledbrokerage.add(cb);
                                        }
                                    }
                                }
                            }else{
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_Local_Bookings__c,
                                         Additional_Brokerage_for_OS_NRI__c,Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                    for(Brokerage__c cb :cancelledbrokerage){
                                        if(cb.Brokerage_Summary__c == bs.Id){
                                            cb.Cancelled__c = true;
                                            Updatecancelledbrokerage.add(cb);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
            } 
            if(!brokerage4.isEmpty() && brokerage4 != null){
                insert brokerage4;
                system.debug('brokerage4::'+brokerage4);
            }
            if(!Updatecancelledbrokerage.isEmpty()){
                update Updatecancelledbrokerage;
            }
            bookList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Opportunity__c,Type_of_Client__c,
                         RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Brokerage__c,Base_Brokerage__c,Custom_Base_Brokerage__c,Type_Of_Client_Formula__c
                         from Booking__c where Id Not IN:bId and Brokerage_Scheme__c =: bookList[0].Brokerage_Scheme__c and Brokerage_Summary__c != null
                         and BrokerIId__c =: bookList[0].BrokerIId__c and Brokerage_Cancelled__c = false];         
            system.debug('bookList3::'+bookList3);
            system.debug('size of bookList3::'+bookList3.size());
            
            if(!bookList3.isEmpty() && !scheme.isEmpty() && scheme[0].Slab_TYpe__c != null){
                if(scheme[0].Slab_TYpe__c == 'Value'){
                    for(Booking__c bk : bookList3){
                        totalAV = totalAV + bk.Agreement_Value_for_brokers__c;
                        system.debug('totalAV::'+totalAV);
                    }
                }
                if(scheme[0].Slab_TYpe__c == 'Count'){
                    count = bookList3.size();
                    system.debug('count::'+count);
                }
            }
            
        }
        
        slab2 = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Additional_Brokerage_for_OS_NRI__c,
                 Additional_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_Local_Bookings__c,
                 Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Brokerage_Scheme__c =: bookList[0].Brokerage_Scheme__c];
        system.debug('slab2::'+slab2);
        if(!bookList3.isEmpty() && !slab1.isEmpty()){
            system.debug('Inside if of bookList3 & slab1 lists');
            system.debug('size of bookList3::'+bookList3.size());
            
            if(count != 0){ 
                if((slab1[0].From__c <= count && (slab1[0].To__c >= count || slab1[0].To__c == null))){
                    
                    system.debug('(slab1[0].From__c <= count && slab1[0].To__c >= count)::'+(slab1[0].From__c <= count && slab1[0].To__c >= count));
                } else {
                    system.debug('Inside else');
                    if(!slab2.isEmpty()){
                        for(Brokerage_Slab__c bs : slab2){
                            system.debug('bs.From__c <= count && bs.To__c >= count::::'+ (bs.From__c <= count && bs.To__c >= count));
                            if(bs.From__c != null && (bs.From__c <= count && (bs.To__c >= count || bs.To__c == null))){
                                slabId1.add(bs.Id);
                                system.debug('slabId1::'+slabId1);
                            }
                        }
                        if(slabId1 != null){
                            slab3 = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Total_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,
                                     Additional_Brokerage_for_Local_Bookings__c,
                                     Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Id IN : slabId1];
                            system.debug('slab3::'+slab3);
                        }
                        
                        for(Booking__c bk1 : bookList3){
                            if(bk1.Custom_Base_Brokerage__c != null){
                                if(bk1.Type_Of_Client_Formula__c == 'Local' || bk1.Type_Of_Client_Formula__c == 'Corporate'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c
                                                          where Booking__c =: bk1.Id and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            system.debug('bk1.Custom_Base_Brokerage__c'+bk1.Custom_Base_Brokerage__c);
                                            system.debug('slab3[0].Additional_Brokerage_for_Local_Bookings__c'+slab3[0].Additional_Brokerage_for_Local_Bookings__c);
                                            system.debug('slab1[0].Additional_Brokerage_for_Local_Bookings__c'+slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            system.debug('br1.Brokerage__c'+br1.Brokerage__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                                else if(bk1.Type_Of_Client_Formula__c == 'NRI'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            system.debug('(bk1.Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c));
                                            system.debug('(bk1.Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            br1.Brokerage__c = ((bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                                else if(bk1.Type_Of_Client_Formula__c == 'Outstation'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            system.debug('(bk1.Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c));
                                            system.debug('(bk1.Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            br1.Brokerage__c = ((bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                            }else{
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
	                              else if(bk1.Type_of_Client__c == 'NRI'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        if(!brokerage5.isEmpty()){
                            insert brokerage5;
                            system.debug('inserted brokerage5::'+brokerage5);
                        }
                        if(!updateBrokerSummarySlab4.isEmpty()){
                            update updateBrokerSummarySlab4;
                            system.debug('updated updateBrokerSummarySlab4::'+updateBrokerSummarySlab4);
                        }
                    }
                }
            }
            if(totalAV != 0){
                if(slab1[0].From__c <= totalAV && (slab1[0].To__c >= totalAV || slab1[0].To__c == null)){
                    
                    system.debug('(slab1[0].From__c <= totalAV && slab1[0].To__c >= totalAV)::'+(slab1[0].From__c <= totalAV && slab1[0].To__c >= totalAV));
                } else {
                    system.debug('Inside else');
                    if(!slab2.isEmpty()){
                        for(Brokerage_Slab__c bs : slab2){
                            system.debug('bs.From__c <= totalAV && bs.To__c >= totalAV::::'+ (bs.From__c <= totalAV && bs.To__c >= totalAV));
                            if(bs.From__c != null && (bs.From__c <= totalAV && (bs.To__c >= totalAV || bs.To__c == null))){
                                slabId1.add(bs.Id);
                                system.debug('slabId1::'+slabId1);
                            }
                        }
                        if(slabId1 != null){
                            slab3 = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Total_Brokerage_for_Local_Bookings__c,
                                     Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c from Brokerage_Slab__c where Id IN : slabId1];
                            system.debug('slab3::'+slab3);
                        }
                        
                        for(Booking__c bk1 : bookList3){
                            if(bk1.Custom_Base_Brokerage__c != null){
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    } 
                                }
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c);
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                } 
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c);
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                            }else{
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    } 
                                }
                                else if(bk1.Type_of_Client__c == 'NRI'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * ( br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false && brokerSummary2[0].Applied_Slab_Name__c != 'Slab 1'){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * ( br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    if(cb.Cancelled_Brokerage_percentage__c == cb.Brokerage__c){
                                                        cb.Cancelled__c = true;
                                                    }
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update Updatecancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        if(!brokerage5.isEmpty()){
                            insert brokerage5;
                            system.debug('inserted brokerage5::'+brokerage5);
                        }
                        if(!updateBrokerSummarySlab4.isEmpty()){
                            update updateBrokerSummarySlab4;
                            system.debug('updated updateBrokerSummarySlab4::'+updateBrokerSummarySlab4);
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    public static void BookingSourceChange(set<Id> bId){
        system.debug('Inside BookingSourceChange method------');
        List<Booking__c> bookingList = new List<Booking__c>();
        List<Booking__c> bookList = new List<Booking__c>();
        List<Booking__c> bookList2 = new List<Booking__c>();
        List<Booking__c> bookList3 = new List<Booking__c>();
        List<Brokerage_Summary__c> brokerSummary1 = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> brokerSummary2 = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> updateBrokerSummarySlab4 = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerage4 = new List<Brokerage__c>();
        List<Brokerage__c> brokerage5 = new List<Brokerage__c>();
        List<Brokerage_Slab__c> slab1 = new List<Brokerage_Slab__c>();
        List<Brokerage_Slab__c> slab2 = new List<Brokerage_Slab__c>();
        List<Brokerage_Slab__c> slab3 = new List<Brokerage_Slab__c>();
        List<Brokerage_Scheme__c> scheme = new List<Brokerage_Scheme__c>();
        set<Id> oppId1 = new set<Id>();
        set<Id> slabId1 = new set<Id>();
        Decimal totalAV = 0.0;
        Integer count = 0;
        bookList = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,
                    RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c from Booking__c where
                    Id IN:bId and BrokerIId__c != null];
        
        
        system.debug('bookList::'+bookList);
        system.debug('size of bookList::'+bookList.size());
        
        if(!bookList.isEmpty()){
            system.debug('Inside if of bookList');
            for(Booking__c bk : bookList){
                system.debug('Inside for loop of bookList');
                if(bk.Brokerage_Scheme__c != null){
                    bk.Brokerage_Cancelled__c = true;
                    bookList2.add(bk);
                    system.debug('oppId1::'+oppId1);
                    system.debug('bk id - '+ bk.Id );
                    list<Brokerage_Summary__c> brokerSummary12 = [Select Id,Channel_Partner__c,Brokerage_Scheme__c,Booking__c from Brokerage_Summary__c];
                    system.debug(' brokerSummary12 = > '+brokerSummary12);
                    system.debug('bk Brokerage_Scheme__c - '+ bk.Brokerage_Scheme__c );
                    system.debug('bk BrokerIId__c - '+ bk.BrokerIId__c );
                    
                    brokerSummary1 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Channel_Partner__c,
                                      Brokerage_Scheme__c,Booking__r.Custom_Base_Brokerage__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Booking__c,Booking__r.Type_of_Client__c,
                                      Booking__r.Brokerage__c,Booking__r.Base_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk.Id 
                                      and Brokerage_Scheme__c =: bk.Brokerage_Scheme__c and Channel_Partner__c =: bk.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                    system.debug('brokerSummary1::'+brokerSummary1);
                    
                    scheme = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,
                              Start_Date__c from Brokerage_Scheme__c where Id =: bk.Brokerage_Scheme__c];
                    
                }
            }
            if(!bookList2.isEmpty()){
                update bookList2;
                system.debug('updated bookList2::'+bookList2);
            }
            if(!brokerSummary1.isEmpty()){
                for(Brokerage_Summary__c bs : brokerSummary1){
                    if(bs.Invoice_Submitted_by_CP__c == false){
                        if(bs.Booking__r.Custom_Base_Brokerage__c != null){
                            if(bs.Booking__r.Type_of_Client__c == 'Local' || bs.Booking__r.Type_of_Client__c == 'Corporate'){
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_Local_Bookings__c,
                                         Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                }
                            }
                            
                             else if(bs.Booking__r.Type_of_Client__c == 'NRI'){
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_NRI__c,
                                         Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_Local_Bookings__c
                                         from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    system.debug('bs.Booking__r.Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                    system.debug('slab1[0].Additional_Brokerage_for_NRI__c::'+slab1[0].Additional_Brokerage_for_NRI__c);
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                }
                            }  
                            
                            else if(bs.Booking__r.Type_of_Client__c == 'Outstation'){
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_OS_NRI__c,
                                         Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_Local_Bookings__c
                                         from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    system.debug('bs.Booking__r.Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                    system.debug('slab1[0].Additional_Brokerage_for_OS_NRI__c::'+slab1[0].Additional_Brokerage_for_OS_NRI__c);
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                }
                            }  
                        }
                        
                        else{
                            if(bs.Booking__r.Type_of_Client__c == 'Local' || bs.Booking__r.Type_of_Client__c == 'Corporate'){
                                system.debug('Inside for loop of Local brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_OS_NRI__c,
                                         Additional_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                }
                            }
                            else if(bs.Booking__r.Type_of_Client__c == 'NRI'){
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_Local_Bookings__c,
                                         Additional_Brokerage_for_NRI__c,Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                }
                            }
                            else if(bs.Booking__r.Type_of_Client__c == 'Outstation'){
                                system.debug('Inside for loop of brokerSummary1 list');
                                slab1 = [select id,Name,From__c,To__c,Brokerage_Scheme__c,Total_Brokerage__c,Additional_Brokerage__c,Base_Brokerage__c,Additional_Brokerage_for_Local_Bookings__c,
                                         Additional_Brokerage_for_OS_NRI__c,Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c
                                         where Brokerage_Scheme__c =: bs.Brokerage_Scheme__c and Name =: bs.Applied_Slab_Name__c ];
                                system.debug('slab1::'+slab1);
                                system.debug('size of slab1::'+slab1.size());
                                if(!slab1.isEmpty()){
                                    Brokerage__c br = new Brokerage__c();
                                    br.Brokerage_Summary__c = bs.Id;
                                    br.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                    br.Opportunity__c = bs.Opportunity__c;
                                    br.Booking__c = bs.Booking__c;
                                    br.Channel_Partner__c = bs.Channel_Partner__c;
                                    br.Brokerage_Type__c = 'Cancellation Brokerage';
                                    br.Name = 'Cancellation Brokerage';
                                    br.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                    br.Brokerage__c = -bs.Brokerage__c;
                                    br.Brokerage_Amount__c = -bs.Total_Brokerage__c;
                                    brokerage4.add(br);
                                    system.debug('br::'+br);
                                }
                            }
                        }
                    }
                    
                }
                
            } 
            if(!brokerage4.isEmpty() && brokerage4 != null){
                insert brokerage4;
                system.debug('brokerage4::'+brokerage4);
            }
            bookList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Opportunity__c,Type_of_Client__c,
                         RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Brokerage__c,Base_Brokerage__c,Custom_Base_Brokerage__c,Type_Of_Client_Formula__c
                         from Booking__c where Id Not IN:bId and Project__c =: bookList[0].Project__c and Brokerage_Scheme__c =: bookList[0].Brokerage_Scheme__c 
                         and BrokerIId__c =: bookList[0].BrokerIId__c and Brokerage_Cancelled__c = false];
            
            
            system.debug('bookList3::'+bookList3);
            system.debug('size of bookList3::'+bookList3.size());
            
            if(!bookList3.isEmpty() && !scheme.isEmpty() && scheme[0].Slab_TYpe__c != null){
                if(scheme[0].Slab_TYpe__c == 'Value'){
                    for(Booking__c bk : bookList3){
                        totalAV = totalAV + bk.Agreement_Value_for_brokers__c;
                        system.debug('totalAV::'+totalAV);
                    }
                }
                if(scheme[0].Slab_TYpe__c == 'Count'){
                    count = bookList3.size();
                    system.debug('count::'+count);
                }
            }
            
        }
        
        slab2 = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Additional_Brokerage_for_OS_NRI__c,
                 Additional_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_Local_Bookings__c,
                 Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Brokerage_Scheme__c =: bookList[0].Brokerage_Scheme__c];
        system.debug('slab2::'+slab2);
        if(!bookList3.isEmpty() && !slab1.isEmpty()){
            system.debug('Inside if of bookList3 & slab1 lists');
            system.debug('size of bookList3::'+bookList3.size());
            
            if(count != 0){ 
                if((slab1[0].From__c <= count && (slab1[0].To__c >= count || slab1[0].To__c == null))){
                    
                    system.debug('(slab1[0].From__c <= count && slab1[0].To__c >= count)::'+(slab1[0].From__c <= count && slab1[0].To__c >= count));
                } else {
                    system.debug('Inside else');
                    if(!slab2.isEmpty()){
                        for(Brokerage_Slab__c bs : slab2){
                            system.debug('bs.From__c <= count && bs.To__c >= count::::'+ (bs.From__c <= count && bs.To__c >= count));
                            if(bs.From__c != null && (bs.From__c <= count && (bs.To__c >= count || bs.To__c == null))){
                                slabId1.add(bs.Id);
                                system.debug('slabId1::'+slabId1);
                            }
                        }
                        if(slabId1 != null){
                            slab3 = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Total_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,
                                     Additional_Brokerage_for_Local_Bookings__c,
                                     Total_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Id IN : slabId1];
                            system.debug('slab3::'+slab3);
                        }
                        
                        for(Booking__c bk1 : bookList3){
                            if(bk1.Custom_Base_Brokerage__c != null){
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c
                                                          where Booking__c =: bk1.Id and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_Local_Bookings__c - slab1[0].Total_Brokerage_for_Local_Bookings__c );
                                            //br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * ((bk1.Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c - bk1.Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c ) / 100));
                                            system.debug('bk1.Custom_Base_Brokerage__c'+bk1.Custom_Base_Brokerage__c);
                                            system.debug('slab3[0].Additional_Brokerage_for_Local_Bookings__c'+slab3[0].Additional_Brokerage_for_Local_Bookings__c);
                                            system.debug('slab1[0].Additional_Brokerage_for_Local_Bookings__c'+slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            system.debug('br1.Brokerage__c'+br1.Brokerage__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                
                                }
                                else if(bk1.Type_of_Client__c == 'NRI'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            system.debug('(bk1.Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c));
                                            system.debug('(bk1.Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            br1.Brokerage__c = ((bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            system.debug('(bk1.Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c));
                                            system.debug('(bk1.Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c)::'+(bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            br1.Brokerage__c = ((bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                            }else{
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                                else if(bk1.Type_of_Client__c == 'NRI'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                                else if(bk1.Type_of_Client__c == 'Outstaion'){
                                    system.debug('Inside for loop of bookList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        if(!brokerage5.isEmpty()){
                            insert brokerage5;
                            system.debug('inserted brokerage5::'+brokerage5);
                        }
                        if(!updateBrokerSummarySlab4.isEmpty()){
                            update updateBrokerSummarySlab4;
                            system.debug('updated updateBrokerSummarySlab4::'+updateBrokerSummarySlab4);
                        }
                    }
                }
            }
            if(totalAV != 0){
                if(slab1[0].From__c <= totalAV && (slab1[0].To__c >= totalAV || slab1[0].To__c == null)){
                    
                    system.debug('(slab1[0].From__c <= totalAV && slab1[0].To__c >= totalAV)::'+(slab1[0].From__c <= totalAV && slab1[0].To__c >= totalAV));
                } else {
                    system.debug('Inside else');
                    if(!slab2.isEmpty()){
                        for(Brokerage_Slab__c bs : slab2){
                            system.debug('bs.From__c <= totalAV && bs.To__c >= totalAV::::'+ (bs.From__c <= totalAV && bs.To__c >= totalAV));
                            if(bs.From__c != null && (bs.From__c <= totalAV && (bs.To__c >= totalAV || bs.To__c == null))){
                                slabId1.add(bs.Id);
                                system.debug('slabId1::'+slabId1);
                            }
                        }
                        if(slabId1 != null){
                            slab3 = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Total_Brokerage_for_Local_Bookings__c,
                                     Total_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Id IN : slabId1];
                            system.debug('slab3::'+slab3);
                        }
                        
                        for(Booking__c bk1 : bookList3){
                            if(bk1.Custom_Base_Brokerage__c != null){
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_Local_Bookings__c - slab1[0].Total_Brokerage_for_Local_Bookings__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    } 
                                }
                                else if(bk1.Type_of_Client__c == 'NRI'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c);
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Custom_Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Custom_Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c);
                                            //br1.Brokerage__c = (slab3[0].Total_Brokerage_for_OS_NRI__c - slab1[0].Total_Brokerage_for_OS_NRI__c );
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }  
                            }else{
                                if(bk1.Type_of_Client__c == 'Local' || bk1.Type_of_Client__c == 'Corporate'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = (bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_Local_Bookings__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_Local_Bookings__c);
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * (br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    } 
                                }
                                else if(bk1.Type_of_Client__c == 'NRI'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * ( br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                                else if(bk1.Type_of_Client__c == 'Outstation'){
                                    system.debug('Inside for loop of optyList3');
                                    if(bk1.Brokerage_Scheme__c != null){
                                        brokerSummary2 = [select Id, Brokerage__c,Additional_Brokerage__c,Applied_Slab_Name__c,Base_Brokerage__c,Broker__c,Status__c,
                                                          Brokerage_Scheme__c,Total_Agreement_Value__c,Opportunity__c,Total_Brokerage__c,Invoice_Submitted_by_CP__c from Brokerage_Summary__c where Booking__c =: bk1.Id 
                                                          and Brokerage_Scheme__c =: bk1.Brokerage_Scheme__c and Channel_Partner__c =: bk1.BrokerIId__c and Is_Kicker_Incentive_Summary__c = false];
                                        system.debug('brokerSummary2::'+brokerSummary2);
                                        if(!brokerSummary2.isEmpty() && !slab3.isEmpty() && brokerSummary2[0].Invoice_Submitted_by_CP__c == false){
                                            system.debug('Inside if to insert cancelled Brokerage Recprd');
                                            List<Brokerage__c> cancelledbrokerage = new List<Brokerage__c>();
                                            List<Brokerage__c> Updatecancelledbrokerage = new List<Brokerage__c>();
                                            Brokerage__c br1 = new Brokerage__c();
                                            br1.Brokerage_Summary__c = brokerSummary2[0].Id;
                                            br1.Brokerage_Scheme__c = bk1.Brokerage_Scheme__c;
                                            br1.Opportunity__c = bk1.Opportunity__c;
                                            br1.Booking__c = bk1.Id;
                                            br1.Channel_Partner__c = bk1.BrokerIId__c;
                                            br1.Brokerage_Type__c = 'Cancellation Brokerage';
                                            br1.Name = 'Cancellation Brokerage';
                                            br1.Opportunity_AV__c = bk1.Agreement_Value_for_brokers__c;
                                            br1.Brokerage__c = ((bk1.Base_Brokerage__c + slab3[0].Additional_Brokerage_for_OS_NRI__c) - (bk1.Base_Brokerage__c + slab1[0].Additional_Brokerage_for_OS_NRI__c));
                                            br1.Brokerage_Amount__c = ((bk1.Agreement_Value_for_brokers__c) * ( br1.Brokerage__c / 100));
                                            cancelledbrokerage = [Select id,name,Cancelled__c,Cancelled_Brokerage_percentage__c,Cancelled_Brokerage_Amount__c,Brokerage__c
                                                                  from Brokerage__c where Brokerage_Summary__c =: brokerSummary2[0].Id 
                                                                  and (Brokerage_Type__c = 'Retrofit Brokerage' OR Brokerage_Type__c = 'Additional Brokerage') and Cancelled__c = false];
                                            system.debug('cancelledbrokerage::'+cancelledbrokerage);
                                            for(Brokerage__c cb :cancelledbrokerage){
                                                if(cb.Brokerage__c == (-br1.Brokerage__c)){
                                                    br1.Cancelled_Brokerage__c = cb.id;
                                                    cb.Cancelled__c = true;
                                                    Updatecancelledbrokerage.add(cb);
                                                    break;
                                                }else if(cb.Brokerage__c > (-br1.Brokerage__c)){
                                                    cb.Cancelled_Brokerage_percentage__c = cb.Cancelled_Brokerage_percentage__c + (-br1.Brokerage__c);
                                                    cb.Cancelled_Brokerage_Amount__c = cb.Cancelled_Brokerage_Amount__c + br1.Brokerage_Amount__c;
                                                    Updatecancelledbrokerage.add(cb);
                                                }
                                            }
                                            if(!Updatecancelledbrokerage.isEmpty()){
                                                update cancelledbrokerage;
                                            }
                                            brokerage5.add(br1);
                                            system.debug('br1::'+br1);
                                            
                                            Brokerage_Summary__c bs5 = new Brokerage_Summary__c();
                                            bs5.Id = brokerSummary2[0].Id;
                                            bs5.Applied_Slab_Name__c = slab3[0].Name;
                                            system.debug('slab3.Name::'+slab3[0].Name);
                                            updateBrokerSummarySlab4.add(bs5);
                                            system.debug('bs5::'+bs5);
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        if(!brokerage5.isEmpty()){
                            insert brokerage5;
                            system.debug('inserted brokerage5::'+brokerage5);
                        }
                        if(!updateBrokerSummarySlab4.isEmpty()){
                            update updateBrokerSummarySlab4;
                            system.debug('updated updateBrokerSummarySlab4::'+updateBrokerSummarySlab4);
                        }
                    }
                }
            }
        }
        
    }
    
    
    public static String GetKickerIncentives(Id UId,Date activedate,Id PId, Id TId,String Toc){
        String kickerId = null;
        String kickertypoId = null;
        Boolean Cumlative = false;
        Boolean projectandtower = false;
        Boolean NRIClient = false;
        Boolean LocalClient = false;
        Boolean BothClient = false;
        List<Project_Unit__c> UnitList = new List<Project_Unit__c>();
        List<Kicker_Incentive__c> KickerList = new List<Kicker_Incentive__c>();
        List<Kicker_Typology__c> KickertypologyList = new List<Kicker_Typology__c>();
        List<Kicker_Incentive_Configuration__c> KickerconfigList = new List<Kicker_Incentive_Configuration__c>();
        UnitList = [Select id,name,New_Type__c from Project_Unit__c where Id=:UId];
        KickerconfigList = [Select Id,Name,Kicker_Incentive__c from Kicker_Incentive_Configuration__c where ((Project__c =:PId and Tower__c =:TId) OR (Project__c =:PId and Tower__c =:null)) ];
        system.debug('KickerconfigList :'+KickerconfigList);
        if(!KickerconfigList.isEmpty()){
            KickerList = [Select id,name,Unit_Type__c,Amount__c,Project__c,Tower__c,Start_Date__c,End_Date__c,Type__c,Type_Of_Client__c from Kicker_Incentive__c where id=:KickerconfigList[0].Kicker_Incentive__c 
                          and Start_Date__c <=: activedate and (End_Date__c = null or End_Date__c >=: activedate) and (Type_Of_Client__c =: Toc  or Type_Of_Client__c = '') ];
            system.debug('Id ::'+KickerconfigList[0].Kicker_Incentive__c );
            system.debug('activedate ::'+activedate);
            system.debug('Kicker Incentive tower::'+KickerList);
            if(!KickerList.isEmpty()){
                if(KickerList[0].Type__c == 'Unit Typology' && !UnitList.isEmpty()){
                    KickertypologyList = [Select Id,name,Amount__c,Kicker_Incentive__c,Unit_Type__c from Kicker_Typology__c where Kicker_Incentive__c =:KickerList[0].Id 
                                          And Unit_Type__c =:UnitList[0].New_Type__c];
                    system.debug('KickertypologyList::'+KickertypologyList);
                }else if(KickerList[0].Type__c == 'Cumulative'){
                    Cumlative = true;
                }else if(KickerList[0].Type__c == 'Per Deal'){
                    projectandtower = true;
                }
                else if(KickerList[0].Type_Of_Client__c == 'NRI'){
                    system.debug('nri kicker');
                    NRIClient = true;
                }  
                else if(KickerList[0].Type_Of_Client__c == 'Local'){
                    system.debug('Local kicker');
                    LocalClient = true;
                }
                else if(KickerList[0].Type_Of_Client__c == ' '|| KickerList[0].Type_Of_Client__c == Null){
                    system.debug('Both kicker');
                    BothClient = true;
                }
            }
        }
        
        if(!KickertypologyList.isEmpty() && !KickerList.isEmpty()){
            if(KickerList.size() == 1){
                kickerId = KickerList[0].Id;
            }
        }else if(Cumlative && !KickerList.isEmpty()){
            if(KickerList.size() == 1){
                kickerId = KickerList[0].Id;
            }
        }else if(projectandtower && !KickerList.isEmpty()){
            if(KickerList.size() == 1){
                kickerId = KickerList[0].Id;
            }
        }
        else if(NRIClient && !KickerList.isEmpty()){
            if(KickerList.size() == 1){
                system.debug('nri k');
                kickerId = KickerList[0].Id;
            }
        }
          else if(LocalClient && !KickerList.isEmpty()){
            if(KickerList.size() == 1){
                system.debug('Local k');
                kickerId = KickerList[0].Id;
            }
        }
        else if(BothClient && !KickerList.isEmpty()){
            if(KickerList.size() == 1){
                system.debug('Both k');
                kickerId = KickerList[0].Id;
            }
        }      
        else{
            kickerId = null;
        }
        system.debug('kickerId Incentive::'+kickerId);
        return kickerId;
    }    
    public static void KickerCalulation(String KId){
        Decimal Count = 0;
        Decimal Value = 0;
        Decimal projectlistsize = 0;
        Set<Id> BIds = new Set<Id>();
        List<Id> KickerSlabIds = new List<Id>();
        Set<Id> CPIds = new Set<Id>();
        Set<Id> PIds = new Set<Id>();
        Id KickerSlabId;
        List<Booking__c> bklist = new List<Booking__c>();
        List<Booking__c> bklist2 = new List<Booking__c>();
        List<Booking__c> CPbklist2 = new List<Booking__c>();
        List<Kicker_Incentive__c> KickerIncentivelist = new List<Kicker_Incentive__c>();
        List<Kicker_Typology__c> KickerIncentivetypolist = new List<Kicker_Typology__c>();
        List<Kicker_Incentive_Slab__c> KickerIncentiveSlablist = new List<Kicker_Incentive_Slab__c>();
        List<Brokerage_Summary__c> BsList = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> BsListExisting = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> BsListInsert = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> BsListInsertperdeal = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> BsListInserttypo = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerage = new List<Brokerage__c>();
        Map<Id,Kicker_Incentive_Slab__c> KIslabmap = new Map<Id,Kicker_Incentive_Slab__c>();
        Map<Id,Kicker_Typology__c> KItypomap = new Map<Id,Kicker_Typology__c>();
        List<String> typologyList = new List<String>();
        Id KickerRecordTypeId = Schema.SObjectType.Brokerage_Summary__c.getRecordTypeInfosByName().get('Kicker Summary').getRecordTypeId();
        KickerIncentivelist = [Select Id,Name,Per_Deal_Amount__c,Brokerage_Scheme__c,Type__c from Kicker_Incentive__c where Id =: KId];
        bklist = [Select Id,Name,Agreement_Value_for_brokers__c,BrokerIId__c,Unit_No__r.New_Type__c,Account__c from Booking__c where Kicker_Incentive_lookup__c =: KId];
        for(Booking__c bk :bklist){
            BIds.add(bk.Id);
        }
        for(Kicker_Incentive_Slab__c kis : [Select Id,Value__c,No_of_Bookings__c,Logical_Operator__c,Amount__c,To__c,From__c,To_Value__c,From_Value__c,Kicker_Incentive__c from Kicker_Incentive_Slab__c where Kicker_Incentive__c =:KId ]){
            KIslabmap.put(kis.id,kis);
        }
        if(!KickerIncentivelist.isEmpty() && KickerIncentivelist[0].Type__c == 'Unit Typology'){
            BsList = [Select Id,Name,Booking__c,Opportunity__c,Channel_Partner__c,Total_Agreement_Value__c,Is_Kicker_Incentive_Summary__c,
                      Booking__r.Unit_No__r.New_Type__c,Brokerage_Scheme__c from Brokerage_Summary__c where Booking__c IN: BIds];
            For(Brokerage_Summary__c bs :BsList){
                typologyList.add(bs.Booking__r.Unit_No__r.New_Type__c);
            }
            KickerIncentivetypolist = [Select id,Amount__c from Kicker_Typology__c where Unit_Type__c IN:typologyList And
                                       Kicker_Incentive__c =:KId];
            For(Brokerage_Summary__c bs :BsList){
                For(Kicker_Typology__c ty :KickerIncentivetypolist){
                    if(bs.Booking__r.Unit_No__r.New_Type__c == ty.Unit_Type__c){
                        KItypomap.put(bs.id,ty);
                    }
                }
            }
            For(Brokerage_Summary__c bs :BsList){
                /*KickerIncentivetypolist = [Select id,Amount__c from Kicker_Typology__c where Unit_Type__c =:bs.Booking__r.Unit_No__r.New_Type__c And
Kicker_Incentive__c =:KId];*/
                if(bs.Booking__r.Unit_No__r.New_Type__c == KItypomap.get(bs.Id).Unit_Type__c){
                    Brokerage__c b = new Brokerage__c();
                    b.Brokerage_Summary__c = bs.Id;
                    b.Brokerage_Scheme__c =  bs.Brokerage_Scheme__c;
                    b.Booking__c = bs.Booking__c;
                    b.Channel_Partner__c = bs.Channel_Partner__c;
                    b.Brokerage_Type__c = 'Kicker Incentive';
                    b.Name = 'Kicker Incentive';
                    b.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                    b.Brokerage_Amount__c = KItypomap.get(bs.Id).Amount__c ;
                    b.Status__c = 'Due'; 
                    bs.Kicker_Incentive__c = KId;
                    brokerage.add(b);
                    BsListInsertperdeal.add(bs);
                }
            }
            if(!brokerage.isEmpty()){
                insert brokerage;
            }
            if(!BsListInsertperdeal.isEmpty()){
                update BsListInsertperdeal;
            }
        }else if(!KickerIncentivelist.isEmpty() && KickerIncentivelist[0].Type__c == 'Per Deal'){
            BsList = [Select Id,Name,Booking__c,Opportunity__c,Channel_Partner__c,Total_Agreement_Value__c,Is_Kicker_Incentive_Summary__c,
                      Booking__r.Unit_No__r.New_Type__c,Brokerage_Scheme__c from Brokerage_Summary__c where Booking__c IN: BIds];
            For(Brokerage_Summary__c bs :BsList){
                Brokerage__c b = new Brokerage__c();
                b.Brokerage_Summary__c = bs.Id;
                b.Brokerage_Scheme__c =  bs.Brokerage_Scheme__c;
                b.Booking__c = bs.Booking__c;
                b.Channel_Partner__c = bs.Channel_Partner__c;
                b.Brokerage_Type__c = 'Kicker Incentive';
                b.Name = 'Kicker Incentive';
                b.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                b.Brokerage_Amount__c = KickerIncentivelist[0].Per_Deal_Amount__c ;
                b.Status__c = 'Due';
                bs.Kicker_Incentive__c = KId;
                brokerage.add(b);
                BsListInserttypo.add(bs);
            }
            system.debug('brokerage::'+brokerage);
            if(!brokerage.isEmpty()){
                insert brokerage;
            }
            if(!BsListInserttypo.isEmpty()){
                update BsListInserttypo;
            }
        }else if(!KickerIncentivelist.isEmpty() && KickerIncentivelist[0].Type__c == 'Cumulative'){
            
            for(Booking__c b :bklist){
                system.debug('bklist Size::'+bklist.size()+'::List::'+bklist);
                CPIds.add(b.BrokerIId__c);
            }
            system.debug('CPIds::'+CPIds);
         
            for(Id Idcp :CPIds){
                BsListInsert = new List<Brokerage_Summary__c>();
                brokerage = new List<Brokerage__c>();
                count = 0;
                Value = 0;
                PIds = new Set<Id>();
                KickerSlabIds = new List<Id>();
                CPbklist2 = [Select Id,Name,Agreement_Value_for_brokers__c,Status__c,Account__c,Project__c,BrokerIId__c from Booking__c where Kicker_Incentive_lookup__c =: KId and BrokerIId__c =: Idcp ORDER BY Booking_Date__c desc];
                for(Booking__c b :CPbklist2){
                    for(Booking__c b2 :CPbklist2){
                        if(b2.Status__c != 'Cancelled'){
                            Count = Count + 1;
                            PIds.add(b2.Project__c);
                            system.debug('Count::'+count);
                        }
                        
                        if(b2.Status__c != 'Cancelled'){
                            Value = Value + b2.Agreement_Value_for_brokers__c;
                            PIds.add(b2.Project__c);
                            system.debug('Value::'+Value);
                        }
                    }
                    system.debug('END Specific CP::'+count);
                    system.debug('KIslabmap::'+KIslabmap);
                    system.debug('KickerSlabIds Before::'+KickerSlabIds);
                    system.debug('PIds Size::'+PIds.size()+'::List::'+PIds);
                    for(Id kis :KIslabmap.keySet()){
                        if(KIslabmap.get(kis).Logical_Operator__c == 'AND'){
                            if((KIslabmap.get(kis).From__c != null && (KIslabmap.get(kis).From__c <= count && (KIslabmap.get(kis).To__c >= count || KIslabmap.get(kis).To__c == null))) && 
                               (KIslabmap.get(kis).From_Value__c != null && (KIslabmap.get(kis).From_Value__c <= Value && (KIslabmap.get(kis).To_Value__c >= Value || KIslabmap.get(kis).To_Value__c == null)))){
                                   
                                   KickerSlabIds.add(kis);
                               }
                        }else{
                            if((KIslabmap.get(kis).From__c != null && (KIslabmap.get(kis).From__c <= count && (KIslabmap.get(kis).To__c >= count || KIslabmap.get(kis).To__c == null))) || 
                               (KIslabmap.get(kis).From_Value__c != null && (KIslabmap.get(kis).From_Value__c <= Value && (KIslabmap.get(kis).To_Value__c >= Value || KIslabmap.get(kis).To_Value__c == null)))){
                                   KickerSlabIds.add(kis);
                               }
                        }
                        
                    }
                    system.debug('KickerSlabIds After::'+KickerSlabIds);
                    projectlistsize = PIds.size();
                    if(!KickerSlabIds.isEmpty()){
                        KickerSlabId = KickerSlabIds[0];
                    }
                    if(KickerSlabId != null){  
                        for(Id projId : PIds){
                            Brokerage_Summary__c bs = new Brokerage_Summary__c();
                            bs.Channel_Partner__c = b.BrokerIId__c;
                            bs.Is_Kicker_Incentive_Summary__c = true;
                            bs.Status__c = 'Due';
                            bs.recordtypeId = KickerRecordTypeId;
                            bs.Count_of_Bookings__c = Count;
                            bs.Aggregate_Agreement_Value__c = value;
                            bs.CP_Account__c = b.Account__c;
                            bs.Project_Lookup__c = projId;
                            bs.Kicker_Incentive_Slab__c = KickerSlabId;
                            bs.Kicker_Incentive__c = KIslabmap.get(KickerSlabId).Kicker_Incentive__c;
                            BsListInsert.add(bs) ;
                            if(!BsListInsert.isEmpty()){
                                system.debug('BsListInsert inserted::'+BsListInsert);
                                insert BsListInsert;
                                system.debug('BsListInsert inserted::'+BsListInsert);
                            }
                            
                            Brokerage__c bro = new Brokerage__c();
                            if(!BsListInsert.isEmpty()){
                                bro.Brokerage_Summary__c = BsListInsert[0].Id;
                            }
                            bro.Channel_Partner__c = b.BrokerIId__c;
                            bro.Brokerage_Type__c = 'Kicker Incentive';
                            bro.Name = 'Kicker Incentive';
                            if(projectlistsize > 0){
                                bro.Brokerage_Amount__c = KIslabmap.get(KickerSlabId).Amount__c/projectlistsize;
                            }
                            bro.Status__c = 'Due';
                            brokerage.add(bro);
                            insert brokerage;
                        }
                        
                        
                    }
                    system.debug('END First Loop::');
                    break;
                }
            }
        }
        
    }
     public static void BrokerageCalculationForInactiveScheme(Id bookingId,Id BrokerageSchemeId){
        system.debug('Inside brokerageCalculation method');
        List<Opportunity> optyList = new List<Opportunity>();
        List<Opportunity> optyList1 = new List<Opportunity>();
        List<Booking__c> bkList1 = new List<Booking__c>();
        List<Booking__c> bkList2 = new List<Booking__c>();
        List<Booking__c> bkList3 = new List<Booking__c>();
        List<Booking__c> bkList4 = new List<Booking__c>();
        List<Booking__c> bkList5 = new List<Booking__c>();
        List<Booking__c> updatebkList = new List<Booking__c>();
        List<Brokerage_Scheme__c> brokerageScheme = new List<Brokerage_Scheme__c>();
        List<Brokerage_Scheme__c> brokerageScheme1 = new List<Brokerage_Scheme__c>();
        List<Brokerage__c> brokerage = new List<Brokerage__c>();
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        List<Brokerage_Slab__c> brokerageSlab = new List<Brokerage_Slab__c>();
        List<Scheme_Configuration__c> sc = new List<Scheme_Configuration__c>();
        List<Scheme_Configuration__c> scprojtower = new List<Scheme_Configuration__c>();
        set<ID> scprj = new set<ID>();
        set<ID> sctower = new set<ID>();
        set<ID> cpID = new set<ID>();
        set<ID> bcpID = new set<ID>();
        set<ID> bId = new set<ID>();
        set<ID> bookId = new set<ID>();
        List<Project__c> proj1 = new List<Project__c>();
        List<Tower__c> t1 = new List<Tower__c>();
        Integer count = 0;
        Date bookingDate1;
        Date startDate;
        Date endDate;
        Decimal totalAV = 0.0;
        String KickerIncentiveId;
        Decimal KickerPercentage;
        bkList1 = [select Id,Name,Opportunity__c,Base_Brokerage_2__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,Passback__c,Type_of_Client__c,Is_Special_Brokerage_Scheme__c ,Is_AOP_CP_Applicable__c,
                   RW_Total_Receipt_Amount_Received__c,RW_Registration_Done__c,RW_Registration_Status__c,Brokerage_Scheme__c,BrokerIId__c,RW_Registration_Date__c,Type_Of_Client_Formula__c from Booking__c 
                   where Id =: bookingId and Project__c != null and BrokerIId__c != null and Opportunity__c != null and Brokerage_Summary__c = null /*Added by Prashant to update the filter conditions to add the RERA & CC check as well. 16-9-25.*/ AND BrokerIId__r.Valid_RERA_certificate__c = true/* AND BrokerIId__r.Valid_competency_certificate__c = true //Commented by Prashant as discussed with team to discard use of CC. 12/12/25.*/ AND Checklist_Approved__c = true/*Added by Prashant to add checklist approved condition(billing checklist should be approved before summary creation )//17-11-2025...*/];
        system.debug('bkList1::'+bkList1);
        system.debug('bkList1 size::'+bkList1.size());
        
        if(!bkList1.isEmpty()){
            system.debug('Inside bkList1 if block---');
            for(Booking__c bk : bkList1){
                system.debug('Inside for loop 1');
                bookingDate1 = Date.ValueOf(bk.Booking_Date__c);
                //sc = [Select Id,Name,Brokerage_Scheme__c,Type__c,Tower__c,Project__c from Scheme_Configuration__c where Brokerage_Scheme__c =: BrokerageSchemeId];
                if(bk.BrokerIId__c != null && bk.Project__c != null ){
                    system.debug('Inside if of for loop 1');
                    
                    
                    brokerageScheme1 = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,Approval_Status__c,Type__c,
                                        Start_Date__c from Brokerage_Scheme__c where id =: BrokerageSchemeId and Approval_Status__c = 'Approved by Level 2'];
                    system.debug('brokerageScheme1::'+brokerageScheme1);
                    if(!brokerageScheme1.isEmpty()){
                        system.debug('Inside brokerageScheme1 if-- ');
                        bk.Brokerage_Scheme__c = brokerageScheme1[0].id;
                        bkList2.add(bk);
                        startDate = brokerageScheme1[0].Start_Date__c;
                        endDate = brokerageScheme1[0].End_Date__c;
                        system.debug('startDate::'+ startDate +' endDate::'+endDate);
                    }
                    if(!bkList2.isEmpty()){
                        update bkList2;
                        system.debug('updated bkList2::'+bkList2);
                    }
                    scprojtower = [Select id,Tower__c,Project__c from Scheme_Configuration__c where Brokerage_Scheme__c =: BrokerageSchemeId];
                    for(Scheme_Configuration__c scon :scprojtower){
                        if(scon.Project__c != null && scon.Tower__c != null){
                            scprj.add(scon.Project__c);
                            sctower.add(scon.Tower__c);
                        }else{
                            scprj.add(scon.Project__c);
                        }
                    }
                    
                    system.debug('sctower--'+sctower);
                    system.debug('scprj--'+scprj);
                    
                    if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && sctower.isEmpty()){
                        system.debug('Inside brokerageScheme1.isEmpty() && !scprj.isEmpty() && sctower.isEmpty() ::');
                        if(brokerageScheme1[0].Type__c == 'Local'&& (bk.RW_Registration_Date__c != Null || (bk.RW_Registration_Date__c ==null &&(bk.Is_Special_Brokerage_Scheme__c == true || bk.Is_AOP_CP_Applicable__c == true)))){
                            system.debug('Inside scheme type local::');
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_X9_99_Received__c = true or X5_Received__c = true ) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }else if(brokerageScheme1[0].Type__c == 'NRI'){
                            system.debug('Inside scheme type NRI::');
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_X9_99_Received__c = true or X5_Received__c = true ) and DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }
                        
                        else if(brokerageScheme1[0].Type__c == 'Both'){
                            system.debug('Inside scheme type both::');
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and (Type_of_Client__c =:'Local' OR Type_of_Client__c =:'NRI') and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_Registration_Date__c != null or(RW_Registration_Date__c = Null and  (Type_of_Client__c ='NRI' or  Type_of_Client__c ='Outstation' or Is_Special_Brokerage_Scheme__c = true or Is_AOP_CP_Applicable__c = true ))) and (RW_X9_99_Received__c = true or X5_Received__c = true) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }
                    } else if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty()){
                        system.debug('Inside !brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty()::');
                        if(brokerageScheme1[0].Type__c == 'Local'&& (bk.RW_Registration_Date__c != Null || (bk.RW_Registration_Date__c ==null &&(bk.Is_Special_Brokerage_Scheme__c == true ||bk.Is_AOP_CP_Applicable__c == true)  ))){
                            system.debug('Inside !brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty() scheme type local::');
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_X9_99_Received__c = true or X5_Received__c = true ) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }else if(brokerageScheme1[0].Type__c == 'NRI'){
                            system.debug('Inside !brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty() scheme type NRI::');
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,RW_X9_99_Received__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_X9_99_Received__c = true or X5_Received__c = true ) and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                            system.debug('bkList3 NRI::'+bkList3);	
                            system.debug('bkList3 size NRI::'+bkList3.size());
                        }
                        
                        else if(brokerageScheme1[0].Type__c == 'Both'){
                            system.debug('Inside !brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty() scheme type both::');
                            bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                       RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                       and (Type_of_Client__c =:'Local' OR Type_of_Client__c =:'NRI') and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                       (RW_Registration_Date__c != null or(RW_Registration_Date__c = Null and  (Type_of_Client__c ='NRI' or  Type_of_Client__c ='Outstation' or  Is_Special_Brokerage_Scheme__c = true or Is_AOP_CP_Applicable__c = true) ))and (RW_X9_99_Received__c = true or X5_Received__c = true)and
                                       DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: bk.BrokerIId__c ORDER BY Booking_Date__c ASC];
                        }
                    }
                    system.debug('bkList3::'+bkList3);
                    system.debug('bkList3 size::'+bkList3.size());
                    //count = bkList3.size();
                    //system.debug('count::'+count);
                    if(!bkList3.isEmpty() && !brokerageScheme1.isEmpty()){
                        system.debug('brokerageScheme1[0].Slab_Type__c::'+brokerageScheme1[0].Slab_Type__c);
                        if(brokerageScheme1[0].Slab_Type__c != null && brokerageScheme1[0].Slab_Type__c == 'Count'){
                            for(Booking__c bk3 : bkList3){
                                if(bk3.Id != bk.Id && bk3.Status__c != 'Cancelled'){
                                    count = count + 1;
                                    system.debug('Count::'+count);
                                    system.debug('bk3.Id::'+bk3.Id);
                                }
                                if(bk3.Id == bk.Id){
                                    count = count + 1;
                                    system.debug('count::'+ count);
                                    break;
                                }
                            }
                        }
                        if(brokerageScheme1[0].Slab_Type__c != null && brokerageScheme1[0].Slab_Type__c == 'Value'){
                            for(Booking__c bk3 : bkList3){
                                if(bk3.Id != bk.Id && bk3.Status__c != 'Cancelled'){
                                    totalAV = totalAV + bk3.Agreement_Value_for_brokers__c;
                                    system.debug('totalAV::'+totalAV);
                                    system.debug('bk3.Id::'+bk3.Id);
                                }
                                if(bk3.Id == bk.Id){
                                    system.debug('bk3.Id::'+bk3.Id + ' bk.Id::'+bk.Id);
                                    system.debug('totalAV::'+ totalAV);
                                    totalAV = totalAV + bk3.Agreement_Value_for_brokers__c;
                                    system.debug('totalAV::'+ totalAV);
                                    break;
                                }
                            }
                        }
                    }
                }
                if(bk.Id != null){
                    bId.add(bk.Id);
                    system.debug('bId::'+ bId);
                    system.debug('bId::'+ bId.size());
                }
            }
        }
        
        bkList5 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Type_of_Client__c,Passback__c,Account__c,RW_Registration_Date__c,
                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Brokerage__c,Custom_Base_Brokerage__c,Unit_No__c,
                   Base_Brokerage_2__c,RW_X9_99_Received__c,Is_Special_Brokerage_Scheme__c ,Dif_Br__c,Passback_Amount__c,X5_Received__c,Is_AOP_CP_Applicable__c,Type_Of_Client_Formula__c
                   from Booking__c where Id IN: bId
                   and BrokerIId__c != null];
        if(!bkList3.isEmpty()){
            for(Booking__c bk : bkList5){
                Date bookingDate = Date.ValueOf(bk.Booking_Date__c);
                Date startDate1;
                Date endDate1;
                system.debug('bookingDate::'+bookingDate);
                if(bk.BrokerIId__c != null){
                    system.debug('Inside 1st If----op.BrokerIId__c::'+bk.BrokerIId__c);
                    cpID.add(bk.BrokerIId__c);
                    system.debug('cpID::'+cpID);
                }
                
                
                system.debug('Inside 2nd If----bk.Project__c::'+bk.Project__c);
                brokerageScheme = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,Approval_Status__c,Base_Brokerage_for_Local_Bookings__c,Base_Brokerage_for_OS_NRI__c,AOP_CP__c,
                                   Start_Date__c,Base_Brokerage_for_NRI__c from Brokerage_Scheme__c where id =: BrokerageSchemeId and Approval_Status__c = 'Approved by Level 2'];
                
                system.debug('brokerageScheme::'+brokerageScheme);
                if(!brokerageScheme.isEmpty()){
                    startDate1 = brokerageScheme[0].Start_Date__c;
                    endDate1 = brokerageScheme[0].End_Date__c;
                    List<Brokerage_Summary__c> bs1 = new List<Brokerage_Summary__c>();
                    List<Brokerage__c> brokerage1 = new List<Brokerage__c>();
                    List<Brokerage__c> Kickerincentive1 = new List<Brokerage__c>();
                    system.debug('Inside BrokerageScheme if');
                    bk.Brokerage_Scheme__c = brokerageScheme[0].Id;
                    bk.Brokerage_Scheme_Name__c = brokerageScheme[0].Name;
                    KickerIncentiveId = GetKickerIncentives(bk.Unit_No__c,bookingDate,bk.Project__c,bk.Tower__c,bk.Type_of_Client__c);
                    if(bk.Custom_Base_Brokerage__c != null){
                        bk.Base_Brokerage_2__c = bk.Custom_Base_Brokerage__c;
                        bk.Base_Brokerage__c = bk.Custom_Base_Brokerage__c - bk.Passback__c ;
                        bk.Brokerage__c = bk.Custom_Base_Brokerage__c - bk.Passback__c;
                        bk.Kicker_Incentive_lookup__c = KickerIncentiveId;
                    }else{
                        if(bk.Type_Of_Client_Formula__c == 'Local' || bk.Type_Of_Client_Formula__c == 'Corporate'){
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c ;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c ;
                            bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                            if(KickerIncentiveId != null){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        }/*else{
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c;
                            bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                            if(KickerIncentiveId != null && bk.Type_of_Client__c == 'NRI'){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        } */ 
                        
                        //Added by Prashant to add NRI base brokerage.//22-10-25.START
                        else if(bk.Type_Of_Client_Formula__c == 'NRI'){
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - bk.Passback__c;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - bk.Passback__c;
                            bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_NRI__c;
                            if(KickerIncentiveId != null){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        }  
                        //Added by Prashant to add NRI base brokerage.//22-10-25.END
                        else if(bk.Type_Of_Client_Formula__c == 'Outstation'){
                            bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c;
                            bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c;
                            bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                            if(KickerIncentiveId != null){
                                bk.Kicker_Incentive_lookup__c = (Id)KickerIncentiveId;
                            }
                        }
                    }
                    
                    
                    updatebkList.add(bk);
                    if(!updatebkList.isEmpty()){
                        update updatebkList;
                        system.debug('updatebkList::'+updatebkList);
                    }
                    
                    brokerSummaryList = [select Id,Name,Broker__c,Brokerage_Scheme__c,Opportunity__c from Brokerage_Summary__c where Booking__c =: bk.Id and Broker__c IN : cpID];
                    system.debug('brokerSummaryList::'+brokerSummaryList);
                    
                    
                    brokerageSlab = [select id,Name,From__c,To__c,Total_Brokerage__c,Base_Brokerage__c,Additional_Brokerage__c,Brokerage_Scheme__c,
                                     Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,Base_Brokerage_for_Local_Bookings__c,
                                     Base_Brokerage_for_OS_NRI__c,Base_Brokerage_for_NRI__c,Total_Brokerage_for_OS_NRI__c,Total_Brokerage_for_Local_Bookings__c from Brokerage_Slab__c where Brokerage_Scheme__c =: brokerageScheme[0].Id and Name =: 'Slab 1'];
                    system.debug('brokerageSlab::'+brokerageSlab);
                    
                    List<Brokerage_Summary__c> updateBrokerSummarySlab1 = new List<Brokerage_Summary__c>();
                    List<Brokerage_Slab__c> brokerageSlabAV = new List<Brokerage_Slab__c>();
                    List<Booking__c> bookingList11 = new List<Booking__c>();
                    List<Brokerage_Scheme__c> brokerageScheme2 = new List<Brokerage_Scheme__c>();
                    List<Brokerage__c> brokerage2 = new List<Brokerage__c>();
                    List<Brokerage__c> brokerage3 = new List<Brokerage__c>();
                    List<Brokerage_Summary__c> updateBrokerSummarySlab = new List<Brokerage_Summary__c>();
                    List<Brokerage_Summary__c> BrokerSummarySlab2 = new List<Brokerage_Summary__c>();
                    List<Brokerage_Summary__c> updateBrokerSummarySlab3 = new List<Brokerage_Summary__c>();
                    List<Booking__c> bookList11 = new List<Booking__c>();
                    set<Id> bkId = new set<Id>();
                    map<Id,Id> mapforoptyAndBrokerSum = new map<Id,Id>();
                    
                    bkList4 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,Type_of_Client__c,Passback__c,
                               RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Is_Special_Brokerage_Scheme__c,X5_Received__c,Type_Of_Client_Formula__c from Booking__c where Id =: bk.Id];
                    system.debug('bkList4::'+bkList4);
                    if(bk.Is_AOP_CP_Applicable__c){
                        system.debug('Inside AOP Applicable..');
                        if(bk.X5_Received__c && bk.RW_X9_99_Received__c == false ||( bk.RW_X9_99_Received__c && bk.RW_Registration_Date__c ==Null)){
                            if(brokerSummaryList.isEmpty() && !brokerageSlab.isEmpty()){
                                system.debug('Inside empty brokerSummaryList-------');
                                //create a brokerage summary record
                                Brokerage_Summary__c bs = new Brokerage_Summary__c();
                                bs.Channel_Partner__c = bk.BrokerIId__c;
                                bs.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                bs.CP_Account__c = bk.Account__c;
                                if(!bkList4.isEmpty())
                                    bs.Booking__c = bkList4[0].id;
                                bs.Opportunity__c = bkList4[0].Customer__c;
                                bs.Status__c = 'Not Due';
                                bs1.add(bs) ;
                                if(!bs1.isEmpty()){
                                    insert bs1;
                                    system.debug('bs1 inserted::'+bs1);
                                    for(Brokerage_Summary__c bss :bs1){
                                        Booking__c book = new Booking__c();
                                        book.Brokerage_Summary__c = bss.id;
                                        book.Id = bk.Id;
                                        update book;
                                    }
                                }
                                
                                // if(!brokerageSlab1.isEmpty()){
                                //create a brokerage slab record
                                Brokerage__c b = new Brokerage__c();
                                if(brokerSummaryList.isEmpty()){
                                    b.Brokerage_Summary__c = bs1[0].Id;
                                }else{
                                    b.Brokerage_Summary__c = brokerSummaryList[0].Id;
                                }
                                b.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                b.Opportunity__c = bk.Customer__c;
                                b.Booking__c = bk.Id;
                                b.Channel_Partner__c = bk.BrokerIId__c;
                                b.Brokerage_Type__c = 'Base Brokerage';
                                b.Name = 'Base Brokerage';
                                b.Eligible_Slab__c = 'Slab 1';
                                b.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                                /*if((bk.RW_X9_99_Received__c == true && bk.RW_Registration_Date__c != NULL)||(bk.RW_X9_99_Received__c == true && bk.Is_Special_Brokerage_Scheme__c ==true)){
                                            b.Status__c = 'Due';
                                }
                                else{
                                  b.Status__c = 'Not Due';
                                }*/
                                /* if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Is_Special_Brokerage_Scheme__c == true ||bkList4[0].Is_Special_Brokerage_Scheme__c == true)){
b.Status__c = 'Due';
}
if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Type_of_Client__c == 'NRI' ||bk.Type_of_Client__c == 'Outstatoin')){
b.Status__c = 'Due';
}*/
                                if(bk.Custom_Base_Brokerage__c != null){
                                    
                                    b.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    //b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                
                                    }
                                }else{	
                                    if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                        b.Brokerage__c = brokerageSlab[0].Base_Brokerage_for_Local_Bookings__c - brokerageScheme[0].AOP_CP__c;
                                        // b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        //b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                                                       
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                    
                                        }                                        
                                    }
                                    
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'NRI'){
                                        b.Brokerage__c = brokerageSlab[0].Base_Brokerage_for_NRI__c- brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } 
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'Outstation'){
                                        b.Brokerage__c = brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        }                                                                                
                                    } 
                                    
                                   /* else{
                                        // b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        b.Brokerage__c = brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - brokerageScheme[0].AOP_CP__c;
                                        
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                    
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                    
                                        }                                
                                    } */
                                }                               
                               brokerage1.add(b);
                                
                                Brokerage__c b1 = new Brokerage__c();
                                if(brokerSummaryList.isEmpty()){
                                    b1.Brokerage_Summary__c = bs1[0].Id;
                                }else{
                                    b1.Brokerage_Summary__c = brokerSummaryList[0].Id;
                                }
                                b1.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                b1.Opportunity__c = bk.Customer__c;
                                b1.Booking__c = bk.Id;
                                b1.Channel_Partner__c = bk.BrokerIId__c;
                                b1.Brokerage_Type__c = 'Base Brokerage';
                                b1.Name = '1% Brokerage';
                                b1.Eligible_Slab__c = 'Slab 1';
                                b1.AOP_CP__c = true;
                                b1.Status__c = 'Due';
                                b1.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                                
                                if(bk.Custom_Base_Brokerage__c != null){
                                    b1.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b1.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                        system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );
                                    }
                                    else{
                                        b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b1.Brokerage__c / 100))) ;
                                        system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c);
                                        
                                    }
                                    
                                }
                                else{	
                                    if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                        b1.Brokerage__c = brokerageScheme[0].AOP_CP__c;
                                        // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );
                                          }
                                        else{
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+b1.Brokerage_Amount__c );
                                            
                                        }
                                    }else{
                                        b1.Brokerage__c = brokerageScheme[0].AOP_CP__c;
                                        if(bk.Passback_Amount__c > 0){
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c ) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );
                                            
                                        }
                                        else{
                                            b1.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b1.Brokerage__c ) / 100)));
                                            system.debug('Brokerage Amount  ::'+ b1.Brokerage_Amount__c );
                                            
                                        }
                                        
                                    } 
                                }
                                brokerage1.add(b1);                 
                                if(!brokerage1.isEmpty()){
                                    insert brokerage1;
                                    system.debug('brokerage1 inserted::'+brokerage1);
                                    
                                    Brokerage_Summary__c bs3 = new Brokerage_Summary__c();
                                    bs3.Id = brokerage1[0].Brokerage_Summary__c; 
                                    bs3.Applied_Slab_Name__c = brokerageSlab[0].Name;
                                    system.debug('Applied_Slab_Name__c::'+bs3.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab[0].Name::'+brokerageSlab[0].Name);
                                    updateBrokerSummarySlab1.add(bs3);
                                    system.debug('Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                
                                if(!updateBrokerSummarySlab1.isEmpty()){
                                    update updateBrokerSummarySlab1;
                                    system.debug('Updated Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                
                            } 
                        }
                        else if((bk.X5_Received__c && bk.RW_X9_99_Received__c && bk.RW_X9_99_Received__c && (bk.RW_Registration_Date__c != null ||(bk.RW_Registration_Date__c == Null &&  (bk.Type_of_Client__c =='NRI' ||  bk.Type_of_Client__c =='Outstation' || bk.Is_Special_Brokerage_Scheme__c == true ))))){
                            if(brokerSummaryList.isEmpty() && !brokerageSlab.isEmpty()){
                                system.debug('Inside empty brokerSummaryList-------');
                                //create a brokerage summary record
                                Brokerage_Summary__c bs = new Brokerage_Summary__c();
                                bs.Channel_Partner__c = bk.BrokerIId__c;
                                bs.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                bs.CP_Account__c = bk.Account__c;
                                if(!bkList4.isEmpty())
                                    bs.Booking__c = bkList4[0].id;
                                bs.Opportunity__c = bkList4[0].Customer__c;
                                bs.Status__c = 'Not Due';
                                bs1.add(bs) ;
                                if(!bs1.isEmpty()){
                                    insert bs1;
                                    system.debug('bs1 inserted::'+bs1);
                                    for(Brokerage_Summary__c bss :bs1){
                                        Booking__c book = new Booking__c();
                                        book.Brokerage_Summary__c = bss.id;
                                        book.Id = bk.Id;
                                        update book;
                                    }
                                }
                                
                                // if(!brokerageSlab1.isEmpty()){
                                //create a brokerage slab record
                                Brokerage__c b = new Brokerage__c();
                                if(brokerSummaryList.isEmpty()){
                                    b.Brokerage_Summary__c = bs1[0].Id;
                                }else{
                                    b.Brokerage_Summary__c = brokerSummaryList[0].Id;
                                }
                                b.Brokerage_Scheme__c = brokerageScheme[0].Id;
                                b.Opportunity__c = bk.Customer__c;
                                b.Booking__c = bk.Id;
                                b.Channel_Partner__c = bk.BrokerIId__c;
                                b.Brokerage_Type__c = 'Base Brokerage';
                                b.Name = 'Base Brokerage';
                                b.Eligible_Slab__c = 'Slab 1';
                                b.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                                /* if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Is_Special_Brokerage_Scheme__c == true ||bkList4[0].Is_Special_Brokerage_Scheme__c == true)){
b.Status__c = 'Due';
}
if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Type_of_Client__c == 'NRI' ||bk.Type_of_Client__c == 'Outstatoin')){
b.Status__c = 'Due';
}*/
                                if(bk.Custom_Base_Brokerage__c != null){
                                    b.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                        system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );
                                        
                                    }
                                    
                                }else{	
                                    if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                        b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }
                                        
                                        
                                    }
                                    //Added by Prashant Start
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'NRI'){
                                       b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }                                                                              
                                    } 
                                    else if(bkList4[0].Type_Of_Client_Formula__c == 'Outstation'){
                                        b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        // b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }                                                                               
                                    } 
                                    
                                    /*else{
                                        b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        if(bk.Passback_Amount__c > 0){
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }
                                        else{
                                            b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                            system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                            
                                        }
                                        
                                    } */
                                    //Added by Prashant END
                                }
                                                                
                                 brokerage1.add(b);
                                if(!brokerage1.isEmpty() ){
                                    insert brokerage1;
                                    system.debug('brokerage1 inserted::'+brokerage1);
                                    
                                    Brokerage_Summary__c bs3 = new Brokerage_Summary__c();
                                    bs3.Id = brokerage1[0].Brokerage_Summary__c; 
                                    bs3.Applied_Slab_Name__c = brokerageSlab[0].Name;
                                    system.debug('Applied_Slab_Name__c::'+bs3.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+brokerageSlab[0].Name);
                                    updateBrokerSummarySlab1.add(bs3);
                                    system.debug('Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }
                                    if(!updateBrokerSummarySlab1.isEmpty()){
                                    update updateBrokerSummarySlab1;
                                    system.debug('Updated Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                                }                                
                            }
                        }                        
                        
                    }// aop applicable
                    else{ if(brokerSummaryList.isEmpty() && !brokerageSlab.isEmpty() && bk.RW_X9_99_Received__c && (bk.RW_Registration_Date__c != null ||(bk.RW_Registration_Date__c == Null &&  (bk.Type_of_Client__c =='NRI' ||  bk.Type_of_Client__c =='Outstation' || bk.Is_Special_Brokerage_Scheme__c == true )))){
                            system.debug('Inside empty brokerSummaryList-------');
                            //create a brokerage summary record
                            Brokerage_Summary__c bs = new Brokerage_Summary__c();
                            bs.Channel_Partner__c = bk.BrokerIId__c;
                            bs.Brokerage_Scheme__c = brokerageScheme[0].Id;
                            bs.CP_Account__c = bk.Account__c;
                            if(!bkList4.isEmpty())
                                bs.Booking__c = bkList4[0].id;
                            bs.Opportunity__c = bkList4[0].Customer__c;
                            bs.Status__c = 'Not Due';
                            bs1.add(bs) ;
                            if(!bs1.isEmpty()){
                                insert bs1;
                                system.debug('bs1 inserted::'+bs1);
                                for(Brokerage_Summary__c bss :bs1){
                                    Booking__c book = new Booking__c();
                                    book.Brokerage_Summary__c = bss.id;
                                    book.Id = bk.Id;
                                    update book;
                                }
                            }
                            //create a brokerage slab record
                            Brokerage__c b = new Brokerage__c();
                            if(brokerSummaryList.isEmpty()){
                                b.Brokerage_Summary__c = bs1[0].Id;
                            }else{
                                b.Brokerage_Summary__c = brokerSummaryList[0].Id;
                            }
                            b.Brokerage_Scheme__c = brokerageScheme[0].Id;
                            b.Opportunity__c = bk.Customer__c;
                            b.Booking__c = bk.Id;
                            b.Channel_Partner__c = bk.BrokerIId__c;
                            b.Brokerage_Type__c = 'Base Brokerage';
                            b.Name = 'Base Brokerage';
                            b.Eligible_Slab__c = 'Slab 1';
                            b.Opportunity_AV__c = bk.Agreement_Value_for_brokers__c;
                            if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Is_Special_Brokerage_Scheme__c == true ||bkList4[0].Is_Special_Brokerage_Scheme__c == true)){
                                b.Status__c = 'Due';
                            }
                            if(bk.RW_X9_99_Received__c == true && b.Brokerage_Type__c == 'Base Brokerage'&&(bk.Type_of_Client__c == 'NRI' ||bk.Type_of_Client__c == 'Outstation')){
                                b.Status__c = 'Due';
                            }
                            if(bk.Custom_Base_Brokerage__c != null){
                                b.Brokerage__c = (bk.Custom_Base_Brokerage__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                if(bk.Passback_Amount__c > 0){
                                    b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100)) + (bk.Dif_Br__c)) ;
                                    system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                }
                                else{
                                    b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * (b.Brokerage__c / 100))) ;
                                    system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );                                    
                                }                                
                            }else{	
                                if(bkList4[0].Type_Of_Client_Formula__c == 'Local' || bkList4[0].Type_Of_Client_Formula__c == 'Corporate'){
                                    b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_Local_Bookings__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                        system.debug('Avb::'+bk.Agreement_Value_for_brokers__c);
                                        system.debug('b::'+b.Brokerage__c);
                                        system.debug('b1::'+(b.Brokerage__c)/ 100);
                                        system.debug('dif::'+bk.Dif_Br__c);
                                        system.debug('Ca::::'+((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount 291 ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }
                                }
                                
                                else if(bkList4[0].Type_Of_Client_Formula__c == 'NRI'){
                                    b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                        system.debug('Avb::'+bk.Agreement_Value_for_brokers__c);
                                        system.debug('b::'+b.Brokerage__c);
                                        system.debug('b1::'+(b.Brokerage__c)/ 100);
                                        system.debug('dif::'+bk.Dif_Br__c);
                                        system.debug('Ca::::'+((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount 291 ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }                                                                            
                                } 
                                else if(bkList4[0].Type_Of_Client_Formula__c == 'Outstation'){
                                    b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)) + bk.Dif_Br__c);
                                        system.debug('Avb::'+bk.Agreement_Value_for_brokers__c);
                                        system.debug('b::'+b.Brokerage__c);
                                        system.debug('b1::'+(b.Brokerage__c)/ 100);
                                        system.debug('dif::'+bk.Dif_Br__c);
                                        system.debug('Ca::::'+((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount 291 ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c)/ 100)));
                                        system.debug('Brokerage Amount  ::'+ b.Brokerage_Amount__c );
                                    }                                                                             
                                } 
                                
                                /*else{
                                    b.Brokerage__c = (brokerageSlab[0].Base_Brokerage_for_OS_NRI__c - bk.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                    if(bk.Passback_Amount__c > 0){
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)) + bk.Dif_Br__c);
                                        system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                    else{
                                        b.Brokerage_Amount__c = (((bk.Agreement_Value_for_brokers__c) * ((b.Brokerage__c) / 100)));
                                        system.debug('Brokerage Amount ::'+ b.Brokerage_Amount__c );                                        
                                    }
                                } */
                                //Added by Prashant END
                            }
                            brokerage1.add(b);
                            if(!brokerage1.isEmpty() ){
                                insert brokerage1;
                                system.debug('brokerage1 inserted::'+brokerage1);
                                
                                Brokerage_Summary__c bs3 = new Brokerage_Summary__c();
                                bs3.Id = brokerage1[0].Brokerage_Summary__c; 
                                bs3.Applied_Slab_Name__c = brokerageSlab[0].Name;
                                system.debug('Applied_Slab_Name__c::'+bs3.Applied_Slab_Name__c);
                                system.debug('brokerageSlab[0].Name::'+brokerageSlab[0].Name);
                                updateBrokerSummarySlab1.add(bs3);
                                system.debug('Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                            }
                               if(!updateBrokerSummarySlab1.isEmpty()){
                                update updateBrokerSummarySlab1;
                                system.debug('Updated Brokerage Summary Slab1::'+updateBrokerSummarySlab1);
                            }
                            
                        }
                    }
                    
                }
            }
        }
        
    }   
    
    Public static void dummy1(){
        
        integer i = 0;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++; i++;
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
        i++;
        i++;
        i++;
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
        i++; i++;
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
        i++; i++;
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
        i++;
        i++;
        i++;
        i++;
        i++; i++;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
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
        i++;
        i++;
        i++;
        i++; i++;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
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
        i++;
        i++;
        i++;
        i++;
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}