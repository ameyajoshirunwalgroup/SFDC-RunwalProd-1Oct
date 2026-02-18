// Controller Class for CP Brokerage VF Page
public class CPBrokerageSAP {
    public Id BrokerageIds { get; set; }
    public Boolean EnterCondTypeforSAPDocNo { get; set; }
    public Set<Id> CPBrokerageIdSet = new Set<Id>();
    public List<CP_Brokerage__c> CPBrokerageList { get; set; }
    public String selectedPicklistValue { get; set; }
    
    // Picklist options for condition types
    public List<SelectOption> getPicklistOptions() {     
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ZEXB', 'ZEXB'));
        options.add(new SelectOption('ZFXB', 'ZFXB'));
        options.add(new SelectOption('ZGXB', 'ZGXB'));
        return options;
    }
    
    // Constructor
    public CPBrokerageSAP() {
        BrokerageIds = ApexPages.currentPage().getParameters().get('BrokerageIds');
        EnterCondTypeforSAPDocNo = Boolean.valueOf(ApexPages.currentPage().getParameters().get('EnterCondTypeforSAPDocNo'));
        CPBrokerageList = new List<CP_Brokerage__c>();
        
        // Initial validation in constructor (same as BrokerageInvoiceSAP)
        List<CP_Brokerage__c> blist = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c, Brokerage_Type__c, AOP__c
                                      FROM CP_Brokerage__c
                                     // WHERE Approval_Status__c = 'Approved By L4 - Accounts' AND Id = :BrokerageIds];
                                      WHERE Approval_Status__c = 'Approved By L3 - Accounts' AND Id = :BrokerageIds];//Added by Prashant as last status used is L3.//15-12-25..
        if (!blist.isEmpty() && blist.size() > 0 && EnterCondTypeforSAPDocNo == true) {
            if(blist[0].Brokerage_Type__c == 'Base Brokerage' && blist[0].AOP__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Condition type cannot be given for Base Brokerage type without AOP'));
            }
        } 
    }
    
    // Validate brokerage record on page load
    Public void validateBrokerageRecord(){
        try{
            List<CP_Brokerage__c> brokerageList = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c, 
                                                  Brokerage_Type__c, AOP__c, Total_Brokerage__c
                                                  FROM CP_Brokerage__c
                                                  WHERE Id = :BrokerageIds
                                                  LIMIT 1];
            
            if (!brokerageList.isEmpty()) {
                CP_Brokerage__c brokerage = brokerageList[0];
                System.debug('cp list'+brokerageList);
                // Check if already processed
                if(String.isNotBlank(brokerage.SAP_Document_No__c)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                        'This CP Brokerage has already been processed. SAP Document No: ' + brokerage.SAP_Document_No__c));
                }
                
                // Check approval status
                //if(brokerage.Approval_Status__c != 'Approved By L4 - Accounts'){
                if(brokerage.Approval_Status__c != 'Approved By L3 - Accounts'){//Added by Prashant as last status used is L3.//15-12-25..
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        'CP Brokerage must be approved by L3-Accounts before SAP processing. Current Status: ' + brokerage.Approval_Status__c));
                }
                
                // Validation for condition type
                if (EnterCondTypeforSAPDocNo == true) {
                    if(brokerage.Brokerage_Type__c == 'Base Brokerage'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                            'Condition type cannot be manually entered for Base Brokerage type without AOP'));
                    }
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'CP Brokerage record not found'));
            }
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Error validating record: ' + e.getMessage()));
            System.debug('Validation Error: ' + e.getMessage());
        }
    }
    
    
    // Main method to process CP Brokerage (called automatically from VF page action)
    public void ProcessCPBrokerage() {
        CPBrokerageList = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c, Brokerage_Type__c, 
                          AOP__c, Total_Brokerage__c, Invoice_Status__c
                          FROM CP_Brokerage__c
                          //WHERE Approval_Status__c = 'Approved By L4 - Accounts' AND Id = :BrokerageIds];
                           WHERE Approval_Status__c = 'Approved By L3 - Accounts' AND Id = :BrokerageIds];//Added by Prashant as last status used is L3.//15-12-25..
        System.debug('CPBrokerageList: ' + CPBrokerageList);
        System.debug('CPBrokerageList Size: ' + CPBrokerageList.size());
        System.debug('Selected Picklist Value: ' + selectedPicklistValue);
        
        // Validation for condition type (same logic as BrokerageInvoiceSAP)
        if (!CPBrokerageList.isEmpty() && CPBrokerageList.size() > 0 && EnterCondTypeforSAPDocNo == true) {
            if(CPBrokerageList[0].Brokerage_Type__c == 'Base Brokerage' && CPBrokerageList[0].AOP__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Condition type cannot be given for Base Brokerage type without AOP'));
                return;
            }
        }
       
        // Process if validation passes
        if (!CPBrokerageList.isEmpty() && CPBrokerageList.size() > 0) {
            CPBrokerageIdSet.add(BrokerageIds);
            SAPCPBrokerageCreation.SendReq(CPBrokerageIdSet, EnterCondTypeforSAPDocNo, selectedPicklistValue);
            System.debug('CP Brokerage API Triggered from action method');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                'Document number generation in process, please click on Back to CP Brokerage button and refresh the CP Brokerage page.'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Approval Status is not Approved by L4-Accounts'));
        }
    }
    
    // Method to go back to CP Brokerage record
    public PageReference BackToCPBrokerage() {
        PageReference pageRef = new PageReference('/' + BrokerageIds);
        return pageRef;
    }
}