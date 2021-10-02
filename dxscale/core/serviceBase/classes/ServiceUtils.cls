public class ServiceUtils {

    // ID generator configuration
    @TestVisible private static final Integer ID_RESERVED_CHARACTERS = 7;
    @TestVisible private static final Integer ID_INCREMENTER_PREFIX_LENGTH = 1;
    @TestVisible private static final String BASE62_ALPHABET = '0123456789abcdefghijklmnopqrstuvwqyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // Count of generated IDs, used as an incrementer in generateId()
    @TestVisible private static Integer idCount = 1;


    public static Id generateId() {
        // Salesforce IDs are 15-character Base62 strings. The first 7 characters will be the same for all IDs in the
        // same environment, while the last 8 characters will be an incremented identifier
        // (https://salesforce.stackexchange.com/questions/1653/what-are-salesforce-ids-composed-of)
        //
        // We'll use the current user's ID to determine the appropriate environment-specific characters. We'll set a
        // number of characters following the 7th to 'Z', to make collisions with system-generated IDs unlikely. We'll
        // then use a simple incrementing pattern to generate the remaining characters.

        // Get environment-specific ID prefix from user ID
        String envPrefix = UserInfo.getUserId().substring(0, ID_RESERVED_CHARACTERS);
        String incPrefix = ''.rightPad(ID_INCREMENTER_PREFIX_LENGTH, BASE62_ALPHABET.substring(BASE62_ALPHABET.length() - 1));

        // Generate incremented value
        Integer incrementLength = (15 - ID_RESERVED_CHARACTERS - ID_INCREMENTER_PREFIX_LENGTH);
        String increment = convertBase(idCount, 62, BASE62_ALPHABET).leftPad(incrementLength, '0');

        // Increment counter and build ID
        idCount++;
        return envPrefix + incPrefix + increment;
    }

    /**
     * Converts an integer value to a different numerical base, using a provided alphabet for representation.
     * @param value Value to convert
     * @param radix Numerical base to convert to
     * @param alphabet Sequential set of characters defining the alphabet used to represent the resulting value
     * @return The converted value
     */
    private static String convertBase(Integer value, Integer radix, String alphabet) {

        // Short circuit in case of 0
        if (value == 0) {
            return '0';
        }

        // Convert input number to given base by repeatedly dividing it by base and taking remainder
        String output = '';
        while (value > 0) {
            Integer charIndex = Math.mod(value, radix);
            output = alphabet.substring(charIndex, charIndex + 1) + output;
            value = value / radix;
        }

        return output;
    }

    public static String getMyDomain () {
        String hostURL = URL.getSalesforceBaseUrl().toExternalForm();
        return stripMyDomain(hostURL);
    }

    public static String stripMyDomain (String hostURL) {
        Integer firstDot = hostURL.indexOf('.');
        Integer lastDash = hostURL.lastIndexOf('/');
        String sReturn = hostURL.substring(lastDash + 1,firstDot);
        return sReturn;
    }

    public static String getHashBase16(String s) {
        Blob digest = Crypto.generateDigest('MD5', Blob.valueOf(s));   
        return EncodingUtil.convertToHex(digest); // return base 16
    } 

    public static String stripNonAlphas(String serviceInvocationName) {
        String stripped = '';
        for (Integer i = 0; i < serviceInvocationName.length(); i++) {
            if (serviceInvocationName.substring(i, i+1).isAlphanumeric()) {
                stripped += serviceInvocationName.substring(i, i+1);
            }
        }
        return stripped;
    }

    
}
