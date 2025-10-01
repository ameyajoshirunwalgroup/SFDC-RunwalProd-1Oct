({
    getDependentPicklist:function(cmp){
        var action = cmp.get("c.getDependentPicklists");
        action.setParams({
            ObjectName : cmp.get("v.objectName"),
            fieldsMap : cmp.get("v.dependentPicklist")
        });
        debugger;
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                cmp.set("v.statePicklist",pickListResponse.State__c);
                debugger;
                cmp.set("v.ResidentialPicklist",pickListResponse.Subtype_Of_Applicant__c);
                
                
                console.log(pickListResponse);
            }
        });
        $A.enqueueAction(action);
    },
    getPicklistValues: function(cmp, event, helper)
    {
        
        var fieldNames = ["City__c","Type_Of_Origin__c","Address_Proof_Document__c","Gender__c" ,"Marital_Status__c","Designation_picklist__c","Type_Of_Applicant__c","Subtype_Of_Applicant__c","Occupation__c","Nationality_Picklist__c","Salutation__c","Contact_Person_Relationship__c","Country__c"];
        var action12 = cmp.get("c.getPicklistValuesForFields");
        console.log('entered here -- >' + action12);
        action12.setParams({ "objectName" : 'Applicant_Details__c' , fieldNames :fieldNames });
        action12.setCallback(this, function(response) 
                             { 
                                 var state = response.getState(); 
                                 if (state === "SUCCESS") 
                                 {
                                     var responsevalues = response.getReturnValue();
                                     if(responsevalues.City__c)
                                     {
                                         cmp.set("v.CityPicklistOptions",responsevalues.City__c);
                                     }
                                     if(responsevalues.Gender__c)
                                     {
                                         cmp.set("v.GenderPicklistOptions",responsevalues.Gender__c);
                                     }
                                     
                                     if(responsevalues.Marital_Status__c)
                                     {
                                         cmp.set("v.MaritalStatusPicklistOptions",responsevalues.Marital_Status__c);
                                     }
                                     
                                     if(responsevalues.Designation_picklist__c)
                                     {
                                         cmp.set("v.DesignationPicklistOptions",responsevalues.Designation_picklist__c);
                                     }
                                     
                                     if(responsevalues.Type_Of_Applicant__c)
                                     {
                                         cmp.set("v.ApplicantPicklistOptions",responsevalues.Type_Of_Applicant__c);
                                     }
                                     
                                     if(responsevalues.Occupation__c)
                                     {
                                         cmp.set("v.OccupationPicklistOptions",responsevalues.Occupation__c);
                                     }
                                     if(responsevalues.Nationality_Picklist__c)
                                     {
                                         cmp.set("v.NationalityPicklistOptions",responsevalues.Nationality_Picklist__c);
                                     }
                                     if(responsevalues.Salutation__c)
                                     {
                                         debugger;
                                         cmp.set("v.SalutationPicklistOptions",responsevalues.Salutation__c);
                                     }
                                     if(responsevalues.Contact_Person_Relationship__c)
                                     {
                                         debugger;
                                         cmp.set("v.ContactPersonPicklistOptions",responsevalues.Contact_Person_Relationship__c);
                                     }
                                     if(responsevalues.Country__c)
                                     {
                                         debugger;
                                         cmp.set("v.CountryPicklistOptions",responsevalues.Country__c);
                                     }
                                     if(responsevalues.Address_Proof_Document__c)
                                     {
                                         debugger;
                                         cmp.set("v.AddressProofDocument",responsevalues.Address_Proof_Document__c);
                                     }
                                     if(responsevalues.Type_Of_Origin__c)
                                     {
                                         debugger;
                                         cmp.set("v.TypeOfOriginOptions",responsevalues.Type_Of_Origin__c);
                                     }
                                     
                                     
                                 }
                             });
        
        $A.enqueueAction(action12); 
    },
    
    validate:function(cmp,event){
        var applicants = cmp.get("v.applicantDetails");
        var errorList =[];
        var validationError = false;
        debugger;
        var namregExp =/^[A-Za-z]*$/;
        var mobileRegExp = /^\d{10}$/;
        var dateRegEx = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/;
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        for(var j=0;j<applicants.length;j++)
        { 
            var app = applicants[j];
            
            if(app.Mailing_Address_same_as_PermanentAddress__c){
                app.Mailing_Address_Line_1__c = app.Permanent_Address_Line_1__c;
                app.Mailing_Address_Line_2__c = app.Permanent_Address_Line_2__c;
                app.Mailing_Address_Line_3__c = app.Permanent_Address_Line_3__c;
                app.Mailing_State__c =app.State__c;
                app.Mailing_Country__c = app.Country__c;
                app.Mailing_City__c = app.City__c;
                app.Mailing_Pincode__c = app.Pincode__c;
                
            }
            
            
            if(app.Salutation__c =='undefined' || app.Salutation__c == null || app.Salutation__c == ''){
                validationError =true;
                errorList.push( "Please fill Salution of Applicant "+(j+1))   ;
            }   
            if(app.First_Name__c =='undefined' || app.First_Name__c == null ||app.First_Name__c==''){
                validationError =true;
                errorList.push( "Please fill First Name of Applicant "+(j+1))   ;
            }   else if(!namregExp.test(app.First_Name__c)){
                validationError =true;
                errorList.push("Numbers and Special Characters are not allowed in First Name of Applicant "+(j+1))   ;
            }
            
            
            if(app.Last_Name__c =='undefined' || app.Last_Name__c == null ||app.Last_Name__c==''){
                validationError =true;
                errorList.push("Please fill Last Name ofApplicant "+(j+1))   ;
            }   else if(!namregExp.test(app.Last_Name__c)){
                validationError =true;
                errorList.push("Numbers and Special Characters are not allowed in First Name of Applicant "+(j+1))   ;
            }
            if(!	namregExp.test(app.Middle_Name__c)){
                validationError =true;
                errorList.push("Numbers and Special Characters are not allowed in Middle Name of Applicant "+(j+1))   ;
            }
            
            if(!mobileRegExp.test(app.Mobile_Number__c) && app.Country__c == 'India' && app.Subtype_Of_Applicant__c != 'For NRI'){
                validationError =true;
                var ErrorMsg = "Please enter valid 10 digit Mobile number for Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }else if(app.Mobile_Number__c=='' || app.Mobile_Number__c=='undefined' || app.Mobile_Number__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Mobile number for Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(!(app.Secondary_Mobile_Number__c=='' || app.Secondary_Mobile_Number__c=='undefined' || app.Secondary_Mobile_Number__c==null)&& !mobileRegExp.test(app.Secondary_Mobile_Number__c)){
               
                debugger;
                validationError =true;
                var ErrorMsg = "Please enter valid 10 digit Altername Mobile Number for Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Gender__c=='' || app.Gender__c=='undefined' || app.Gender__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Gender of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Nationality_Picklist__c=='' || app.Nationality_Picklist__c=='undefined' || app.Nationality_Picklist__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Nationality of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.DOB__c=='' || app.DOB__c=='undefined' || app.DOB__c==null){
                validationError =true;
                var ErrorMsg = "Please enter DOB of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }else if(dateRegEx.test(app.DOB__c)){
                validationError =true;
                var ErrorMsg = "Please enter valid Date in DD/MM/YYYY format for Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }  else if(app.DOB__c>=today){
                validationError =true;
                var ErrorMsg = "Date of Birth cannot be today or in the future. for Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }  
            if(app.Marital_Status__c=='' || app.Marital_Status__c=='undefined' || app.Marital_Status__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Marital status of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(! (/^\d*$/).test(app.Landline_Number__c) &&app.Landline_Number__c=='' && app.Landline_Number__c=='undefined' && app.Landline_Number__c==null ){
                validationError =true;
                var ErrorMsg = "Text and Special characters are not allowed in Landline for Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            
            if(app.Organization_Name__c=='' || app.Organization_Name__c=='undefined' || app.Organization_Name__c==null){
                validationError =true;
                var ErrorMsg = "Please enter company name of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Occupation__c=='' || app.Occupation__c=='undefined' || app.Occupation__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Occupation of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            
            if(app.Permanent_Address_Line_1__c=='' || app.Permanent_Address_Line_1__c=='undefined' || app.Permanent_Address_Line_1__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Permanent Address Line 1 of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Permanent_Address_Line_2__c=='' || app.Permanent_Address_Line_2__c=='undefined' || app.Permanent_Address_Line_2__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Permanent Address Line 2 of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Country__c	=='' || app.Country__c=='undefined' || app.Country__c	==null){
                validationError =true;
                var ErrorMsg = "Please enter Country of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Country__c == 'India' && (app.State__c=='' || app.State__c=='undefined' || app.State__c==null)){
                validationError =true;
                var ErrorMsg = "Please enter State of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Pincode__c=='' || app.Pincode__c=='undefined' || app.Pincode__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Pincode of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }else 
                if (app.Country__c == 'India' && !(/^[1-9][0-9]{5}$/).test(app.Pincode__c)){
                    validationError =true;
                    var ErrorMsg = "Pin code should be 6 digits when country is selected as India for Applicant "+(j+1);
                    errorList.push(ErrorMsg)  
                }
            if(app.Mailing_Address_Line_1__c=='' || app.Mailing_Address_Line_1__c=='undefined' || app.Mailing_Address_Line_1__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Mailing Address Line 1 of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Mailing_Address_Line_2__c	=='' || app.Mailing_Address_Line_2__c	=='undefined' || app.Mailing_Address_Line_2__c	==null){
                validationError =true;
                var ErrorMsg = "Please enter Mailing Address Line 2 of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Mailing_Country__c	=='' || app.Mailing_Country__c=='undefined' || app.Mailing_Country__c	==null){
                validationError =true;
                var ErrorMsg = "Please enter Mailing Country of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Mailing_Country__c == 'India' && (app.Mailing_State__c=='' || app.Mailing_State__c=='undefined' || app.Mailing_State__c==null)){
                validationError =true;
                var ErrorMsg = "Please enter Mailing State of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }
            if(app.Mailing_Pincode__c=='' || app.Mailing_Pincode__c=='undefined' || app.Mailing_Pincode__c==null){
                validationError =true;
                var ErrorMsg = "Please enter Maling Pincode of Applicant "+(j+1);
                errorList.push(ErrorMsg)   ;
            }else if (app.Mailing_Country__c == 'India' && !(/^[1-9][0-9]{5}$/).test(app.Mailing_Pincode__c)){
                validationError =true;
                var ErrorMsg = "Pin code should be 6 digits when mailing country is selected as India for Applicant "+(j+1);
                errorList.push(ErrorMsg)  
            }
            if (app.Organisation_Country__c == 'India' && app.Organisation_Pincode__c!=''&& app.Organisation_Pincode__c!=null && app.Organisation_Pincode__c!= 'undefined' && !('/^[1-9][0-9]{5}$/').test(app.Organisation_Pincode__c)){
                validationError =true;
                var ErrorMsg = "Pin code should be 6 digits when Office country is selected as India for Applicant "+(j+1);
                errorList.push(ErrorMsg)  
            }
            if(app.Type_Of_Applicant__c === 'Individual Buyer'){
                if(app.Subtype_Of_Applicant__c == 'Indian National'){
                    if(app.PancardNo__c == "" || app.PancardNo__c == null || app.PancardNo__c =="undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter PAN Details of Applicant "+(j+1);
                        errorList.push(ErrorMsg) 
                    }else if(!(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/).test(app.PancardNo__c)){
                        validationError =true;
                        var ErrorMsg = "Please Enter PAN in XXXXXDDDDX format for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    
                    if(app.Address_Proof_Document__c  == "" || app.Address_Proof_Document__c ==null || app.Address_Proof_Document__c =="undefined"){
                        validationError =true;
                        var ErrorMsg = "Please Select Address Proof document for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    if(app.Address_Proof_Number__c  == "" || app.Address_Proof_Number__c ==null || app.Address_Proof_Number__c =="undefined"){
                        validationError =true;
                        var ErrorMsg = "Please add Address Proof document number for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    if(app.Address_Proof_Document__c == "Passport"){
                        if(app.Nationality_Picklist__c=="India" &&!(/^[A-Za-z]{1}[0-9]{7}$/).test(app.Address_Proof_Number__c)){
                            validationError =true;
                            var ErrorMsg = "Please Enter valid Indian passport number for Applicant "+(j+1);
                            errorList.push(ErrorMsg);
                        }
                    }else if(app.Address_Proof_Document__c =="Aadhar Card"){
                        if(app.Nationality_Picklist__c=="India" &&!(/^[0-9]{12}$/).test(app.Address_Proof_Number__c)){
                            validationError =true;
                            var ErrorMsg = "Please Enter valid Aadhar number for Applicant "+(j+1);
                            errorList.push(ErrorMsg);
                        }
                    }
                }else if(app.Subtype_Of_Applicant__c == "For NRI"){
                    if(app.PassportNoDetails__c == "" || app.PassportNoDetails__c == null || app.PassportNoDetails__c =="undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter Passport Details of Applicant "+(j+1);
                        errorList.push(ErrorMsg) 
                    }else  if(!(/^[A-Za-z]{1}[0-9]{7}$/).test(app.PassportNoDetails__c)){
                        validationError =true;
                        var ErrorMsg = "Please Enter valid Indian passport number for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    if(app.PancardNo__c == "" || app.PancardNo__c == null || app.PancardNo__c =="undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter PAN Details of Applicant "+(j+1);
                        errorList.push(ErrorMsg) 
                    }else if(!(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/).test(app.PancardNo__c)){
                        validationError =true;
                        var ErrorMsg = "Please Enter PAN in XXXXXDDDDX format for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    
                    
                }else if(app.Subtype_Of_Applicant__c == "Foreign Nationals Of Indian Origin"){
                    if(app.PassportNoDetails__c == "" ||app.PassportNoDetails__c == null||app.PassportNoDetails__c == "undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter passport number for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    if(app.Type_Of_Origin__c == "" ||app.Type_Of_Origin__c == null||app.Type_Of_Origin__c == "undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Choose Origin Type of Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    if(app.Origin_Details__c == "" ||app.Origin_Details__c == null||app.Origin_Details__c == "undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter PIO/OCI number for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                }else{
                    validationError =true;
                    var ErrorMsg = "Please enter Residential status for Applicant "+(j+1);
                    errorList.push(ErrorMsg);
                }
            }
            else   if(app.Type_Of_Applicant__c == "Corporate Buyer"){
                
                if(app.Subtype_Of_Applicant__c == "For Company" || app.Subtype_Of_Applicant__c == "Partnership Firms" ){
                    if(app.PancardNo__c == "" || app.PancardNo__c == null || app.PancardNo__c =="undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter Company PAN Details of Applicant "+(j+1);
                        errorList.push(ErrorMsg) 
                    }else if(!(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/).test(app.PancardNo__c)){
                        validationError =true;
                        var ErrorMsg = "Please Enter PAN in XXXXXDDDDX format for Applicant "+(j+1);
                        errorList.push(ErrorMsg);
                    }
                    if(app.Pan_Card_Number_of_Authority_Signatory__c == "" || app.Pan_Card_Number_of_Authority_Signatory__c == null || app.Pan_Card_Number_of_Authority_Signatory__c =="undefined" ){
                        validationError =true;
                        var ErrorMsg = "Please Enter PAN Details of Authority Signatory for Applicant "+(j+1);
                        errorList.push(ErrorMsg) ;
                    };
                }else{
                    validationError =true;
                    var ErrorMsg = "Please enter Residential status for Applicant "+(j+1);
                    errorList.push(ErrorMsg);
                }
                
            }
                else{
                    validationError =true;
                    var ErrorMsg = "Please Enter Type of Applicant "+(j+1);
                    errorList.push(ErrorMsg) ;
                    
                }
            
        }  
        cmp.set("v.applicantValidationError",validationError);
        
        cmp.set("v.applicantErrorList",errorList); 
        return   validationError;
        
    },
    
    paymentval: function(cmp,event){
        debugger;
        var receipts = cmp.get("v.RecieptsList");
        var errorList =[];
        var validationError = false;
        for(var j=0;j<receipts.length;j++)
        {
            var rec = receipts[j]
            if(rec.Mode__c == "" || rec.Mode__c == null || rec.Mode__c == "undefined" ){
                validationError =true;
                var ErrorMsg = "Please Enter Payment mode for Payment Section"+(j+1);
                errorList.push(ErrorMsg) ;
            }else if(rec.Mode__c !='Digital'){
                if((rec.Cheque_DD_Date__c == "" || rec.Cheque_DD_Date__c == null || rec.Cheque_DD_Date__c =="undefined" )){
                    validationError =true;
                    var ErrorMsg = "Please Enter Checque/DD/Card Swipe Date in Payment Reference Date field for Payment Section"+(j+1);
                    errorList.push(ErrorMsg) ;
                }else{
                    if(rec.Mode__c !='Card Swipe'){
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        var threemonth = new Date();
                        threemonth.setMonth(threemonth.getMonth() - 3);
                        threemonth = $A.localizationService.formatDate(threemonth, "YYYY-MM-DD");
                        
                        if(rec.Cheque_DD_Date__c < threemonth){
                            validationError =true;
                            var ErrorMsg = "Cheque Date cannot be before Last 3 months from today in Payment Section"+(j+1);
                            errorList.push(ErrorMsg) ;
                        }
                    }else{
                        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                        if(rec.Cheque_DD_Date__c > today){
                            validationError =true;
                            var ErrorMsg = "Card swipe date cannot be future dated in Payment Reference Date for Payment Section"+(j+1);
                            errorList.push(ErrorMsg) ;
                        }
                    }
                }
                if(rec.Total_Amount__c == "" || rec.Total_Amount__c == null || rec.Total_Amount__c =="undefined"){
                    validationError =true;
                    errorList.push("Amount cannot be blank in Payment"+(j+1)) ;
                }
                if(rec.Cheque_DD__c == "" || rec.Cheque_DD__c == null || rec.Cheque_DD__c =="undefined"){
                    validationError =true;
                    errorList.push("Please enter Payment reference(Cheque/DD) number in Payment Section "+(j+1)) ;
                }
                if(rec.DraweeBank__c == "" || rec.DraweeBank__c == null || rec.DraweeBank__c =="undefined"){
                    validationError =true;
                    errorList.push("Please enter Bank Details in Payment Section"+(j+1)) ;
                }
            }
        }
        
        
        cmp.set("v.paymentsValidationError",validationError);
        
        cmp.set("v.paymentsValidationErrorList",errorList);
        return validationError;
        
    }
    
})