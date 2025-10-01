public class KickerIncentiveCalculationController {
	public id KId {get;set;}
    List<Kicker_Incentive__c> kiclist = new List<Kicker_Incentive__c>();
    public KickerIncentiveCalculationController() { 
          KId = ApexPages.currentPage().getParameters().get('KId');
          kiclist = [Select Id,name,Is_Completed__c from Kicker_Incentive__c where Id=:KId];
    }  
    public void StartKickerRun(){
        if(kiclist[0].Is_Completed__c == False){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Batch Started'));
            BrokerageManagementService.KickerCalulation(KId);
            kiclist[0].Is_Completed__c = true;
            update kiclist;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Kickers have already been calculated under this scheme'));
        }
    } 
    public PageReference Home() {  
      // return new PageReference('https://runwal--uat.sandbox.lightning.force.com/lightning/r/Kicker_Incentive__c/'+KId+'/view'); 
         return new PageReference('https://runwal.lightning.force.com/lightning/r/Kicker_Incentive__c/'+KId+'/view'); 
          
    }
}