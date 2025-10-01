// This Class is used as Common class for All TestClass
// --------------------------------------------------------------------------------------------- 

@istest
public class RDSCommon
 {
 
    public Static Legal_Entity__c CreateLegalEntity(Legal_Entity__c objlglentity)
    {
      insert objlglentity;            
       return objlglentity;
    }    
    
    public Static Broker__c CreateBroker(Broker__c objBroK)
    {
      insert objBroK;            
       return objBroK;
    }
    public Static Project__c CreateProject(Project__c objpr )
    {
      insert objpr;            
       return objpr;
    }
  
     public Static Tower__c CreateTower(Tower__c t )
    {
      insert t;            
       return t;
    }
   
     public Static Tax_Slab__c CreateTaxSlab(Tax_Slab__c t )
    {
      insert t;            
      return t;
    }
    
    
    public Static Project_Unit_Type__c CreateProjectUnitType( Project_Unit_Type__c objProjectUnitType)
    {
      insert objProjectUnitType;            
       return objProjectUnitType;
    }
   public Static Unit_Number_Structure__c CreateUnitNumberStructure(Unit_Number_Structure__c  objUn )
    {
         
      insert objUn;              
       return objUn;
    }
    
    public Static Global_Charges__c CreateGlobalCharges(Global_Charges__c ObjGloChrg)
    {
         
      insert ObjGloChrg;            
       return ObjGloChrg;
    }
    public Static Project_Charges__c CreateProjectCharges(Project_Charges__c PCharge )
    {
         
      insert PCharge;            
       return PCharge;
    }
     
    public Static Project_Unit__c CreateProjectUnit(Project_Unit__c  objPU)
    {
         
      insert objPU;             
       return objPU;
    }
   public Static Customer_Pay_Plan_Header__c CreateCustomerPayPlanHeader(Customer_Pay_Plan_Header__c objCustomerPayPlanHeader)
    {
         
       insert objCustomerPayPlanHeader ;            
       return objCustomerPayPlanHeader;
    }
     public Static Standard_Customer_Pay_Plan_Detail__c CreateCustomerPayPlanHeaderDetail(Standard_Customer_Pay_Plan_Detail__c objSPPD)
    {
         
      insert objSPPD;             
       return objSPPD;
    }
      public Static Standard_Pay_Plan_Header__c CreateStandardPayPlanHeader(Standard_Pay_Plan_Header__c objSPP)
    {
      insert objSPP;            
      return objSPP;
    }
     public Static Rate_List_Header__c CreateRateListHeader(Rate_List_Header__c objRlh)
    {
         
         insert objRlh;
            
       return objRlh;
    }
    
    public Static Rate_List_Detail__c CreateRateListHeader(Rate_List_Detail__c objRld)
    {
         
         insert objRld;
            
       return objRld;
    }
    
     public Static Rate_List__c CreateRateList(Rate_List__c objRL)
    {
         
         insert objRL;
            
       return objRL;
    }
     public Static Receipt__c CreateReceipt(Receipt__c objRec  )
    {
      insert objRec;             
       return objRec;
    }
    public Static Receipt_Details__c CreateReceiptDetail(Receipt_Details__c objRecDtl)
    {
      insert objRecDtl;           
       return objRecDtl;
    }
       public Static Booking__c CreateBooking(Booking__c objBk)
    {
         
         insert objBk;
            
       return objBk;
    }
     /*public Static Transfer_Header__c CreateTransferHeader(Transfer_Header__c objTrnsfr)
    {
         
         insert objTrnsfr;
            
       return objTrnsfr;
    }*/
    public static Opportunity CreateOpportunity(Opportunity objopportunity)
   {
        
        insert objopportunity;
        return  objopportunity;
    }
   public static Account CreateAccount(Account ObjAcc)
   {
      insert objAcc;
   return ObjAcc;
   }
}