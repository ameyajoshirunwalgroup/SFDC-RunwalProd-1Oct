/**
* @File Name : CPBrokerageInvoiceController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 17, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 17, 2025 |   | Initial Version
**/

public without sharing class CPBrokerageInvoiceController {

    @AuraEnabled(cacheable=true)
    public static List<CP_Brokerage__c> getCpBrokerages(
        String searchKey,
        String sortBy,
        String sortDirection,
        String searchKeystatus
    ) {
        Id loggeduserId = UserInfo.getUserId();
    
        System.debug('User id'+loggeduserId);
        // Get current user → Contact → Account (Channel Partner Account)
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('User'+user[0].ContactId);
        if(!user.isEmpty() && user[0].ContactId != null){
        List<Contact> contact = [SELECT Id, AccountId FROM Contact WHERE Id =: user[0].ContactId];
        List<Account> accList = [SELECT Id,Channel_Partner__c FROM Account WHERE Id =: contact[0].AccountId];
        if (accList.isEmpty()) return new List<CP_Brokerage__c>();
        Id cpAccountId = accList[0].Channel_Partner__c;
          System.debug('cpAccountId----'+cpAccountId);
        }
          String a = 'Approved By L1';
          String b = 'Approved By L2';
    
        String query =
            'SELECT Id, Name, Invoice_Number__c, Invoice_Date__c, If_GST_is_applicable__c,Total_Brokerage__c,' +
            ' Approval_Status__c, Approval_Status_clearing__c, Brokerage_Type__c,' +
            ' Channel_Partner__c,Legal_Entity__c,Legal_Entity__r.Name, CreatedDate, LastModifiedDate' +
            ' FROM CP_Brokerage__c' + ' WHERE  (Approval_Status_clearing__c = :a OR Approval_Status_clearing__c = :b)'+' AND Channel_Partner__c = :cpAccountId';
          System.debug('Cp Brokerag record'+query);//Channel_Partner__c = :cpAccountId' +
          // ' AND
        if (!String.isBlank(searchKey)) {
            String key = '%' + searchKey + '%';
            query += ' AND Invoice_Number__c LIKE :key';
        }
        if (!String.isBlank(searchKeystatus)) {
            String key2 = '%' + searchKeystatus + '%';
            query += ' AND Approval_Status__c LIKE :key2';
        }
        if (!String.isBlank(sortBy) && !String.isBlank(sortDirection)) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
      List<CP_Brokerage__c> results = Database.query(query);
    System.debug('📌 Query Result Size: ' + results.size());
    System.debug('📌 Query Records: ' + results);
    return results;
    
    }

    @AuraEnabled
    public static Boolean CheckForGSTNo(String InvId) {
        system.debug('InvId::'+InvId);
        Boolean isExist = false;
        
        // First try to query as Brokerage_Invoice__c
        list<Brokerage_Invoice__c> IList = [Select Id, Name, Channel_Partner__c 
                                           from Brokerage_Invoice__c 
                                           where Id = :InvId LIMIT 1];
        
        if(!IList.isEmpty()){
            // This is a Brokerage_Invoice__c record
            list<Broker__c> CPList = [Select Id, Name, RW_GST_Number__c 
                                     from Broker__c 
                                     where Id = :IList[0].Channel_Partner__c LIMIT 1];
            if(!CPList.isEmpty() && CPList[0].RW_GST_Number__c != null){
                isExist = true;
            }
        } else {
            // If not found as Brokerage_Invoice__c, try as CP_Brokerage__c
            list<CP_Brokerage__c> cpBrokerageList = [Select Id, Name, Channel_Partner__c 
                                                    from CP_Brokerage__c 
                                                    where Id = :InvId LIMIT 1];
            
            if(!cpBrokerageList.isEmpty()){
                // This is a CP_Brokerage__c record
                list<Broker__c> CPList = [Select Id, Name, RW_GST_Number__c 
                                         from Broker__c 
                                         where Id = :cpBrokerageList[0].Channel_Partner__c LIMIT 1];
                if(!CPList.isEmpty() && CPList[0].RW_GST_Number__c != null){
                    isExist = true;
                }
            }
        }
        
        return isExist;
    }
}