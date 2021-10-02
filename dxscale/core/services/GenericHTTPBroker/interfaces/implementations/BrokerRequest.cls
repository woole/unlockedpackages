public inherited sharing class BrokerRequest extends ServiceOutputMaster implements IBrokerRequest{
    private  IService_Input_Master brokerRequest;

    public IService_Input_Master getBrokerRequest(){
        return this.brokerRequest;
    }

    public void setBrokerRequest(IService_Input_Master request){
        this.brokerRequest = request;
    }
}
