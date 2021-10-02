public without sharing class GuidUtils {
    
    /**
     * getGUID Get a new GUID / UUID
     * @return  returns valid guid in standard format as per https://en.wikipedia.org/wiki/Universally_unique_identifier
     */ 
    public static String getGUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        
        system.debug(LoggingLevel.DEBUG,guid);
        return guid;
    }

}
