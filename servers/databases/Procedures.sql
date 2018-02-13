SELECT * FROM [USER]
SELECT * FROM FRIEND_TYPE
SELECT * FROM FRIEND
SELECT * FROM [NOTIFICATION]
SELECT * FROM NOTIFICATION_TYPE

INSERT INTO NOTIFICATION_TYPE (NotificationType, LinkToView, [Message])
		VALUES ('Friend Request', 'www.sample.com', 'has sent a friend request')

--CREATE PROC insertNotification
--@
ALTER PROC insertFriend
	@Username1 nvarchar(50),
	@Username2 nvarchar(50),
	@FriendType nvarchar(25)
	AS
	DECLARE @User1Id INT = (SELECT UserId FROM [USER] WHERE Username = @Username1)
	DECLARE @User2Id INT = (SELECT UserId FROM [USER] WHERE Username = @Username2)
	DECLARE @FriendTypeId INT = (SELECT FriendTypeId FROM FRIEND_TYPE WHERE FriendType = @FriendType)
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'User1 or User2 does not exist'
			RAISERROR('@Username1 or @Username2 is null', 11, 1)
			RETURN
		END
	IF @FriendTypeId IS NULL
		BEGIN
			PRINT 'FriendType does not exist'
			RAISERROR('@FriendType does not exist', 11, 1)
			RETURN
		END
	IF EXISTS (SELECT * FROM FRIEND WHERE User1Id = @User1Id AND User2Id = @User2Id)
		BEGIN
			PRINT 'User1 and User2 are already friends'
			RAISERROR('@User1Id and @User2Id are already in the table', 11, 1)
			RETURN
		END
	IF EXISTS (SELECT * FROM FRIEND WHERE User1Id = @User2Id AND User2Id = @User1Id)
		BEGIN
			PRINT 'User1 and User2 are already friends'
			RAISERROR('@User1Id and @User2Id are already in the table', 11, 1)
			RETURN
		END
	BEGIN TRAN
		INSERT INTO FRIEND (User1Id, User2Id, FriendTypeId) VALUES (@User1Id, @User2Id, @FriendTypeId)
		DECLARE @FriendId INT = (SELECT SCOPE_IDENTITY())
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
			IF @FriendType = 'Pending'
				DECLARE @NotificationTypeId INT = (SELECT NotificationTypeId FROM NOTIFICATION_TYPE WHERE NotificationType = @FriendType)
				IF @NotificationTypeId IS NULL
					BEGIN
						PRINT 'Pending is not a type of notification'
						RAISERROR('@NotificationTypeId is null',11,1)
						RETURN
					END
				INSERT INTO NOTIFICATION (FriendId, NotificationTypeId, SendFrom, NotificationDate)
						VALUES(@FriendId, @NotificationTypeId, 0, GETDATE())

EXEC insertFriend @Username1 = 'andre', @Username2 = 'guopher8', @FriendType = 'Pending'

DECLARE @pwd varbinary(max) = CAST('wat' AS VARBINARY(MAX))
EXEC insertUser @UserFname = 'Andre', 
				@UserLname = 'Nguyen', 
				@UserEmail = 'andre@uw.edu',
				@PasswordHash = @pwd,
				@PhotoUrl = NULL,
				@UserDOB = '03-08-1997',
				@Username = 'andre'

ALTER PROC insertUser
@UserFname nvarchar(50),
@UserLname nvarchar(50),
@UserEmail nvarchar(100),
@PasswordHash varbinary(max),
@PhotoUrl nvarchar(max),
@UserDOB date,
@Username nvarchar(50)
AS
	IF EXISTS (SELECT * FROM [USER] WHERE Username = @Username)
			BEGIN
				PRINT 'Username already exists'
				RAISERROR('@Username is not unique', 11, 1)
				RETURN
			END

	IF EXISTS (SELECT * FROM [USER] WHERE UserEmail = @UserEmail)
	BEGIN
		PRINT 'An account with this email already exists'
		RAISERROR('@UserEmail is already in the database', 11, 1)
		RETURN
	END

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