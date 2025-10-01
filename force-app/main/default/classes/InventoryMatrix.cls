public class InventoryMatrix
{
    public String SelectedProjId {get;set;} 
    public String SelectedTowerId {get;set;}
    public List<SelectOption> TowerOptions1 {get;set;}
    public set<string> TowerName {get;set;}
    public Map<string, list<Project_Unit__c>> MapTowerToProjUnit {get;set;}
    
    
    public  InventoryMatrix ()
    {
        
        MapTowerToProjUnit = New Map<string, list<Project_Unit__c>> ();
        TowerName = New set<string>();
    }
    public List<SelectOption> getProjectNames()
    {
        set<string> projSet = new set<string>();
        List<SelectOption> ProjectOptions= new List<SelectOption>();
        ProjectOptions.add( new SelectOption('0','--Select--'));
        for( Project__c proj : [select Id,name from Project__c limit 999] )
        {
            if(!projSet.contains(proj.name.tolowercase()))
            {
                ProjectOptions.add( new SelectOption(proj.Id,proj.name)); 
            }
            projSet.add(proj.name.tolowercase());
        }
        return ProjectOptions;
    }
    
    public List<SelectOption> getTowerNames()
    {
        set<string> proSet = new set<string>();
        TowerName = New set<string>();
        SelectedTowerId = '0';
        TowerOptions1 = new List<SelectOption>();
        TowerOptions1.add( new SelectOption('0','--Select--'));
        for(Project_Unit__c projunit : [select id,RW_Param2__c,RW_Param3__c, name from Project_Unit__c where  RW_Param2__c !=null and RW_Project__c =:SelectedProjId])
        {
            //system.debug('**** '+projunit.RW_Param2__c+'    '+proSet);
            if(!proSet.contains(projunit.RW_Param2__c.tolowercase()))
            {
                TowerOptions1.add( new SelectOption(projunit.RW_Param2__c,projunit.RW_Param2__c));
            }
            proSet.add(projunit.RW_Param2__c.tolowercase());
        }
        return TowerOptions1;
    }
           
    public PageReference SearchProjectUnit() 
    {
        try
        {
            MapTowerToProjUnit = New Map<string, list<Project_Unit__c>> ();
            TowerName = New set<string>();
            
            set<string> proSet = new set<string>();
            TowerOptions1 = new List<SelectOption>();
            TowerOptions1.add( new SelectOption('0','--Select--'));
            
            List<Project_Unit__c> lstProjectUnit = [select id, name,RW_Unit_Status__c,RW_Param2__c,RW_Param3__c,New_Floor__c from Project_Unit__c where  RW_Param2__c =:SelectedTowerId and RW_Project__c =:SelectedProjId order by New_Floor__c ASC,RW_Param3__c ASC,RW_Param4__c ASC];
            Set<Integer> stInteger = new Set<Integer>();
            List<Integer> lstInteger = new List<Integer>();
            if(lstProjectUnit != null && lstProjectUnit.size() > 0)
            {
                for(Project_Unit__c eachProjUnit : lstProjectUnit)
                {
                    if((!stInteger.contains(Integer.valueOf(eachProjUnit.New_Floor__c)) && eachProjUnit.New_Floor__c!= null))
                    {
                        stInteger.add(Integer.valueOf(eachProjUnit.New_Floor__c));
                        lstInteger.add(Integer.valueOf(eachProjUnit.New_Floor__c));
                    }
                }
            }
            
            lstInteger.sort();
            
            for(Integer I : lstInteger)
            {
                TowerName.add(String.valueOf(I));
            }
            
            for(Project_Unit__c projobj : lstProjectUnit)
            {
                if(MapTowerToProjUnit != null && MapTowerToProjUnit.get(string.valueof(integer.valueOf(projobj.New_Floor__c))) != null && MapTowerToProjUnit.get(string.valueof(integer.valueOf(projobj.New_Floor__c))).size() > 0)
                {
                    list<Project_Unit__c > lstProjUnit = MapTowerToProjUnit.get(string.valueof(integer.valueOf(projobj.New_Floor__c)));
                    lstProjUnit.add(projobj);
                    MapTowerToProjUnit.put(string.valueof(integer.valueOf(projobj.New_Floor__c)),  lstProjUnit);
                }
                else
                {
                    MapTowerToProjUnit.put(string.valueof(integer.valueOf(projobj.New_Floor__c)),  new list<Project_Unit__c>());
                    list<Project_Unit__c > lstProjUnit = new list<Project_Unit__c>();
                    lstProjUnit.add(projobj);
                    MapTowerToProjUnit.put(string.valueof(integer.valueOf(projobj.New_Floor__c)),  lstProjUnit);
                }
                
            }
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Found Currupted data while processing you request, please contact your Administrator.   ERROR :  ' + ex ));
        }
        return null;
    }
       
                    
        /*public void SearchProjectUnit1()
        {
            for(Project_Unit__c projobj : [select id, name,Unit_Status__c,Booking__c,Param2__c,Param3__c   from Project_Unit__c where  Param2__c =:SelectedTowerId and Project__c =:SelectedProjId order by Name DESC])
            {
                if(MapTowerToProjUnit != null && MapTowerToProjUnit.get(projobj.Param3__c) != null && MapTowerToProjUnit.get(projobj.Param3__c).size() > 0)
                {
                    list<Project_Unit__c > lstProjUnit = MapTowerToProjUnit.get(projobj.Param3__c);
                    lstProjUnit.add(projobj);
                    MapTowerToProjUnit.put(projobj.Param3__c,  lstProjUnit);
                }
                else
                {
                    MapTowerToProjUnit.put(projobj.Param3__c,  new list<Project_Unit__c>());
                    list<Project_Unit__c > lstProjUnit = new list<Project_Unit__c>();
                    lstProjUnit.add(projobj);
                    MapTowerToProjUnit.put(projobj.Param3__c,  lstProjUnit);
                }
            }
        }  */
        
        public void TowersName()
        {
           set<string> proSet = new set<string>();
           TowerOptions1 = new List<SelectOption>();
           for(Project_Unit__c projunit : [select id,RW_Param2__c,RW_Param3__c, name from Project_Unit__c where  RW_Param2__c !=null and RW_Project__c =:SelectedProjId])
           {
                if(!proSet.contains(projunit.RW_Param2__c.tolowercase()))
                {
                    TowerOptions1.add( new SelectOption(projunit.RW_Param2__c,projunit.RW_Param2__c));
                     
                }
                         proSet.add(projunit.RW_Param2__c.tolowercase());
           }
        }
}