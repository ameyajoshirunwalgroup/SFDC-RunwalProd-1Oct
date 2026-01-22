public class NameConfirmationController {
    public Name_Confirmation form { get; set; }

    public NameConfirmationController() {
        Id bkgId = ApexPages.currentPage().getParameters().get('id');
        List<Applicant_Details__c> appList = [SELECT Id,Name,Applicant_Number__c,PancardNo__c,Booking__r.Unit_No__r.Name,Permanent_Address__c,Email_Address__c
                                              FROM Applicant_Details__c WHERE Booking__c =: bkgId];
        DateTime d = System.now();
		String formattedDate = d.format('dd-MM-yyyy', 'GMT');
        form = new Name_Confirmation();
        form.dt = formattedDate;
        form.Flat_No = appList[0].Booking__r.Unit_No__r.Name;
        for(Applicant_Details__c app : appList){
            if(app.Applicant_Number__c == 'Primary Applicant'){
                form.Applicant1_Name = app.Name;
                form.Applicant1_PAN = app.PancardNo__c;
                form.Address = app.Permanent_Address__c;
        		form.Email = app.Email_Address__c;
            }else if(app.Applicant_Number__c == 'Second Applicant'){
                form.Applicant2_Name = app.Name;
                form.Applicant2_PAN = app.PancardNo__c;
            }else if(app.Applicant_Number__c == 'Third Applicant'){
                form.Applicant3_Name = app.Name;
                form.Applicant3_PAN = app.PancardNo__c;
            }else if(app.Applicant_Number__c == 'Fourth Applicant'){
                form.Applicant4_Name = app.Name;
                form.Applicant4_PAN = app.PancardNo__c;
            }
        }
        //form.Address = appList[0].Permanent_Address__c;
        //form.Email = appList[0].Email_Address__c;
        System.debug('form: ' + form);
    }

    public static String generateAndSendForm(Id formId) {
        System.debug('generateAndSendForm:');
        PageReference pdfPage = Page.NameConfirmationPDF;
        pdfPage.getParameters().put('id', formId);
        //Blob pdfBlob = pdfPage.getContentAsPDF();
        Blob pdfBlob;
        if(Test.isRunningTest()){
            pdfBlob = Blob.valueOf('Test');
        }else{
             pdfBlob = pdfPage.getContentAsPDF();
        }

        List<Booking__c> bkg = [SELECT Id,NCF_Document_Id__c FROM Booking__c WHERE Id =: formId];
        if(bkg.size() > 0 && bkg[0].NCF_Document_Id__c != null){
            String ncfUrl = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId  =: bkg[0].NCF_Document_Id__c].DistributionPublicUrl;
            return ncfUrl;
        }else{
            ContentVersion cv = new ContentVersion(
                Title = 'NameConfirmation_' + formId,
                PathOnClient = 'NameConfirmationForm.pdf',
                VersionData = pdfBlob
            );
            insert cv;
            System.debug('cv: ' + cv);
            Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            System.debug('docId: ' + docId);
            
            ContentDistribution dist = new ContentDistribution(
                Name = 'Name Confirmation Form',
                ContentVersionId = cv.Id,
                PreferencesAllowViewInBrowser = true,
                PreferencesAllowOriginalDownload = true
            );
            insert dist;
            System.debug('dist: ' + dist);
            ContentDistribution distr = [SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE Id =: dist.Id];
            System.debug('distr: ' + distr);
            //String linkUrl = distr.DistributionPublicUrl;
            bkg[0].NCF_Document_Id__c = docId;
            BookingTriggerHandler.byPass =true;
            update bkg[0];
            BookingTriggerHandler.byPass =false;
            return distr.DistributionPublicUrl;
        }
        
        //String base64String = EncodingUtil.base64Encode(pdfBlob);
        //System.debug('base64String: ' + base64String);
        
        //return base64String;
    }
    
    public class Name_Confirmation{
        public String dt { get; set; }
        public String Flat_No { get; set; }
        public String Applicant1_Name { get; set; }
        public String Applicant1_PAN { get; set; }
        public String Applicant2_Name { get; set; }
        public String Applicant2_PAN { get; set; }
        public String Applicant3_Name { get; set; }
        public String Applicant3_PAN { get; set; }
        public String Applicant4_Name { get; set; }
        public String Applicant4_PAN { get; set; }
        public String Nominee_Name { get; set; }
        public String Nominee_PAN { get; set; }
        public String POA_Name { get; set; }
        public String POA_PAN { get; set; }
        public String Address { get; set; }
        public String Contact { get; set; }
        public String Email { get; set; }
        public String Reside_in_MMR { get; set; }
        public String Reside_Overseas { get; set; }
    }
}