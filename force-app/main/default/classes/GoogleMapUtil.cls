public class GoogleMapUtil {
    
    public static String generateMapLinkFromDMS(String dmsValue) {
        if(String.isBlank(dmsValue)) {
            return null;
        }
        
        // Split latitude and longitude
        List<String> parts = dmsValue.split(' ');
        
        Decimal latitude = convertDMSToDecimal(parts[0]);
        Decimal longitude = convertDMSToDecimal(parts[1]);
        
        return 'https://www.google.com/maps?q=' + latitude + ',' + longitude;
    }
    
    
    private static Decimal convertDMSToDecimal(String dms) {
        
        // Extract direction (N,S,E,W)
        String direction = dms.right(1);
        dms = dms.left(dms.length()-1);
        
        // Replace symbols with space
        dms = dms.replace('°',' ')
                 .replace('\'',' ')
                 .replace('"',' ');
        
        List<String> values = dms.split(' ');
        
        Decimal degrees = Decimal.valueOf(values[0]);
        Decimal minutes = Decimal.valueOf(values[1]);
        Decimal seconds = Decimal.valueOf(values[2]);
        
        Decimal decimalValue = degrees + (minutes/60) + (seconds/3600);
        
        // If South or West → make negative
        if(direction == 'S' || direction == 'W'){
            decimalValue = decimalValue * -1;
        }
        
        return decimalValue.setScale(6);
    }
}