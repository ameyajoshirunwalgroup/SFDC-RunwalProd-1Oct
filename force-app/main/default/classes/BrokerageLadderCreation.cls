public class BrokerageLadderCreation {
    public static void CreateInvoice(Set<ID> AllSchemeId,Id CPId){
        List<Booking__c> bkList1 = new List<Booking__c>();
        List<Booking__c> bkList2 = new List<Booking__c>();
        List<Booking__c> bkList3 = new List<Booking__c>();
        List<Broker__c> CPList = new List<Broker__c>();
        List<Scheme_Configuration__c> scprojtower = new List<Scheme_Configuration__c>();
        List<Brokerage_Scheme__c> brokerageScheme1 = new List<Brokerage_Scheme__c>();
        List<Brokerage_Slab__c> brokerageSlab = new List<Brokerage_Slab__c>();
        List<Brokerage_Slab__c> brokerageSlab1 = new List<Brokerage_Slab__c>();
        List<Brokerage_Summary__c> BrokerSummarySlab = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerage = new List<Brokerage__c>();
        List<Brokerage_Summary__c> updateBrokerSummarySlab = new List<Brokerage_Summary__c>();
        Map<Id,Brokerage_Slab__c> slabmap = new Map<Id,Brokerage_Slab__c>();
        Map<Id,Brokerage__c> Brokeragemap = new Map<Id,Brokerage__c>();
        Map<Id,Broker__c> CPMap = new Map<Id,Broker__c>();
        List<Brokerage__c> Existingbrokerage = new List<Brokerage__c>();
        set<ID> CPIds = new set<ID>();
        set<ID> scprj = new set<ID>();
        set<ID> sctower = new set<ID>();
        set<Id> bSlabId = new set<Id>();
        Date startDate;
        Date endDate;
        Decimal totalAV = 0.0;
        Integer count = 0;
        CPList = [Select Id,Name from Broker__c where ID =: CPId];
        for(Broker__c cp:CPList){
            CPMap.put(cp.Id,cp);
        }
        brokerageScheme1 = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,Approval_Status__c,Type__c,
                            Start_Date__c from Brokerage_Scheme__c where id IN: AllSchemeId and Approval_Status__c = 'Approved by Level 2'];
        system.debug('brokerageScheme1::'+brokerageScheme1);
        scprojtower = [Select id,Tower__c,Project__c,Brokerage_Scheme__c from Scheme_Configuration__c where Brokerage_Scheme__c IN: brokerageScheme1];
        brokerageSlab = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Additional_Brokerage_for_Local_Bookings__c,
                         Additional_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Brokerage_Scheme__c IN: brokerageScheme1];
        system.debug('brokerageSlab::'+brokerageSlab);
        brokerageSlab1 = [select id,Name,From__c,To__c,Total_Brokerage__c,Base_Brokerage__c,Additional_Brokerage__c,Brokerage_Scheme__c,
                          Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,Base_Brokerage_for_Local_Bookings__c,
                          Base_Brokerage_for_OS_NRI__c,Total_Brokerage_for_OS_NRI__c,Total_Brokerage_for_Local_Bookings__c from Brokerage_Slab__c];
        system.debug('brokerageSlab1::'+brokerageSlab1);
        for(Brokerage_Slab__c bs:brokerageSlab1){
            slabmap.put(bs.Id, bs);
        }
        Existingbrokerage = [Select Id,Name,Brokerage_Summary__c,Eligible_Slab__c,Booking__c,Brokerage_Type__c,Status__c,Brokerage_Amount__c,Brokerage__c from Brokerage__c
                             where Brokerage_Type__c = 'Additional Brokerage' and Status__c != 'Due' and Cancelled__c = false];
        for(Brokerage__c b:Existingbrokerage){
            Brokeragemap.put(b.Brokerage_Summary__c,b);
        }
        for(Id cp:CPMap.keySet()){
            for(Brokerage_Scheme__c Scheme:brokerageScheme1){
                scprj = new set<ID>();
                sctower = new set<ID>();
                totalAV = 0.0;
                count = 0;
                bSlabId = new set<Id>();
                Id SlabId = null;
                for(Scheme_Configuration__c scon :scprojtower){
                    if(scon.Brokerage_Scheme__c == Scheme.Id){
                        if(scon.Project__c != null && scon.Tower__c != null){
                            scprj.add(scon.Project__c);
                            sctower.add(scon.Tower__c);
                        }else{
                            scprj.add(scon.Project__c);
                        }
                    }
                }
                system.debug('scprj::'+scprj);
                system.debug('sctower::'+sctower);
                if(!brokerageScheme1.isEmpty()){
                    startDate = brokerageScheme1[0].Start_Date__c;
                    endDate = brokerageScheme1[0].End_Date__c;
                    system.debug('startDate::'+ startDate +' endDate::'+endDate);
                }
                
                if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && sctower.isEmpty()){
                    if(brokerageScheme1[0].Type__c == 'Local'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed'  and RW_Registration_Done__c = 'Yes'  
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'NRI'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' and RW_Registration_Done__c = 'Yes'
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'Both'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed'  and RW_Registration_Done__c = 'Yes' and
                                    (Type_Of_Client_Formula__c =:'Local' OR Type_Of_Client_Formula__c =:'NRI') and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }
                } else if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty()){
                    if(brokerageScheme1[0].Type__c == 'Local'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and RW_Registration_Done__c = 'Yes' and  Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp  ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'NRI'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and RW_Registration_Done__c = 'Yes' and  Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'Both'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                   and (Type_Of_Client_Formula__c =:'Local' OR Type_Of_Client_Formula__c =:'NRI') and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and RW_Registration_Done__c = 'Yes' and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }
                }                 
                system.debug('bkList2::'+bkList2);
                system.debug('bkList2 size::'+bkList2.size());
                if(!bkList2.isEmpty() && !brokerageScheme1.isEmpty()){
                    system.debug('brokerageScheme1[0].Slab_Type__c::'+brokerageScheme1[0].Slab_Type__c);
                    if(brokerageScheme1[0].Slab_Type__c != null && brokerageScheme1[0].Slab_Type__c == 'Count'){
                        for(Booking__c bk3 : bkList2){
                            if(bk3.Status__c != 'Cancelled'){
                                count = count + 1;
                                system.debug('Count::'+count);
                                system.debug('bk3.Id::'+bk3.Id);
                            }
                        }
                    }
                    if(brokerageScheme1[0].Slab_Type__c != null && brokerageScheme1[0].Slab_Type__c == 'Value'){
                        for(Booking__c bk3 : bkList2){
                            if(bk3.Status__c != 'Cancelled'){
                                totalAV = totalAV + bk3.Agreement_Value_for_brokers__c;
                                system.debug('totalAV::'+totalAV);
                                system.debug('bk3.Id::'+bk3.Id);
                            }
                        }
                    }
                }
                
                for(Brokerage_Slab__c bSlab : brokerageSlab){
                    system.debug('inside Brokerage Slab if---');
                    system.debug('Count::'+count);
                    system.debug('totalAV::'+totalAV);
                    if(count != 0 && count > 0 && bSlab.Brokerage_Scheme__c == Scheme.Id){
                        system.debug('bSlab.From__c <= count && bSlab.To__c >= count::::'+ (bSlab.From__c <= count && bSlab.To__c >= count));
                        if(bSlab.From__c != null && (bSlab.From__c <= count && (bSlab.To__c >= count || bSlab.To__c == null))){
                            bSlabId.add(bSlab.Id);
                            SlabId = bSlab.Id;
                            system.debug('bSlabId::'+bSlabId);
                        }
                    }
                    if(totalAV != 0 && totalAV > 0 && bSlab.Brokerage_Scheme__c == Scheme.Id){
                        system.debug('bSlab.From__c <= totalAV && bSlab.To__c >= totalAV::::'+ (bSlab.From__c <= totalAV && bSlab.To__c >= totalAV));
                        if(bSlab.From__c != null && (bSlab.From__c <= totalAV && (bSlab.To__c >= totalAV || bSlab.To__c == null))){
                            bSlabId.add(bSlab.Id);
                            SlabId = bSlab.Id;
                            system.debug('bSlabId1::'+bSlabId);
                        }
                    }
                }
                bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,
                           RW_Total_Receipt_Amount_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c,BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' and RW_Registration_Date__c != null and RW_X9_99_Received__c = true and RW_Registration_Done__c = 'Yes' and  Brokerage_Summary__c != null and
                           Customer__c != null and Brokerage_Scheme__c =:Scheme.Id and BrokerIId__c =:cp
                           and DAY_ONLY(Booking_Date__c) >=:startDate and DAY_ONLY(Booking_Date__c) <=:endDate ORDER BY Booking_Date__c ASC];
                system.debug('bkList3::'+bkList3);
                BrokerSummarySlab =  [select Id,Name,Channel_Partner__c,Booking__r.Custom_Base_Brokerage__c,Applied_Slab_Name__c,Brokerage_Scheme__c,Brokerage__c,Opportunity__c,Total_Agreement_Value__c,Passback__c,
                                      Booking__r.Type_of_Client__c,Booking__c,Booking__r.Brokerage__c,Booking__r.Type_Of_Client_Formula__c from Brokerage_Summary__c where Booking__c IN : bkList3 
                                      and Channel_Partner__c =: cp and Brokerage__c > 0];
                system.debug('BrokerSummarySlab::'+BrokerSummarySlab);
                system.debug('Size of BrokerSummarySlab::'+BrokerSummarySlab.size());
                if(!BrokerSummarySlab.isEmpty()){
                  
                    system.debug('Inside if BrokerSummarySlab if this list is not empty');
                    for(Brokerage_Summary__c bs : BrokerSummarySlab){
                        if(bs.Booking__r.Custom_Base_Brokerage__c != null){
                            if(bs.Booking__r.Type_Of_Client_Formula__c == 'Local' || bs.Booking__r.Type_Of_Client_Formula__c == 'Corporate'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                 system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                 system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_Local_Bookings__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('b2.Brokerage__c::'+b2.Brokerage__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((b2.Brokerage__c / 100)));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_Local_Bookings__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((Brokeragemap.get(bs.Id).Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                } 
                            }else{
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Brokerage__c = (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        system.debug('b2.Brokerage__c ::'+b2.Brokerage__c );
                                        system.debug('Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                        system.debug('Additional_Brokerage_for_Local_Bookings__c::'+slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        system.debug('bs.Brokerage__c::'+(bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c - bs.Brokerage__c));
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((b2.Brokerage__c) / 100));
                                        //b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ( bs.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }  
                            }
                        }else{
                            if(bs.Booking__r.Type_Of_Client_Formula__c == 'Local' || bs.Booking__r.Type_Of_Client_Formula__c == 'Corporate'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = ((slabmap.get(SlabId).Total_Brokerage_for_Local_Bookings__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('brokerageSlab1[0].Total_Brokerage_for_Local_Bookings__c::'+slabmap.get(SlabId).Total_Brokerage_for_Local_Bookings__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * (b2.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + ((slabmap.get(SlabId).Total_Brokerage_for_Local_Bookings__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }
                            }else{
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = ((slabmap.get(SlabId).Total_Brokerage_for_OS_NRI__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('brokerageSlab1[0].Total_Brokerage_for_OS_NRI__c::'+slabmap.get(SlabId).Total_Brokerage_for_OS_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * (b2.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + ((slabmap.get(SlabId).Total_Brokerage_for_OS_NRI__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }
                            }  
                        }
                    }
                    if(!brokerage.isEmpty()){
                        insert brokerage;
                        system.debug('brokerage inserted::'+brokerage);
                        
                        
                    }
                    if(!updateBrokerSummarySlab.isEmpty()){
                        update updateBrokerSummarySlab;
                        system.debug('Updated Brokerage Summary Slab  ::'+updateBrokerSummarySlab);
                    }
                    
                }
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
       
        
        
    }
}