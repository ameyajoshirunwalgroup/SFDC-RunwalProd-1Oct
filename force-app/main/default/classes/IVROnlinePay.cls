public class IVROnlinePay {
    
    public Decimal amount {get;set;}
    public Decimal totalOutStanding {get;set;}
    public Decimal principalAmount {get;set;}
    public Decimal gstAmount {get;set;}
    public Boolean separatePay {get;set;}
    public Booking__c bkg {get;set;}
    public String crn = System.currentPagereference().getParameters().get('crn');
    
    
    public pageReference successPage(){
        bkg = [SELECT Id, Opportunity__c, Unit_No__r.TowerName__c, Project__r.Seperate_payment__c,RW_Total_Demand_Raised__c,
                          RW_Total_Receipt_Amount_Received__c, RW_Total_Receipt_Discount_Recieved__c, Total_Demand_Raised_Principal__c,
                          RW_Total_TDS_Due__c, RW_Total_GST_Amount__c, RW_Total_TDS_Outstanding__c
               FROM Booking__c WHERE Opportunity__r.SAP_Customer_Number__c =: crn LIMIT 1];
        totalOutStanding = bkg.RW_Total_Demand_Raised__c - bkg.RW_Total_Receipt_Amount_Received__c - bkg.RW_Total_Receipt_Discount_Recieved__c;
        
        String ProjectSpecificTotalAmount = CustomerLedgerController.getCheckProjectTotalAmount(totalOutStanding,bkg.RW_Total_TDS_Due__c);
        	System.debug('ProjectSpecificTotalAmount: ' + ProjectSpecificTotalAmount);
        String TotalPrincipalPayable = CustomerLedgerController.getPrincipalPayableAmount(bkg.Total_Demand_Raised_Principal__c,bkg.RW_Total_GST_Amount__c,bkg.RW_Total_Demand_Raised__c,totalOutStanding,bkg.RW_Total_TDS_Outstanding__c);
            System.debug('TotalPrincipalPayable: ' + TotalPrincipalPayable);
        String TotalGstPayable = CustomerLedgerController.getGstPayableAmount(bkg.RW_Total_GST_Amount__c,bkg.RW_Total_Demand_Raised__c,totalOutStanding,bkg.RW_Total_TDS_Due__c,bkg.Total_Demand_Raised_Principal__c);
             System.debug('TotalGstPayable: ' + TotalGstPayable);
        
        if(bkg.Project__r.Seperate_payment__c){
            separatePay = true;
            amount = Integer.valueOf(ProjectSpecificTotalAmount);
        }else{
            separatePay = false;
            principalAmount = Integer.valueOf(TotalPrincipalPayable);
            gstAmount = Integer.valueOf(TotalGstPayable);
            
        }
        System.debug('totalOutStanding: ' + totalOutStanding);
        System.debug('principalAmount: ' + principalAmount);
        System.debug('gstAmount: ' + gstAmount);
        return null;
    }
    
    public pageReference pay(){
        System.debug('--pay--');
        pageReference pageRef = new Pagereference('https://runwal.my.salesforce-sites.com/pay?bkgId='+bkg.Id+'&oppId='+bkg.Opportunity__c+'&twrId='+bkg.Unit_No__r.TowerName__c+'&amount='+amount+'&unit='+bkg.Unit_No__c+'&type='+'SinglePayment');
        pageRef.setRedirect(true);
        return pageRef;	
    }
    
    public pageReference demandPay(){
        System.debug('--principalAmount-- ' + principalAmount);
        pageReference pageRef = new Pagereference('https://runwal.my.salesforce-sites.com/pay?bkgId='+bkg.Id+'&oppId='+bkg.Opportunity__c+'&twrId='+bkg.Unit_No__r.TowerName__c+'&amount='+principalAmount+'&unit='+bkg.Unit_No__c+'&type='+'Normal');
        pageRef.setRedirect(true);
        return pageRef;	
    }
    
    public pageReference gstPay(){
        System.debug('--gstPay-- ' + gstAmount);
        pageReference pageRef = new Pagereference('https://runwal.my.salesforce-sites.com/pay?bkgId='+bkg.Id+'&oppId='+bkg.Opportunity__c+'&twrId='+bkg.Unit_No__r.TowerName__c+'&amount='+gstAmount+'&unit='+bkg.Unit_No__c+'&type='+'GST');
        pageRef.setRedirect(true);
        return pageRef;	
    }

}