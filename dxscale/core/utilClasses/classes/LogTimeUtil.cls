/**
 * Util class that allows us to trap time info into debug logs so we can see issues around DML and the like
 */
public without sharing class LogTimeUtil {
    
    private Datetime startTime;
    private Datetime endTime;
    private String name;

    private static LogTimeUtil timerInstance;

    public static LogTimeUtil getInstance(String name){
        if(timerInstance == null){
            timerInstance = new LogTimeUtil(name);
        }
        return timerInstance;
    }
    private LogTimeUtil(String name){
        this.name = name;
    }


    public void start(){
        startTime = datetime.now();
    }
    public String end(){
        String logEntry;
        //only log if called in sequence
        if(startTime != null){
            endTime = datetime.now();
            logEntry = getLogEntry();
            system.debug(logginglevel.WARN, logEntry);
        }
        //reset
        startTime = null;
        endTime = null;
        return logEntry;
        
    }

    @TestVisible
    private String getLogEntry(){
        String logEntry = 'STATS : ' + name + ' : time (ms) : ' + (endTime.getTime() - startTime.getTime());
        return logEntry;
    }
}
