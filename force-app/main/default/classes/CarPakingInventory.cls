public with sharing class CarPakingInventory{
    // Function to fetch Project
    @AuraEnabled
    public static List <String> getProjectList(){
        List <String> projectNameList= new List <String>();
        list<Project__c> masterDataList = [select id,Name from Project__c];
        for(Project__c md : masterDataList) {
            projectNameList.add(md.Name);
        }
        return projectNameList;
    }
    
    
    @AuraEnabled
    public static List <String> getTowerList(String projectName){
        List <String> towerNamesList= new List <String>();
        list<Tower__c> masterDataList = [select Name from Tower__c where ProjectName__r.Name=:projectName];
        for(Tower__c md : masterDataList) {
            towerNamesList.add(md.Name);
        }
        return towerNamesList;
    }
        
    @AuraEnabled
    public static List<Car_Parking_Allotment__c> getCarParking(string projectname, string level, string parkingtype, string status, string facingtype, string towerName, string bookingid){
     	String strAND = 'AND';
        String strSOQL = 'select Name,Parking_type__c,Status__c,Facing_Type__c,Booking__r.id,Id , Tower_Name__c , Booking__r.Customer__r.Name ,  Booking__r.Unit_No__r.RW_Param4__c  from Car_Parking_Allotment__c ';               
        String strWhere = 'Where';
        if(projectname != '' || towerName != '' || level != '' || parkingtype != '' || status != '' || facingtype != ''){
            strSOQL += strWhere + ' ' ;
        }
        if(projectname != ''){
            strSOQL += 'ProjectName__r.Name = \''+String.escapeSingleQuotes(projectname.trim())+'\''; 
            system.debug(strSOQL);
        }
        if(towerName != ''){
            strSOQL += 'AND Tower_Name__c = \''+String.escapeSingleQuotes(towerName.trim())+'\'';  
            system.debug(strSOQL);
        }
        if(level != '')   {
            strSOQL += 'AND level__c = \''+String.escapeSingleQuotes(level.trim())+'\'';  
            system.debug(strSOQL);
        }
        if(parkingtype != '')   {
            strSOQL += 'AND Parking_Type__c = \''+String.escapeSingleQuotes(parkingtype.trim())+'\'';  
            system.debug(strSOQL);
        }
        if(status != '')   {
            strSOQL += 'AND Status__c = \''+String.escapeSingleQuotes(status.trim())+'\''; 
            system.debug(strSOQL);
        }
        if(facingtype != '')   {
            strSOQL += 'AND Facing_Type__c = \''+String.escapeSingleQuotes(facingtype.trim())+'\'';
            system.debug(strSOQL);
        }
        if(bookingid != null && parkingtype == '')   {
            /* List<Car_Parking_Charge__c> chargeParkingTypeList = [select parking__c from Car_Parking_Charge__c Where Booking__r.id =: bookingid] ;
string[] stringList = new String[0];
for(Car_Parking_Charge__c item: chargeParkingTypeList) {
stringList.add(String.valueOf(item.parking__c));
} 
strSOQL += 'AND Parking_Type__c in \''+stringList+'\'';  
system.debug(strSOQL); */
        }
        List<Car_Parking_Allotment__c> carParkingList = Database.query(strSOQL);
        return carParkingList;
    }
       
    
    @AuraEnabled
    public static List<Car_Parking_Allotment__c> getCarParkingforBooking(string projectId , string bookingid)    {
        
        List<Car_Parking_Charge__c> chargeParkingTypeList = [select id,status__c,parking__c from Car_Parking_Charge__c Where Booking__r.id =: bookingid] ;
        
        Booking__c bookinginfo = [select Project__r.Name from Booking__c Where id =: bookingid limit 1];
        string project = bookinginfo.Project__r.Name;    
        string[] stringList = new String[0];
		for(Car_Parking_Charge__c item: chargeParkingTypeList) {
    		stringList.add(String.valueOf(item.parking__c));
		}    
        
        List<Car_Parking_Allotment__c> carParkingList = [select Name,Parking_type__c,Status__c,Facing_Type__c,Booking__r.id,Id,Tower_Name__c,Booking__r.Customer__r.Name,Booking__r.Unit_No__r.RW_Param4__c from Car_Parking_Allotment__c 
                                                        Where Parking_Type__c IN: (stringList) AND ProjectName__r.Name =: project]; //: projectname ORDER BY Name];
                
        return carParkingList;
    }
    
    @AuraEnabled
    public static List<Integer> getCountDetails(string bookingid){
        integer totalCount = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid];
        integer bookedCount = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Status__c = 'Booked'];
        integer vacantCount = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Status__c = 'Vacant'];
        
        integer tandamOpen = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Tandem Open'];
        integer tandemCovered = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Tandem Covered'];
        integer Stilt = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Stilt'];
        integer SingleOpen = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Single Open'];
        integer SingleCovered = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Single Covered'];
        integer MLCP = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'MLCP'];
        integer Podium = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Podium'];
        integer PuzzleCarPark = [select Count() from Car_Parking_Charge__c Where Booking__r.id =:bookingid and Car_Parking_Allotment__c = '' AND parking__c = 'Puzzle Car Park']; //Added by Vinay 28-03-2025
        
        List<Integer> CountParkingTypeInfo = new List<Integer>();
        CountParkingTypeInfo.add(tandamOpen);
        CountParkingTypeInfo.add(tandemCovered);
        CountParkingTypeInfo.add(Stilt);
        CountParkingTypeInfo.add(SingleOpen);
        CountParkingTypeInfo.add(SingleCovered);
        CountParkingTypeInfo.add(Podium);
        CountParkingTypeInfo.add(PuzzleCarPark); //Added by Vinay 28-03-2025
        
        List<AggregateResult> lstCount = [SELECT parking__c parkingname,count(id)parkingcount FROM Car_Parking_Charge__c WHERE Booking__r.id =:bookingid GROUP BY parking__c ];
        
        Map<String,Integer> mapParkingCount = new Map<String,Integer>();
		for(AggregateResult aggResult : lstCount){
 			 mapParkingCount.put((String)aggResult.get('parkingname'), (Integer)aggResult.get('parkingcount'));
		}
               
        List<Integer> CountInfo = new List<Integer>();
        CountInfo.add(totalCount);
        CountInfo.add(bookedCount);
        CountInfo.add(vacantCount);
        
        return CountParkingTypeInfo;
    }
    
    @AuraEnabled
    public static List<Car_Parking_Charge__c> getCarChargePartkingType(string bookingid){
        List<Car_Parking_Charge__c> chargeParkingType = [select parking__c,  Status__c , Car_Parking_Allotment__c from Car_Parking_Charge__c Where Booking__r.id =: bookingid] ;
        return chargeParkingType;
    }
    
    @AuraEnabled 
    public static void updateCarParkingAllotment(string BookingId , string carAllotmentId){
        Car_Parking_Allotment__c carAllotmentRecordUpdate = [select Name , Booking__c, Status__c , parking_type__c, id, Permanent_Allocation_date__c from Car_Parking_Allotment__c Where id =:carAllotmentId limit 1];        
        string parkingtype = carAllotmentRecordUpdate.parking_type__c;        
        carAllotmentRecordUpdate.Booking__c = BookingId;
        carAllotmentRecordUpdate.Status__c = 'Booked';   
        carAllotmentRecordUpdate.Permanent_Allocation_date__c = system.today();
        update carAllotmentRecordUpdate;        
        Car_Parking_Charge__c carParkChargeRecordUpdate = [select Car_Parking_Allotment__c ,  Status__c from Car_Parking_Charge__c Where Booking__r.id =: BookingId 
                                                          //AND Status__c = 'Vacant'
                                                          AND Car_Parking_Allotment__c = '' AND parking__c =: parkingtype  limit 1] ;
        carParkChargeRecordUpdate.Car_Parking_Allotment__c = carAllotmentId;
        //carParkChargeRecordUpdate.Status__c = 'Booked';
        update carParkChargeRecordUpdate;
    }
   
    @AuraEnabled 
    public static void unAllotParking(string BookingId , string carAllotmentId){
        
                
        Car_Parking_Allotment__c carAllotmentRecordUpdate = [select Name , Booking__c, Status__c ,  id from Car_Parking_Allotment__c Where id =:carAllotmentId limit 1];  
                               
        carAllotmentRecordUpdate.Booking__c = null;
        carAllotmentRecordUpdate.Status__c = 'Available';        
        update carAllotmentRecordUpdate;   
        
        Car_Parking_Charge__c carParkChargeRecordUpdate = [select Car_Parking_Allotment__c ,  Status__c from Car_Parking_Charge__c Where Booking__r.id =: BookingId AND Car_Parking_Allotment__c =:  carAllotmentId];
        
        carParkChargeRecordUpdate.Car_Parking_Allotment__c = null;
        //carParkChargeRecordUpdate.Status__c = 'Vacant';
        update carParkChargeRecordUpdate;
        
    }
    
    @AuraEnabled
    public static List<String> SelectedParkingType(string bookingid) {
        List <String> selectedParkingtype= new List <String>();
        list<Car_Parking_Charge__c> masterDataList = [select parking__c from Car_Parking_Charge__c Where Booking__r.id =: bookingid];        
        for(Car_Parking_Charge__c md : masterDataList) {
            selectedParkingtype.add(md.parking__c);
        }
        return selectedParkingtype;
    }
    
    @AuraEnabled
    public static List<String> getProjectName(string bookingid) {
        List <String> selectedProject= new List <String>();
        list<Booking__c> masterDataList = [select Project__r.Name from Booking__c Where id =: bookingid];        
        for(Booking__c md : masterDataList) {
            selectedProject.add(md.Project__r.Name);
        }       
        return selectedProject;
    }
    
    @AuraEnabled
    public static List<String> getTowerlist(){
        List<Car_Parking_Allotment__c> lstTower= [select Tower_Name__c from Car_Parking_Allotment__c];
 		Set<String> setTower=new Set<String>();
		for(Car_Parking_Allotment__c c:lstTower){
    	setTower.add(c.Tower_Name__c);
		}
        List<String> towerlist = new List<String>(setTower);
		return towerlist;
    }
    
    @AuraEnabled
    public static List<String> getLevellist(){
        List<Car_Parking_Allotment__c> lstLevel= [select level__c from Car_Parking_Allotment__c];
 		Set<String> setlevel=new Set<String>();
		for(Car_Parking_Allotment__c c:lstLevel){
    	setlevel.add(c.level__c);
		}
        List<String> levelList = new List<String>(setlevel);
		return levelList;
    }
    
    @AuraEnabled
    public static List<String> getFacingTypelist(){
        List<Car_Parking_Allotment__c> lstFacingType= [select Facing_Type__c from Car_Parking_Allotment__c];
 		Set<String> setFacingType=new Set<String>();
		for(Car_Parking_Allotment__c c:lstFacingType){
    	setFacingType.add(c.Facing_Type__c);
		}
        List<String> levelFacingType = new List<String>(setFacingType);
		return levelFacingType;
    }
    
    
    
}