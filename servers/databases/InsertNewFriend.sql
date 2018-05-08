/*
	Insert data into FRIEND table to record friend connection
	Insert notification into NOTIFICATION table to record notification sent to @Username2
	@Username1 sent a friend request to @Username2
	@FriendType will always be "Pending"
*/
EXEC sp_rename 'uspRequestFriend', 'uspcRequestFriend'

ALTER PROC uspcRequestFriend
@User1Id INT,
@User2Id INT
AS
	-- Check both users already exist in the [USER] database
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'User1 or User2 does not exist'
			RAISERROR('@Username1 or @Username2 is null', 11, 1)
			RETURN
		END
	DECLARE @FriendId INT
	EXEC uspGetFriendId @User1Id, @User2Id, @MatchedFriendId = @FriendId OUT
	
	IF @FriendId IS NOT NULL
		BEGIN
			PRINT'These users already establish a friendship'
			RAISERROR('@FriendId must not already exist in the FRIEND table',11,1)
			RETURN
		END

	--Get the FriendTypeId of Pending since this is the default type when inserting a new friend
	DECLARE @FriendTypeId INT
	EXEC uspGetFriendTypeId 'Pending', @FriendType_ID = @FriendTypeId OUT

	-- Check @FriendType exists in FRIEND database
	IF @FriendTypeId IS NULL
		BEGIN
			PRINT 'This friendType does not exist'
			RAISERROR('@FriendType does not exist', 11, 1)
			RETURN
		END

	DECLARE @NotificationTypeId INT
	EXEC uspGetNotificationType 'Pending', 'Friends', @NotificationType_ID = @NotificationTypeId OUT
	IF @NotificationTypeId IS NULL
		BEGIN
			PRINT 'Friend request is not a type of notification'
			RAISERROR('@NotificationTypeId is null',11,1)
			RETURN
		END

	DECLARE @TodaysDate DATETIME = (SELECT GETDATE())

	-- INSERT Notification to alert User2 that User1 would like to be friend 
	-- Default notification for InsertFriend is based on 'Pending' Friend Type
	BEGIN TRAN insertNotification
	-- INSERT friendship between @Username1 and @Username2 in FRIEND table
	BEGIN TRAN insertIntoFriend
	INSERT INTO FRIEND (User1Id, User2Id, FriendTypeId, IsDeleted) VALUES (@User1Id, @User2Id, @FriendTypeId, 0)
	--SET @FriendId = (SELECT SCOPE_IDENTITY())
	IF @@ERROR <> 0
		ROLLBACK TRAN insertIntoFriend
	ELSE
		COMMIT TRAN insertIntoFriend
		EXEC uspInsertNotification @NotificationTypeId, @User1Id, @User2Id, @TodaysDate, NULL
		IF @@ERROR <> 0
			ROLLBACK TRAN insertNotification
		ELSE
			COMMIT TRAN insertNotification
GO
	/*

	-- INSERT friendship between @Username1 and @Username2 in FRIEND table
	BEGIN TRAN insertIntoFriend
		INSERT INTO FRIEND (User1Id, User2Id, FriendTypeId, IsDeleted) VALUES (@User1Id, @User2Id, @FriendTypeId, 0)
		DECLARE @FriendId INT = (SELECT SCOPE_IDENTITY())
		IF @@ERROR <> 0
			ROLLBACK TRAN insertIntoFriend
		ELSE
			COMMIT TRAN insertIntoFriend
			-- INSERT Notification to alert User2 that User1 would like to be friend 
			-- Default notification for InsertFriend is based on 'Pending' Friend Type
			BEGIN TRAN insertNotification
			EXEC InsertNotification @FriendId, @NotificationTypeId, 0, @TodaysDate
			IF @@ERROR <> 0
				ROLLBACK TRAN insertNotification
			ELSE
				COMMIT TRAN insertNotification
				*/