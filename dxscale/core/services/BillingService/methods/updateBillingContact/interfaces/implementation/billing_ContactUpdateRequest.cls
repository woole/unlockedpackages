public inherited sharing class billing_ContactUpdateRequest extends billing_Request implements billing_IContactUpdateRequest{
    
    private String existingEmailAddress;
    private String newEmailAddress;
    private String contactId;

    public billing_ContactUpdateRequest(String newEmailAddress,String existingEmailAddress,String accountId,String contactId) {
        super(accountId);
        this.newEmailAddress = newEmailAddress;
        this.existingEmailAddress = existingEmailAddress;
        this.contactId = contactId;
    }

    public String getNewEmailAddress(){
        return this.newEmailAddress;
    }

    public String getExistingEmailAddress(){
        return this.existingEmailAddress;
    }

    public String getContactId(){
        return this.contactId;
    }    
}
