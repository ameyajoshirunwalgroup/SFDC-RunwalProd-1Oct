@RestResource(urlMapping='/cpGetBaseLadderProgress/*')
global with sharing class Lockated_CPGetBaseLadderProgress {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        String cpId = req.params.get('cpId');
        if (String.isBlank(cpId)) {
            sendResponse(res, 400, new Map<String, String>{'status' => 'error', 'message' => 'Please pass valid CP Id'});
            return;
        }

        try {
            Map<String, Date> fyDates = getFinancialsYearDates();
            Date startDate = fyDates.get('start');
            Date endDate = fyDates.get('end');
            
            String cutOffString = System.Label.Base_Brokerage_Cut_off_Date;
			Date cutOffDate = Date.valueOf(cutOffString);
            
            List<CP_Brokerage__c> brokerageRecords = [
                SELECT Id, Total_Brokerage__c, Total_Amount_Balance__c, Project__c, Booking__r.Booking_Date__c, Brokerage__c, Total_Invoice_Amount__c  
                FROM CP_Brokerage__c
                WHERE Brokerage_Type__c = 'Base Brokerage' AND Channel_Partner__c = :cpId 
                AND Booking__r.Booking_Date__c >= :startDate 
                AND Booking__r.Booking_Date__c <= :endDate
            ];
            
            List<Brokerage_Invoice__c> brokerageInvoicesRecords = [
                SELECT Id, Brokerage_In_Rs__c, Total_Amount_Balance__c, Project__c, Booking__r.Booking_Date__c, Brokerage__c, Invoice_Amount__c  
                FROM Brokerage_Invoice__c
                WHERE Brokerage_Lookup__r.Brokerage_Type__c ='Base Brokerage' AND Channel_Partner__c = :cpId 
                AND Booking__r.Booking_Date__c >= :startDate 
                AND Booking__r.Booking_Date__c <= :endDate
                AND CreatedDate <=: cutOffDate
            ];

            if (brokerageRecords.isEmpty() && brokerageInvoicesRecords.isEmpty()) {
                sendResponse(res, 404, new Map<String, String>{'status' => 'error', 'message' => 'No data found'});
                return;
            }

            ResponseWrapper response = processData(brokerageRecords,brokerageInvoicesRecords);
            sendResponse(res, 200, response);

        } catch (Exception ex) {
            sendResponse(res, 500, new Map<String, String>{'status' => 'error', 'message' => ex.getMessage()});
        }
    }

    public static ResponseWrapper processData(List<CP_Brokerage__c> cpBrokerageInvoices,List<Brokerage_Invoice__c> brokerageInvoicesRecords) {
        ResponseWrapper rw = new ResponseWrapper();
        Map<String, ProjectData> projectMap = new Map<String, ProjectData>();
        Decimal globalInvoiceSum = 0;
        
        if(!cpBrokerageInvoices.isEmpty()){
            for (CP_Brokerage__c rec : cpBrokerageInvoices) {
                rw.totalNoOfBookings++;
                rw.totalbrokerage += (rec.Total_Invoice_Amount__c  != null) ? rec.Total_Invoice_Amount__c  : (rec.Total_Brokerage__c != null) ? rec.Total_Brokerage__c : 0;
                rw.brokeragePending += (rec.Total_Amount_Balance__c != null) ? rec.Total_Amount_Balance__c : 0;
                // Track which projects this specific booking has already contributed to
                // to avoid double-counting the same booking for the same project
                Set<String> processedProjectsForThisRecord = new Set<String>();
                
                globalInvoiceSum += (rec.Brokerage__c != null) ? rec.Brokerage__c : 0;
    
                if (!projectMap.containsKey(rec.Project__c)) {
                    projectMap.put(rec.Project__c, new ProjectData(rec.Project__c));
                }
                
                ProjectData pd = projectMap.get(rec.Project__c);
                pd.tempInvoiceSum += (rec.Brokerage__c != null) ? rec.Brokerage__c : 0;
                
                // Only add parent totals to the project summary ONCE per unique booking/project combo
                if (!processedProjectsForThisRecord.contains(rec.Project__c)) {
                    pd.projectSummary.noOfBookings++;
                    pd.projectSummary.totalbrokerage += (rec.Total_Invoice_Amount__c  != null) ? rec.Total_Invoice_Amount__c  : (rec.Total_Brokerage__c != null) ? rec.Total_Brokerage__c : 0;
                    pd.projectSummary.brokeragePending += (rec.Total_Amount_Balance__c != null) ? rec.Total_Amount_Balance__c : 0;
                    processedProjectsForThisRecord.add(rec.Project__c);
                }
            }
        }
        
        if(!brokerageInvoicesRecords.isEmpty()){
            for (Brokerage_Invoice__c rec : brokerageInvoicesRecords) {
                rw.totalNoOfBookings++;
                rw.totalbrokerage += (rec.Invoice_Amount__c != null) ? rec.Invoice_Amount__c : (rec.Brokerage_In_Rs__c!=null) ? rec.Brokerage_In_Rs__c : 0;
                rw.brokeragePending += (rec.Total_Amount_Balance__c != null) ? rec.Total_Amount_Balance__c : 0;
                // Track which projects this specific booking has already contributed to
                // to avoid double-counting the same booking for the same project
                Set<String> processedProjectsForThisRecord = new Set<String>();
                
                globalInvoiceSum += (rec.Brokerage__c != null) ? rec.Brokerage__c : 0;
    
                if (!projectMap.containsKey(rec.Project__c)) {
                    projectMap.put(rec.Project__c, new ProjectData(rec.Project__c));
                }
                
                ProjectData pd = projectMap.get(rec.Project__c);
                pd.tempInvoiceSum += (rec.Brokerage__c != null) ? rec.Brokerage__c : 0;
                
                // Only add parent totals to the project summary ONCE per unique booking/project combo
                if (!processedProjectsForThisRecord.contains(rec.Project__c)) {
                    pd.projectSummary.noOfBookings++;
                    pd.projectSummary.totalbrokerage +=(rec.Invoice_Amount__c != null) ? rec.Invoice_Amount__c : (rec.Brokerage_In_Rs__c!=null) ? rec.Brokerage_In_Rs__c : 0;
                    pd.projectSummary.brokeragePending += (rec.Total_Amount_Balance__c != null) ? rec.Total_Amount_Balance__c : 0;
                    processedProjectsForThisRecord.add(rec.Project__c);
                }
            }
        }

        // Finalize Averages
        if (rw.totalNoOfBookings > 0) {
            rw.brokerage = (globalInvoiceSum / rw.totalNoOfBookings).setScale(0, System.RoundingMode.HALF_UP);
        }

        for (ProjectData pd : projectMap.values()) {
            if (pd.projectSummary.noOfBookings > 0) {
                pd.projectSummary.brokerage = (pd.tempInvoiceSum / pd.projectSummary.noOfBookings).setScale(0, System.RoundingMode.HALF_UP);
            }
            rw.projectDetails.add(pd);
        }

        return rw;
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

    private static void sendResponse(RestResponse res, Integer code, Object body) {
        res.statusCode = code;
        res.responseBody = Blob.valueOf(JSON.serialize(body));
    }

    // --- Optimized Wrapper Structure ---
    public class ResponseWrapper {
        public Integer totalNoOfBookings = 0;
        public Decimal brokerage = 0;
        public Decimal totalbrokerage = 0;
        public Decimal brokeragePending = 0;
        public List<ProjectData> projectDetails = new List<ProjectData>();
    }

    public class ProjectData {
        public String projectName;
        public SummaryMetrics projectSummary;
        @testVisible private Decimal tempInvoiceSum = 0;

        public ProjectData(String name) {
            this.projectName = name;
            this.projectSummary = new SummaryMetrics();
        }
    }

    public class SummaryMetrics {
        public Integer noOfBookings = 0;
        public Decimal brokerage = 0;
        public Decimal totalbrokerage = 0;
        public Decimal brokeragePending = 0;
    }
}