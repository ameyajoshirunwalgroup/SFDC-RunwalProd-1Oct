({
     doInit : function( component, event, helper ) {  
         //component.set("v.applicantdetailsCopy",component.get('v.applicantdetails'));
          component.set("v.existingfirstName",component.get("v.applicantdetails.firstName") );
         component.set("v.existinglastName",component.get("v.applicantdetails.lastName") );
          component.set("v.existingemail",component.get("v.applicantdetails.email") );
          component.set("v.existingmobile",component.get("v.applicantdetails.mobile") );
          component.set("v.existingcompany",component.get("v.applicantdetails.companyname") );
          component.set("v.existingaddress",component.get("v.applicantdetails.address") );
     },
    
	       closeModal: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    openApplicantDetails: function(component, event, helper) 
    {
    	component.set("v.isOpen", true);
        component.set("v.complaintRecord.Description",'');
	},
    
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.isOpen", false);
        
    },
    
    onsubmit:  function(component, event, helper) 
    {
        var datachanged = false;
        var descriptiondata ='';
        var counter=1;
        if(component.get("v.existingfirstName") != component.get("v.applicantdetails.firstName"))
           {
              datachanged = true;
              descriptiondata = descriptiondata+ counter++ +') First Name Change from '+component.get("v.existingfirstName")+' to '+component.get("v.applicantdetails.firstName")+'\n';
           }
    	if(component.get("v.existinglastName") != component.get("v.applicantdetails.lastName"))
           {
              datachanged = true;
              descriptiondata = descriptiondata+ counter++ +') Last Name Change from '+component.get("v.existinglastName")+' to '+component.get("v.applicantdetails.lastName")+'\n';
           }
 		if(component.get("v.existingemail") != component.get("v.applicantdetails.email"))
           {
              datachanged = true;
              descriptiondata = descriptiondata+ counter++ +') Email Change from '+component.get("v.existingemail")+' to '+component.get("v.applicantdetails.email")+'\n';
           }

		if(component.get("v.existingmobile") != component.get("v.applicantdetails.mobile"))
           {
              datachanged = true;
              descriptiondata = descriptiondata+ counter++ +') Phone Number Change from '+component.get("v.existingmobile")+' to '+component.get("v.applicantdetails.mobile")+'\n';
           }
		if(component.get("v.existingcompany") != component.get("v.applicantdetails.companyname"))
           {
              datachanged = true;
              descriptiondata = descriptiondata+ counter++ +') Company Name Change from '+component.get("v.existingcompany")+' to '+component.get("v.applicantdetails.companyname")+'\n';
           }
        if(component.get("v.existingaddress") != component.get("v.applicantdetails.address"))
           {
              datachanged = true;
              descriptiondata = descriptiondata+ counter++ +') Address Change from '+component.get("v.existingaddress")+' to '+component.get("v.applicantdetails.address")+'\n';
           }

                                                      
         if(datachanged)  
         {
        var details ={};
        details['bookingName'] = component.get("v.applicantdetails.bookingName");  
        details['applicantNumber'] = component.get("v.applicantdetails.appNumber"); 
        details['unitnumber'] = component.get("v.applicantdetails.unitNumber"); 
        details['projectId'] = component.get("v.applicantdetails.ProjectId");
        details['bookingId'] = component.get("v.applicantdetails.bookingId");
        details['description'] = descriptiondata;
        component.set("v.Spinner",true);
    	var action = component.get("c.insertChangeRequestCase");
        action.setParams({newCase:component.get("v.complaintRecord"),"Details": details });
        	action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Request is created successfully. Relationship Manager will check and revert"});
                        toastEvent.fire();
                        component.set("v.isOpen", false);
                         component.set("v.Spinner",false);
                    }
            });

		$A.enqueueAction(action);
         }
else
{
     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "type":"error",
                            "message": "Please change at least one value to submit"});
                        toastEvent.fire();
    return;
}
                       
	}
})