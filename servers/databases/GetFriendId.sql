/*
@params: username1,username, an initialized value to hold the FriendId
GetFriendId query the FRIEND table with 2 usernames to find whether they are friend
or not (order is not important). If the 2 usernames are friend, then it will return the FriendId of the pair
If the 2 usernames are NOT friend, it will return NULL
*/
ALTER PROC GetFriendID
@Username1 NVARCHAR(50),
@Username2 NVARCHAR(50),
@MatchedFriendId INT OUT
AS
	DECLARE @IdUsername1 INT 
	DECLARE @IdUsername2 INT
	-- Execute a function to find the UserId based on the given Username
	EXEC GetUserId @Username1, @User_Id = @IdUsername1 OUT
	EXEC GetUserId @Username2, @User_Id = @IdUsername2 OUT

	-- Check whether or not both of the given usernames are in the database
	IF @IdUsername1 IS NULL OR @IdUsername2 IS NULL
		BEGIN
			PRINT 'One or both usernames are not registered in our system'
			RAISERROR('@IdUsername1 and @IdUsername2 cannot be NULL', 11, 1)
			RETURN
		END

	-- Find the FriendId based on Username1 and Username2 (in that order)
	-- If found, set the output parameter to that FriendId
	SET @MatchedFriendId = (SELECT FriendId FROM FRIEND WHERE User1Id = @IdUsername1 
		AND User2Id = @IdUsername2)
	-- If not, find the FriendId based on Username2 and Username1 (in that order)
	-- If found, set the output parameter to that FriendId
	-- If not found, simply return a NULL output 
	IF @MatchedFriendId IS NULL
		BEGIN
		PRINT 'Found NULL'
		SET @MatchedFriendId = (SELECT FriendId FROM FRIEND WHERE User1Id = @IdUsername2 
			AND User2Id = @IdUsername1)
		END
GO