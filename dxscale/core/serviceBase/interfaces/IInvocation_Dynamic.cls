global interface IInvocation_Dynamic {

    // Information that is dynamically generated during an invocation.
    DateTime getInvocationTime();
    void setInvocationTime(DateTime invocationTime);

    Id getUserId();
    void setUserId(Id userId);

    Id getAuditIdReplayed();
    void setAuditIdReplayed(Id auditId);

}

