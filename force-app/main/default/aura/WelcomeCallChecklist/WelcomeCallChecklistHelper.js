({
    
    // sending booking id to cls
    loadRecordIdHelper: function (component, event) {
        var action = component.get("c.callCheckList");
        action.setParams({
            "strBookingId":component.get("v.recordId")
            
        });
        
        action.setCallback(this, function(response){  
            
            var state = response.getState();
            if ("SUCCESS" === state ) {
                component.set("v.spinner", false);
                //alert(response.getReturnValue());                
                if(null!=response.getReturnValue()){
                    var bookingObj = response.getReturnValue(); 
                    console.log('bookingObj!!!',bookingObj);
                    if(null!=bookingObj.bkg.Name){
                        component.set("v.bookingList", bookingObj);
                        component.set("v.applicantList",bookingObj.applicantList);
                        component.set("v.receiptList",bookingObj.receiptList);
                        // console.log('bookingObj.bkg.Welcome_Calls__r!!!!',bookingObj.bkg.Welcome_Calls__r.RW_Welcome_Call_Completed__c);
                        
                        if(bookingObj.bkg.Status__c == 'Booking Confirmed'){
                            //  console.log('BookingConfirmed______',bookingObj.bkg.Status__c);
                            var BookingConfirmed = component.get("v.BookingConfirmed");
                            component.set("v.BookingConfirmed",true);
                            component.set("v.SalesManagerIsNull",false);
                            component.set("v.welcomeCallCompleted",false);
                            component.set("v.welcomeCallRejected",false);
                            if((bookingObj.bkg.Sales_Manager__c == null || bookingObj.bkg.Sales_Manager__c == '')&&
                               (bookingObj.bkg.Welcome_Calls__r[0].RW_Welcome_Call_Status__c != 'Accept')){
                                var SalesManagerIsNull = component.get("v.SalesManagerIsNull");
                                component.set("v.SalesManagerIsNull",true);
                                //component.set("v.BookingConfirmed",false);
                                component.set("v.welcomeCallCompleted",false);
                                component.set("v.welcomeCallRejected",false);
                                
                            }else if(bookingObj.bkg.Welcome_Calls__r[0].RW_Welcome_Call_Status__c == 'Accept'){
                                // console.log('WCCompleted________',bookingObj.bkg.Welcome_Calls__r[0].RW_Welcome_Call_Status__c);
                                var welcomeCallCompleted = component.get("v.welcomeCallCompleted");
                                component.set("v.welcomeCallCompleted",true);
                                component.set("v.SalesManagerIsNull",false);
                                component.set("v.BookingConfirmed",false);
                                component.set("v.welcomeCallRejected",false);
                            }else if(bookingObj.bkg.Welcome_Calls__r[0].RW_Welcome_Call_Status__c == 'Reject'){
                                // console.log('WCRejected_____',bookingObj.bkg.Welcome_Calls__r[0].RW_Welcome_Call_Status__c);
                                var welcomeCallRejected = component.get("v.welcomeCallRejected");
                                component.set("v.welcomeCallRejected",true);
                                component.set("v.SalesManagerIsNull",false);
                                component.set("v.BookingConfirmed",false);
                                component.set("v.welcomeCallCompleted",false);
                            }
                        }else if(bookingObj.bkg.Status__c != 'Booking Confirmed'){
                            component.set("v.BookingNotConfirmed",true);
                        }
                        
                        //Added by Prashant to show dhamaka offer for all projects other than mahalaxmi
                        if(bookingObj.bkg.Project__r.Name != '7 Mahalaxmi'){
                            component.set("v.showDhamakaOffer",true);
                            //console.log("Location Name: " + bookingObj.bkg.Project__r.Project_Location__r.Name);
                        }
                        
                        if(bookingObj.bkg.Project__r.Name == '7 Mahalaxmi'){
                            console.log("Project name"+bookingObj.bkg.Project__r.Name);
                            if(bookingObj.bkg.Unit_No__r.Relationship_Manager__r.User__r.DID__c != null){
                                console.log("mahalaxmi number"+bookingObj.bkg.Unit_No__r.Relationship_Manager__r.User__r.DID__c);
                                component.set("v.regPhone", bookingObj.bkg.Unit_No__r.Relationship_Manager__r.User__r.DID__c);
                            }
                        }else{
                            console.log("Project name"+bookingObj.bkg.Project__r.Name);
                            if(bookingObj.bkg.Project__r.Contact_No__c != null){
                                console.log("non mahalaxmi number"+bookingObj.bkg.Project__r.Contact_No__c);
                                component.set("v.regPhone", bookingObj.bkg.Project__r.Contact_No__c);
                            }
                        }
                        
                        var dropDownOpts = [
                            { value: "", label: "--None--" },
                            { value: "No", label: "No" },
                            { value: "Yes", label: "Yes" }
                        ];
                        component.set("v.dropDownOpts",dropDownOpts );
                        var opts = [
                            { value: "", label: "-- None --" },
                            { value: "Self Funded", label: "Self Funded" },
                            { value: "Bank Loan", label: "Bank Loan" }
                        ];
                        component.set("v.options",opts );
                    }else{
                        
                    }
                }
            }else if ("ERROR" === state ) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {
                    
                }
            }
        });  
        $A.enqueueAction(action);  
    },
    
    getPicklistValuesBank: function(component, event, helper)
    {
        
        //var fieldNames = ["RW_Bank_Name__c"];
        var fieldNames = ["RW_Bank_Preference_1__c"];
        var action = component.get("c.getPicklistValuesForBankName");
        action.setParams({ "objectName" : 'Loan__c' , fieldNames :fieldNames });
        action.setCallback(this, function(response) 
                           { 
                               var state = response.getState(); 
                               console.log('state response' + state);
                               if (state === "SUCCESS") 
                               {
                                   var responsevalues = response.getReturnValue();
                                   // console.log('responsevalues ' + responsevalues);
                                   //console.log('BankNamePicklistOptions ' +  component.get("v.BankNamePicklistOptions"));
                                   var bankNames = component.get("v.BankNamePicklistOptions");
                                   bankNames.push({ value: "", label: "--None--" });
                                   for(let j = 0; j < responsevalues.length; j++) {
                                       bankNames.push({ value: responsevalues[j], label: responsevalues[j] });
                                   }
                                   component.set("v.BankNamePicklistOptions",bankNames);
                                   
                                   // console.log('BankNamePicklistOptions ' +  component.get("v.BankNamePicklistOptions"));
                               }
                           });
        
        $A.enqueueAction(action); 
    },

    loadCriticalListHelper : function(component, event) {
        
        var inputValueList = ['ApplicantName1', 'EmailAddresses1', 'MobileNo1', 'PermanentAddress1',
                              'ApplicantName2', 'EmailAddresses2', 'MobileNo2', 'PermanentAddress2',
                              'ApplicantName3', 'EmailAddresses3', 'MobileNo3', 'PermanentAddress3', 
                              'ApplicantName4', 'EmailAddresses4', 'MobileNo4', 'PermanentAddress4', 
                              'ApplicantName5', 'EmailAddresses5', 'MobileNo5', 'PermanentAddress5', 
                              'Project', 'FlatTypology', 'Wing', 'Floor', 'FlatNo', 'CarpetArea', 'CarParkings',
                              'AgreementValue','SourceOfBooking','BankingPreferenceforLoan', 'PaymentPlanType',
                              'PaymentPlanMilestonesDetails','ViewCostSheet','ReceiptListRemarks',
                              'Modeoffunding','RMName','RMcontactNumber','RMworkhours','RMemail', 'Remarks', 'PrimaryPANDetails',
                             'Applicant2PAN', 'BookingDate','RegistrationConsultant','FamilyCount','ResidencePincode','Profession','OfficecDistance','CompanyName','Industry','Designation','FamilyIncome','PurchaseReason','VehiclesCount','FourWheeler'];
        component.set("v.inputValueList",inputValueList);
        
        //To get values from Custommeta data onload 
        var action = component.get("c.CriticalNonCriticalLineItems");
        
        action.setCallback(this, function(response){  
            
            var state = response.getState();
            if ("SUCCESS" === state ) {
                //alert(response.getReturnValue());                
                if(null!=response.getReturnValue()){
                    var CriticalNonCriticalMetaList = response.getReturnValue(); 
                    //console.log('CriticalNonCriticalMetaList!!!',CriticalNonCriticalMetaList.length);
                    if(CriticalNonCriticalMetaList.length > 1){
                        component.set("v.CriticalNonCriticalMetaList", CriticalNonCriticalMetaList);
                        for(var i=0; i<CriticalNonCriticalMetaList.length; i++ ){
                            if(CriticalNonCriticalMetaList[i].Type__c == "Critical"){
                                //console.log('MasterLabel!!!',CriticalNonCriticalMetaList[i].MasterLabel);
                                var CriticalMap = component.get("v.CriticalMap");
                                var CriticalList = component.get("v.CriticalList");
                                for(let j = 0; j < inputValueList.length; j++) { 
                                    if(CriticalNonCriticalMetaList[i].MasterLabel === inputValueList[j]){
                                        // console.log('inputValueList!!!',inputValueList[j]);
                                        
                                        CriticalMap[inputValueList[j]] = inputValueList[j];
                                        CriticalList.push(CriticalNonCriticalMetaList[i].MasterLabel);
                                        
                                        //  console.log('CriticalMap!!! ' ,CriticalMap);
                                    }
                                }
                                component.set("v.CriticalList", CriticalList);
                                component.set("v.CriticalMap", CriticalMap);
                            }
                            
                        }
                        
                    }
                    
                }
                
            }else if ("ERROR" === state ) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {
                    
                }
            }
        });  
        $A.enqueueAction(action); 
    },

    loadPerviousCallRemarksHelper: function(component, event) {
        
        //To get values from Custommeta data onload 
        var action = component.get("c.prevCallRemarks");
        action.setParams({
            "strBookingId":component.get("v.recordId")
            
        });
        
        action.setCallback(this, function(response){  
            
            var state = response.getState();
            if ("SUCCESS" === state ) {
                //alert(response.getReturnValue());                
                if(null!=response.getReturnValue()){
                    var prevCallRemarksObj = response.getReturnValue(); 
                    // console.log('prevCallRemarksObj!!!',prevCallRemarksObj);
                    
                    if(null!=prevCallRemarksObj && '' != prevCallRemarksObj){
                        component.set("v.prevCallRemarksObj", prevCallRemarksObj);
                        var premap = component.get("v.preMap");
                        for(var key in prevCallRemarksObj){
                            // console.log('key '+key.replace(/(\r\n|\n|\r)/gm,"") +' val '+prevCallRemarksObj[key].replace(/(\r\n|\n|\r)/gm,"") );
                            premap[key.replace(/(\r\n|\n|\r)/gm,"")] = prevCallRemarksObj[key]; 
                        } 
                        // console.log('### premap '+premap);
                        var prevCallRemarksListToShow = component.get("v.prevCallRemarksListToShow");
                        var preMap = component.get("v.preMap");
                        var predatabln = component.get("v.predatabln");
                        prevCallRemarksListToShow.push(prevCallRemarksObj.RW_Remarks__c);
                        component.set("v.prevCallRemarksListToShow", prevCallRemarksListToShow);
                        component.set("v.preMap", premap);
                        component.set("v.predatabln", true);
                        
                    }else{
                        component.set("v.predatabln", false);
                    }
                    
                }
                
            }else if ("ERROR" === state ) {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {
                    
                }
            }
        });  
        $A.enqueueAction(action); 
    },
    //Modified by Dolly
    handleModeOfFundingChange: function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value"); // <-- get value from the event
        console.log("Mode of Funding changed to: " + selectedValue);
    
        component.set("v.selectedValue", selectedValue); // <-- update the component variable
    
        if (selectedValue !== 'Bank Loan') {
            component.set("v.BankPreferenceforLoan1", null);
            component.set("v.BankPreferenceforLoan2", null);
            component.set("v.BankPreferenceforLoan3", null);
            component.set("v.BankPreferenceforLoan", []);
        }
    },

    loadModeOfFundingHelper: function(component, event) {
    console.log(">> Entering loadModeOfFundingHelper");
    console.log(">> recordId:", component.get("v.recordId"));

    var action = component.get("c.loadModeOfFunding");
    action.setParams({
        "strBookingId": component.get("v.recordId")
    });

    action.setCallback(this, function(response) {  
        console.log(">> Callback reached, state=", response.getState());

        var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();

            // Debug the options vs returned values
            console.log("Funding Options => ", component.get("v.options"));
            console.log("BankNamePicklistOptions => ", component.get("v.BankNamePicklistOptions"));
            console.log("Funding Map (from Apex):", JSON.stringify(result));

            // Set values
            component.set("v.selectedValue", result.ModeOfFunding);
            component.set("v.BankPreferenceforLoan1", result.BankPref1);
            component.set("v.BankPreferenceforLoan2", result.BankPref2);
            component.set("v.BankPreferenceforLoan3", result.BankPref3);

            // Verify what actually got set
            console.log("Mode of Funding => " + component.get("v.selectedValue"));
            console.log("BankPref1 => " + component.get("v.BankPreferenceforLoan1"));
            console.log("BankPref2 => " + component.get("v.BankPreferenceforLoan2"));
            console.log("BankPref3 => " + component.get("v.BankPreferenceforLoan3"));
        } 
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors && errors[0] && errors[0].message) {
                console.error("❌ Apex Error: " + errors[0].message);
            } else {
                console.error("❌ Unknown Error", errors);
            }
        }
        else {
            console.warn("⚠ Unexpected state: " + state);
        }
    });  

    $A.enqueueAction(action); 
},

    
     loadYesNoDropDownHelper: function(component, event) {
        
        //To get values from Custommeta data onload 
        var action = component.get("c.loadYesNoDropDown");
        action.setParams({
            "strBookingId":component.get("v.recordId")
            
        });
        
        action.setCallback(this, function(response){  
            
            var state = response.getState();
            if ("SUCCESS" === state ) {
                
                var yesNoDrpDwn = response.getReturnValue(); 
                console.log('yesNoDrpDwn___',yesNoDrpDwn);
                var counter = component.get("v.counter");
                var finalCount = component.get("v.finalCount");
                var finalCountNo = component.get("v.finalCountNo");
                var mapOfKeyValueNew =  component.get("v.mapOfKeyValueNew");
                var CriticalList =  component.get("v.CriticalList");
                
                var preMapYesNo = {};
                var selectedCheckBoxes =  component.get("v.selectedCheckBoxes");
                var mapOfKeyValueGet =  component.get("v.mapOfKeyValue");
                var mapOfKeyBoolean =  component.get("v.mapOfKeyBoolean");
                for(var key in yesNoDrpDwn){
                    var yesNo = yesNoDrpDwn[key].replace(/(\r\n|\n|\r)/gm,"").trim();
                    var yesNoSel = yesNo.split('~');
                    
                    selectedCheckBoxes.push(yesNoSel[0]);
                    mapOfKeyValueGet[key.replace(/(\r\n|\n|\r)/gm,"")] = key.replace(/(\r\n|\n|\r)/gm,"");
                    if(key.replace(/(\r\n|\n|\r)/gm,"") === 'ReceiptListRemarks'){
                        console.log('____yesNoSel ',yesNoSel);
                        var yesNoSelForRemarks = yesNoSel[0].split(':');
                        preMapYesNo[key.replace(/(\r\n|\n|\r)/gm,"")] =yesNoSelForRemarks[1].replace(/(\r\n|\n|\r)/gm,"").trim();
                        console.log('yesNoSelForRemarks[1]',yesNoSelForRemarks[1].replace(/(\r\n|\n|\r)/gm,"").trim());
                        mapOfKeyBoolean[key.replace(/(\r\n|\n|\r)/gm,"")] = yesNoSelForRemarks[1].replace(/(\r\n|\n|\r)/gm,"").trim() +'~' + yesNoSel[1] +'~'+key.replace(/(\r\n|\n|\r)/gm,"");  
                    }else{
                        preMapYesNo[key.replace(/(\r\n|\n|\r)/gm,"")] =yesNoSel[0];
                        mapOfKeyBoolean[key.replace(/(\r\n|\n|\r)/gm,"")] = yesNoSel[0] +'~' + yesNoSel[1] +'~'+key.replace(/(\r\n|\n|\r)/gm,"");
                    }
                    
                    mapOfKeyValueNew[key.replace(/(\r\n|\n|\r)/gm,"")] = key.replace(/(\r\n|\n|\r)/gm,"");
                }
                console.log('map data : ',typeof preMapYesNo)
                console.log('preMapYesNo[key]___',preMapYesNo)
                
                component.set("v.preMapYesNo", preMapYesNo);
                component.set("v.mapOfKeyValue", mapOfKeyValueGet);
                component.set("v.mapOfKeyBoolean", mapOfKeyBoolean);
                
                for (var i=0; i<CriticalList.length; i++) { 
                    
                   console.log('critical___'+CriticalList[i]+' ____ '+mapOfKeyValueNew[CriticalList[i]]);
                    if(CriticalList[i] == mapOfKeyValueNew[CriticalList[i]]){    
                        var str = mapOfKeyBoolean[CriticalList[i]].split('~');
                        console.log('str value____'+str[0]);
                        console.log('str label____'+str[1]);
                        console.log('str Name_____'+str[2]);  
                        
                        if(str[0] === 'Yes'){
                            finalCount++; 
                            console.log('finalCount inc___'+finalCount);
                        }else if(str[0] === 'No'){
                            finalCountNo++;
                        }
                    } 
                    
                }
                component.set("v.counter" , finalCount);
                
                
            }   
        });  
        $A.enqueueAction(action); 
    }, 
 //Modified by Dolly
 handlebankLoanHelper : function(component, event) {
    var selectedCheckboxValue = event.getSource().get("v.value");
    var selectedCheckboxLabel = event.getSource().get("v.label");
    
    var BankPreferenceforLoan = component.get("v.BankPreferenceforLoan") || [];

    // Update only the bank that changed
    if(selectedCheckboxLabel == 'BankName1') BankPreferenceforLoan[0] = selectedCheckboxValue;
    if(selectedCheckboxLabel == 'BankName2') BankPreferenceforLoan[1] = selectedCheckboxValue;
    if(selectedCheckboxLabel == 'BankName3') BankPreferenceforLoan[2] = selectedCheckboxValue;

    // Check for duplicates
    var duplicatesExist = 
        (BankPreferenceforLoan[0] && BankPreferenceforLoan[1] && BankPreferenceforLoan[0] === BankPreferenceforLoan[1]) ||
        (BankPreferenceforLoan[1] && BankPreferenceforLoan[2] && BankPreferenceforLoan[1] === BankPreferenceforLoan[2]) ||
        (BankPreferenceforLoan[2] && BankPreferenceforLoan[0] && BankPreferenceforLoan[2] === BankPreferenceforLoan[0]);

    if(duplicatesExist){
        // Show toast
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: 'Banks should not be same',
            duration: '5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();

        // Reset only the bank that caused the conflict
        if(selectedCheckboxLabel == 'BankName1') {
            BankPreferenceforLoan[0] = null;
            component.set("v.BankPreferenceforLoan1", null);
        }
        if(selectedCheckboxLabel == 'BankName2') {
            BankPreferenceforLoan[1] = null;
            component.set("v.BankPreferenceforLoan2", null);
        }
        if(selectedCheckboxLabel == 'BankName3') {
            BankPreferenceforLoan[2] = null;
            component.set("v.BankPreferenceforLoan3", null);
        }
    }

    // Update the array for internal tracking
    component.set("v.BankPreferenceforLoan", BankPreferenceforLoan);
},

    handleCheckboxHelper : function(component, event) {
        
        var selectedCheckboxValue = event.getSource().get("v.value");
        console.log('selectedCheckboxValue___',selectedCheckboxValue);
        var selectedCheckboxName = event.getSource().get("v.name");
        console.log('selectedCheckboxName___',selectedCheckboxName);
        var selectedCheckboxLabel = event.getSource().get("v.label");
        console.log('selectedCheckboxLabel___',selectedCheckboxLabel);
       // if(selectedCheckboxName === 'Modeoffunding'){
         // selectedCheckboxLabel = component.get("v.BankPreferenceforLoan");
       // }
                   
        var selectedCheckBoxes =  component.get("v.selectedCheckBoxes");
        var mapOfKeyValueGet =  component.get("v.mapOfKeyValue");
        var mapOfKeyValueNew =  component.get("v.mapOfKeyValueNew");
        var mapOfKeyBoolean =  component.get("v.mapOfKeyBoolean");
        var inputValueList =  component.get("v.inputValueList");

        var CriticalList =  component.get("v.CriticalList");
        console.log('CriticalList___',CriticalList.length);
        var BankPreferenceforLoan = component.get("v.BankPreferenceforLoan");
        
        console.log('___selectedCheckBoxes___'+selectedCheckBoxes);

        if(selectedCheckboxValue === ''){ 
          
            selectedCheckBoxes.splice(selectedCheckBoxes.indexOf(selectedCheckboxValue), 1);
            //delete selectedCheckBoxes[selectedCheckboxValue];
            delete mapOfKeyValueGet[selectedCheckboxName];
            delete mapOfKeyBoolean[selectedCheckboxName];
            delete mapOfKeyValueNew[selectedCheckboxName];
           
           } 
           else{
               console.log('typeof____',typeof selectedCheckboxLabel) 
               var str='';
               if(selectedCheckboxLabel != null && selectedCheckboxLabel != undefined && typeof selectedCheckboxLabel == 'object'){
                   selectedCheckboxLabel.forEach(ele=>{
                       console.log('line___',ele) 
                       Object.keys(ele).forEach(key=>{
                       str+=key+':'+ele[key]+';\n'
                   });
                   });
                       console.log('string final :__',str)
                   }else{
                       str = selectedCheckboxLabel;
                   }
                       selectedCheckBoxes.push(selectedCheckboxValue);
                       mapOfKeyValueGet[selectedCheckboxName] = selectedCheckboxName;
                       mapOfKeyBoolean[selectedCheckboxName] = selectedCheckboxValue +'~' +str +'~'+selectedCheckboxName;
                       mapOfKeyValueNew[selectedCheckboxName] = selectedCheckboxName;
                       
                   }
                       
       
        component.set("v.selectedCheckBoxes", selectedCheckBoxes);
        component.set("v.mapOfKeyValue", mapOfKeyValueGet);
        component.set("v.mapOfKeyBoolean", mapOfKeyBoolean);

        var mapOfKeyBoolean =  component.get("v.mapOfKeyBoolean");
        console.log('mapOfKeyBoolean___',mapOfKeyBoolean);
        for (var key in mapOfKeyBoolean) { 
            console.log('key___' ,key,' ',mapOfKeyBoolean[key]);
        }
        var counter = component.get("v.counter");
        var finalCount = component.get("v.finalCount");
        var finalCountNo = component.get("v.finalCountNo");
      
        for (var i=0; i<CriticalList.length; i++) { 
           console.log('critical___'+CriticalList[i]+'___'+mapOfKeyValueNew[CriticalList[i]]);
                if(CriticalList[i] == mapOfKeyValueNew[CriticalList[i]]){    
                    var str = mapOfKeyBoolean[CriticalList[i]].split('~');
                    console.log('str value___'+str[0]);
                    console.log('str label___'+str[1]);
                    console.log('str Name____'+str[2]);  

                    if(str[0] === 'Yes'){
                        finalCount++; 
                        console.log('finalCount inc___'+finalCount);
                    }else if(str[0] === 'No'){
                        finalCountNo++;
                    }
                } 
            
        }

        var mapSize = 0;
        for (var count in mapOfKeyBoolean) {
            mapSize++;
        }
        console.log('mapSize___'+mapSize);
        console.log('finalCount___'+finalCount);
        //console.log('selectedCheckBoxes___'+selectedCheckBoxes.length);
        component.set("v.counter" , finalCount);  

        if(finalCount === CriticalList.length){
            component.set("v.btnAcc",false);
            //component.set("v.btnRej",true);
            
        } else if(mapSize > 0 && finalCount === 0 && finalCountNo > 0) {
                component.set("v.btnAcc",true);
                component.set("v.btnRej",false);
        } else if(mapSize === 0 && finalCount === 0){
            component.set("v.btnAcc",true);
        } else{
            component.set("v.btnRej",false);
            component.set("v.btnAcc",true);
         }
         
      },
                       
                       handleCheckboxChangeHelper : function(component, event) {
                           var isChecked = event.getSource().get("v.checked"); 
                           console.log('Dhamaka selectedCheckboxValue___', isChecked); 
                           component.set("v.isDhamaka", isChecked);
                           console.log('v.isDhamaka', component.get("v.isDhamaka")); 
                           var selectedCheckboxName = event.getSource().get("v.name");
                           console.log('Dhamaka selectedCheckboxName___',selectedCheckboxName);
                           var selectedCheckboxLabel = event.getSource().get("v.label");
                           console.log('Dhamaka selectedCheckboxLabel___',selectedCheckboxLabel);
                       },    
    
     handleAcceptHelper : function (component, event) {
            var modeOfFunding = component.get("v.selectedValue");
            var bank1 = component.get("v.BankPreferenceforLoan1") || '';
            var bank2 = component.get("v.BankPreferenceforLoan2") || '';
            var bank3 = component.get("v.BankPreferenceforLoan3") || '';
         
         

    // Mode of Funding is required
    if(!modeOfFunding || modeOfFunding === ''){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: 'Please select Mode of Funding',
            duration:'5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
        return; // STOP saving
    }

    // If Mode of Funding is Bank Loan, check all required banks
    if(modeOfFunding === 'Bank Loan') {
        if(!bank1 || bank1 === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please select Bank Prefrence 1',
                duration:'5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            return; 
        }
        /*if(!bank2 || bank2 === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please select Bank Prefrence 2',
                duration:'5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            return; 
        }
        if(!bank3 || bank3 === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please select Bank Prefrence 3',
                duration:'5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            return; 
        }*/
    }
         
         var label = event.getSource().get("v.label");
         console.log('label___',label);
         var mapOfKeyBoolean =  component.get("v.mapOfKeyBoolean");
         console.log('mapOfKeyBoolean___',mapOfKeyBoolean);
         var finalList = component.get("v.finalListOfValue");
         console.log('finalList___',finalList);
         var mapOfKeyValueGet =  component.get("v.mapOfKeyValue");
         console.log('mapOfKeyValueGet___',mapOfKeyValueGet);
         var drpDownVal =  component.get("v.selectedValue");
         console.log('drpDownVal___',drpDownVal);
         
         var count = 0;
         var yescheck = '';
         for (var key in mapOfKeyBoolean) { 
             count++;
             console.log('___key ','Key____ ',key,' ',mapOfKeyBoolean[key]);
             var str = mapOfKeyBoolean[key].split('~');
             console.log('str___',str[0]);
             console.log('str___',str[1]);
             console.log('str___',str[2]);
             
             
             //Modified by vinay 11-04-2022 start
             //var valch = component.find(key).get("v.value");
             var valch1 = component.find(key);
             var valch = valch1 ? valch1.get("v.value") : null;
             //Modified by vinay 11-04-2022 end
             console.log('valch___',valch);
             if(valch ==='' || valch === null || valch === undefined){
                 if(str[0] === 'Yes'){
                     yescheck = 'verified'
                     finalList.push('\n'+key +': '+ mapOfKeyBoolean[key] +' % '+ '');
                 }
             }else{
                 finalList.push('\n'+key +': '+ mapOfKeyBoolean[key] +' % '+ valch);
             }
             
             
         }
         
         if( (count > 0) && (finalList == null || finalList == '')  && (yescheck != 'verified') ){
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                 title : 'Error',
                 message: 'Please enter remarks for selected DropDown',
                 duration:' 5000',
                 key: 'info_alt',
                 type: 'error',
                 mode: 'pester'
             });
             toastEvent.fire();
             
             
         }
              
         console.log('mapOfKeyBoolean___',count);
         if(count === 0){
             var addRemarks = component.find("Remarks").get("v.value");
             // console.log('#### addRemarks '+addRemarks);
             if(addRemarks === "" || addRemarks === null || addRemarks === undefined){
                 //   console.log('#### addRemarks in if '+addRemarks);
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     title : 'Error',
                     message: 'Please enter Additional Remarks',
                     duration:' 5000',
                     key: 'info_alt',
                     type: 'error',
                     mode: 'pester'
                 });
                 toastEvent.fire();
                 //component.set("v.errorMsg",'Please enter remarks');  
             }else{
                 component.set("v.additionalRemarks",addRemarks);
                 //finalList.push(Remarks);
                 //component.set("v.errorMsg",''); 
             }
             //var acc = component.find(Acc).get("v.label");
             component.set("v.btnRej",false);
             component.set("v.btnAcc",true);
         }
         
         console.log('finalList-- ', finalList);
         var addRmrk =  component.get("v.additionalRemarks");
         var selValDrp = component.get("v.selectedValue");
         //var BankPrefLoan = component.get("v.BankPreferenceforLoan");
         var receiptList = component.get("v.receiptList");
         //var isDhamaka = component.find("dhamaka").get("v.checked");
         //Modified by Dolly
         //var BankPrefLoan = component.get("v.BankPreferenceforLoan");
         var BankPrefLoan = [bank1, bank2, bank3];
         console.log('v.isDhamaka', component.get("v.isDhamaka")); 
         if( (finalList != null && finalList != '') ||  (addRmrk !=null && addRmrk != '') ){
             // && (selValDrp != null && selValDrp != '' )) 
             var action = component.get("c.saveCheckList"); 
             console.log('wrapperListToSave^^',component.get("v.bookingList"));
             console.log('finalList^^',finalList);
             console.log('Status^^',label);
             console.log('addRmrk^^',addRmrk);
             console.log('selValDrp^^',selValDrp);
             console.log('BankPrefLoan^^',BankPrefLoan);
             console.log('receiptList^^',receiptList);
             console.log('v.isDhamaka', component.get("v.isDhamaka"));
             action.setParams({
                 "finalRemarksList": finalList,
                 "wrapperListToSave":component.get("v.bookingList"),
                 "Status": label,
                 "addRrmks": addRmrk,
                 "modeOfFunding": selValDrp,
                 "bankPrefrence1": bank1,
                 "bankPrefrence2": bank2,
                 "bankPrefrence3": bank3,
                 "BankPreferenceforLoan": BankPrefLoan,
                 "receiptList": receiptList,
                 "isDhamaka": component.get("v.isDhamaka")
             });
             
             
             action.setCallback(this, function(response){  
                 console.log('response.getState() ',+response.getState());
                 var state = response.getState();
                 if ("SUCCESS" === state ) {
                     component.set("v.errorMessage",'');
                     if(null!=response.getReturnValue()){
                         var welcomeCallObj = response.getReturnValue(); 
                         console.log('welcomeCallObj___',welcomeCallObj);
                         var navEvt = $A.get("e.force:navigateToSObject");
                         console.log('navEvt___',navEvt);
                         navEvt.setParams({
                             "recordId": welcomeCallObj.Id
                             
                         });
                         navEvt.fire();
                     }  
                 }
                 else
                 {
                     component.set("v.errorMessage",response.getError()[0].message);
                     console.log('error: ',response.getError()[0].message);
                 }
             });  
             $A.enqueueAction(action);  
         }
         
     },
  
    handleCloseHelper : function(component, event) {
     var dismissActionPanel = $A.get("e.force:closeQuickAction");
      dismissActionPanel.fire();
     },
                       
   regConsultants: function(component, event, helper) {
        var action = component.get("c.registrationConsultants");
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            console.log('state response---' + state);
            if (state === "SUCCESS") 
            {
                var responsevalues = response.getReturnValue();
                // console.log('responsevalues ' + responsevalues);
                //console.log('RegConsltNameListOptions ' +  component.get("v.RegConsltNameListOptions"));
                var regNames = component.get("v.RegConsltNameListOptions");
                regNames.push({ value: "", label: "--None--" });
                for(let j = 0; j < responsevalues.length; j++) {
                    regNames.push({ value: responsevalues[j], label: responsevalues[j] });
                }
                component.set("v.RegConsltNameListOptions",regNames);
                
                // console.log('RegConsltNameListOptions ' +  component.get("v.RegConsltNameListOptions"));
            }
        });
        
        $A.enqueueAction(action); 
    },
                       
    updatebking : function(component, event){
    	var booking = component.get("v.bookingList.bkg");
        var reg = event.getSource().get("v.value");
        var chrg = event.getSource().get("v.name");
        console.log('reg: ',reg);
        var action = component.get("c.updateRegConsltnt");
        booking.sobjectType = 'Booking__c';
        action.setParams({
            bkId : booking.Id, "regCons": reg, "charge": chrg
        });    
        $A.enqueueAction(action);
    },
                         
   	updateConsChrg : function(component, event){
    	var bkng = component.get("v.bookingList.bkg");
        var chrg = event.getSource().get("v.value");
        var name = event.getSource().get("v.name");
        console.log('name: ',name);
        console.log('chrg: ',chrg);
        var action = component.get("c.updateRegConsltnt");
        bkng.sobjectType = 'Booking__c';
        action.setParams({
            "bkId" : bkng.Id, "regCons": name, "charge": chrg
        });                         
        $A.enqueueAction(action);
    },
    
    checkWelcomecallHelper : function(component, event){ // Added by Vinay 13-12-2024
       return new Promise(
           $A.getCallback(function(resolve, reject) {
               var action = component.get("c.checkWelcomecall");
               action.setParams({
                   "bkgId":component.get("v.recordId")
               });
               action.setCallback(this, function(response) {
                   var state = response.getState();
                   resolve(response.getReturnValue());
               });
               $A.enqueueAction(action);
           })
       );
   }
                       
     
  
	
})