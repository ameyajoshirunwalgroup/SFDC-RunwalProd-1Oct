({
    doInit: function(component, event, helper) {
        debugger;
        
        
        
        console.log(component.get("v.applicantDetail").Salutation__c);
        console.log(component.get("v.CountryPicklistOptions"));
        var residential = component.get("v.applicantDetail.Type_Of_Applicant__c");
        var residentialMap = component.get("v.ResidentialPicklist");

        if(residential != null){
            component.set("v.ResidentialPicklistOptions",residentialMap.pickListMap[residential]);
        } 
        
        
        var country = component.get("v.applicantDetail.Country__c");
        
        var mcountry = component.get("v.applicantDetail.Mailing_Country__c");
        var ocountry = component.get("v.applicantDetail.Mailing_Country__c");
        
        var allPickMaps = component.get("v.statePicklist");
        
        if(country != null){
            component.set("v.PermStatePicklistOptions",allPickMaps.pickListMap[country]);
        }
        if(mcountry != null){
            component.set("v.MailStatePicklistOptions",allPickMaps.pickListMap[mcountry]);
        }
        
        if(ocountry != null){
            component.set("v.OffStatePicklistOptions",allPickMaps.pickListMap[ocountry]);
        }     
        
        
        var action = component.get("c.profileCheck");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log("response.getReturnValue(): " + response.getReturnValue());
            if (state === "SUCCESS") {
                
                var obj =response.getReturnValue();                
                component.set("v.Masked", obj);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    selectChange:function(component,event,helper){
        debugger;
        var mailingField = component.get("v.applicantDetail.Mailing_Address_same_as_PermanentAddress__c");
        console.log(mailingField);
        if(mailingField){
            debugger;
            
            component.set("v.applicantDetail.Mailing_Address_Line_1__c",component.get("v.applicantDetail.Permanent_Address_Line_1__c "));
            component.set("v.applicantDetail.Mailing_Address_Line_2__c",component.get("v.applicantDetail.Permanent_Address_Line_2__c "));
            component.set("v.applicantDetail.Mailing_Address_Line_3__c",component.get("v.applicantDetail.Permanent_Address_Line_3__c "));
            component.set("v.applicantDetail.Mailing_City__c",component.get("v.applicantDetail.City__c "));
            component.set("v.applicantDetail.Mailing_State__c",component.get("v.applicantDetail.State__c "));
            component.set("v.applicantDetail.Mailing_Country__c",component.get("v.applicantDetail.Country__c "));
            component.set("v.applicantDetail.Mailing_Pincode__c",component.get("v.applicantDetail.Pincode__c "));
            
            
        }else{
            // component.set("v.mailingFields",true);
            
        }
    },
    getPermState:function(component,event,helper){
        debugger;
        var selectedCountry = component.get("v.applicantDetail.Country__c");
        var allPickMaps = component.get("v.statePicklist");
        console.log(selectedCountry);
        console.log(allPickMaps);
        
        component.set("v.PermStatePicklistOptions",allPickMaps.pickListMap[selectedCountry]);
    },
    getMailState:function(component,event,helper){
        debugger;
        var selectedCountry = component.get("v.applicantDetail.Mailing_Country__c");
        var allPickMaps = component.get("v.statePicklist");
        console.log(selectedCountry);
        console.log(allPickMaps);
        
        component.set("v.MailStatePicklistOptions",allPickMaps.pickListMap[selectedCountry]);
    },
    getOfficeState:function(component,event,helper){
        debugger;
        var selectedCountry = component.get("v.applicantDetail.Organisation_Country__c");
        var allPickMaps = component.get("v.statePicklist");
        console.log(selectedCountry);
        console.log(allPickMaps);
        component.set("v.OffStatePicklistOptions",allPickMaps.pickListMap[selectedCountry]);
    },
    getResidentialStatus:function(component,event,helper){
     debugger;
        var residential = component.get("v.applicantDetail.Type_Of_Applicant__c");
        var residentialMap = component.get("v.ResidentialPicklist");
                 component.set("v.ResidentialPicklistOptions",residentialMap.pickListMap[residential]);
              
         debugger;
        console.log(component.get("v.applicantDetail.Subtype_Of_Applicant__c"));
    }
    
})