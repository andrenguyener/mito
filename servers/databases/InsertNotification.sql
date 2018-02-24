CREATE PROC InsertNotification
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