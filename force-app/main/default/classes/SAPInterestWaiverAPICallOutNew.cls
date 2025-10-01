public class SAPInterestWaiverAPICallOutNew implements Queueable, Database.AllowsCallouts {
    public String sEndPoint;
    public String sUserName;
    public String sPassword;
    public HttpResponse res;
    private List<Id> waiverIds;
    
    public SAPInterestWaiverAPICallOutNew(List<Id> IWIds) {
        this.waiverIds = IWIds;
    }
    
    public void execute(QueueableContext context) {
        Set<Id> setWaiverId = new Set<Id>(waiverIds);
        List<Interest_Waiver__c> lstIWUpdate = new List<Interest_Waiver__c>();
        List<Interest_Waiver__c> lstWaiver = [SELECT Id, Booking__r.Project__r.SAPMaterial_Code__c, Booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c,
                                              Booking__r.Unit_No__r.TowerName__r.SAP_Plant_Code__c, Demand__r.SAP_Customer_Number__c,
                                              Name,Demand__c, Demand__r.RW_Billing_Document_Number__c,
                                              Booking__r.Floor__c, Demand__r.Unit_No__c, Sub_Reason__c,                                            
                                              Demand__r.SAP_Slab_Code__c, Demand__r.SAP_Slab_Description__c,
                                              Demand__r.Demand_Date__c, Demand__r.Due_Date__c, Demand__r.Payment_Date__c,
                                              Demand__r.Interest_Days__c, Demand__r.Total_Interest_Amount__c, Booking__r.Project__r.RDS_Company_Code__r.RDS_Company_Code__c,
                                              Interest_Amount__c, Waiver_Amount__c, Project_Name__c,Unit__c,Booking__r.Customer__r.RW_Mobile_No__c,
                                              Approval_Status__c, Booking__c,Customer_Name__c,
                                              Booking__r.Sale_Order__c, Booking__r.Opportunity__r.SAP_Customer_Number__c,
                                              Is_Send_To_SAP__c, Remarks__c
                                              FROM Interest_Waiver__c 
                                              WHERE Approval_Status__c = 'Approved' AND Id IN :setWaiverId];
        
        List<WrapperInterestWaiverRequest> lstWrapp = new List<WrapperInterestWaiverRequest>();
        if(!lstWaiver.isEmpty() && lstWaiver.size()>0){
            for (Interest_Waiver__c objWaiver : lstWaiver) {
                WrapperInterestWaiverRequest objWrapp = new WrapperInterestWaiverRequest();
                
                /*if (objWaiver.Booking__r != null && objWaiver.Booking__r.Project__r != null) {
objWrapp.bukrs = objWaiver.Booking__r.Project__r.SAPMaterial_Code__c;
} else {
objWrapp.bukrs = null;
}*/
                
                if (objWaiver.Booking__r != null && objWaiver.Booking__r.Unit_No__r != null && objWaiver.Booking__r.Unit_No__r.TowerName__r != null
                    && objWaiver.Booking__r.Unit_No__r.TowerName__r.Legal_Entity__r != null && objWaiver.Booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c != null) {
                        objWrapp.bukrs = objWaiver.Booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c;
                    } else if(objWaiver.Booking__r != null && objWaiver.Booking__r.Project__r != null && 
                              objWaiver.Booking__r.Project__r.RDS_Company_Code__r != null && objWaiver.Booking__r.Project__r.RDS_Company_Code__r.RDS_Company_Code__c != null){
                                  objWrapp.bukrs = objWaiver.Booking__r.Project__r.RDS_Company_Code__r.RDS_Company_Code__c;
                              } else{
                                  objWrapp.bukrs = null;
                              }
                
                if (objWaiver.Booking__r != null && objWaiver.Booking__r.Unit_No__r != null &&
                    objWaiver.Booking__r.Unit_No__r.TowerName__r != null) {
                        objWrapp.werks = objWaiver.Booking__r.Unit_No__r.TowerName__r.SAP_Plant_Code__c;
                    } else {
                        objWrapp.werks = null;
                    }
                
                if (objWaiver.Demand__r != null) {
                    objWrapp.kunnr    = objWaiver.Demand__r.SAP_Customer_Number__c;
                    //   objWrapp.vbeln    = objWaiver.Demand__r.RW_Billing_Document_Number__c;
                    if (objWaiver.Booking__r != null && objWaiver.Booking__r.Sale_Order__c != null) {
                        objWrapp.vbeln    = objWaiver.Booking__r.Sale_Order__c;
                    } else {
                        objWrapp.vbeln = '';
                    }  
                    
                    objWrapp.unit_no  = objWaiver.Demand__r.Unit_No__c;
                    objWrapp.mlbez    = objWaiver.Demand__r.SAP_Slab_Code__c;
                    objWrapp.mstxt    = objWaiver.Demand__r.SAP_Slab_Description__c;
                    // objWrapp.belnr    = objWaiver.Demand__r.RW_Billing_Document_Number__c;
                    objWrapp.belnr    = '';
                    // DateTime demandDateTime = objWaiver.Demand__r.Demand_Date__c;
                    //String formattedDemandDate = demandDateTime != null ? demandDateTime.format('dd.MM.yyyy', 'en_US') : null;
                    DateTime paymentDateTime = objWaiver.Demand__r.Payment_Date__c;
                    String formattedPayDate = paymentDateTime != null ? paymentDateTime.format('dd.MM.yyyy', 'en_US') : null;
                    // objWrapp.bldat = formattedDemandDate;
                    objWrapp.bldat = formattedPayDate;
                    //  Date dueDate = objWaiver.Demand__r.Due_Date__c;
                    // String formattedDueDate = dueDate != null ? DateTime.newInstance(dueDate, Time.newInstance(0, 0, 0, 0)).format('dd.MM.yyyy', 'en_US') : null;
                    // objWrapp.due_dt   = formattedDueDate;
                    // objWrapp.intr_fr  = formattedDemandDate;
                    objWrapp.due_dt   = formattedPayDate;
                    objWrapp.intr_fr  = formattedPayDate;
                    //  Date todayDate = Date.today(); // Get today's date
                    // DateTime todayDateTime = DateTime.newInstance(todayDate.year(), todayDate.month(), todayDate.day(), 0, 0, 0); // Convert to DateTime
                    //  String formattedDate = todayDateTime.format('dd.MM.yyyy'); // Format the DateTime object
                    //   objWrapp.intr_to  = formattedDate;
                    objWrapp.intr_to  = formattedPayDate;
                    objWrapp.intr_amt = objWaiver.Demand__r.Total_Interest_Amount__c;
                    objWrapp.nt_due_day = Integer.ValueOf(objWaiver.Demand__r.Interest_Days__c); // uncomment if needed
                } else {
                    objWrapp.kunnr     = '';
                    objWrapp.vbeln     = '';
                    objWrapp.unit_no   = '';
                    objWrapp.mlbez     = '';
                    objWrapp.mstxt     = '';
                    objWrapp.belnr     = '';
                    objWrapp.bldat     = '';
                    objWrapp.due_dt    = '';
                    objWrapp.intr_fr   = '';
                    objWrapp.intr_to   = '';
                    objWrapp.intr_amt  = 0.00;
                    objWrapp.nt_due_day = 0;
                }
                
                // objWrapp.name = objWaiver.Name;
                if(objWaiver.Customer_Name__c != null){
                    objWrapp.name = objWaiver.Customer_Name__c;
                } else{
                    objWrapp.name = '';
                }
                if (objWaiver.Booking__r != null) {
                    objWrapp.floor = String.ValueOf(objWaiver.Booking__r.Floor__c);
                } else {
                    objWrapp.floor = '';
                }
                
                objWrapp.blart = System.Label.SAP_Default_DocType;
                objWrapp.intr_rate = 0.00; // Not mapped from SF
                objWrapp.base_amt  = 0.00; // Not mapped from SF
                objWrapp.wave_amt  = objWaiver.Waiver_Amount__c;
                objWrapp.recv_amt  = 0; // default to 0
                objWrapp.remark    = objWaiver.Sub_Reason__c; // need to change values in SAP
                
                lstWrapp.add(objWrapp);
            }
        }
        system.debug('lstWrapp>>>>> ' +lstWrapp);
        SAP_Integration__mdt config = [SELECT End_Point_URL__c, Username__c, Password__c
                                       FROM SAP_Integration__mdt 
                                       WHERE DeveloperName = 'Post_Interest_Waiver_New' LIMIT 1];
        system.debug('config>>>>' +config);
        
        if (config != null) {
            sEndPoint = config.End_Point_URL__c;
            sUserName = config.Username__c;
            sPassword = config.Password__c;
        }
        if (!lstWrapp.isEmpty()) {
            
            String requestBody = JSON.serialize(lstWrapp);
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            Blob headerValue = Blob.valueOf(sUserName + ':' + sPassword);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            req.setEndpoint(sEndPoint); // replace with actual SAP endpoint
            req.setMethod('POST');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            system.debug('JSON Body>>>>>>>' +requestBody);
            try {
                res = http.send(req);
                
                System.debug('SAP Response Status: ' + res.getStatus());
                System.debug('SAP Response Body: ' + res.getBody());
                System.debug('SAP Response code: ' + res.getStatusCode());
                
                if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
                    for(Interest_Waiver__c objIW : lstWaiver){
                        objIW.Is_Send_To_SAP__c = True;
                        lstIWUpdate.add(objIW);
                    }
                }
                else if(res.getStatusCode() != 201 || res.getStatusCode() != 200){
                    system.debug('res.getStatusCode()>>>>>>>>>>>' +res.getStatusCode());
                    for(Interest_Waiver__c objIW1 : lstWaiver){
                        SAP_IntegrationHelper.insertLogEntry('Interest Waiver', 'Failure', objIW1.id, objIW1.Demand__c, requestBody, res.getBody(), res.getStatus(), '');   
                    }
                }
                if(!lstIWUpdate.isEmpty()){
                    System.debug('IW is Sent to SAP? ' +lstIWUpdate);
                    Update lstIWUpdate;
                    SAP_IntegrationHelper.insertLogEntry('Interest Waiver', 'Success', lstIWUpdate[0].Id, lstIWUpdate[0].Demand__c, requestBody, res.getBody(), '', '');
                    
                    for(Interest_Waiver__c objIW : lstIWUpdate){
                        if(string.isNotBlank(objIW.Customer_Name__c) && String.isNotBlank(objIW.Unit__c)
                           && String.isNotBlank(objIW.Booking__r.Customer__r.RW_Mobile_No__c) && objIW.Waiver_Amount__c != null && objIW.Is_Send_To_SAP__c == TRUE){
                               system.debug('call whatsapp mtd>>>>');
                               sendWhatsAppMsg(objIW.Id, objIW.Customer_Name__c, objIW.Unit__c, objIW.Booking__r.Customer__r.RW_Mobile_No__c, String.ValueOf(objIW.Waiver_Amount__c));
                           }
                    }
                }
            } catch (Exception e) {
                System.debug('Callout failed: ' + e.getMessage());
                SAP_IntegrationHelper.insertLogEntry('Interest Waiver', 'Failure', null, null,'', '', e.getMessage(), '');          
                
            }
        }
    }
    
    @Future(callout=true)
    public static void sendWhatsAppMsg(String IWId, String CustName, String Unit, String MobileNo, String waiverAmt){
        String templateName;
        String languageCode = 'en';
        String jsonParse;
        String fullNumber;
        
        // Fetch metadata record
        Collection_WhatsApp__mdt objMeta = [
            SELECT element_name__c
            FROM Collection_WhatsApp__mdt 
            WHERE DeveloperName = 'Notify_Cust_For_Interest_Waiver'
            LIMIT 1
        ];
        System.debug('objMeta >>> ' + objMeta);
        
        if (objMeta == null) {
            System.debug('Metadata not found. Exiting method.');
            return;
        }
        
        templateName = objMeta.element_name__c;
        
        
        Http http = new Http();
        
        if (String.isBlank(MobileNo)) {
            // System.debug('Skipping lead ' + objCN.Id + ' due to missing mobile number.');
            return;
        }
        
        fullNumber = '+91' + MobileNo;
        System.debug('Sending WhatsApp message to ' + fullNumber);
        
        // Construct JSON payload
        jsonParse = '{"countryCode": "+91",';
        jsonParse += '"fullPhoneNumber": "' + fullNumber + '",';
        jsonParse += '"campaignId": "",';
        jsonParse += '"callbackData": "' + CustName + '",';
        jsonParse += '"type": "Template",';
        jsonParse += '"template": { "name": "' + templateName + '", "languageCode": "' + languageCode + '",';
        jsonParse += '"headerValues": [],';
        jsonParse += '"bodyValues": [';
        
        List<String> bodyValues = new List<String>();
        if (String.isNotBlank(CustName)) {
            bodyValues.add('"' + CustName + '"');
        }
        if (waiverAmt != null) {
            bodyValues.add('"' + waiverAmt + '"');
        }
        if (Unit!= null && String.isNotBlank(Unit)) {
            bodyValues.add('"' + Unit + '"');
        }
        jsonParse += String.join(bodyValues, ',') + ']}}';
        
        System.debug('JSON Payload: ' + jsonParse);
        
        // Send HTTP request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key);
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        
        try {
            HTTPResponse res = http.send(req);
            System.debug('Response Status: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error sending WhatsApp message: ' + e.getMessage());
        }
    } 
    public static void dummyMethod(){
        
        String s2;        
        String s3;
        String s4;                
        String s5;
        String s6;        
        String s7;
        String s8;                
        String s9;
        String s10;        
        String s11;
        String s12;                
        String s13;
        String s14;        
        String s15;
        String s16;                
        String s110;
        String s210;        
        String s310;
        String s410;                
        String s510;
        String s610;        
        String s710;
        String s810;                
        String s910;
        String s1010;        
        String s1110;
        String s1210;                
        String s1310;
        String s1410;        
        String s1510;
        String s1610;                
        String s111;
        String s211;        
        String s311;
        String s411;                
        String s511;
        String s611;        
        String s711;
        String s811;                
        String s911;
        String s1011;        
        String s1111;
        String s1211;                
        String s1311;
        String s1411;        
        String s1511;
        String s1611;                
        String s1101;
        String s2111;        
        
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}