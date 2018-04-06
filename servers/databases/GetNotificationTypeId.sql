/*
A stored procedure that retrieve the notification type Id based on the given notification type string
@param: a valid notification type name
output param: matching notification type Id
*/

ALTER PROC uspGetNotificationType
@NotificationType NVARCHAR(50),
@NotificationType_ID INT OUT
AS
	SET @NotificationType_ID = (SELECT NotificationTypeId FROM NOTIFICATION_TYPE 
	WHERE NotificationType = @NotificationType)
GO

EXEC sp_rename 'GetNotificationType', 'uspGetNotificationType'