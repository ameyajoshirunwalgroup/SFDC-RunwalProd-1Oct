({
    // on load function helps to get the pick list values for project
    doInit: function(component, event, helper) { 
        var BookingRecordID = component.get("v.recordId"); 
        if(BookingRecordID == null)
        {
        	helper.fetchProjectNames(component);    
            helper.fetchlevellist(component , helper);
            helper.fetchTowerlist(component , helper);
            helper.fetchFacingTypelist(component , helper);
        }        
        if(BookingRecordID != null)
        {               
            helper.SelectedProjectName(component ,  BookingRecordID ,  helper);             
            helper.getCountInfo(component ,  BookingRecordID , helper);
            helper.getParkingType(component , BookingRecordID , helper);
            helper.SelectParkingType(component ,  BookingRecordID ,  helper);            
            helper.fetchCarParkingForBooking(component , BookingRecordID , helper);  
            helper.fetchlevellist(component , helper);
            helper.fetchTowerlist(component , helper);
            helper.fetchFacingTypelist(component , helper);
            
        }
    },
    
    
    // Based on project name selection , it fetches the tower names
    onProjectNamePicklistChange: function(component, event, helper) {
        helper.fetchTowerNames(component,event.getSource().get("v.value"),'projectId');
    },
    
    // Fetches car parking name 
    carParkingList: function(component, event ,helper) {
        var BookingRecordID = component.get("v.recordId");
        helper.fetchCarParkingList(component, BookingRecordID);
    },
    
    allotCarParking: function(component , event , helper){
        var allotmentID = event.getSource().get("v.value"); 
        var BookingID = component.get("v.recordId");        
        helper.allotCarParkingtoBooking(component , allotmentID , BookingID , helper); 
        helper.fetchCarParkingForBooking(component , BookingID , helper);  
        helper.getCountInfo(component ,  BookingID , helper);
        helper.getParkingType(component , BookingID , helper);
    },
    
     unallotBooking: function(component , event , helper){
        var allotmentID = event.getSource().get("v.value"); 
        var BookingID = component.get("v.recordId");        
        helper.unTagCarParking(component , allotmentID , BookingID , helper); 
        helper.fetchCarParkingForBooking(component , BookingID , helper);  
        helper.getCountInfo(component ,  BookingID , helper);
        helper.getParkingType(component , BookingID , helper);
    },
       

})