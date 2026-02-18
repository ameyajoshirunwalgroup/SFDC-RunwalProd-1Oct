public class IrisAPIChannelPartnerRestCallout {
  /*  
    public static boolean ChannelPartnerRestCallOutPost(Broker__c channelPartner){
        //Broker__c channelPartner = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Representative_Name__c, RW_Email__c, RW_Mobile_No__c, RW_Broker_Number__c, Address__c, Broker_Pan_No__c, Broker_Type__c, Service_Tax_No__c, City__c, State__c, Pin_Code__c, Phone_2__c, Country__c, RW_GST_Number__c, RW_RERA_Registration_Number__c, RW_Is_GST_Applicable__c, RW_Is_RERA_Applicable__c, RW_Proof_of_Income__c, Is_NRI_CP__c, SAP_CP_Code__c, Locality__c, Zone__c, Experience__c, CP_Speciality__c, Lead_Generation_Methodology__c, RW_CreateFromIRIS__c, Individual_CP__c, NAME_FIRST__c, NAME_LAST__c, NAME_MIDDLE__c, RW_IRIS_Sync__c, STREET__c, STR_SUPPL1__c, STR_SUPPL2__c, RW_NATURE_WORK__c, Aadhar_Card__c, STR_SUPPL3__c, Payment_Terms__c, TITLE__c, Legal_Form__c FROM Broker__c where Id=:channelPartnerId];
        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
        log.API_name__c = 'IRIS Channel Partner';
        log.Channel_Partner__c = channelPartner.id;
        try{
            IrisAPIChannelPartnerJson objJson  = new IrisAPIChannelPartnerJson();
            IrisAPIChannelPartnerJson.Channel_partner chnPatner = new IrisAPIChannelPartnerJson.Channel_partner();
            chnPatner.first_name = channelPartner.NAME_FIRST__c;
            chnPatner.last_name = channelPartner.NAME_LAST__c;
            chnPatner.email = channelPartner.RW_Email__c;// 'Test17DecPostMan@gmail.com';
            chnPatner.phone = channelPartner.RW_Mobile_No__c;//'+919441523623';
            chnPatner.pan_number = channelPartner.Broker_Pan_No__c; //'ALWPG5809L';
            chnPatner.reference_id = channelPartner.id;
            chnPatner.rera_id = channelPartner.RW_RERA_Registration_Number__c;//'123';
            chnPatner.team_size = 5;
            chnPatner.company_name = channelPartner.Name; 
            chnPatner.cp_code =  channelPartner.SAP_CP_Code__c ;//'qwsed';
            objJson.channel_partner = chnPatner;
            
            system.debug('_____objJson  '+objJson);
            string str = System.JSON.serialize(objJson);
            
            system.debug('____JsonStr  '+str);
            
            
            log.Request__c=str;
            //callout
            Http http = new Http();
            HttpRequest req = new HttpRequest(); 
            req.setMethod('POST');
            req.setHeader('Content-Type',  'application/json');
            req.setHeader('Client-key', 'f389fd4bf4e34a772a2a5946b5b159a0'); 
            req.setHeader('Client-id', '5fa1990f62d4a723cee0e6a3'); 
            req.setEndpoint('http://runwal.iris1.selldoapp.com/api/v1/channel_partners');
            req.setBody(str);
            HTTPResponse res = http.send(req);
            System.debug('res!!! getBody '+res.getBody());
            System.debug('res!!! getStatusCode '+res.getStatusCode());
            log.Response__c = json.serialize(res);
            if(res.getStatusCode() == 200 || res.getStatusCode()==201){
                log.Status__c = 'Success';
                
                insert log;
                return true;
            }else{
                log.Status__c = 'Failure';
                log.Error_Type__c='Data Error';
                insert log;
                return false;
            }
        }
        catch(exception e){
            
            log.Status__c = 'Failure';
            log.Error_Type__c = 'Timeout Error';
            log.Error_Reason__c = e.getMessage();
            insert log;
            return false;
        }
    }*/
    
    public static boolean ChannelPartnerRestCallOutPatch(Broker__c channelPartner){
        //Broker__c channelPartner = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Representative_Name__c, RW_Email__c, RW_Mobile_No__c, RW_Broker_Number__c, Address__c, Broker_Pan_No__c, Broker_Type__c, Service_Tax_No__c, City__c, State__c, Pin_Code__c, Phone_2__c, Country__c, RW_GST_Number__c, RW_RERA_Registration_Number__c, RW_Is_GST_Applicable__c, RW_Is_RERA_Applicable__c, RW_Proof_of_Income__c, Is_NRI_CP__c, SAP_CP_Code__c, Locality__c, Zone__c, Experience__c, CP_Speciality__c, Lead_Generation_Methodology__c, RW_CreateFromIRIS__c, Individual_CP__c, NAME_FIRST__c, NAME_LAST__c, NAME_MIDDLE__c, RW_IRIS_Sync__c, STREET__c, STR_SUPPL1__c, STR_SUPPL2__c, RW_NATURE_WORK__c, Aadhar_Card__c, STR_SUPPL3__c, Payment_Terms__c, TITLE__c, Legal_Form__c FROM Broker__c where Id=:channelPartnerId];
        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
        log.API_name__c = 'IRIS Channel Partner';
        log.Channel_Partner__c = channelPartner.id;
        IrisAPIChannelPartnerJson objJson  = new IrisAPIChannelPartnerJson();
        IrisAPIChannelPartnerJson.Channel_partner chnPatner = new IrisAPIChannelPartnerJson.Channel_partner();
     /*   chnPatner.first_name = channelPartner.NAME_FIRST__c;
chnPatner.last_name = channelPartner.NAME_LAST__c;
chnPatner.email = channelPartner.RW_Email__c;// 'Test17DecPostMan@gmail.com';
chnPatner.phone = channelPartner.RW_Mobile_No__c;//'+919441523623';
chnPatner.pan_number = channelPartner.Broker_Pan_No__c; //'ALWPG5809L';
chnPatner.rera_id = channelPartner.RW_RERA_Registration_Number__c;//'123';
chnPatner.team_size = 5;*/
        chnPatner.cp_code =  channelPartner.SAP_CP_Code__c ;
        objJson.channel_partner = chnPatner;
        
        system.debug('_____objJson  '+objJson);
        string str = System.JSON.serialize(objJson);
            //String codecoverageby ='true'; //Commented by Vinay 03-06-2025
            //string codercoverage='yes'; //Commented by Vinay 03-06-2025
        system.debug('____JsonStr  '+str);
        
        log.Request__c=str;
        //callout
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest(); 
            req.setMethod('PATCH');
            req.setHeader('Content-Type',  'application/json');
            req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
            req.setHeader('Client-id', System.label.RW_Iris_clientid); 
            req.setEndpoint(System.label.RW_IRIS_Endpoint+'channel_partners/'+channelPartner.Id);
            req.setBody(str);
            HTTPResponse res = http.send(req);
            System.debug('res!!! getBody '+res.getBody());
            System.debug('res!!! getStatusCode '+res.getStatusCode());
            log.Response__c =res.getBody();
          
            
            if(res.getStatusCode() == 200 || res.getStatusCode()==201){
                log.Status__c = 'Success';
                
                insert log;               
                return true;
            }else{
                log.Status__c = 'Failure';
                log.Error_Type__c='Data Error';
                insert log;
                return false;
            }
        }
        catch(exception e){
            
            log.Status__c = 'Failure';
            log.Error_Type__c = 'Timeout Error';
            log.Error_Reason__c = e.getMessage();
            insert log;            
            return false;
        }
    }
    
 /*   @invocablemethod (label='Sends the Channel Partner to IRIS' description='Send the Channel Partner to IRIS')
    public static void sendtoIris(list<Broker__c> channelPartner){
        if(channelPartner[0].RW_Sent_to_IRIS__c	)
ChannelPartnerRestCallOutPatch(channelPartner[0].id);
else
ChannelPartnerRestCallOutPost(channelPartner[0].id);
    }*/
}