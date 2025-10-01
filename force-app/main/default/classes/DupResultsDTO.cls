public class DupResultsDTO {
    public Lead originalLead;
    public Id dupEnquiryTaskId;
    public Id duplicateMaster;
    public Map<String,Set<Id>> duplicatesMap = new Map<String,Set<Id>>();
    
    public DupResultsDTO() {
        this.originalLead = null;
        this.dupEnquiryTaskId = null;
        this.duplicateMaster = null;
        this.duplicatesMap = new Map<String,Set<Id>>();
    } 
    public DupResultsDTO(Lead l, Id duplicateMaster, Id taskId, Map<String,Set<Id>> duplicatesMap) {
        this.originalLead = l;
        this.dupEnquiryTaskId = taskId;
        this.duplicateMaster = duplicateMaster;
        this.duplicatesMap = duplicatesMap;
    } 
}