public class RWProjectLogoController 
{
	public String projectId {get; set;}
    public String attachmentId {get; set;}
    public String strWidth {get; set;}
    public String strHeight {get; set;}
    public string initialize{
        get{
            if(projectId != null)
            {
                List<Attachment> lstAttachment = [SELECT id, name FROM Attachment WHERE ParentID =: projectId AND name =: Label.RWProjectLogo];
                if(lstAttachment != null && lstAttachment.size() > 0)
                {
                    attachmentId = lstAttachment[0].id;
                }
            }
            return '';
        }
        set;
    }
}