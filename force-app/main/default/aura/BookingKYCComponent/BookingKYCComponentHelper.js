({
   
    getuploadedFiles:function(component,event){
        /*var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId":component.get("v.recordId")  
        });   */ 
        debugger;
         var action = component.get("c.getKYCFiles");  
        action.setParams({  
           "bookingId":component.get("v.bookingId"),"applicantNumber":component.get("v.applicantDetail.Applicant_Number__c")
        });  
        
 
        
        action.setCallback(this,function(response){  
            var columnArray =[];
            var urlcolumnArray ={};
            var columnObject ={fieldName: 'fileName', type: 'url'};
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue(); 

                   var disablePANupload;
                   var disableOtherDocumentupload;
                   var disablePassportUpload;
                var disablePhotoUpload;
                   
                component.set("v.data",result); 
                if(result.length ==0)
                {
                    if(component.get("v.bDisabledSubDependentFld"))
                    {
                    component.set("v.disablePANUpload", true);
                    component.set("v.disableOtherDocumentUpload", true); 
                           component.set("v.disablePhotoupload", true); 
                    component.set("v.Spinner", false);
                    }
                    else
                    {
                         component.set("v.disablePANUpload", false);
                        component.set("v.disablePassportUpload", false);
                                                   component.set("v.disablePhotoupload", false); 

                   //component.set("v.disableOtherDocumentUpload", false); 
                        component.set("v.Spinner", false);
                    }
                    
                    
                }
                else
                {debugger;
                 for(var i=0 ; i<component.get("v.data").length; i++)
                        {
                           if(component.get("v.data")[i].documentType == 'PAN Card') 
                           disablePANupload = 'true';
                   
                            if(component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'Indian National' && component.get("v.data")[i].documentType == component.get("v.applicantDetail.Address_Proof_Document__c") )
                                disableOtherDocumentupload ='true';
                            if(component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'Indian National' && (component.get("v.applicantDetail.Address_Proof_Document__c") == '' || component.get("v.applicantDetail.Address_Proof_Document__c") == undefined) )
                                disableOtherDocumentupload ='true';
                            if(component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'Foreign Nationals Of Indian Origin' && component.get("v.data")[i].documentType == component.get("v.applicantDetail.Type_Of_Origin__c") )
                                disableOtherDocumentupload ='true';
                              if(component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'Foreign Nationals Of Indian Origin' && (component.get("v.applicantDetail.Type_Of_Origin__c") == '' || component.get("v.applicantDetail.Type_Of_Origin__c") == undefined) )
                                disableOtherDocumentupload ='true';
                             if(component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'Foreign Nationals Of Indian Origin' && component.get("v.data")[i].documentType == 'Passport' )
                                disablePassportUpload ='true';
                             if((component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'For Company' || component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'Partnership Firm' ) && component.get("v.data")[i].documentType == 'Pan Card Number of Authority Signatory' )
                                disableOtherDocumentupload ='true';
                            if((component.get("v.applicantDetail.Subtype_Of_Applicant__c") == 'For NRI') && component.get("v.data")[i].documentType == 'Passport' )
                                disableOtherDocumentupload ='true';
                         debugger;
                            if( component.get("v.data")[i].documentType == 'Passport Size Photo' )
                                disablePhotoUpload ='true';
                        
                        
                        
                        }
                    
                 if(disablePhotoUpload){
                       component.set("v.disablePhotoupload", true); 
                 }else{
                                            component.set("v.disablePhotoupload", false); 

                 }
                    
                    if(disablePANupload == 'true' )
                    component.set("v.disablePANUpload", true); 
                    else
                    {
                        if(component.get("v.applicantDetail.PancardNo__c") == '' || component.get("v.applicantDetail.PancardNo__c") == undefined)
                        {
                            component.set("v.disablePANUpload", true); 
                        }
                        else
                        {
                    component.set("v.disablePANUpload", false);
                        }
                    }
                    
                     if(disablePassportUpload == 'true' || disablePassportUpload == undefined)
                    component.set("v.disablePassportUpload", true); 
                    else
                    component.set("v.disablePassportUpload", false);
                    
                    if(disableOtherDocumentupload == 'true' )
                         component.set("v.disableOtherDocumentUpload", true);                   
                    else
                    component.set("v.disableOtherDocumentUpload", false); 
                    
                    if(component.get("v.bDisabledSubDependentFld"))
                    {
                        component.set("v.disablePANUpload", true); 
                         component.set("v.disableOtherDocumentUpload", true);    
                    }
                    
                component.set("v.Spinner", false);
                }
            }  
        });  
        
        $A.enqueueAction(action);  
    },
    
    validatePANNumber : function(component,event) 
    {debugger;
		var format = '[A-Z]{5}[0-9]{4}[A-Z]{1}';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
        {debugger;
            
            if(event.getSource().get("v.value").length > 10)
            {
                return false;  
            }
            else
            {
                if(event.getSource().get("v.value").match(format))
                {  
                return true;
                }  
                
                else
                {
                  return false;  
                }
            }
        }
        
        else
        {
            return true;
        }
	},
    
    validateAadharNumber : function(component,event) 
    {
		//var format = '^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$';
        var format = '^[0-9]{12}$';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
        {
        if(event.getSource().get("v.value").match(format))
        {  
        return true;
        }  
        
        else
        {
          return false;  
        }
        }
        
        else
        {
            return true;
        }
	},
    
    validatePassportNumber: function(component,event) 
    {debugger;
		var format = '^[A-PR-WYa-pr-wy][1-9]\\d\\s?\\d{4}[1-9]$';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
        {
        if(event.getSource().get("v.value").match(format))
        {  
        return true;
        }  
        
        else
        {
          return false;  
        }
        }
        
        else
        {
            return true;
        }
	}
    
})