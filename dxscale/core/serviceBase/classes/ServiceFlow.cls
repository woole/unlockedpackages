public inherited sharing class ServiceFlow implements IService_Implementation {

/*

How flows are run

When we create a Service Implementation record with Implementation Type = “Flow” we instruct our framework to implement functionality via an autolaunched flow, and we can run almost any auto-launched flow subject to some conditions.     Behind the scenes our Flow Implementations are invoked from an Apex Class called ServiceFlow, this one Apex class is used to run all flows and does not need any per-flow modification, does not need to be referenced in any configuration and developers do not even need to be aware of its existence. When the framework sees that a Flow implementation is configured an instance of ServiceFlow is created, this class implements IService_Implementation and the dispatch method required by the interface is called. Within the body of the dispatch() method we run the flow.

There are some special conditions that we require to run flows. We pass in an implementation of IInvocation_Details, this needs to return the name of the flow to run in the getImplementingFlow() method and the framework ensures that this is the case and again this can be invisible to the app developer. However there are some other aspects that the developer will need to be aware of.

How to develop and invoke a Flow-based service

We invoke a flow-based service method in the same way as an Apex based, i.e. we provide the service, iteration, method and an Input and Output Interface version. The interfaces each have one extra requirement:

Requirements for the input interface: We also pass in an implementation of (an extension of) IService_Input_Master but in order to trigger the flow this also needs to implement the interface IService_Flow_Input. This interface contains a method 
         Map<String,Object> createFlowInput()

To run a flow interview in Apex the input parameters of the flow are passed as a Map<String,Object> object and createFlowInput() uses methods from the input interface specified by the Service Invocation to create the Map to input to the flow
    
Requirements for the flow: The flow we need to run also needs to satisfy some properties. We will want to map the output of the flow into an (extension of the) IService_Output_Master structure which means we will want to call setState() and setErrorMessage() to pass state and error information to the caller. To accomplish this in a standardized way we require every flow to have output string variables called State and ErrorMessage and the flow logic should set these accordingly, in the case of State we should map this to Success or to a Failure expression, and in the latter case we should also set the ErrorMessage variable.

Requirements for the flow: It is then up to the Output Interface version to convert the flow output to the requested Output Interface structure. Flow output can be extracted in Apex by calling the Interview's getVariableValue() method with the name of the Flow variable as the input. In addition to implementing the IService_Output_Master methods and those setting and getting business properties we also require the output interface version to satisfy the interface IService_Flow_Output and in particular the method processFlowOutput.  

This method takes the Flow Interview as its argument and uses the setter methods on the Output Interface to build up the Output Structure that the invoker will require. So for example, for a output interface passing back a single string this method might look like this:

         public void processFlowOutput(Flow.Interview myFlow) {
           setOutputMessage((String) myFlow.getVariableValue('outputMessage'));
           setState((String) myFlow.getVariableValue('state'));
           setErrorMessage((String) myFlow.getVariableValue('errorMessage'));
        }

Setting up a Service Method to use a flow is very similar to the setup using an Apex Class. The only difference is that that the Service Implementation record should have:

•	Implementation Type = 'Flow' 
•	Implementing Flow set to the name of the flow. 

All of the logic and configuration for setting up Services, Invocations and Methods applies as for Apex implementations.




*/

  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {

    String flowName = invocationDetails.getImplementingFlow();
    IService_Flow_Input isi = (IService_Flow_Input) inputData;

    Map<String,Object> mapInput = isi.createFlowInput(); // processing the input becomes the job of the input interface
    Flow.Interview myFlow = Flow.Interview.createInterview(flowName, mapInput);
    myFlow.start();

    IService_Flow_Output iso = new StringOutputV1(); // not generic
    iso.processFlowOutput(myFlow); // processing the output becomes the job of the output interface
    return (IService_Output_Master) iso;
  }



}
