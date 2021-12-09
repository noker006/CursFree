/**
 * Created by MAX on 08.12.2021.
 */

public with sharing class RequestTriggerHandler {
    public static void afterInsertMethod(List<Request__c> requests) {
        createNotificationForEmployer(requests);
    }

    public static void afterUpdateMethod(List<Request__c> newList, Map<Id, Request__c> oldMap){
        checkRequestStatus(newList, oldMap);
    }

    public static void checkRequestStatus(List<Request__c> newRequests, Map<Id, Request__c> oldRequestMap){
        List<Request__c> rejectedRequests = new List<Request__c>();
        List<Request__c> confirmedRequests = new List<Request__c>();

        for(Request__c req : newRequests) {
            Request__c oldRequest =  oldRequestMap.get(req.Id);

            if(req.Status__c != oldRequest.Status__c){
                if(req.Status__c == 'Rejected'){
                    rejectedRequests.add(req);
                } else if(req.Status__c == 'Confirmed'){
                    confirmedRequests.add(req);
                }
            }
        }

        createNotificationForFreelancer(rejectedRequests,'Rejected');

        createNotificationForFreelancer(confirmedRequests,'Confirmed');
        createContractAndActivity(confirmedRequests);
    }

    public static void createContractAndActivity(List<Request__c> requests){
        List<Contract__c> contracts = new List<Contract__c>();
        List<Activity__c> activities = new List<Activity__c>();

        for(Request__c req :requests){
            Contract__c contract = new Contract__c();
            contract.Name = 'Contract with ' +  req.FreelancerId__r.Name;
            contract.Duration__c = req.Duration__c;
            contract.FreelancerId__c = req.FreelancerId__c;
            contract.HourlyRate__c = req.Hourly_rate__c;
            contract.JobId__c = req.JobId__c;
            contract.Status__c = 'Frozen';

            Activity__c activity = new Activity__c();
            activity.Name = req.FreelancerId__r.Name + 'Activity';
            activity.FreelancerId__c = req.FreelancerId__c;
            activity.JobId__c = req.JobId__c;
            activity.LastActivity__c = Datetime.now();

            activities.add(activity);
            contracts.add(contract);
        }
        
        insert activities;
        insert contracts;
    }

    public static void createNotificationForFreelancer(List<Request__c> requests, String requestStatus){
        List<Notification__c> notifications = new List<Notification__c>();

        List<Id> requestIds = getIdsFromRequestsList(requests);
        List<Request__c> reQRequests = getRequestsByIds(requestIds);

        for (Request__c req : reQRequests) {
            Notification__c notification = new Notification__c();
            notification.Name = 'Your request was ' + requestStatus;
            notification.Text__c = 'Your request was ' + requestStatus + ' (Job "'+ req.JobId__r.Name +'")';
            notification.FreelancerId__c = req.FreelancerId__c;
            notifications.add(notification);
        }

        insert notifications;
    }

    public static List<Id> getIdsFromRequestsList(List<Request__c> requests) {
        List<Id> requestIds = new List<Id>();

        for (Request__c req : requests) {
            requestIds.add(req.Id);
        }

        return requestIds;
    }

    public static void createNotificationForEmployer(List<Request__c> requests) {
        List<Id> requestIds = getIdsFromRequestsList(requests);

        List<Request__c> reQRequests = getRequestsByIds(requestIds);
        Map<Id, Id> jobIdByRequestId = getJobIdByRequestId(requests);
        Map<Id, Id> employerIdByJobId = getEmployerIdByJobId(jobIdByRequestId.values());
        List<Notification__c> notifications = new List<Notification__c>();

        for (Request__c req : reQRequests) {
            Id jobId = jobIdByRequestId.get(req.Id);
            Id employerId = employerIdByJobId.get(jobId);
            Notification__c notification = new Notification__c();
            notification.Name = 'Request from ' + req.FreelancerId__r.Name;
            notification.Text__c = 'You have new request, Please check Job ' + req.JobId__r.Name;
            notification.EmployerId__c = employerId;
            notifications.add(notification);
        }

        insert notifications;
    }

    public static List<Request__c> getRequestsByIds(List<Id> requestIds) {
        return [
                SELECT Id,
                        FreelancerId__r.Name,
                        JobId__r.Name
                FROM Request__c
                WHERE Id IN :requestIds
        ];
    }

    public static Map<Id, Id> getJobIdByRequestId(List<Request__c> requests) {
        Map<Id, Id> jobIdByRequestId = new Map<Id, Id>();

        for (Request__c req : requests) {
            jobIdByRequestId.put(req.Id, req.JobId__c);
        }

        return jobIdByRequestId;
    }

    public static Map<Id, Id> getEmployerIdByJobId(List<Id> jobIds) {
        List<Job__c> jobs = getJobsWithEmployerId(jobIds);
        Map<Id, Id> employerIdByJobId = new Map<Id, Id>();

        for (Job__c job : jobs) {
            employerIdByJobId.put(job.Id, job.EmployerId__c);
        }

        return employerIdByJobId;
    }

    public static List<Job__c> getJobsWithEmployerId(List<Id> jobIds) {
        List<Job__c> jobs = new List<Job__c>();

        jobs = [
                SELECT Id, EmployerId__c
                FROM Job__c
                WHERE Id IN :jobIds
        ];

        return jobs;
    }

}