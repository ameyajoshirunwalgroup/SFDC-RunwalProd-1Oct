public with sharing class BillDeskStatusService {

    /**
     * Fetch full response from BillDesk Retrieve API
     */
    public static Map<String,Object> fetchFullResponse(String orderId, String merchantId) {

        Map<String,Object> result = new Map<String,Object>();
        String rawResponse;

        try {

            // ==============================
            // 🔹 Input Validation
            // ==============================
            if (String.isBlank(orderId) || String.isBlank(merchantId)) {
                throw new AuraHandledException('OrderId or MerchantId is missing');
            }

            // ==============================
            // 🔹 Fetch Gateway Configuration
            // ==============================
            List<Payment_Gateway__mdt> gatewayList = [
                SELECT Client_Id__c, Secret_Key__c
                FROM Payment_Gateway__mdt
                WHERE Parent_Merchant_Id__c = :merchantId
                LIMIT 1
            ];

            if (gatewayList.isEmpty()) {
                throw new AuraHandledException('Payment Gateway configuration not found');
            }

            Payment_Gateway__mdt gateway = gatewayList[0];

            // ==============================
            // 🔹 Call Common Service
            // ==============================
            BillDeskCommonService.ResponseWrapper resWrap =
                BillDeskCommonService.hitRetrieveAPI(
                    orderId,
                    merchantId,
                    gateway.Client_Id__c,
                    gateway.Secret_Key__c
                );

            rawResponse = resWrap.rawResponse;
            String decoded = resWrap.decodedResponse;

            System.debug('decoded------------>' + decoded);

            // ==============================
            // 🔹 Safe JSON Parsing
            // ==============================
            Map<String,Object> responseMap = new Map<String,Object>();

            if (!String.isBlank(decoded)) {
                responseMap =
                    (Map<String,Object>) JSON.deserializeUntyped(decoded);
            }

            // ==============================
            // 🔹 Prepare Response
            // ==============================
            result.put('decodedResponse', decoded);
            result.put('statusCode', resWrap.statusCode);
            result.put('body', responseMap);

            // ==============================
            // 🔹 ERP SUCCESS LOG
            // ==============================
            ERPIntegrationLogger.log(
                'BillDeskStatusService',
                'fetchFullResponse',
                'BillDesk Retrieve API',
                null,
                orderId,
                orderId,
                decoded,
                'SUCCESS',
                null,
                null
            );

            return result;

        } catch (Exception e) {

            // ==============================
            // 🔹 ERP ERROR LOG
            // ==============================
            ERPIntegrationLogger.log(
                'BillDeskStatusService',
                'fetchFullResponse',
                'BillDesk Retrieve API',
                null,
                orderId,
                orderId,
                rawResponse,
                'FAIL',
                'SYSTEM_EXCEPTION',
                e.getMessage()
            );

            result.put('statusCode', 500);
            result.put('error', e.getMessage());
            return result;
        }
    }
}