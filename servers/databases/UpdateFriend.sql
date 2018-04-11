/*
params: user1 and user2 id, FriendType that wish to update to and notification response 
for the friend update request 
*/

ALTER PROC uspcUpdateFriend
@User1Id INT,
@User2Id INT,
@FriendTypeToUpdate NVARCHAR(25),
@FriendTypeRequestResponse NVARCHAR(25)
AS
	-- Check both users already exist in the [USER] database
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'User1 or User2 does not exist'
			RAISERROR('@Username1 or @Username2 is null', 11, 1)
			RETURN
		END

	DECLARE @FriendId INT
	--Get FriendId for both username, if they're not friend, it will return NULL
	EXEC uspGetFriendId @User1Id, @User2Id, @MatchedFriendId = @FriendId OUT

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
	EXEC uspGetFriendTypeId @FriendTypeToUpdate, @FriendType_Id = @NewFriendTypeId OUT
	--Check if the requested friend type update already existed
	--if it does, cancel the transaction
	IF EXISTS (SELECT * FROM FRIEND WHERE FriendId = @FriendId AND FriendTypeId = @NewFriendTypeId)
		BEGIN
		PRINT'This friendship is already established'
		RAISERROR('@FriendId and @NewFriendTypeId cannot exist before',11,1)
		RETURN
		END
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
	EXEC uspGetNotificationType @FriendTypeRequestResponse, 'Friends', @NotificationType_ID = @NotificationTypeId OUT
	
	DECLARE @TodaysDate DATETIME = GETDATE()
	--determine if the sender is a User1 or User2 in FriendTable
	--DECLARE @SendFromUser BIT
	--EXEC uspUser1orUser2 @FriendId, @User1Id, @User1 = @SendFromUser OUT

	BEGIN TRAN insertNotification
		--Update the friend type based on the FriendId
			BEGIN TRAN updateFriend
			EXEC uspUpdateFriendType @FriendId, @NewFriendTypeId, @Delete 
			IF @@ERROR <> 0
				ROLLBACK TRAN updateFriend
			ELSE
				COMMIT TRAN updateFriend
		
		-- Insert a new notification that @User1 accepted @User2 friend request
		EXEC uspInsertNotification @NotificationTypeId, @User1Id, @User2Id, @TodaysDate
		IF @@ERROR <> 0 
			ROLLBACK TRAN insertNotification
		ELSE
			COMMIT TRAN insertNotification
GO

EXEC sp_rename 'uspUpdateFriend', 'uspcUpdateFriend'
