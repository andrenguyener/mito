ALTER PROC updateFriend
@Username1 NVARCHAR(50),
@Username2 NVARCHAR(50),
@FriendTypeToUpdate NVARCHAR(25)
AS
	DECLARE @User1Id INT
	DECLARE @User2Id INT
	DECLARE @FriendId INT
	--Get UserId for both username
	EXEC GetUserId @Username1, @User_ID = @User1Id OUT
	EXEC GetUserId @Username2, @User_ID = @User2Id OUT
	--Get FriendId for both username, if they're not friend, it will return NULL
	EXEC GetFriendId @User1Id, @User2Id, @MatchedFriendId = @FriendId OUT

	-- Check both users already exist in the [USER] database
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'User1 or User2 does not exist'
			RAISERROR('@Username1 or @Username2 is null', 11, 1)
			RETURN
		END
	-- Ensure the friendship exists in the FRIEND table, should be a pending status
	IF @FriendId IS NULL
		BEGIN
			PRINT 'These users has not establish a friendship yet'
			RAISERROR('@Username1 and @Username2 are not in FRIEND table',11,1)
			RETURN
		END

	--Get the current FriendTypeId of the two users (not sure what I want to do with this yet)
	--DECLARE @OldFriendTypeId INT
	--EXEC GetCurrentFriendTypeId @FriendId, @CurrentFriendType_Id = @OldFriendTypeId
	
	--Get a new FriendTypeId that the friend will update to  
	DECLARE @NewFriendTypeId INT
	EXEC GetFriendTypeId @FriendTypeToUpdate, @FriendType_Id = @NewFriendTypeId
	DECLARE @Delete BIT = 0
	--If the new friend type to update is 'Unfriend', prompt deleted
	IF @FriendTypeToUpdate = 'Unfriend'
		BEGIN
			SET @Delete = 1
		END 
	/*
	-- Ensure Pending is a FRIEND_TYPE and NOTIFICATION_TYPE
	IF @FriendTypeId IS NULL OR @NotificationTypeId IS NULL
		BEGIN
			PRINT 'User1 does not have a pending friend request status with User2'
			RAISERROR('@Username1 and @Username2 do not have a pending friend request',11,1)
			RETURN
		END
	*/

	DECLARE @NotificationTypeId INT 
	EXEC GetNotificationType @FriendTypeToUpdate, @NotificationType_ID = @NotificationTypeId
	
	DECLARE @TodaysDate DATETIME = GETDATE()
	BEGIN TRAN updateFriend
		--Update the friend type based on the FriendId
		EXEC UpdateFriendType @FriendId, @NewFriendTypeId, @Delete 
		IF @@ERROR <> 0
			ROLLBACK TRAN updateFriend
		ELSE
			COMMIT TRAN updateFriend
			BEGIN TRAN insertNotification
			-- Insert a new notification that @Username2 accepted @Username1's friend request
			EXEC InsertNotification @FriendId, @NotificationTypeId, 0, @TodaysDate
			IF @@ERROR <> 0 
				ROLLBACK TRAN insertNotification
			ELSE
				COMMIT TRAN insertNotification
