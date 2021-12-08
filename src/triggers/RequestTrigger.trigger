/**
 * Created by MAX on 08.12.2021.
 */

trigger RequestTrigger on Request__c (after insert, after update) {
    switch on Trigger.operationType {
        when  AFTER_INSERT {
            RequestTriggerHandler.afterInsertMethod(Trigger.new);
        }
        when AFTER_UPDATE {
//            RequestTriggerHandler.convertProxyObjectsToStandard(Trigger.newMap);
//            RequestTriggerHandler.createCustomerInGFN(Trigger.new, Trigger.oldMap);
        }
    }
}