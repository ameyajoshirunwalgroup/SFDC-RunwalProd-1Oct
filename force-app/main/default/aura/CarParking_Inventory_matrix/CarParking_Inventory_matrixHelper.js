({
	/* Helps to fetch the project types and prepare list of selections */
    fetchProjectNames: function(component) {
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}
        
        var action = component.get("c.getProjectList");
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--None--",
                        value: ""
                    });
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({                           
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                }
                component.set("v.projectList", opts);
               
                if(spinner) {
                    $A.util.removeClass(spinner,"slds-show");
                    $A.util.addClass(spinner, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    /* Helps to fetch the tower name */
    fetchTowerNames: function(component) {         
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
           var projectId = component.find('projectId').get('v.value');
            var action = component.get("c.getTowerList");
            action.setParams({
                "projectName": projectId
            });
            var opts = [];
            action.setCallback(this, function(response) {
               
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue();                    
                    if (allValues != undefined && allValues.length > 0) {
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    }
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.towerList",opts);
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
            
        
    },
    
    /* Helps to fetch the details of car parking information */
    fetchCarParkingList: function(component, elementId) { 
		   
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		}
       
          
            var action = component.get("c.getCarParking");
            var level = component.find('level').get('v.value');
        	var parkingtype = component.find('parkingtype').get('v.value');
        	var status = component.find('status').get('v.value');
        	var facingtype = component.find('facingtype').get('v.value');
            var projectId = component.find('projectId').get('v.value');
        	var towerName = component.find('towerName').get('v.value');
            var elementsShow = document.getElementsByClassName("showhide");
            var nomessage = document.getElementsByClassName("nomessage");
            if(projectId == '--None--' || projectId == 'undefined')
            {   
                projectId = '';
            }
        	if(parkingtype == '--None--')
            {
                parkingtype = '';
            }
            if(facingtype == '--None--')
            {
                facingtype = '';
            }
        	if(towerName == '--None--')
            {
                towerName = '';
            }
            if(status == '--None--')
            {
                status = '';
            }
            if(level == '--None--')
            {
                level = '';
            }
            
            action.setParams({
                "projectname": projectId ,                
                "level":level,
                "parkingtype":parkingtype,
                "status" : status,
                "facingtype" : facingtype,
                "towerName": towerName,
                "bookingid" : elementId
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 
                    if (allValues != undefined && allValues.length > 0) {
                        component.set("v.carparkingList",allValues);
                        elementsShow[0].style.display = '';
                        nomessage[0].style.display = 'none';
                    }
                    else{
                        elementsShow[0].style.display = 'none';
                        nomessage[0].style.display = '';
                    }
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
            
        
    },
    
     /* Helps to fetch the details of car parking information for booking*/
    fetchCarParkingForBooking: function(component, elementId) { 
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getCarParkingforBooking");
            var projectId = component.find('projectId').get('v.value');            
            var elementsShow1 = document.getElementsByClassName("showhide");
            var nomessage1 = document.getElementsByClassName("nomessage");            
            action.setParams({
                "projectId": projectId , 
                 "bookingid" : elementId,
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue();                     
                    if (allValues != undefined && allValues.length > 0 && allValues != '') {
                        component.set("v.carparkingList",allValues);   
                      //  alert(JSON.stringify(allValues));
                    }
                    else{
                        alert('No carking assigned for this booking');
                        $A.get("e.force:closeQuickAction").fire() 
                        
                    }
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
            
        
    },
   
    allotCarParkingtoBooking:function(component , elementId , BookingID){         
        var spinner = component.find("mySpinner");
        if(spinner){
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
        }        
         var action = component.get("c.updateCarParkingAllotment");
            action.setParams({
                "BookingId" : BookingID ,
                "carAllotmentId": elementId
            });
            action.setCallback(this, function(response) {
               // alert(response.getState());
                if (response.getState() == "SUCCESS") {                      
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Car parking allotted." 
                        });
                        toastEvent.fire();
                    }
                    return true;
                   
            }
            
        });
    	$A.enqueueAction(action);
    },    
    
  /*  getCountInfo: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getCountDetails");
        	            
            action.setParams({
                "bookingid": elementId 
            });
            action.setCallback(this, function(response) {
                var custs=[];
                var state=response.getState();  
                var conts=response.getReturnValue();
                
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue();                     
                    if (allValues != undefined && allValues != '') {
                        component.set('v.map1',response.getReturnValue()); 
                        //component.set("v.countAllot",allValues);                        
                    }
                    
                    
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
                
                for(var key in conts )
                	{     
                   		custs.push({value:conts[key], key:key});   // Pushing keys in array
                	}
                    component.set('v.list1',custs);
            });
            $A.enqueueAction(action);
    },    */
    
    getParkingType: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getCarChargePartkingType");
        	            
            action.setParams({
                "bookingid": elementId 
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 					
                    if (allValues != undefined && allValues != '') {                    
                    component.set("v.parkingtypelist",allValues);  
                    }
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
    SelectParkingType: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.SelectedParkingType");
            action.setParams({
                "bookingid": elementId 
            });
        	var opts = [];
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 					
                    if (allValues != undefined && allValues != '') {
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    } 
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.selectParkingtype",opts);  
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
    
    
    unTagCarParking:function(component , allotmentID , BookingID ){ 
        
        var spinner = component.find("mySpinner");
        if(spinner){
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
        }        
         var action = component.get("c.unAllotParking");
            action.setParams({
                "BookingId" : BookingID ,
                "carAllotmentId": allotmentID
            });        	
            action.setCallback(this, function(response) {               
                if (response.getState() == "SUCCESS") {                      
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Car parking unallotted." 
                        });
                        toastEvent.fire();
                    }                                     
            }            
        });
    	$A.enqueueAction(action);
    },   
    
    fetchTowerlist: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getTowerlist");
        	var opts = [];
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 	
                    
                    if (allValues != undefined && allValues != '') {
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    } 
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.towerList",opts);  
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    fetchlevellist: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getLevellist");
        	var opts = [];
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 					
                    if (allValues != undefined && allValues != '') {
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    } 
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.levelList",opts);  
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
    fetchFacingTypelist: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getFacingTypelist");
        	var opts = [];
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 					
                    if (allValues != undefined && allValues != '') {
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    } 
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.FacingtypeList",opts);  
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
    SelectedProjectName: function(component , BookingRecordID){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getProjectName");
            action.setParams({
                "bookingid": BookingRecordID 
            });
        	var opts = [];
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue(); 					
                    if (allValues != undefined && allValues != '') {
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    } 
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }
                    component.set("v.projectList",opts);  
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
    getCountInfo: function(component , elementId){
        var spinner = component.find("mySpinner");
        if(spinner) {
            $A.util.removeClass(spinner,"slds-hide");
            $A.util.addClass(spinner, "slds-show");
		} 
            var action = component.get("c.getCountDetails");
        	            
            action.setParams({
                "bookingid": elementId 
            });
            action.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    var allValues = response.getReturnValue();                     
                    if (allValues != undefined && allValues != '') {
                       
                        component.set("v.countAllot",allValues);                        
                    }
                    else{
                        alert('All charge Alloted');
                        
                    }
                    if(spinner) {
                        $A.util.removeClass(spinner,"slds-show");
                        $A.util.addClass(spinner, "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
    },
    
})