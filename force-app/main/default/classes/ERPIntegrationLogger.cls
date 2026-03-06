public with sharing class ERPIntegrationLogger {

    // =====================================================
    // MAIN LOG METHOD (Standard Usage)
    // =====================================================
    public static void log(
        String className,
        String methodName,
        String apiName,
        String bookingId,
        String externalId,
        String request,
        String response,
        String status,
        String errorType,
        String errorMessage
    ){
        log(className, methodName, apiName, bookingId, externalId,
            request, response, status, errorType, errorMessage,
            null, null, null);
    }


    // =====================================================
    // ADVANCED LOG METHOD (With Extra Tracking)
    // =====================================================
    public static void log(
        String className,
        String methodName,
        String apiName,
        String bookingId,
        String externalId,
        String request,
        String response,
        String status,
        String errorType,
        String errorMessage,
        Integer httpStatusCode,
        Integer retryCount,
        Long executionTimeMs
    ){
        try {

            ERP_Integration_Log__c logRec = new ERP_Integration_Log__c();

            // 🔹 Core Info
            logRec.API_Name__c     = apiName;
            logRec.Booking__c      = bookingId;
            logRec.External_Id__c  = externalId;
            logRec.Status__c       = status;

            // 🔹 Class + Method Trace
            logRec.StatusTxt__c    = className + '.' + methodName;

            // 🔹 Request / Response (Safe Length)
            logRec.Request__c  = safeString(request);
            logRec.Response__c = safeString(response);

            // 🔹 Error Info
            logRec.Error_Type__c   = safeString(errorType);
            logRec.Error_Reason__c = buildErrorMessage(errorMessage, httpStatusCode, executionTimeMs);

            // 🔹 Retry Support
            if(retryCount != null){
                logRec.Retry_Count__c = retryCount;
            }

            insert logRec;

        } catch (Exception e) {
            System.debug('ERP Log Insert Failed: ' + e.getMessage());
        }
    }


    // =====================================================
    // SAFE STRING HANDLER (Prevents 131k char errors)
    // =====================================================
    private static String safeString(String input){
        if(String.isBlank(input)) return null;
        return input.length() > 130000 ? input.substring(0,130000) : input;
    }


    // =====================================================
    // BUILD ERROR MESSAGE WITH EXTRA DETAILS
    // =====================================================
    private static String buildErrorMessage(String errorMessage,
                                            Integer httpStatus,
                                            Long executionTimeMs){

        String finalMsg = errorMessage;

        if(httpStatus != null){
            finalMsg = (finalMsg != null ? finalMsg : '') +
                       ' | HTTP_CODE: ' + httpStatus;
        }

        if(executionTimeMs != null){
            finalMsg = (finalMsg != null ? finalMsg : '') +
                       ' | EXEC_TIME_MS: ' + executionTimeMs;
        }

        return safeString(finalMsg);
    }

}