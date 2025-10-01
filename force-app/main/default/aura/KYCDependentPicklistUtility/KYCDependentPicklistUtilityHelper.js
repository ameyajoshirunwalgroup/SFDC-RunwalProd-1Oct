({
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField,mapAttrName) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set(mapAttrName,StoreResponse);
                
                
                if(mapAttrName == 'v.depnedentFieldMap'){

                    // create a empty array for store map keys(@@--->which is controller picklist values) 
                    var listOfkeys = []; // for store all map keys (controller picklist values)
                    var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                    
                    // play a for loop on Return map 
                    // and fill the all map key on listOfkeys variable.
                    for (var singlekey in StoreResponse) {
                        listOfkeys.push(singlekey);
                    }
                    
                    //set the controller field value for lightning:select
                    if (listOfkeys != undefined && listOfkeys.length > 0) {
                        //ControllerField.push('--- None ---');
                    }
                    
                    for (var i = 0; i < listOfkeys.length; i++) {
                        ControllerField.push(listOfkeys[i]);
                    }  
                    // set the ControllerField variable values to country(controller picklist field)
                    component.set("v.listControllingValues", ControllerField);
                }
            }else{
                alert('Something went wrong..');
            }
            
            if(component.get("v.EOIWrap.RWTypeofapplicant") != '' && component.get("v.EOIWrap.RWTypeofapplicant") != undefined)
            {
                var depnedentFieldMap = component.get("v.depnedentFieldMap");
                var ListOfDependentFields = depnedentFieldMap[component.get("v.EOIWrap.RWTypeofapplicant")];
                      
              if(ListOfDependentFields.length > 0){
            component.set("v.bDisabledDependentFld" , false);  
            this.fetchDepValues(component,event, ListOfDependentFields,"v.listDependingValues");    
              }
            }
            
            if(mapAttrName == 'v.subDepnedentFieldMap')
            {
            if(component.get("v.EOIWrap.RWResidentialstatus") != '' && component.get("v.EOIWrap.RWResidentialstatus") != undefined)
            {
                var depnedentFieldMap = component.get("v.subDepnedentFieldMap");
            var ListOfDependentFields = depnedentFieldMap[component.get("v.EOIWrap.RWResidentialstatus")];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledSubDependentFld" , false);  
                this.fetchDepValues(component,event, ListOfDependentFields,"v.listSubDependingValues"); 
            }
            }
            }
            });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, event, ListOfDependentFields,lstAttrName) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        //if(event.getSource().get("v.name") !='dependentFld')
        //dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set(lstAttrName, dependentFields);
        
    },
    
    getuploadedFiles:function(component,event){
        /*var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId":component.get("v.recordId")  
        });   */ 
        
         var action = component.get("c.getKYCFiles");  
        action.setParams({  
            "recordId":component.get("v.recordId")  ,"eoiId":component.get("v.eoiId")
        });  
        
       /* var action = component.get("c.getFilesData");  
        action.setParams({  
            "recordId":component.get("v.encryptedToken")  
        });  */
        
       /* action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);  
            }  
        });  */
        
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
                   
                component.set("v.data",result); 
                if(result.length ==0)
                {
                    if(component.get("v.bDisabledSubDependentFld"))
                    {
                    component.set("v.disablePANUpload", true);
                    component.set("v.disableOtherDocumentUpload", true); 
                    component.set("v.Spinner", false);
                    }
                    else
                    {
                         component.set("v.disablePANUpload", false);
                        component.set("v.disablePassportUpload", false);
                   //component.set("v.disableOtherDocumentUpload", false); 
                        component.set("v.Spinner", false);
                    }
                    
                    
                }
                else
                {
                 for(var i=0 ; i<component.get("v.data").length; i++)
                        {
                           if(component.get("v.data")[i].documentType == 'PAN Card') 
                           disablePANupload = 'true';
                          /* if(component.get("v.data")[i].documentType == 'Aadhar Card' &&
                             component.get("v.objDetail.RW_Document_Proof__c")== 'Aadhar Card')
                                disableOtherDocumentupload ='true'; 
                        if(component.get("v.data")[i].documentType == 'Passport' &&
                             component.get("v.objDetail.RW_Document_Proof__c")== 'Passport')
                                disableOtherDocumentupload ='true'; */
                            if(component.get("v.EOIWrap.RWResidentialstatus") == 'Indian National' && component.get("v.data")[i].documentType == component.get("v.EOIWrap.RWDocumentProof") )
                                disableOtherDocumentupload ='true';
                            if(component.get("v.EOIWrap.RWResidentialstatus") == 'Indian National' && (component.get("v.EOIWrap.RWDocumentProof") == '' || component.get("v.EOIWrap.RWDocumentProof") == undefined) )
                                disableOtherDocumentupload ='true';
                            if(component.get("v.EOIWrap.RWResidentialstatus") == 'Foreign Nationals Of Indian Origin' && component.get("v.data")[i].documentType == component.get("v.EOIWrap.RWTypeOfOrigin") )
                                disableOtherDocumentupload ='true';
                              if(component.get("v.EOIWrap.RWResidentialstatus") == 'Foreign Nationals Of Indian Origin' && (component.get("v.EOIWrap.RWTypeOfOrigin") == '' || component.get("v.EOIWrap.RWTypeOfOrigin") == undefined) )
                                disableOtherDocumentupload ='true';
                             if(component.get("v.EOIWrap.RWResidentialstatus") == 'Foreign Nationals Of Indian Origin' && component.get("v.data")[i].documentType == 'Passport' )
                                disablePassportUpload ='true';
                             if((component.get("v.EOIWrap.RWResidentialstatus") == 'For Company' || component.get("v.EOIWrap.RWResidentialstatus") == 'Partnership Firm' ) && component.get("v.data")[i].documentType == 'Pan Card Number of Authority Signatory' )
                                disableOtherDocumentupload ='true';
                            if((component.get("v.EOIWrap.RWResidentialstatus") == 'For NRI') && component.get("v.data")[i].documentType == 'Passport' )
                                disableOtherDocumentupload ='true';
                         }
                    
                    
                    
                    if(disablePANupload == 'true' )
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
    {
		var format = '[A-Z]{5}[0-9]{4}[A-Z]{1}';
        if(event.getSource().get("v.value") != null && event.getSource().get("v.value") != undefined && event.getSource().get("v.value") !='')
        {
            
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
    {
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