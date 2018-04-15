/*
@param UserId
Find relevant user information based on the given UserId
*/

ALTER PROC uspcGetUserById 
@UserId INT
As	
	--DECLARE @err_msg NVARCHAR(255)
	-- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.
	SET NOCOUNT ON
	IF EXISTS(SELECT UserId FROM [USER] WHERE UserId = @UserId)
		BEGIN
		DECLARE @FriendCount INT
		EXEC dbo.uspGetUserFriendCount @UserId, @Count = @FriendCount OUT
		SELECT UserId, UserFname, UserLname,UserEmail,PhotoUrl, 
		UserDOB, Username, @FriendCount AS NumFriends 
		FROM [USER] WHERE UserId = @UserId
		--FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		END
	ELSE
		BEGIN 
		PRINT'UserId does not exist.'
		RAISERROR('UserId is not found.', 11,1)
		RETURN
		END

EXEC sp_rename 'uspGetUserById', 'uspcGetUserById'

--example call
EXEC dbo.uspcGetUserById 7