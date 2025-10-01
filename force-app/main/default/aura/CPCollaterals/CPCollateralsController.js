({
    doInit : function(component, event, helper) {
        helper.getcollA(component); 
        //helper.getcollB(component); 
        
    },
	onPictureClick: function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:onPictureClick");
        var selectedRecord = event.currentTarget;
        var propId =  selectedRecord.getAttribute("id");
        console.log('get propId:::'+propId);
        alert("Image will be Download Please click on OK"); 
        
        
    }
    
})