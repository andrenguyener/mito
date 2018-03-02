SELECT * FROM [USER]

ALTER PROC UpdateUserProfile
@Id INT,
@Fname NVARCHAR(50),
@Lname NVARCHAR(50),
@Email NVARCHAR(100),
@Photo NVARCHAR(max),
@DOB DATE,
@Username NVARCHAR(50)
AS 
	IF EXISTS (SELECT * FROM [USER] WHERE Username = @Username AND UserId <> @Id 
		OR UserEmail = @Email AND UserId <> @Id)
		BEGIN
			PRINT'This username already exists. Please choose another username'
			RAISERROR('@Username cannot be duplicated',11,1)
			RETURN
		END

	IF DATEDIFF(YEAR, @DOB, GETDATE()) < 13
		BEGIN
			PRINT'You must be at least 13 years old'
			RAISERROR('The difference between @DOB and todays date must be at least 13 years a part',11,1)
			RETURN
		END

	BEGIN TRAN
		UPDATE [USER]
		SET UserFname = @Fname, UserLname = @Lname, UserEmail = @Email, 
		PhotoUrl = @Photo, UserDOB = @DOB, Username = @Username
		WHERE UserId = @Id
		IF @@ERROR <> 0
			ROLLBACK TRAN
		ELSE
			COMMIT TRAN
GO

SELECT * FROM [USER] WHERE UserId = 7

--EXEC UpdateUserProfile 7, 'Sopheaky', 'Neaky', 'sneak@uw.edu', 'PHOTOURL', '1/01/2008', 'sneak'
