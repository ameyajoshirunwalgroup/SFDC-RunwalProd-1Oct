@isTest
private  Class TestTaskManagementServices {
  @isTest  
  static void TaskTest() {
    Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
       // List<Opportunity>  oList = New List<Opportunity>();
        List<Lead> llist = TestDataFactory.createLead(3);
        List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
       // Opportunity o = new Opportunity(Name = 'Opp-1', StageName='Qualification', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
       // insert o;
       //  Opportunity o2 = new Opportunity(Name = 'Opp-2', StageName='Qualification', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
      //  insert o2;
        
       // oList.add(o);
       //  oList.add(o2);
        system.debug(oList[0].Name);                
        System.debug('Oplist Size :: ' +oList.size());
          //List<Task> tList1 = TestDataFactory.createTasksForOpp(oList[0].Id, 2, 'Presales Call');
          //List<Task> tList2 = TestDataFactory.createTasksForOpp(oList[1].Id, 2, 'Site Visit');
          List<Task> tskList = new List<Task>();
          task t = new task();
          t.Subject = 'New Task';
          t.Task_Type__c = 'Presales Call';
          t.activityDate = System.Today();
          t.whatId = oList[0].Id;
          t.call_time__c = TaskManagementServices.FormatTime(system.now());
          t.ActivityDate__c = '25/05/2021';
          t.ActivityDate = System.Today();
          t.Next_Action_Date__c = System.Today();
          //insert t;
      	  tskList.add(t);
          
          task t1 = new task();
          t1.Subject = 'New Task';
          t1.Task_Type__c = 'Site Visit';
          t1.Type = 'Site Visit';
          t1.activityDate = System.Today();
     
          t1.whatId = oList[1].Id;
          t1.call_time__c = TaskManagementServices.FormatTime(system.now());
          t1.ActivityDate__c = '25/05/2021'; 
          t1.ActivityDate = System.Today();
          t1.Next_Action_Date__c = System.Today();
          //insert t1;
          tskList.add(t1);
      insert tskList;
          
          Test.startTest(); 
          List<Task> tList11 = TestDataFactory.createTasksForLead(lList[0].Id, 2, 'Presales Call');
          List<Task> tList22 = TestDataFactory.createTasksForLead(lList[1].Id, 2, 'Enquiry Received');
          List<Task> tList33 = TestDataFactory.createTasksForLeadWithStatus(lList[1].Id, 2, 'Enquiry Received','','');
        
          List<Opportunity> updatedOList = [Select Id, Presales_Call_counter__c from Opportunity where Id = :oList[0].Id];
          
          List<Opportunity> updatedOList1 = [Select Id, visit_counter__c from Opportunity where Id = :oList[1].Id];
          
          //System.assertEquals(1, updatedOList[0].Presales_Call_counter__c);
         // System.assertEquals(1, updatedOList1[0].visit_counter__c);
          
        Test.stopTest();
 
  }
  
  @isTest  
  static void TaskTest2222() {
    Project__c p2 = TestDataFactory.createProject('Xanadu_prj2','111');
        Account acc2 = TestDataFactory.createPATemplate('TestPA2' , 'testleada@ozonetest.com', '9876544441', false);
        
        List<Lead> llist2 = TestDataFactory.createLead(3);
        List<Opportunity>  oList2 = TestDataFactory.createOpptyForAccount(acc2.Id, p2.Id, 2);
       
        system.debug(oList2[0].Name);                
       
          //List<Task> tList1 = TestDataFactory.createTasksForOpp(oList[0].Id, 2, 'Presales Call');
          //List<Task> tList2 = TestDataFactory.createTasksForOpp(oList[1].Id, 2, 'Site Visit');
          
      		List<Prospect__c> prospectList = new List<Prospect__c>();
          Prospect__c ps = new Prospect__c();
          ps.Account__c = acc2.id;
          ps.Project__c = p2.id;
          ps.Active__c = true;
          //insert ps;
      	  prospectList.add(ps);
          
          Prospect__c ps2 = new Prospect__c();
          ps2.Lead__c = llist2[0].id;
          ps2.Project__c = p2.id;
          ps2.Active__c = true;
          //insert ps2;
          prospectList.add(ps2);
      insert prospectList;
          
      	  List<Task> tskList = new List<Task>();
          task t = new task();
          t.Subject = 'New Task';
          t.Task_Type__c = 'Presales Call';
          t.activityDate = System.Today();
          t.whatId = oList2[0].Id;
          t.Prospect__c = ps.id;
          t.call_time__c = TaskManagementServices.FormatTime(system.now());
          t.ActivityDate__c = '25/05/2021';
          t.ActivityDate = System.Today();
          t.Next_Action_Date__c = System.Today();
          //insert t;
      	  tskList.add(t);
          
          task t1 = new task();
          t1.Subject = 'New Task';
          t1.Task_Type__c = 'Sales Call';
          t1.activityDate = System.Today();
          t1.whatId = oList2[1].Id;
          t1.Prospect__c = ps.id;
          t1.call_time__c = TaskManagementServices.FormatTime(system.now());
          t1.ActivityDate__c = '25/05/2021';
          t1.ActivityDate = System.Today();
          t1.Next_Action_Date__c = System.Today();
          //insert t1;
          tskList.add(t1);
          
          task t2 = new task();
          t2.Subject = 'New Task2';
          t2.Task_Type__c = 'Sales Call';
          t2.activityDate = System.Today();
          t2.whoId = llist2[0].Id;
          t2.Prospect__c = ps2.id;
          t2.call_time__c = TaskManagementServices.FormatTime(system.now());
          t2.ActivityDate__c = '25/05/2021';
          t2.ActivityDate = System.Today();
          t2.Next_Action_Date__c = System.Today();
          //insert t2;
      	  tskList.add(t2);
      
          /*task t3 = new task();
          t3.Subject = 'New Task3';
          t3.Task_Type__c = 'CRM Call';
          t3.activityDate = System.Today();
          t3.whoId = llist2[0].Id;
          t3.Prospect__c = ps2.id;
          t3.call_time__c = TaskManagementServices.FormatTime(system.now());
          t3.ActivityDate__c = '25/05/2021';
          t3.ActivityDate = System.Today();
          t3.Next_Action_Date__c = System.Today();
      	  tskList.add(t3);*/
      
      	  task t4 = new task();
          t4.Subject = 'New Task3';
          t4.Task_Type__c = 'CRM Call';
          t4.activityDate = System.Today();
          t1.whatId = oList2[1].Id;
          t4.Prospect__c = ps2.id;
          t4.call_time__c = TaskManagementServices.FormatTime(system.now());
          t4.ActivityDate__c = '25/05/2021';
          t4.ActivityDate = System.Today();
          t4.Next_Action_Date__c = System.Today();
      	  tskList.add(t4);
      	insert tskList;
          
          Test.startTest(); 
          TaskManagementServices.callStatusMethod(new List<Task>{t2});
          TaskManagementServices.callStatusMethod(new List<Task>{t1});
          TaskManagementServices.latestTaskRollupToOpp(new List<Task>{t});
          TaskManagementServices.latestTaskRollupToOpp(new List<Task>{t1});
          TaskManagementServices.latestTaskRollupToProspect(new List<Task>{t});
          /*List<Task> tList11 = TestDataFactory.createTasksForLead(lList[0].Id, 2, 'Presales Call');
          List<Task> tList22 = TestDataFactory.createTasksForLead(lList[1].Id, 2, 'Sales Call');
        
          List<Opportunity> updatedOList = [Select Id, Presales_Call_counter__c from Opportunity where Id = :oList[0].Id];
          
          List<Opportunity> updatedOList1 = [Select Id, visit_counter__c from Opportunity where Id = :oList[1].Id];
        
        System.assertEquals(1, updatedOList[0].Presales_Call_counter__c);
        System.assertEquals(1, updatedOList1[0].visit_counter__c);*/
              MAP<Id,Lead> LeadMap = new MAP<Id,Lead>();
              LeadMap.putall(llist2);
              TaskManagementServices.createTaskforEnquiries(LeadMap);
               TaskManagementServices.dummyMethod();
          
            // List<task> tList1 = TaskManagementServices.getTaskByTypeLead('Sales call',null,'call_time__c','ASC',llist2[0].id);
             // List<task> tList4 = TaskManagementServices.getAllsiteVisitTasks(null,'call_time__c','ASC',llist2[0].id);
              List<task> tList20 = TaskManagementServices.getTaskByType('Sales call','ALL','call_time__c','DESC',llist2[0].id);
             
              TaskManagementServices.latestTaskRollupToLead(tList20);
              TaskManagementServices.latestTaskRollupToOpp(tList20);
              TaskManagementServices.latestTaskRollupToProspect(tList20);
              TaskManagementServices.callStatusMethod(tList20);
              
             
             
        
         
             // List<task> tList2 = TaskManagementServices.getTaskByTypeLead('Sales call','ALL','call_time__c',null,llist2[0].id);
            //  List<task> tList5 = TaskManagementServices.getAllsiteVisitTasks('ALL','call_time__c',null,llist2[0].id);
               List<task> tList21 = TaskManagementServices.getTaskByType('Sales call','ALL','call_time__c','ASC',llist2[0].id);
              TaskManagementServices.latestTaskRollupToLead(tList21);
              TaskManagementServices.latestTaskRollupToOpp(tList21);
              TaskManagementServices.latestTaskRollupToProspect(tList21);
              TaskManagementServices.callStatusMethod(tList21);
        
          List<task> tList3 = TaskManagementServices.getTaskByTypeLead('Sales call','ALL','call_time__c','ASC',llist2[0].id);
          List<task> tList6 = TaskManagementServices.getAllsiteVisitTasks('ALL','call_time__c','ASC',llist2[0].id);

          TaskManagementServices.missedCallemailAlert(new List<Task>{t1});
         
        Test.stopTest();
 
  }
 
  
}