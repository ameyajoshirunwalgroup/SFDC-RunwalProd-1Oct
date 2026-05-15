public class PaymentDeviation {
    
    public static void calculateMilestoneDatesOnQuoteUpdate(List<Id> quoteIds){
        List<Id> bkgIds = new List<Id>();
        for(Booking__c bkg : [SELECT Id FROM Booking__c WHERE Quotation__c =: quoteIds]){
            bkgIds.add(bkg.Id);
        }
        if(bkgIds.size() > 0){
            milestoneDateCalculation(bkgIds);
        }
    }

    public static void milestoneDateCalculation(List<Id> bkgIds){
        if(bkgIds.size() > 0){
            List<Booking__c> bkgs = [SELECT Id,Quotation__c,Booking_Date__c FROM Booking__c WHERE Id =: bkgIds];
            List<Id> quoteIds = new List<Id>();
            for(Booking__c bkg : bkgs){
                quoteIds.add(bkg.Quotation__c);
            }
            List<Customer_Pay_Plan_Header__c> cpphList = [SELECT Id,Quotation__c FROM Customer_Pay_Plan_Header__c WHERE Quotation__c =: quoteIds AND Global_Charge_Name__c = 'Basic'];
            Map<Id,Id> quoteIdVsCpphId = new Map<Id,Id>();
            for(Customer_Pay_Plan_Header__c cpph : cpphList){
                quoteIdVsCpphId.put(cpph.Quotation__c, cpph.Id);
            }
            if(cpphList.size() > 0){
                List<Standard_Customer_Pay_Plan_Detail__c> scppdList = [SELECT Id,Amount_Value__c,Days_Months_Value__c,Customer_Pay_Plan_Header__c FROM Standard_Customer_Pay_Plan_Detail__c WHERE Customer_Pay_Plan_Header__c =: quoteIdVsCpphId.values() AND Is_to_be_Paid__c = 'From Dt. of Booking' ORDER By Days_Months_Value__c ASC];
                Map<Id,List<Standard_Customer_Pay_Plan_Detail__c>> cpphIdIdVsScppdList = new Map<Id,List<Standard_Customer_Pay_Plan_Detail__c>>();
                for(Standard_Customer_Pay_Plan_Detail__c scppd : scppdList){
                    if(cpphIdIdVsScppdList.get(scppd.Customer_Pay_Plan_Header__c) != null){
                        cpphIdIdVsScppdList.get(scppd.Customer_Pay_Plan_Header__c).add(scppd);
                    }else{
                        cpphIdIdVsScppdList.put(scppd.Customer_Pay_Plan_Header__c, new List<Standard_Customer_Pay_Plan_Detail__c>{scppd});
                    }
                }
                
                Map<Id,Standard_Customer_Pay_Plan_Detail__c> bkgIdVs5Perc = new Map<Id,Standard_Customer_Pay_Plan_Detail__c>();
                Map<Id,Standard_Customer_Pay_Plan_Detail__c> bkgIdVs9_9Perc = new Map<Id,Standard_Customer_Pay_Plan_Detail__c>();
                for(Booking__c bk : bkgs){
                    for(Standard_Customer_Pay_Plan_Detail__c scppd : cpphIdIdVsScppdList.get(quoteIdVsCpphId.get(bk.Quotation__c))){{
                        if(scppd.Amount_Value__c == 5){
                            bkgIdVs5Perc.put(bk.Id, scppd);
                        }else if(scppd.Amount_Value__c == 9.9){
                            bkgIdVs9_9Perc.put(bk.Id, scppd);
                        }
                    }
                }
                for(Booking__c bkg : bkgs){
                    
                    Date dateOf_9_9_Percent;
                    Date dateOf_5_Percent;
                    Decimal percentVal = 0;
                    /*if(bkgIdVs5Perc.get(bkg.Id) == null){
                        Decimal percentVal = 0;
                        for(Standard_Customer_Pay_Plan_Detail__c scppd : cpphIdIdVsScppdList.get(quoteIdVsCpphId.get(bkg.Quotation__c))){
                            System.debug('Amount_Value__c: ' + scppd.Amount_Value__c);
                            percentVal += scppd.Amount_Value__c;
                            if(percentVal >= 5 && dateOf_5_Percent == null){
                                dateOf_5_Percent = Date.valueOf(bkg.Booking_Date__c) + Integer.valueOf(scppd.Days_Months_Value__c);
                            }
                        }
                    }else{
                        dateOf_5_Percent = Date.valueOf(bkg.Booking_Date__c) + Integer.valueOf(bkgIdVs5Perc.get(bkg.Id).Days_Months_Value__c);
                    }
                    if(bkgIdVs9_9Perc.get(bkg.Id) == null){
                        Decimal percentVal = 0;
                        for(Standard_Customer_Pay_Plan_Detail__c scppd : cpphIdIdVsScppdList.get(quoteIdVsCpphId.get(bkg.Quotation__c))){
                            System.debug('Amount_Value__c: ' + scppd.Amount_Value__c);
                            percentVal += scppd.Amount_Value__c;
                            if(percentVal >= 9.9 && dateOf_9_9_Percent == null){
                                dateOf_9_9_Percent = Date.valueOf(bkg.Booking_Date__c) + Integer.valueOf(scppd.Days_Months_Value__c);
                            }
                        }
                    }else{
                        dateOf_9_9_Percent = Date.valueOf(bkg.Booking_Date__c) + Integer.valueOf(bkgIdVs9_9Perc.get(bkg.Id).Days_Months_Value__c);
                    }*/
                    for(Standard_Customer_Pay_Plan_Detail__c scppd : cpphIdIdVsScppdList.get(quoteIdVsCpphId.get(bkg.Quotation__c))){
                        System.debug('Amount_Value__c: ' + scppd.Amount_Value__c);
                        percentVal += scppd.Amount_Value__c;
                        if(percentVal >= 9.9 && dateOf_9_9_Percent == null){
                            dateOf_9_9_Percent = Date.valueOf(bkg.Booking_Date__c) + Integer.valueOf(scppd.Days_Months_Value__c);
                        }if(percentVal >= 5 && dateOf_5_Percent == null){
                            dateOf_5_Percent = Date.valueOf(bkg.Booking_Date__c) + Integer.valueOf(scppd.Days_Months_Value__c);
                        }
                    }
                    System.debug('dateOf_9_9_Percent: ' + dateOf_9_9_Percent);
                    System.debug('dateOf_5_Percent: ' + dateOf_5_Percent);
                    bkg.X5_Milestone_Date__c = dateOf_5_Percent;
                    bkg.X9_9_Milestone_Date__c = dateOf_9_9_Percent;
                }
                BookingTriggerHandler.byPass =true;
                update bkgs; 
                BookingTriggerHandler.byPass =false;
            }
        }
    }
    }
}