public class NewPaymentPlanController {
    public Payment_Plan__c objPaymentPlan {
        get;
        set;
    }
    public Standard_Customer_Pay_Plan_Detail__c objPayPlanDetail {
        get;
        set;
    }

    public List < Project_Charges__c > lstProjectCharges {
        get;
        set;
    }
    public List < WrapperClassForCreation > lstWrapperClassForCreation {
        get;
        set;
    }
    public List < Standard_Pay_Plan_Header__c > lstPayPlanHeader {
        get;
        set;
    }
    public List < List < Standard_Customer_Pay_Plan_Detail__c >> lstPayPlanDetails {
        get;
        set;
    }
    public List < Standard_Customer_Pay_Plan_Detail__c > lstEditPayPlanDetails {
        get;
        set;
    }
    public List < Standard_Customer_Pay_Plan_Detail__c > lstUpdatePayPlanDetails {
        get;
        set;
    }

    public String strId {
        get;
        set;
    }
    public String strTask {
        get;
        set;
    }
    public String PlanHeaderId {
        get;
        set;
    }
    public String ErrorMsg {
        get;
        set;
    }
    public String EditValue {
        get;
        set;
    }
    public String Pid {
        get;
        set;
    }
    public String tID {
        get;
        set;
    }

    public Boolean showStage {
        get;
        set;
    }
    public Boolean EditMode {
        get;
        set;
    }
    public Boolean bankFunded {get;set;}

    public class WrapperClassForCreation {
        public String ProjectId {
            get;
            set;
        }
        public String PlanId {
            get;
            set;
        }
        public String ChargeId {
            get;
            set;
        }
        public String ChargeName {
            get;
            set;
        }
        public Boolean SelectCharge {
            get;
            set;
        }
        public Standard_Customer_Pay_Plan_Detail__c objPayPlanDetail {
            get;
            set;
        }

        public WrapperClassForCreation() {
            ProjectId = '';
            PlanId = '';
            ChargeId = '';
            ChargeName = '';
            SelectCharge = false;
            objPayPlanDetail = new Standard_Customer_Pay_Plan_Detail__c();
        }
    }

    public NewPaymentPlanController(ApexPages.StandardController controller) {

    }

