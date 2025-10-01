public class PaymentItemHandler {
    
    public static void paymentRollUps(set<Id> PaymentItemIds)
    {
        List<RW_Demand_Item__c> demandItemsToUpdate = new List<RW_Demand_Item__c>();
        system.debug(PaymentItemIds);
        if(PaymentItemIds.size() > 0){
            
            // create a field to calculate - total demand item amount recieved 
            demandItemsToUpdate = [Select id,RW_Demand_Item_Amount__c,RW_Legacy_Amount_Paid__c,RW_Legacy_Demand__c,Total_Demand_Item_Amount_Paid__c,(Select id,RW_Amount__c,RW_Payment_Details__r.RW_Status_Code__c from Payment_Detail_Items__r   ) from RW_Demand_Item__c where id IN : PaymentItemIds and RW_Stop_Receipt_Rollup__c = false];
        }
        system.debug('%%%%%%%%%%');
        system.debug(demandItemsToUpdate);
        for(RW_Demand_Item__c dem : demandItemsToUpdate){
            Decimal val = 0.00;
            for(RW_Payment_Detail_Item__c pdi : dem.Payment_Detail_Items__r){
                if(pdi.RW_Payment_Details__r.RW_Status_Code__c == null)
                    val += pdi.RW_Amount__c;
                
            }
            if(dem.RW_Legacy_Demand__c && dem.RW_Legacy_Amount_Paid__c != null){
                  dem.Total_Demand_Item_Amount_Paid__c = dem.RW_Legacy_Amount_Paid__c+ val;
                  dem.RW_Total_Demand_Item_Amount_Paid__c = dem.RW_Legacy_Amount_Paid__c+ val; // Added by coServe 24-10-2024 to match the 'Total Demand Item Amount Paid' with 'Calculated Total Demand Item Amount Paid'
            }else{
            	dem.Total_Demand_Item_Amount_Paid__c = val;
                dem.RW_Total_Demand_Item_Amount_Paid__c = val;// Added by coServe 24-10-2024 to match the 'Total Demand Item Amount Paid' with 'Calculated Total Demand Item Amount Paid'
            }
            system.debug(val);
        }
        update demandItemsToUpdate;
    }
    
    public static void reCalculateReceipt(set<Id> PaymentId)
    {
        // query payemnt item with payment details id (parent) 
        // make a list payement id 
        // create a set of payment ID & loop through the paymnet Ids and check demandItem
        
        set<Id> setIds = new set<Id>();
        set<Id> setDem = new set<Id>();
        
        List<RW_Payment_Details__c> payList = [select id, name, (select id, name ,RW_Demand_Item__c from Payment_Detail_Items__r ) from RW_Payment_Details__c where id In: PaymentId];
        
        for(RW_Payment_Details__c pd : payList)
        {
            // setIds.add(pd);
            
            /* if(paymentItem.RW_Demand_Item__c != null)
{
PaymentItemIds.add(paymentItem.RW_Demand_Item__c);  
}*/
            if(pd.Payment_Detail_Items__r.size()>0)
            {
                for(RW_Payment_Detail_Item__c pdi :pd.Payment_Detail_Items__r)
                {
                    if(pdi.RW_Demand_Item__c!=null)
                        setIds.add(pdi.RW_Demand_Item__c);
                }
                
            }   
        }
        
        //  List<RW_Payment_Detail_Item__c> listPayItem = [select id, name,(select id, name from Demand_Items__r) from RW_Payment_Detail_Item__c where id in: setIds];
        /*    List<RW_Payment_Detail_Item__c> listPayItem = [select id, name,RW_Demand_Item__c from RW_Payment_Detail_Item__c where id in: setIds];

for(RW_Payment_Detail_Item__c pi : listPayItem)
{
if(pi.RW_Demand_Item__c!=null)
{
setDem.add(pi.id);
}
}
*/        if(setIds.size()>0)
    paymentRollUps(setIds);
    }
    public static void recalculateDemanditem(set<id> dmids){
        List<RW_Demand_Item__c>             demandItemsToUpdate = [Select id,RW_Legacy_Demand__c,RW_Legacy_Amount_Paid__c,RW_Demand_Item_Amount__c,(Select id,RW_Amount__c,RW_Payment_Details__r.RW_Status_Code__c from Payment_Detail_Items__r ) from RW_Demand_Item__c where id IN : dmids and RW_Stop_Receipt_Rollup__c = false];
        for(RW_Demand_Item__c dem : demandItemsToUpdate){
            Decimal val = 0.00;
            for(RW_Payment_Detail_Item__c pdi : dem.Payment_Detail_Items__r){
                if(pdi.RW_Payment_Details__r.RW_Status_Code__c == null)
                    val += pdi.RW_Amount__c;
                
            }
            if(dem.RW_Legacy_Demand__c && dem.RW_Legacy_Amount_Paid__c != null){
                dem.Total_Demand_Item_Amount_Paid__c = dem.RW_Legacy_Amount_Paid__c+ val;
                dem.RW_Total_Demand_Item_Amount_Paid__c = dem.RW_Legacy_Amount_Paid__c+ val; // Added by coServe 24-10-2024 to match the 'Total Demand Item Amount Paid' with 'Calculated Total Demand Item Amount Paid'
            }else{
                dem.Total_Demand_Item_Amount_Paid__c = val;
                dem.RW_Total_Demand_Item_Amount_Paid__c = val;//Added by coServe 27-09-2023
            }
            	
            system.debug(val);}
        update demandItemsToUpdate;
        
    }
}