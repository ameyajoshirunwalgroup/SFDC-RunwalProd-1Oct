@RestResource(urlMapping='/cpGetPicklistValues/*')
global without sharing class Lockated_CPGetPicklistValues {
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @HttpGet
    global static ResponseWrapper doGet() {
        ResponseWrapper res = new ResponseWrapper();

        //Get Projects
        /*if (data == 'getProjects') {
            for (Project__c proj : [SELECT Name FROM Project__c WHERE RW_Status__c = 'Active']) {
                res.values.add(proj.Name);
            }
        }*/
        //Get CP Type
        res.getCPType = getPicklistValues('Broker__c', 'Broker_Type__c');
        //Get Experience Values
        res.getCPExperiences = getPicklistValues('Broker__c', 'Experience__c');
        //Get Operation Place Values
        res.getCPOperationPlaces = getPicklistValues('Broker__c', 'Place_of_Supply__c');
        //Get Expertise Values
        res.getCPExpertise = getPicklistValues('Broker__c', 'Expertise__c');
        //Get Developers Worked For Values
        res.getDevelopersWorkedFor = getPicklistValues('Broker__c', 'Developers_Worked_For__c');
        //Get Bank Names
        res.getBankNames = getPicklistValues('Broker__c', 'Bank_Name__c');
		//Get Case Category and Sub Category
        res.getcaseCatSubCat = getDependentPicklist('Case', 'Case_Category__c','Case_Sub_Category__c');
        //Opportunity to be kept mandatory for Category - Payment Related and Category - Invoice Related.
        //
        //Get Team Size
        res.getTeamSize = getPicklistValues('Broker__c', 'Team_Size__c');
        
        res.getCountryCode = getPicklistValues('Account', 'Country_Code__c');
        
        res.getPropertyTypefromLead = getPicklistValues('Lead', 'Project_Type__c');
        
        res.getYears = getPicklistValues('Broker__c', 'CP_APP_Years__c');
        
        //res.getCountrywiseCountryCode = getDependentPicklist('Lead','RDS_Country__c','RDS_Country_Code__c');
        
        res.getCountryStateCity = getThreeLevelPicklistNew('Lead','Country__c','State__c','City__c');
        
        res.getProjectNames = new List<String>();
        List<Project__c> activeProjects = [SELECT Name FROM Project__c WHERE RW_Status__c = 'Active'];
        if(!activeProjects.isEmpty()){
            for (Project__c proj : activeProjects) {
                if(proj.Name!=null){
                	res.getProjectNames.add(proj.Name);
                }
            }
        }
        //res.getCountryStateCity = getThreeLevelPicklist('Lead','Country__c','State__c','City__c');
        //res.getCountryState = getDependentPicklist('Lead','Country__c','State__c');
        //res.getStateCity = getDependentPicklist('Lead','State__c','City__c');
        
        system.debug('getDependentPicklist Country > State -> '+ getDependentPicklist('Lead','Country__c','State__c'));
        system.debug('getDependentPicklist State > City -> '+ getDependentPicklist('Lead','State__c','City__c'));
        return res;
    }
    
    global class ResponseWrapper {
        //public String getProjects;
        public list<String> getCPType;
        public list<String> getCPExperiences;
        public list<String> getCPOperationPlaces;
        public list<String> getCPExpertise;
		public list<String> getDevelopersWorkedFor;
        public list<String> getBankNames;
        public list<String> getTeamSize;
        public list<String> getPropertyTypefromLead;
        public list<String> getCountryCode;
        //public PicklistWrapper getCountrywiseCountryCode;
        public PicklistWrapper getcaseCatSubCat;
        //public PicklistWrapper getCountryState;
        //public PicklistWrapper getStateCity;
        public Map<String, Map<String, List<String>>> getCountryStateCity;
        public list<String> getYears;
        public list<String> getProjectNames;
    }
    
    private static List<String> getPicklistValues(String objectName, String fieldName) {
        Schema.DescribeFieldResult fieldDescribe =
            Schema.getGlobalDescribe().get(objectName)
                  .getDescribe()
                  .fields.getMap().get(fieldName)
                  .getDescribe();
        
        List<String> results = new List<String>();
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            results.add(entry.getLabel());
        }
        return results;
    }
    
    public static Map<String, Map<String, List<String>>> getThreeLevelPicklistNew(String objectName,String countryField,String stateField,String cityField)
    {
        // Country -> State
        PicklistWrapper countryToState = getDependentPicklist(objectName, countryField, stateField);
        
        // State -> City
        PicklistWrapper stateToCity = getDependentPicklist(objectName, stateField, cityField);
        
        Map<String, Map<String, List<String>>> finalHierarchy = new Map<String, Map<String, List<String>>>();
        
        for (String country : countryToState.pickListMap.keySet()) {
            
            Map<String, List<String>> stateCityMap = new Map<String, List<String>>();
            
            for (String state : countryToState.pickListMap.get(country)) {
                stateCityMap.put(
                    state,
                    stateToCity.pickListMap.containsKey(state) ? stateToCity.pickListMap.get(state) : new List<String>()
                );
            }
            
            finalHierarchy.put(country, stateCityMap);
        }
        
        return finalHierarchy;
    }

    
    
   /* public static Map<String, Map<String, List<String>>> getThreeLevelPicklist(
        String objectName,
        String countryField,
        String stateField,
        String cityField
    ) {
        Map<String, Map<String, List<String>>> hierarchy = new Map<String, Map<String, List<String>>>();
        
        // Step 1: get Country → State map
        PicklistWrapper countryState = getDependentPicklist(objectName, stateField, cityField);
        system.debug('countryState -> '+countryState);
        // Step 2: get State → City map
        PicklistWrapper stateCity = getDependentPicklist(objectName, stateField, cityField);
        system.debug('stateCity -> '+stateCity);
        
        // Step 3: Merge into nested map
        for (String country : countryState.pickListMap.keySet()) {
            Map<String, List<String>> stateToCities = new Map<String, List<String>>();
            for (String state : countryState.pickListMap.get(country)) {
                stateToCities.put(state, stateCity.pickListMap.get(state));
            }
            hierarchy.put(country, stateToCities);
        }
        system.debug('hierarchy -> '+hierarchy);
        return hierarchy;
    }*/
    
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue; 
        public String label;
        public String value;
        public String validFor;
        
    }
    
    public class PicklistWrapper{
        public Map<String, List<String>> pickListMap;
        public String parentFieldLabel;
        public String childFieldLabel;      
    }	

}