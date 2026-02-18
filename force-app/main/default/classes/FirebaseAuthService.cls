public class FirebaseAuthService {

    // Replace these with your actual Firebase service account values
    /*private static final String CLIENT_EMAIL = 'firebase-adminsdk-fbsvc@testfcm-dfc7d.iam.gserviceaccount.com';
    private static final String PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCcZKZL8e4+yHrg\nvl6KXjxbTxBrM3JI5q09RmfplkOBvXXuNmTFyQL4k5wOai0dSmr8zKZXPG/cIRK9\no/t2oVeIFxSbcc+fH2mcS7YCePsEZd4rol6DA9sJZ51Tts2bsrb3UqzT9McukGbz\nHoG/VNJFImFCf68xTXlnHsXHEzoocdqVoC05bjSk7zqaNdPNjySf05Ux5ggEgsEn\nwzTek9IHuMNTwWDCJjkEiy1iUmBlc2WmzGgUisTesapdSVka12W+QvpcXgLwao3M\npHHm3K879Y4CbJwnW2GfRukNTHt8QlJVw5Hf6TFgv44sW8oirpGKnhgueSTeGOdc\nsW3qLSn1AgMBAAECggEACs53oTrL5CG1P+9XmAcP851AfK/W30u1P80sI/timcXu\nLrIqf3I21tdYSrSyflokj2hSvCdscVEFuv3oQ9e9NSWnImCYYJ3qjca7gms6qSCi\n2/AByNrM2VcEC4NPrMkKFIftck3xL3oB6x26CG8DgoxwHQi2odkBIQuCzhE5jQ7J\nR6N5xHwUd72V8VUS1t/JJH75JOFdAfv1HsfEe8VhxSRhe5Gk/DXvX6cbMxJ4zP5e\nvRur1GS1Fmv5lDLKlNyjiPfyFxru8Kv5uWNFQrJ/yOWrCiMsq9iAjd1gKyIIvtN5\n3i8fmwx3HFbEj92QNp715wI6/wi7+/GV3t6t4Q0rxwKBgQDQR11p/ARN3TLnd/EE\no1eq3jo+xrqOCu1RYbBnB+u0vJ19d6KOnqcekX1qa7AWV3hLDynUkPel2buGADyT\niz0eAHOHOElrTQsaTP20TWDPGp8BSO1XG+OsSHp8XuJwyO85mOEiJKj/2Tqdcqu4\ntQvlal41c6+nXBVulxTBLFFf1wKBgQDAOexqxXa8lw8+wlXCQCTDULNG/nXn2e2s\n5f3Q8g2ys/2zP/mXm/CkCmNUUoseaixNBOLTurfsgHMafTHsyOJc5/vEQoVebEnO\nREQV/MQCiP117OZdUts1VRtIgEYJ3ETIii1EVZN0VOccnTBqvJIp/mFLjRjbypEm\nCqIk6ce7EwKBgQC3ysH8DJAfxdptt8HPvfRWq9PqIaPuRGY3MmVgBfVRgD/ZwACK\nqiX/K5PonS6+CGH2mmLnWSWwDPsVvI+4A17jYrKP2HOxZEMv6lDXEpEjMPKvR5Np\nEwtNtIehyHk53ZZ81ROV9ZPMcfzvg4lVbS4aPEr2ECgpH3EqLdf6vwjv8QKBgQCg\nh/8bT9sQNitCIzNRbRYGkv+VO26l+IaXzN7CP1MXOV+W8cd0SIOXyyEWy3RpKwvi\nKkFvxtBQzxjRN1qZP05jfkzwowkUSOT+QF6H6jabU2IwuG3N5CMzD+cgDhfvpic/\nPr39AmaJUVpMuC02BlMehNUmLihjbXD4TwsIPsBRRwKBgG2HUOC0SjVwGgHo24Ki\nfcqVw4fLQipMwDJeVkRNKeLOvh4rvja0yrY3zNuskLNAGteNOdIIQRzc3W1FUya0\nj3uToPFZoNzes1+4e4XxKqldXaSBPhi8kBZ+OTsYpsfT6V9/VJvXL+SVXgWylGWM\njHE3iKdXy8an6AKk/Lvk8qKv\n-----END PRIVATE KEY-----\n';
    public static final String PROJECT_ID = 'testfcm-dfc7d';*/

    private static final String CLIENT_EMAIL = 'firebase-adminsdk-jyl3k@runwal-8fc5c.iam.gserviceaccount.com';
    private static final String PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCcQUidbviOz7wA\nDNVNaBseRu0fyF87I+PoAn2oOnaA01XD5vOAel82hqiQyIxKQKcdPMj8bDR394IA\n4It+IyfEbcC/MptpL4cUUyc7DehwoyJotNexgb+ute1tPMLA/JJ2rdcst1RT6+xX\nzmafcvvEUyzsNPjQfBUCXMZKjSTy6RWLi+ZYwsyY3it6/p+wTFcZxiWJeVfsKLOv\nlwN49yv6dc72eoTfL5+0We6GacfYjBKiCfKyQazbAjBgiRPo2dr82IBBPmWlrDSg\nKg3dbPUFybvZc0d7IwJfg/gf/R2Q/mzqtqapjmGwBNPhjssBa4+5iEDCF8cb2kdp\nUbCrtU+ZAgMBAAECggEAAfokflN5Yys3PIPtDgPvdehdVz3ckJ3BZD3l06NbvQEP\nkIFDWwCRZFn7V4umFMlxI+JRQ7plxo/T7glpUnEE74wY+IJeK4xNqADuWeWw5330\n8UC6ivUylPYZ2Tw/1ZvMiaJk+tyd/UrarHjA3SsiCuenhZyc+lxbkrJUUvyqt0Ud\nMAgf9uugWbyS0fJEND4mgWo5gl0AUMLYcvrLs8sC7pk5WK4HBHcRWD/fiPsIYd3h\njmJ88vl043Vg9a6qWuy8+m3RDVUOWMiw1DAaJY+u1482J1aa+613LadhiCDOadHN\nCDZWwu8aYzeTz4quX06eAYuMxCTfSqKVLwpR1UiXFQKBgQDLRiRZ2MSdFQ2v9KFg\nwX0htRkoDb/a0lhNJluOXWx7J6o5F5to9gu/ihjw8FIKB1murUtc5ZKfRtxooaJW\nk1mrLT4NS4k+VVpPdlLsEQhHHSYobmbyVJ2PtWBI7+wTszHDR4JE/1+Px6smMYsr\n4B+sFap80okSE1Mvsq/KlNIvtQKBgQDEyPlW7KG4PV/I7a3Zv9pSn6VfePFjPgnB\nlUYNRoqLR+dPNIBF+aFFjnDoVIwrIevL1T36/eAafmDFBo+ryWS9xGYNCeUaZa/J\nQy0VFztDtsPsxmyhAaVd8apNjfcYB0FTHeFsTuxFMK1UvdTgz/QyAMWDM1q1fn6o\nsXXefnvm1QKBgAcOaUahKroVOANqp4t3TAO2iKgGSimrcZtEAJuhjJl91//hXOi4\n2dGNVq5OeVqVxLw2kc4ovf0/dXlAWyVMOimiCWxmud3rEpZ9kgVV1ga58VAn/PTe\nkRWjAzOk+Hn6l3ii69e/Ua7pDHzn7V/ZiN/tZJyupkl1WEbomgebQOydAoGAdai4\ntMl9lFxV9hxuk0CL+FTuGxyEL9N7H9zx6qQf2FFgs1Hv1GcCj0UwqylKOcvpYZGZ\nooXDRfQERim7I3qiGnjgj7E348WjClJ5FSAz1jPkB6FIeCg0yOvi6MYWVK6Z12mJ\nTCoQSPpm2ME8FEMiffdKIT1GYjhE4PZiRGsaCBUCgYBhWn1V5W3CWWlR4BgJFpZf\nZ5bEMxeqXnUSG+T8BAK/clLtCifQYoEh1iwYPgplxnGjnRBSRwNJFGyJtPk0mTCV\nbAUwZOgUkog8LmUXh0eOCPcL7HY/EbvAbnKhg8e9Caao0hUbV8KplrMol1ru8iVW\n0VTVRjBEGGHObNiOOJ3Pzg==\n-----END PRIVATE KEY-----\n';
    public static final String PROJECT_ID = 'runwal-8fc5c';

    // Get Firebase Access Token
    public static String getAccessToken() {
        try {
            // 1️⃣ Build JWT header
            Map<String, Object> header = new Map<String, Object>{
                'alg' => 'RS256',
                'typ' => 'JWT'
            };

            // 2️⃣ Build JWT claim
            Long now = DateTime.now().getTime() / 1000;
            Map<String, Object> claim = new Map<String, Object>{
                'iss' => CLIENT_EMAIL,
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => now,
                'exp' => now + 3600
            };

            // 3️⃣ Encode Header & Claim
            String encodedHeader = base64UrlEncode(JSON.serialize(header));
            String encodedClaim  = base64UrlEncode(JSON.serialize(claim));
            String unsignedJWT = encodedHeader + '.' + encodedClaim;

            // 4️⃣ Sign JWT using private key
            String pk = PRIVATE_KEY
                        .replace('-----BEGIN PRIVATE KEY-----','')
                        .replace('-----END PRIVATE KEY-----','')
                        .replace('\n','')
                        .replace('\r','');

            Blob keyBlob = EncodingUtil.base64Decode(pk);
            Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(unsignedJWT), keyBlob);
            String signedJWT = unsignedJWT + '.' + base64UrlEncode(signature);

            // 5️⃣ Request access token
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://oauth2.googleapis.com/token');
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setBody('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' + signedJWT);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == 200){
                Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                return (String)result.get('access_token');
            } else {
                System.debug('Error getting access token: ' + res.getBody());
                return null;
            }

        } catch(Exception ex){
            System.debug('Exception: ' + ex.getMessage());
            return null;
        }
    }

    // Helper method: Base64 URL encode
    private static String base64UrlEncode(String input) {
        Blob b = Blob.valueOf(input);
        String encoded = EncodingUtil.base64Encode(b);
        // Convert to Base64 URL safe
        return encoded.replace('+','-').replace('/','_').replace('=','');
    }

    private static String base64UrlEncode(Blob input) {
        String encoded = EncodingUtil.base64Encode(input);
        return encoded.replace('+','-').replace('/','_').replace('=','');
    }
}