@RestResource(urlMapping='/InsertProjectUnit/*')
global with sharing class ProjectUnitRestService 
{
    public class Result
    {
        public string Message {get; set;}
        public string Name {get; set;}
        public string Id {get; set;}
    }
    
    @HttpPost
    global static string doPost(list<Project_Unit__c> ProjectUnits)
    {
        try
        {
            list<Project_Unit__c> InsertProjectUnits =new list<Project_Unit__c>();
            List<Result> insertedProjects = new List<Result>();
            
            set<string> projectsName = new set<string>();
            
            for(Project_Unit__c projectUnit: ProjectUnits)
            {
                projectsName.add(projectUnit.Name);
            }
                
            List<Project__c> lstProject = [Select Id, Name from Project__c where Name in: projectsName];
               
            system.debug('**lstProject**: ' + lstProject);
            
            for(Project_Unit__c projectUnit: ProjectUnits)
            {
                system.debug('**projectUnit**:'+projectUnit);
                
                for(Project__c project: lstProject)
                {
                    system.debug('**project**:'+project);

                    if((project.Name).trim() == (projectUnit.Name).trim())
                    {
                        system.debug('**project ID/Name**:' + project.Id + '/' + project.Name);
                        projectUnit.RW_Project__c = project.Id;
                        
                        InsertProjectUnits.add(projectUnit);
                        break;
                    }
                }
                
            }
            
            system.debug('InsertProjectUnits: ' + InsertProjectUnits);
            
            insert InsertProjectUnits;
            
            for(Project_Unit__c insertedProjectUnit :InsertProjectUnits)
            {
                Result objResult = new Result();
                objResult.Id = insertedProjectUnit.id;
                objResult.Name = insertedProjectUnit.Name; 
                objResult.Message = 'Inserted successfully';
                
                insertedProjects.add(objResult);
            }
            
            String JSONString = JSON.serialize(insertedProjects);
            
            system.debug('JSONString : ' + JSONString);
            return JSONString;
        }
        catch(exception e)
        {
            system.debug('/InsertProjectUnit/ ProjectUnitRestService Exception :: ' + e);
            return 'false :: ' + e;
        }
        
    }

}