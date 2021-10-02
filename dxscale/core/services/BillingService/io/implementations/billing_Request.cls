public inherited sharing virtual class billing_Request extends ServiceInputMaster implements billing_IRequest {

    private String sfAccountId;

	protected billing_Request(){}


    public billing_Request(String sfAccountId){
        this.sfAccountId = sfAccountId;
    
    }

    public String getSFAccountId(){
        return this.sfAccountId;
    }

	public override String getCorrelationId(){
		String cid = super.getCorrelationId();
		if(String.isBlank(cid)){
			cid = GUIDUtils.getGUID();
			super.setCorrelationId(cid);
		}
		return cid;
	}	    

}
