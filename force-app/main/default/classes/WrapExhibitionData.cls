public class WrapExhibitionData 
{
    @AuraEnabled
    public string objMasterId{ get; set; }
    @AuraEnabled
    public string objExhId { get; set; }
    @AuraEnabled
    public string strImgId { get; set; }
    @AuraEnabled
    public boolean isSaved { get; set; }
    @AuraEnabled
    public string strNumber { get; set; }
    @AuraEnabled
    public string strMasterNam { get; set; }
    @AuraEnabled
    public string strContent { get; set; }
    @AuraEnabled
    public date strFrom { get; set; }
    @AuraEnabled
    public date strTo { get; set; }
    @AuraEnabled
    public Boolean IMComming { get; set; }
    
    public WrapExhibitionData()
    {
        isSaved = false;
        IMComming = false;
        strNumber = '';
    }
}