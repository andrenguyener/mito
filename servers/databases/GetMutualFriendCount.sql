--returns a list of mutual friend between 2 users
ALTER PROC uspcGetMutualFriendCount
@UserId1 INT,
@UserId2 INT
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
	SELECT UserId, Username, UserFname, UserLname,UserEmail, PhotoUrl FROM [USER] U
	JOIN 
	(SELECT List1.FriendId FROM @User1FriendIdList List1
	JOIN @User2FriendIdList List2 ON List1.FriendId = List2.FriendId
	) UserFriendList
	ON U.UserId = UserFriendList.FriendId
	END
GO

-- test example
EXEC dbo.uspcGetUserFriendsById 7,1
EXEC dbo.uspcGetUserFriendsById 3,1
EXEC dbo.uspcGetMutualFriendCount 7, 3
