public with sharing class QuotationManagementServices1 {
public static String INFormat(Decimal money) {
    Boolean negative = false;
    if(money < 0) {
      negative = true;
    }
    String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
    String mF = '';
    for(Integer i=0; i < m1.length() ; i++) {
      mF += m1.substring(i,i+1);
      if(i==2) {
        mF += ',';
      }
      if(i==4 || i==6 || i==8 || i==10 || i==12) {
        mF += ',';
      }
    }
    mf = mf.reverse();
    if(mf.substring(0,1).equals(',')) {
      mf = mf.substring(1);
    }
    if(!negative)
      mf = 'Rs ' + mf + '/-';
    else
      mf = '- Rs ' + mf + '/-';
    return mf;
  }
  
  public static Legal_Entity__c getLegalEntityDetails(Id unitId, Id pId) {
        Legal_Entity__c le = new Legal_Entity__c();
        Id leId = null;
        List<Project_Unit__c> pu = [Select Id, Name, Legal_Entity__r.Id from Project_Unit__c where Id = : unitId];
        if(pu != null && pu.size() > 0) {
            leId =pu[0].Legal_Entity__r.Id; 
        }
        
        if(leId == null) {
            List<Project__c> p = [Select Id, Name, RDS_Company_Code__r.Id from Project__c where Id = : pId];
            if(p != null && p.size() > 0)
                leId = p[0].RDS_Company_Code__r.Id;
        }
        System.debug('ledId:' + leId);
        if(leId != null) {
            le = [Select Name,Account_Name_Flat_Cost__c, Account_Number_Flat_Cost__c, Bank_Name_Flat_Cost__c, 
                                        IFSC_Code_Flat_Cost__c, MICR_Code_Flat_Cost__c,RDS_PAN_No__c,
                                        Account_Name_Service_Tax__c,Account_Number_Service_tax__c, Bank_Name_Service_tax__c, 
                                        IFSC_Code_Service_Tax__c, MICR_Code_Service_Tax__c, RDS_Service_Tax_No__c,
                                        RDS_Address1__c,RDS_Address2__c, RDS_City__c, RDS_Pin_Code__c, CIN__c
                                        FROM Legal_Entity__c where Id = : leId];
        }
        return le;
    }
    
     public static Map<String, Decimal> getTaxSlabs() {
        Map<String, Decimal> taxslabsMap = new Map<String, Decimal>();
        list<Tax_Slab__c>   lstTaxSlab = [select Name,From_Date__c, To_Date__c, Percentage__c from Tax_Slab__c where From_Date__c <= TODAY and (To_Date__c >= TODAY OR To_Date__c = null)];
        system.debug('lstTaxSlab --- '+lstTaxSlab);
        for(Tax_Slab__c objTS : lstTaxSlab){
            taxslabsMap.put(objTS.Name,objTS.Percentage__c);
        }   
        return taxslabsMap;
    }
    
  }