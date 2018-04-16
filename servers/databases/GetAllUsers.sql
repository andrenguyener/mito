/*
Get all users basic information
*/

ALTER PROC uspcGetAllUsers 
As	
	--DECLARE @err_msg NVARCHAR(255)
	-- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.
	SET NOCOUNT ON
	IF EXISTS(SELECT UserId, UserFname, UserLname,UserEmail,PhotoUrl, UserDOB, Username FROM [USER])
		BEGIN
		SELECT UserId, UserFname, UserLname,UserEmail,PhotoUrl, 
		UserDOB, Username, NumFriends FROM [USER]
		--FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		END
	ELSE
		BEGIN 
		PRINT'There is no user in the database'
		RAISERROR('No user not found.', 11,1)
		RETURN
		END

EXEC sp_rename 'uspGetAllUsers', 'uspcGetAllUsers'

EXEC dbo.uspGetAllUsers