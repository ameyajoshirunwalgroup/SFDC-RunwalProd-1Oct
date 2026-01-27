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
            List<CP_Brokerage__c> brokerageRecords = [
                SELECT Id, Total_Brokerage__c, Total_Amount_Balance__c,
                       (SELECT Id, Brokerage__c, Project__c FROM Brokerage_Invoices__r WHERE Project__c != null) 
                FROM CP_Brokerage__c
                WHERE Brokerage_Type__c = 'Base Brokerage' AND Channel_Partner__c = :cpId
            ];

            if (brokerageRecords.isEmpty()) {
                sendResponse(res, 404, new Map<String, String>{'status' => 'error', 'message' => 'No data found'});
                return;
            }

            ResponseWrapper response = processData(brokerageRecords);
            sendResponse(res, 200, response);

        } catch (Exception ex) {
            sendResponse(res, 500, new Map<String, String>{'status' => 'error', 'message' => ex.getMessage()});
        }
    }

    public static ResponseWrapper processData(List<CP_Brokerage__c> records) {
        ResponseWrapper rw = new ResponseWrapper();
        Map<String, ProjectData> projectMap = new Map<String, ProjectData>();
        Decimal globalInvoiceSum = 0;

        for (CP_Brokerage__c rec : records) {
            rw.totalNoOfBookings++;
            rw.totalbrokerage += (rec.Total_Brokerage__c != null) ? rec.Total_Brokerage__c : 0;
            rw.brokeragePending += (rec.Total_Amount_Balance__c != null) ? rec.Total_Amount_Balance__c : 0;

            // Track which projects this specific booking has already contributed to
            // to avoid double-counting the same booking for the same project
            Set<String> processedProjectsForThisRecord = new Set<String>();

            for (Brokerage_Invoice__c inv : rec.Brokerage_Invoices__r) {
                globalInvoiceSum += (inv.Brokerage__c != null) ? inv.Brokerage__c : 0;

                if (!projectMap.containsKey(inv.Project__c)) {
                    projectMap.put(inv.Project__c, new ProjectData(inv.Project__c));
                }

                ProjectData pd = projectMap.get(inv.Project__c);
                pd.tempInvoiceSum += (inv.Brokerage__c != null) ? inv.Brokerage__c : 0;

                // Only add parent totals to the project summary ONCE per unique booking/project combo
                if (!processedProjectsForThisRecord.contains(inv.Project__c)) {
                    pd.projectSummary.noOfBookings++;
                    pd.projectSummary.totalbrokerage += (rec.Total_Brokerage__c != null) ? rec.Total_Brokerage__c : 0;
                    pd.projectSummary.brokeragePending += (rec.Total_Amount_Balance__c != null) ? rec.Total_Amount_Balance__c : 0;
                    processedProjectsForThisRecord.add(inv.Project__c);
                }
            }
        }

        // Finalize Averages
        if (rw.totalNoOfBookings > 0) {
            rw.brokerage = globalInvoiceSum / rw.totalNoOfBookings;
        }

        for (ProjectData pd : projectMap.values()) {
            if (pd.projectSummary.noOfBookings > 0) {
                pd.projectSummary.brokerage = pd.tempInvoiceSum / pd.projectSummary.noOfBookings;
            }
            rw.projectDetails.add(pd);
        }

        return rw;
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