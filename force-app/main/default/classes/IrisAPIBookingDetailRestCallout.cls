//http://runwal.iris1.selldoapp.com/api/v1/booking_details
public class IrisAPIBookingDetailRestCallout {
  
    @invocablemethod(label='IrisAPIBookingDetailRestCallout')
    
    public static void callIris(List<id> bklist){
     
        irisBookingAPICallout(bklist);
    }
    
    @future(callout=true)
    public static void irisBookingAPICallout(List<id> bkId){
    
        List<Booking__c> bkList = [select id, Carpet_Area__c,Token_Amount__c,Booking_Date__c,Customer__r.RW_Walkin_Channel_Partner__c,Unit_No__r.Saleable_Area__c,BrokerIId__r.RW_CreateFromIRIS__c,Customer__r.RW_Walkin_Channel_Partner__r.RW_CreateFromIRIS__c,BrokerIId__c, Source_of_Booking__c ,Quotation__r.Agreement_Value__c,Quotation__r.Agreement_Value_D__c,Quotation__r.Grand_Total__c,RW_Stop_IRIS_Sync__c,Customer__c,Unit_No__c,Unit_No__r.Unit_SAP_Code__c,Unit_no__r.Bed_Rooms__c,Unit_No__r.New_Floor__c,RW_Synced_with_IRIS__c,RW_X9_99_Received__c,
                                   (select id,Salutation__c,First_Name__c,Last_Name__c,Email_Address__c,Mobile_Number__c,PancardNo__c,DOB__c,Address_Proof_Document__c,Address_Proof_Number__c
                                    ,Subtype_Of_Applicant__c,Designation_picklist__c,Organization_Name__c,Type_Of_Applicant__c from ApplicantDetails__r where Applicant_Number__c = 'Primary Applicant'),
                                   (select id,Name,RW_Payment_Mode__c,RW_Instrument_Number__c,RW_Status_Code__c,RW_Posting_Date__c,RW_Accounting_Document_Number__c,RW_Bank_Reference_Number__c,RW_Booking__c,RW_Branch_Name__c,RW_Clearing_Document_Number__c	
                             ,RW_Payment_Amount__c ,RW_Company_Code__c,Total_Amount_Paid__c,RW_Payment_Date__c,RW_Iris_Synced__c,Status__c from Payment_Details__r where RW_Iris_Synced__c=false)
                                   from booking__c where id in : bkId];
        if(bkList[0].Source_of_Booking__c == 'Channel Partner' && (bkList[0].BrokerIId__c != null || bkList[0].Customer__r.RW_Walkin_Channel_Partner__c != null)  && (bkList[0].BrokerIId__r.RW_CreateFromIRIS__c || bkList[0].Customer__r.RW_Walkin_Channel_Partner__r.RW_CreateFromIRIS__c)){
            if(!(bkList[0].RW_Synced_with_IRIS__c)){
                System.debug('*inside 1*');
                if( ! bkList[0].RW_X9_99_Received__c  && !bkList[0].RW_Stop_IRIS_Sync__c)
                {
                    System.debug('*inside 2*');
                    IrisAPIBookingDetailJson objJson  = new IrisAPIBookingDetailJson();
                    IrisAPIBookingDetailJson.cls_booking_detail clsBookingDetails = new IrisAPIBookingDetailJson.cls_booking_detail();
                    List<IrisAPIBookingDetailJson.cls_receipts_attributes> listOfreceiptAtt = new List<IrisAPIBookingDetailJson.cls_receipts_attributes>();
                    
                    clsBookingDetails.reference_id = bkList[0].id;
                    clsBookingDetails.project_unit_id=bkList[0].Unit_No__r.Unit_SAP_Code__c;
                    clsBookingDetails.lead_id = bkList[0].Customer__c;
                    //clsBookingDetails.agreement_price = bkList[0].Quotation__r.Agreement_Value__c;
                    clsBookingDetails.agreement_price = bkList[0].Quotation__r.Agreement_Value_D__c;
                    clsBookingDetails.all_inclusive_price = bkList[0].Quotation__r.Grand_Total__c;
                    //Added by Mounika on 08Feb2021 New fields updated by Sell.do
                    clsBookingDetails.blocking_amount = String.valueOf(bkList[0].Token_Amount__c);
                    clsBookingDetails.booked_on = DateTime.newInstance(bkList[0].Booking_Date__c.year(),bkList[0].Booking_Date__c.month(), bkList[0].Booking_Date__c.day()).format('d/MM/YYYY');//String.valueOf(bkList[0].Booking_Date__c);
                    clsBookingDetails.saleable = String.valueOf(bkList[0].Unit_No__r.Saleable_Area__c);
                    clsBookingDetails.carpet =  String.valueOf(bkList[0].Carpet_Area__c);
                    //Ends here
                    IrisAPIBookingDetailJson.cls_configurations config= new IrisAPIBookingDetailJson.cls_configurations();
                    config.conf=bkList[0].Unit_no__r.Bed_Rooms__c;
                    IrisAPIBookingDetailJson.cls_preferred_floors pref= new IrisAPIBookingDetailJson.cls_preferred_floors();
                    pref.flr=bkList[0].Unit_no__r.New_Floor__c;
                    IrisAPIBookingDetailJson.cls_primary_user_kyc_attributes usr = new IrisAPIBookingDetailJson.cls_primary_user_kyc_attributes();
                    //IrisAPIBookingDetailJson.cls_tasks_attributes task = new  IrisAPIBookingDetailJson.cls_tasks_attributes();
                    for(Applicant_Details__c ap : bkList[0].ApplicantDetails__r){
                        usr.reference_id = ap.id;
                        usr.salutation = ap.Salutation__c;
                        usr.first_name = ap.First_Name__c;
                        usr.last_name = ap.Last_Name__c;
                        usr.email = ap.Email_Address__c;
                        usr.phone = ap.Mobile_Number__c;
                        usr.pan_number = ap.PancardNo__c;
                        if(ap.Address_Proof_Document__c == 'Aadhar Card')
                            usr.aadhaar = ap.Address_Proof_Number__c;
                        system.debug(ap.DOB__c);
                        usr.dob =DateTime.newInstance( ap.DOB__c.year(), ap.DOB__c.month(), ap.DOB__c.day()).format('d/MM/YYYY');//'10/10/1990'; //string.valueOf(ap.DOB__c);
                        usr.configurations = new List<IrisAPIBookingDetailJson.cls_configurations>();
                        usr.configurations.add(config);
                        usr.preferred_floors = new  List<IrisAPIBookingDetailJson.cls_preferred_floors>();
                        
                        usr.preferred_floors.add(pref); 
                        usr.designation = ap.Designation_picklist__c;
                        usr.customer_company_name = ap.Organization_Name__c;
                        usr.lead_id = bkList[0].Customer__c;
                        if(ap.Subtype_Of_Applicant__c == 'For NRI')
                            usr.nri = true;
                        if(ap.Type_Of_Applicant__c == 'Corporate Buyer')
                            usr.is_company = true;
                        
                    }
                    
                    for(RW_payment_details__c pd : bkList[0].payment_details__r){
                        if(pd.status__c != 'Reversed')
                        {
                        IrisAPIBookingDetailJson.cls_receipts_attributes rec = new IrisAPIBookingDetailJson.cls_receipts_attributes();
                        
                        rec.issued_date = DateTime.newInstance( pd.RW_Payment_Date__c.year(), pd.RW_Payment_Date__c.month(), pd.RW_Payment_Date__c.day()).format('d/MM/YYYY');
                        rec.processed_on = DateTime.newInstance( pd.RW_Posting_Date__c.year(), pd.RW_Posting_Date__c.month(), pd.RW_Posting_Date__c.day()).format('d/MM/YYYY');
                        rec.total_amount= pd.RW_Payment_Amount__c;
                        rec.payment_identifier = pd.RW_Instrument_Number__c;
                        
                        rec.reference_id = pd.Id;
                        if(pd.RW_Status_Code__c == null)
                            rec.status = 'success';
                        else
                            rec.status ='revoke';
                        listOfreceiptAtt.add(rec);
                    }
                    }
                    
                    
                    //
                    clsBookingDetails.receipts_attributes=listOfreceiptAtt;
                    clsBookingDetails.primary_user_kyc_attributes = usr;
                    objJson.booking_detail = clsBookingDetails;
                    
                    system.debug('_____objJson  '+objJson);
                    string str = System.JSON.serialize(objJson);
                    
                    system.debug('____JsonStr  '+str);
                    
                    ERP_Integration_Log__c log = new ERP_Integration_Log__c(); /* logging changes start */
                    log.API_name__c = 'IRIS Channel Partner';
                    log.Booking__c = bkList[0].id;
                    log.Request__c=str;  //logging Request
                    try{                    
                    //callout
                    Http http = new Http();
                    HttpRequest req = new HttpRequest(); 
                    req.setMethod('POST');
                    req.setHeader('Content-Type',  'application/json');
               //     req.setHeader('Client-key', 'f389fd4bf4e34a772a2a5946b5b159a0'); 
         req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
            req.setHeader('Client-id', System.label.RW_Iris_clientid); 
     req.setTimeout(120000);
                 //   req.setHeader('Client-id', '5fa1990f62d4a723cee0e6a3'); 
                    req.setEndpoint(System.label.RW_IRIS_Endpoint+'booking_details');
                    req.setBody(str);
                    HTTPResponse res = http.send(req);
                    System.debug('res!!! getBody '+res.getBody());
                    System.debug('res!!! getStatusCode '+res.getStatusCode());
	                log.Response__c =res.getBody(); //logging response
                    if(res.getStatusCode() == 200 || res.getStatusCode()  ==201){
	                    log.Status__c = 'Success';
                        bkList[0].RW_Synced_with_IRIS__c = true;
                        //  pd.RW_Iris_Synced__c = true;
                        //   update pd;
                        update bkList;
                    }
                    else{
                    	log.Status__c = 'Failure';
                        log.Error_Type__c = 'Data Error';
                    }
                    }catch(exception e){
                	 	log.Status__c = 'Failure';
                		log.Error_Type__c = 'Timeout Error';
               			log.Error_Reason__c = e.getMessage();
            	    }finally{
                		upsert log;
            		}
                }
            }}
        
        //if booking is iris synced and receipt is not iris synced then call iris payment created
        //call booking create
        
    }
     	
    
  
}