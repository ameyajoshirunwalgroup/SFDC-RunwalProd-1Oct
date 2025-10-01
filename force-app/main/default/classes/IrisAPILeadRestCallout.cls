//http://runwal.iris1.selldoapp.com/api/v1/leads
public class IrisAPILeadRestCallout {
    @future(callout=true)
    public static void LeadRestCalloutPost(id optyid){
        opportunity             oppo= [select id,Name,account.firstname,account.lastname,RW_Email__c,RW_Mobile_No__c,StageName,First_Site_Visit_Date__c
                                       ,Last_Site_Visit_Date__c,RW_Number_of_Re_Visit__c,visit_counter__c,RW_Walkin_Channel_Partner__c,AccountId,RW_Project__r.Name,RW_Project__c    from opportunity where id=:optyid];
        
        
        IrisAPILeadJson objJson  = new IrisAPILeadJson();
        IrisAPILeadJson.cls_lead clsLead = new IrisAPILeadJson.cls_lead();
        clsLead.first_name = oppo.Name;
        //clsLead.first_name = oppo.account.firstname;
        //clsLead.last_name=   oppo.account.lastname;
        clsLead.email = oppo.RW_Email__c;
        clsLead.phone = oppo.RW_Mobile_No__c;
        clsLead.stage = oppo.StageName;
        if(oppo.First_Site_Visit_Date__c!=null)
            clsLead.sitevisit_date =DateTime.newInstance( oppo.First_Site_Visit_Date__c.year(), oppo.First_Site_Visit_Date__c.month(), oppo.First_Site_Visit_Date__c.day()).format('d/MM/YYYY');// String.valueOf(oppo.First_Site_Visit_Date__c);
        if(oppo.Last_Site_Visit_Date__c!=null)
            clsLead.last_revisit_date =DateTime.newInstance( oppo.Last_Site_Visit_Date__c.year(), oppo.Last_Site_Visit_Date__c.month(), oppo.Last_Site_Visit_Date__c .day()).format('d/MM/YYYY'); //String.valueOf(oppo.Last_Site_Visit_Date__c);
        clsLead.revisit_count = Integer.valueOf(oppo.RW_Number_of_Re_Visit__c);
        clsLead.manager_id = oppo.RW_Walkin_Channel_Partner__c;
        clsLead.user_id = oppo.AccountId;
        //clsLead.project_id = oppo.RW_Project__r.Name;//'Runwal Bliss';
		clsLead.project_id = oppo.RW_Project__c;
        clsLead.reference_id = oppo.Id;
        
        
        objJson.lead = clsLead;
        
        system.debug('_____objJson  '+objJson);
        string str = System.JSON.serialize(objJson);
		ERP_Integration_Log__c log = new ERP_Integration_Log__c();
         log.API_name__c = 'IRIS Channel Partner';
         log.Opportunity__c =oppo.id;
          log.Request__c= str;						 
        
        system.debug('____JsonStr  '+str);
        try{
            
            //callout
            Http http = new Http();
            HttpRequest req = new HttpRequest(); 
            req.setMethod('POST');
            req.setHeader('Content-Type',  'application/json');
            req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
            req.setHeader('Client-id', System.label.RW_Iris_clientid); 
            req.setEndpoint(System.label.RW_IRIS_Endpoint+'leads');
            req.setBody(str);
            HTTPResponse res = http.send(req);
			            log.Response__c =res.getBody();							   
            System.debug('res!!! getBody '+res.getBody());
            System.debug('res!!! getStatusCode '+res.getStatusCode());
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
				log.Status__c ='Success';						  
                oppo.RW_Sent_to_IRIS__c =true;
                update oppo;
            }else if( res.getStatusCode() == 422){
                
                Http http1 = new Http();
                objJson.lead.reference_id = null;
                HttpRequest req1 = new HttpRequest(); 
                req1.setMethod('PUT');
                req1.setHeader('Content-Type',  'application/json');
                req1.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
                req1.setHeader('Client-id', System.label.RW_Iris_clientid); 
                req1.setEndpoint(System.label.RW_IRIS_Endpoint+'leads/'+oppo.Id);
                req1.setBody(json.serialize(objJson));
                HTTPResponse res1 = http1.send(req1);
                System.debug('res!!! getBody '+res1.getBody());
                System.debug('res!!! getStatusCode '+res1.getStatusCode());
                if(res1.getStatusCode() == 200 || res1.getStatusCode() == 201){
					log.Status__c ='Success';
                    oppo.RW_Sent_to_IRIS__c =true;
                    update oppo;
                }
            }
        }catch(exception e){
			log.Status__c ='Failure';
                    log.Error_Reason__c =e.getMessage();
                    log.Error_Type__c = 'Data Error';											
            
        }
	finally
        {
            upsert log;
            
        }		
    }
    @future(callout=true)
    public static void LeadRestCalloutPatch(id optyid){
        opportunity             oppo= [select id,account.firstname,account.lastname,RW_Email__c,RW_Mobile_No__c,StageName,First_Site_Visit_Date__c,
                                      RW_Number_of_Re_Visit__c, RW_Project__r.name,RW_Project__c ,Last_Site_Visit_Date__c,visit_counter__c,RW_Walkin_Channel_Partner__c,AccountId    from opportunity where id=:optyid];
        
        
        IrisAPILeadJson objJson  = new IrisAPILeadJson();
        IrisAPILeadJson.cls_lead clsLead = new IrisAPILeadJson.cls_lead();
        clsLead.first_name = oppo.account.firstname;
        clsLead.last_name=   oppo.account.lastname;
        clsLead.email = oppo.RW_Email__c;
        clsLead.phone = oppo.RW_Mobile_No__c;
        clsLead.stage = oppo.StageName;
        if(oppo.First_Site_Visit_Date__c!=null)
            clsLead.sitevisit_date =DateTime.newInstance( oppo.First_Site_Visit_Date__c.year(), oppo.First_Site_Visit_Date__c.month(), oppo.First_Site_Visit_Date__c.day()).format('d/MM/YYYY');// String.valueOf(oppo.First_Site_Visit_Date__c);
        if(oppo.Last_Site_Visit_Date__c!=null)
            clsLead.last_revisit_date =DateTime.newInstance( oppo.Last_Site_Visit_Date__c.year(), oppo.Last_Site_Visit_Date__c.month(), oppo.Last_Site_Visit_Date__c .day()).format('d/MM/YYYY'); //String.valueOf(oppo.Last_Site_Visit_Date__c);
        
        clsLead.revisit_count = Integer.valueOf(oppo.RW_Number_of_Re_Visit__c);
        clsLead.manager_id = oppo.RW_Walkin_Channel_Partner__c;
        clsLead.user_id = oppo.AccountId;
       // clsLead.project_id = oppo.RW_Project__r.name;//'Runwal Bliss';
	   clsLead.project_id = oppo.RW_Project__c;
        objJson.lead = clsLead;
        
        system.debug('_____objJson  '+objJson);
        string str = System.JSON.serialize(objJson);
        ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
         erp.API_name__c = 'IRIS Channel Partner';
         erp.Opportunity__c =oppo.id;
         erp.Request__c= str;
        system.debug('____JsonStr  '+str);
        
        try{
        //callout
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('PUT');
        req.setHeader('Content-Type',  'application/json');
        req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
        req.setHeader('Client-id', System.label.RW_Iris_clientid); 
        
        req.setEndpoint(System.label.RW_IRIS_Endpoint+'leads/'+oppo.Id);
        req.setBody(str);
        HTTPResponse res = http.send(req);
			erp.Response__c =res.getBody();						   
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
		if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                     //changes,req - res
                    
                    
                     erp.Status__c ='Success';
                    oppo.RW_Sent_to_IRIS__c =true;
                    update oppo;
                }
        
    }catch(exception e){
        erp.Status__c ='Failure';//
                    erp.Error_Reason__c =e.getMessage();
                    erp.Error_Type__c = 'Data Error';
                    //erp.Request__c= str;
                    //insert erp;
    }
        finally
        {
            upsert erp;
        }															  
    }
    
    
    @invocablemethod (label='Sends the opportunity to IRIS' description='Send the opportunity to IRIS')
    public static void sendtoIris(list<opportunity> opps){
        if(opps[0].RW_Sent_to_IRIS__c	)
            LeadRestCalloutPatch(opps[0].id);
        else
            LeadRestCalloutPost(opps[0].id);
    }
    
}