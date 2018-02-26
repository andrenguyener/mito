/*
@params: user1,user2, an initialized value to hold the FriendId
GetFriendId queries the FRIEND table with 2 usernames to find whether they are friend
or not (order is not important). If the 2 usernames are friend, then it will return the FriendId of the pair
If the 2 usernames are NOT friend, it will return NULL
*/
CREATE PROC GetFriendIdByUsersId
@UserId1 INT,
@UserId2 INT,
@MatchedFriendId INT OUT
AS
	-- Check whether or not both of the given usernames are in the database
	IF @UserId1 IS NULL OR @UserId2 IS NULL
		BEGIN
			PRINT 'One or both UserId are not registered in our system'
			RAISERROR('@UserId1 and @UserId2 cannot be NULL', 11, 1)
			RETURN
		END

	-- Find the FriendId based on Username1 and Username2 (in that order)
	-- If found, set the output parameter to that FriendId
	SET @MatchedFriendId = (SELECT FriendId FROM FRIEND WHERE User1Id = @UserId1 
		AND User2Id = @UserId1)
	-- If not, find the FriendId based on Username2 and Username1 (in that order)
	-- If found, set the output parameter to that FriendId
	-- If not found, simply return a NULL output 
	IF @MatchedFriendId IS NULL
		BEGIN
		PRINT 'Found NULL'
		SET @MatchedFriendId = (SELECT FriendId FROM FRIEND WHERE User1Id = @UserId2 
			AND User2Id = @UserId2)
		END
GO