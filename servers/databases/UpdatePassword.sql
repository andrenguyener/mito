
CREATE PROC uspcUpdatePassword
@UserId INT,
@NewPass VARBINARY(MAX)
AS
	IF @NewPass IS NULL
	BEGIN
		PRINT'The given password is null'
		RAISERROR('@NewPass cannot be null',11,1)
	END
	EXEC dbo.uspGetMatchingUserId @UserId, @Id = @UserId OUT
	IF @UserId IS NULL
	BEGIN
		PRINT'The given user id is null or does not exist'
		RAISERROR('@UserId cannot be null',11,1)
		RETURN
	END
	BEGIN
		UPDATE [USER]
		SET PasswordHash = @NewPass WHERE UserId = @UserId
	END
GO
