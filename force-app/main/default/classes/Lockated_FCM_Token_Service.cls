public class Lockated_FCM_Token_Service {

    // Named Credential API Name for Google's token endpoint
    private static final String GOOGLE_NAMED_CREDENTIAL = 'callout:Google_OAuth2_Token';
    private static String accessToken; // Cache the token

    /*public static String getAccessToken() {
        if (accessToken != null) {
            return accessToken; // Return cached token if available
        }
        
        // Get the JWT assertion from our generator class
        String jwtAssertion = Lockated_FCM_JWT_Generator.getJWTAssertion();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(GOOGLE_NAMED_CREDENTIAL + '/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=' + EncodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:jwt-bearer', 'UTF-8') + 
                      '&assertion=' + EncodingUtil.urlEncode(jwtAssertion, 'UTF-8');
        req.setBody(body);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                accessToken = (String) responseMap.get('access_token');
                return accessToken;
            } else {
                System.debug('Error getting access token: ' + res.getBody());
                throw new CalloutException('Failed to retrieve access token: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('An error occurred during token exchange: ' + e.getMessage());
            throw e;
        }
    }*/
    
    public static String getAccessToken1(String clientEmail, String privateKey, String scope) {
        String jwt = generateJWT(clientEmail, privateKey, scope);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth2.googleapis.com/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + jwt);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        } else {
            throw new CalloutException('Error getting access token: ' + res.getBody());
        }
    }
    
    public static String generateJWT(String clientEmail, String privateKey, String scope) {
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