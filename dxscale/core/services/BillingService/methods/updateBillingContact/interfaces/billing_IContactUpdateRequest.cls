//Base request
public interface billing_IContactUpdateRequest extends billing_IRequest{
    String getNewEmailAddress();
    String getContactId();
    String getExistingEmailAddress();
    
}
