public with sharing class KeyAccountInfo_d {

    @AuraEnabled
    public String id {get;set;}
    @AuraEnabled
    public Integer priority {get;set;}
    @AuraEnabled
    public String message {get;set;}
    @AuraEnabled
    public Boolean customStyle {get;set;}

    public KeyAccountInfo_d(Integer priority, String message, Boolean customStyle) {
        this.priority = priority;
        this.message = message;
        this.id = geId();
        this.customStyle = customStyle;      
    }

    private String geId(){
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        return EncodingUtil.convertToHex(hash);
    }
}
