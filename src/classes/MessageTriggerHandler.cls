/**
 * Created by MAX on 09.12.2021.
 */

public with sharing class MessageTriggerHandler {
    public static void afterInsertMethod(List<Message__c> newMessages) {
        createHistory('Create', new Map<Id, Message__c>() , newMessages);
    }

    public static void afterUpdateMethod(List<Message__c> newList, Map<Id, Message__c> oldMap) {
        createHistory( 'Update', oldMap , newList);
    }

    //TODO сделать кверюдля мессаджей где достану заново эти релейшены для фрилансера и имплойера
    public static void createHistory(String activityType, Map<Id, Message__c> oldMessagesMap, List<Message__c> newMessages) {
        List<History__c> histories = new List<History__c>();
        List<Message__c> messages = getMessagesByIds(oldMessagesMap.keySet());

        if (activityType == 'Create') {

            for(Message__c newMess : messages){
                History__c historyCreate = new History__c();
                historyCreate.ActivityId__c = newMess.ActivityId__c;
                historyCreate.ActivityType__c = 'Create';
                historyCreate.ChangedText__c = newMess.Text__c;
                if(newMess.FreelancerId__c != null){
                    historyCreate.Name = newMess.FreelancerId__r.Name + ' Create Message';
                } else if(newMess.EmployerId__c != null){
                    historyCreate.Name = newMess.EmployerId__r.Name + ' Create Message';
                }
                histories.add(historyCreate);
            }
        } else if (activityType == 'Update') {

            for(Message__c newMess : messages){
                Message__c oldMess = oldMessagesMap.get(newMess.Id);

                if(newMess.Text__c != oldMess.Text__c){
                    History__c historyCreate = new History__c();
                    historyCreate.ActivityId__c = newMess.ActivityId__c;
                    historyCreate.ActivityType__c = 'Update';
                    historyCreate.ChangedText__c = 'From: ' + oldMess.Text__c +  '/\n '  + 'To: ' + newMess.Text__c;
                    if(newMess.FreelancerId__c != null){
                        historyCreate.Name = newMess.FreelancerId__r.Name + ' Update Message';
                    } else if(newMess.EmployerId__c != null){
                        historyCreate.Name = newMess.EmployerId__r.Name + ' Update Message';
                    }
                    histories.add(historyCreate);
                } else {
                    break;
                }
            }
        }

        insert histories;
    }

    public static List<Message__c> getMessagesByIds(Set<Id> messIds) {

        return [
                SELECT Id,
                        Text__c,
                        ActivityId__c,
                        FreelancerId__c,
                        FreelancerId__r.Name,
                        EmployerId__c,
                        EmployerId__r.Name
                FROM Message__c
                WHERE Id IN :messIds
        ];
    }
}