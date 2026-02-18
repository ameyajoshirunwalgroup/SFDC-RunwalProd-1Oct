public class LockatedApp_LoyaltyMemberCreation {
    
    @future(callout=true)
    public static void createLoyaltyMember(List<Id> accountIds){
        try{
            Map<String, String> accIdVsBkgId = getBookingDetails(accountIds, 'Member');
            System.debug('accIdVsBkgId: ' + accIdVsBkgId);
            if(accIdVsBkgId.size() > 0){
                Map<Id, Booking__c> bkgMap =  new Map<Id, Booking__c>([SELECT Id,Project__c,Opportunity__r.SAP_Customer_Number__c,Project__r.Name,
                                                                       Unit_No__r.RW_Param2__c,Unit_No__r.RW_Param4__c,Unit_No__r.RW_Param3__c,
                                                                       Opportunity__r.Account.Mobile_No__c,Opportunity__r.Account.PersonEmail,
                                                                       Opportunity__r.Account.FirstName,Opportunity__r.Account.LastName,
                                                                       Opportunity__r.AccountId,Opportunity__r.Account.Gender__c FROM Booking__c WHERE Id =: accIdVsBkgId.values()]);
                
                List<Account> accountsToUpdate = new List<Account>();
                for(Id accId : accountIds){
                    Booking__c bkg = bkgMap.get(accIdVsBkgId.get(accId));
                    Map<String, String> data = new Map<String, String>();
                    data.put('is_primary', '');
                    data.put('ownership','');
                    data.put('status', '');
                    data.put('country_code_name', '');
                    data.put('country_code', '');
                    data.put('project_id', bkg.Project__c);
                    data.put('booking_number', bkg.Id);
                    data.put('customer_code',bkg.Opportunity__r.SAP_Customer_Number__c);
                    data.put('project_name', bkg.Project__r.Name);
                    data.put('tower', bkg.Unit_No__r.RW_Param2__c);
                    data.put('floor', bkg.Unit_No__r.RW_Param3__c);
                    data.put('unit', bkg.Unit_No__r.RW_Param4__c);
                    data.put('mobile_number', bkg.Opportunity__r.Account.Mobile_No__c);
                    data.put('email', bkg.Opportunity__r.Account.PersonEmail);
                    data.put('lastname', bkg.Opportunity__r.Account.LastName);
                    data.put('firstname', bkg.Opportunity__r.Account.FirstName);
                    data.put('account_id', bkg.Opportunity__r.AccountId);
                    data.put('birth_date', bkg.Opportunity__r.Account.PersonEmail);
                    data.put('gender', bkg.Opportunity__r.Account.Gender__c);
                    
                    System.debug('data: ' + JSON.Serialize(data));
                    
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    request.setEndpoint('https://runwal-api.lockated.com/add_loyalty_member.json');
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    request.setHeader('Authorization', 'QsUjajggGCYJJGKndHkRidBxJN2cIUC06lr42Vru1EQ');
                    request.setTimeout(120000);
                    request.setBody(JSON.Serialize(data));
                    response = http.send(request);
                    System.debug('request: ' + request);
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                        System.debug('Response: ' + response);
                        System.debug('Response Body: ' + response.getBody());
                        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        Map<String, Object> loyaltyMember = (Map<String, Object>) root.get('loyalty_member');
                        Map<String, Object> member = (Map<String, Object>) loyaltyMember.get('member');
                        Integer userId = (Integer) member.get('user_id');
                        System.debug(userId); 
                        Account acc = new Account();
                        acc.Id = accId;
                        acc.Lockated_Loyalty_Member_Id__c = String.valueOf(userId);
                        accountsToUpdate.add(acc);
                    }else{
                        System.debug('Response: ' + response);
                        System.debug('Response Body: ' + response.getBody());
                    }
                }
                if(accountsToUpdate.size() > 0){
                    update accountsToUpdate;
                }
            }
        }catch(System.CalloutException e){
            System.debug('Error: ' + e.getMessage()); 
        }
        
    }
    
    @future(callout=true)
    public static void creditWallet(List<Id> refPointIds){
        try{
            List<Referral_Points__c> points = [SELECT Id, Account__c,Points__c,Account__r.Lockated_Loyalty_Member_Id__c  FROM Referral_Points__c WHERE Id =: refPointIds];
            Set<Id> accIds = new Set<Id>();
            for(Referral_Points__c point : points){
                accIds.add(point.Account__c);
            }
            Map<String, String> accIdVsCustomerNum = getBookingDetails(new List<Id>(accIds), 'Wallet');
            List<ERP_Integration_Log__c> logList = new List<ERP_Integration_Log__c>();
            for(Referral_Points__c point : points){
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                if(accIdVsCustomerNum.get(point.Account__c) != null && point.Account__r.Lockated_Loyalty_Member_Id__c != null){
                    Map<String, object> data = new Map<String, object>();
                    //data.put('customer_code', accIdVsCustomerNum.get(point.Account__c));
                    data.put('customer_code', point.Account__r.Lockated_Loyalty_Member_Id__c);
                    data.put('amount',point.Points__c);
                    data.put('remarks', '');
                    data.put('transaction_note', '');
                    data.put('payment_mode', '');
                    data.put('topup_by', '');
                    
                    System.debug('data: ' + JSON.Serialize(data));
                    
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    request.setEndpoint('https://runwal-api.lockated.com/loyalty/members/credit_wallet.json');
                    request.setHeader('Content-Type', 'application/json');
                    request.setMethod('POST');
                    request.setHeader('Authorization', 'QsUjajggGCYJJGKndHkRidBxJN2cIUC06lr42Vru1EQ');
                    request.setTimeout(120000);
                    request.setBody(JSON.Serialize(data));
                    response = http.send(request);
                    System.debug('request: ' + request);
                    if(response.getStatusCode() == 200){
                        System.debug('Response: ' + response);
                        System.debug('Response Body: ' + response.getBody());
                    }else{
                        System.debug('Response: ' + response);
                        System.debug('Response Body: ' + response.getBody());
                    }
                }
            }
        }catch(System.CalloutException e){
            System.debug('Error: ' + e.getMessage()); 
        }
        
    }
    
    public static Map<String, String> getBookingDetails(List<Id> accIds, String memberOrWallet){
        Map<String, String> accIdVsBkgId = new Map<String, String>();
        Map<String, String> accIdVsCustomerNum = new Map<String, String>();
        for(Account acc : [SELECT Id,(SELECT Id,AccountId,SAP_Customer_Number__c,Booking__c,Booking__r.Lockated_User_Device_ID__c FROM Opportunities WHERE StageName = 'Unit Booked' ORDER By CreatedDate DESC) FROM Account WHERE Id =: accIds ]){
            for(Opportunity opp : acc.Opportunities){
                if(opp.Booking__r.Lockated_User_Device_ID__c != null){
                    accIdVsBkgId.put(opp.AccountId, opp.Booking__c);
                    accIdVsCustomerNum.put(opp.AccountId, opp.SAP_Customer_Number__c);
                    continue;
                }
            }
            if(accIdVsBkgId.get(acc.Id) == null && acc.Opportunities.size() > 0){
                accIdVsBkgId.put(acc.Id, acc.Opportunities[0].Booking__c);
                accIdVsCustomerNum.put(acc.Id, acc.Opportunities[0].SAP_Customer_Number__c);
            }
        }
        if(memberOrWallet == 'Member'){
            return accIdVsBkgId;
        }else if(memberOrWallet == 'Wallet'){
            return accIdVsCustomerNum;
        }else{
            return null;
        }
    }
    
}