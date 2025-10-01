public with sharing class GlobalException extends Exception{
    
    private  List<String> customMessage = new List<String>();
    private  String ErrorCode;
    private  String classDetails;
    
    public GlobalException(List<String> customMessage, String ErrorCode, String classDetails) {
        this.customMessage = customMessage;
        this.ErrorCode = ErrorCode;
        this.classDetails = classDetails;
    }
    
    public List<String> getErrorMsg() {
      return this.customMessage;
    }
    public  String getErrorCode() {
      return this.ErrorCode;
    }
    
    public  String getClassDetails() {
      return this.classDetails;
    }
}