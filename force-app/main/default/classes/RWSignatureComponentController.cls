global class RWSignatureComponentController
{
	public id objParentId{get;set;}
    public string accountid{get;set;}
    public account objaccount{get;set;}
    public string strAttName{get;set;}
    
    @RemoteAction
    global static Account findAccounts(String accid)
    {
        //name = '%' + name + '%';
        //Account accounts = [Select Id, Name from Account where id = :accid];
        return null;
    }
    @RemoteAction
    global static String saveSignature(String signatureBody, String parentId, string strName) 
    {
        try
        {
            string strAttachmentName = strName + '.png';
            Attachment a = new Attachment();
            list<Attachment> lstAttachment = [select id, Name from Attachment where Name =: strAttachmentName and ParentId =: parentId];
            
            if(lstAttachment.size() > 0)
            {
                a.id = lstAttachment[0].id;
            }
            else
                a.ParentId = parentId;
            
            system.debug('Record Id == ' + parentId);
            system.debug(signatureBody);
            a.Body = EncodingUtil.base64Decode(signatureBody);
            a.ContentType = 'image/png';
            a.Name = strName+'.png';
            upsert a;
            //return '{success:true, attachId:' + a.Id + '}';
            return 'Signature successfully added.';
        }
        catch(Exception e)
        {
            return JSON.serialize(e);
        }
        return null;
    }
}