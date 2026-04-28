@isTest
public class CurrentPreviousMilestoneUpdateOnBkgTest {
    
    @isTest
    private static void milestoneUpdateTest(){
        Booking__c bkg = new Booking__c();
        bkg.Lockated_User_Device_ID__c = '123';
        bkg.RW_Booking_Confirmed_Date__c = Date.today() - 2;
        bkg.RW_Total_Receipt_Amount_Received__c = 60000;
        bkg.Allotment_Premium__c = 1000000;
        bkg.GST_Percent__c = 5;
        bkg.RW_Total_TDS_Outstanding__c = 20000;
        insert bkg;
        
        RW_Demand__c dem1 = new RW_Demand__c();
        dem1.Booking__c = bkg.Id;
        dem1.RW_Demand_Status__c = 'Due';
        insert dem1;
        
        RW_Demand__c dem2 = new RW_Demand__c();
        dem2.Booking__c = bkg.Id;
        dem2.RW_Demand_Status__c = 'Due';
        insert dem2;
            
        RW_Demand_Item__c demItem = new RW_Demand_Item__c();
        demItem.RW_Demand__c = dem1.Id;
        demItem.RW_Demand_Item_Amount__c = 10000;
        demItem.RW_GST_Amount__c = 0;
        insert demItem;
        
        CurrentPreviousMilestoneUpdateOnBooking.updateMilestoneDetails(bkg.Id);
        CurrentPreviousMilestoneUpdateOnBooking.updateMilestones(new List<Id>{bkg.Id});
    }

}