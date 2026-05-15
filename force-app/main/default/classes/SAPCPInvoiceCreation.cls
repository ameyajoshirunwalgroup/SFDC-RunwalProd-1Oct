public class SAPCPInvoiceCreation {
    public static List<ERP_Integration_Log__c> APIlogsToInsertList = new List<ERP_Integration_Log__c>();
    Public static list<Legal_Entity__c> legalentity;
    Public static list<Project__c> ProjectList;
    Public static list<Brokerage_Scheme__c> BrokerageschemeList;
    Public static list<Brokerage_Slab__c> BrokerageSlabList;
    Public static List<Brokerage_Invoice__c> UpdateInvList;
    
    Public SAPCPInvoiceCreation(){
        ProjectList = new list<Project__c>();
        legalentity = new list<Legal_Entity__c>();
        
    }
    public static void SendReq(Set<Id> InvoiceId,Boolean EnterCondTypeforSAPDocNo,String HardcodeCondType){
        system.debug('Inside Invoice SendReq !!!');
        system.debug('EnterCondTypeforSAPDocNo'+EnterCondTypeforSAPDocNo);
        system.debug('HardcodeCondType'+HardcodeCondType);
        List<Brokerage_Invoice__c> InvList = new List<Brokerage_Invoice__c>();        
        
        List<Tower__c> tlist = new List<Tower__c>();
        UpdateInvList = new List<Brokerage_Invoice__c>();
        
        String body = '';
        
        InvList = [SELECT Id,Name,Invoice_Number__c,If_GST_is_applicable__c,Brokerage__c,Total_Agreement_Value__c,Approval_Status__c,Invoice_Status__c,Booking__c,
                   Opportunity__c,Brokerage_Lookup__c,Place_of_Supply__c,Eligible_Slab__c,Customer_Name__c,Tower_Unit__c,Project__c,Brokerage_Scheme_Name__c,SAP_Document_No__c,
                   Invoice_Date__c,SO_Number__c,Customer_Code__c,SAP_Broker_code__c,IGST__c,CGST__c,SGST__c,Invoice_Amount__c,SAP_Document_Date__c,SAP_Posting_Date__c,SAP_Clearing_Date__c,SAP_TDS__c,Brokerage_Lookup__r.AOP_CP__c,Brokerage_Lookup__r.name,
                   Brokerage_In_Rs__c,Channel_Partner__c,Booking__r.Tower__c,Brokerage_Lookup__r.Brokerage_Type__c,Booking__r.Passback_Amount__c,Brokerage_Summary__r.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c,Brokerage_Summary__r.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c,Brokerage_Summary__r.Brokerage_Scheme__r.AOP_CP__c,Type_of_Client__c,Brokerage_Summary__r.Brokerage_Scheme__r.Base_Brokerage_Without_AOP__c,
                   Legal_Entity__c
                   from Brokerage_Invoice__c where Id IN: InvoiceId];
        system.debug('InvList ::>> '+ InvList);
        
        if(!InvList.isEmpty() && InvList.size() > 0){
            for(Brokerage_Invoice__c inv: InvList){
                system.debug('Inside For !!!');
                Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
                ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                try{
                    if(inv.Brokerage_Lookup__r.Brokerage_Type__c != 'Kicker Incentive'){
                        tlist = [Select id,name,Legal_Entity__c from Tower__c where Id =:inv.Booking__r.Tower__c];
                        system.debug('tlist::'+tlist);
                        if(!tlist.isEmpty()){
                            legalentity = [Select Id,name,RDS_Company_Code__c,RDS_Company_Name__c,RDS_Address1__c,RDS_Address2__c,RDS_PAN_No__c,GSTIN__c,RERA_Number__c from Legal_Entity__c where Id=:tlist[0].Legal_Entity__c];
                            system.debug('legalentity::'+legalentity);
                        }else if(inv.Legal_Entity__c != null){ // Added by coServe 25-06-2024
                            legalentity = [Select Id,name,RDS_Company_Code__c,RDS_Company_Name__c,RDS_Address1__c,RDS_Address2__c,RDS_PAN_No__c,GSTIN__c,RERA_Number__c from Legal_Entity__c where Id=:inv.Legal_Entity__c];
                        }
                    }else{
                        ProjectList = [Select Id,Name,RDS_Company_Code__c from Project__c where Name=:inv.Project__c];
                        system.debug('ProjectList::'+ProjectList);
                        if(!ProjectList.isEmpty()){
                            legalentity = [Select Id,name,RDS_Company_Code__c,RDS_Company_Name__c,RDS_Address1__c,RDS_Address2__c,RDS_PAN_No__c,GSTIN__c,RERA_Number__c from Legal_Entity__c where Id=:ProjectList[0].RDS_Company_Code__c];
                            system.debug('legalentity::'+legalentity);
                        }
                    }
                    SAPCPInvoiceCreationParser jsonResponse = new SAPCPInvoiceCreationParser();
                    Http http = new Http();
                    Http http1 = new Http();
                    
                    
                    String username = Label.SAP_Username;
                    String password = Label.SAP_Password;
                    String endPointURL = Label.SAP_CP_Invoice_Endpoint;
                    Blob headerValue = Blob.valueOf(username + ':' + password);
                    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                    String EligibleSlab = '';
                    if(inv.Eligible_Slab__c != null){
                        EligibleSlab = getslabcondition(inv.Eligible_Slab__c,InvList);
                    }else{
                        EligibleSlab = '';
                    }
                    
                    Datetime d = inv.Invoice_Date__c;
                    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYYMMdd');
                    DateTime d1 = inv.Invoice_Date__c; 
                    String dateStr =  d1.format('dd.MM.yy') ;
                    system.debug('Date' +dt);
                    system.debug('Date1 :' +dateStr);
                   
                    String sapdocno = '';
                    String sapdocdate = '';
                    String sappostingdate = '';
                    String sapclearingdate = '';
                    Decimal saptds = 0;
                    String errortext = '';
                    /* Calling get method for Authentication */
                    
                    String salesOrderNo = '';
                    
                    /* Create JSON Body for Post method */
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    //gen.writeStringField('MANDT','210'); //SB
                    gen.writeStringField('MANDT','300'); //PD
                    if(!legalentity.isEmpty()){
                        if(String.isNotBlank(legalentity[0].RDS_Company_Code__c)){
                            gen.writeStringField('BUKRS',legalentity[0].RDS_Company_Code__c);
                        }else{
                            gen.writeStringField('BUKRS','');
                        }
                    }
                    
                    
                    if(String.isNotBlank(inv.SO_Number__c)){
                        gen.writeStringField('SO_NUMBER',inv.SO_Number__c);
                    }else{
                        gen.writeStringField('SO_NUMBER','');
                    }
                    
                    if(String.isNotBlank(inv.SAP_Broker_code__c)){
                        gen.writeStringField('BROK_CODE',inv.SAP_Broker_code__c);
                    }else{
                        gen.writeStringField('BROK_CODE','');
                    }
                    
                    if(String.isNotBlank(inv.Customer_Code__c)){
                        gen.writeStringField('CUST_CODE',inv.Customer_Code__c);
                    }else{
                        gen.writeStringField('CUST_CODE','');
                    }
                    gen.writeStringField('PAY_MODE','DM');
                    
                    if(EnterCondTypeforSAPDocNo == true){
                        gen.writeStringField('BROK_COND2',HardcodeCondType);
                    }
                    else if(EnterCondTypeforSAPDocNo == false) {
                        if(String.isNotBlank(EligibleSlab) && InvList[0].Eligible_Slab__c != 'Slab 1' ){
                            gen.writeStringField('BROK_COND2',EligibleSlab);//EligibleSlab
                        }
                        
                        else if(InvList[0].Eligible_Slab__c == 'Slab 1' && InvList[0].Brokerage_Lookup__r.AOP_CP__c == true){
                            
                            gen.writeStringField('BROK_COND2','Z1BR');
                        }
                        
                        else if(InvList[0].Eligible_Slab__c == 'Slab 1'){
                            gen.writeStringField('BROK_COND2','');
                        }
                        else if(InvList[0].Brokerage_Lookup__r.name != '' && InvList[0].Brokerage_Lookup__r.name == 'Kicker Incentive'){
                            gen.writeStringField('BROK_COND2','ZGXB');
                            
                        }
                    }
                     if(String.isNotBlank(EligibleSlab) || (InvList[0].Brokerage_Lookup__r.name != '' && InvList[0].Brokerage_Lookup__r.name == 'Kicker Incentive') ){
                        gen.writeStringField('BROK_COND','ZBRK');
                    }else{
                        gen.writeStringField('BROK_COND','');
                    }
                
                    
                   
                   
                    
                    if(inv.If_GST_is_applicable__c == 'Yes'){
                        gen.writeStringField('IS_GST','Y');
                    }else if(inv.If_GST_is_applicable__c == 'No'){
                        gen.writeStringField('IS_GST','N');
                    }else{
                        gen.writeStringField('IS_GST','');
                    }
                    if(String.isNotBlank(inv.IGST__c)){
                        gen.writeStringField('IGST',inv.IGST__c);
                    }else{
                        gen.writeStringField('IGST','');
                    }
                    if(String.isNotBlank(inv.CGST__c)){
                        gen.writeStringField('CGST',inv.CGST__c);
                    }else{
                        gen.writeStringField('CGST','');
                    }
                    if(String.isNotBlank(inv.SGST__c)){
                        gen.writeStringField('SGST',inv.SGST__c);
                    }else{
                        gen.writeStringField('SGST','');
                    }
                    /*if(String.isNotBlank(String.valueOf(inv.Brokerage__c))){
gen.writeStringField('BROK_PERC',String.valueOf(inv.Brokerage__c));
}else{
gen.writeStringField('BROK_PERC','');
}*/
                    if((InvList[0].Brokerage_Lookup__r.AOP_CP__c == true) &&(String.isNotBlank(String.valueOf(inv.Brokerage_Summary__r.Brokerage_Scheme__r.Base_Brokerage_Without_AOP__c)))){
                        gen.writeStringField('BROK_PERC',String.valueOf(inv.Brokerage_Summary__r.Brokerage_Scheme__r.Base_Brokerage_Without_AOP__c));
                    }
                  else if((String.isNotBlank(String.valueOf(inv.Booking__r.Passback_Amount__c)) && inv.Booking__r.Passback_Amount__c > 0 && inv.Brokerage_Lookup__r.name == 'Base Brokerage')){
                        gen.writeStringField('BROK_PERC',String.valueOf(inv.Brokerage_In_Rs__c));
                        }
                    else if(inv.Brokerage_Lookup__r.name == 'Base Brokerage' && (inv.Booking__r.Passback_Amount__c == NULL || inv.Booking__r.Passback_Amount__c == 0)){
                           gen.writeStringField('BROK_PERC',String.valueOf(inv.Brokerage__c));
                    }
                  else{
                    gen.writeStringField('BROK_PERC','0');
                    }  
                   
                    if((InvList[0].Brokerage_Lookup__r.AOP_CP__c == true) &&(String.isNotBlank(String.valueOf(inv.Brokerage_Summary__r.Brokerage_Scheme__r.AOP_CP__c)))){
                        gen.writeStringField('BROK_PERC2',String.valueOf(inv.Brokerage_Summary__r.Brokerage_Scheme__r.AOP_CP__c));
                    }
                    else if(inv.Brokerage_Lookup__r.name != 'Base Brokerage' && inv.Brokerage_Lookup__r.name != 'Kicker Incentive' ){
                        system.debug('inside 1');
                             gen.writeStringField('BROK_PERC2',String.valueOf(inv.Brokerage__c));
                    }
                     else if(InvList[0].Brokerage_Lookup__r.name != '' && InvList[0].Brokerage_Lookup__r.name == 'Kicker Incentive'){
                           system.debug('inside 2');

                         gen.writeStringField('BROK_PERC2',String.valueOf(inv.Brokerage_In_Rs__c));

                    }
                    else{
                        gen.writeStringField('BROK_PERC2','0');
                           system.debug('inside 3');

                    }
                 
                    
                    if(String.isNotBlank(String.valueOf(inv.Total_Agreement_Value__c))){
                        gen.writeStringField('TOT_AV',String.valueOf(inv.Total_Agreement_Value__c));
                    }else{
                        gen.writeStringField('TOT_AV','');
                    }
                    if(String.isNotBlank(inv.Invoice_Number__c)){
                        gen.writeStringField('INV_NO',inv.Invoice_Number__c);
                    }else{
                        gen.writeStringField('INV_NO','');
                    }
                    if(String.isNotBlank(String.valueOf(inv.Invoice_Amount__c))){
                        gen.writeStringField('INV_AMT',String.valueOf(inv.Invoice_Amount__c));
                    }else{
                        gen.writeStringField('INV_AMT','');
                    }
                    if(String.isNotBlank(dt)){
                        gen.writeStringField('INV_DATE',dt);
                    }else{
                        gen.writeStringField('INV_DATE','');
                    }
                    //   gen.writeStringField('REMARK',inv.Tower_Unit__c+'-'+inv.Customer_Name__c+'-'+inv.Invoice_Number__c+'-'+inv.Brokerage__c);
                    if(inv.Brokerage_Lookup__r.name == 'Base Brokerage' ||inv.Brokerage_Lookup__r.name == '1% Brokerage' ){
                        gen.writeStringField('REMARK',inv.Tower_Unit__c+''+' '+'B'+'-'+inv.Brokerage__c+'%'+''+' '+inv.Invoice_Number__c+''+' '+inv.Customer_Name__c );
                    }
                    else{
                        gen.writeStringField('REMARK',inv.Tower_Unit__c+''+' '+'L'+'-'+inv.Brokerage__c+'%'+''+' '+inv.Invoice_Number__c+''+' '+inv.Customer_Name__c );
                        
                    }
                    
                    
                    gen.writeEndObject();
                    
                    // Get the JSON string.
                    body += gen.getAsString();
                    system.debug('body:: ' + body);
                    /* Calling Post method to push data */
                    
                    
                    
                    Httprequest request = new HttpRequest();                      
                    request.setMethod('POST');
                    request.setEndpoint(endPointURL); 
                    request.setTimeout(120000);   /// 120 seconds //// 2 mins     
                    request.setHeader('authorization', authorizationHeader);
                    request.setHeader('content-type', 'text/plain'); /// application/json
                    request.setBody(body);
                    if(!Test.isRunningTest()){
                        //Making call to external REST API
                        HttpResponse response = http1.send(request); 
                        system.debug('Response:: ' + response.getBody());
                        jsonResponse = SAPCPInvoiceCreationParser.parse(response.getBody());
                        system.debug('jsonResponse :: ' + jsonResponse );
                        sapdocno = String.valueOf(jsonResponse.SAP_DOC_NO);
                        sapdocdate = String.valueOf(jsonResponse.SAP_DOC_DT);
                        sappostingdate = String.valueOf(jsonResponse.SAP_POST_DT);
                        sapclearingdate = String.valueOf(jsonResponse.SAP_CLR_DT);
                        saptds = Decimal.valueOf(jsonResponse.SAP_TDS);
                        errortext = String.valueOf(jsonResponse.ERROR_TEXT);
                    }else{
                        //dummy();
                    }
                    
                    bi.SAP_Document_No__c = sapdocno;
                    if(sapdocdate != '0000-00-00'){
                        bi.SAP_Document_Date__c = Date.valueOf(sapdocdate);
                    }
                    if(sappostingdate != '0000-00-00'){
                        bi.SAP_Posting_Date__c = Date.valueOf(sappostingdate);
                    }
                    if(sapclearingdate != '0000-00-00'){
                        bi.SAP_Clearing_Date__c = Date.valueOf(sapclearingdate);
                    }
                    //bi.SAP_Clearing_Date__c = Date.valueOf(sapclearingdate);
                    bi.SAP_TDS__c = saptds;
                    bi.Id = inv.Id;
                    UpdateInvList.add(bi);
                    api.API_Name__c = 'CP Invoice Creation API';
                    api.Request__c = body;
                    api.Response__c = String.valueOf(jsonResponse);
                    api.Status__c = 'Success';
                    api.CP_Invoice__c = bi.Id;
                }catch(Exception e){
                    system.debug('api request in catch:: ' + e);
                    system.debug('Error at Line No:: ' + e.getLineNumber());
                    api.API_Name__c = 'CP Invoice Creation API';
                    api.Request__c = body;
                    api.Response__c = e.getMessage() + ' Error at Line No:: ' + e.getLineNumber();
                    api.Status__c = 'Failure';
                    api.CP_Invoice__c = inv.Id;
                }
                try{
                    if(UpdateInvList.size()>0){
                        update UpdateInvList;
                        system.debug('Success !!!!');
                    }
                }catch(Exception e){
                    system.debug('Error at Line No:: ' + e.getLineNumber());
                    api.API_Name__c = 'CP Invoice Creation API';
                    api.Request__c = body;
                    api.Response__c = e.getMessage() + ' Error at Line No:: ' + e.getLineNumber();
                    api.Status__c = 'Failure';
                    api.CP_Invoice__c = inv.Id;
                }
                
                //Inserting API Log
                if(api != null){
                    APIlogsToInsertList.add(api);
                }
                system.debug('APIlogsToInsertList::'+APIlogsToInsertList);
                if(!APIlogsToInsertList.isEmpty()){
                    insert APIlogsToInsertList;
                    system.debug('Success !!');
                }
            }
        }
    }
    
    Public static String getslabcondition(String Slabname,List<Brokerage_Invoice__c> InvList){
        String condtype;
        
        if(Slabname == 'Slab 1'){
            condtype = 'ZBRK';
            //condtype1 = 'Z1BR';
            
        }
        /*else if(Slabname == 'Slab 1' && InvList[0].Brokerage_Lookup__r.AOP_CP__c == false ){
condtype = 'Z1BR';

}*/
        else if(Slabname == 'Slab 2'){
            condtype = 'ZEXB';
        }else if(Slabname == 'Slab 3'){
            condtype = 'ZFXB';
        }
        else if(Slabname == 'Slab 4'){
            condtype = 'ZFXB';
        }else if(Slabname == 'Slab 5'){
            condtype = 'ZFXB';
        }else if(Slabname == 'Slab 6'){
            condtype = 'ZFXB';
        }
        return condtype;
        
    }
    
    
}