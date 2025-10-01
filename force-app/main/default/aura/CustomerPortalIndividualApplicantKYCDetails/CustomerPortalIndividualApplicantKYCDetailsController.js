({
	 uploadDocument :   function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files"); 
        var details ={};
        if(event.getSource().get("v.name") == 'PAN Card')
        component.set('v.applicantdetails.panCardDocumentId',uploadedFiles[0].documentId);
        if(event.getSource().get("v.name") == 'Aadhar Card')
        component.set('v.applicantdetails.aadharDocumentId',uploadedFiles[0].documentId);
        if(event.getSource().get("v.name") == 'Driving License')
        component.set('v.applicantdetails.drivingLicenseDocumentId',uploadedFiles[0].documentId);
        if(event.getSource().get("v.name") == 'Passport' && component.get("v.applicantdetails.residentialStatus")=='Indian National')
        component.set('v.applicantdetails.passportDocumentId',uploadedFiles[0].documentId);
        if(event.getSource().get("v.name") == 'Electricity Bill')
        component.set('v.applicantdetails.electricitybillDocumentId',uploadedFiles[0].documentId);
         if(event.getSource().get("v.name") == 'Voter’s ID Card')
        component.set('v.applicantdetails.voterIdDocumentId',uploadedFiles[0].documentId);
         if(event.getSource().get("v.name") == 'PIO card')
        component.set('v.applicantdetails.piocardDocumentId',uploadedFiles[0].documentId);
          if(event.getSource().get("v.name") == 'OCI card')
        component.set('v.applicantdetails.ocicardDocumentId',uploadedFiles[0].documentId);
         if(event.getSource().get("v.name") == 'Passport' && (component.get("v.applicantdetails.residentialStatus")=='Foreign Nationals Of Indian Origin' || component.get("v.applicantdetails.residentialStatus")=='For NRI'))
        component.set('v.applicantdetails.passportnodetails',uploadedFiles[0].documentId);
         if(event.getSource().get("v.name") == 'Self-attested copy of Pan Card of Authority Signatory')
          component.set('v.applicantdetails.panCardNumberofAuthoritySignatoryDocumentId',uploadedFiles[0].documentId);   
         
         
         
         details['documentId'] = uploadedFiles[0].documentId;
        details['applicantType'] = component.get("v.applicantdetails.applicantType");
        details['residentialStatus'] = component.get("v.applicantdetails.residentialStatus");
        details['documentType'] = event.getSource().get("v.name");
        details['oppRecId'] = component.get("v.applicantdetails.opportunityId");  
        details['bookingId'] = component.get("v.applicantdetails.bookingId");  
        details['applicantId'] = component.get("v.applicantdetails.applicantId"); 
        details['ApplicantNumber'] = component.get("v.applicantdetails.appNumber");
        details['uploadType'] = 'KYC';
        var action = component.get("c.insertDocumentData");  
        action.setParams({     
            "DocDetails": details 
        });  
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue(); 
                var appEvent = $A.get("e.c:CustomerPortalSessionEvent");
                //compEvent.setParams({"sessionstore" : component.get("v.RunwalHomeWrapList") });
                appEvent.fire();
                //component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action); 
	},
    
    previewfile :   function(component, event, helper) {
    $A.get('e.lightning:openFiles').fire({ 
                     recordIds: [event.getSource().get('v.name')]
                 }); 
    }
})