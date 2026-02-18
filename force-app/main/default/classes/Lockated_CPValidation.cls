@RestResource(urlMapping='/cpValidation/*')
global class Lockated_CPValidation {

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Always set the content type so the client knows it's receiving JSON
        res.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> response = new Map<String, Object>();

        try {
            // 1. Handle Empty Request Body
            if (req.requestBody == null) {
                res.statusCode = 400;
                response.put('status', 'error');
                response.put('message', 'Request body is empty');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                return;
            }

            String jsonBody = req.requestBody.toString();
            
            // 2. Safe Deserialization
            cpRegistrationWrapper data = (cpRegistrationWrapper) JSON.deserialize(jsonBody, cpRegistrationWrapper.class);

            // 3. Check if we have any data to validate to avoid unnecessary queries
            if (String.isBlank(data.email) && String.isBlank(data.panNo) && String.isBlank(data.phone)) {
                res.statusCode = 400; // Bad Request
                response.put('status', 'error');
                response.put('message', 'Please provide at least one field (Email, Pan, or Phone) to validate.');
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                return;
            }

            // 4. Secure Query using Bind Variables
            // We ensure we only match against non-null input values
            List<Broker__c> existing = [
                SELECT Id 
                FROM Broker__c 
                WHERE (RW_Email__c = :data.email AND RW_Email__c != NULL) 
                   OR (Broker_Pan_No__c = :data.panNo AND Broker_Pan_No__c != NULL) 
                   OR (RW_Mobile_No__c = :data.phone AND RW_Mobile_No__c != NULL)
                LIMIT 1
            ];
            
            // 5. Construct Response
            if (!existing.isEmpty()) {
                // Duplicate found
                res.statusCode = 200; // OK, but business logic validation failed
                response.put('status', 'error');
                response.put('message', 'Partner already exists with this Email, PAN, or Mobile.');
                response.put('existingId', existing[0].Id); // Optional: Help the frontend know which ID caused the conflict
            } else {
                // No duplicate found
                res.statusCode = 200;
                response.put('status', 'success');
                response.put('message', 'Validation passed. No duplicates found.');
            }

        } catch (Exception e) {
            // 6. Global Exception Handling
            res.statusCode = 500;
            response.put('status', 'error');
            response.put('message', 'Internal Server Error: ' + e.getMessage());
        }

        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    public class cpRegistrationWrapper {
        public String email;
        public String phone;
        public String panNo;
    }
}