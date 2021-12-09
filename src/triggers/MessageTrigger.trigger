/**
 * Created by MAX on 09.12.2021.
 */

trigger MessageTrigger on Message__c (after insert, after update) {
    switch on Trigger.operationType {
        when  AFTER_INSERT {
            MessageTriggerHandler.afterInsertMethod(Trigger.new);
        }
        when AFTER_UPDATE {
            MessageTriggerHandler.afterUpdateMethod(Trigger.new, Trigger.oldMap);
        }
    }
}