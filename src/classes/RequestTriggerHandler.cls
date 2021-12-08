/**
 * Created by MAX on 08.12.2021.
 */

public with sharing class RequestTriggerHandler {
    public static void afterInsertMethod(List<Request__c> requests) {
        createNotificationForEmployer(requests);
    }

    public static void createNotificationForEmployer(List<Request__c> requests) {
        List<Id> requestIds = new List<Id>();

        for (Request__c req : requests) {
            requestIds.add(req.Id);
        }

        List<Request__c> reQRequests = getRequestsByIds(requestIds);
        Map<Id, Id> jobIdByRequestId = getJobIdByRequestId(requests);
        Map<Id, Id> employerIdByJobId = getEmployerIdByJobId(jobIdByRequestId.values());
        List<Notification__c> notifications = new List<Notification__c>();

        for (Request__c req : reQRequests) {
            Id jobId = jobIdByRequestId.get(req.Id);
            Id employerId = employerIdByJobId.get(jobId);
            Notification__c notification = new Notification__c();
            notification.Name = 'Request from ' + req.FreelancerId__r.FirstName__c + ' ' + req.FreelancerId__r.LastName__c;
            notification.Text__c = 'You have new request, Please check Job ' + req.JobId__r.Name;
            notification.EmployerId__c = employerId;
            notifications.add(notification);
        }

        insert notifications;
    }

    public static List<Request__c> getRequestsByIds(List<Id> requestIds) {
        return [
                SELECT Id, FreelancerId__r.FirstName__c, FreelancerId__r.LastName__c, JobId__r.Name
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