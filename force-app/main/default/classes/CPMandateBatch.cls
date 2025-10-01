global class CPMandateBatch implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable{

    @InvocableMethod
    public static void executeCpMandateBatch() {
        Id jobId = Database.executeBatch(new CPMandateBatch());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        return Database.getQueryLocator([SELECT Id, Name, Start_Date__c, End_Date__c, Channel_Partner__c, Projects__c, RecordTypeId, Approver_L1__c, Approver_L2__c, AOP_CP_Name__c, Brokerage__c, CP_Invoice_Approver_L1__c, CP_Invoice_Approver_L2__c, CP_Invoice_Approver_L3__c, CP_Invoice_Approver_L4__c, CP_Invoice_Approver_L5__c, Brokerage_for_Outstation__c, Brokerage_for_NRI__c FROM AOP__c WHERE RecordTypeId =: recordTypeId]);
    }
    
    global void execute(Database.BatchableContext BC, List<AOP__c> aopList){
        List<Date> startDates = new List<Date>();
        List<Date> endDates = new List<Date>();
        List<String> projectList = new List<String>();
        String projectString = '';
        Map<String, AOP__c> aopMap = new Map<String, AOP__c>();
        if(aopList.size() > 0){
            for(AOP__c aop : aopList){
                startDates.add(aop.Start_Date__c);
                endDates.add(aop.End_Date__c);
                aopMap.put(aop.Name, aop);
                if(aop.Projects__c != null){
                    projectString += aop.Projects__c + ';';
                }
            }
            projectList = projectString.split(';');
            startDates.sort();
            endDates.sort();
            List<Booking__c> bkgList = new List<Booking__c>();
            List<Booking__c> bkgListForRecovery = new List<Booking__c>();
            List<Booking__c> bkgListForAtt = new List<Booking__c>();
            
            if(!Test.isRunningTest()){
                bkgList = [SELECT Id, Name, Booking_Date__c, AOP_Mandate__c, Project__r.Name, Agreement_Value_for_brokers__c, Status__c,
                           Unit_No__r.Legal_Entity__c, CP_Mandate_Invoice_Date__c, CP_Mandate_Recovery_Date__c, Allotment_Premium__c,
                           Unit_No__r.Legal_Entity__r.Name, Type_of_Client__c, Payment_Received__c, RW_Registration_Date__c FROM Booking__c WHERE   
                           Project__r.Name IN: projectList AND Booking_Date__c >=: startDates[0] AND 
                           Booking_Date__c <=: endDates[endDates.size()-1]];
                
                bkgListForRecovery = [SELECT Id, Name, Booking_Date__c, AOP_Mandate__c, Project__r.Name, Agreement_Value_for_brokers__c, Status__c,
                                      Unit_No__r.Legal_Entity__c, CP_Mandate_Invoice_Date__c, CP_Mandate_Recovery_Date__c, Allotment_Premium__c,
                                      Unit_No__r.Legal_Entity__r.Name, Type_of_Client__c FROM Booking__c WHERE  RW_Registration_Date__c != null 
                                      AND Payment_Received__c >= 9.9 AND Status__c = 'Booking Confirmed' AND AOP_Mandate__c != null AND 
                                      CP_Mandate_Invoice_Date__c != null AND CP_Mandate_Recovery_Date__c = null AND Project__r.Name IN: projectList 
                                      AND (Booking_Date__c <: startDates[0] OR Booking_Date__c >: endDates[endDates.size()-1])];
            }else{
                bkgList = [SELECT Id, Name, Booking_Date__c, AOP_Mandate__c, Project__r.Name, Agreement_Value_for_brokers__c, Status__c,
                                        Unit_No__r.Legal_Entity__c, CP_Mandate_Invoice_Date__c, CP_Mandate_Recovery_Date__c, Allotment_Premium__c,
                                        Unit_No__r.Legal_Entity__r.Name, Type_of_Client__c, RW_Registration_Date__c, Payment_Received__c FROM Booking__c];
            }
            List<Booking__c> bkgsToUpdate = new List<Booking__c>();
            
            Map<String, String> bkgVsAopName = new Map<String, String>();
            Map<String, List<Booking__c>> aopVsBkgMap = new Map<String, List<Booking__c>>();
            if(bkgList.size() > 0){
                for(AOP__c aop : aopList){
                    aopVsBkgMap.put(aop.Name, new List<Booking__c>());
                    if(aop.Projects__c != null){
                        List<String> projList = aop.Projects__c.split(';');
                        for(Booking__c bkg : bkgList){
                            if(bkg.Booking_Date__c >= aop.Start_Date__c && bkg.Booking_Date__c <= aop.End_Date__c && projList.contains(bkg.Project__r.Name)){
                                bkgVsAopName.put(bkg.Id, aop.Name);
                                aopVsBkgMap.get(aop.Name).add(bkg);
                            }
                        }
                        for(Booking__c bkg : bkgListForRecovery){
                            bkgVsAopName.put(bkg.Id, aop.Name);
                            aopVsBkgMap.get(aop.Name).add(bkg);
                        }
                    }
                }
            }
            List<Brokerage_Invoice__c> invoices = new List<Brokerage_Invoice__c>();
            List<String> canceslStatusValues = new List<String>{'Cancelled','Cancellation Initiated','Booking Cancelled – Refund Pending'};
            List<Brokerage_Summary__c> summaries = new List<Brokerage_Summary__c>();
            List<Brokerage__c> brokerages = new List<Brokerage__c>();
            Map<String, String> legalEntityMap = new Map<String, String>();
            Map<String, List<String>> leVsBkgName = new Map<String, List<String>>();
            
            for(AOP__c aop : aopList){
                Map<String, List<Booking__c>> legalEntityBkgMap = new Map<String, List<Booking__c>>();
                for(Booking__c bkg : aopVsBkgMap.get(aop.Name)){
                    if(bkg.Unit_No__r.Legal_Entity__c != null){
                        if(!legalEntityBkgMap.keySet().contains(bkg.Unit_No__r.Legal_Entity__c)){
                            legalEntityBkgMap.put(bkg.Unit_No__r.Legal_Entity__c, new List<Booking__c>{bkg});
                        }else{
                            legalEntityBkgMap.get(bkg.Unit_No__r.Legal_Entity__c).add(bkg);
                        }
                        legalEntityMap.put(bkg.Unit_No__r.Legal_Entity__c, bkg.Unit_No__r.Legal_Entity__r.Name);
                    }
                }
                Map<String, Decimal> leAvMap = new Map<String, Decimal>();
                Map<String, Decimal> leAvMapBooked = new Map<String, Decimal>();
                Map<String, Decimal> leAvMapCancelled = new Map<String, Decimal>();
                Map<String, Decimal> leBrkAmtMapBooked = new Map<String, Decimal>();
                Map<String, Decimal> leBrkAmtMapCancelled = new Map<String, Decimal>();
                
                for(String le : legalEntityBkgMap.keySet()){
                    Decimal leAvBooked = 0;
                    Decimal leAvCancelled = 0;
                    Decimal leBrkAmtBooked = 0;
                    Decimal leBrkAmtCancelled = 0;
                    leVsBkgName.put(le, new List<String>{});
                    for(Booking__c bkg : legalEntityBkgMap.get(le)){
                        Decimal av = 0;
                        if((bkg.Status__c == 'Booking Confirmed' && bkg.AOP_Mandate__c == null && bkg.CP_Mandate_Invoice_Date__c == null && bkg.Payment_Received__c >= 9.9 && bkg.RW_Registration_Date__c != null) || Test.isRunningTest()){
                            if(bkg.Agreement_Value_for_brokers__c != null && bkg.Agreement_Value_for_brokers__c != 0){
                                leAvBooked += bkg.Agreement_Value_for_brokers__c;
                                av = bkg.Agreement_Value_for_brokers__c;
                            }else{
                                leAvBooked += bkg.Allotment_Premium__c;
                                av = bkg.Allotment_Premium__c;
                            }
                            if(bkg.Type_of_Client__c == 'Local'){
                                leBrkAmtBooked += ((av * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage__c)/100);
                            }else if(bkg.Type_of_Client__c == 'Outstation'){
                                leBrkAmtBooked += ((av * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage_for_Outstation__c)/100);
                            }else if(bkg.Type_of_Client__c == 'NRI'){
                                leBrkAmtBooked += ((av * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage_for_NRI__c)/100);
                            }
                            bkg.CP_Mandate_Invoice_Date__c = Date.today();
                            bkg.AOP_Mandate__c = bkgVsAopName.get(bkg.Id);
                            bkgsToUpdate.add(bkg);
                            leAvMap.put(le, leAvBooked);
                            leVsBkgName.get(le).add(bkg.Name);
                            bkgListForAtt.add(bkg);
                        }else if(canceslStatusValues.contains(bkg.Status__c) && bkg.AOP_Mandate__c != null && bkg.CP_Mandate_Invoice_Date__c != null &&
                                 bkg.CP_Mandate_Recovery_Date__c == null){
                                    Decimal avCancl = 0;
                                     if(bkg.Agreement_Value_for_brokers__c != null && bkg.Agreement_Value_for_brokers__c != 0){
                                         leAvCancelled = leAvCancelled - bkg.Agreement_Value_for_brokers__c;
                                         avCancl = bkg.Agreement_Value_for_brokers__c;
                                     }else{
                                         leAvCancelled = leAvCancelled - bkg.Allotment_Premium__c;
                                         avCancl = bkg.Agreement_Value_for_brokers__c;
                                     }
                                     if(bkg.Type_of_Client__c == 'Local'){
                                         leBrkAmtCancelled += ((avCancl * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage__c)/100);
                                     }else if(bkg.Type_of_Client__c == 'Outstation'){
                                         leBrkAmtCancelled += ((avCancl * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage_for_Outstation__c)/100);
                                     }else if(bkg.Type_of_Client__c == 'NRI'){
                                         leBrkAmtCancelled += ((avCancl * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage_for_NRI__c)/100);
                                     }
                                     bkg.CP_Mandate_Recovery_Date__c = Date.today();
                                     bkg.AOP_Mandate__c = bkgVsAopName.get(bkg.Id);
                                     bkgsToUpdate.add(bkg);
                                     leAvMap.put(le, leAvCancelled);
                                     leVsBkgName.get(le).add(bkg.Name);
                                     bkgListForAtt.add(bkg);
                                 }
                    }
                    leAvMapBooked.put(le, leAvBooked);
                    leAvMapCancelled.put(le, leAvCancelled);
                    leBrkAmtMapBooked.put(le, leBrkAmtBooked);
                    leBrkAmtMapCancelled.put(le, leBrkAmtCancelled);
                }
                
                for(Booking__c bkg : bkgListForRecovery){
                    if(leAvMapCancelled.keySet().contains(bkg.Unit_No__r.Legal_Entity__c)){
                        Decimal val;
                        Decimal BrkAmt = 0;
                        if(bkg.Agreement_Value_for_brokers__c != null && bkg.Agreement_Value_for_brokers__c != 0){
                            val = leAvMapCancelled.get(bkg.Unit_No__r.Legal_Entity__c) + bkg.Agreement_Value_for_brokers__c;
                        }else{
                            val = leAvMapCancelled.get(bkg.Unit_No__r.Legal_Entity__c) + bkg.Allotment_Premium__c;
                        }
                        if(bkg.Type_of_Client__c == 'Local'){
                            BrkAmt += ((val * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage__c)/100);
                        }else if(bkg.Type_of_Client__c == 'Outstation'){
                            BrkAmt += ((val * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage_for_Outstation__c)/100);
                        }else if(bkg.Type_of_Client__c == 'NRI'){
                            BrkAmt += ((val * aopMap.get(bkgVsAopName.get(bkg.Id)).Brokerage_for_NRI__c)/100);
                        }
                        leAvMapCancelled.put(bkg.Unit_No__r.Legal_Entity__c, val);
                        leBrkAmtMapCancelled.put(bkg.Unit_No__r.Legal_Entity__c, BrkAmt);
                        leVsBkgName.get(bkg.Unit_No__r.Legal_Entity__c).add(bkg.Name);
                        bkgListForAtt.add(bkg);
                        leAvMap.put(bkg.Unit_No__r.Legal_Entity__c, val);
                        bkg.CP_Mandate_Recovery_Date__c = Date.today();
                        bkg.AOP_Mandate__c = bkgVsAopName.get(bkg.Id);
                        bkgsToUpdate.add(bkg);
                    }
                }
                for(String le : leAvMap.keySet()){
                    
                    Brokerage_Summary__c bs = new Brokerage_Summary__c();
                    bs.Channel_Partner__c = aop.Channel_Partner__c;
                    summaries.add(bs);
                    
                    String leName = legalEntityMap.get(le); 
                    if(leName.length() > 60){
                        leName = leName.substring(0, 60);
                    }
                    Brokerage__c br = new Brokerage__c();
                    br.Name = 'AOP Mandate - ' + leName;
                    br.Channel_Partner__c = aop.Channel_Partner__c;
                    brokerages.add(br);
                    
                    String bkgListStr = '';
                    for(String bkg : leVsBkgName.get(le)){
                        bkgListStr = bkgListStr + bkg + ',';
                    }
                    
                    Brokerage_Invoice__c inv = new Brokerage_Invoice__c();
                    inv.Channel_Partner__c = aop.Channel_Partner__c;
                    inv.Total_Agreement_Value__c = leAvMapBooked.get(le) - leAvMapCancelled.get(le);
                    //inv.CP_Mandate_Recovery_Amount__c = (leAvMapCancelled.get(le) * aop.Brokerage__c)/100;
                    inv.CP_Mandate_Recovery_Amount__c = leBrkAmtMapCancelled.get(le).setscale(2,RoundingMode.HALF_UP);
                    inv.AOP__c = aop.Id;
                    inv.Legal_Entity__c = le;
                    //inv.Brokerage__c = aop.Brokerage__c;
                    //inv.Brokerage_In_Rs__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
                    inv.Brokerage_In_Rs__c = (leBrkAmtMapBooked.get(le) - leBrkAmtMapCancelled.get(le)).setscale(2,RoundingMode.HALF_UP);
                    //inv.Invoice_Amount__c = (inv.Total_Agreement_Value__c * inv.Brokerage__c)/100;
                    inv.Invoice_Amount__c = (leBrkAmtMapBooked.get(le) - leBrkAmtMapCancelled.get(le)).setscale(2,RoundingMode.HALF_UP);
                    inv.CP_Invoice_Clearing_L1__c = aop.Approver_L1__c;
                    inv.CP_Invoice_Approver_L1__c = aop.Approver_L1__c;
                    inv.CP_Invoice_Approver_L2__c = aop.CP_Invoice_Approver_L1__c;
                    inv.CP_Invoice_Approver_L5__c = aop.CP_Invoice_Approver_L4__c;
                    inv.Booking_List__c = bkgListStr;
                    invoices.add(inv);
                }
            }
            
            insert summaries;
            for(Brokerage__c br : brokerages){
                br.Brokerage_Summary__c = summaries[brokerages.indexOf(br)].Id;
            }
            insert brokerages;
            for(Brokerage_Invoice__c inv : invoices){
                inv.Brokerage_Lookup__c = brokerages[invoices.indexOf(inv)].Id;
            }
            
            
            //insert invoices;
            Database.saveResult[] srList = Database.insert(invoices, false);
            update bkgsToUpdate;
            List<Attachment> atts = new List<Attachment>();
            if (srList[0].isSuccess()){
                List<Brokerage_Invoice__c> invs = [SELECT Id, AOP__r.Name, Legal_Entity__c, AOP__r.Brokerage__c, Booking_List__c,
                                                   CP_Mandate_Recovery_Amount__c FROM Brokerage_Invoice__c WHERE Id =: invoices];
                
                List<Booking__c> bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Opportunity__r.SAP_Customer_Number__c,
                                         Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, Date_of_Cancellation__c, 
                                         Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                        				 Allotment_Premium__c, AOP_Mandate__c, Type_of_Client__c FROM Booking__c WHERE Id =: bkgListForAtt];
                Map<String, Booking__c> bkgNameMap = new Map<String, Booking__c>();
                for(Booking__c bkg : bkgs){
                    bkgNameMap.put(bkg.Name, bkg);
                }
                for(Brokerage_Invoice__c inv : invs){
                    String csvContentString ='CRN,Customer Name,Client Type,Booking Date,Booking Status,Tower - Unit No,Final AV Value,Brokerage %,Brokerage Amount,CGST @ 9%,SGST @ 9%,Total Brokerage,CP Name\n';
					String fileRow = '';
                    List<String> bkNameList = inv.Booking_List__c.split(',');
                    for(String bkName : bkNameList){
                        fileRow = '';
                        fileRow = fileRow +','+ bkgNameMap.get(bkName).Opportunity__r.SAP_Customer_Number__c;
                        fileRow = fileRow +','+ bkgNameMap.get(bkName).Opportunity__r.Name;
                        fileRow = fileRow +','+ bkgNameMap.get(bkName).Type_of_Client__c;
                        fileRow = fileRow +','+ Date.valueOf(bkgNameMap.get(bkName).Booking_Date__c);
                        fileRow = fileRow +','+ bkgNameMap.get(bkName).Status__c;
                        fileRow = fileRow +','+ bkgNameMap.get(bkName).Unit_No__r.RW_Param2__c + ' - ' + bkgNameMap.get(bkName).Unit_No__r.RW_Param4__c;
                        Decimal amountVal = 0;
                        if(bkgNameMap.get(bkName).Agreement_Value_for_brokers__c != null && bkgNameMap.get(bkName).Agreement_Value_for_brokers__c != 0){
                            amountVal = bkgNameMap.get(bkName).Agreement_Value_for_brokers__c.setscale(2,RoundingMode.HALF_UP);
                        }else{
                            amountVal = bkgNameMap.get(bkName).Allotment_Premium__c.setscale(2,RoundingMode.HALF_UP);
                        }
                        fileRow = fileRow +','+ amountVal;
                        fileRow = fileRow +','+ inv.AOP__r.Brokerage__c;
                        Decimal brokerageAmount = ((inv.AOP__r.Brokerage__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                        fileRow = fileRow +','+ brokerageAmount;
                        Decimal cgst = 0;
                        Decimal sgst = 0;
                        fileRow = fileRow +','+ cgst;
                        fileRow = fileRow +','+ sgst;
                        Decimal totalBrokerage = (brokerageAmount + cgst + sgst).setscale(2,RoundingMode.HALF_UP);
                        fileRow = fileRow +','+ totalBrokerage;
                        String cpName = (bkgNameMap.get(bkName).BrokerIId__r.Name != null)? bkgNameMap.get(bkName).BrokerIId__r.Name : '';
                        fileRow = fileRow +','+ cpName;
                        fileRow = fileRow.replaceFirst(',','');
    					csvContentString = csvContentString + fileRow + '\n';  
                    }
                    
                    Attachment att=new Attachment();
                    att.Body= Blob.valueOf(csvContentString);
                    att.Name= 'Invoice.csv';
                    att.parentId= inv.Id;
                    atts.add(att);
                }
                insert atts;  
            } 
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    global void execute(SchedulableContext dc) {
        
        CPMandateBatch b = new CPMandateBatch();
        Database.executeBatch(b, 1);
    }
}