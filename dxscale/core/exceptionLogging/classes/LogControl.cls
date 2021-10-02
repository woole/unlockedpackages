/**
 * @author Bhushan Sukumar (bhushan.sukumar@sage.com)
 * @date 01-Aug-2018
 *
 * Logger class to capture exceptions as part of the loggin framework. The class has the necessary methods
 to store the exception information on the Log object in SF
 */

public without sharing class LogControl {

	public class CustomException extends Exception {
	}

	public static final string STACKSTR = ' stack: ';

	static integer currentLevel = 0;
	@TestVisible static integer sequence = 0;
	@TestVisible
	static List<StackTrace> stack = new List<StackTrace>();
	@TestVisible
	static List<ExceptionEvent__e> exceptionEvents = new List<ExceptionEvent__e>();

	public class StackTrace {
		public integer level { get; private set; }
		private string function;
		private string objectName;

		public string getEntry() {
			return (objectName + ' : ' + function);
		}

		public StackTrace(integer level, string function, string objectName) {
			this.level = level;
			this.function = function;
			this.objectName = objectName;
		}
	}

	/**
     * This method should be called when entering every in a class. This method will initiate the stacktrace that will
     * have the exception info along with the function name
     *
     * @param functionName  String denoting the name of the method from which this method was called
     * @param objectName    String denoting the name of the class from which the method was called
     */
	static public void push(string functionName, string objectName) {
		stack.add(new StackTrace(currentLevel, functionName, objectName));
		currentLevel++;
	}

	/**
     *
     *
     * @return      returns the stacktrace string that will contain the stack trace entries along with the trace level
     */
	static private string getStackTrace() {
		string retVal = '';
		if (stack != null && stack.size() > 0) {
			String spaces = '                                                                ';
			for (StackTrace se : stack) {
				Integer endIndex = 3 * se.level;
				if (endIndex >= spaces.length())
					endIndex = spaces.length() - 1;
				retVal += spaces.substring(0, endIndex) + se.getEntry() + '\n';
			}
		}
		return retVal;
	}

	/**
     * This method should be called when exiting every method in a class. This method will remove the debuginfo along
     * with the functionName and objectName
     */
	static public void pop() {

		if (currentLevel > 0) {
			currentLevel--;
			if (stack.size() > 0) {
				stack.remove(stack.size() - 1);
			}
		}

		if (currentLevel == 0 && !exceptionEvents.isEmpty()) {
			String exptListString = JSON.serialize(exceptionEvents);
			if (System.isBatch() || System.isFuture()) {
				List<ExceptionEvent__e> eventsParsed = (List<ExceptionEvent__e>) JSON.deserialize(exptListString, List<ExceptionEvent__e>.class);
				EventBus.publish(eventsParsed);
			} else {
				writeLogsToDatabase(exptListString);
			}
			exceptionEvents = new List<ExceptionEvent__e>();
		}
	}

	/**
     * This method is called by methods which needs to capture an exception statement into Salesforce. The String that
     * needs to be displayed is passed to this method and is added to the list of logs that will be inserted in SF
     *
     * @param ex    exception object that is passed from the method that wants to capture the exception.
     */
	static public void debugException(Exception ex){

		string exceptionInfo = ex.getMessage() + STACKSTR + ex.getStackTraceString();
		ExceptionEvent__e eve = new ExceptionEvent__e();
		eve.StackTrace__c = getStackTrace();
		eve.ErrorMessage__c = exceptionInfo;
		eve.ExceptionType__c = ex.getTypeName();
		eve.ExceptionCause__c = String.valueOf(ex.getCause());
		exceptionEvents.add(eve);
		sequence++;
	}

	/**
     * Asynchronous method to inser the log record with the exception information.
     *
     * @param exptListString
     */
	@future
	static private void writeLogsToDatabase(string exptListString) {

		List<ExceptionEvent__e> exceptListParsed = (List<ExceptionEvent__e>)JSON.deserialize(exptListString
				, List<ExceptionEvent__e>.class);
		EventBus.publish(exceptListParsed);
	}

}