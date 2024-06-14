public with sharing class CustomNotificationFromApex {

    @AuraEnabled
    public static void notifyUsersStatic(String[] recipientsIds, String targetId, String title, String body){
        try {
            CustomNotificationFromApex cn = new CustomNotificationFromApex();
            Set<String> ns = new Set<String>();
            for(String r : recipientsIds)
            { //Clear out empty strings
                if (r != '') ns.add(r);
            }
            if (ns.size() > 0)
            { //Only send if there's at least one recipient
                cn.notifyUsers(ns, targetId, title, body);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void notifyUsers(Set<String> recipientsIds, String targetId, String title, String body) {
 
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='AsyncProcess_Complete'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
 
        // Set the contents for the notification
        notification.setTitle(title);
        notification.setBody(body);
 
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}