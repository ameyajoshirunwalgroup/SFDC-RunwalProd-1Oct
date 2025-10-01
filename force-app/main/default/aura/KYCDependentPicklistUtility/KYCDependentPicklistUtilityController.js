({
    doInit : function(component, event, helper) { 
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var subDependingFieldAPI = component.get("v.subDependingFieldAPI");
        
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI, "v.depnedentFieldMap");
        
        // 2nd and 3ed picklist 
        helper.fetchPicklistValues(component,objDetails,dependingFieldAPI, subDependingFieldAPI, "v.subDepnedentFieldMap");
        
        var fieldNames = ["RW_Document_Proof__c","RW_Type_Of_Origin__c"];
                                    var action = component.get("c.getPicklistValuesForFields");
                                    action.setParams({ "objectName" : 'RW_EOI__c' , fieldNames :fieldNames });
                                    action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   if(responsevalues.RW_Document_Proof__c)
                                   {
                                       component.set("v.addressProofDcoumentPicklists",responsevalues.RW_Document_Proof__c);
                                   }
                                   
                                    if(responsevalues.RW_Document_Proof__c)
                                   {
                                       component.set("v.OriginTypePicklistValues",responsevalues.RW_Type_Of_Origin__c);
                                   }
                               }
                           });
         $A.enqueueAction(action);
        if(component.get("v.EOIWrap.RWTypeofapplicant") !='' && component.get("v.EOIWrap.RWTypeofapplicant") != undefined)
        component.set("v.bDisabledDependentFld",false);
        
        if(component.get("v.EOIWrap.RWResidentialstatus") !='' && component.get("v.EOIWrap.RWResidentialstatus") != undefined)
        {
            component.set("v.bDisabledSubDependentFld",false);
            if(component.get("v.EOIWrap.RWResidentialstatus") == 'Foreign Nationals Of Indian Origin' && component.get("v.EOIWrap.RWPassportNoDetails") != '' && component.get("v.EOIWrap.RWPassportNoDetails") != undefined)
                
            {
                component.set("v.disablePassportUpload",false);
            }
            else
            {
                component.set("v.disablePassportUpload",true);
            }
            
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
        component.set('v.columns', [
            
            {type: 'button',initialWidth: width, typeAttributes: { label: 'Preview' }},
            {type: 'button',initialWidth: width, typeAttributes: { label: 'Remove' }},
            //{label:'Document', fieldName: 'fileName', type: 'text'},
            {label: 'Document Type', fieldName: 'documentType', type: 'text'},
            
            
            
        ]);
            component.set("v.encryptedToken",component.get("v.recordId")+'|'+'8889');
            helper.getuploadedFiles(component,event);

            },
            
            onControllerFieldChange: function(component, event, helper) { 
            component.set("v.EOIWrap.RWResidentialstatus",'');
            component.set("v.EOIWrap.RWTypeOfOrigin","");
        component.set("v.EOIWrap.RWDocumentProof","");
        component.set("v.EOIWrap.RWDocumentNumber","");
        component.set("v.EOIWrap.RWOriginDetails","");
        component.set("v.EOIWrap.RWPanCardNumberofAuthoritySignatory","");
        component.set("v.EOIWrap.RWPassportNoDetails","");
            component.set("v.EOIWrap.RWPANDetails","");
        component.set("v.disableOtherDocumentUpload", true);
            
            var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
            component.set("v.disablePANUpload",true);
            if(controllerValueKey == '')
            {
            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": false , "errorMessage":"Please select Applicant Type under KYC section." });
            compEvent.fire();
            component.set("v.EOIWrap.RWTypeofapplicant",'');
            component.set("v.EOIWrap.RWResidentialstatus",'');
            }
            else
            {
            
             var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": true});
            compEvent.fire();
            

            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": false , "errorMessage":"Please select Residential Status under KYC section." });
            compEvent.fire();
            component.set("v.EOIWrap.RWTypeofapplicant",controllerValueKey);
            }
            
            var depnedentFieldMap = component.get("v.depnedentFieldMap");
            
            if (controllerValueKey != '') {
            // disable and reset sub dependent field 
            
            
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
                      
                      if(ListOfDependentFields.length > 0){
            component.set("v.bDisabledDependentFld" , false);  
            helper.fetchDepValues(component,event, ListOfDependentFields,"v.listDependingValues");    
        }else{
            component.set("v.bDisabledDependentFld" , true); 
            component.set("v.listDependingValues", '');
        }  
        
    } else {
    //component.set("v.listDependingValues", '');
    component.set("v.bDisabledDependentFld" , true);
    
}
 
 component.set("v.bDisabledSubDependentFld" , true); 
//component.set("v.listSubDependingValues", ['--- None ---']);
},
    
    
    onSubControllerFieldChange : function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected sub controller field value
        component.set("v.EOIWrap.RWTypeOfOrigin","");
        component.set("v.EOIWrap.RWDocumentProof","");
        component.set("v.EOIWrap.RWDocumentNumber","");
        component.set("v.EOIWrap.RWOriginDetails","");
        component.set("v.EOIWrap.RWPanCardNumberofAuthoritySignatory","");
        component.set("v.EOIWrap.RWPassportNoDetails","");
        component.set("v.EOIWrap.RWPANDetails","");
        component.set("v.disableOtherDocumentUpload", true); 
        
        //component.find("DocumentDetails").set("v.disabled",true);
           // component.find("OriginDetails").set("v.disabled",true);
        
        if(controllerValueKey == '')
          {
            component.set("v.EOIWrap.RWResidentialstatus",'');
            component.set("v.disableOtherDocumentUpload", true); 
            component.set("v.disablePANUpload",true);
            component.set("v.disablePassportUpload",true);
              
            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": false , "errorMessage":"Please select Residential Status under KYC section." });
            compEvent.fire();
          }
            else
            {
                component.set("v.bDisabledSubDependentFld",false);
                var disablePANupload;
                var disablePassportUpload;
                for(var i=0 ; i<component.get("v.data").length; i++)
                {
                    if(component.get("v.data")[i].documentType == 'PAN Card') 
                        disablePANupload = 'true';
                }
                
                if(disablePANupload == 'true')
                    component.set("v.disablePANUpload", true); 
                else
                {
                    if(component.get("v.EOIWrap.RWPANDetails") == '' || component.get("v.EOIWrap.RWPANDetails") == undefined)
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
                
            component.set("v.EOIWrap.RWResidentialstatus",controllerValueKey); 
            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({ "IsValid": true  });
            compEvent.fire();
            }
 
            
        
    },
        
    
    uploadDocument :   function(component, event, helper) {  
        
        var uploadedFiles = event.getParam("files"); 
        var details ={};
        details['documentId'] = uploadedFiles[0].documentId;
        details['applicantType'] = component.get("v.EOIWrap.RWTypeofapplicant");
        details['residentialStatus'] = component.get("v.EOIWrap.RWResidentialstatus");
        details['documentType'] = event.getSource().get("v.name");
        //details['documentNumber'] = component.find(event.getSource().get("v.name")).get("v.value");
        details['oppRecId'] = component.get("v.recordId");  
        details['eoiRecId'] = component.get("v.eoiId"); 
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
            
            var uploadedFiles = event.getParam("files"); 
            var details ={};
            details['documentId'] = uploadedFiles[0].documentId;
            details['applicantType'] = component.get("v.EOIWrap.RWTypeofapplicant");
            details['residentialStatus'] = component.get("v.EOIWrap.RWResidentialstatus");
            details['documentType'] = component.get("v.documentType");
            //details['documentNumber'] = component.find(event.getSource().get("v.name")).get("v.value");
            details['oppRecId'] = component.get("v.recordId");  
            details['eoiRecId'] = component.get("v.eoiId"); 
            var action = component.get("c.insertOtherDocumentData");  
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
            
           /* UploadFinished : function(component, event, helper) {  
                var uploadedFiles = event.getParam("files");  
                var details ={};
                details['documentId'] = uploadedFiles[0].documentId;
                details['encrytedToken']=component.get("v.encryptedToken");
                details['oppRecId'] = component.get("v.recordId");
                details['applicantType'] = component.get("v.EOIWrap.RWTypeofapplicant");
                details['residentialStatus'] = component.get("v.EOIWrap.RWResidentialstatus");
                details['documentType'] = component.get("v.objDetail.RW_Document_Proof__c");
                //details['documentType'] = event.getSource().get("v.name");
                //details['documentNumber'] = component.find(event.getSource().get("v.name")).get("v.value");
                var action = component.get("c.insertDocumentDetails");  
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
                
                //var fileName = uploadedFiles[0].name; 
                helper.getuploadedFiles(component,event);         
                 component.find('notifLib').showNotice({
            "variant": "info",
            "header": "Success",
            "message": "File Uploaded successfully!!",
            closeCallback: function() {}
        });
     },
         */
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
    event.getSource().set("v.value",event.getSource().get("v.value").toUpperCase());
    var localid =event.getSource().getLocalId();
    var inputCmp =component.find(localid);
    var returnValue = helper.validatePANNumber(component,event);
    if(returnValue == true)
    {
        inputCmp.setCustomValidity("");
        var compEvent = component.getEvent("DocumentNumberValidate");
        compEvent.setParams({"IsValid": true });
        compEvent.fire();
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
        /* var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({"DocumentType" : 'PAN Card', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": true });
            compEvent.fire(); */
            
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid PAN Number");
            component.set("v.disablePANUpload", true); 
            var compEvent = component.getEvent("DocumentNumberValidate");
            compEvent.setParams({"DocumentType" : 'PAN Card', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false , "errorMessage":"Please enter Valid PAN Number under KYC section" });
            compEvent.fire();
            
        }
        
        inputCmp.reportValidity();
    },
        

    
    validateOtherDocument: function(component,event,helper)
{
    event.getSource().set("v.value",event.getSource().get("v.value").toUpperCase());
    var localid =event.getSource().getLocalId();
    var inputCmp =component.find(localid);
    if(component.get("v.EOIWrap.RWDocumentProof")!= '')
    {
        if(event.getSource().get("v.value") != '' && event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined)
            {
        if(component.get("v.EOIWrap.RWDocumentProof")== 'Aadhar Card')
        {
            
            var returnValue = helper.validateAadharNumber(component,event);
            if(returnValue == true)
            {
                inputCmp.setCustomValidity("");
                component.set("v.EOIWrap.RWPrimaryAadharDetails",event.getSource().get("v.value"));
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
                inputCmp.setCustomValidity("Please enter Valid Aadhar Number");
                component.set("v.disableOtherDocumentUpload", true); 
                var compEvent = component.getEvent("DocumentNumberValidate");
                compEvent.setParams({"DocumentType" : 'Aadhar Card', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false,"errorMessage":"Please enter Valid Aadhar Number under KYC section" });
                compEvent.fire();
                
            }
            
            inputCmp.reportValidity();
            }
           
        
        
        
        if(component.get("v.EOIWrap.RWDocumentProof")== 'Driving License')
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
       
        if(component.get("v.EOIWrap.RWDocumentProof")== 'Electricity Bill')
        {
                component.set("v.EOIWrap.RWDocumentNumber",event.getSource().get("v.value"));
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
        
        if(component.get("v.EOIWrap.RWDocumentProof")== "Voter’s ID Card")
        {
                component.set("v.EOIWrap.RWDocumentNumber",event.getSource().get("v.value"));
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
        
         if(component.get("v.EOIWrap.RWDocumentProof")== 'Passport')
        {
            var returnValue = helper.validatePassportNumber(component,event);
            if(returnValue == true)
            {
                inputCmp.setCustomValidity("");
                component.set("v.EOIWrap.RWPrimaryPassportDetails",event.getSource().get("v.value"));
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
        }
            }
         else
            {
                 component.set("v.disableOtherDocumentUpload", true); 
            }
        
        
         
        
           
        }
        
        
        
    
},
    
    onOtherDocumentSelect : function (component, event) 
		{
            var inputCmp =component.find("DocumentDetails");
            if(inputCmp != undefined && inputCmp.length == undefined )
            {
            inputCmp.setCustomValidity("");
            inputCmp.reportValidity();
            }
            component.set("v.disableOtherDocumentUpload", true);
             var compEvent = component.getEvent("DocumentNumberValidate");
                compEvent.setParams({"IsValid": true });
                compEvent.fire();
            
            
            if(event.getSource().get("v.value") !='')
            {
            //component.find("DocumentDetails").set("v.disabled",false);
            //component.find("OriginDetails").set("v.disabled",false);
            component.set("v.documentType",event.getSource().get("v.value"));
            
            component.set("v.EOIWrap.RWDocumentNumber","");
            component.set("v.EOIWrap.RWOriginDetails","");
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
                component.set("v.EOIWrap.RWDocumentNumber","");
            component.set("v.EOIWrap.RWOriginDetails","");
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
            if(component.get("v.EOIWrap.RWTypeOfOrigin")== 'PIO card')
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
            
            if(component.get("v.EOIWrap.RWTypeOfOrigin")== 'OCI card')
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
}

})