public class ScheduleP1toP4CategoryAutomation implements schedulable
{
    public void execute(SchedulableContext sc)
    {
     
        // Added by Prashant 20-03-2025
        //String currentYear = '2026';	
        String currentYear = String.valueOf(System.today().year());	
        list<String> segmentList = getSegmentPicklistValues();
        /*For(String segment : segmentList){
            BatchforP1toP4CategoryAutomation c1 = new BatchforP1toP4CategoryAutomation(segment,currentYear);
            database.executeBatch(c1,50);
        }*/
        BatchforP1toP4CategoryAutomation c1 = new BatchforP1toP4CategoryAutomation('7 Mahalaxmi',currentYear);
        database.executeBatch(c1,50);
        
        BatchforP1toP4CategoryAutomation c2 = new BatchforP1toP4CategoryAutomation('Runwal Pinnacle',currentYear);
        database.executeBatch(c2,50);
        
        BatchforP1toP4CategoryAutomation c3 = new BatchforP1toP4CategoryAutomation('Runwal Forests',currentYear);
        database.executeBatch(c3,50);
        
        BatchforP1toP4CategoryAutomation c4 = new BatchforP1toP4CategoryAutomation('Runwal City Center',currentYear);
        database.executeBatch(c4,50);
        
        BatchforP1toP4CategoryAutomation c5 = new BatchforP1toP4CategoryAutomation('Runwal Garden City',currentYear);
        database.executeBatch(c5,50);
        
        BatchforP1toP4CategoryAutomation c6 = new BatchforP1toP4CategoryAutomation('Garden Heights',currentYear);
        database.executeBatch(c6,50);
        
    }
       
    public static List<String> getSegmentPicklistValues() {
        List<String> picklistValues = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Project__c.Segment__c.getDescribe();
        
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry val : values) {
            //picklistValues.add(val.getLabel()); 
            picklistValues.add(val.getValue());
        }
        
        return picklistValues;
    }

}