    public void Constructor() {
        objPaymentPlan = new Payment_Plan__c();
        objPayPlanDetail = new Standard_Customer_Pay_Plan_Detail__c();
        lstProjectCharges = new List < Project_Charges__c > ();
        lstWrapperClassForCreation = new List < WrapperClassForCreation > ();
        lstPayPlanHeader = new List < Standard_Pay_Plan_Header__c > ();
        lstPayPlanDetails = new List < List < Standard_Customer_Pay_Plan_Detail__c >> ();
        lstEditPayPlanDetails = new List < Standard_Customer_Pay_Plan_Detail__c > ();
        lstUpdatePayPlanDetails = new List < Standard_Customer_Pay_Plan_Detail__c > ();

        strId = '';
        PlanHeaderId = '';
        ErrorMsg = '';
        showStage = false;
        bankFunded = false;

        if (ApexPages.currentPage().getParameters().get('pid') != Null && ApexPages.currentPage().getParameters().get('pid') != '') {
            strId = ApexPages.currentPage().getParameters().get('pid');
        }
        if (ApexPages.currentPage().getParameters().get('task') != Null && ApexPages.currentPage().getParameters().get('task') != '') {
            strTask = ApexPages.currentPage().getParameters().get('task');
        }

        if (strId != Null && strId != '') {
            objPaymentPlan = [select Id, Name, Plan_Code__c, Project__c, Tower__c, Tower__r.Name,Sub_Vention__c from Payment_Plan__c where Id = : strId];
            if(objPaymentPlan != null){
                if(objPaymentPlan.Sub_Vention__c){
                    bankFunded = true;
                }
            }
            if (objPaymentPlan.Project__c != Null) {
                PId = objPaymentPlan.Project__c;
                tID = objPaymentPlan.Tower__c;
                System.debug('amit' + pid);
                lstProjectCharges = [select Id, Name from Project_Charges__c where Project__c = : objPaymentPlan.Project__c AND Payment_Plan_Applicable__c = true ORDER BY Name limit 999];

                if (lstProjectCharges != Null && lstProjectCharges.size() > 0) {
                    for (Project_Charges__c objProjectCharges: lstProjectCharges) {
                        WrapperClassForCreation objWrapperClassForCreation = new WrapperClassForCreation();

                        objWrapperClassForCreation.PlanId = objPaymentPlan.Id;
                        objWrapperClassForCreation.ProjectId = objPaymentPlan.Project__c;
                        objWrapperClassForCreation.ChargeId = objProjectCharges.Id;
                        objWrapperClassForCreation.ChargeName = objProjectCharges.Name;

                        lstWrapperClassForCreation.add(objWrapperClassForCreation);
                    }
                } else {
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.Info, 'No Project Charge Defined For Payment Plan');
                    ApexPages.addMessage(msg);


                }
                lstPayPlanHeader = [select Id, Name, Charge_Code__r.Name, Tower__r.Name, Project__r.Name from Standard_Pay_Plan_Header__c where Payment_Plan__c = : objPaymentPlan.Id AND Project__c = : objPaymentPlan.Project__c ORDER BY Charge_Code__r.Name limit 999];

                Set < Id > setHeaderId = new Set < Id > ();

                if (lstPayPlanHeader != Null && lstPayPlanHeader.size() > 0) {
                    for (Standard_Pay_Plan_Header__c objPayPlanHeader: lstPayPlanHeader) {
                        setHeaderId.add(objPayPlanHeader.Id);
                    }

                    if (setHeaderId != Null && setHeaderId.size() > 0) {
                        List < Standard_Customer_Pay_Plan_Detail__c > lstPayPlanDetailsForDays = [select Id, Is_to_be_Paid__c, Registration_Linked__c, On_date__c, Standard_Pay_Plan_Header__c, Days_Months__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c where Standard_Pay_Plan_Header__c IN: setHeaderId AND Is_to_be_Paid__c = 'From Dt. of Booking'
                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999
                        ];

                        List < Standard_Customer_Pay_Plan_Detail__c > lstPayPlanDetailsForStages = [select Id, Is_to_be_Paid__c, Registration_Linked__c, On_date__c, Standard_Pay_Plan_Header__c, Days_Months__c, Days_Months_Value__c, Project_Construction_Stages__r.Sequence_No__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c where Standard_Pay_Plan_Header__c IN: setHeaderId AND Is_to_be_Paid__c = 'Construction Stage'
                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Project_Construction_Stages__r.Sequence_No__c limit 999
                        ];

                        List < Standard_Customer_Pay_Plan_Detail__c > lstPayPlanDetailsForReg = [select Id, Is_to_be_Paid__c, Registration_Linked__c, On_date__c, Standard_Pay_Plan_Header__c, Days_Months__c, Days_Months_Value__c, Project_Construction_Stages__r.Sequence_No__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c where Standard_Pay_Plan_Header__c IN: setHeaderId AND Is_to_be_Paid__c = 'Registration'
                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999
                        ];

                        List < Standard_Customer_Pay_Plan_Detail__c > lstPayPlanDetailsForRegisDt = [select Id, Is_to_be_Paid__c, Registration_Linked__c, On_date__c, Standard_Pay_Plan_Header__c, Days_Months__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                            where Standard_Pay_Plan_Header__c IN: setHeaderId AND
                            Is_to_be_Paid__c = 'From Dt. of Registration'
                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999
                        ];

                        if (lstPayPlanDetailsForDays != Null && lstPayPlanDetailsForDays.size() > 0) {
                            Set < Integer > Days = new Set < Integer > ();

                            for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForDays) {
                                Days.add(Integer.valueof(objPayPlan.Days_Months_Value__c));
                            }
                            //system.debug('test' + Days);
                            if (Days != Null && Days.size() > 0) {
                                for (Integer objDay: Days) {
                                    List < Standard_Customer_Pay_Plan_Detail__c > lstTempPayPlanDetails = new List < Standard_Customer_Pay_Plan_Detail__c > ();

                                    for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForDays) {
                                        if (Integer.valueof(objPayPlan.Days_Months_Value__c) == objDay) {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }

                                    if (lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0) {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                    }
                                }
                            }
                        }
                        system.debug('Sumit lstPayPlanDetails______' + lstPayPlanDetails);
                        if (lstPayPlanDetailsForStages != Null && lstPayPlanDetailsForStages.size() > 0) {
                            Set < Integer > Stages = new Set < Integer > ();

                            for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForStages) {
                                Stages.add(Integer.valueof(objPayPlan.Project_Construction_Stages__r.Sequence_No__c));
                            }
                            system.debug('test' + Stages);
                            if (Stages != Null && Stages.size() > 0) {
                                for (Integer objStage: Stages) {
                                    List < Standard_Customer_Pay_Plan_Detail__c > lstTempPayPlanDetails = new List < Standard_Customer_Pay_Plan_Detail__c > ();

                                    for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForStages) {
                                        if (Integer.valueof(objPayPlan.Project_Construction_Stages__r.Sequence_No__c) == objStage) {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }

                                    if (lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0) {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                    }
                                }
                            }
                        }

                        if (lstPayPlanDetailsForReg != Null && lstPayPlanDetailsForReg.size() > 0) {
                            Set < Integer > Days = new Set < Integer > ();

                            for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForReg) {
                                Days.add(Integer.valueof(objPayPlan.Days_Months_Value__c));
                            }
                            system.debug('test' + Days);
                            if (Days != Null && Days.size() > 0) {
                                for (Integer objDay: Days) {
                                    List < Standard_Customer_Pay_Plan_Detail__c > lstTempPayPlanDetails = new List < Standard_Customer_Pay_Plan_Detail__c > ();

                                    for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForReg) {
                                        if (Integer.valueof(objPayPlan.Days_Months_Value__c) == objDay) {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }

                                    if (lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0) {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                    }
                                }
                            }
                        }

                        if (lstPayPlanDetailsForRegisDt != Null && lstPayPlanDetailsForRegisDt.size() > 0) {
                            Set < Integer > Days = new Set < Integer > ();

                            for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForRegisDt) {
                                Days.add(Integer.valueof(objPayPlan.Days_Months_Value__c));
                            }
                            system.debug('test' + Days);
                            if (Days != Null && Days.size() > 0) {
                                for (Integer objDay: Days) {
                                    List < Standard_Customer_Pay_Plan_Detail__c > lstTempPayPlanDetails = new List < Standard_Customer_Pay_Plan_Detail__c > ();

                                    for (Standard_Customer_Pay_Plan_Detail__c objPayPlan: lstPayPlanDetailsForRegisDt) {
                                        if (Integer.valueof(objPayPlan.Days_Months_Value__c) == objDay) {
                                            lstTempPayPlanDetails.add(objPayPlan);
                                        }
                                    }

                                    if (lstTempPayPlanDetails != Null && lstTempPayPlanDetails.size() > 0) {
                                        lstPayPlanDetails.add(lstTempPayPlanDetails);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (strTask == 'edit') {
            EditMode = true;
        }




    }

    public void ChangeIsToBePaid() {
        objPayPlanDetail.Project__c = PId;
        objPayPlanDetail.Tower__c = tID;
        System.debug('amit' + objPayPlanDetail.Project__c);
        if (objPayPlanDetail.Is_to_be_Paid__c == 'Construction Stage') {
            showStage = true;
        } else {
            objPayPlanDetail.Project_Construction_Stages__c = Null;
            showStage = false;
        }
    }

    public PageReference AddMilestone() {
        boolean iselectcharg = false;

        if (lstWrapperClassForCreation != Null && lstWrapperClassForCreation.size() > 0) {
            for (WrapperClassForCreation objWrapperClassForCreation: lstWrapperClassForCreation) {
                System.debug('amit select charge' + objWrapperClassForCreation.SelectCharge);
                if (objWrapperClassForCreation.SelectCharge == true) {
                    iselectcharg = true;
                    if (objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c != null) {

                        if (objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c < 0) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '% Amount value cannot be negative.');
                            ApexPages.addMessage(msg);
                            return null;

                        }

                    }

                    if (objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c != null) {

                        if (objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c < 0) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '% Calculate Inst. Amount cannot be negative.');
                            ApexPages.addMessage(msg);
                            return null;
                        }

                    }

                    if (objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c != null) {

                        if (objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c < 0) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ' Total Charge value cannot be negative.');
                            ApexPages.addMessage(msg);
                            return null;
                        }

                    }


                    if ((objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c == 0 || objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c == null) && ((objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c == 0 || objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c == null) && (objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c == 0 || objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c == null))) {
                        if (objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c == 0 || objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c == null) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '% Amount value cannot be zero.');
                            ApexPages.addMessage(msg);
                            return null;
                        }
                        if ((objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c == 0 || objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c == null) && (objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c == 0 || objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c == null)) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Calculate Inst. Amount as % value cannot be zero.');
                            ApexPages.addMessage(msg);
                            return null;
                        }
                    }

                    //--- Line Added By Sumit Banarji-----//
                    Savepoint sp = Database.setSavepoint();

                    List < Standard_Pay_Plan_Header__c > lstPayPlanHeader = [select Id, Name from Standard_Pay_Plan_Header__c where Payment_Plan__c = : objWrapperClassForCreation.PlanId AND Project__c = : objWrapperClassForCreation.ProjectId AND Charge_Code__c = : objWrapperClassForCreation.ChargeId limit 1];
                    if (lstPayPlanHeader != Null & lstPayPlanHeader.size() > 0) {
                        PlanHeaderId = lstPayPlanHeader[0].Id;
                    } else {
                        Standard_Pay_Plan_Header__c objPayPlanHeader = new Standard_Pay_Plan_Header__c();

                        objPayPlanHeader.Name = 'xyz';
                        objPayPlanHeader.Payment_Plan__c = objWrapperClassForCreation.PlanId;
                        objPayPlanHeader.Project__c = objWrapperClassForCreation.ProjectId;
                        objPayPlanHeader.Charge_Code__c = objWrapperClassForCreation.ChargeId;
                        objPayPlanHeader.Effective_from__c = System.Today();
                        objPayPlanHeader.Plan_Code__c = objPaymentPlan.Plan_Code__c;
                        objPayPlanHeader.Tower__c = objPaymentPlan.Tower__c;
                        Database.SaveResult sr = Database.insert(objPayPlanHeader);

                        if (sr.isSuccess()) {
                            PlanHeaderId = sr.getId();
                        }
                    }

                    if (PlanHeaderId != '') {
                        list < Standard_Pay_Plan_Header__c > lstExistingPayHeader = new list < Standard_Pay_Plan_Header__c > ();
                        //--------- Lines added by Sumit Banarji------------//

                        for (list < Standard_Customer_Pay_Plan_Detail__c > lstPPD: lstPayPlanDetails) {
                            System.debug('Lst Pay Plan Records lstPPD:' + lstPPD);

                            for (Standard_Customer_Pay_Plan_Detail__c objPPD: lstPPD) {
                                System.debug('Lst Pay Plan Records:  objPPD' + objPPD);

                                if (
                                    objPPD.Is_to_be_Paid__c != null && objPPD.Is_to_be_Paid__c == objPayPlanDetail.Is_to_be_Paid__c &&
                                    (
                                        (
                                            objPPD.Days_Months_Value__c != null && objPayPlanDetail.Days_Months_Value__c != null &&
                                            objPayPlanDetail.Days_Months__c != null && objPPD.Days_Months__c != null &&
                                            objPPD.Days_Months_Value__c == objPayPlanDetail.Days_Months_Value__c &&
                                            objPayPlanDetail.Days_Months__c == objPPD.Days_Months__c && objPPD.Is_to_be_Paid__c == 'From Dt. of Booking'
                                        ) ||
                                        (
                                            objPPD.On_date__c != null && objPayPlanDetail.On_date__c != null &&
                                            objPPD.On_date__c == objPayPlanDetail.On_date__c
                                        ) ||
                                        (
                                            objPPD.Is_to_be_Paid__c == 'Construction Stage' &&
                                            objPPD.Project_Construction_Stages__c != null && objPayPlanDetail.Project_Construction_Stages__c != null &&
                                            objPPD.Project_Construction_Stages__c == objPayPlanDetail.Project_Construction_Stages__c &&
                                            objPPD.Days_Months_Value__c != null && objPayPlanDetail.Days_Months_Value__c != null &&
                                            objPayPlanDetail.Days_Months__c != null && objPPD.Days_Months__c != null &&
                                            objPPD.Days_Months_Value__c == objPayPlanDetail.Days_Months_Value__c &&
                                            objPayPlanDetail.Days_Months__c == objPPD.Days_Months__c
                                        )
                                    )
                                ) {
                                    System.debug('Here');
                                } else {
                                    system.debug('Sumit ');
                                }
                            }
                        }
                        //---------End Lines added by Sumit Banarji-------//


                        Standard_Customer_Pay_Plan_Detail__c objSavePayPlanDetail = new Standard_Customer_Pay_Plan_Detail__c();

                        objSavePayPlanDetail.Is_to_be_Paid__c = objPayPlanDetail.Is_to_be_Paid__c;
                        objSavePayPlanDetail.Project_Construction_Stages__c = objPayPlanDetail.Project_Construction_Stages__c;
                        objSavePayPlanDetail.Days_Months__c = objPayPlanDetail.Days_Months__c;
                        objSavePayPlanDetail.Days_Months_Value__c = objPayPlanDetail.Days_Months_Value__c;
                        objSavePayPlanDetail.Amount__c = objWrapperClassForCreation.objPayPlanDetail.Amount__c;
                        objSavePayPlanDetail.Amount_Value__c = objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c;
                        objSavePayPlanDetail.Calculate_Installment_Amount_as__c = objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c;
                        objSavePayPlanDetail.Total_Charge_Value_Minus__c = objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c;
                        objSavePayPlanDetail.Registration_Linked__c = objWrapperClassForCreation.objPayPlanDetail.Registration_Linked__c;
                        objSavePayPlanDetail.Project__c = objWrapperClassForCreation.ProjectId;
                        objSavePayPlanDetail.Standard_Pay_Plan_Header__c = PlanHeaderId;
                        objSavePayPlanDetail.Tower__c = tID;
                         objSavePayPlanDetail.OC_Milestone__c = objWrapperClassForCreation.objPayPlanDetail.OC_Milestone__c;

                        try {
                            insert objSavePayPlanDetail;
                        } catch (DMLException excep) {
                            if (excep.getDMLmessage(0).contains('Unique_ConstructionStage__c') == true) {
                                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'This Project Construction Stage already defined.');
                                ApexPages.addMessage(msg);
                                return null;
                            }
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excep.getDMLmessage(0));
                            ApexPages.addMessage(msg);
                        }
                    }
                }
            }
            if (iselectcharg == false) {
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, 'Please select Project Charges.');
                ApexPages.addMessage(msg);
                return null;
            }
        }

        return (new PageReference('/apex/NewPaymentPlan?pid=' + strId));
    }

    public void EditCharge() {
        try {
            if (EditValue != null) {
                integer i = Integer.valueOf(EditValue);

                if (lstPayPlanDetails[i] != Null) {
                    Set < Id > setId = new Set < Id > ();

                    for (Standard_Customer_Pay_Plan_Detail__c objTempDetails: lstPayPlanDetails[i]) {
                        setId.add(objTempDetails.Id);
                    }

                    if (setId != Null && setId.size() > 0) {
                        lstEditPayPlanDetails = [select Id, Name, Is_to_be_Paid__c, Project_Construction_Stages__c, Days_Months__c, Days_Months_Value__c, Amount__c, Amount_Value__c, Calculate_Installment_Amount_as__c, Total_Charge_Value_Minus__c, Project_Charge__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c where Id IN: setId];

                        if (lstEditPayPlanDetails != Null && lstEditPayPlanDetails.size() > 0) {
                            for (Standard_Customer_Pay_Plan_Detail__c obj: lstEditPayPlanDetails) {
                                objPayPlanDetail.Is_to_be_Paid__c = obj.Is_to_be_Paid__c;
                                objPayPlanDetail.Project_Construction_Stages__c = obj.Project_Construction_Stages__c;
                                objPayPlanDetail.Days_Months__c = obj.Days_Months__c;
                                objPayPlanDetail.Days_Months_Value__c = obj.Days_Months_Value__c;
                                break;
                            }
                            for (Standard_Customer_Pay_Plan_Detail__c obj: lstEditPayPlanDetails) {
                                for (WrapperClassForCreation objwrapper: lstWrapperClassForCreation) {
                                    if (objWrapper.ChargeId.substring(0, 15) == obj.Project_Charge__c) {
                                        objWrapper.SelectCharge = true;
                                        objWrapper.objPayPlanDetail = obj;
                                    }
                                }
                            }

                            ChangeIsToBePaid();
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.Debug('Error in RowEditCall,RowEditCall' + ex);
        }
    }

    public PageReference DeleteCharge() {
        try {
            if (EditValue != null) {
                integer i = Integer.valueOf(EditValue);

                if (lstPayPlanDetails[i] != Null) {
                    List < Standard_Customer_Pay_Plan_Detail__c > lstTempDetails = lstPayPlanDetails[i];

                    if (lstTempDetails != Null && lstTempDetails.size() > 0) {
                        delete lstTempDetails;
                        return (new PageReference('/apex/NewPaymentPlan?pid=' + strId + '&task=edit'));
                    }
                }
            }
            return Null;
        } catch (Exception ex) {
            System.Debug('Error in RowDelCall,RowDelCall' + ex);
            return Null;
        }
    }

    public PageReference Save() {
        if (lstEditPayPlanDetails != Null && lstEditPayPlanDetails.size() > 0) {
            if (lstWrapperClassForCreation != Null && lstWrapperClassForCreation.size() > 0) {
                for (WrapperClassForCreation objWrapperClassForCreation: lstWrapperClassForCreation) {


                    if (objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c != null) {

                        if (objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c < 0) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '% Amount value cannot be negative.');
                            ApexPages.addMessage(msg);
                            return null;

                        }

                    }

                    if (objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c != null) {

                        if (objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c < 0) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, '% Calculate Inst. Amount cannot be negative.');
                            ApexPages.addMessage(msg);
                            return null;

                        }

                    }

                    if (objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c != null) {

                        if (objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c < 0) {
                            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ' Total Charge value cannot be negative.');
                            ApexPages.addMessage(msg);
                            return null;
                        }

                    }



                    if (objWrapperClassForCreation.SelectCharge == true) {
                        for (Standard_Customer_Pay_Plan_Detail__c objDetail: lstEditPayPlanDetails) {
                            if (objWrapperClassForCreation.ChargeId.substring(0, 15) == objDetail.Project_Charge__c) {
                                objDetail.Is_to_be_Paid__c = objPayPlanDetail.Is_to_be_Paid__c;
                                objDetail.Project_Construction_Stages__c = objPayPlanDetail.Project_Construction_Stages__c;
                                objDetail.Days_Months__c = objPayPlanDetail.Days_Months__c;
                                objDetail.Days_Months_Value__c = objPayPlanDetail.Days_Months_Value__c;
                                objDetail.Amount__c = objWrapperClassForCreation.objPayPlanDetail.Amount__c;
                                objDetail.Amount_Value__c = objWrapperClassForCreation.objPayPlanDetail.Amount_Value__c;
                                objDetail.Calculate_Installment_Amount_as__c = objWrapperClassForCreation.objPayPlanDetail.Calculate_Installment_Amount_as__c;
                                objDetail.Total_Charge_Value_Minus__c = objWrapperClassForCreation.objPayPlanDetail.Total_Charge_Value_Minus__c;
                                objDetail.Registration_Linked__c = objWrapperClassForCreation.objPayPlanDetail.Registration_Linked__c;
                                objDetail.OC_Milestone__c = objWrapperClassForCreation.objPayPlanDetail.OC_Milestone__c;
                                
                                lstUpdatePayPlanDetails.add(objDetail);
                            }
                        }
                    }
                }

                if (lstUpdatePayPlanDetails != Null && lstUpdatePayPlanDetails.size() > 0) {
                    try {
                        update lstUpdatePayPlanDetails;
                    } catch (DMLException excep) {
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excep.getDMLmessage(0));
                        ApexPages.addMessage(msg);
                    }
                }
                return (new PageReference('/apex/NewPaymentPlan?pid=' + strId));
            }
        }
        return Null;
    }

    public PageReference Close() {
        return (new PageReference('/' + objPaymentPlan.Id));
    }

    public PageReference Cancel() {
        return (new PageReference('/' + objPaymentPlan.Project__C));
    }
}