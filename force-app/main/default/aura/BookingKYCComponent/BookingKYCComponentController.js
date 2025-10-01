({
    doInit : function(component, event, helper) { 
        console.log('bookingId'+component.get("v.bookingId"));
        var residential = component.get("v.applicantDetail.Type_Of_Applicant__c");
        var subtype = component.get("v.applicantDetail.Subtype_Of_Applicant__c");
        var residentialMap = component.get("v.ResidentialPicklist");
        if(component.get("v.applicantDetail.Applicant_Number__c") == 'Primary Applicant'){
                    component.set("v.primaryApplicant",true );

        }
        if(residential == 'Individual Buyer'){
            if(subtype == 'Indian National' && component.get("v.applicantDetail.Address_Proof_Document__c") != '' && component.get("v.applicantDetail.Address_Proof_Document__c") != null && component.get("v.applicantDetail.Address_Proof_Document__c") != undefined)
            {      
                component.set("v.documentType",component.get("v.applicantDetail.Address_Proof_Document__c") );
            }else if(subtype =='Foreign Nationals Of Indian Origin' && component.get("v.applicantDetail.Type_Of_Origin__c")!= '' &&component.get("v.applicantDetail.Type_Of_Origin__c") != null && component.get("v.applicantDetail.Type_Of_Origin__c") != undefined)
            {   component.set("v.documentType",component.get("v.applicantDetail.Type_Of_Origin__c") );                                                                
                    
                }else if(subtype=='For NRI'&& component.get("v.applicantDetail.PassportNoDetails__c") != null && component.get("v.applicantDetail.PassportNoDetails__c") != '' && component.get("v.applicantDetail.PassportNoDetails__c") != undefined)
                {
                                    component.set("v.documentType",'Passport' );                                                             

                }        
        }
        debugger;
        if(residential != null){
            component.set("v.ResidentialPicklistOptions",residentialMap.pickListMap[residential]);
        } 
        
        if(component.get("v.applicantDetail.Type_Of_Applicant__c") !='' && component.get("v.applicantDetail.Type_Of_Applicant__c") != undefined)
            component.set("v.bDisabledDependentFld",false);
        
        if(component.get("v.applicantDetail.Subtype_Of_Applicant__c") !='' && component.get("v.applicantDetail.Subtype_Of_Applicant__c") != undefined)
        {debugger;
         component.set("v.bDisabledSubDependentFld",false);
         if( component.get("v.applicantDetail.PassportNoDetails__c") != '' && component.get("v.applicantDetail.PassportNoDetails__c") != undefined && ! component.get("v.applicantDetail.PassportNumber__c")	)
             
         {
             component.set("v.disablePassportUpload",false);
         }
         else
         {
             component.set("v.disablePassportUpload",true);
         }
         if(component.get("v.applicantDetail.Pancard__c")&& component.get("v.applicantDetail.PancardNo__c") != '' && component.get("v.applicantDetail.PancardNo__c") != undefined)
             
         {
             component.set("v.disablePANUpload",false);
         }
         else
         {
             component.set("v.disablePANUpload",true);
         }
         
         if( component.get("v.applicantDetail.Address_Proof__c") &&component.get("v.applicantDetail.Address_Proof_Document__c") != '' && component.get("v.applicantDetail.Address_Proof_Document__c") != undefined)
             
         {
             component.set("v.disableOtherDocumentUpload",false);
         }
         else
         {
             component.set("v.disableOtherDocumentUpload",true);
         }
         
         
        }
        debugger;
        if(component.get("v.applicantDetail.Type_Of_Applicant__c") =='Individual Buyer' && !component.get("v.applicantDetail.One_Passport_Size_Color_Photograph__c")){
         component.set("v.disablePhotoupload",false);

           }
        var device = $A.get("$Browser.formFactor");
        var width;
        if(device == 'PHONE')
        {
            width = 100;
        }
        
        else
        {
            width = 100;
        }
        var readonly = component.get("v.readonly");
        if(!readonly){
            component.set('v.columns', [
                
                {type: 'button',initialWidth: width, typeAttributes: { label: 'Preview' }},
                {type: 'button',initialWidth: width, typeAttributes: { label: 'Remove' }},
                //{label:'Document', fieldName: 'fileName', type: 'text'},
                {label: 'Document Type', fieldName: 'documentType', type: 'text'},
                
                
                
            ]);
                }else{
                component.set('v.columns', [
                
                {type: 'button',initialWidth: width, typeAttributes: { label: 'Preview' }},
                //{label:'Document', fieldName: 'fileName', type: 'text'},
                {label: 'Document Type', fieldName: 'documentType', type: 'text'},
                
                
                
            ]);
        }
        component.set("v.encryptedToken",component.get("v.recordId")+'|'+'8889');
        helper.getuploadedFiles(component,event);
        
    },
    
    onControllerFieldChange: function(component, event, helper) { 
        debugger;
        component.set("v.applicantDetail.Subtype_Of_Applicant__c",'');
        component.set("v.applicantDetail.Type_Of_Origin__c","");
        component.set("v.applicantDetail.Address_Proof_Document__c","");
        component.set("v.applicantDetail.Address_Proof_Number__c","");
        component.set("v.applicantDetail.Origin_Details__c","");
        component.set("v.applicantDetail.Pan_Card_Number_of_Authority_Signatory__c","");
        component.set("v.applicantDetail.PassportNoDetails__c","");
        component.set("v.applicantDetail.PancardNo__c","");
        component.set("v.disableOtherDocumentUpload", true);
        
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        component.set("v.disablePANUpload",true);
        
        var residential = component.get("v.applicantDetail.Type_Of_Applicant__c");
        
        var depnedentFieldMap = component.get("v.ResidentialPicklist");
        
        if (residential != '') {
            // disable and reset sub dependent field 
            
            
            var ListOfDependentFields = depnedentFieldMap.pickListMap[residential];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  		
                component.set("v.ResidentialPicklistOptions", ListOfDependentFields);
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.ResidentialPicklistOptions", '');
            }  
            
        } else {
            component.set("v.bDisabledDependentFld" , true);
            
        }
        
        component.set("v.bDisabledSubDependentFld" , true); 
    },
    
    
    onSubControllerFieldChange : function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected sub controller field value
        component.set("v.applicantDetail.Type_Of_Origin__c","");
        component.set("v.applicantDetail.Address_Proof_Document__c	","");
        component.set("v.applicantDetail.Address_Proof_Number__c","");
        component.set("v.applicantDetail.Origin_Details__c","");
        component.set("v.applicantDetail.Pan_Card_Number_of_Authority_Signatory__c","");
        component.set("v.applicantDetail.PassportNoDetails__c","");
        component.set("v.applicantDetail.PancardNo__c","");
        component.set("v.disableOtherDocumentUpload", true); 
        
        //component.find("DocumentDetails").set("v.disabled",true);
        // component.find("OriginDetails").set("v.disabled",true);
        
        if(controllerValueKey == '')
        {
            component.set("v.applicantDetail.Subtype_Of_Applicant__c",'');
            component.set("v.disableOtherDocumentUpload", true); 
            component.set("v.disablePANUpload",true);
            component.set("v.disablePassportUpload",true);
                        component.set("v.disablePhotoupload",true);

            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": false , "errorMessage":"Please select Residential Status under KYC section." });
            compEvent.fire();
        }
        else
        {
            component.set("v.bDisabledSubDependentFld",false);
            var disablePANupload;
            var disablePassportUpload;
            var disablePhotoUpload;
            for(var i=0 ; i<component.get("v.data").length; i++)
            {
                if(component.get("v.data")[i].documentType == 'PAN Card') 
                    disablePANupload = 'true';
                  if(component.get("v.data")[i].documentType == 'Passport Size Photo') 
                    disablePhotoUpload = 'true';
            }
            if(disablePhotoUpload){
                  component.set("v.disablePhotoupload", true); 
            }else{
                                  component.set("v.disablePhotoupload", false); 

            }
            if(disablePANupload == 'true')
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
            
            for(var i=0 ; i<component.get("v.data").length; i++)
            {
                if(component.get("v.data")[i].documentType == 'Passport') 
                    disablePassportUpload = 'true';
            }
            
            if(disablePassportUpload == 'true' || disablePassportUpload == undefined)
                component.set("v.disablePassportUpload", true); 
            else
            {
                // if(component.find("Passport Number").get("v.value") == '')
                //     component.set("v.disablePassportUpload", true);
                // else
                component.set("v.disablePassportUpload", false);
                
            }
            
            component.set("v.applicantDetail.Subtype_Of_Applicant__c",controllerValueKey); 
            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": true  });
            compEvent.fire();
        }
        
        
        
    },
    
    
    uploadDocument:   function(component, event, helper) {  
        debugger;
        var uploadedFiles = event.getParam("files"); 
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['applicantType'] = component.get("v.applicantDetail.Type_Of_Applicant__c");
        details['residentialStatus'] = component.get("v.applicantDetail.Subtype_Of_Applicant__c");
        details['documentType'] = event.getSource().get("v.name");
        details['ApplicantNumber'] = component.get("v.applicantDetail.Applicant_Number__c");
        //details['documentNumber'] = component.find(event.getSource().get("v.name")).get("v.value");
        details['bookingId'] = component.get("v.bookingId");   
            details['oppId'] = component.get("v.oppId");   
        var action = component.get("c.insertDocumentData");  
        action.setParams({     
            "DocDetails": details 
        });  
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                //component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action); 
        
        helper.getuploadedFiles(component,event);  
        
    },
    
    uploadOtherDocument :   function(component, event, helper) {  
        debugger;
        var uploadedFiles = event.getParam("files"); 
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['applicantType'] = component.get("v.applicantDetail.Type_Of_Applicant__c");
        details['residentialStatus'] = component.get("v.applicantDetail.Subtype_Of_Applicant__c");
        details['documentType'] = component.get("v.documentType");
        //details['documentNumber'] = component.find(event.getSource().get("v.name")).get("v.value");
        details['bookingId'] = component.get("v.bookingId");  
        details['ApplicantNumber'] = component.get("v.applicantDetail.Applicant_Number__c");
        details['oppId'] = component.get("v.oppId"); 
        var action = component.get("c.insertDocumentData");  
        action.setParams({     
            "DocDetails": details 
        });  
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                //component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action); 
        
        helper.getuploadedFiles(component,event);  
        
    },
    
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var rec_id = event.getParam('row').Id;
        if(action.label =='Preview')
        {
            $A.get('e.lightning:openFiles').fire({ 
                recordIds: [rec_id]
            });  
        }
        
        if(action.label =='Remove')
        {
            cmp.set("v.Spinner", true); 
            var action1 = cmp.get("c.deleteFiles");           
            action1.setParams({
                "sdocumentId":rec_id            
            });  
            action1.setCallback(this,function(response){  
                var state = response.getState();  
                if(state=='SUCCESS'){ 
                    
                    helper.getuploadedFiles(cmp,event);
                    
                    
                }  
            });  
            $A.enqueueAction(action1);   
        }
        
        
    },
    
    validatePAN: function(component,event,helper)
    {
        debugger;
        event.getSource().set("v.value",event.getSource().get("v.value").toUpperCase());
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid); 
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
        {
            var returnValue = helper.validatePANNumber(component,event);
            if(returnValue == true)
            {debugger;
             inputCmp.setCustomValidity("");
             component.set("v.disablePANUpload", false); 
             
             /*  var compEvent = component.getEvent("DocumentNumberValidate");
        compEvent.setParams({"IsValid": true });
        compEvent.fire();*/
     var disablePANupload;
     for(var i=0 ; i<component.get("v.data").length; i++)
     {
         if(component.get("v.data")[i].documentType == 'PAN Card') 
             disablePANupload = 'true';
     }
     
     if(disablePANupload == 'true')
         component.set("v.disablePANUpload", true); 
     else
         component.set("v.disablePANUpload", false);     
     
     
    }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid PAN Number in ABCDE1234A format");
            component.set("v.disablePANUpload", true); 
            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({"DocumentType" : 'PAN Card', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false , "errorMessage":"Please enter Valid PAN Number under KYC section" });
            compEvent.fire();
            
        }
    }
    inputCmp.reportValidity();
},
    
    
    
    validateOtherDocument: function(component,event,helper)
    {
        event.getSource().set("v.value",event.getSource().get("v.value").toUpperCase());
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        if(component.get("v.applicantDetail.Address_Proof_Document__c")!= '')
        {
            if(event.getSource().get("v.value") != '' && event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined)
            {
                if(component.get("v.applicantDetail.Address_Proof_Document__c")== 'Aadhar Card')
                {
                    
                    var returnValue = helper.validateAadharNumber(component,event);
                    if(returnValue == true)
                    {
                        inputCmp.setCustomValidity("");
                        component.set("v.applicantDetail.RWPrimaryAadharDetails",event.getSource().get("v.value"));
                        //component.set("v.EOIWrap.RWDocumentNumber",event.getSource().get("v.value"));
                        component.set("v.disableOtherDocumentUpload", false); 
                        var compEvent = component.getEvent("DocumentNumberValidate");
                        compEvent.setParams({"IsValid": true });
                        compEvent.fire();
                        var disableOtherDocumentUpload;
                        for(var i=0 ; i<component.get("v.data").length; i++)
                        {
                            if(component.get("v.data")[i].documentType == 'Aadhar Card') 
                                disableOtherDocumentUpload = 'true';
                        }
                        
                        if(disableOtherDocumentUpload == 'true')
                            component.set("v.disableOtherDocumentUpload", true); 
                        else
                            component.set("v.disableOtherDocumentUpload", false);     
                        
                    }
                    
                    else
                    {
                        inputCmp.setCustomValidity("Please enter Valid Aadhar Number without -");
                        component.set("v.disableOtherDocumentUpload", true); 
                        var compEvent = component.getEvent("DocumentNumberValidate");
                        compEvent.setParams({"DocumentType" : 'Aadhar Card', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false,"errorMessage":"Please enter Valid Aadhar Number under KYC section" });
                        compEvent.fire();
                        
                    }
                    
                    inputCmp.reportValidity();
                }
                
                
                
                
                if(component.get("v.applicantDetail.Address_Proof_Document__c")== 'Driving License')
                {
                    //component.set("v.EOIWrap.RWDocumentNumber",event.getSource().get("v.value"));
                    var disableOtherDocumentUpload;
                    
                    for(var i=0 ; i<component.get("v.data").length; i++)
                    {
                        if(component.get("v.data")[i].documentType == 'Driving License') 
                            disableOtherDocumentUpload = 'true';
                    }
                    
                    if(disableOtherDocumentUpload == 'true')
                        component.set("v.disableOtherDocumentUpload", true); 
                    else
                        component.set("v.disableOtherDocumentUpload", false);     
                    
                }
                
                if(component.get("v.applicantDetail.Address_Proof_Document__c")== 'Electricity Bill')
                {
                    component.set("v.applicantDetail.Address_Proof_Number__c",event.getSource().get("v.value"));
                    var disableOtherDocumentUpload;
                    for(var i=0 ; i<component.get("v.data").length; i++)
                    {
                        if(component.get("v.data")[i].documentType == 'Electricity Bill') 
                            disableOtherDocumentUpload = 'true';
                    }
                    
                    if(disableOtherDocumentUpload == 'true')
                        component.set("v.disableOtherDocumentUpload", true); 
                    else
                        component.set("v.disableOtherDocumentUpload", false);     
                    
                }
                
                if(component.get("v.applicantDetail.Address_Proof_Document__c")== "Voter’s ID Card")
                {
                    component.set("v.applicantDetail.Address_Proof_Number__c",event.getSource().get("v.value"));
                    var disableOtherDocumentUpload;
                    for(var i=0 ; i<component.get("v.data").length; i++)
                    {
                        if(component.get("v.data")[i].documentType == 'Voter\'s ID Card') 
                            disableOtherDocumentUpload = 'true';
                    }
                    
                    if(disableOtherDocumentUpload == 'true')
                        component.set("v.disableOtherDocumentUpload", true); 
                    else
                        component.set("v.disableOtherDocumentUpload", false);     
                    
                }
                
                if(component.get("v.applicantDetail.Address_Proof_Document__c")== 'Passport')
                {
                    var returnValue = helper.validatePassportNumber(component,event);
                    if(returnValue == true)
                    {
                        inputCmp.setCustomValidity("");
                        component.set("v.applicantDetail.PassportNoDetails__c",event.getSource().get("v.value"));
                        //component.set("v.EOIWrap.RWDocumentNumber",event.getSource().get("v.value"));
                        var compEvent = component.getEvent("DocumentNumberValidate");
                        compEvent.setParams({"IsValid": true });
                        compEvent.fire();
                        var disableOtherDocumentUpload;
                        for(var i=0 ; i<component.get("v.data").length; i++)
                        {
                            if(component.get("v.data")[i].documentType == 'Passport') 
                                disableOtherDocumentUpload = 'true';
                        }
                        
                        if(disableOtherDocumentUpload == 'true')
                            component.set("v.disableOtherDocumentUpload", true); 
                        else
                            component.set("v.disableOtherDocumentUpload", false);     
                        
                    }
                    
                    
                    
                    else
                    {
                        inputCmp.setCustomValidity("Please enter Valid Passport Number like A1234567");
                        component.set("v.disableOtherDocumentUpload", true); 
                        var compEvent = component.getEvent("DocumentNumberValidate");
                        compEvent.setParams({"DocumentType" : 'Passport', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false ,"errorMessage":"Please enter Valid Passport Number under KYC section"});
                        compEvent.fire();
                        
                    }
                    
                    inputCmp.reportValidity();
                }
            }
            else
            {
                component.set("v.disableOtherDocumentUpload", true); 
            }
            
            
            
            
            
        }
        
        
        
        
    },
    
    onOtherDocumentSelect : function (component, event) 
    {debugger;
     var inputCmp =component.find("DocumentDetails");
     if(inputCmp != undefined && inputCmp.length == undefined )
     {
         inputCmp.setCustomValidity("");
         inputCmp.reportValidity();
     }
     component.set("v.disableOtherDocumentUpload", true);
     /* var compEvent = component.getEvent("DocumentNumberValidate");
    compEvent.setParams({"IsValid": true });
    compEvent.fire();*/
 
 
 if(event.getSource().get("v.value") !='')
 {
     //component.find("DocumentDetails").set("v.disabled",false);
     //component.find("OriginDetails").set("v.disabled",false);
     component.set("v.documentType",event.getSource().get("v.value"));
     
     component.set("v.applicantDetail.Address_Proof_Number__c","");
     component.set("v.applicantDetail.Origin_Details__c","");
     var disableOtherDocumentUpload;
     for(var i=0 ; i<component.get("v.data").length; i++)
     {
         if(component.get("v.data")[i].documentType == event.getSource().get("v.value")) 
             disableOtherDocumentUpload = 'true';
     }
     
     if(disableOtherDocumentUpload == 'true')
         component.set("v.disableOtherDocumentUpload", true); 
     //else
     // component.set("v.disableOtherDocumentUpload", false);
 }
 else
 {
     component.set("v.disableOtherDocumentUpload", true);
     component.set("v.v.applicantDetail.Address_Proof_Number__c","");
     component.set("v.applicantDetail.Origin_Details__c","");
     //component.find("DocumentDetails").set("v.disabled",true);
     //component.find("OriginDetails").set("v.disabled",true);
 }
 //component.set("disableOtherDocumentUpload" , false);
},
    
    onPanCardNumberofAuthoritySignatoryChange: function (component, event) 
    {
        component.set("v.documentType","Pan Card Number of Authority Signatory");
        var disableOtherDocumentUpload;
        for(var i=0 ; i<component.get("v.data").length; i++)
        {
            if(component.get("v.data")[i].documentType == 'Pan Card Number of Authority Signatory') 
                disableOtherDocumentUpload = 'true';
        }
        
        if(disableOtherDocumentUpload == 'true')
            component.set("v.disableOtherDocumentUpload", true); 
        else
            component.set("v.disableOtherDocumentUpload", false);  
        //component.set("disableOtherDocumentUpload" , false);
    },
    
    onPassportChange: function (component, event,helper) 
    { 
        if(event.getSource().get("v.value") != '' && event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined)
        {
            if(event.getSource().get("v.value") != '')
            {
                var localid =event.getSource().getLocalId();
                var inputCmp =component.find(localid);
                component.set("v.documentType","Passport");
                //----------
                
                var returnValue = helper.validatePassportNumber(component,event);
                if(returnValue == true)
                {
                    inputCmp.setCustomValidity("");
                    //component.set("v.EOIWrap.RWDocumentNumber",event.getSource().get("v.value"));
                    var compEvent = component.getEvent("DocumentNumberValidate");
                    compEvent.setParams({"IsValid": true });
                    compEvent.fire();
                    var disableOtherDocumentUpload;
                    for(var i=0 ; i<component.get("v.data").length; i++)
                    {
                        if(component.get("v.data")[i].documentType == 'Passport') 
                            disableOtherDocumentUpload = 'true';
                    }
                    
                    if(disableOtherDocumentUpload == 'true')
                        component.set("v.disableOtherDocumentUpload", true); 
                    else
                        component.set("v.disableOtherDocumentUpload", false);     
                    
                }
                
                
                
                else
                {
                    inputCmp.setCustomValidity("Please enter Valid Passport Number");
                    component.set("v.disableOtherDocumentUpload", true); 
                    var compEvent = component.getEvent("DocumentNumberValidate");
                    compEvent.setParams({"DocumentType" : 'Passport', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false ,"errorMessage":"Please enter Valid Passport Number under KYC section"});
                    compEvent.fire();
                    
                }
                
                inputCmp.reportValidity();
                
                
                //-----------
                var disableOtherDocumentUpload;
                for(var i=0 ; i<component.get("v.data").length; i++)
                {
                    if(component.get("v.data")[i].documentType == 'Passport') 
                        disableOtherDocumentUpload = 'true';
                }
                
                if(disableOtherDocumentUpload == 'true')
                    component.set("v.disableOtherDocumentUpload", true); 
                else
                    component.set("v.disableOtherDocumentUpload", false);   
                //component.set("disableOtherDocumentUpload" , false);
            }
            else
            {
                var localid =event.getSource().getLocalId();
                var inputCmp =component.find(localid);
                inputCmp.setCustomValidity("");
                inputCmp.reportValidity();
                var compEvent = component.getEvent("DocumentNumberValidate");
                compEvent.setParams({"IsValid": true });
                compEvent.fire();
                component.set("v.disableOtherDocumentUpload", true); 
            }
        }
        else
        {
            component.set("v.disableOtherDocumentUpload", true); 
        }
    },
    
    onFNPassportChange: function (component, event) 
    {
        component.set("v.documentType","Passport");
        var disablePassportUpload;
        for(var i=0 ; i<component.get("v.data").length; i++)
        {
            if(component.get("v.data")[i].documentType == 'Passport') 
                disablePassportUpload = 'true';
        }
        
        if(disablePassportUpload == 'true')
            component.set("v.disablePassportUpload", true); 
        else
            component.set("v.disablePassportUpload", false);   
        //component.set("disableOtherDocumentUpload" , false);
    },
    
    onOriginDetailsChange: function (component, event) 
    {
        if(event.getSource().get("v.value") != '' && event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined)
        {
            if(component.get("v.applicantDetail.Type_Of_Origin__c")== 'PIO card')
            {
                component.set("v.documentType","PIO card");
                var disableOtherDocumentUpload;
                for(var i=0 ; i<component.get("v.data").length; i++)
                {
                    if(component.get("v.data")[i].documentType == 'PIO card') 
                        disableOtherDocumentUpload = 'true';
                }
                
                if(disableOtherDocumentUpload == 'true')
                    component.set("v.disableOtherDocumentUpload", true); 
                else
                    component.set("v.disableOtherDocumentUpload", false); 
            }
            
            if(component.get("v.applicantDetail.Type_Of_Origin__c")== 'OCI card')
            {
                component.set("v.documentType","OCI card");
                var disableOtherDocumentUpload;
                for(var i=0 ; i<component.get("v.data").length; i++)
                {
                    if(component.get("v.data")[i].documentType == 'OCI card') 
                        disableOtherDocumentUpload = 'true';
                }
                
                if(disableOtherDocumentUpload == 'true')
                    component.set("v.disableOtherDocumentUpload", true); 
                else
                    component.set("v.disableOtherDocumentUpload", false); 
            }
            
        }
        
        else
        {
            component.set("v.disableOtherDocumentUpload", true); 
        }
    },
    
    
    ShowHideAll: function (component, event) {
        let activeSections = component.get("v.activeSections");
        if (activeSections.length === 0) {
            component.set("v.activeSections",["A"]);
        } else {
            component.set("v.activeSections",[]);
        }
    },
    updateDatatable:function(component,event,helper){debugger;
                                                     console.log("old value: " + event.getParam("oldValue"));
                                                     console.log("current value: " + event.getParam("value"));
                                                     var device = $A.get("$Browser.formFactor");
                                                     var width;
                                                     if(device == 'PHONE')
                                                     {
                                                         width = 100;
                                                     }
                                                     
                                                     else
                                                     {
                                                         width = 100;
                                                     }
                                                     var readonly = component.get("v.readonly");
                                                     if(!readonly){
                                                         component.set('v.columns', [
                                                             
                                                             {type: 'button',initialWidth: width, typeAttributes: { label: 'Preview' }},
                                                             {type: 'button',initialWidth: width, typeAttributes: { label: 'Remove' }},
                                                             //{label:'Document', fieldName: 'fileName', type: 'text'},
                                                             {label: 'Document Type', fieldName: 'documentType', type: 'text'},
                                                             
                                                             
                                                             
                                                         ]);
                                                             }else{
                                                             component.set('v.columns', [
                                                             
                                                             {type: 'button',initialWidth: width, typeAttributes: { label: 'Preview' }},
                                                             //{label:'Document', fieldName: 'fileName', type: 'text'},
                                                             {label: 'Document Type', fieldName: 'documentType', type: 'text'},
                                                             
                                                             
                                                             
                                                         ]);
                                                     }
                                                    }
    
})