public class BilldeskPaymentAPI {
    
    public static String billdeskPayment(Map<String,String> DetailMap){
        List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: DetailMap.get('towerId')];
        List<Opportunity> opp = [SELECT Id,RW_Project__c,SAP_Customer_Number__c,SalesOrder_Number__c,RW_Mobile_No__c,RW_Email__c,
                                 RW_Project_Unit__r.Name FROM Opportunity WHERE Id =: DetailMap.get('OpportunityId')];
        Receipt__c receipt = new Receipt__c();
        receipt.Opportunity__c = DetailMap.get('OpportunityId');
        receipt.Project__c = towerData[0].ProjectName__c;
        receipt.Mode__c = 'Digital';
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c = Decimal.valueof(DetailMap.get('Amount'));
        receipt.Booking__c = DetailMap.get('bookingId');
        System.debug('DetailMap'+DetailMap.get('ProjectUnit'));
        receipt.Project_Unit__c=DetailMap.get('ProjectUnit');
        if(DetailMap.get('TypeOfAmount') == 'Normal'){
            receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Flat Cost';  
        }
        else if(DetailMap.get('TypeOfAmount') == 'GST'){
            receipt.RW_Payment_Collection_Type__c = 'Customer Portal - GST';  
        }
        if(DetailMap.containsKey('ButtonType') && DetailMap.get('ButtonType') == 'SinglePayment'){
            receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Outstanding'; 
        }
        //insert receipt;
        
        
        
        Datetime d = system.now();
        String timestamp = d.format('yyyyMMddHHmmss');
        
        String jwt = '';
        
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', 'HS256');
        header.writeStringField('clientid', System.label.Billdesk_Client_Id);
        header.writeEndObject();
        String encodedHeader = base64URLencode(Blob.valueOf(header.getAsString()));
        
        Device device = new Device();
        device.init_channel = 'internet';
        device.ip = '104.161.128.0';
        device.accept_header = 'text/html';
        device.browser_tz = '-330';
        device.browser_color_depth = '32';
        device.browser_java_enabled = 'false';
        device.browser_screen_height = '601';
        device.browser_screen_width = '657';
        device.browser_language = 'en-US';
        device.browser_javascript_enabled = 'true';
        device.user_agent = 'Mozilla/5.0(WindowsNT10.0;WOW64;rv:51.0)Gecko/20100101Firefox/51.0';
        
