public interface IEmailRequestV1  extends IService_Input_Master {
    String getEmailTemplateName();
    Id getRecipientId();
    Id getRelatedTo();
    List<String> getBCCList();
    Boolean getSaveActivity();
    String getDisplayName();
}