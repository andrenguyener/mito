ALTER PROC GetNotificationType
@NotificationType NVARCHAR(50),
@NotificationType_ID INT OUT
AS
	SET @NotificationType_ID = (SELECT NotificationTypeId FROM NOTIFICATION_TYPE 
	WHERE NotificationType = @NotificationType)
GO