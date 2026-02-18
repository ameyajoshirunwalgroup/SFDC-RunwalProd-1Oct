@RestResource(urlMapping='/cpGetCPInvoicesStatus/*')
global without sharing class Lockated_CPGetCPInvoicesStatus {
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> responseMap = new Map<String, Object>();
        
        String invId = req.params.get('invId');
        
        List<String> missingParams = new List<String>();
        if (String.isBlank(invId)) missingParams.add('invId');
        
        if (!missingParams.isEmpty()) {
            res.statusCode = 400;
            responseMap.put('status', 'error');
            responseMap.put('message', 'Missing required parameters: ' + String.join(missingParams, ', '));
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            return; // Stop execution if validation fails
        }
        try{
            List<Wrapper> wrapperList = new List<Wrapper>();
            //Changes made by Prashant to update BI and CPB depends on what Id is received in request.// 04-02-26. START...
            if (invId != null) {
                Id invIdNew = invId;
                Schema.SObjectType objType = invIdNew.getSObjectType();
                if (objType == CP_Brokerage__c.SObjectType) {
                    
                    list<CP_Brokerage__c> cpbinvlist = [
                        SELECT Id, Invoice_Number__c, If_GST_is_applicable__c,
                        Invoice_Date__c, Invoice_Status__c, Booking__c,
                        Booking__r.Project__c,
                        Booking__r.Project__r.Project_Property_Type__c,
                        Total_Invoice_Amount__c
                        FROM CP_Brokerage__c
                        WHERE Id = :invId
                        LIMIT 1
                    ];
                    if (!cpbinvlist.isEmpty()) {
                        for(CP_Brokerage__c cpBrokerage: cpbinvlist){
                            Wrapper wrapperObj = new Wrapper();
                            wrapperObj.status = cpBrokerage.Invoice_Status__c;
                            
                            //This is not directy to what status the business needs in the screen.
                            /*
                            So status goes like - 
                            1. Invoice Created & Submitted for Verification - When invoice is created and goes for clearing approval.(Approval Status(Eligibility check)= Submitted for Approval) 
                            2. Invoice Eligible for Payout - When clearing approval is approved.(Approval Status(Eligibility check)	= Approved by L1)
                            3. Invoice Uploaded by CP(CP Uploades the documents and update details from portal)
                            4. Invoice Reuploaded by Billing team - Submitted for Payout Approval (Submit for approval )
                            5. Invoice to be Approved by Billing 
                            6. Invoice to be Approved by Accounts 
                            7. Invoice details sent to SAP
                            
                            Need to give the mapping manually based on the process change...
*/
                            wrapperObj.invNumber = cpBrokerage.Invoice_Number__c;
                            wrapperObj.amount = cpBrokerage.Total_Invoice_Amount__c	;																										
                            //Get Picklist values to map.
                            Schema.DescribeFieldResult fieldResult = CP_Brokerage__c.Invoice_Status__c.getDescribe();
                            List<Schema.PicklistEntry> pickValues = fieldResult.getPicklistValues();
                            wrapperObj.statuslist = getDynamicStatusList(cpBrokerage.Invoice_Status__c); 
                            if(cpBrokerage.Booking__c != null && cpBrokerage.Booking__r.Project__c != null && 
                               cpBrokerage.Booking__r.Project__r.Project_Property_Type__c != null){
                                   wrapperObj.booking = cpBrokerage.Booking__r.Project__r.Project_Property_Type__c;
                                   
                               }
                            wrapperList.add(wrapperObj);
                        }
                        res.statusCode = 200;
                        responseMap.put('status', 'success');
                        responseMap.put('id', invId);
                        responseMap.put('details',wrapperList);
                    }
                    else{
                        res.statusCode = 404;
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'No CP_Brokerage__c record found with Id: ' + invId);
                    }
                    
                    
                } else if (objType == Brokerage_Invoice__c.SObjectType) {
                    
                    list<Brokerage_Invoice__c> invlist = [
                        SELECT Id, Invoice_Number__c, If_GST_is_applicable__c,
                        Invoice_Date__c, Invoice_Status__c, Booking__c,
                        Booking__r.Project__c,
                        Booking__r.Project__r.Project_Property_Type__c,
                        Invoice_Amount__c
                        FROM Brokerage_Invoice__c
                        WHERE Id = :invId
                        LIMIT 1
                    ];
                    
                    if (!invlist.isEmpty()) {
                        for(Brokerage_Invoice__c inv: invlist){
                            Wrapper wrapperObj = new Wrapper();
                            wrapperObj.status = inv.Invoice_Status__c;
                            
                            //This is not directy to what status the business needs in the screen.
                            /*
                            So status goes like - 
                            1. Invoice Created & Submitted for Verification - When invoice is created and goes for clearing approval.(Approval Status(Eligibility check)= Submitted for Approval) 
                            2. Invoice Eligible for Payout - When clearing approval is approved.(Approval Status(Eligibility check)	= Approved by L1)
                            3. Invoice Uploaded by CP(CP Uploades the documents and update details from portal)
                            4. Invoice Reuploaded by Billing team - Submitted for Payout Approval (Submit for approval )
                            5. Invoice to be Approved by Billing 
                            6. Invoice to be Approved by Accounts 
                            7. Invoice details sent to SAP
                            
                            Need to give the mapping manually based on the process change...
                            */
                            wrapperObj.invNumber = inv.Invoice_Number__c;
                            wrapperObj.amount = inv.Invoice_Amount__c;
                            //Get Picklist values to map.
                            Schema.DescribeFieldResult fieldResult = Brokerage_Invoice__c.Invoice_Status__c.getDescribe();
                            List<Schema.PicklistEntry> pickValues = fieldResult.getPicklistValues();
                            wrapperObj.statuslist = getDynamicStatusList(inv.Invoice_Status__c);
                            if(inv.Booking__c != null && inv.Booking__r.Project__c != null && 
                               inv.Booking__r.Project__r.Project_Property_Type__c != null){
                                   wrapperObj.booking = inv.Booking__r.Project__r.Project_Property_Type__c;
                                   
                               }
                            wrapperList.add(wrapperObj);
                        }
                        res.statusCode = 200;
                        responseMap.put('status', 'success');
                        responseMap.put('id', invId);
                        responseMap.put('details',wrapperList);
                    }
                    else{
                        res.statusCode = 404;
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'No Brokerage_Invoice__c record found with Id: ' + invId);
                    }
                }
            }
            //Changes made by Prashant to update BI and CPB depends on what Id is received in request.// 04-02-26. END...

            
            
            
        }catch(Exception ex){
            res.statusCode = 500;
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }
    
    // Define correct order manually
    static Map<String, Integer> statusOrder = new Map<String, Integer>{
        'Not Submitted'        => 1,
            'Invoice Downloaded'   => 2,
            'Invoice Uploaded'     => 3,
            'Payment in Progress'  => 4,
            'Payment Done'         => 5
            };

    
    public static List<statusWrapper> getDynamicStatusList(String currentStatus) {
        List<statusWrapper> statusList = new List<statusWrapper>();
        
        // Get the step number of current status
        Integer currentStep = statusOrder.containsKey(currentStatus)
            ? statusOrder.get(currentStatus)
            : 0;
        
        // Loop through your defined order (not picklist order)
        for (String keyStatus : statusOrder.keySet()) {
            
            statusWrapper sw = new statusWrapper();
            sw.title = keyStatus;
            sw.stepNumber = statusOrder.get(keyStatus);
            
            // Mark TRUE if step ≤ currentStep
            sw.status = (sw.stepNumber <= currentStep) ? 'true' : 'false';
            
            statusList.add(sw);
        }
        
        return statusList;
    }


    
    public class Wrapper{
        public list<statusWrapper> statuslist;
        public String status;
        public String invNumber;
        public String booking;
        public Decimal amount;
    }
    public class statusWrapper {
        public String title;
        public String status; 
        public Integer stepNumber; 
    }

}