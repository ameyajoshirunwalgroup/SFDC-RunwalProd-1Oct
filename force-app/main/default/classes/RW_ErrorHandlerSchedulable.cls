public class RW_ErrorHandlerSchedulable implements schedulable {
    public string apiname ;
    public string project;
    integer batchSize;
public    RW_ErrorHandlerSchedulable(string apiName,integer batchSize,string projectname){
        this.batchSize = batchSize;
        this.apiName = apiName;
    this.project=projectname;
    }
    
    public void execute(SchedulableContext SC) {
        RW_ERPErrorHandlerService erp = new RW_ERPErrorHandlerService(apiName,project);
        Database.executeBatch(erp, batchSize);
        
    }
}