--returns the number of mutual friend between 2 users
CREATE PROC uspcGetMutualFriendCount
@UserId1 INT,
@UserId2 INT,
@MutualFriendsCount INT OUT
AS
	BEGIN
	-- stores the list of user1's friend in a table variable
	DECLARE @User1FriendIdList TABLE(FriendId INT)
	INSERT @User1FriendIdList
	EXEC uspGetUserFriendsIdList @UserId1, 1

	-- stores the list of user2's friend in a table variable
	DECLARE @User2FriendIdList TABLE(FriendId INT)
	INSERT @User2FriendIdList
	EXEC uspGetUserFriendsIdList @UserId2, 1
	
	-- count the same id appears in both list
	SET @MutualFriendsCount =
	(SELECT COUNT(*) 
	FROM @User1FriendIdList List1
	JOIN @User2FriendIdList List2 ON List1.FriendId = List2.FriendId)
	END
GO

EXEC dbo.uspcGetUserFriendsById 7,1
EXEC dbo.uspcGetUserFriendsById 3,1

-- test example
DECLARE @Test INT
EXEC dbo.uspcGetMutualFriendCount 7, 3, @MutualFriendsCount = @Test OUT
PRINT @Test