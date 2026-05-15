public without sharing class CustomerDetailsFormController {
    
    public String selectedSalutation { get; set; }
    public String selectedOccupation { get; set; }
    public String selectedDistanceToOfc { get; set; }
    public String selectedFamilyIncome { get; set; }
    public String selectedPurchaseReason { get; set; }
    public String selectedFourWheeler { get; set; }
    public String selectedNoOfvehicles { get; set; }
    public String lastName { get; set; }
    public Id oppId { get; set; }
    public Opportunity opp { get; set; }
    public CIF__c cif { get; set; }
    
    public List<Integer> charIndexes { get; set; }
    public List<Integer> familyCharIndexes { get; set; }
    public List<Integer> addrCharIndexes { get; set; }
    public List<Integer> companyCharIndexes { get; set; }
    public List<Integer> industryCharIndexes { get; set; }
    public List<Integer> designationCharIndexes { get; set; }
    
    public CustomerDetailsFormController() {
        
        oppId = ApexPages.currentPage().getParameters().get('id');
        opp = [SELECT Id, Account.Salutation, Account.FirstName, Account.Lastname, Account.Industry, Account.BillingPostalCode, Designation__c, RW_Project_Unit__r.Name, No_of_Family_Members__c, Permanent_Address__c, Occupation__c, Distance_To_Office__c, Account.RW_Company_Name__c, Family_Income__c, Reason_To_Purchase__c, No_of_Vehicles__c, Four_Wheeler__c, RW_Project_Unit__r.RW_Param4__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
        List<CIF__c> cifs = [SELECT Id, Salutation__c, FirstName__c, LastName__c, MiddleName__c, ZipCode__c, CompanyName__c, Four_Wheeler__c,
                             Current_Residential_Address__c, No_of_Vehicles__c, Family_Income__c, Distance_To_Office__c,  Purpose__c,
                             No_of_Family_Members__c, Occupation__c, Designation__c, Industry__c, CompanyNameOther__c
                             FROM CIF__c WHERE Opportunity__c =: opp.Id];
        cif = (cifs.size() > 0) ? cifs[0] : new CIF__c();
        List<String> salutations = new List<String>{'Mr.','Ms.','Mrs.'};
        if(cif != null){	
            if(cif.Salutation__c != null)
                selectedSalutation = cif.Salutation__c;
            if(String.isNotBlank(cif.Occupation__c))
                selectedOccupation = cif.Occupation__c;
            if(String.isNotBlank(cif.Distance_To_Office__c))
                selectedDistanceToOfc = cif.Distance_To_Office__c;
            if(String.isNotBlank(cif.Family_Income__c))
                selectedFamilyIncome = cif.Family_Income__c;
            if(String.isNotBlank(cif.Purpose__c))
                selectedPurchaseReason = cif.Purpose__c;
            if(String.isNotBlank(cif.Four_Wheeler__c))
                selectedFourWheeler = cif.Four_Wheeler__c;
            if(String.isNotBlank(cif.No_of_Vehicles__c))
                selectedNoOfvehicles = cif.No_of_Vehicles__c;
            if(String.isNotBlank(cif.LastName__c)){
                for(String sal : salutations){
                    if(cif.LastName__c.contains(sal)){
                        lastName = cif.LastName__c.subString(sal.length());
                        lastName = lastName.trim();
                        break;
                    }else{
                        lastName = cif.LastName__c;
                    }
                }
            }
        }

        charIndexes = new List<Integer>();
        for (Integer i = 0; i < 6; i++) {
            charIndexes.add(i);
        }
        familyCharIndexes = new List<Integer>();
        for (Integer i = 0; i < 2; i++) {
            familyCharIndexes.add(i);
        }
        addrCharIndexes = new List<Integer>();
        for (Integer i = 0; i < 36; i++) {
            addrCharIndexes.add(i);
        }
        companyCharIndexes = new List<Integer>();
        for (Integer i = 0; i < 18; i++) {
            companyCharIndexes.add(i);
        }
        industryCharIndexes = new List<Integer>();
        for (Integer i = 0; i < 16; i++) {
            industryCharIndexes.add(i);
        }
        designationCharIndexes = new List<Integer>();
        for (Integer i = 0; i < 15; i++) {
            designationCharIndexes.add(i);
        }
    } 
    
    
    
    public PageReference saveDetails() {
        try {
            cif.Salutation__c = selectedSalutation;
            cif.Occupation__c = selectedOccupation;
            cif.Distance_To_Office__c = selectedDistanceToOfc;
            cif.Family_Income__c = selectedFamilyIncome;
            cif.Purpose__c = selectedPurchaseReason;
            cif.Four_Wheeler__c = selectedFourWheeler;
            cif.No_of_Vehicles__c = selectedNoOfvehicles;
            cif.FirstName__c = extractField('firstNameChar');
            System.debug('lastName: ' + lastName);
            System.debug('extractField(lastNameChar): ' + extractField('lastNameChar'));
            if(lastName != extractField('lastNameChar')){
                System.debug('---');
                cif.LastName__c = extractField('lastNameChar');
            }
            //cif.LastName__c = extractField('lastNameChar');
            cif.MiddleName__c = extractField('midNameChar');

            String familyCount = extractField('familyChar').replaceAll('[^0-9]', '');

            if (!String.isEmpty(familyCount)) cif.No_of_Family_Members__c = Integer.valueOf(familyCount);
            cif.ZipCode__c = extractField('pinChar');
            cif.Current_Residential_Address__c = extractField('addrChar');
            cif.CompanyName__c = extractField('companyChar');
            cif.Industry__c = extractField('industryChar');
            cif.Designation__c = extractField('desgChar');
            cif.Booked_Unit_No__c = extractField('bookedUnitChar');
            cif.Opportunity__c = oppId;
            upsert cif;
            
            Account acc = new Account();
            acc.Id = opp.AccountId;
            acc.Salutation = cif.Salutation__c;
            acc.RW_Occupation__c = cif.Occupation__c;
            acc.Distance_To_Office__c = cif.Distance_To_Office__c;
            acc.Family_Income__c = cif.Family_Income__c;
            acc.Purpose__c = cif.Purpose__c;
            acc.Four_Wheeler__c = cif.Four_Wheeler__c;
            acc.Vehicles_owned__c = cif.No_of_Vehicles__c;
            acc.FirstName = cif.FirstName__c;
            //acc.Middle_Name__c = cif.MiddleName__c;
            acc.LastName = cif.MiddleName__c + ' ' + cif.LastName__c;
            acc.No_of_family_members__c = cif.No_of_Family_Members__c;
            acc.RW_Zip_Code__c = cif.ZipCode__c;
            acc.Current_Residential_Address__c = cif.Current_Residential_Address__c;
            acc.RW_Company_Name__c = cif.CompanyName__c;
            acc.RW_Other_Company_Name__c = cif.CompanyNameOther__c;
            acc.Industry = cif.Industry__c;
            acc.RW_Designation__c = cif.Designation__c;
            update acc;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Details updated successfully.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()));
        }
        return null;
    }
    
    private String extractField(String prefix) {
        String result = '';
        for (Integer i = 0; i < 20; i++) {
            String val = ApexPages.currentPage().getParameters().get(prefix + i);
            result += (val != null) ? val : '';
        }
        return result.trim();
    }
    private List<SelectOption> picklistvalues(Schema.sObjectField field){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    }   
    public List<SelectOption> getSalutationOptions(){
        return picklistvalues(CIF__c.Salutation__c);
    }
    public List<SelectOption> getDistanceToOfficeOptions(){ 
        return picklistvalues(CIF__c.Distance_To_Office__c);
    }
    public List<SelectOption> getFamilyIncomeOptions(){
        return picklistvalues(CIF__c.Family_Income__c);
    }
    public List<SelectOption> getPurchaseReasonOptions(){
        return picklistvalues(CIF__c.Purpose__c);
    }
    public List<SelectOption> getFourWheelerOptions(){
        return picklistvalues(CIF__c.Four_Wheeler__c);
    }
    public List<SelectOption> getOccupationOptions(){
        return picklistvalues(CIF__c.Occupation__c);
    }
    public List<SelectOption> getNoOfVehiclesOptions(){
        return picklistvalues(CIF__c.No_of_Vehicles__c);
    }
    /*public List<String> getFirstNameChars() {
        if(cif != null && String.isNotBlank(cif.FirstName__c))
        	return splitToChars(cif.FirstName__c);
        else
            return squareBoxes(6);
    }

    public List<String> getMiddleNameChars() {
        if(cif != null && String.isNotBlank(cif.MiddleName__c))
        	return splitToChars(cif.MiddleName__c);
        else
            return squareBoxes(6);
    }

    public List<String> getLastNameChars() {
        if(cif != null && String.isNotBlank(cif.LastName__c))
        	return splitToChars(cif.LastName__c);
        else
            return squareBoxes(6);
    }
    
    public List<String> getUnitNum() {
        return splitToChars(opp.RW_Project_Unit__r.Name);
    }
    
    public List<String> getFamilyMembers() {
        if(cif != null && cif.No_of_Family_Members__c != null)
        	return splitToChars(String.valueOf(cif.No_of_Family_Members__c));
        else
            return squareBoxes(6);
    }
    
    public List<String> getPinCode() {
        if(cif != null && String.isNotBlank(cif.ZipCode__c))
        	return splitToChars(cif.ZipCode__c);
        else
            return squareBoxes(6);
    }
    
    public List<String> getAddress() {
        if(cif != null && String.isNotBlank(cif.Current_Residential_Address__c)){
            return splitToChars(cif.Current_Residential_Address__c);
        }else{
            return squareBoxes(42);
        }
    }
    
    public List<String> getCompanyName() {
        if(cif != null && String.isNotBlank(cif.CompanyName__c)){
            return splitToChars(cif.CompanyName__c);
        }else{
            return squareBoxes(21);
        }
    }
    
    public List<String> getIndustry() {
        if(cif != null && String.isNotBlank(cif.Industry__c)){
            return splitToChars(cif.Industry__c);
        }else{
             return squareBoxes(19);
        }
        
    }
    
    public List<String> getDesignation() {
        if(cif != null && String.isNotBlank(cif.Designation__c)){
            return splitToChars(cif.Designation__c);
        }else{
             return squareBoxes(18);
        }
    }
    
    public List<String> getNoOfVehicles() {
        if(cif != null && cif.No_of_Vehicles__c != null){
            return splitToChars(String.valueOf(cif.No_of_Vehicles__c));
        }else{
            return squareBoxes(4);
        }
    }
    
    private List<String> splitToChars(String name) {
        List<String> chars = new List<String>();
        if (String.isNotBlank(name)) {
            for (Integer i = 0; i < name.length(); i++) {
                System.debug('Char: ' + name.substring(i, i+1));
                chars.add(name.substring(i, i+1));
            }
        }else{
            for (Integer i = 0; i < 6; i++) {
                chars.add('');
            }
        }
        return chars;
    }
    
    private List<String> squareBoxes(Integer count) {
        List<String> chars = new List<String>();
        for (Integer i = 0; i < count; i++) {
            chars.add('');
        }
        return chars;
    }*/
}