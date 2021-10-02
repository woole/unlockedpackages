/**
 * @date 26-Jul-2018
 * @description this trigger is part of the logging framework implemented in customer core.
 */
trigger ExceptionEvent_Trigger on ExceptionEvent__e (after insert) {
    TriggerFactory.executeTrigger();
}