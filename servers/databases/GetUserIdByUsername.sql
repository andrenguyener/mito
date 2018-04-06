-- an output parameter SPROC for retrieving an UserId
-- @param Username 
CREATE PROC uspGetUserId
@Username NVARCHAR(50),
@User_Id INT OUT
AS
	SET @User_Id = (SELECT UserId FROM [USER] WHERE Username = @Username)

EXEC sp_rename 'GetUserId', 'uspGetUserId'