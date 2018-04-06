/*
Update the username of the given UserId
*/

ALTER PROC uspUpdateUsername
@newUsername NVARCHAR(50),
@userId INT
AS
	IF @userId IS NULL
	BEGIN
		PRINT'The UserId is NULL'
		RAISERROR('@userId cannot be NULL',11,1)
		RETURN
	END

	IF EXISTS (SELECT * FROM [USER] WHERE Username = @newUsername AND UserId <> @userId)
		BEGIN
			PRINT'This username already exists. Please choose another username'
			RAISERROR('@newUsername cannot be duplicated',11,1)
			RETURN
		END

	BEGIN TRAN 
	UPDATE [USER]
	SET Username = @newUsername
	WHERE UserId = @userId
	
	IF @@ERROR <> 0 
		ROLLBACK TRAN
	ELSE
		COMMIT TRAN
GO

-- EXEC UpdateUsername 'andre', 7
EXEC sp_rename 'UpdateUsername', 'uspUpdateUsername'