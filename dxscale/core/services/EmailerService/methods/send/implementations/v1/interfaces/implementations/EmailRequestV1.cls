public inherited sharing class EmailRequestV1 extends ServiceInputMaster implements IEmailRequestV1 {

    private String emailTemplateName;
    private Id recipientId;
    private Id relatedTo;
    List<String> bccList;
    private Boolean saveActivity = true;
    private String displayName;
    
    public EmailRequestV1(String emailTemplateName, Id recipientId, Id relatedTo,List<String> bccList,Boolean saveActivity,String displayName){
        this.emailTemplateName = emailTemplateName;
        this.recipientId = recipientId;
        this.relatedTo = relatedTo;
        this.bccList = bccList;
        this.saveActivity = saveActivity;
        this.displayName = displayName;
    }

    public String getEmailTemplateName(){
        return this.emailTemplateName;
    }
    public Id getRecipientId(){
        return this.recipientId;
    }
    public Id getRelatedTo(){
        return this.relatedTo;
    }
    public List<String> getBCCList(){
        return this.bccList;
    }
    public Boolean getSaveActivity(){
        return this.saveActivity;
    }

    public String getDisplayName(){
        return this.displayName;
    }

}