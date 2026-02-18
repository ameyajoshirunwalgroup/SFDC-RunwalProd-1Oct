@RestResource(urlMapping='/cpAnalytics/*')
global without sharing class Lockated_CPAnalytics {
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        resp.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        String cpId = req.params.get('cpId'); 
        if(String.isBlank(cpId)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid CP Id');
            resp.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            resp.statusCode = 400;
        }else{ 
            try{
                Map<String, Date> fyDates = getFinancialsYearDates();
                Date startDate = fyDates.get('start');
                Date endDate = fyDates.get('end');
                
                Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
                Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
                list<Broker__c> brs = [Select Id,RecordTypeId from Broker__c where Id =: cpId limit 1];            
                
                // Query active leads
                Integer activeLeadsCount = 0;        
                if(brs[0].RecordTypeId == CPRecordTypeId){
                    activeLeadsCount = [
                        SELECT COUNT()
                        FROM Lead where IsActive__c = true
                        and (Walkin_Channel_Partner__c = :cpId OR RW_Broker__c =: cpId)
                        AND (LeadSource = 'Channel Partner' OR Walkin_Source__c = 'Channel Partner') AND CreatedDate >=: startDate AND CreatedDate <=: endDate                 
                    ];
                } else if(brs[0].RecordTypeId == TempCPRecordTypeId){
                    activeLeadsCount = [
                        SELECT COUNT()
                        FROM Lead where IsActive__c = true
                        and (Walkin_Channel_Partner__c = :cpId OR RW_Broker__c =: cpId)
                        AND (LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner') AND CreatedDate >=: startDate AND CreatedDate <=: endDate
                    ];
                }
                
                // Query Walkin Opportunities
                Integer activeOppsCount = 0;        
                if(brs[0].RecordTypeId == CPRecordTypeId){
                    activeOppsCount = [
                        SELECT COUNT()
                        FROM Opportunity where
                        RW_Walkin_Channel_Partner__c  = : cpId and StageName = 'Site Visit'
                        AND Walkin_Source__c  = 'Channel Partner' AND CreatedDate >=: startDate AND CreatedDate <=: endDate
                    ];
                } else if(brs[0].RecordTypeId == TempCPRecordTypeId){
                    activeOppsCount = [
                        SELECT COUNT()
                        FROM Opportunity where
                        RW_Walkin_Channel_Partner__c  = : cpId and StageName = 'Site Visit'
                        AND Walkin_Source__c  = 'Temp Channel Partner' AND CreatedDate >=: startDate AND CreatedDate <=: endDate
                    ];
                }
                
                // Query Bookings
                Decimal salesValue = 0;
                Decimal salesValueCurrentYear = 0;
                Integer activeBookingsCount = 0;
                List<SalesDetail> salesDetails = new List<SalesDetail>();
                list<Booking__c> blist = [SELECT Id,Name,Agreement_Value_for_brokers__c,Booking_Date__c,Source_of_Booking__c,Status__c,Unit_Type__c,Unit_No__r.Name,Tower__r.Name,Project__r.Name,Opportunity__r.Name
                                          FROM Booking__c where 
                                          (Source_of_Booking__c ='Channel Partner' OR Source_of_Booking__c ='Temp Channel Partner')  and BrokerIId__c =: cpId AND Booking_Date__c >=: startDate AND Booking_Date__c <=: endDate Order by Booking_Date__c Desc];
                if(!blist.isEmpty()){            
                    Date today = Date.today();
                    Integer year = today.year();
                    Integer fyStartYear;
                    Integer fyEndYear;
                    if (today.month() >= 4) {
                        fyStartYear = year;
                        fyEndYear   = year + 1;
                    } else {
                        fyStartYear = year - 1;
                        fyEndYear   = year;
                    }
                    Date fyStartDate = Date.newInstance(fyStartYear, 4, 1);
                    Date fyEndDate   = Date.newInstance(fyEndYear, 3, 31); 
                    System.debug('FY Start: ' + fyStartDate);
                    System.debug('FY End: '   + fyEndDate);
                    for(Booking__c b : blist){
                        if(brs[0].RecordTypeId == CPRecordTypeId && b.Status__c == 'Booking Confirmed' && b.Source_of_Booking__c =='Channel Partner'){
                            activeBookingsCount += 1;
                            salesValue += b.Agreement_Value_for_brokers__c;
                            if(b.Booking_Date__c >= fyStartDate && b.Booking_Date__c <= fyEndDate ){
                                salesValueCurrentYear += b.Agreement_Value_for_brokers__c;
                            }
                        }else if(brs[0].RecordTypeId == TempCPRecordTypeId && b.Source_of_Booking__c == 'Temp Channel Partner'){
                            activeBookingsCount += 1;
                            salesValue += b.Agreement_Value_for_brokers__c;
                            if(b.Booking_Date__c >= fyStartDate && b.Booking_Date__c <= fyEndDate ){
                                salesValueCurrentYear += b.Agreement_Value_for_brokers__c;
                            }
                        }
                        
                        SalesDetail sd = new SalesDetail();
                        sd.bookingId = b.Name;
                        sd.customerName = (b.Opportunity__c != null) ? b.Opportunity__r.Name : null;
                        sd.projectName = (b.Project__c != null) ? b.Project__r.Name : null;
                        sd.tower = (b.Tower__c != null) ? b.Tower__r.Name : null;
                        sd.unitNo = (b.Unit_No__c != null) ? b.Unit_No__r.Name : null;
                        sd.unitType = (b.Unit_Type__c != null) ? b.Unit_Type__c : null;
                        // sd.bookingDate = Date.valueof(b.Booking_Date__c);
                        if(b.Booking_Date__c!=null){
                            DateTime dt = DateTime.newInstance(b.Booking_Date__c.year(), b.Booking_Date__c.month(), b.Booking_Date__c.day());
							sd.bookingDate = dt.format('dd-MM-yyyy');
                        }
                        sd.salesValue = b.Agreement_Value_for_brokers__c;
                        salesDetails.add(sd);
                    }
                    
                }
                
                ResponseWrapper res = new ResponseWrapper();
                res.summary = new Summary();
                res.summary.noOfActiveLeads = activeLeadsCount;
                res.summary.noOfWalkins = activeOppsCount;
                res.summary.totalBookings = activeBookingsCount;
                res.summary.salesValueCurrentYear = salesValueCurrentYear;
                res.salesDetails = salesDetails;
                
                //Assign Gross Brokerage Earned
                list<Brokerage_Invoice__c> invlist = [Select id,Booking__c,Invoice_Amount__c,Total_Amount_Paid__c,Brokerage_Lookup__r.Brokerage_Type__c,SAP_Document_No__c,
                                                      Customer_Name__c,Project__c,Total_Agreement_Value__c,Brokerage_In_Rs__c,Invoice_Date__c,Invoice_Number__c,Status__c,
                                                      Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Booking__r.Booking_Date__c,Booking__r.Name,Opportunity__r.Name,
                                                      Opportunity__c,Booking__r.Id                                       
                                                      from Brokerage_Invoice__c  where Channel_Partner__c =: cpId AND Booking__r.Booking_Date__c >=: startDate AND Booking__r.Booking_Date__c <=: endDate];
                
                if(!invlist.isEmpty()){
                    list<SummaryWrapper> slist = new list<SummaryWrapper>();
                    Decimal pendingPayout = 0;
                    Decimal totalBrokerageEarned = 0;
                    Integer invCount = 0;
                    res.summary.grossBrokerageEarned = new GrossBrokerageEarned();
                    for(Brokerage_Invoice__c inv : invlist){
                        invCount ++;
                        SummaryWrapper s = new SummaryWrapper();                        
                        s.bookingName = inv.Booking__r.Name;
                        s.customerName = (inv.Opportunity__c != null) ? inv.Opportunity__r.Name : null;
                        s.projectName = (inv.Project__c != null) ? inv.Project__c : null;
                        // s.bookingDate = Date.valueof(inv.Booking__r.Booking_Date__c);
                        if(inv.Booking__r.Booking_Date__c!=null){
                            DateTime dt = DateTime.newInstance(inv.Booking__r.Booking_Date__c.year(), inv.Booking__r.Booking_Date__c.month(), inv.Booking__r.Booking_Date__c.day());
                            s.bookingDate = dt.format('dd-MM-yyyy');
                        }
                        s.bookingId = (inv.Booking__r.Id != null && inv.Booking__c != null) ? inv.Booking__r.Id : null;
                        s.brokerageAmount = (inv.Invoice_Amount__c != null) ? inv.Invoice_Amount__c : 0;
                        if(inv.Status__c == 'Paid'){//Paid                    
                            s.payoutStatus = 'Paid';
                            totalBrokerageEarned += s.brokerageAmount;
                        }else{//Not Due
                            s.payoutStatus = 'Pending';
                            pendingPayout += s.brokerageAmount;
                        }
                        slist.add(s);
                    }
                    res.summary.grossBrokerageEarned.totalBrokerageEarned = totalBrokerageEarned;
                    res.summary.grossBrokerageEarned.noOfInvoices = invCount;
                    res.summary.grossBrokerageEarned.pendingPayout = pendingPayout;
                    res.summary.grossBrokerageEarned.brokerageDetails = slist;                    
                    
                } /*else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'No Brokerage Data Found');
                    resp.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    resp.statusCode = 400;
                }*/
                
                resp.responseBody = Blob.valueOf(JSON.serialize(res));
                resp.statusCode = 200;
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                resp.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                resp.statusCode = 400;
            }
        }
    }
    
    public static Map<String, Date> getFinancialsYearDates() {
        Date today = Date.today();
        Integer currentMonth = today.month();
        Integer currentYear = today.year();
        
        // If month is Jan, Feb, or Mar (1, 2, 3), the FY started in the previous calendar year
        Integer startYear = (currentMonth <= 3) ? currentYear - 1 : currentYear;
        
        Date fyStart = Date.newInstance(startYear, 4, 1);
        Date fyEnd = Date.newInstance(startYear + 1, 3, 31);
        
        return new Map<String, Date>{
            'start' => fyStart,
            'end' => fyEnd
        };
    }
    
    public class Summary {
        public Integer noOfActiveLeads;
        public Integer noOfWalkins;
        public Integer totalBookings;
        public Decimal salesValueCurrentYear;
        public GrossBrokerageEarned grossBrokerageEarned;        
        
    }
    
     public class SalesDetail {
        public String bookingId;
        public String customerName; 
        public String projectName;
        public String tower ;
        public String unitNo ;
        public String unitType ;
        public String bookingDate ;
        public Decimal salesValue;
    }
    
    global class ResponseWrapper {
        public Summary summary;
        public List<SalesDetail> salesDetails;
    }
    
    global class GrossBrokerageEarned {
        public decimal totalBrokerageEarned;
        public integer noOfInvoices;
        public decimal pendingPayout;
        public list<SummaryWrapper> brokerageDetails;         
    }
    
    public class SummaryWrapper{
        public String bookingName;
        public String customerName;
        public String projectName;
        public String bookingDate;
        public Decimal brokerageAmount = 0;
        public String payoutStatus;
        public String bookingId;
    }
    
    
    
}