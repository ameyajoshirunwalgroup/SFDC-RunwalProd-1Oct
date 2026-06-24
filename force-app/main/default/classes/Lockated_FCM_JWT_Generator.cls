public with sharing class Lockated_FCM_JWT_Generator {

    private static final String GOOGLE_TOKEN_URI = 'https://oauth2.googleapis.com/token';
    private static final String FIREBASE_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';
    private static String cachedAccessToken;
    private static Long tokenExpirationTime;

    // Method to get a valid access token, generating a new one if expired
    public static String getAccessToken() {
        if (cachedAccessToken != null && tokenExpirationTime > Datetime.now().getTime()) {
            return cachedAccessToken;
        }

        try {
            Lockated_FCM_Credentials__mdt credentials = [
                SELECT Client_Email__c, Private_Key__c 
                FROM Lockated_FCM_Credentials__mdt 
                LIMIT 1
            ];
			System.debug('credentials: ' + credentials);
            Auth.JWT jwt = new Auth.JWT();
            jwt.setIss(credentials.Client_Email__c);
            jwt.setAud(GOOGLE_TOKEN_URI);
            jwt.setSub(credentials.Client_Email__c);
            
			System.debug('jwt: ' + jwt);
            
            Map<String, Object> additionalClaims = new Map<String, Object>();
            additionalClaims.put('scope', FIREBASE_SCOPE);
            jwt.setAdditionalClaims(additionalClaims);

            jwt.setValidityLength(3600); // Token valid for 1 hour

            Auth.JWS jws = new Auth.JWS(jwt, credentials.Private_Key__c);
            System.debug('jws: ' + jws);
            String jwtAssertion = jws.getCompactSerialization();
            System.debug('jwtAssertion: ' + jwtAssertion);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(GOOGLE_TOKEN_URI);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

            String requestBody = 'grant_type=' + EncodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:jwt-bearer', 'UTF-8') + 
                                 '&assertion=' + EncodingUtil.urlEncode(jwtAssertion, 'UTF-8');
            req.setBody(requestBody);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                cachedAccessToken = (String) responseMap.get('access_token');
                tokenExpirationTime = Datetime.now().addSeconds(Integer.valueOf(responseMap.get('expires_in')) - 300).getTime(); // Cache for a bit less than expiration
                return cachedAccessToken;
            } else {
                throw new CalloutException('Failed to retrieve access token: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new CalloutException('An error occurred during token exchange: ' + e.getMessage());
        }
    }
    
    
    // Helper method to convert standard Base64 to Base64 URL-Safe
    private static String base64URLencode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.substring(0, output.length() - 1);
        }
        return output;
    }

    // Helper method to convert Base64 URL-Safe to standard Base64 and decode
    public static Blob base64URLdecode(String input) {
        String output = input.replace('-', '+').replace('_', '/');
        switch on Math.mod(output.length(), 4) {
            when 2 {
                output += '==';
            }
            when 3 {
                output += '=';
            }
        }
        return EncodingUtil.base64Decode(output);
    }

    public static String generateJWT(String firebaseClientEmail, String firebasePrivateKey) {
        // Step 1: Create JWT Header and Claims as Maps
        Map<String, String> header = new Map<String, String>();
        header.put('alg', 'RS256');
        header.put('typ', 'JWT');

        Map<String, Object> claims = new Map<String, Object>();
        claims.put('iss', firebaseClientEmail);
        claims.put('scope', 'https://www.googleapis.com/auth/firebase.messaging');
        claims.put('aud', 'https://oauth2.googleapis.com/token');
        claims.put('exp', (DateTime.now().addHours(1)).getTime() / 1000); // 1 hour expiration
        claims.put('iat', DateTime.now().getTime() / 1000);

        // Step 2: Serialize the Maps to JSON Strings
        // This is the crucial step to fix the error.
        String headerJson = JSON.serialize(header);
        String claimsJson = JSON.serialize(claims);
        
        // Step 3: Base64 URL-Safe encode the JSON strings
        String encodedHeader = base64URLencode(Blob.valueOf(headerJson));
        String encodedClaims = base64URLencode(Blob.valueOf(claimsJson));
        String unsignedToken = encodedHeader + '.' + encodedClaims;

        // Step 4: Sign the token
        Blob privateKeyBlob = EncodingUtil.base64Decode(firebasePrivateKey);
        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(unsignedToken), privateKeyBlob);
        String encodedSignature = base64URLencode(signature);

        // Step 5: Construct the final JWT
        return unsignedToken + '.' + encodedSignature;
    }
    
    
    public static String generateJWT1(String clientEmail, String privateKey, String scope) {
        Long now = DateTime.now().getTime() / 1000;
        Long exp = now + 3600; // 1 hour

        // Header
        String header = '{"alg":"RS256","typ":"JWT"}';
        String encodedHeader = encode(Blob.valueOf(header));

        // Claim Set
        Map<String, Object> claimSet = new Map<String, Object>{
            'iss' => clientEmail,
            'scope' => scope,
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => now,
            'exp' => exp
        };
        String claimJson = JSON.serialize(claimSet);
        String encodedClaim = encode(Blob.valueOf(claimJson));

        String unsignedToken = encodedHeader + '.' + encodedClaim;

        // Use PKCS#1 key
        Blob privateKeyBlob = EncodingUtil.base64Decode(
            privateKey.replace('-----BEGIN RSA PRIVATE KEY-----', '')
                      .replace('-----END RSA PRIVATE KEY-----', '')
                      .replaceAll('\\s','')
        );

        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(unsignedToken), privateKeyBlob);
        String encodedSignature = encode(signature);

        return unsignedToken + '.' + encodedSignature;
    }
    
    public static String encode(Blob input) {
        String b64 = EncodingUtil.base64Encode(input);
        return b64.replace('+','-').replace('/','_').replaceAll('=','');
    }
}