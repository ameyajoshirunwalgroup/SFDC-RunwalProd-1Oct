public class ShowPaymentPlanController 
{
    public Payment_Plan__c objPaymentPlan {get;set;}
    
    public List<Project_Charges__c> lstProjectCharges {get;set;}
    public List<Standard_Pay_Plan_Header__c> lstPayPlanHeader {get;set;}
    public List<List<Standard_Customer_Pay_Plan_Detail__c>> lstPayPlanDetails {get;set;}
   
    public String strId {get;set;}    
    
    public ShowPaymentPlanController(ApexPages.StandardController controller)
    {
        objPaymentPlan = new Payment_Plan__c();
        lstProjectCharges = new List<Project_Charges__c>();
        lstPayPlanHeader = new List<Standard_Pay_Plan_Header__c>();
        lstPayPlanDetails = new List<List<Standard_Customer_Pay_Plan_Detail__c>>();
        
        strId = '';
        
        /*if(ApexPages.currentPage().getParameters().get('id') != Null && ApexPages.currentPage().getParameters().get('id') != '')
        {
            strId = ApexPages.currentPage().getParameters().get('id');
        }*/
        
        //Added on 21-10-2021 by Vinay-- Start
        String strId = controller.getId();
        //Added on 21-10-2021 by Vinay-- End
        
        
        if(strId != Null && strId != '')
        {
            objPaymentPlan = [select Id, Name, Project__c from Payment_Plan__c where Id =: strId];
            
            if(objPaymentPlan.Project__c != Null)
            {
                lstProjectCharges = [select Id, Name from Project_Charges__c where Project__c =: objPaymentPlan.Project__c AND Payment_Plan_Applicable__c = true ORDER BY Name limit 999];       
                
                lstPayPlanHeader = [select Id, Name, Charge_Code__r.Name from Standard_Pay_Plan_Header__c where Payment_Plan__c =: objPaymentPlan.Id AND Project__c =: objPaymentPlan.Project__c ORDER BY Charge_Code__r.Name limit 999];
                
                Set<Id> setHeaderId = new Set<Id>();
                
                if(lstPayPlanHeader != Null && lstPayPlanHeader.size() > 0)
                {
                    for(Standard_Pay_Plan_Header__c objPayPlanHeader : lstPayPlanHeader)
                    {
                        setHeaderId.add(objPayPlanHeader.Id);
                    }
                    
                    if(setHeaderId != Null && setHeaderId.size() > 0)
                    {
                        List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForDays = [select Id, Registration_Linked__c , Standard_Pay_Plan_Header__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                                                                            where Standard_Pay_Plan_Header__c IN: setHeaderId AND 
                                                                            Is_to_be_Paid__c = 'From Dt. of Booking'
                                                                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999];
                        
                       List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForRegisDt = [select Id, Registration_Linked__c, Standard_Pay_Plan_Header__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                                                                            where Standard_Pay_Plan_Header__c IN: setHeaderId AND 
                                                                            Is_to_be_Paid__c = 'From Dt. of Registration' 
                                                                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999];
                      
                      List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForRegistration = [select Id, Registration_Linked__c , Standard_Pay_Plan_Header__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                                                                            where Standard_Pay_Plan_Header__c IN: setHeaderId AND 
                                                                            Is_to_be_Paid__c = 'Registration' 
                                                                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999];
                      
                        
                        List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForStages = [select Id, Registration_Linked__c , Standard_Pay_Plan_Header__c, Project_Construction_Stages__r.Sequence_No__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c where Standard_Pay_Plan_Header__c IN: setHeaderId AND Is_to_be_Paid__c = 'Construction Stage' AND Customer_Pay_Plan_Header__c = Null ORDER BY Project_Construction_Stages__r.Sequence_No__c limit 999];
                        if(lstPayPlanDetailsForDays != Null && lstPayPlanDetailsForDays.size() > 0)
                        {
                            Set<Integer> Days = new Set<Integer>();
                            
                            for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForDays)
                            {
                                Days.add(Integer.valueof(objPayPlan.Days_Months_Value__c));
                            }
                            system.debug('test' + Days);
                            if(Days != Null && Days.size() > 0)
                            {
                                for(Integer objDay : Days)
                                {
                                    List<Standard_Customer_Pay_Plan_Detail__c> lstTempPayPlanDetails = new List<Standard_Customer_Pay_Plan_Detail__c>();
                                    
                                    for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForDays)
                                    {
                                        if(Integer.valueof(objPayPlan.Days_Months_Value__c) == objDay)
                                        {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }
                                    
                                    if(lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0)
                                    {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                        system.debug('test1' + lstPayPlanDetails);
                                    }
                                }
                            }
                        }

                        if(lstPayPlanDetailsForRegisDt != Null && lstPayPlanDetailsForRegisDt.size() > 0)
                        {
                            Set<Integer> Days = new Set<Integer>();
                            
                            for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForRegisDt)
                            {
                                Days.add(Integer.valueof(objPayPlan.Days_Months_Value__c));
                            }
                            system.debug('test' + Days);
                            if(Days != Null && Days.size() > 0)
                            {
                                for(Integer objDay : Days)
                                {
                                    List<Standard_Customer_Pay_Plan_Detail__c> lstTempPayPlanDetails = new List<Standard_Customer_Pay_Plan_Detail__c>();
                                    
                                    for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForRegisDt)
                                    {
                                        if(Integer.valueof(objPayPlan.Days_Months_Value__c) == objDay)
                                        {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }
                                    
                                    if(lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0)
                                    {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                        system.debug('test1 from Registration date' + lstPayPlanDetails);
                                    }
                                }
                            }
                        }
                        if(lstPayPlanDetailsForRegistration != Null && lstPayPlanDetailsForRegistration.size() > 0)
                        {
                            Set<Integer> Days = new Set<Integer>();
                            
                            for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForRegistration)
                            {
                                Days.add(Integer.valueof(objPayPlan.Days_Months_Value__c));
                            }
                            system.debug('test' + Days);
                            if(Days != Null && Days.size() > 0)
                            {
                                for(Integer objDay : Days)
                                {
                                    List<Standard_Customer_Pay_Plan_Detail__c> lstTempPayPlanDetails = new List<Standard_Customer_Pay_Plan_Detail__c>();
                                    
                                    for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForRegistration)
                                    {
                                        if(Integer.valueof(objPayPlan.Days_Months_Value__c) == objDay)
                                        {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }
                                    
                                    if(lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0)
                                    {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                        system.debug('test1 on registration' + lstPayPlanDetails);
                                    }
                                }
                            }
                        }
                        
                        if(lstPayPlanDetailsForStages != Null && lstPayPlanDetailsForStages.size() > 0)
                        {
                            Set<Integer> Stages = new Set<Integer>();
                            
                            for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForStages)
                            {
                                Stages.add(Integer.valueof(objPayPlan.Project_Construction_Stages__r.Sequence_No__c));
                            }
                            system.debug('test' + Stages);
                            if(Stages != Null && Stages.size() > 0)
                            {
                                for(Integer objStage : Stages)
                                {
                                    List<Standard_Customer_Pay_Plan_Detail__c> lstTempPayPlanDetails = new List<Standard_Customer_Pay_Plan_Detail__c>();
                                    set<string> setSCPPD = new set<string>();
                                    for(Standard_Customer_Pay_Plan_Detail__c objPayPlan : lstPayPlanDetailsForStages)
                                    {
                                        if(Integer.valueof(objPayPlan.Project_Construction_Stages__r.Sequence_No__c) == objStage && !setSCPPD.Contains(objPayPlan.Standard_Pay_Plan_Header__c))
                                        {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                            setSCPPD.add(objPayPlan.Standard_Pay_Plan_Header__c);
                                        }
                                    }                                    
                                    if(lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0)
                                    {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}