CREATE PROC GetUserIdByEmail
@EmailAddress NVARCHAR(100),
@User_Id INT OUT
AS
	SET @User_Id = (SELECT UserEmail FROM [USER] WHERE UserEmail = @EmailAddress)
GO