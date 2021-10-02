public inherited sharing class EmailServiceHelper {
    

    
    public static Messaging.SingleEmailMessage getEmailMessage(IEmailRequestV1 request){
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        
        EmailTemplate emailTemplate = getEmailTemplate(request.getEmailTemplateName());
        
        String templateId = emailTemplate.Id;
        String emailSubject = emailTemplate.Subject;

        semail.setBccAddresses(request.getBCCList());
        String fromNoReply = request.getDisplayName();
        OrgWideEmailAddress[] orgEmailList = [select Id from OrgWideEmailAddress where Address = :fromNoReply];
        if(orgEmailList.size() > 0){
            OrgWideEmailAddress owea = orgEmailList[0];
            semail.setOrgWideEmailAddressId(owea.Id);
        }else{
            semail.setSenderDisplayName(fromNoReply);
            semail.setReplyTo(fromNoReply);
        }
              
        semail.setTemplateId(templateId);
       
        semail.setTargetObjectId(request.getRecipientId());
        semail.setWhatId(request.getRelatedTo());
        
        semail.setSaveAsActivity(request.getSaveActivity());
        return semail;
    }
    
    
    @TestVisible
    private static EmailTemplate getEmailTemplate(String templateName){
        EmailTemplate[] templates = [select Id, name, subject,HtmlValue,Body from EmailTemplate
                                         where Name =: templateName];
        
        if(templates.isEmpty()){
            throw new EmailServiceException('Email Template ('+templateName+') Not Found');
        }
        
        return templates[0];
    }
    
    public static void sendEmail(Messaging.SingleEmailMessage message){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
    }
    
    
}