({
    doInit : function( component, event, helper ) {  
        
        var action = component.get("c.getBankPicklists");
        action.setParams({
            "ProjectName": component.get("v.Bookingrec.ProjectId")
            
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var obj =response.getReturnValue();
                var map ={};
                var bankNames = [];
                for (var key in obj) {
                    if (obj.hasOwnProperty(key)) {
                        bankNames.push(key);
                        map[key] = obj[key];
                    }
                }
                component.set("v.BankName", bankNames);
                component.set('v.DependentBranchMap',map);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    } ,
    
    handleOnBankChange:  function(component, event, helper) 
    {
        var dependepicklist=[];
        for (var key in component.get('v.DependentBranchMap')) 
        {
            if(key == event.getSource().get('v.value'))
            {
                component.get('v.DependentBranchMap')[key];
                for(var i=0; i<component.get('v.DependentBranchMap')[key].length; i++)
                {
                    dependepicklist.push(component.get('v.DependentBranchMap')[key][i]);
                }
            }
        }
        component.set('v.BranchName', dependepicklist);
        
    },
    
    validatePAN: function(component,event,helper)
    {
        debugger;
        event.getSource().set("v.value",event.getSource().get("v.value").toUpperCase());
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        var returnValue = helper.validatePANNumber(component,event);
        if(returnValue == true)
        {debugger;
         inputCmp.setCustomValidity("");
         component.set("v.disablePANUpload", false); 

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
        inputCmp.setCustomValidity("Please enter Valid PAN Number");
        component.set("v.disablePANUpload", true); 
        var compEvent = component.getEvent("DocumentNumberValidate");
        compEvent.setParams({"DocumentType" : 'PAN Card', "DocumentNumber" : event.getSource().get("v.value") , "IsValid": false , "errorMessage":"Please enter Valid PAN Number under KYC section" });
        compEvent.fire();
        
    }
    
    inputCmp.reportValidity();
},
    
    uploadDocument: function(component,event,helper)
    {
        var details = {};
        
        var uploadedFiles = event.getParam("files");
        if(event.getSource().get("v.name") == "pancard")
        {
         component.set('v.uploadedPANDocumentID',uploadedFiles[0].documentId);
        }
        if(event.getSource().get("v.name") == "adharCard")
        {
         component.set('v.uploadedAadharCardDocumentID',uploadedFiles[0].documentId);
        }
        if(event.getSource().get("v.name") == "Salary Slip")
        {
         component.set('v.uploadedSalarySlipId',uploadedFiles[0].documentId);
        }
        if(event.getSource().get("v.name") == "ITR")
        {
         component.set('v.uploadedITRId',uploadedFiles[0].documentId);
        }
        if(event.getSource().get("v.name") == "Bank Statement")
        {
         component.set('v.uploadedBankStatementId',uploadedFiles[0].documentId);
        }
        
       /* details['documentId'] = uploadedFiles[0].documentId;
        details['pancardno'] = component.get("v.pancardno");
        details['bookingId'] = component.get("v.Bookingrec.BookingId");
        details['documentType'] = event.getSource().get("v.name");
        details['oppRecId'] = component.get("v.Bookingrec.opportunityId");
        
        var action = component.get("c.insertDocumentLoanData");
        action.setParams({
            "DocDetails": details   
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
        });
        
        $A.enqueueAction(action); */
    },
    
    
    
    onsubmit:  function(component, event, helper) 
    {
        
        var controlAuraIds = ["Pancard","adharCard"];
        //reducer function iterates over the array and return false if any of the field is invalid otherwise true.
        var isAllValid = controlAuraIds.reduce(function(isValidSoFar, controlAuraId){
            //fetches the component details from the auraId
            var inputCmp = component.find(controlAuraId);
            //displays the error messages associated with field if any
            if(inputCmp != undefined)
            {
            inputCmp.reportValidity();
            //form will be invalid if any of the field's valid property provides false value.
            return isValidSoFar && inputCmp.checkValidity() ;
            }
            else
            {
                return true;
            }
           
        },true);
        
        if(isAllValid)
        {
        
        var details ={};
        
        if(component.get("v.BankWrap.bankname") != undefined && component.get("v.BankWrap.bankname")!=null)
        {
           details['Bankname'] = component.get("v.BankWrap.bankname");
        }
        
        if(component.get("v.BankWrap.branchname") != undefined && component.get("v.BankWrap.branchname")!=null)
        {
           details['branchname'] = component.get("v.BankWrap.branchname");
        }
       
        if(component.get("v.pancardno") != undefined && component.get("v.pancardno")!=null)
        {
           details['pancardno'] = component.get("v.pancardno");
        }
        if(component.get("v.aadharno") != undefined && component.get("v.aadharno")!=null)
        {
           details['aadharno'] = component.get("v.aadharno");
        }
        if(component.get("v.uploadedSalarySlip") != undefined && component.get("v.uploadedSalarySlip")!=null)
        {
           details['uploadedSalarySlip'] = component.get("v.uploadedSalarySlip");
        }
        
        if(component.get("v.uploadedITR") != undefined && component.get("v.uploadedITR")!=null)
        {
           details['uploadedITR'] = component.get("v.uploadedITR");
        }
        
         if(component.get("v.uploadedBankStatement") != undefined && component.get("v.uploadedBankStatement")!=null)
        {
           details['uploadedBankStatement'] = component.get("v.uploadedBankStatement");
        }
           
        if(component.get("v.uploadedPANDocumentID") != undefined && component.get("v.uploadedPANDocumentID")!=null)
        {
         details['uploadedPANDocumentID'] = component.get("v.uploadedPANDocumentID");
        }
        if(component.get("v.uploadedAadharCardDocumentID") != undefined && component.get("v.uploadedAadharCardDocumentID")!=null)
        {
         details['uploadedAadharCardDocumentID'] = component.get("v.uploadedAadharCardDocumentID");
        }
        if(component.get("v.uploadedSalarySlipId") != undefined && component.get("v.uploadedSalarySlipId")!=null)
        {
         details['uploadedSalarySlipId'] = component.get("v.uploadedSalarySlipId");
        }
        
        if(component.get("v.uploadedITRId") != undefined && component.get("v.uploadedITRId")!=null)
        {
         details['uploadedITRId'] = component.get("v.uploadedITRId");
        }
        
        if(component.get("v.uploadedBankStatementId") != undefined && component.get("v.uploadedBankStatementId")!=null)
        {
         details['uploadedBankStatementId'] = component.get("v.uploadedBankStatementId");
        }
        
        
        if(component.get("v.Bookingrec.opportunityId") != undefined && component.get("v.Bookingrec.opportunityId")!=null)
        {
         details['oppId'] = component.get("v.Bookingrec.opportunityId"); 
        }
        
        if(component.get("v.Bookingrec.BookingId") != undefined && component.get("v.Bookingrec.BookingId")!=null)
        {
         details['bookingId'] = component.get("v.Bookingrec.BookingId");   
        }
        
        if(component.get("v.Bookingrec.ProjectId") != undefined && component.get("v.Bookingrec.ProjectId")!=null)
        {
         details['projectID'] = component.get("v.Bookingrec.ProjectId");
        }
        
               
        
    	var action = component.get("c.createLoanRecord");
        
        component.set("v.showSpinner", true);
        action.setParams({"DocDetails": details });
        	action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                          component.set("v.showSpinner",false);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "SUCCESS!",
                            "type":"success",
                            "message": "Documents are uploaded successfully."});
                        toastEvent.fire();
                       // component.set("v.isOpen", false);
                       
                        
                         var action1 = component.get("c.getPortalHomeData");
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    {
                        component.set("v.RunwalWrapList",response.getReturnValue());
                          var jsonobject = {
            			state: {  
                               
                                   /*  bookingdetails: component.get('v.RunwalHomeWrapList')*/
                            bookingdetails: response.getReturnValue()
                                } 
                         };
        			sessionStorage.setItem('pageTransfer', JSON.stringify(jsonobject.state));
                    }
                });
                        $A.enqueueAction(action1); 
                    }
            });

		$A.enqueueAction(action);  
        }
        else
        {
           // component.set("v.Spinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"error",
                "message": "Please check and correct all the errors in form and then submit"
            });
            toastEvent.fire();
        }
	},
    
    ValidatePanCard : function(component, event, helper) 
    {
         var returnValue = helper.validatePANNumber(component,event);
         var localid =event.getSource().getLocalId();
         var inputCmp =component.find(localid);
        
         if(returnValue == true)
         {
              inputCmp.setCustomValidity("");
              component.set("v.disablePANUpload", false);
         }
        else
        {
           inputCmp.setCustomValidity("Please enter Valid PAN Number"); 
           component.set("v.disablePANUpload", true);
        }
        
        inputCmp.reportValidity();
    },
    
    validateAadhar: function(component,event,helper)
    {
        var localid =event.getSource().getLocalId();
        var inputCmp =component.find(localid);
        var returnValue = helper.validateAadharNumber(component,event);
        if(returnValue == true)
        {
            inputCmp.setCustomValidity("");
            component.set("v.disableAADHARUpload",false);
        }
        
        else
        {
            inputCmp.setCustomValidity("Please enter Valid Aadhar Number");
            component.set("v.disableAADHARUpload",true);
        }
        
        inputCmp.reportValidity();
    },
    
    

 
})