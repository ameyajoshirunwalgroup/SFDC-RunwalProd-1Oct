public class InboundSMS 
{
    public Lead objLead;
    public InboundSMS()
    {
        string strMobile = ApexPages.currentPage().getParameters().get('mobile');
        string strSMSText = ApexPages.currentPage().getParameters().get('SMSText');
        string strTime = ApexPages.currentPage().getParameters().get('time');
        string strTo = ApexPages.currentPage().getParameters().get('to');
        string strCircle= ApexPages.currentPage().getParameters().get('Circle');
        string strOperator= ApexPages.currentPage().getParameters().get('Operator');
        
        if(strMobile != null && strMobile != '')
        {
            objLead = new Lead();
            
            objLead.MobilePhone= strMobile;
            objLead.LastName = strMobile;
            if(strSMSText != null)
                objLead.Description = strSMSText;
            if(strTime != null)
            {
                system.debug('Sumit strTime ::' + strTime );
                //objLead.SMSDateTIme__c
            }
            if(strOperator != null)
                objLead.Operator__c = strOperator;
            if(strCircle != null)
                objLead.Circle__c = strCircle;
            if(strTo != null)
                objLead.SMSSendTo__c = strTo;
            
        }
        
    }
    
    public void InsertLead()
    {
        try
        {
            system.debug('Sumit Lets Insert Lead :: '+objLead);
            if (objLead != null)
                insert objLead;
        }
        catch(Exception e)
        {
            system.debug('Sumit Exception :: '+e);
        }
        
    }
}