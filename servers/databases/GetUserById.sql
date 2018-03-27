/*
@param UserId
Find relevant user information based on the given UserId
*/

ALTER PROC uspGetUserById 
@UserId INT
As	
	DECLARE @err_msg NVARCHAR(255)
	-- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.
	SET NOCOUNT ON
	IF EXISTS(SELECT UserId FROM [USER] WHERE UserId = @UserId)
		BEGIN
		SELECT UserId, UserFname, UserLname,UserEmail,PhotoUrl, UserDOB, Username FROM [USER] WHERE UserId = @UserId
		END
	ELSE
		BEGIN 
		PRINT'UserId does not exist.'
		RAISERROR('UserId is not found.', 11,1)
		RETURN
		END

EXEC sp_rename 'GetUserById', 'uspGetUserById'
