public with sharing class S_InventoryMatrix {
    public Project_Unit__c unit {
        get;
        private set;
    }
    public String selectedTower {
        get;
        set;
    }
    public String selectedVal {
        get;
        set;
    }
    public String selectedstatus {
        get;
        set;
    }
    public String SelectedClusterId {
        get;
        set;
    }
    public String SelectedProjectId {
        get;
        set;
    }
    public String selectedConf {
        get;
        set;
    }
    
    public String projectUnitRecordId {
        get;
        set;
    }
    
     public Id oppId {
        get;
        set;
    }
    
    public String getprojectUnitRecordId() {
        return projectUnitRecordId;
    }
    
    public Boolean sold {
        get;
        set;
    }
    public Boolean open {
        get;
        set;
    }
    public Boolean booked {
        get;
        set;
    }
    public Boolean blocked {
        get;
        set;
    }
    public Boolean reserved {
        get;
        set;
    }
    public Boolean onebhk {
        get;
        set;
    }
    public Boolean twobhk {
        get;
        set;
    }
    public Boolean threebhk {
        get;
        set;
    }
    public Boolean fourbhk {
        get;
        set;
    }
    public Boolean fivebhk {
        get;
        set;
    }
    public List < Decimal > floorAscSeqList {
        get;
        set;
    }
    public Map < Decimal, List < Project_Unit__c >> JMap {
        get;
        set;
    }
    
    public Boolean hasError {
        get {
            return ApexPages.hasMessages();
        }
    }
    
    public S_InventoryMatrix() 
    {
         System.debug('inside constructor');
         if (ApexPages.currentPage().getParameters().get('oppid') != null)
         {
             System.debug('inside constructor'+ApexPages.currentPage().getParameters().get('oppid'));
             oppId = ApexPages.currentPage().getParameters().get('oppid');
             System.debug('inside constructor'+oppId);
         }
    }
    
    String projectsent = ApexPages.currentPage().getParameters().get('projectsent');
    String statussent = ApexPages.currentPage().getParameters().get('statussent');
    String towersent = ApexPages.currentPage().getParameters().get('towersent');
    List < String > s = new List < String > ();

  /*  public List < SelectOption > getClients {
        get {
            List < SelectOption > clientoptns = new List < Selectoption > ();
            List < Client__c > clientqury = new List < Client__c > ();
            clientqury = new List < Client__c > ([Select Id, Name from Client__c]);
            clientoptns.add(new SelectOption('', 'Select a Client'));
            for (Client__c obj: clientqury) {
                clientoptns.add(new SelectOption(obj.Id, obj.Name));
            }
            return clientoptns;
        }
        set;
    }
    */

    public List < SelectOption > getProjects {
        get {
            List < SelectOption > optns = new List < Selectoption > ();
            List < Project__c > queryResult = new List < Project__c > ();
          
            queryResult = [Select Id, Name from Project__c];
            optns.add(new SelectOption('', 'Select a Project'));
            for (Project__c obj: queryResult) {
                optns.add(new SelectOption(obj.Id, obj.Name));
            }
            return optns;
        }
        set;
    }
    public List < SelectOption > getClusterNames {

        get {

            set < string > clusterSet = new set < string > ();
            List < SelectOption > ClusterOptions = new List < SelectOption > ();
            ClusterOptions.add(new SelectOption('0', 'Select a Phase'));
            if (selectedVal != null) {
                for (Cluster__c c: [select Id, name, Project__c from Cluster__c Where Project__c = : selectedVal]) {
                    if (!clusterSet.contains(c.name.tolowercase())) {
                        ClusterOptions.add(new SelectOption(c.Id, c.name));
                    }
                    clusterSet.add(c.name.tolowercase());
                }
            }
            return ClusterOptions;
        }
        set;

    }
   

    public List < SelectOption > getTowers {

        get {
            List < SelectOption > options = new List < Selectoption > ();
            options.add(new SelectOption('', 'Select a Tower'));
            if (SelectedClusterId != null) {
                List < Tower__c > qResult = new List < Tower__c > ([Select Id, Name from Tower__c where Zone_Name__r.id = : SelectedClusterId order by Name asc]);
                for (Tower__c obj1: qResult) {
                    options.add(new SelectOption(obj1.Id, obj1.Name));
                }
            }
            return options;
        }
        set;
    }

    /* public List < SelectOption > getProjectunittype {
        get {
            List < SelectOption > unitopt = new List < Selectoption > ();
            unitopt.add(new SelectOption('', 'Select Configuration'));

            if (selectedVal != null && selectedTower != null) {

                List < Project_Unit_Type__c > conf = new List < Project_Unit_Type__c > ([Select Id, Name from Project_Unit_Type__c Where RDS_Project__c = : selectedVal]);
                system.debug(' project unit query>>>>>' + conf);

                for (Project_Unit_Type__c unit: conf) {
                    unitopt.add(new SelectOption(unit.Id, unit.Name));
                }
            }
            system.debug('unitopt >>>>' + unitopt);
            return unitopt;

        }
        set;
    }

   */

    public List < Decimal > floorDescSeqList {
        get {
            towersent = selectedTower;
            projectsent = selectedVal;
            JMap = new Map < Decimal, List < Project_Unit__c >> ();
            floorAscSeqList = new List < Decimal > ();
            floorDescSeqList = new List < Decimal > ();
            system.debug('towersent ..' + towersent);
            system.debug('projectsent ..' + projectsent);

            if (towersent != null && projectsent != null) {
                List < Project_Unit__c > unitlist = ([SELECT Id, Name,ToLabel(New_Type__c),RW_EOI_Block_Status__c, RW_Floor__c, RW_Unit_Status__c, Type__c,RW_Customer__c,  RW_Customer__r.Name,Project_Unit_Type__r.Name  from Project_Unit__c where TowerName__c = : towersent order by RW_Floor__c DESC, Name ASC]);///*Booking__c,Booking__r.Opportunity__c,*/
                System.debug('UNIT LIST:' + unitList);

                for (Project_Unit__c thisUnit: unitList) {
                    if (JMap.containsKey((thisUnit.RW_Floor__c))) {
                        JMap.get((thisUnit.RW_Floor__c)).add(thisUnit);
                    } else {
                        List < Project_Unit__c > unitList1 = new List < Project_Unit__c > ();
                        unitList1.add(thisUnit);
                        JMap.put((thisUnit.RW_Floor__c), unitList1);
                    }
                }

                floorAscSeqList.addAll(JMap.keySet());
                floorAscSeqList.sort();

                for (Integer i = floorAscSeqList.size() - 1; i >= 0; i--) {
                    floorDescSeqList.add(floorAscSeqList.get(i));
                }
                System.debug('FLOOR SEQ:' + floorDescSeqList.size());
                System.debug('J Map:' + JMap);


            }
            return floorDescSeqList;
        }
        set;

    }
    
    public PageReference updateEOIBlockStatus()
    {
     
        System.debug(projectUnitRecordId+'*entered*'+projectUnitRecordId);
       // Map<String,Project_Unit__c> unitMap = new Map<String,Project_Unit__c>();
        List<Project_Unit__c> unitList = new List<Project_Unit__c>();
        try
        {
          if(oppId != null)
          {
              List<String> eoiStatus = new List<String>{'EOI Booked','Cancellation Initiated','EOI Cancelled - Refund pending','EOI Cancelled - Refund Initiated','EOI Cancelled -Refunded'};
              List<Opportunity> oppRec = [Select id,(SELECT id,RW_Status__c FROM EOI__r Where RW_Status__c Not in : eoiStatus ) from Opportunity Where id =: oppId];
   				if(oppRec[0].EOI__r.size() >0)
                  {
                  	RW_EOI__c eoiRec = oppRec[0].EOI__r[0];
                    if(eoiRec.RW_Status__c == 'EOI Confirmed')
                    {
                 	
                          Project_Unit__c unitRecord = [Select Id, Name, RW_EOI_Blocked_By__c,RW_EOI_Blocked_Date__c,RW_EOI_Block_Status__c,EOI__c from Project_Unit__c Where Id =:projectUnitRecordId ];
                          System.debug('*entered if*'+projectUnitRecordId);
                            if(unitRecord.RW_EOI_Block_Status__c !='EOI Blocked')
                            {
                          unitRecord.RW_EOI_Block_Status__c ='EOI Blocked';
                          unitRecord.EOI__c = eoiRec.Id;
                          unitRecord.RW_EOI_Blocked_Date__c=System.today();
                          unitRecord.RW_EOI_Blocked_By__c= UserInfo.getUserId();
                            update unitRecord;
                          
                            eoiRec.RW_Status__c = 'EOI Blocked';
                            update eoiRec;
                          

                             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'EOI is blocked Successfully');
                             ApexPages.addMessage(msg);
                             return null;
                            }
                          else
                          {
                              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'This unit is already blocked for an EOI-'+unitRecord.EOI__c);
                             ApexPages.addMessage(msg);
                             return null;
                          }
                      
                  }
                      else if(eoiRec.RW_Status__c == 'EOI Blocked')
                      {
                          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'EOI for this opportunity is already blocked.');
                    ApexPages.addMessage(msg);
                    return null;
                      }
                      
                      else 
                      {
                          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'EOI Status for this opportunity is not Confirmed. Please check if EOI is confirmed and then block the unit.');
                    ApexPages.addMessage(msg);
                    return null;
                      }
                  }
                  else
                  {
                     ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'There is no EOI associated for this opportunity');
                    ApexPages.addMessage(msg);
                    return null;
                  }
             

          }
            
            return null;
        }
        catch(Exception ex)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
             ApexPages.addMessage(msg);
             return null;
            //return 'There was an error -'+e.getMessage();
        }
        
    }
    
    
     public PageReference updateEOIAvailableStatus()
    {
        System.debug('*entered*'+projectUnitRecordId);
        try
        {
        	Project_Unit__c unitRec = [Select Id,RW_EOI_Block_Status__c,RW_EOI_Blocked_By__c,RW_EOI_Blocked_Date__c,EOI__c from Project_Unit__c Where Id =:projectUnitRecordId];
            List<RW_EOI__c> eoiRec = [Select id,Name , Opportunity__c from RW_EOI__c Where id =:unitRec.EOI__c];
            if(eoiRec != null && eoiRec.size() >0 )
            {
                if(eoiRec[0].Opportunity__c == oppId)
                {
                    System.debug('*entered if*'+projectUnitRecordId);
                    if(unitRec.RW_EOI_Blocked_By__c ==  Userinfo.getUserId() || (getUserRoleName(userinfo.getUserRoleId()) == 'Site Head' || getUserRoleName(userinfo.getUserRoleId()) == 'Director'))
                    {
                    unitRec.RW_EOI_Block_Status__c ='EOI Available';
                    unitRec.RW_EOI_Blocked_By__c =null;
                    unitRec.RW_EOI_Blocked_Date__c=null;
                    unitRec.EOI__c = null;
                    update unitRec;
                    
                    eoiRec[0].RW_Status__c = 'EOI Confirmed';
                    update eoiRec[0];
                      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'EOI is Unblocked Successfully');
                             ApexPages.addMessage(msg);
                             return null;
                    }
                    
                    else
                    {
                         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'This unit can only be unblocked by Sales Manager who blocked it or by Site Head/Director');
                             ApexPages.addMessage(msg);
                             return null;
                    }
                }
                
                else
                {
                      List<Opportunity> oppRec = [Select id,(SELECT id FROM EOI__r Where RW_Status__c ='EOI Blocked' ) from Opportunity Where id =: oppId];
                      if(oppRec.size() > 0)
                      {
                          if(oppRec[0].EOI__r.size() >0)
                  		{
                             RW_EOI__c eoiRecord = oppRec[0].EOI__r[0];
                             List<Project_Unit__c> unitRecord = [Select Id, Name,RW_EOI_Block_Status__c,EOI__c from Project_Unit__c Where EOI__c =:eoiRecord.Id and RW_EOI_Block_Status__c ='EOI Blocked']; 

                              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'This unit is not EOI blocked for this opportunity. The unit that is EOI blocked for this opportunity is -'+unitRecord[0].Name );
                    		  ApexPages.addMessage(msg);
                    		  return null;
                  		}
                          else
                          {
                              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'There is no EOI tagged to this opportunity OR the tagged EOI is not EOI Blocked.' );
                    		  ApexPages.addMessage(msg);
                    		  return null;
                          }
                         
                      }
                    
                    else
                    {
                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'This unit is not EOI blocked for this opportunity and neither this opportunity has any EOI that is \'EOI Blocked\' ' );
                    		  ApexPages.addMessage(msg);
                    		  return null;
                    }

     
                }
            }
            
            else
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'This is no EOI tagged to this unit when this unit was blocked. Please tag the EOI and then unblock it' );
                    		  ApexPages.addMessage(msg);
                    		  return null;
            }
            

            
        }
        catch(Exception ex)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
             ApexPages.addMessage(msg);
             return null;
        }
        
    }
    
    public PageReference checkEOIBeforeBooking()
    {
        String unitName;
         try
        {
        List<Opportunity> oppRec = [Select id,(SELECT id,RW_Status__c FROM EOI__r ) from Opportunity Where id =: oppId];
                  if(oppRec[0].EOI__r.size() >0)
                  {
                  	RW_EOI__c eoiRec = oppRec[0].EOI__r[0];
                      if(eoiRec.RW_Status__c == 'EOI Blocked')
                      {
                    Project_Unit__c unitRec = [Select Id,RW_EOI_Block_Status__c,EOI__c from Project_Unit__c Where Id =:projectUnitRecordId];

                          if(unitRec.EOI__c == eoiRec.Id)
                          {
                              return null;
                          }
                          
                          else
                          {
                               List<Project_Unit__c> unitRecords = [Select Id, Name, RW_EOI_Block_Status__c,EOI__c from Project_Unit__c where EOI__c = :eoiRec.Id ];
                                /*  for(Project_Unit__c unit : unitRecords)
                                  {
                                    if(unit.EOI__c == eoiRec.Id && unit.RW_EOI_Block_Status__c =='EOI Blocked')
                                    {
                                        unitName = unit.Name;
                                    }
                                  }*/
                              
                              if(unitRecords != null && unitRecords.size() >0)
                              {
                                  unitName = unitRecords[0].Name;
                                  }
                               
                                if(unitName != '' && unitName != null)
                                {
                                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please book only the unit which is EOI blocked for this opportunity. The unit that is EOI blocked for this opportunity is-'+unitName);
                                ApexPages.addMessage(msg);
                                 return null;
                                }
                                    else
                                    {
                                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Please book only the unit which is EOI blocked for this opportunity. ');
                                    ApexPages.addMessage(msg);
                                 return null;
                                    }
                                 
                          }
                      }
                      else
                      {
                          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'EOI Status for this opportunity is not \'EOI Blocked\' . Please block this unit first for EOI to book for this opportunity.' );
                                    ApexPages.addMessage(msg);
                                 return null;
                      }
                  }
            else
            {
                return null;
            }

    
              }
    
    catch(Exception ex)
        {
             ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
             ApexPages.addMessage(msg);
             return null;
        }
    }
    
    public String getUserRoleName(String roleId)
    {
        if(roleId != null && !String.isEmpty(roleId))
        {
        UserRole ur =[SELECT Id, Name FROM UserRole where id =:roleId];
        return ur.Name;
        }
        else
        return '';
    }
    
	public PageReference checkOpportunityStatus()
    {
        
         try
        {
        	List<Opportunity> oppRec = [Select id,StageName from Opportunity Where id =: oppId];
             if(oppRec != null && oppRec.size() >0 && oppRec[0].StageName == 'Cancelled')
              {
                                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Quotation cannot be generated on a Cancelled Opportunity. Please check Opportunity stage.');
                                ApexPages.addMessage(msg);
                                 return null;
              }
            else
            {
                return null;
            }
        }
        
        catch(Exception ex)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
             ApexPages.addMessage(msg);
             return null;
        }
    }											 
    
}