public with sharing class SAPChannelPartnerAPICallOut {
    
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    
    @future (callout=true)
    // @InvocableMethod
    //public static void sendBrokerlist(List<Id> brokerids) {
    public static void sendBrokerlist(Id brokerids) {
        List<Broker__c> lstBroker = [SELECT Name,SAP_CP_Code__c,Aadhar_Card__c,TITLE__c,NAME_FIRST__c,NAME_LAST__c,NAME_MIDDLE__c,Representative_Name__c,
                                     STREET__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,City__c,Pin_Code__c,State__c,
                                     Country__c,RW_Broker_Number__c,RW_Mobile_No__c,RW_Email__c,
                                     RW_NATURE_WORK__c,Legal_Form__c,Is_NRI_CP__c,Broker_Pan_No__c,RW_GST_Number__c,
                                     RW_RERA_Registration_Number__c,Payment_Terms__c,Individual_CP__c,RW_CreateFromIRIS__c FROM Broker__c 
                                     WHERE ID =:brokerids  LIMIT 1];
        
        system.debug('____lstBroker'+lstBroker[0]);
        SAPChannelPartnerAPI.ZSD_SFDC_VENDOR brokerData = New SAPChannelPartnerAPI.ZSD_SFDC_VENDOR();
        SAPChannelPartnerAPI.TABLE_OF_BAPIRET2 RETURN_x= new  SAPChannelPartnerAPI.TABLE_OF_BAPIRET2();
        SAPChannelPartnerAPI.ZSD_SFDC_VENDOR_HD VENDOR_HEADER = new SAPChannelPartnerAPI.ZSD_SFDC_VENDOR_HD();
        VENDOR_HEADER.LIFNR = lstBroker[0].SAP_CP_Code__c;
        VENDOR_HEADER.KTOKK = 'Z006'; 
       // VENDOR_HEADER.TITLE = String.valueOf(lstBroker[0].TITLE__c);
         String partnershipName = lstBroker[0].NAME_FIRST__c +' '+lstBroker[0].NAME_LAST__c;
          
        If(lstBroker[0].Individual_CP__c){
             if(partnershipName != lstBroker[0].Name){
                VENDOR_HEADER.NAME_ORG1 = lstBroker[0].Name;
                //VENDOR_HEADER.NAME_LAST = lstBroker[0].NAME_LAST__c;
                VENDOR_HEADER.PARTN_CAT = '2'; // Added by Vinay 05-05-2022
                
            }else{
                VENDOR_HEADER.NAME_FIRST = lstBroker[0].NAME_FIRST__c;
                VENDOR_HEADER.NAME_LAST = lstBroker[0].NAME_LAST__c;
                VENDOR_HEADER.NAME_MIDDLE = lstBroker[0].NAME_MIDDLE__c;   
                VENDOR_HEADER.TITLE = String.valueOf(lstBroker[0].TITLE__c);
                VENDOR_HEADER.PARTN_CAT = '1'; // Added by Vinay 05-05-2022
            }
            //VENDOR_HEADER.PARTN_CAT = '1'; // Commented by Vinay 05-05-2022
           
        }else{
            if(partnershipName != lstBroker[0].Name){
              VENDOR_HEADER.NAME_ORG1 = lstBroker[0].Name;
            }
            VENDOR_HEADER.CONTACT_PERSON = lstBroker[0].Representative_Name__c; 
            // VENDOR_HEADER.LEGAL_FORM = String.valueOf(lstBroker[0].Legal_Form__c);
            // VENDOR_HEADER.NATURE_WORK = String.valueOf(lstBroker[0].RW_NATURE_WORK__c);
            VENDOR_HEADER.PARTN_CAT = '2';
        }
        VENDOR_HEADER.STREET = lstBroker[0].STREET__c;
        VENDOR_HEADER.STR_SUPPL1 = lstBroker[0].STR_SUPPL1__c;
        VENDOR_HEADER.STR_SUPPL2 = lstBroker[0].STR_SUPPL2__c;
        VENDOR_HEADER.STR_SUPPL3 = lstBroker[0].STR_SUPPL3__c;
        VENDOR_HEADER.CITY = lstBroker[0].City__c;
        VENDOR_HEADER.POST_CODE = lstBroker[0].Pin_Code__c;
        VENDOR_HEADER.REGION = lstBroker[0].State__c;
        VENDOR_HEADER.COUNTRY = lstBroker[0].Country__c;
        VENDOR_HEADER.SORT1 = String.valueOf(lstBroker[0].RW_Broker_Number__c);
        VENDOR_HEADER.MOB_NUMBER = String.valueOf(lstBroker[0].RW_Mobile_No__c);
        VENDOR_HEADER.SMTP_ADDR = String.valueOf(lstBroker[0].RW_Email__c);
        
        if(!lstBroker[0].Is_NRI_CP__c){
            VENDOR_HEADER.RESIDENTIAL_STATUS = 'Residential';   
        }else{
            VENDOR_HEADER.RESIDENTIAL_STATUS = 'Non- Residential';  
        }
        
        if(lstBroker[0].Broker_Pan_No__c != null) // Added by coServe 29-11-2022
        	VENDOR_HEADER.PAN = lstBroker[0].Broker_Pan_No__c.toUpperCase(); // Added '.toUpperCase()' by coServe 29-11-2022
        if(lstBroker[0].RW_GST_Number__c != null) // Added by coServe 29-11-2022
        	VENDOR_HEADER.GST_NO = lstBroker[0].RW_GST_Number__c.toUpperCase(); // Added '.toUpperCase()' by coServe 29-11-2022
        if(lstBroker[0].RW_RERA_Registration_Number__c != null) // Added by coServe 29-11-2022
        	VENDOR_HEADER.RERA_NO = lstBroker[0].RW_RERA_Registration_Number__c.toUpperCase(); // Added '.toUpperCase()' by coServe 29-11-2022
        VENDOR_HEADER.ZTERMS = String.valueOf('Z500');
        VENDOR_HEADER.AADHAR_NO =lstBroker[0].Aadhar_Card__c;
        String jsonstring = Json.serialize(VENDOR_HEADER);
        system.debug('____jsonstring'+jsonstring);
        boolean callOutError=false;
        String exceptionMsg;
        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
        log.API_name__c = 'Channel Partner';
        log.Channel_Partner__c = lstBroker[0].id;
        
        
        try{
            boolean status = false;
            log.Request__c = JSON.serialize(VENDOR_HEADER);
            SAPChannelPartnerAPI.ZSD_SFDC_VENDORResponse_element resp = brokerData.ZSD_SFDC_VENDOR( RETURN_x,VENDOR_HEADER);
            log.Response__c = json.serialize(resp);
            system.debug('resp___ '+  json.serialize(resp));
            system.debug('resp.VENDOR_HEADER.LIFNR '+ resp.VENDOR_NUM);
            
            if(  resp.VENDOR_NUM != null &&  resp.VENDOR_NUM!= '')
                
            {
                lstBroker[0].SAP_CP_Code__c =  resp.VENDOR_NUM;
                log.Status__c='Success';
                if(   lstBroker[0].RW_CreateFromIRIS__c)
                status= IrisAPIChannelPartnerRestCallout.ChannelPartnerRestCallOutPatch(lstBroker[0]);
                system.debug(status);
                lstBroker[0].RW_IRIS_Sync__c = status;
                
                
                
            }else{
                log.Status__c='Failure';
                 log.Error_Type__c='Data Error';
            }
        }catch(Exception ex){
            System.debug('Exception:' + ex.getMessage());
            callOutError = true;
            exceptionMsg = ex.getMessage();
        }finally{
            if(!callOutError) {
                // log.Status__c = 'Success';
                erpLogList.add(log);
                
            } else {
                log.Status__c = 'Failure';
                log.Error_Type__c='Timeout Error';
                log.Error_Reason__c = exceptionMsg;
                erpLogList.add(log);
                
            }
         ChannelPartnerTriggerHandler.bypasstrigger =true;
            update lstBroker;
                       ChannelPartnerTriggerHandler.bypasstrigger =false;

            if(erpLogList.size()>0)
                upsert erpLogList;
        }
    }
    
   /*
       @invocablemethod 
    public static void callSAP(List<id> ids){
        sendBrokerlist(ids[0]);
    }*/
}