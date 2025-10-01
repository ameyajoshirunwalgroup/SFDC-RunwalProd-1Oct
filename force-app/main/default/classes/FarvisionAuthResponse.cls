public class FarvisionAuthResponse
{
    public Integer ErrorCode;
    public String StatusMessage;
    public List<UserInfo> UserInfo;
    public string ApplicantID;

    public class UserInfo {
        public String CompanyLogo;
        public String UserID;
        public String UserToken;
    }
    
    public static FarvisionAuthResponse parse(String json) {
        return (FarvisionAuthResponse) System.JSON.deserialize(json, FarvisionAuthResponse.class);
    }
}