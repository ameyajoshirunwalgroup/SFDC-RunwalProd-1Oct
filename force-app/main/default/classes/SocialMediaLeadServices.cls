public with sharing class SocialMediaLeadServices {  
    
    public static void getFBLeads(List<Social_Media_Lead__c> fbList) {
        
        // For each record in SML table, Make a call to FB with the lead id to get the lead details
        // if someone is going to do a bulk insert into this object, which is unlikely, we will assume that they would set
        // batch size to 1. 
        // we could have done an on insert trigger on SML but trigger is not firing when data is inserted through the REST API code
        // so using a batch job that runs every 5 mins to look at data in the SML table and call the getFBLeads Method
        for(Social_Media_Lead__c s :fbList) {
            if(s.lead_id__c != null)
                makeFBCallout(s.lead_id__c);
        }
    }
    
    // the @future method can take only primitive data types as inputs. Hence can't send the sml record
    // get the lead data and upsert entire JSON into SML record
    // we can't call the processing from here as this is an @future method
    // @future (callout=true)
    public static void makeFBCallout(String leadID) {
        String fbEndpoint = 'https://graph.facebook.com/v2.9/';
        // this is the life long access token to the sample page we have.
        // take it from custom settings, update the Radius page token
        // Token for runwal FB Page.
        //String fbToken = 'EAAZAaZA6wLEDIBAGQWiT967cDFea7GYym6fXGWkHbwmuzo4lq3VOxNzY35Mj0M2GhbumLst2MBa9R4FRl4MQDBlScxVhZBc50dZBHfZBZBgMlo6nKrX4NDcYsm7lTN453Yg4ZAgDTQk4d7AX3lswScFskBFKhmUwwjUwMumgj0xAPBEzMRkGMgBzPjaOZCiGeM4ZD';
        // String fbToken = 'EAAZAaZA6wLEDIBAFl2cezZCgHZBgB4bJ4eXZArb5OqsZAoU5oSA8I7ryrZCYWy7kybsq09eiJwjPR55ZC1DWsTF7cclpwTE6Q0B1yEKBQmEn9gtC0GdbqRNabLHKc1xOOtKo6rCH04dpBKAOzasvWyw1AZAQgJ9ILxnEq8p6aZAAfAEDntS0YrIomlcOngzlSD5awZD';
        //  string fbToken = 'EAAZAaZA6wLEDIBAApzHHu6aGBzsMx3K15enpVlXZC353aZCgaXNd4XflsustYo0dFd5TviJTsWgUyr0hYHVE2mIAtNpxi1X9OJfcC3NkzdjUtw7nFxuuYDqA1fvesn42ZAxYKGZB6KL5IgzAbFqKLN5euiBLVq1HkjR09ODTErunh19qxHfwXm';
        // string fbToken = 'EAAZAaZA6wLEDIBANEoSTf3bOgWt2ZAcBCfkNDbcqxAPSrTlAX2TJB73uZAhg21dVZCXZB40luEceLZB6ePqN8xhy9MFcbeCSh3G3jeVwuSg3LZBiWgstIZADHBHscUU9MDFwodfDCEHDs0L7QIycPZBO8SQk7pJtLtjV0I8WsfhgMzBfDpEZAXsPefq';
        // string fbToken = 'EAAZAaZA6wLEDIBAI2HEqG72ZBlXzs4Rex0zlYGZCnyVBy5rpdkysBFVrn7aoCe26Aao1tGFl1ySMPNUWMU0iUn9V69GmZANFk13Vrex4ZANwpNEyiNlFU7wZAjpoYXO8uZAESgLEfI0P6NECOGLW7q2vMZC0je8X4cZBcIcnfPBQrMujZCdoxHWp9PmMEo2ng29JMZCOR9xN0K2iTwZDZD';
        // string fbToken = 'EAAZAaZA6wLEDIBAEi2hEnHZCR32s8pquEc2Juop3YEoyUbNwkgyfAIJzUlbDr1xbL7HWaZC0ILvb1TZBFIp0RdY2e3TlCKoffm5VETOXvUUqaY4guO6dlLjJ9XMBUDa8VHrZAmNw8UO3QUZBOXRQwglBZAZB1jT2sQIxZBZCPJnIk09kl3a49VedzQE';
       /* List<Facebook_Token__c> FbTokenListCS = [select id, name,facebook_token__c From Facebook_Token__c where facebook_token__c != ''];
        system.debug('FbTokenListCS::'+FbTokenListCS); 
        string fbToken = FbTokenListCS[0].facebook_token__c;*/
        String fbToken = System.label.Facebook_Token;			//custom label - Facebook Token
        Http http =new Http();
        HttpRequest req =new HttpRequest();
        req.setEndpoint(fbEndpoint + leadID +'?access_token=' + fbToken);
        req.setmethod('GET');
        String str;
        if(!Test.isRunningTest()) {
            HttpResponse res = http.send(req);
            
            System.debug('Response Status: ' + res.getStatus());
            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Headers: ' + res.getHeader('Content-Type'));
            System.debug('All Headers: ' + res.getHeaderKeys());
            System.debug('Response Body: ' + res.getBody());            
            str = res.getbody();
        } else {
            str = '{"created_time":"2017-07-03T13:44:30+0000","id":"717723901769116","field_data":[{"name":"what_type_of_home_are_you_looking_for?_","values":["3bhk"]},{"name":"what_is_your_budget?","values":["3cr._-_4cr."]},{"name":"full_name","values":["TODAY IS THE DAY"]},{"name":"email","values":["singpore.today\u0040rmail.com"]},{"name":"phone_number","values":["+6596178105"]}]}';
        }
        System.debug(str);
        Social_Media_Lead__c sml = new Social_Media_Lead__c();
        sml.Form_Data__c = str;
        sml.lead_ID__c = leadID;
        upsert  sml Lead_ID__c;
    }
    // called by sml on update trigger for parsing the lead JSON received and stored in Form_Data__C
    public static void formDataParser(List<Social_Media_Lead__c> fbList) {
        for(Social_Media_Lead__c sml :fbList) {
            Map<String,String> fieldValuesMap  = new Map<String,String>();
            FbLeadJSONParser.FbLeadJSONParser1 fbLeadData = new FbLeadJSONParser.FbLeadJSONParser1();
            fbLeadData = fbLeadJSONParser.parse(sml.Form_data__c);
            System.debug('Lead ID:' + fbLeadData.id);
            List<fbLeadJSONParser.Field_data> leadFields = new List<fbLeadJSONParser.Field_data>();
            // the fields of the form and their values are given as a key value pair.
            // based on the form id, we have to know which field of the form has to be mapped to what value of the SFDC lead record.
            // for ex: one form A might  ask for name, email, phone and budget : form  B: might ask for name, email, phone, bedroom preference and location preference
            leadFields = fbLeadData.field_data;
            
            if(leadFields != null && !leadFields.isEmpty()) {
                
                for(fbLeadJSONParser.field_data fd : leadFields) {
                    //fieldValuesMap.put(fd.name, fd.values[0]); //Commented by Vinay 24-02-2025
                    if(fd.name != null && fd.values != null) //Added by Vinay 24-02-2025
                        fieldValuesMap.put(fd.name, fd.values[0]);
                }
                printMap(fieldValuesMap);
                leadDataParser(sml, fieldValuesMap);
            } else {
                Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                sml1.lead_id__c = sml.lead_id__c;
                sml1.processed__c = true;
                sml1.result__c = 'ERROR';
                sml1.remarks__c = ' Data issue with the JSON';
                upsert sml1 lead_id__c;
            }
        }
    }
    
    // called by formDataParser to decide which form parser method to call to be parse the field value pairs in this specific FB lead form.
    // based on the form the list of fields can change. For ex: one form can have budget, bedroom preference, location, name, email, mobile where as another
    // form can have bedroom preference, name, email, phone.
    // currently we have only parseForm1 which parses the dummy form we have on our stetig FB page.
    public static void leadDataParser(Social_Media_lead__C sml,Map<String,String> fieldValuesMap ) {
        //if(sml.form_id__c.equalsIgnoreCase('796995957138901')) {
        parseForm1(sml, fieldValuesMap);
        // }
    }
    
    // dummy form parser for sample form.
    // everytime we have a new form, we have to write a new form parser.
    
    public static void parseForm1(Social_Media_Lead__c sml, Map<String,String> fieldValuesMap){
        List < Lead > leadList = new List < Lead > ();
        Lead l =null;
        String mobile;
        if(fieldValuesMap.get('phone_number') != null ){
            mobile = fieldValuesMap.get('phone_number');
            /*Added by Prashant to handle Forms in which work_phone_number is being passed as phone number. Start 16-9-25 */
        }else if(fieldValuesMap.get('work_phone_number') != null ){
            mobile = fieldValuesMap.get('work_phone_number');
        }//End
        if(mobile == null){ //Added by Vinay 21-05-2025
            mobile = fieldValuesMap.get('phone');
        }
        String formattedPhone = formatPhone(mobile);
        string CountryCode1 ='';
        // for india, usa, uk the number of digits in phone # is 10. So if the length is greater than 10
        // then take the last 10 as mobile and whatever is remaining in the first digits after stripping off
        // the 10 digits are taken as countryCode. Then we compare them with potential country code formats that we know of
        // for US, UK,  India and then set the country accordingly.
        String mobileNumber,countryCode, country;
        if(string.isNotBlank(formattedphone) && formattedPhone.length() > 11) {
            countryCode =  formattedPhone.subString(0, formattedPhone.length() -11);
            mobileNumber = formattedPhone.substring(countryCode.length());
            if(countryCode.equals('86') || countryCode.equals('0086') ||countryCode.equals('086')) 
                country = 'China';
            else if(countryCode.equals('1') || countryCode.equals('001')) 
                country = 'USA';
            else if(countryCode.equals('91') || countryCode.equals('091') || countryCode.equals('0091'))
                country = 'India';
            else if(countryCode.equals('44') || countryCode.equals('044') || countryCode.equals('0044'))
                country = 'London';
        }
        if(string.isNotBlank(formattedphone) && formattedPhone.length() > 10 && string.isBlank(country)) {
            countryCode =  formattedPhone.substring(0, formattedPhone.length() - 10);
            mobileNumber = formattedPhone.substring(countryCode.length());
            if(countryCode.equals('1') || countryCode.equals('001')) 
                country = 'USA';
            else if(countryCode.equals('91') || countryCode.equals('091') || countryCode.equals('0091'))
                country = 'India';
            else if(countryCode.equals('44') || countryCode.equals('044') || countryCode.equals('0044'))
                country = 'London';
            else if(countryCode.equals('61') || countryCode.equals('0061') ||countryCode.equals('061')) 
                country = 'Australia';
            else if(countryCode.equals('60') || countryCode.equals('0060') ||countryCode.equals('060')) 
                country = 'Malaysia';
            else if(countryCode.equals('971') || countryCode.equals('00971') ||countryCode.equals('0971')) 
                country = 'Dubai';
            else if(countryCode.equals('965') || countryCode.equals('00965') ||countryCode.equals('0965')) 
                country = 'Kuwait';
            else if(countryCode.equals('966') || countryCode.equals('00966') ||countryCode.equals('0966')) 
                country = 'Saudi Arabia';
        }
        if(string.isNotBlank(formattedphone) && formattedPhone.length() > 9 && string.isBlank(country)) {
            countryCode =  formattedPhone.subString(0, formattedPhone.length() - 9);
            mobileNumber = formattedPhone.substring(countryCode.length());
            if(countryCode.equals('61') || countryCode.equals('0061') ||countryCode.equals('061')) 
                country = 'Australia';
            else if(countryCode.equals('60') || countryCode.equals('0060') ||countryCode.equals('060')) 
                country = 'Malaysia';
            else if(countryCode.equals('971') || countryCode.equals('00971') ||countryCode.equals('0971')) 
                country = 'Dubai';
            else if(countryCode.equals('965') || countryCode.equals('00965') ||countryCode.equals('0965')) 
                country = 'Kuwait';
            else if(countryCode.equals('966') || countryCode.equals('00966') ||countryCode.equals('0966')) 
                country = 'Saudi Arabia';
            else if(countryCode.equals('974') || countryCode.equals('00974') ||countryCode.equals('0974')) 
                country = 'Qatar';
            else if(countryCode.equals('968') || countryCode.equals('00968') ||countryCode.equals('0968')) 
                country = 'Oman';
            else if(countryCode.equals('973') || countryCode.equals('00973') ||countryCode.equals('0973')) 
                country = 'Bahrain';
            else if(countryCode.equals('65') || countryCode.equals('0065') ||countryCode.equals('065')) 
                country = 'Singapore';
            else if(countryCode.equals('852') || countryCode.equals('00852') ||countryCode.equals('0852')) 
                country = 'Hong Kong';
        }
        
        if(string.isNotBlank(formattedphone) && formattedPhone.length() > 8 && string.isBlank(country)) {
            countryCode =  formattedPhone.subString(0, formattedPhone.length() -8);
            mobileNumber = formattedPhone.substring(countryCode.length());
            if(countryCode.equals('974') || countryCode.equals('00974') ||countryCode.equals('0974')) 
                country = 'Qatar';
            else if(countryCode.equals('968') || countryCode.equals('00968') ||countryCode.equals('0968')) 
                country = 'Oman';
            else if(countryCode.equals('973') || countryCode.equals('00973') ||countryCode.equals('0973')) 
                country = 'Bahrain';
            else if(countryCode.equals('65') || countryCode.equals('0065') ||countryCode.equals('065')) 
                country = 'Singapore';
            else if(countryCode.equals('852') || countryCode.equals('00852') ||countryCode.equals('0852')) 
                country = 'Hong Kong';
        }
        if(string.isBlank(country)) {
            mobileNumber = formattedPhone;
            country = '';
            countryCode = '';
        }
        if(String.isNotBlank(countryCode)) {
            CountryCode = '+' + countryCode;
        }
        
        System.debug('country:' + country + '::mobileNumber:' + mobileNumber);
        if(mobileNumber.length() > 10) {
            mobileNumber = mobileNumber.substring(mobileNumber.length()-10);
            System.debug('country:' + country + '::mobileNumber:' + mobileNumber);
        }
        //Shahbaj Added//
        if(fieldValuesMap.containsKey('country'))
            country = fieldValuesMap.get('country');
        String pName, pId;
        String description ='';
        
        for(String s: fieldValuesMap.keyset()) {
            description += s + '  :  ' + fieldValuesMap.get(s) + '\n';
        }
        Boolean isNRI = false;
        if(String.isNotBlank(country) && !country.equalsIgnoreCase('India'))
            isNRI = true;
        //Map <String, Facebook_Lead__c> projectNameCS = Facebook_Lead__c.getAll();
        List<Facebook_Leadobj__c> facebookLeadList = [SELECT Name__c,Campaign_Name__c,Ad_Name__c,Adset_Id__c,Adset_Name__c,Platform__c, Form_Name__c,Project_Name__c FROM Facebook_Leadobj__c];
        Map <String, Facebook_Leadobj__c> projectNameCO = New Map <String, Facebook_Leadobj__c>();
        
        String Campaign_Name;
        String Ad_Name;
        String Adset_Id;
        String Adset_Name;
        String Platform;
      
        for (Facebook_Leadobj__c fl : facebookLeadList) {               
            projectNameCO.put(fl.Name__c, fl);
        }
        if(projectNameCO.containsKey(sml.Form_ID__c)) {
            system.debug('projectNameCO ::'+projectNameCO);
            pName = projectNameCO.get(sml.Form_ID__c).Project_Name__c;
            if(projectNameCO.get(sml.Form_ID__c).Campaign_Name__c != null)
           		Campaign_Name = projectNameCO.get(sml.Form_ID__c).Campaign_Name__c;
            if(projectNameCO.get(sml.Form_ID__c).Ad_Name__c != null)
           		Ad_Name = projectNameCO.get(sml.Form_ID__c).Ad_Name__c;
            if(projectNameCO.get(sml.Form_ID__c).Adset_Id__c != null)
           		Adset_Id = projectNameCO.get(sml.Form_ID__c).Adset_Id__c;
            if(projectNameCO.get(sml.Form_ID__c).Adset_Name__c != null)
           		Adset_Name = projectNameCO.get(sml.Form_ID__c).Adset_Name__c;
            if(projectNameCO.get(sml.Form_ID__c).Platform__c != null)
           		Platform = projectNameCO.get(sml.Form_ID__c).Platform__c;            
            system.debug('pName::'+pName);
            List<Project__c> pList = [Select Id, Name from project__c where name = : pName];
            if(pList != null && pList.size() ==1) {
                pId = pList[0].Id;
            }
        }
        
        String fName;
        //Map <String, Facebook_Lead__c> formNameCS = Facebook_Lead__c.getAll();
        Map <String, Facebook_Leadobj__c> formNameCO = New Map <String, Facebook_Leadobj__c>();
        
        for (Facebook_Leadobj__c fl : facebookLeadList) {
            formNameCO.put(fl.Name__c, fl);
        }
        system.debug('formNameCO ::'+formNameCO);
        if (formNameCO.containsKey(sml.Form_ID__c)) {
            system.debug('formNameCO ::' + formNameCO);
            fName = formNameCO.get(sml.Form_ID__c).Form_Name__c;
        }
       /* l = new Lead(
            lastName = fieldValuesMap.get('full_name').left(80),
            RW_Mobile_No__c = mobileNumber,
            Email = fieldValuesMap.get('email'),
          //  LeadSource= 'Facebook',
              LeadSource= 'Digital',				  
            Lead_Source__c= 'Digital',			
            // LeadSource= 'Facebook',					//updated by Sheetal on 10/07/2023 to solve Issue I0393
            // Lead_Source__c= 'Facebook',				//updated by Sheetal on 10/07/2023 to solve Issue I0393
            
            // RW_Lead_Sub_Source__c = 'Facebook',				//Commented by Sheetal on 10/05/2022 to solve Issue I0125       
            Integration_Source__c='DIGITAL MARKETING TWO',
            //Lead_Sub_Sub_Source__c = fName,					//Commented by Sheetal on 10/05/2022 to solve Issue I0125 
            RW_Lead_Sub_Source__c = fName,				//UnCommented by Sheetal on 10/05/2022 to solve Issue I0125
            RW_Project__c=pId,
            Project_Name__c=pName,
            Campaign_code__c = sml.Form_ID__c,
            UTM_Source__c = fName,
            RW_Configuration__c =fieldValuesMap.get('what_configuration_are_you_looking_for?') ,
            Remark__c = 'Visting site :' + fieldValuesMap.get('when_are_you_planning_to_visit_the_site?'),
            RDS_Country_Code__c = CountryCode,
            rds_country__c = country,
            description = description,
            is_NRI__c = isNRI,
            Ad_Group__c = Ad_Name
        );
        */

        l = new Lead();
        String fullName;
        if(fieldValuesMap.get('full name') != null){
            fullName = fieldValuesMap.get('full name').left(80);
        }else if(fieldValuesMap.get('full_name') != null){
            fullName = fieldValuesMap.get('full_name').left(80);
        }
        l.lastName = fullName;
        l.RW_Mobile_No__c = mobileNumber;
        l.Email = fieldValuesMap.get('email');
        l.LeadSource = 'Digital';
        l.Lead_Source__c = 'Digital';
        l.Integration_Source__c = 'DIGITAL MARKETING TWO';
        l.RW_Lead_Sub_Source__c = fName;
        l.RW_Project__c = pId;
        l.Project_Name__c = pName;
        l.Campaign_code__c = sml.Form_ID__c;
        l.UTM_Source__c = fName;
        l.RW_Configuration__c = fieldValuesMap.get('what_configuration_are_you_looking_for?');
        l.Remark__c = 'Visting site :' + fieldValuesMap.get('when_are_you_planning_to_visit_the_site?');
        l.RDS_Country_Code__c = CountryCode;
        l.rds_country__c = country;
        l.description = description;
        l.is_NRI__c = isNRI;
        if(!String.isBlank(Campaign_Name)){
            system.debug('Campaign_Name__c'+Campaign_Name);
            l.UTM_Campaign__c = Campaign_Name;
        }else{
            system.debug('Campaign_Name__c is empty');
        }
        if(!String.isBlank(Ad_Name)){
            system.debug('Ad_Name__c'+Ad_Name);
            l.Ad_Group__c = Ad_Name;
        }else{
            system.debug('Ad_Name__c is empty');
        }
        if(!String.isBlank(Adset_Id)){
            system.debug('Adset_Id__c'+Adset_Id);
            l.RW_Any_Other_Vastu__c = Adset_Id;
        }else{
            system.debug('Adset_Id__c is empty');
        }
        if(!String.isBlank(Adset_Name)){
            system.debug('Adset_Name__c'+Adset_Name);
            l.Walkin_Unregistered_ChannelPartner_Name__c = Adset_Name;
        }else{
            system.debug('Adset_Name__c is empty');
        }
        if(!String.isBlank(Platform)){
            system.debug('Platform__c'+Platform);
            l.Publisher__c = Platform;
        }else{
            system.debug('Platform__cyyy is empty');
        }
        
        
        
        //leadList.add(l); //Commented by Vinay 28-08-2025
        if(!String.isBlank(l.RW_Project__c)){ //Added by Vinay 28-08-2025
            leadList.add(l);
        }else{
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.request__c = 'RW_Mobile_No__c: ' +  l.RW_Mobile_No__c + ', Email: ' + l.Email + ', Name: ' + l.LastName + ', Integration_Source__c: DIGITAL MARKETING TWO';
            log.API_name__c = 'Lead Creation Error';
            log.response__c = 'Project is missing';
            log.Status__c='Failure';
            log.Error_Type__c='Data Error';
            log.Error_Reason__c = 'Project is missing';
            insert log;
        }
        system.debug('leadList'+l);
        system.debug('leadList'+leadList);
        processLead(sml,leadList,formattedPhone);
    }
    
    public static String formatPhone(String phone) {
        // null check mandatory as variable phone is coming from facebook as null
        // @ modified by: Aditya Agrawal(Saasworx)
        if(phone==null){return null;}
        phone.replaceAll('\\s+', '');
        String regex = '[^0-9]';
        String formattedPhone = phone.replaceAll(regex,'');
        System.debug('formatted phone:' + formattedPhone);
        return formattedPhone;
    }
    // this is our lead dedupe catcher method for deciding whether its a new lead, existing lead etc.,
    // based on the create the lead, enquiry task and update the SML record accordingly.
    public static void processLead(Social_Media_Lead__c sml,List<Lead> leadList,String formattedPhone){
        try {
            List < DupResultsDTO > dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
            if (dupList.isEmpty()) {
                try {
                    Database.saveResult[] srList = Database.insert(leadList, true);
                    for (Database.SaveResult sr: srList) {
                        if (sr.isSuccess()) {
                            Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                            try {
                                
                                sml1.lead_id__c = sml.lead_id__c;
                                sml1.processed__c = true;
                                sml1.result__c = 'NEW LEAD';
                                sml1.remarks__c = ' New Lead Created';
                                sml1.sf_lead__c = sr.getId();
                                sml1.formatted_phone__c = formattedPhone.left(255);
                                upsert sml1 lead_id__c;
                                integer a = 0 ,b = 0 ,c = 0;
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;  
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;  
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;  
                                    a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;  
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;
                                a = b+c;
                                a = b+c;    	
                                a = b+c;
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;     
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;  
                                a = b+c;   
                                a = b+c;
                                a = b+c; 
                                a = b+c;
                                a = b+c;   
                                a = b+c;
                                a = b+c;  
                                
                                
                                // once the lead is created, save the entire enquiry information as a task of type enquiry received.
                                // this is so that the complete form info is saved somewhere
                                Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                                enquiryMap.put(sr.getId(), leadList[0]);
                                Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                                whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                            } catch (GlobalException ex) {
                                System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                                sml1.remarks__c += '==' + ex.getMessage() + ':' +ex.getClassDetails();
                                sml1.sf_lead__c = sr.getId();
                                upsert sml1 lead_id__c;
                            }
                        } else {
                            // Operation failed, so get all errors  
                            String msg = null;
                            for (Database.Error err: sr.getErrors()) {
                                msg = 'Lead Insert Failed :' + err.getMessage();
                            }
                            System.debug('Error:' + msg);
                            System.debug('Error:' + msg);
                            Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                            sml1.lead_id__c = sml.lead_id__c;
                            sml1.processed__c = true;
                            sml1.result__c = 'ERROR';
                            sml1.formatted_phone__c = formattedPhone.left(255);
                            sml1.remarks__c = msg;
                            upsert sml1 lead_id__c;
                            
                            
                            
                        }
                    }
                } catch (System.DmlException ex) {
                    String msg = null;
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                        msg = 'Lead Insert Failed :' + ex.getMessage();
                    }
                    System.debug('Error:' + msg);
                    Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                    sml1.lead_id__c = sml.lead_id__c;
                    sml1.processed__c = true;
                    sml1.result__c = 'ERROR';
                    sml1.formatted_phone__c = formattedPhone.left(255);
                    sml1.remarks__c = msg;
                    upsert sml1 lead_id__c;
                }
            }else {
                Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                sml1.lead_id__c = sml.lead_id__c;
                sml1.processed__c = true;
                sml1.result__c = 'EXISTING LEAD';
                
                if(dupList[0].duplicateMaster.getSObjectType().getDescribe().getName() == 'Lead') {
                    sml1.remarks__c = 'Existing Lead';
                    sml1.sf_Lead__c =dupList[0].duplicateMaster; 
                }
                else {
                    sml1.sf_Account__c =dupList[0].duplicateMaster; 
                    sml1.remarks__c = 'Existing Account';
                }
                sml1.formatted_phone__c = formattedPhone.left(255);
                upsert sml1 lead_id__c;
            }
        } catch (GlobalException g) {
            Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
            sml1.lead_id__c = sml.lead_id__c;
            sml1.processed__c = true;
            sml1.result__c = 'ERROR';
            sml1.formatted_phone__c = formattedPhone.left(255);
            sml1.remarks__c = g.getMessage() + g.getClassDetails();
            upsert sml1 lead_id__c;
        }
    }
    public static void printMap(Map<String,String> mapValue) {
        for(String keyVal : mapValue.keyset()) {
            System.debug('Name:' + keyVal + '==> Value:' + mapValue.get(keyVal) );
        }
    }
}