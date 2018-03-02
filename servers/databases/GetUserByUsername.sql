/*
@param Username
Find relevant user information based on the given Username
*/

ALTER PROC GetUserByUsername 
@Username NVARCHAR(50)
As	
	--DECLARE @err_msg NVARCHAR(255)
	-- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.
	SET NOCOUNT ON
	IF EXISTS(SELECT UserId FROM [USER] WHERE Username = @Username)
		BEGIN
		SELECT UserId, UserFname, UserLname,UserEmail,PhotoUrl, UserDOB, Username FROM [USER] WHERE Username = @Username
		END
	ELSE
		BEGIN 
		PRINT'This Username does not exist.'
		RAISERROR('UserId is not found.', 11,1)
		RETURN
		END
