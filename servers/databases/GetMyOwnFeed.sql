ALTER PROC uspcGetMyOwnFeed
@UserId INT
AS
BEGIN
	-- stores the list of user1's friend in a table variable
	DECLARE @MyFriendIdList TABLE(FriendId INT)
	INSERT @MyFriendIdList
	EXEC uspGetUserFriendsIdList @UserId, 1
	-- filter to only have SendFrom column that has value of 
	-- user friendId and my own Id from SendTo
	SELECT OrderId, SenderId, RecipientId,OrderMessage, OrderDate FROM [ORDER] O
	JOIN @MyFriendIdList MF ON O.SenderId = MF.FriendId
	WHERE O.RecipientId = @UserId
	--Combine the two SELECT into one
	UNION
	-- filter to only have SendTo column that has value of 
	-- user friendId and my own Id from SendFrom
	SELECT OrderId, SenderId, RecipientId,OrderMessage, OrderDate FROM [ORDER] O2
	JOIN @MyFriendIdList MF2 ON O2.RecipientId = MF2.FriendId
	WHERE O2.SenderId = @UserId
	ORDER BY OrderDate
END

EXEC dbo.uspcGetMyOwnFeed 7
