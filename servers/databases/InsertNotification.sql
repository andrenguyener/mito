/*
A stored procedure to insert notification into the table
@param FriendId: a valid friendid 
@NotificationTypeId: the notification type for a specific action (ex: update friend, accept friend, etc)
@SendFrom: always 0 // might need to modify
@NotifcationDate: the date of when the notification is inserted
*/
CREATE PROC uspInsertNotification
@FriendId INT,
@NotificationTypeId INT,
@SendFrom BIT,
@NotificationDate DATETIME
AS
	IF @NotificationDate IS NULL 
		BEGIN
		SET @NotificationDate = GETDATE()
		END
	BEGIN TRAN
	INSERT INTO NOTIFICATION (FriendId, NotificationTypeId, SendFrom, NotificationDate)
	VALUES (@FriendId, @NotificationTypeId, @SendFrom, @NotificationDate)

	IF @@ERROR <> 0 
		ROLLBACK TRAN
	ELSE
		COMMIT TRAN

EXEC sp_rename 'InsertNotification', 'uspInsertNotification'