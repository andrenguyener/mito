/*
Retreive a user id based on the given email address
@param a valid email address
output param: a matched user id 
*/
CREATE PROC GetUserIdByEmail
@EmailAddress NVARCHAR(100),
@User_Id INT OUT
AS
	SET @User_Id = (SELECT UserEmail FROM [USER] WHERE UserEmail = @EmailAddress)
GO