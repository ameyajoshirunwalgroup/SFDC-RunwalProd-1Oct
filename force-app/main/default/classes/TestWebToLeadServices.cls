@isTest
private Class TestWebToLeadServices {
  @isTest
  static void createWebLead(){
    TestDataFactory.createProject('Project Xanadu', '111');
    TestDataFactory.createCampaignCCNew( 'Test_campaign_1', 'TV', '2001');
    TestDataFactory.createCampaignCCNew( 'Test_campaign_2', 'TV', '2002');
        
    WebToLeadServices.result wlresult = new WebToLeadServices.result();
      wlresult.message = 'success';
      wlresult.recordId = '00Q1e000001ihgCEAQ';
      wlresult.returnCode = 1;
      
    WebToLeadServices.WebLead wlGood = new WebToLeadServices.WebLead();
    wlGood.fullName = 'Digital Lead';
    wlGood.emailAddress = 'click2call@email.com';
    wlGood.country = 'India';
    wlGood.city = 'Mumbai';
    wlGood.dialingCode = '91';
    wlGood.mobileNumber = '9080706050';
    wlGood.source = 'DIGITAL MARKETING';
    wlGood.projectInterested = 'Project Xanadu';
    wlGood.budget = '7 to 9 Cr';
    wlGood.CampaignCode = '2001'; 
 //   wlGood.source = 'Test Source';
    wlGood.webBannerSource = 'Test web banner';
    wlGood.IPAddress = '192.168.02.201';
   
    WebToLeadServices.WebLead wlBad = new WebToLeadServices.WebLead();
    wlBad.fullName = 'Click2Call Lead';
    wlBad.emailAddress = 'click2call@email.com';
    wlBad.country = 'India';
    wlBad.city = 'Mumbai';
    wlBad.dialingCode = '91';
    wlBad.mobileNumber = '9080706050';
    wlBad.source = 'DIGITAL MARKETING';
    wlBad.projectInterested = 'Xanadu';
    wlBad.budget = '7 to 9 Cr';
    wlBad.CampaignCode = '2001';
    wlBad.webBannerSource = 'Test web banner1';
    wlBad.IPAddress = '192.168.05.202';
    
    WebToLeadServices.WebLead wlUgly = new WebToLeadServices.WebLead();
    
    WebToLeadServices.WebLead wlWorst = new WebToLeadServices.WebLead();
    wlWorst.fullName = 'Digital Lead';
    wlWorst.emailAddress = 'click2call@email.com.com.com.com';
    wlWorst.country = 'India';
    wlWorst.city = 'Mumbai';
    wlWorst.dialingCode = '91';
    wlWorst.mobileNumber = '90807060501234556';
    wlWorst.source = 'DIGITAL MARKETING';
    wlWorst.projectInterested = 'Project Xanadu';
    wlWorst.budget = '7 to 9 Cr';
    wlWorst.CampaignCode = '2001';
    wlWorst.webBannerSource = 'Test web banner3';
    wlWorst.IPAddress = '192.168.05.205';
    
    WebToLeadServices.WebLead wlNew = new WebToLeadServices.WebLead();
    wlNew.fullName = '';
    wlNew.emailAddress = 'click2call@email.com.com.com.com';
    wlNew.country = 'India';
    wlNew.city = 'Mumbai';
    wlNew.dialingCode = '91';
    wlNew.mobileNumber = '90807060501234556';
    wlNew.source = 'DIGITAL MARKETING'; 
    wlNew.projectInterested = 'Project Xanadu';
    wlNew.budget = '7 to 9 Cr';
    wlNew.CampaignCode = '2001';
      
    WebToLeadServices.WebLead wlNew1 = new WebToLeadServices.WebLead();
    wlNew1.fullName = 'TEST1';
   // wlNew1.emailAddress = 'click2call@email.com.com.com.com';
    wlNew1.country = 'India';
    wlNew1.city = 'Mumbai';
    wlNew1.dialingCode = '91';
  //  wlNew1.mobileNumber = '90807060501234556';
    wlNew1.source = 'CHATBOT'; 
    wlNew1.projectInterested = 'Project Xanadu';
    wlNew1.budget = '7 to 9 Cr';
    wlNew1.CampaignCode = '2001';
      
    WebToLeadServices.WebLead wl = new WebToLeadServices.WebLead();
    wl.fullName = 'payal test102';
	wl.emailAddress = 'payal.bedare102@stetig.in';
	wl.country = 'India';
	wl.city = 'Pune';
	wl.dialingCode = '+91';
	wl.mobileNumber = '9999997537';
	wl.projectInterested = 'Runwal Bliss';
	wl.source = 'DIGITAL MARKETING';
	wl.RwLeadSource = 'Loyalty';
    wl.RefereeName = 'payal test diff';
    wl.RefereeMobileNo = '9999999956';
	wl.RefereeEmailId = 'abc@gmail.com';
	wl.RefereeProject = '';
	wl.RefereeFlat = '';
	wl.ReferenceSource = 'Existing Customer';
    wl.budget = '7 to 9 Cr';
    wl.CampaignCode = '2001';
	        
    Test.startTest();
    WebToLeadServices.result rGood = WebToLeadServices.createLeadFromWeb(wlGood);
    WebToLeadServices.result rBad = WebToLeadServices.createLeadFromWeb(wlBad);
    WebToLeadServices.result rUgly = WebToLeadServices.createLeadFromWeb(wlUgly);
    WebToLeadServices.result rWorst = WebToLeadServices.createLeadFromWeb(wlWorst);
    WebToLeadServices.result rNew = WebToLeadServices.createLeadFromWeb(wlNew);
    WebToLeadServices.result rNew1 = WebToLeadServices.createLeadFromWeb(wlNew1);
	WebToLeadServices.result rWl = WebToLeadServices.createLeadFromWeb(wl);
    
    List<lead> l2 = [select Id,Name,Campaign_Code__c from Lead where Id =: rGood.recordId];
     
    system.debug('LEAD LIST CHANGE Campaign**'+l2);
    for(Lead l : l2)
    {
        l.Campaign_Code__c = '2002';
        update l;
    }
    List<lead> l3 = [select Id,Name,RW_Mobile_No__c  from Lead where Id =: rWl.recordId];
    List<Account> aList = [Select Id,Name from Account where Mobile_No__c = : wl.RefereeMobileNo LIMIT 1];
      for(Lead l1 : l3){
          l1.Customer_Reference__c = aList[0].Id;
          update l1;
      }
       List<Opportunity> oList = [Select Id,AccountId,Booking__c from Opportunity Limit 1];
      if(oList.size() == 1){
         String remark = 'Ref by \n'+ wl.RefereeName+'  '+wl.RefereeMobileNo+'\n Booked customer'+'\n'+wl.RefereeProject + ' '+wl.RefereeFlat;
          wl.RwLeadSource = 'Referral';
      }
    
    
    System.assertEquals('INVALID SOURCE', rUgly.message);
    
    System.assertEquals('INVALID PROJECT SELECTED', rBad.message);
    
    List<lead> ll = [Select Id, lastName from Lead where Id = : rGood.recordId];
    System.assertEquals('SUCCESS', rGood.message);
    System.assertEquals(1,ll.size());
    System.assertEquals(rGood.recordId,ll[0].Id);
   
    
    // creating an throwing exception to cover for the global exception class
    // just fitting it inside this TM , its too small have a TM class / method of its own
    Task t = new Task(activityDate = system.today(), subject ='new task', priority='normal', status ='open');
    insert t;
    List < String > customMsgList = new List < String > ();
    String msg = 'Task not created';
    System.debug('Missed Call Task not Created:');
    customMsgList.add(msg);
    try {
      throw new GlobalException(customMsgList, 'ERR001', 'TestMethod');
    } catch(GlobalException g){
      List<String> msg1 = g.getErrorMsg();
      String errCode = g.getErrorCode();
      String className = g.getClassDetails();
    }
    
    Map<String,Set<Id>> dupMap = new Map<String,Set<Id>>();
    DupResultsDTO drDTO = new DupResultsDTO(ll[0], ll[0].Id, t.Id, dupMap);
    
    Test.stopTest();    
    
  }
   @isTest
    private static void applicantdetailtest2(){
        Test.startTest();
    WebToLeadServices.dummy();
         test.stopTest();
    }

}