        AdditionaInfo addInfo = new AdditionaInfo();
        addInfo.additional_info1 = (opp.size() > 0)? opp[0].SalesOrder_Number__c : 'NA';
        addInfo.additional_info2 = (opp.size() > 0)? opp[0].SAP_Customer_Number__c : 'NA';
        addInfo.additional_info3 = (opp.size() > 0)? opp[0].RW_Project_Unit__r.Name : 'NA';
        addInfo.additional_info4 = (opp.size() > 0)? opp[0].RW_Email__c : 'NA';
        addInfo.additional_info5 = (opp.size() > 0)? opp[0].RW_Mobile_No__c : 'NA';
        addInfo.additional_info6 = 'NA';
        addInfo.additional_info7 = 'NA';
               
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('mercid', System.label.Billdesk_Merchint_Id);
        body.writeStringField('orderid', DetailMap.get('bookingId')+'_'+timestamp);
        body.writeStringField('amount', DetailMap.get('Amount'));
        body.writeStringField('order_date', DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'+05:30\''));
        body.writeStringField('currency', '356');
        body.writeStringField('ru', System.label.Billdesk_Site_URL);
        body.writeStringField('itemcode', 'DIRECT');
        body.writeFieldName('device');
        body.writeObject(device);
        body.writeFieldName('additional_info');
        body.writeObject(addInfo);
        body.writeEndObject();
        
        jwt = encodedHeader + '.' + base64URLencode(Blob.valueOf(body.getAsString()));
        Blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),Blob.valueOf(System.label.Billdesk_Secret_Key));
        jwt += '.' + base64URLencode(signature);
        
        System.debug('jwt: ' + jwt);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.label.Billdesk_Payment_API);
        req.setMethod('POST');
        req.setHeader('content-Type', 'application/jose');
        req.setHeader('bd-timestamp', d.format('yyyyMMddHHmmss'));
        req.setHeader('bd-traceid', DetailMap.get('bookingId')+'_'+timestamp);
        req.setHeader('accept', 'application/jose');
        req.setBody(jwt);
        
        Http http = new Http();
        HTTPResponse res = new HttpResponse();
         String resBody;
        if(!Test.isRunningTest()){
            res = http.send(req);
            System.debug('Response: ' + res.getBody());
        	resBody = res.getBody();
        }else{
            resBody = 'eyJhbGciOiJIUzI1NiIsImNsaWVudGlkIjoicnJlcGxtdWF0Iiwia2lkIjoiSE1BQyJ9.eyJvYmplY3RpZCI6Im9yZGVyIiwib3JkZXJpZCI6ImEwc0lwMDAwMDAwTElnQ0lBV18yMDI1MDEwNzE1MTQzNiIsImJkb3JkZXJpZCI6Ik9BNFgxQk1VVFI3V1gzSFoiLCJtZXJjaWQiOiJSUkVQTE1VQVQiLCJvcmRlcl9kYXRlIjoiMjAyNS0wMS0wN1QwMzoxNDozNiswNTozMCIsImFtb3VudCI6Ijg0MTM0NCIsImN1cnJlbmN5IjoiMzU2IiwicnUiOiJodHRwczovL3J1bndhbC0tZnVsbGNvcHkuc2FuZGJveC5teS5zYWxlc2ZvcmNlLXNpdGVzLmNvbS9CaWxsRGVzayIsImFkZGl0aW9uYWxfaW5mbyI6eyJhZGRpdGlvbmFsX2luZm8xIjoiTkEiLCJhZGRpdGlvbmFsX2luZm8yIjoiTkEiLCJhZGRpdGlvbmFsX2luZm8zIjoiTkEiLCJhZGRpdGlvbmFsX2luZm80IjoiTkEiLCJhZGRpdGlvbmFsX2luZm81IjoiTkEiLCJhZGRpdGlvbmFsX2luZm82IjoiTkEiLCJhZGRpdGlvbmFsX2luZm83IjoiTkEiLCJhZGRpdGlvbmFsX2luZm84IjoiTkEiLCJhZGRpdGlvbmFsX2luZm85IjoiTkEiLCJhZGRpdGlvbmFsX2luZm8xMCI6Ik5BIn0sIml0ZW1jb2RlIjoiRElSRUNUIiwiY3JlYXRlZG9uIjoiMjAyNS0wMS0wN1QxNToxNDozNyswNTozMCIsIm5leHRfc3RlcCI6InJlZGlyZWN0IiwibGlua3MiOlt7ImhyZWYiOiJodHRwczovL3d3dy5iaWxsZGVzay5jb20vcGdpL3ZlMV8yL29yZGVycy9hMHNJcDAwMDAwMExJZ0NJQVdfMjAyNTAxMDcxNTE0MzYiLCJyZWwiOiJzZWxmIiwibWV0aG9kIjoiR0VUIn0seyJocmVmIjoiaHR0cHM6Ly91YXQxLmJpbGxkZXNrLmNvbS91Mi93ZWIvdjFfMi9lbWJlZGRlZHNkayIsInJlbCI6InJlZGlyZWN0IiwibWV0aG9kIjoiUE9TVCIsInBhcmFtZXRlcnMiOnsibWVyY2lkIjoiUlJFUExNVUFUIiwiYmRvcmRlcmlkIjoiT0E0WDFCTVVUUjdXWDNIWiIsInJkYXRhIjoiYzk2NDgyMGJhMjRhOWQ1NDk0YmZjZjA4MjEwM2IyMGQwY2M0YmJhYTI1OTM1MGEyNzI0ZjhlZWY5YzM0NWM4YmM1YWQ1ZDlhZjk1OTA2YjQ0MDBmODdkYjUwYmYwZjdiMTZiNzQ2MWYwMzExYWFjNmQzYWQ5NzAxMjUyOThjZmU0OGIwLjQxNDU1MzVmNTU0MTU0MzEifSwidmFsaWRfZGF0ZSI6IjIwMjUtMDEtMDdUMTU6NDQ6MzcrMDU6MzAiLCJoZWFkZXJzIjp7ImF1dGhvcml6YXRpb24iOiJPVG9rZW4gMDY2M2JkNmJhMGQ4OGY5NzI3Mjk4OTc1ZTBhMDI3MjQ5MmYwOTA2YTEzNzMzYTAyZGIyYjU3OWRjODg4YWIyNmJjODIwODRjNTNmYTQxMzFmN2ZjZjZmYjZkZTA2MTE1OWQyYzZjOTBmZGYzM2E1ZmZmMjcxYjFlM2E2MmNhNzcxMzFhMTdiNjVlY2E2NTFjZTdiOTNlOTA4M2I1YWEzMDlkZmU3N2EyYjVkYzBhZGE1NWI3ZWM0N2ZhOWUyNWY1NjA0Y2RlNmJiNWNiN2M1NDE3ZTM1NThjODliYzUxMjlhY2MzYWNjMDhiZWI1ZTI1ZjQ4ZjE2Njg4M2ExMGIzZmQ1YzAzZDhmYTk0YzM3YmZlYzc2NDMwZjVjYzM0MDdiNWY4YzQxYjNlMDc2NDZhYWRiMmEuNDE0NTUzNWY1NTQxNTQzMSJ9fV0sInN0YXR1cyI6IkFDVElWRSJ9.Ga1-asBGKSwDeX2T_-AFAOzeJG7QLTCCGEm33faxQeo';
        }
		
        
        Integer index1 = resBody.indexOf('.');
        if(index1 != null){
            resBody = resBody.subString(index1+1, resBody.length()-1);
            Integer index2 = resBody.indexOf('.');
            if(index2 != null){
                resBody = resBody.subString(0,index2);
            }
        }
        Blob bsignature = EncodingUtil.base64Decode(resBody);
        String decodeBase64String = bsignature.toString();
        System.debug('decodeBase64String: ' + decodeBase64String);
        ResponseBody result = (ResponseBody)JSON.deserialize(decodeBase64String, ResponseBody.class );
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'Billdesk_html'];
        System.debug('body: ' + sr.Body.toString());
        String srBody = sr.Body.toString();
        srBody = srBody.replace('{rdata}', result.links[1].parameters.rdata);
        srBody = srBody.replace('{bdorderid}', result.bdorderid);
        srBody = srBody.replace('{merchantid}', result.mercid);
        System.debug('srBody: ' + srBody);
        
        receipt.Booking_Id_with_Timestamp__c = DetailMap.get('bookingId')+'_'+timestamp;
        receipt.Billdesk_Order_Id__c = result.orderid;
        insert receipt;
        
        return srBody;
        
    }
    
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
    
    public PageReference redirect(){
        //return new PageReference('https://runwal--fullcopy.sandbox.my.site.com/customer/s/customerledger');
        pageReference pageRef = new Pagereference('/apex/FeedbackAlreadySubmitted');
            pageRef.setRedirect(true);
            return pageRef;
    }
    public class ResponseBody{
        public string objectid;
        public string orderid;
        public string bdorderid;
        public string mercid;
        public string order_date;
        public string amount;
        public string ru;
        public AdditionaInfo additional_info;
        public string itemcode;
        public string createdon;
        public string next_step;
		public List<Link> links;        
    }
    
    public class AdditionaInfo{
        public string additional_info1;
        public string additional_info2;
        public string additional_info3;
        public string additional_info4;
        public string additional_info5;
        public string additional_info6;
        public string additional_info7;
    }
    
    public class Link{
        public String href;	
		public String rel;	
		public String method;	
		public Link_Parameters parameters;
		public String valid_date;	
		public Link_Headers headers;
    }
    class Link_Parameters {
		public String mercid;	
		public String bdorderid;	
		public String rdata;	
	}
	class Link_Headers {
		public String authorization;	
	}

    class Device {
		public String init_channel;
        public String ip;	
        public String user_agent;	
        public String accept_header;
        public String browser_tz;
        public String browser_color_depth;	
        public String browser_java_enabled;	
        public String browser_screen_height;
        public String browser_screen_width;
        public String browser_language;
        public String browser_javascript_enabled;
	}

}