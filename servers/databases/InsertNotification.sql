/*
A stored procedure to insert notification into the table
@param FriendId: a valid friendid 
@NotificationTypeId: the notification type for a specific action (ex: update friend, accept friend, etc)
@SendFrom: always 0 // might need to modify
@NotifcationDate: the date of when the notification is inserted
*/
ALTER PROC uspInsertNotification
@NotificationTypeId INT,
@SendFrom INT,
@SendTo INT,
@NotificationDate DATETIME,
@Id INT
AS
	IF @NotificationDate IS NULL 
		BEGIN
		SET @NotificationDate = GETDATE()
		END
	BEGIN TRAN
	INSERT INTO NOTIFICATION (NotificationTypeId, SendFrom, NotificationDate, SendTo, RelevantId)
	VALUES (@NotificationTypeId, @SendFrom, @NotificationDate, @SendTo, @Id)

	IF @@ERROR <> 0 
		ROLLBACK TRAN
	ELSE
		COMMIT TRAN

EXEC sp_rename 'InsertNotification', 'uspInsertNotification'