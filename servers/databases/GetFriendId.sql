/*
@params: user 1 Id,user 2 Id, and an initialized value to hold the FriendId
GetFriendId queries the FRIEND table with 2 usernames to find whether they are friend
or not (order is not important). If the 2 usernames are friend, then it will return the FriendId of the pair
If the 2 users are NOT friend, it will return NULL
*/
ALTER PROC uspGetFriendId
@User1Id INT,
@User2Id INT,
@MatchedFriendId INT OUT
AS
	-- Check whether or not both of the given usernames are in the database
	IF @User1Id IS NULL OR @User2Id IS NULL
		BEGIN
			PRINT 'One or both of these users are not registered in our system'
			RAISERROR('@User1Id and @User2Id cannot be NULL', 11, 1)
			RETURN
		END

	-- Find the FriendId based on Username1 and Username2 (in that order)
	-- If found, set the output parameter to that FriendId
	SET @MatchedFriendId = (SELECT FriendId FROM FRIEND WHERE User1Id = @User1Id 
		AND User2Id = @User2Id)
	-- If not, find the FriendId based on Username2 and Username1 (in that order)
	-- If found, set the output parameter to that FriendId
	-- If not found, simply return a NULL output 
	IF @MatchedFriendId IS NULL
		BEGIN
		SET @MatchedFriendId = (SELECT FriendId FROM FRIEND WHERE User1Id = @User2Id 
			AND User2Id = @User1Id)
		END
GO
EXEC sp_rename 'GetFriendId', 'uspGetFriendId'
