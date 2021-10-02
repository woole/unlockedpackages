
/**
 * Common validation menthods
 */
public without sharing class ValidatorUtils {

    // public static final String GLOBAL_ID = 'GlobalID';
    // public static final String RECORD_ID = 'RecordID';
    // public static final String INVALID_ID = 'InvalidID';
    public enum IDTYPE {
        GlobalID,RecordID,InvalidID
    }

    public static Boolean validateEmail(String email) {
        //final String EMAIL_PATTERN = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        final String EMAIL_PATTERN = '^[\\p{L}0-9\\._|\\\\%#~`=?&/$^*!}{+-]+@[\\p{L}0-9\\.-]+\\.[a-zA-Z]{2,15}$'; // was 4 not 9
        return validate(EMAIL_PATTERN, email);
    }
    
    public static Boolean validateLocale(String locale){
        final String LOCALE_PATTERN = '^[a-z]{2}?_[a-zA-Z]{2}';
        return validate(LOCALE_PATTERN, locale);
    }

    public static Boolean validateSpecialChar(String value){
        //final String CHAR_PATTERN = '^[a-zA-Z0-9 /@.()#>-]*$';
        //updated to allow graphemes like é
        final String CHAR_PATTERN = '^[\\p{L}0-9\\. \'-/@()#>&]+$';
        return validate(CHAR_PATTERN, value);
    }

    public static Boolean validateCurrency(String value){
        final String CURR_PATTERN = '^[a-zA-Z]{3}';
        return validate(CURR_PATTERN, value);
    }        

    public static Boolean validateLength(String value,Integer length){
        Boolean tooLong = false;
        if(String.isNotBlank(value)){
            tooLong = value.length() > length;
        }
        return tooLong; 
    }

    //EAD-2543 - added support for space and hyphen
    public static Boolean validateVatFormat(String value){
        final String CURR_PATTERN = '^[a-zA-Z0-9 ]{5,15}';
        return validate(CURR_PATTERN, value);
    }

    public static Boolean isValidId(String idToValidate) {
        try {
            Id.valueOf(idToValidate);
            return true;
        } catch (System.StringException strException) {
            return false;
        }
    }
    
    /**
     * Usful to determine the type of ID you have.
     */
    public static ValidatorUtils.IDTYPE getIdType(String idToValidation,String idType ){
        
        IDTYPE returnValue = ValidatorUtils.IDTYPE.InvalidID;
        if(isValidObjectId(idToValidation,idType)){
            returnValue = ValidatorUtils.IDTYPE.RecordID;
        }
        else if(isValidGlobalId(idToValidation,idType)){
            returnValue = ValidatorUtils.IDTYPE.GlobalID;
        }
        return returnValue;
    }


    public static Boolean isValidObjectId(String idToValidate, String objectApiName) {
        if (isValidId(idToValidate)) {
            if (Id.valueOf(idToValidate).getSobjectType() 
                != Schema.getGlobalDescribe().get(objectApiName).getDescribe().getSObjectType()) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    }

    public static Boolean isValidGlobalId(String idToValidate, String idType) {
        if (String.isNotBlank(idType)) {
            String mType = idType.toLowerCase();
			String charPattern;
            switch on mType {
                when 'account' {
                    charPattern = '^[1][0-9]{9}';
                }
                when 'contact' {
                    charPattern = '^[2][0-9]{9}';
                }
            }
            if (String.isNotBlank(charPattern)) {
                return validate(charPattern, idToValidate);
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    
    private static Boolean validate(String regexPattern, String value){
        Boolean result = false;
        if(!String.isBlank(value)){
            Pattern mPattern = Pattern.compile(regexPattern);
            Matcher matcher = mPattern.matcher(value);
            if (matcher.matches())
            {
                result = true;
            }
        }
        return result;	
    }
}