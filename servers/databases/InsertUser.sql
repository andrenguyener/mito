/*
	Insert a new user into the [USER] database
	and return the newly made user id as an output parameter
*/
ALTER PROC uspInsertUser
@UserFname nvarchar(50),
@UserLname nvarchar(50),
@UserEmail nvarchar(100),
@PasswordHash varbinary(max),
@PhotoUrl nvarchar(max),
@UserDOB date,
@Username nvarchar(50),
@RetNewUserId INT OUT
AS	
	DECLARE @UserId INT
	EXEC uspGetUserId @Username, @User_Id = @UserId OUT
	DECLARE @UserIdByEmail INT
	EXEC uspGetUserIdByEmail @UserEmail, @UserIdByEmail OUT
	
	-- Check username does not already exist
	IF @UserId IS NOT NULL
			BEGIN
				PRINT 'Username already exists'
				RAISERROR('@Username is not unique', 11, 1)
				RETURN
			END
	-- Check email does not already exist in the database
	IF @UserIdByEmail IS NOT NULL
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
		SET @RetNewUserId = (SELECT SCOPE_IDENTITY())
		--DECLARE @NewUserId INT = (SELECT SCOPE_IDENTITY())
		--EXEC GetUserById @NewUserId
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
