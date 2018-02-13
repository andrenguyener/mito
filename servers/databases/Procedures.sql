-- Be aware of order of @Username1 and @Username2 passed in
ALTER PROC updateAcceptFriendRequest
@Username1 nvarchar(50),
@Username2 nvarchar(50)
AS
	DECLARE @User1Id INT = (SELECT UserId FROM [USER] WHERE Username = @Username1)
	DECLARE @User2Id INT = (SELECT UserId FROM [USER] WHERE Username = @Username2)
	DECLARE @FriendId INT = (SELECT FriendId FROM FRIEND WHERE User1Id = @User1Id AND User2Id = @User2Id)
	DECLARE @FriendTypeId INT = (SELECT FriendTypeId FROM FRIEND_TYPE WHERE FriendType = 'Pending')
	DECLARE @NotificationTypeId INT = (SELECT NotificationTypeId FROM NOTIFICATION_TYPE WHERE NotificationType = 'Pending')
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
			PRINT 'User1 never sent User2 a friend request'
			RAISERROR('@Username1 and @Username2 are not in FRIEND table',11,1)
			RETURN
		END
	-- Ensure Pending is a FRIEND_TYPE and NOTIFICATION_TYPE
	IF @FriendTypeId IS NULL OR @NotificationTypeId IS NULL
		BEGIN
			PRINT 'User1 does not have a pending friend request status with User2'
			RAISERROR('@Username1 and @Username2 do not have a pending friend request',11,1)
			RETURN
		END
	DECLARE @AcceptedFriendRequestId INT = (SELECT NotificationTypeId FROM [NOTIFICATION_TYPE] WHERE NotificationType = 'Accepted')
	BEGIN TRAN T1
		-- Insert a new notification that @Username2 accepted @Username1's friend request
		INSERT INTO NOTIFICATION (FriendId, NotificationTypeId, SendFrom, NotificationDate)
			VALUES(@FriendId, @AcceptedFriendRequestId, 0, GETDATE())
		IF @@ERROR <> 0
			ROLLBACK TRAN T1
		ELSE
			COMMIT TRAN T1
			DECLARE @AcquaintanceId INT = (SELECT FriendTypeId FROM [FRIEND_TYPE] WHERE FriendType = 'Acquaintance')
			-- Change the existing friendship from "Pending" to "Acquaintance"
			BEGIN TRAN T2
				UPDATE FRIEND
				SET FriendTypeId = @AcquaintanceId
				WHERE User1Id = @User1Id AND User2Id = @User2Id
				IF @@ERROR<> 0
					ROLLBACK TRAN T2
				ELSE
					COMMIT TRAN T2

/*
	Insert data into FRIEND table to record friend connection
	Insert notification into NOTIFICATION table to record notification sent to @Username2
	@Username1 sent a friend request to @Username2
	@FriendType will always be "Pending"
*/
ALTER PROC insertFriend
	@Username1 nvarchar(50),
	@Username2 nvarchar(50),
	@FriendType nvarchar(25)
	AS
	DECLARE @User1Id INT = (SELECT UserId FROM [USER] WHERE Username = @Username1)
	DECLARE @User2Id INT = (SELECT UserId FROM [USER] WHERE Username = @Username2)
	DECLARE @FriendTypeId INT = (SELECT FriendTypeId FROM FRIEND_TYPE WHERE FriendType = @FriendType)
	
	-- Check both users already exist in the [USER] database
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'User1 or User2 does not exist'
			RAISERROR('@Username1 or @Username2 is null', 11, 1)
			RETURN
		END

	-- Check @FriendType exists in FRIEND database
	IF @FriendTypeId IS NULL
		BEGIN
			PRINT 'FriendType does not exist'
			RAISERROR('@FriendType does not exist', 11, 1)
			RETURN
		END

	-- Check @Username1 and @Username2 aren't already friends in FRIEND table
	IF EXISTS (SELECT * FROM FRIEND WHERE User1Id = @User1Id AND User2Id = @User2Id)
		BEGIN
			PRINT 'User1 and User2 are already friends'
			RAISERROR('@User1Id and @User2Id are already in the table', 11, 1)
			RETURN
		END

	-- Reverse check order @Username1 and @Username2 aren't already friends in FRIEND table
	IF EXISTS (SELECT * FROM FRIEND WHERE User1Id = @User2Id AND User2Id = @User1Id)
		BEGIN
			PRINT 'User1 and User2 are already friends'
			RAISERROR('@User1Id and @User2Id are already in the table', 11, 1)
			RETURN
		END

	-- INSERT friendship between @Username1 and @Username2 in FRIEND table
	BEGIN TRAN
		INSERT INTO FRIEND (User1Id, User2Id, FriendTypeId) VALUES (@User1Id, @User2Id, @FriendTypeId)
		DECLARE @FriendId INT = (SELECT SCOPE_IDENTITY())
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
			-- Make sure pending is a type in the NOTIFICATION_TYPE table
			IF @FriendType = 'Pending'
				DECLARE @NotificationTypeId INT = (SELECT NotificationTypeId FROM NOTIFICATION_TYPE WHERE NotificationType = @FriendType)
				IF @NotificationTypeId IS NULL
					BEGIN
						PRINT 'Pending is not a type of notification'
						RAISERROR('@NotificationTypeId is null',11,1)
						RETURN
					END
				-- Insert notification that @Username1 sent to @Username2
				INSERT INTO NOTIFICATION (FriendId, NotificationTypeId, SendFrom, NotificationDate)
						VALUES(@FriendId, @NotificationTypeId, 0, GETDATE())

/*
	Insert a new user into the [USER] database
*/
ALTER PROC insertUser
@UserFname nvarchar(50),
@UserLname nvarchar(50),
@UserEmail nvarchar(100),
@PasswordHash varbinary(max),
@PhotoUrl nvarchar(max),
@UserDOB date,
@Username nvarchar(50)
AS
	-- Check username does not already exist
	IF EXISTS (SELECT * FROM [USER] WHERE Username = @Username)
			BEGIN
				PRINT 'Username already exists'
				RAISERROR('@Username is not unique', 11, 1)
				RETURN
			END
	-- Check email does not already exist in the database
	IF EXISTS (SELECT * FROM [USER] WHERE UserEmail = @UserEmail)
	BEGIN
		PRINT 'An account with this email already exists'
		RAISERROR('@UserEmail is already in the database', 11, 1)
		RETURN
	END
	-- Check that new user is at least 13 years old
	IF DATEDIFF(year,@UserDOB,GetDate()) < 13 
		BEGIN
			PRINT 'You must be at least 13 years old.'
			RAISERROR('@UserDOB is not in the valid range',11,1)
			RETURN 
		END

	--IF @PhotoUrl IS NULL
	--	BEGIN
	--		SET @PhotoUrl = 'path/to/default/image'
	--	END

	BEGIN TRAN
		INSERT INTO [USER] (UserFname, UserLname, UserEmail, PasswordHash, PhotoUrl, UserDOB, Username)
		VALUES (@UserFname, @UserLname, @UserEmail, @PasswordHash, @PhotoUrl, @UserDOB, @Username)
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN


CREATE FUNCTION checkUniquename(@Username nvarchar(50))
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS (SELECT * FROM USERNAME WHERE Username = @Username)
			Set @Ret = 1
		RETURN @Ret
END

ALTER TABLE USERNAME
ADD CONSTRAINT
CHECK (dbo.checkUniquename() = 0)